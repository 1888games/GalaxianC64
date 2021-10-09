BULLETS: {


	* = * "Bullets"
	
	BulletSpriteX:		.byte 0, 0, 0, 0
	SpriteY_MSB:		.byte 0, 0, 0, 0
	SpriteY_LSB:		.byte 0, 0, 0, 0


	CharX:		.byte 255, 255, 255, 255
	CharY:		.byte 0, 0, 0, 0

	OffsetX:	.byte 0, 0, 0, 0
	OffsetY:	.byte 0, 0, 0, 0


	CharLookups:	.byte 179, 180, 181, 182
	Cooldown:		.byte CooldownTime, CooldownTime
	MaxBullets:		.byte 1, 4
	BulletToDie:	.byte 0
	PlayerShooting:	.byte 0
	PlayerLookup:	.byte 0, 0, 1, 1

	.label SPEED_MSB = 5
	.label SPEED_LSB = 250
	.label CooldownTime = 3
	.label SpriteYOffset = 12

	.label BulletSpriteID = 17
	.label BulletSpritePointer = 148

	ActiveBullets:		.byte 0, 0



	
	Fire2: {

		lda FORMATION.EnemiesLeftInStage
		clc
		adc ATTACKS.OrphanedFighterColumn
		bne CanFire	

			jmp AbortFire

		CanFire:

			sty ZP.Amount

			lda Cooldown + 1
			beq CooldownExpired

			jmp Finish

		CooldownExpired:

			ldx #2

		CheckOneBullet:

			lda ActiveBullets + 1
			cmp MaxBullets + 1
			bcs AbortFire


		FindLoop:

			lda CharX, x
			bmi SetupData

			inx
			cpx MaxBullets + 1
			bcc FindLoop

			jmp AbortFire

		SetupData:


			sfx(SFX_FIRE)

		NoSFX:

			lda #SHIP.CharY
			sta CharY, x
			
			lda SHIP.CharX + 1, y
			sta CharX, x

			lda #0
			sta SpriteY_LSB, x

			lda #SHIP.SHIP_Y
			sec
			sbc #SpriteYOffset
			sta SpriteY_MSB, x

			lda SHIP.PosX_MSB + 1, y
			sta BulletSpriteX, x

			lda #0
			sta OffsetY, x

			lda SHIP.OffsetX + 1, y
			lsr
			cmp #4
			bcc Okay

			
			.break
			nop

			
			ldy #0

		Okay:

			sta OffsetX, x

			inc ActiveBullets + 1

			jsr SetupSprite

			lda #1
			sta BULLETS.PlayerShooting

			jsr STATS.Shoot

		NoDual:

			lda #CooldownTime
			sta Cooldown + 1

		Finish:

			lda #0
			rts

		AbortFire:

			lda #255
			rts



		rts
	}

	
	Fire: {

		lda FORMATION.EnemiesLeftInStage
		clc
		adc ATTACKS.OrphanedFighterColumn
		bne CanFire	

			jmp AbortFire

		CanFire:

			sty ZP.Amount

			lda Cooldown
			beq CooldownExpired

			jmp Finish

		CooldownExpired:

			ldx #0

			lda SHIP.DualFighter
			beq CheckOneBullet

		CheckTwoBullet:

			lda ZP.Amount
			bne CheckOneBullet

			lda ActiveBullets
			cmp #3
			bcs AbortFire

		CheckOneBullet:

			lda ActiveBullets
			cmp MaxBullets
			bcs AbortFire


		FindLoop:

			lda CharX, x
			bmi SetupData

			inx
			cpx MaxBullets
			bcc FindLoop

			jmp AbortFire

		SetupData:


			cpy #1
			beq NoSFX

			sfx(SFX_FIRE)
			//sfx(SFX_BADGE)
				
		NoSFX:

			lda #SHIP.CharY
			sta CharY, x
			
			lda SHIP.CharX, y
			sta CharX, x

			lda #0
			sta SpriteY_LSB, x

			lda #SHIP.SHIP_Y
			sec
			sbc #SpriteYOffset
			sta SpriteY_MSB, x

			lda SHIP.PosX_MSB, y
			sta BulletSpriteX, x

			lda #0
			sta OffsetY, x

			lda SHIP.OffsetX, y
			lsr
			cmp #4
			bcc Okay

			lda #3

			//.break
		//	nop

		Okay:

			sta OffsetX, x

			inc ActiveBullets

			jsr SetupSprite

			lda #0
			sta BULLETS.PlayerShooting

			jsr STATS.Shoot

			lda SHIP.DualFighter
			beq NoDual

			lda ZP.Amount
			bne NoDual

			jmp Finish

		NoDual:

			lda #CooldownTime
			sta Cooldown

		Finish:

			lda #0
			rts

		AbortFire:

			lda #255
			rts

	}


	

	SetupSprite: {

		lda BulletSpriteX
		sta SpriteX + BulletSpriteID

		lda #YELLOW
		sta SpriteColor + BulletSpriteID

		lda #BulletSpritePointer
		sta SpritePointer + BulletSpriteID

		lda SpriteY_MSB
		sta SpriteY + BulletSpriteID

		rts
	}

	UpdateSprite: {

		lda SpriteY_MSB
		sta SpriteY + BulletSpriteID


		rts
	}

	
	Move: {

		ldx #0

		BulletLoop:	

			stx ZP.StoredXReg

			lda PlayerLookup, x
			sta PlayerShooting

			lda CharX, x
			bmi EndLoop

			lda CharY, x
			sta ZP.Temp1

			lda SpriteY_LSB, x
			sec
			sbc #SPEED_LSB
			sta SpriteY_LSB, x

			lda SpriteY_MSB, x
			sta ZP.Amount
			sbc #0
			sec
			sbc #SPEED_MSB
			sta SpriteY_MSB, x

			jsr CheckSpriteCollisions
			ldx ZP.StoredXReg


		CheckOffset:

			lda SpriteY_MSB, x
			sec
			sbc ZP.Amount
			clc
			adc OffsetY, x
			sta OffsetY, x

			bpl EndLoop

			clc
			adc #8
			sta OffsetY, x

			dec CharY, x
			lda CharY, x
			cmp #253
			beq BulletDead

			
			
			jsr UpdateSprite
			jsr CheckFormationCollision

			
			
			jmp EndLoop

		BulletDead:

			jsr CheckOrphanedCollision

			lda #1
			sta Cooldown

			jsr KillBullet

		EndLoop:

			ldx ZP.StoredXReg
			inx
			cpx #4
			bcc BulletLoop


			rts


	}


	CheckOrphanedCollision: {

		lda ATTACKS.OrphanedFighterColumn
		beq Finish

		sta ZP.Amount

		lda CharX, x
		sec
		sbc ZP.Amount
		cmp #2
		bcs Finish

		lda SpriteX + SHIP.MAIN_SHIP_POINTER + 1
		sta ZP.Column

		lda SpriteY + SHIP.MAIN_SHIP_POINTER + 1
		sta ZP.Row

		lda #10
		//sta SpriteX + SHIP.MAIN_SHIP_POINTER + 1
		sta SpriteY + SHIP.MAIN_SHIP_POINTER + 1

		lda #255
		sta ATTACKS.BeamBoss
		sta ATTACKS.OrphanedFighterID

		lda #0
		sta ATTACKS.BeamStatus
		sta ATTACKS.OrphanedFighterColumn
		sta ATTACKS.AddFighterToWave

		ldy #8
		jsr SCORE.AddScore

		ldy #2
		jsr BONUS.ShowBonus
	
		Finish:


		rts
	}


	KillBullet: {

		lda #10
		sta SpriteY + BulletSpriteID

		ldx #0
		lda #255
		sta CharX, x

		lda SHIP.TwoPlayer
		beq OnePlayer

		cpx #2
		bcc OnePlayer

		dec ActiveBullets + 1
		bpl Okay

		lda #0
		sta ActiveBullets + 1
		rts

		OnePlayer:

		dec ActiveBullets
		bpl Okay

		lda #0
		sta ActiveBullets


		Okay:

		lda #1
		sta FORMATION.Starting
	

		rts


	}


	CheckSpriteCollision: {
		
		ldx ZP.StoredXReg


		
		lda BULLETS.BulletSpriteX, x
		sec
		sbc #4
		sec
		ldx ZP.StoredYReg
		sbc SpriteX, x

		clc
		adc #6
		cmp #12

		bcs NoCollision

		ldx ZP.StoredXReg
		lda BULLETS.SpriteY_MSB, x
		sec
		ldx ZP.StoredYReg
		sbc SpriteY, x
		adc #8
		cmp #16
		bcs NoCollision


		jsr ENEMY.Kill

		lda #1
		sta BulletToDie


		NoCollision:


		rts
	}

	CheckSpriteCollisions: {

		ldx #0
		stx BulletToDie

		Loop:

			stx ZP.StoredYReg

			lda ENEMY.Plan, x
			beq EndLoop

			cmp #PLAN_EXPLODE
			beq EndLoop

			jsr CheckSpriteCollision


			EndLoop:

				ldx ZP.StoredYReg
				inx
				cpx #MAX_ENEMIES
				bcc Loop


		lda BulletToDie
		beq BulletAlive

		lda #1
		sta Cooldown

		ldx ZP.StoredXReg
		jsr KillBullet

		BulletAlive:

		rts
	}

	CheckFormationCollision: {

		lda CharY, x
		cmp #13

		bcc NotTooLow

		rts

		NotTooLow:

		ldy #47

		Loop:

			sty ZP.StoredYReg

			lda FORMATION.Occupied, y
			beq EndLoop

			lda CharY, x
			sec
			sbc FORMATION.Home_Row, y
			sta ZP.Temp4
			cmp #2
			bcc WithinRange

			cmp #5
			bcs EndLoop

		WithinRange:

			lda FORMATION.FormationSpriteX, y
			sta ZP.Amount

			lda BulletSpriteX, x
			sec
			sbc ZP.Amount
			clc
			adc #9
			cmp #18
			bcs EndLoop

			pha

			lda FORMATION.Direction
			beq GoingLeft

		GoingRight:

			pla
			cmp #14
			bcs Missed

			cmp #4
			bcc EndLoop

			jmp NoOffsetCheck

		GoingLeft:	

			pla
			cmp #3
			bcc Missed

			cmp #15
			bcs EndLoop

			jmp NoOffsetCheck

			Missed:

				lda #1
				sta FORMATION.Stopping

				jmp EndLoop

			NoOffsetCheck:

			lda ZP.Temp4
			cmp #2
			bcs EndLoop

			tya
			tax
			jsr FORMATION.Hit

			jsr ENEMY.CreateExplosion

			ldy ZP.StoredYReg

			lda FORMATION.FormationSpriteX, y
			sec
			sbc #4
			sta SpriteX, x

			lda FORMATION.SpriteRow, y
			sec
			sbc #6
			sta SpriteY, x

			ldx ZP.StoredXReg

			lda #1
			sta Cooldown
			jsr KillBullet

			jmp Finish

			EndLoop:

				ldy ZP.StoredYReg
				dey
				bmi Finish

				jmp Loop


		Finish:


		rts
	}

	FrameUpdate: {

		jsr Move

		lda Cooldown + 1
		beq Done

		dec Cooldown + 1

		Done:

		lda Cooldown
		beq Finish

		dec Cooldown

		Finish:

			rts


	}

}