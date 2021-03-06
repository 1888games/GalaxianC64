BONUS: {



	Timer:	.byte 255, 255
	Active:	.byte 0, 0

	Colours:	.byte PURPLE, PURPLE, PURPLE, PURPLE, CYAN, YELLOW, WHITE


	.label StartPointer = 59
	.label StartSpriteID = 21
	.label ShowTime = 60


	FrameUpdate: {

		ldx #0

		Loop:

			lda Active, x
			beq EndLoop

			lda Timer, x
			beq Ready

			dec Timer, x
			jmp EndLoop

			Ready:

				lda #10
			//	sta SpriteX + StartSpriteID, x
				sta SpriteY + StartSpriteID, x

				lda #0
				sta Active, x

			EndLoop:

				inx
				cpx #1
				bcc Loop



		rts
	}


	ShowBonus: {

		// ZP.Row = sprite y
		// ZP.Column = sprite x
		// bonus type = y
		ldx #0

		Loop:
		
			lda Active, x
			beq Found

			inx
			cpx #2
			beq Abandon

			jmp Loop


		Found:

			lda ZP.Row
			sta SpriteY + StartSpriteID, x

			lda ZP.Column
			sta SpriteX + StartSpriteID, x

			lda Colours, y
			sta SpriteColor + StartSpriteID, x

			tya
			clc
			adc #StartPointer
			sta SpritePointer + StartSpriteID, x

			lda #0
			sta ENEMY.Plan + StartSpriteID, x

			lda #ShowTime
			sta Timer, x

			lda #1
			sta Active, x


		Abandon:

		rts
	}
}