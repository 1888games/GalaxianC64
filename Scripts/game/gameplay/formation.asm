FORMATION: {

	


	.label SR = 50
	.label SC = 20

	.label TransformStages = 5
	.label TransformTime = 20


	SpriteRow:	.fill 2, SR
				.fill 6, SR + (2 * 8)
				.fill 8, SR + (4 * 8)
				.fill 10, SR + (6 * 8)
				.fill 10, SR + (8* 8)
				.fill 10, SR + (1* 8)
				.fill 2, 0


	SpriteColumn:

				.fill 1, SC + (9 * 8) + (i*16)
				.fill 1, SC + (1 * 8) + (i*16)
				.fill 6, SC + (7 * 8) + (i*16)
				.fill 8, SC + (5 * 8) + (i*16)
				.fill 10, SC + (3 * 8) + (i*16)
				.fill 10, SC + (3 * 8) + (i*16)
				.fill 10, SC + (3 * 8) + (i*16)
				.fill 2, 0


	.label ExplosionChar = 63
	.label EXPLOSION_TIME = 3
	.label UpdatesPerFrame = 8
	.label MAX_EXPLOSIONS= 3

	Hits:		.fill 4, 0
				.fill 36, 0
				.fill 3, 0
				.fill 3, 0
				.fill 2, 0


	Column:		.fill 48, 0
	PreviousColumn:	.fill 48, 0
	PreviousRow:	.fill 48, 0
	HitsLeft:	.fill 40, 1
				.fill 8, 0
	Switching:	.byte 0

	Plan:		.fill 48, 0
	NextPlan:	.fill 48, 0

	TypeToScore:		.byte 4, 4, 2, 0, 3, 7
	ChallengeToScore: 	.byte 5, 5, 1, 1, 1, 1
	Alive:			.byte 0

	Stop:			.byte 0


	DrawIteration:	.byte 0
	
	FrameTimer:	.byte 0


	* = * "Enemies Left"
	EnemiesLeftInStage:	.byte 0


	TypeToColour:		.byte YELLOW + 8, RED + 8, PURPLE + 8, CYAN + 8


	CurrentRow:	.byte 255


	LeftMaxColumn:	.byte 3
	RightMinColumn:	.byte 21
	FrameAdd:	.byte 0, 8

	IllegalOffsetLeft:	.byte -4
	IllegalOffsetRight: .byte 4




	
	Offset_0_Frame_0_Clear:		.byte 135, 136, 000, 138, 137, 000 
	Offset_0_Frame_0_Nexty:		.byte 135, 136, 158, 138, 137, 000 // check right
	Offset_1_Frame_0_Clear:		.byte 139, 140, 000, 142, 141, 000
	Offset_1_Frame_0_Nexty:		.byte 139, 140, 162, 142, 141, 000 // check right
	Offset_2_Frame_0_Clear:		.byte 143, 144, 147, 146, 145, 150
	Offset_2_Frame_0_Nexty:		.byte 143, 144, 147, 146, 145, 150 // check right
	Offset_3_Frame_0_Clear:		.byte 166, 148, 151, 169, 149, 152
	Offset_3_Frame_0_Nexty:		.byte 176, 148, 151, 169, 149, 152 // check left



	Offset_0_Frame_1_Clear:		.byte 154, 155, 139, 157, 165, 000 
	Offset_0_Frame_1_Nexty:		.byte 154, 155, 139, 157, 165, 142 // check right
	Offset_1_Frame_1_Clear:		.byte 158, 159, 000, 000, 000, 000
	Offset_1_Frame_1_Nexty:		.byte 158, 159, 143, 000, 000, 146 // check right
	Offset_2_Frame_1_Clear:		.byte 162, 163, 000, 000, 164, 000
	Offset_2_Frame_1_Nexty:		.byte 162, 163, 166, 000, 164, 169 // check right
	Offset_3_Frame_1_Clear:		.byte 174, 167, 170, 000, 168, 165
	Offset_3_Frame_1_Nexty:		.byte 147, 167, 170, 150, 168, 165 // check left


						      // 0         // 1      // 2       // 3
	TopLeftChars:		.byte 135, 135, 139, 139, 143, 143, 000, 166

						.byte 154, 154, 158, 158, 162, 162, 174, 147

	TopMiddleChars:		.byte 136, 136, 140, 140, 144, 144, 148, 148

						.byte 155, 155, 159, 159, 163, 163, 167, 167

	TopRightChars:		.byte 000, 158, 000, 162, 173, 147, 151, 151

						.byte 000, 139, 000, 143, 175, 166, 170, 170


	BottomLeftChars:	.byte 138, 138, 142, 142, 146, 146, 169, 169

						.byte 157, 157, 000, 000, 000, 000, 000, 150

	BottomMiddleChars:	.byte 137, 137, 141, 141, 145, 145, 149, 149

						.byte 000, 000, 160, 160, 164, 164, 168, 168


	BottomRightChars:	.byte 000, 000, 000, 000, 150, 150, 152, 152

						.byte 000, 142, 000, 146, 000, 169, 000, 000





	//Spread_Order:	.byte 0, 3, 4, 11, 12, 19, 20, 29, 30, 39


		Type:	.byte          0, 0, 0, 0	// 0-1
				.byte       1, 1, 1, 1, 1, 1 // 2-7
				.byte    2, 2, 2, 2, 2, 2, 2, 2 // 8-15
				.byte 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 // 16-25
				.byte 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 // 26-35
				.byte 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 // 36-45
				.byte 4, 4, 4 // 40-42

		StartOffset:

				.byte          0, 1, 2, 3	// 0-1
				.byte       3, 0, 1, 2, 3, 0 // 2-7
				.byte    2, 3, 0, 1, 2, 3, 0, 1 // 8-15
				.byte 1, 2, 3, 0, 1, 2, 3, 0, 1, 2 // 16-25
				.byte 1, 2, 3, 0, 1, 2, 3, 0, 1, 2 // 26-35
				.byte 1, 2, 3, 0, 1, 2, 3, 0, 1, 2 // 36-45
				.byte 4, 4, 4 // 40-42

			ReverseOrder:		.byte 3, 2, 1, 0
								.byte 9, 8, 7, 6, 5, 4
								.byte 17, 16, 15, 14, 13, 12, 11, 10
								.byte 27, 26, 25, 24, 23, 22, 21, 20, 19, 18
								.byte 37, 36, 35, 34, 33, 32, 31, 30, 29, 28
								.byte 47, 46, 45, 44, 43, 42, 41, 40, 39, 38

		* = * "Offset"

		Offset:

				.byte          0, 1, 2, 3	// 0-3
				.byte       3, 0, 1, 2, 3, 0 // 4-9
				.byte    2, 3, 0, 1, 2, 3, 0, 1 // 10-17
				.byte 1, 2, 3, 0, 1, 2, 3, 0, 1, 2 // 18-27
				.byte 1, 2, 3, 0, 1, 2, 3, 0, 1, 2 // 28-37
				.byte 1, 2, 3, 0, 1, 2, 3, 0, 1, 2 // 38-47
				.byte 4, 4, 4 // 40-42


	Home_Column:
				.byte 			  10, 12, 14, 16	
				.byte         07, 10, 12, 14, 16, 19
				.byte     05, 07, 10, 12, 14, 16, 19, 21
				.byte 03, 05, 07, 10, 12, 14, 16, 19, 21, 23
				.byte 03, 05, 07, 10, 12, 14, 16, 19, 21, 23
				.byte 03, 05, 07, 10, 12, 14, 16, 19, 21, 23
				
				.byte 9, 9


	Home_Row:	.byte 				0, 0, 0, 0	
				.byte 			2, 2, 2, 2, 2, 2
				.byte 		4, 4, 4, 4, 4, 4, 4, 4
				.byte 	6, 6, 6, 6, 6, 6, 6, 6, 6, 6
				.byte 	8, 8, 8, 8, 8, 8, 8, 8, 8, 8
				.byte 10, 10, 10, 10, 10, 10, 10, 10, 10, 10





	Frames:		.byte 		   0, 1, 0, 1
				.byte 		0, 1, 0, 1, 0, 1
				.byte 	 0, 1, 0, 1, 0, 1, 0, 1
				.byte 0, 1, 0, 1, 0, 1, 0, 1, 0, 1
				.byte 0, 1, 0, 1, 0, 1, 0, 1, 0, 1
				.byte 0, 1, 0, 1, 0, 1, 0, 1, 0, 1
				.byte 0, 1

			StartIDs:		.byte 0, 4, 10, 18, 28, 38
			EndIDs:			.byte 3, 9, 17, 27, 37, 47




	Occupied:	.fill 48, 0


	ExplosionTimer: .fill MAX_EXPLOSIONS, 0
	ExplosionList:	.fill MAX_EXPLOSIONS, 255
	ExplosionProgress:	.fill MAX_EXPLOSIONS, 0
	ExplosionX:		.fill MAX_EXPLOSIONS, 0
	ExplosionY:		.fill MAX_EXPLOSIONS, 0

	ExplosionColour:	.byte WHITE + 8, YELLOW + 8, YELLOW + 8, YELLOW + 8


	Mode:		.byte FORMATION_UNISON

	Position:	.byte 0
	PreviousPosition: .byte 0
	Direction:	.byte 1
	SwitchingDirection:	.byte 0
	Speeds:		.byte 7, 12
	SpreadPosition:	.byte 0



	Frame:			.byte 0
	CurrentSlot:	.byte 255
	FrameCounter:	.byte 0

	ColumnSpriteX:	.fill 40, 24 + (i * 8)
	RowSpriteY:		.fill 25, 50 + (i * 8)
	

	TypeCharStart:		.byte 169, 181, 189, 189, 246, 232 
	Colours:			.byte YELLOW + 8, YELLOW + 8, PURPLE + 8, CYAN + 8, YELLOW + 8, GREEN + 8
	TransformColours:	.byte GREEN + 8, YELLOW + 8, GREEN + 8, CYAN + 8, YELLOW + 8, GREEN + 8

	TransformProgress:	.byte 0
	TransformTimer:		.byte 0
	TransformID:		.byte 255

	OffsetChars:		.byte 0



	Initialise: {

		ldx #0

		Loop:

			lda Home_Column, x
			
			sta PreviousColumn, x
			sta PreviousRow, x

			lda StartOffset, x
			sta Offset, x

			lda Hits, x
			sta HitsLeft, x

			//jsr RANDOM.Get
			//and #%00000001

			lda #0
			sta Occupied, x
			sta Column, x
		
			inx
			cpx #48
			bcc Loop


		lda #0
		sta Position
		sta PreviousPosition
		sta CurrentSlot
		sta FrameCounter
		sta SpreadPosition
		sta Switching
		sta Stop
		sta OffsetChars
		sta SwitchingDirection
	

		lda #1
		sta Direction
		sta Frame
		sta Mode
		sta FrameTimer

		lda #STAGE.NumberOfWaves * 8
		sta Alive



		lda #255
		sta TransformID
		sta DrawIteration
		sta CurrentRow


		rts
	}


	


	StartTransform: {

		sty TransformID

		lda #0
		sta TransformProgress

		lda #TransformTime
		sta TransformTimer

		rts
	}

	
	EnemyKilled: {

		dec Alive

		lda Alive
		bmi Error
		// clc
	 // 	adc #48
		// sta SCREEN_RAM + 438

		// lda #1
		// sta VIC.COLOR_RAM + 438

		rts

		Error:

			//.break
			nop


		rts
	}

	
	

		

	DrawEnemy: {

		// x = enemy ID
		// ZP.Row
		// ZP.Column > y

		lda Column, x
		clc
		adc Home_Column, x
		//clc
		//adc OffsetChars
		sta ZP.Column

		lda Type, x
		tay
		lda TypeToColour, y
		sta ZP.Colour


		lda Offset, x
		asl
		sta ZP.Amount

		cmp #6
		beq LookLeft


		LookRight:

			cpx ZP.EndID
			beq AddFrame

			clc
			adc Occupied + 1, x
			sta ZP.Amount
			jmp AddFrame

		LookLeft:

			cpx ZP.StartID
			beq AddFrame

			clc
			adc Occupied - 1, x
			sta ZP.Amount


		AddFrame:

			txa
			clc
			adc Frame
			tax

			lda Frames, x
			ldx ZP.CurrentID
			tay
			lda FrameAdd, y
			clc
			adc ZP.Amount
			sta ZP.CharID

		DrawChars:

			ldy ZP.Column
			ldx ZP.CharID
			lda TopLeftChars, x
			sta (ZP.ScreenAddress), y

				lda ZP.Colour
			sta (ZP.ColourAddress), y

			iny
			lda TopMiddleChars, x
			sta (ZP.ScreenAddress), y
			lda ZP.Colour
			sta (ZP.ColourAddress), y

			iny
			lda TopRightChars, x
			sta (ZP.ScreenAddress), y
			lda ZP.Colour
			sta (ZP.ColourAddress), y


			tya
			clc
			adc #38
			tay

			lda BottomLeftChars, x
			sta (ZP.ScreenAddress), y
			lda ZP.Colour
			sta (ZP.ColourAddress), y

			iny
			lda BottomMiddleChars, x
			sta (ZP.ScreenAddress), y
			lda ZP.Colour
			sta (ZP.ColourAddress), y

			iny
			lda BottomRightChars, x
			sta (ZP.ScreenAddress), y
			lda ZP.Colour
			sta (ZP.ColourAddress), y


		rts
	}
	

	ProcessIteration: {

		jsr ClearRow

		ldx DrawIteration
		lda StartIDs, x
		sta ZP.CurrentID
		sta ZP.StartID


		lda EndIDs, x
		sta ZP.EndID
		//inc ZP.EndID


		ldx ZP.CurrentID

		GetScreenAddress:

			lda Home_Row, x
			sta ZP.Row
			tay

			ldx #0
			stx ZP.Column
			jsr PLOT.GetCharacter

		ldx ZP.CurrentID

		Loop:

			stx ZP.CurrentID

			lda Occupied, x
			beq EndLoop

			jsr DrawEnemy

			EndLoop:

				ldx ZP.CurrentID

				lda Direction
				beq GoingLeft

				GoingRight:

					lda Offset, x
					clc
					adc #1
					sta Offset, x

					cmp #4
					bcc Okay

					lda #0
					sta Offset, x

					inc Column, x
					
					lda Column, x
					cmp IllegalOffsetRight
					bne Okay

				ReachedEdge:

					lda Offset, x
					beq NoDec

					dec Column, x

				NoDec:

					inc SwitchingDirection

					jmp Okay

				GoingLeft:

					lda Offset, x
					sec
					sbc #1
					sta Offset, x
					bpl Okay

					lda #3
					sta Offset, x

					dec Column, x
					lda Column, x
					cmp IllegalOffsetLeft
					bne Okay

				ReachedEdgeLeft:

					lda Offset, x
					cmp #3
					beq NoIncrease

					inc Column, x

				NoIncrease:
					inc SwitchingDirection


			Okay:

				cpx ZP.EndID
				beq Done

				inx
			

			NotSwitching:

				jmp Loop


		Done:

		rts
	}

		
	FrameUpdate: {

		inc $d020

		lda #0
		sta ZP.Temp4

		lda #1
		sta EnemiesLeftInStage

		//lda FrameTimer
		//beq Ready

		//dec FrameTimer
		//rts

		Ready:

		lda Mode
		bne Finish

		Start:

			inc ZP.Temp4
			inc DrawIteration
			lda DrawIteration
			cmp #6
			bcc Okay

			lda #0
			sta DrawIteration


			lda SwitchingDirection
			beq NotSwitching

			lda #0
			sta SwitchingDirection

			lda Direction
			eor #%00000001
			sta Direction

		NotSwitching:

			lda #1
			sta FrameTimer

			inc FrameCounter
			lda FrameCounter
			cmp #3
			bcc Okay

			lda #0
			sta FrameCounter

			lda Frame
			eor #%00000001
			sta Frame

		Okay:

			jsr ProcessIteration

			lda ZP.Temp4
			cmp #1
			bcc Start



		Finish:

		dec $d020

		rts
	}

	DrawFourCorners: {

		TopLeft:

			lda ZP.CharID

			jsr PLOT.PlotCharacter
			lda ZP.Colour
			jsr PLOT.ColorCharacter

			inc ZP.CharID

		TopRight:

			iny
			lda ZP.CharID
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

			inc ZP.CharID

		BottomRight:

			ldy #41
			lda ZP.CharID
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

			inc ZP.CharID

		BottomLeft:

			dey
			lda ZP.CharID
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y


		rts
	}

	DeleteExplosion: {

		stx ZP.FormationID

		lda ExplosionX, x
		sta ZP.Column
		
	TopLeft:

		lda ExplosionY, x
		tay
		ldx ZP.Column

		lda #0
		jsr PLOT.GetCharacter


		bmi TopRight

		ldy #0
		lda #0
		sta (ZP.ScreenAddress), y
		
	TopRight:

		ldy #1
		lda (ZP.ScreenAddress), y
		bmi BottomRight

		lda #0
		sta (ZP.ScreenAddress), y

	BottomRight:

		ldy #41
		lda (ZP.ScreenAddress), y
		bmi BottomLeft

		lda #0
		sta (ZP.ScreenAddress), y

	BottomLeft:

		ldy #40
		lda (ZP.ScreenAddress), y
		bmi Finish

		lda #0
		sta (ZP.ScreenAddress), y

		ldx ZP.FormationID
		
		Finish:

		rts
	}


	DrawExplosion: {

		TopLeft:

			jsr PLOT.GetCharacter

			bmi TopRight

			ldy #0
			lda ZP.CharID
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y


		TopRight:

			inc ZP.CharID

			iny
			lda (ZP.ScreenAddress), y
			bmi BottomRight

			lda ZP.CharID
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

			

		BottomRight:

			inc ZP.CharID

			ldy #41

			lda (ZP.ScreenAddress), y
			bmi BottomLeft

			lda ZP.CharID
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

		
		BottomLeft:

			inc ZP.CharID

			dey
			lda (ZP.ScreenAddress), y
			bmi Finish

			lda ZP.CharID
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

		Finish:

		rts
	}

	ProcessExplosion: {

		lda ExplosionTimer, x
		beq ReadyToDraw

		dec ExplosionTimer, x
		rts

		ReadyToDraw:


		DeleteFirst:


			jsr DeleteExplosion

			ldx ZP.StoredXReg
			lda ExplosionProgress, x
			cmp #4
			bcc NowDraw

			lda #255
			sta ExplosionList, x
			jmp Finish


		NowDraw:

			ldx ZP.StoredXReg

			lda #EXPLOSION_TIME
			sta ExplosionTimer, x

			lda ExplosionProgress, x
			asl
			asl
			clc
			adc #ExplosionChar
			sta ZP.CharID

			lda ExplosionProgress, x
			tay
			lda ExplosionColour, y
			sta ZP.Colour

			ldx ZP.StoredXReg

			lda ExplosionX, x
			sta ZP.Column

			lda ExplosionY, x
			tay

			ldx ZP.Column

			jsr DrawExplosion

			
			ldx ZP.StoredXReg
			inc ExplosionProgress, x
			


		Finish:


		rts
	}

	CheckExplosions: {

		ldx #0

		Loop:

			stx ZP.StoredXReg
			lda ExplosionList, x
			bmi EndLoop	

			sta ZP.CurrentID

			jsr ProcessExplosion

		EndLoop:

			ldx ZP.StoredXReg
			inx
			cpx #MAX_EXPLOSIONS
			bcc Loop


		rts
	}

	AddExplosion: {


		ldy #0

		Loop:

			lda ExplosionList, y
			bmi Found

			iny
			cpy #MAX_EXPLOSIONS
			beq Exit

			jmp Loop

		Exit:

			rts

		Found:

			txa
			sta ExplosionList, y

			lda Column, x
			clc
			adc Position
			sta ExplosionX, y

			//lda Row, x
			sta ExplosionY, y

			lda #0
			sta ExplosionTimer, y
			sta ExplosionProgress, y



			rts
	}

	Hit: {

		lda HitsLeft, x
		sta ZP.SoundFX
		beq Destroy

		dec HitsLeft, x

		stx ZP.FormationID

		jsr STATS.Hit

		ldx ZP.FormationID
		
		//jsr Delete
		//jsr DrawOne
		jmp NoDelete

		Destroy:

			lda #$52

			jsr EnemyKilled

			lda #0
			sta Occupied, x

			stx ZP.FormationID

			jsr ATTACKS.CheckBeamBossHit

			lda #PLAN_INACTIVE
			sta Plan, x
			sta NextPlan, x

			lda Type, x
			tay
			sec
			sbc ZP.SoundFX

			sfxFromA()


			lda TypeToScore, y
			tay

			jsr SCORE.AddScore

			ldx ZP.FormationID

			jsr AddExplosion
			//jsr Delete




		NoDelete:

		


		rts
	}

	

	CalculateEnemiesLeft: {

		lda #46
		sta EnemiesLeftInStage


		lda STAGE.StageIndex
		cmp #3
		bcc NotChallenging

		ChallengingStage:

		lda Alive
		sta EnemiesLeftInStage
		rts

		NotChallenging:

		lda ATTACKS.Active
		bne Calculate

		//lda #0
		//sta SCREEN_RAM
		//sta SCREEN_RAM + 1
		rts

		Calculate:

		ldx #0
		stx EnemiesLeftInStage

		Loop:

			lda FORMATION.Occupied, x
			beq CheckDive

			inc EnemiesLeftInStage


			CheckDive:

			cpx #MAX_ENEMIES
			bcs EndLoop

			lda ENEMY.Plan, x
			beq EndLoop

			inc EnemiesLeftInStage

			EndLoop:

				inx
				cpx #48
				bcc Loop

		Display:

			//lda #48
			//sta SCREEN_RAM
//
			lda EnemiesLeftInStage

		DisplayLoop:

			sec
			sbc #10
			bmi Done

			//inc SCREEN_RAM

			jmp DisplayLoop

			Done:

			

			

		rts

	}


	
	

	
	ClearRow: {

		//inc $d020

		ldx DrawIteration
		bne NotOne

		jmp One

		NotOne:

		cpx #1
		bne NotTwo

		jmp Two

		NotTwo:

		cpx #2
		bne NotThree

		jmp Three

		NotThree:

		cpx #3
		bne NotFour

		jmp Four

		NotFour:

		cmp #4
		bne NotFive

		jmp Five

		NotFive:

			lda #0
		
			.for(var i=0; i<28; i++) {
				
				sta SCREEN_RAM + 400 + i
				sta SCREEN_RAM + 440 + i
			
			}

			//dec $d020

			rts



		Five:

			lda #0
		
			.for(var i=0; i<28; i++) {
				
				sta SCREEN_RAM + 320 + i
				sta SCREEN_RAM + 360 + i
			
			}

			//dec $d020

			rts


		Four:

			lda #0
		
			.for(var i=0; i<28; i++) {
				
				sta SCREEN_RAM + 240 + i
				sta SCREEN_RAM + 280 + i
			
			}

		//	dec $d020

			rts

		Three:

			lda #0
		
			.for(var i=0; i<28; i++) {
				
				sta SCREEN_RAM + 160 + i
				sta SCREEN_RAM + 200 + i
			
			}

			//dec $d020

			rts
			
			
		Two:

			lda #0
		
			.for(var i=0; i<28; i++) {
				
				sta SCREEN_RAM + 080 + i
				sta SCREEN_RAM + 120 + i
				
			}

			//dec $d020
			rts
			

		One:

			lda #0

			.for(var i=0; i<28; i++) {
				
				sta SCREEN_RAM + 000 + i
				sta SCREEN_RAM + 040 + i
				
			}

			//dec $d020
			rts

	}

}