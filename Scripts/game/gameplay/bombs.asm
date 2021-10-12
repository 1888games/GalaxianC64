BOMBS: {

	* = * "Bombs"

	// Explosion = 0
	// Enemies - Sprites 1-7
	// Flagship = 1
	// Escorts = 2 & 3
	// Individuals 4 - 7


	// Bombs - Sprites 8-16

	// Our bullet = 17
	// Ship - Sprites 18-19

	.label BombStartID = 8
	.label Pointer =49
	.label BombEndID = BombStartID + 9
	.label ReloadTime = 15

	Active: 		.fill MAX_ENEMIES + MAX_BOMBS, 0

	PixelSpeedX:	.fill MAX_ENEMIES + MAX_BOMBS, 0
	PixelSpeedY:	.fill MAX_ENEMIES + MAX_BOMBS, 1
	FractionSpeedX:	.fill MAX_ENEMIES + MAX_BOMBS, 0
	FractionSpeedY:	.fill MAX_ENEMIES + MAX_BOMBS, 0

	BombsLeft:				.fill MAX_ENEMIES, 0
	ShotTimer:				.fill MAX_ENEMIES, 0

	MoveX:	.byte 0
	MoveY:	.byte 0
	ActiveBombs:	.byte 0

	MoveXReverse:	.byte 0
	MoveYReverse:	.byte 0

	.label MaxY = 250

	PixelLookup:

	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.byte 2,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0
	.byte 2,2,2,1,1,1,0,0,0,0,0,0,0,0,0,0
	.byte 2,2,2,2,2,1,1,1,1,0,0,0,0,0,0,0
	.byte 2,2,2,2,2,2,1,1,1,1,1,0,0,0,0,0
	.byte 2,2,2,2,2,2,2,1,1,1,1,1,1,1,0,0
	.byte 2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1
	.byte 2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1
	.byte 2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1
	.byte 2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1
	.byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1
	.byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	.byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	.byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	.byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	.byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2


	FractionLookup:
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.byte 188,188,94,233,175,140,117,100,88,78,70,64,58,54,50,47
	.byte 188,188,188,211,94,24,233,200,175,156,140,127,117,108,100,93
	.byte 188,188,188,188,13,164,94,44,7,233,210,191,175,162,150,140
	.byte 188,188,188,188,188,48,211,144,94,55,24,255,233,215,200,187
	.byte 188,188,188,188,188,188,71,244,182,133,94,62,36,13,250,233
	.byte 188,188,188,188,188,188,188,88,13,211,164,126,94,67,44,24
	.byte 188,188,188,188,188,188,188,188,101,32,234,189,152,121,94,71
	.byte 188,188,188,188,188,188,188,188,188,110,48,253,211,175,144,117
	.byte 188,188,188,188,188,188,188,188,188,188,118,61,13,229,194,164
	.byte 188,188,188,188,188,188,188,188,188,188,188,124,71,26,244,211
	.byte 188,188,188,188,188,188,188,188,188,188,188,188,130,80,38,1
	.byte 188,188,188,188,188,188,188,188,188,188,188,188,188,134,88,48
	.byte 188,188,188,188,188,188,188,188,188,188,188,188,188,188,138,95
	.byte 188,188,188,188,188,188,188,188,188,188,188,188,188,188,188,141
	.byte 188,188,188,188,188,188,188,188,188,188,188,188,188,188,188,188



	Fire: {

		ldy #BombStartID

		FindLoop:

			lda Active, y
			beq Found

			iny
			cpy #BombEndID
			bcc FindLoop

			jmp Finish


		Found:

			ldx ZP.EnemyID
		
			jsr SetupSprite
			jsr CalculateDistanceToPlayer
	
			inc ActiveBombs

			ldx ZP.EnemyID

		Finish:

		rts

	}


	SetupSprite: {

		lda SpriteY, x
		sec
		sbc #8
		sta SpriteY, y

		lda #1
		sta Active, y

		lda SpriteX, x
		clc
		adc #4
		sta SpriteX, y

		lda #0
		sta SpriteX_LSB, y
		sta SpriteY_LSB, y

		lda #WHITE
		sta SpriteColor, y

		lda #Pointer
		sta SpritePointer, y

		sty ZP.CurrentID


		rts	
	}

	CalculateDistanceToPlayer: {

		lda #-16
		sec 
		sbc SpriteY, x
		sta ZP.D

		lda SHIP.PosX_MSB
		sec
		sbc SpriteX, x
		bcs DontNegate


	Negate:

		eor #%11111111
		clc
		adc #1

		jsr ComputeBulletDelta

		ldy ZP.CurrentID
		sta FractionSpeedX, y

		
		lda #1
		sta PixelSpeedX, y

		rts

	DontNegate:

		jsr ComputeBulletDelta

		ldy ZP.CurrentID
		sta FractionSpeedX, y

	
		lda #0
		sta PixelSpeedX, y

		rts
	}


	ComputeBulletDelta: {

		jsr CalculateTangent
		jsr RANDOM.Get
		and #%00011111
		clc
		adc ZP.C
		clc
		adc #6
		bpl Finish

		lda #127

		Finish:



		rts
	}

	// 0048: 0E 00         ld   c,$00
	// 004A: 06 08         ld   b,$08
	// 004C: BA            cp   d
	// 004D: 38 01         jr   c,$0050
	// 004F: 92            sub  d
	// 0050: 3F            ccf
	// 0051: CB 11         rl   c
	// 0053: CB 1A         rr   d
	// 0055: 10 F5         djnz $004C
	// 0057: C9            ret
		

	CalculateTangent: {

		ldy #0
		sty ZP.C

		ldy #8

		Loop:

			cmp ZP.D
			bcs Skip

			sec
			sbc ZP.D

		Skip:

			rol
			eor #%00000001
			ror

			rol ZP.C
			ror ZP.D

			dey
			bne Loop

		rts
			

	}

	 CalculateRequiredSpeed: {

	 	lda MoveX
	 	bpl XNotReverse

	 	MinusX:

		 	eor #%11111111
		 	clc
		 	adc #1
		 	sta MoveX

	 	XNotReverse:

	 	CheckMagnitude:

		 	lda MoveX
		 	cmp #16
		 	bcc XOkay

		 	lsr MoveX
		 	lsr MoveY
		 	jmp CheckMagnitude

	 	XOkay:

	 		lda MoveY
	 		cmp #16
	 		bcc CalculateXSpeed

	 		lsr MoveX
	 		lsr MoveY

	 		jmp XOkay


		CalculateXSpeed:

			lda MoveX
			asl
			asl
			asl
			asl
			clc
			adc MoveY
			tay

			lda PixelLookup, y
			sta PixelSpeedX, x

			lda FractionLookup, y
			sta FractionSpeedX, x


		CalculateYSpeed:

			lda MoveY
			asl
			asl
			asl
			asl
			clc
			adc MoveX
			tay

			lda PixelLookup, y
			sta PixelSpeedY, x

			lda FractionLookup, y
			sta FractionSpeedY, x

		rts


	 }



	 CheckMove: {

	 	lda SpriteY, x
	 	cmp #20
	 	bcc Reached
	
			lda PixelSpeedX, x
			bne MoveLeft


		MoveRight:

			lda SpriteX_LSB, x
			clc
			adc FractionSpeedX, x
			sta SpriteX_LSB, x

			lda SpriteX, x
			adc #0
			sta SpriteX, x

			jmp MoveYNow

		MoveLeft:

			lda SpriteX_LSB, x
			sec
			sbc FractionSpeedX, x
			sta SpriteX_LSB, x

			lda SpriteX, x
			sbc #0
			sta SpriteX, x

		MoveYNow:

			lda SpriteY, x
			clc
			adc #2
			sta SpriteY, x
				
			rts

		Reached:

			lda #0
			sta Active, x

			lda #10
			//sta SpriteX, x
			sta SpriteY, x

			dec ActiveBombs

		Done:

		rts
	}	


	

	CheckCollision: {

		lda SHIP.Active
		beq NoCollision

		lda #SHIP.SHIP_Y
		sec
		sbc #14
		sec
		sbc SpriteY, x
		adc #7
		cmp #14
		bcs NoCollision

		lda SHIP.PosX_MSB
		clc
		adc #3
		sec
		sbc SpriteX, x
		clc
		adc #7
		cmp #14
		bcs CheckDualFighter

		Collision:

			jsr SHIP.KillMainShip

		DestroyBombs:

			lda SHIP.Active
			bne NotDead

			ldy #BombStartID

			DestroyLoop:

				lda #0
				sta Active, y

				lda #10
			//	sta SpriteX, y
				sta SpriteY, y

				iny
				cpy #BombStartID + 6
				bcc DestroyLoop

				lda  #0
				sta ActiveBombs

				rts

			NotDead:

				lda #0
				sta Active, x


				lda #10
			//	sta SpriteX, x
				sta SpriteY, x

				dec ActiveBombs

				rts



		CheckDualFighter:

			lda SHIP.DualFighter
			clc
			adc SHIP.TwoPlayer
			beq NoCollision

			lda SHIP.PosX_MSB + 1
			clc
			adc #3
			sec
			sbc SpriteX, x
			clc
			adc #7
			cmp #14
			bcs NoCollision

			jsr SHIP.KillDualShip
			jmp DestroyBombs

		NoCollision:




		rts
	}

	FrameUpdate: {

		Again:

		ldx #BombStartID

		Loop:	

			stx ZP.StoredXReg

			lda Active, x
			beq EndLoop

			jsr CheckCollision

			lda Active, x
			beq EndLoop

			jsr CheckMove
		

		EndLoop:

			ldx ZP.StoredXReg
			inx
			cpx #BombEndID
			bcc Loop

		Finish:

			lda ENEMY.Repeated
			cmp #1
			bne DontRepeat

			inc ENEMY.Repeated
			jmp Again

		DontRepeat:

	 	rts
	 }


	

	


}