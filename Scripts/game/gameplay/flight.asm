.namespace CHARGER {

	* = * "Flight"


	FlightJumpTable: 	.word 0, PacksBags, FliesInArc, ReadyToAttack, AttackingPlayer
						.word NearBottomOfScreen, ReachedBottomOfScreen, ReturningToSwarm
						.word ContinuingAttackFromTop, FullSpeedCharge, AttackingAggressively, LoopTheLoop
						.word CompleteLoop, Unknown_1091


	SpeedLookup:		.byte 2, 2, 3, 1, 2, 1			


	AlienArcTable:		

	.byte $ff, $00, $ff, $00, $ff, $00, $ff, $01, $ff, $00, $ff, $00, $ff, $01, $ff, $00
	.byte $ff, $01, $ff, $00, $00, $01, $ff, $00, $ff, $01, $00, $01, $ff, $00, $00, $01
	.byte $ff, $01, $00, $01, $ff, $01, $00, $01, $00, $01, $ff, $01, $00, $01, $00, $01
	.byte $00, $01, $00, $01, $00, $01, $00, $01, $01, $01, $00, $01, $00, $01, $01, $01
	.byte $00, $01, $01, $01, $00, $01, $01, $00, $00, $01, $01, $01, $01, $00, $00, $01
	.byte $01, $00, $01, $01, $01, $00, $01, $01, $01, $00, $01, $00, $01, $01, $01, $00
	.byte $01, $00, $01, $00, $01, $00, $01 



	PacksBags: {

		
		sfx(SFX_DIVE)

		lda #0
		sta ENEMY.SortieCount, x
	
		GetSpeed:

			lda ENEMY.Slot, x
			tay
			pha

			lda FORMATION.Relative_Row, y
			tay

			lda SpeedLookup, y
			sta ENEMY.Speed, x	

		Position:

			pla
			tay

			lda FORMATION.FormationSpriteX, y
			sec
			sbc #4
			sta SpriteX, x

			lda FORMATION.SpriteRow, y
			sec
			sbc #6
			sta SpriteY, x

		GetColour:

			lda FORMATION.Type, y
			sta ENEMY.Type, x
			tay

			lda FORMATION.TypeToColour, y
			sec
			sbc #8
			sta SpriteColor, x

		Pointer:

			lda EnemyTypeFrameStart, y
			sta ENEMY.BasePointer, x
			sta SpritePointer, x

			lda #FLIES_IN_ARC
			sta ENEMY.Plan, x

			lda #0
			sta ENEMY.AnimFrameStartCode, x
			sta ENEMY.ArcTableLSB, x

			lda #3
			sta ENEMY.TempCounter1, x

			lda #8
			sta ENEMY.TempCounter2, x
		
			lda ENEMY.ArcClockwise, x
			beq GoingLeft


		GoingRight:

			lda #0
			sta ENEMY.Angle, x
			rts

		GoingLeft:

			lda #16
			sta ENEMY.Angle, x
			// COUNT ESCORTS HERE? CAN'T WE DO IT ELSEWHERE?


		rts
	}


	FliesInArc: {

			lda #0
			sta ZP.Amount

		Repeat:

			lda ENEMY.ArcTableLSB, x
			tay

			lda AlienArcTable, y
			sta ENEMY.MoveY

			iny
			lda AlienArcTable, y
			sta ENEMY.MoveX

		
			lda SpriteY, x
			adc #0
			clc
			adc ENEMY.MoveY
			sta SpriteY, x

			lda ENEMY.ArcClockwise, x
			bne FacingRight

		FacingLeft:

			lda SpriteX, x
			sec
			sbc ENEMY.MoveX
			sta SpriteX, x

			cmp #2
			bcs UpdateAngleLeft

			lda #ReturningToSwarm
			sta ENEMY.Plan, x
			rts

		UpdateAngleLeft:

			dec ENEMY.TempCounter1, x
			bne CheckProgress

			lda #5
			sta ENEMY.TempCounter1, x

			dec ENEMY.Angle, x
			lda ENEMY.BasePointer, x
			clc
			adc ENEMY.Angle, x
			sta SpritePointer, x

			lda ENEMY.Angle, x
			cmp #8
			beq ReadyToAttack

			jmp CheckProgress

		FacingRight:

			lda SpriteX_LSB, x
			clc
			adc ENEMY.FractionSpeedX, x
			sta SpriteX_LSB, x

			lda SpriteX, x
			adc #0
			clc
			adc ENEMY.MoveX
			sta SpriteX, x

			cmp #14
			bcs UpdateAngleRight

			lda #ReturningToSwarm
			sta ENEMY.Plan, x
			rts

		UpdateAngleRight:

			dec ENEMY.TempCounter1, x
			bne CheckProgress

			lda #5
			sta ENEMY.TempCounter1, x

			inc ENEMY.Angle, x
			lda ENEMY.BasePointer, x
			clc
			adc ENEMY.Angle, x
			sta SpritePointer, x

			lda ENEMY.Angle, x
			cmp #8
			beq ReadyToAttack

			dec ENEMY.TempCounter2

		CheckProgress:

			lda ENEMY.ArcTableLSB, x
			clc
			adc #2
			sta ENEMY.ArcTableLSB, x

			cmp #88
			bcc Finish

		ReadyToAttack:

			lda #READY_TO_ATTACK
			sta ENEMY.Plan, x
			rts


		Finish:

			lda IRQ.Frame
			sec
			sbc MAIN.MachineType
			adc ZP.Amount
			bpl DontRepeat

			inc ZP.Amount

			jmp Repeat

		DontRepeat:
				

		rts
	}


	ReadyToAttack: {


		CheckIfRed:

			lda ENEMY.Type, x
			cmp #ALIEN_RED
			beq RedAlien

		NotRed:	

			lda SpriteX, x
			sec
			sbc SHIP.PosX_MSB
			bmi AlienToLeft

		AlienToRight:

			lsr
			clc
			adc #16
			cmp #48
			bcs GreaterEqual48

			lda #48

		GreaterEqual48:

			cmp #112
			bcc LessThan112

			lda #112

		LessThan112:

		/// SWAP THEM ROUND, THEIR X CO-ORDS GO 224 - 0

		SetPivotValues:

			sta ENEMY.PivotXValueAdd, x
			sec
			sbc SpriteX, x
			eor #%11111111
		 	clc
		 	adc #1
		 	sta ENEMY.PivotXValue, x

		 	lda #0
		 	sta ENEMY.Inflight_S1A
		 	sta ENEMY.Inflight_S1B
		 	sta ENEMY.Inflight_S1C

		 	inc ENEMY.Plan, x
		 	rts

		AlienToLeft:

			lsr
			ora #%10000000
			sec
			sbc #16
			cmp #208
			bcc LessThan208

			lda #-48

		LessThan208:

			cmp #144
			bcs GreaterEqual144

			lda #-112

		GreaterEqual144:

			jmp SetPivotValues


		RedAlien:

		CheckIfFlagshipAttacking:

			lda ENEMY.Plan + 1
			beq NotRed

			lda ENEMY.PivotXValueAdd + 1
			jmp SetPivotValues	

		rts
	}



	AttackingPlayer: {

		lda #0
		sta ZP.Amount


		Repeat:

			inc SpriteY, x

			jsr Attack_Y_Add

			lda ENEMY.PivotXValue, x
			clc
			adc ENEMY.PivotXValueAdd, x
			sta SpriteX, x
			
			cmp #16
			bcs NotOffScreen

		Off:

			lda #10
			sta SpriteY, x

			lda #REACHED_BOTTOM_OF_SCREEN
			sta ENEMY.Plan, x

			lda ENEMY.Slot, x
			tay
			lda #1
			sta FORMATION.Occupied, y
			rts

		NotOffScreen:

			lda SpriteY, x
			clc
			adc #72
			bcc CheckLookAt

		NearBottomOfScreen:

			lda #NEAR_BOTTOM_OF_SCREEN
			sta ENEMY.Plan, x
			rts
			

		CheckLookAt:

			lda SHIP.Active
			beq CheckRepeat

			jsr CalculateLookAtFrame

		CheckRepeat:

			lda IRQ.Frame
			sec
			sbc MAIN.MachineType
			adc ZP.Amount
			bpl DontRepeat

			inc ZP.Amount

			jmp Repeat

		DontRepeat:



		rts
	}

	CalculateLookAtFrame: {

		lda SHIP.PosX_MSB
		sec
		sbc SpriteX, x
		bcc ShipToRight

		ShipToLeft:

			cmp #128
			bcs Okay

			lda #128
			jmp Okay

		ShipToRight:

			cmp #128
			bcc Okay

			lda #127

		Okay:

			sta ENEMY.MoveX


		lda #SHIP.SHIP_Y
		sec
		sbc SpriteY, x
		bcc ShipBelow

		ShipAbove:

			cmp #128
			bcs Okay2

			lda #128
			jmp Okay2

		ShipBelow:

			cmp #128
			bcc Okay2

			lda #127


		Okay2:

			sta ENEMY.MoveY

		jsr ENEMY.CalculateRequiredSpeed

		rts
	}

	Attack_Y_Add: {

		lda ENEMY.Speed, x // ld a, (ix+$18)
		and #%00000011 // and $03
		clc
		adc #1 // inc a
		tay  // ld b, a

		lda ENEMY.PivotXValueAdd, x // ld h, (ix + $19)
		sta ZP.H  

		lda ENEMY.Inflight_S1A, x // ld l, (ix + $1c)
		sta ZP.L

		lda ENEMY.Inflight_S1B, x // ld d, (ix + $1b)
		sta ZP.D
		               
		lda ENEMY.Inflight_S1C, x  // ld e, (ix + $1a)
		sta ZP.E

		SpeedLoop: // $117E

			lda ZP.H     // ld c, h
			sta ZP.C

			lda ZP.L  // ld a, l
			asl      	// add a, a
			bcc NoDecH  // jr nc $1184 (NoDecH)

			dec ZP.H 	// dec h

		NoDecH:  // $1184

			bcc NoCarry			

		NoCarry:

			clc
			adc ZP.D     // add a, d
			sta ZP.D     // ld d, a

			lda ZP.H    // ld a, $00   PLUS
			adc #0       // adc a, h
			sta ZP.Temp1

			cmp #$80       // cp $80
			bne NoForce   // jr nz, $118E (NoForce)

			lda ZP.C      // ld a, c

		NoForce:        // $118E

			sta ZP.H      // ld h, a
			sta ZP.Temp1

			lda ZP.L     // ld c, l
			sta ZP.C


			lda ZP.Temp1     // restore A 
			eor #%11111111
			clc
			adc #1         // neg
			asl           // add a, a
			bcc NoDecL    // jr nc, $1196 (NoDecL)

			dec ZP.L      // dec l 

		NoDecL:   // $1196

			clc       
			adc ZP.E     // add a, e
			sta ZP.E      // ld e, a

			lda ZP.L      // ld a, $00   PLUS
			adc #0       // adc a, l
			cmp #$80       // cp $80
			bne NoForce2   // jr nz, $11A0

			lda ZP.C     // ld a, c

		NoForce2:      // $11A0

			sta ZP.L   // ld l,a 

			dey           
			bne SpeedLoop // djnz $117E (SpeedLoop)



		lda ZP.H   
		sta ENEMY.PivotXValueAdd, x // ld (ix+$19), h
		
		lda ZP.L
		sta ENEMY.Inflight_S1A, x // ld (ix+$1a), l

		lda ZP.D
		sta ENEMY.Inflight_S1B, x // ld (ix+$1b), d

		lda ZP.E
		sta ENEMY.Inflight_S1C, x // ld (ix+$1c), e



		rts
	}

	NearBottomOfScreen: {


		.break

		rts
	}


	ReachedBottomOfScreen: {




		rts
	}


	FlagshipReachedBottom: {




		rts
	}

	ReturningToSwarm: { 

		lda ENEMY.Slot, x
		tay

		lda #1
		sta FORMATION.Occupied, y

		lda #PLAN_INACTIVE
		sta ENEMY.Plan, x

		lda #10
		sta SpriteY, x

		rts
	}


	BackInSwarm: {



		rts
	}

	ContinuingAttackFromTop: {



		rts
	}


	FullSpeedCharge: {


		rts
	}

	AttackingAggressively: {




		rts
	}

	LoopTheLoop: {




		rts
	}

	CompleteLoop: {


		rts
	}

	Unknown_1091: {


		rts
	}


}