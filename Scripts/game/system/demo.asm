DEMO: {

	* = * "Demo"

	.label DelayTime = 5
	.label FlipTime = 250


	DelayTimer:	.byte DelayTime
	FlipTimer:	.byte 0


	Progress:	.byte 0

	Sprite1: 	.byte 0, 0, 122, 34, 52, 52, 52, 17, 18, 19, 20, 21, 22
			
	
	Rows:		.byte 2, 4, 8, 10, 12, 14, 16, 18, 23
	Colours:	.byte YELLOW, RED, WHITE, CYAN, CYAN, CYAN, CYAN, CYAN, CYAN
	StartColumn:	.byte 10, 8, 8, 12, 14, 14, 14, 14, 7





	Show: {

		lda #1
		sta MAPLOADER.CurrentMapID

		jsr MAPLOADER.DrawMap


		lda #GAME_MODE_DEMO
		sta MAIN.GameMode

		lda #0
		sta Progress

		lda #FlipTime
		sta FlipTimer

		jsr ColourRows
		jsr ColourAliens

		rts
	}

	ColourAliens: {

		lda #RED_MULT
		sta VIC.COLOR_RAM + 571
		sta VIC.COLOR_RAM + 572
		sta VIC.COLOR_RAM + 611
		sta VIC.COLOR_RAM + 612

		lda #PURPLE_MULT
		sta VIC.COLOR_RAM + 651
		sta VIC.COLOR_RAM + 652
		sta VIC.COLOR_RAM + 691
		sta VIC.COLOR_RAM + 692




		rts
	}
		
	ColourRows: {

		ldy #0

		Loop:

			sty ZP.StoredYReg

			lda StartColumn, y
			sta ZP.Amount

			lda Rows, y
			tay

			ldx #0

			jsr PLOT.GetCharacter

			ldy ZP.Amount
			ldx ZP.StoredYReg
			lda Colours, x

			ColumnLoop:

				sta (ZP.ColourAddress), y

				iny
				cpy #40
				bcc ColumnLoop

			ldy ZP.StoredYReg
			iny
			cpy #9
			bcc Loop





		rts
	}

	FrameCode: {

		lda FlipTimer
		beq Ready

		lda ZP.Counter
		and #%00000001
		beq CheckFire

		dec FlipTimer

		CheckFire:

			ldy #1
			lda INPUT.FIRE_UP_THIS_FRAME, y
			beq NoFire

			sfx(SFX_COIN)

		Title:

			jmp MAIN.ShowTitleScreen


		NoFire:

			rts



		Ready:

		jmp MAIN.ShowTitleScreen


		rts
	}





}