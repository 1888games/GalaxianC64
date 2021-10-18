.namespace ENEMY {

	* = * "Enemy"


	// Bashes AX
	NewGame: {

		lda #255
		sta EnemyWithShipID

		lda #0
		sta Quadrant
		sta FormationUpdated
		sta EnemiesAlive
		sta MoveX
		sta MoveY
		sta AddingFighter
		
		jsr ClearData

		rts
	}

	// Bashes AX
	ClearData: {

		ldx #0

		Loop:

			sta Side, x
			sta Angle, x
			sta BasePointer, x
			sta Plan, x
			sta Slot, x
			sta HitsLeft, x
			sta IsExtraEnemy, x
			sta UltimateTargetSpriteY, x

			inx
			cpx #MAX_ENEMIES
			bcc Loop

		rts
	}


	// Bashes AXY
	FrameUpdate: {

		SetDebugBorder(7)


		ldx #0
		stx EnemiesAlive

		lda SHIP.PosX_MSB
		sta CHARGER.ShipX

		lda SHIP.TwoPlayer
		beq UseP1

		lda ZP.Counter
		and #%00000001
		tay

		lda SHIP.PosX_MSB, y
		sta CHARGER.ShipX

		UseP1:

		Loop:

			stx ZP.EnemyID
		
			lda Plan, x
			beq EndLoop

			inc EnemiesAlive

			ldy #0
			sty Repeated

		Repeat:

			jsr ProcessEnemy

			ldx ZP.EnemyID
			lda Plan, x
			beq EndLoop

			lda IRQ.Frame
			sec
			sbc MAIN.MachineType
			adc Repeated
			bpl DontRepeat

			inc Repeated

			jmp Repeat

		DontRepeat:

			jsr CheckShipCollision
			//jsr BOMBS.CheckEnemyFire

		EndLoop:

			ldx ZP.EnemyID
			inx
			cpx #MAX_ENEMIES
			bcc Loop

		Finish:

			lda #0
			sta FormationUpdated

			SetDebugBorder(0)
		
		rts
	}	


	// X = ZP.EnemyID
	ProcessEnemy: {

		cmp #FLAGSHIP_SWARM
		bcc DontExplode

		cmp #PLAN_EXPLODE
		bne Finish

		jmp Explode
		
		DontExplode:
			
			asl
			tay
			lda CHARGER.FlightJumpTable, y
			sta ZP.DataAddress

			lda CHARGER.FlightJumpTable + 1, y
			sta ZP.DataAddress + 1

			jmp (ZP.DataAddress)


		Finish:


		rts
	}





}