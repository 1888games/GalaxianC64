.namespace CHARGER {

	* = * "Flight"


	FlightJumpTable: 	.word 0, PacksBags, FliesInArc, ReadyToAttack, AttackingPlayer
						.word NearBottomOfScreen, ReachedBottomOfScreen, ReturningToSwarm
						.word ContinuingAttackFromTop, FullSpeedCharge, AttackingAggressively, LoopTheLoop
						.word CompleteLoop, Unknown_1091


	SpeedLookup:		.byte 2, 2, 3, 1, 2, 1					





	PacksBags: {

		lda #0
		sta ENEMY.SortieCount, x
	
		sfx(SFX_DIVE)

		GetSpeed:

			lda ENEMY.Slot, x
			tay

			lda FORMATION.Relative_Row, y
			pha
			tay

			lda SpeedLookup, y
			sta ENEMY.Speed

		Position:

			lda FORMATION.FormationSpriteX, y
			sta SpriteX, x

			lda FORMATION.SpriteRow, y
			sta SpriteY, x

		GetColour:

			pla
			tay

			lda FORMATION.TypeToColour, y
			sta SpriteColor, x

		Pointer:

			lda EnemyTypeFrameStart, y
			sta ENEMY.BasePointer, x
			sta SpritePointer, x





		
		rts
	}


	FliesInArc: {




		rts
	}


	ReadyToAttack: {




		rts
	}



	AttackingPlayer: {




		rts
	}

	NearBottomOfScreen: {




		rts
	}


	ReachedBottomOfScreen: {




		rts
	}


	FlagshipReachedBottom: {




		rts
	}

	ReturningToSwarm: { 


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