
	* = * "Enemy Data"


	EnemyTypeFrameStart:		.byte 17, 33, 33, 33, 33
	Colours:					.byte YELLOW, YELLOW, YELLOW, CYAN, WHITE, WHITE
	ExplosionFrames:			.byte 50, 51, 52, 53
	ExplosionColours:			.byte WHITE, YELLOW, YELLOW, YELLOW, YELLOW, WHITE
	
	


	

	TopRightLookup:

	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.byte 4,2,1,1,1,1,0,0,0,0,0,0,0,0,0,0
	.byte 4,3,2,1,1,1,1,1,1,1,1,0,0,0,0,0
	.byte 4,3,3,2,2,1,1,1,1,1,1,1,1,1,1,1
	.byte 4,3,3,2,2,2,1,1,1,1,1,1,1,1,1,1
	.byte 4,3,3,3,2,2,2,2,1,1,1,1,1,1,1,1
	.byte 4,4,3,3,3,2,2,2,2,1,1,1,1,1,1,1
	.byte 4,4,3,3,3,2,2,2,2,2,2,1,1,1,1,1
	.byte 4,4,3,3,3,3,2,2,2,2,2,2,1,1,1,1
	.byte 4,4,3,3,3,3,3,2,2,2,2,2,2,2,1,1
	.byte 4,4,3,3,3,3,3,2,2,2,2,2,2,2,2,1
	.byte 4,4,4,3,3,3,3,3,2,2,2,2,2,2,2,2
	.byte 4,4,4,3,3,3,3,3,3,2,2,2,2,2,2,2
	.byte 4,4,4,3,3,3,3,3,3,2,2,2,2,2,2,2
	.byte 4,4,4,3,3,3,3,3,3,3,2,2,2,2,2,2
	.byte 4,4,4,3,3,3,3,3,3,3,3,2,2,2,2,2


	BottomRightLookup:

	.byte 8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
	.byte 4,6,7,7,7,7,8,8,8,8,8,8,8,8,8,8
	.byte 4,5,6,7,7,7,7,7,7,7,7,8,8,8,8,8
	.byte 4,5,5,6,6,7,7,7,7,7,7,7,7,7,7,7
	.byte 4,5,5,6,6,6,7,7,7,7,7,7,7,7,7,7
	.byte 4,5,5,5,6,6,6,6,7,7,7,7,7,7,7,7
	.byte 4,4,5,5,5,6,6,6,6,7,7,7,7,7,7,7
	.byte 4,4,5,5,5,6,6,6,6,6,6,7,7,7,7,7
	.byte 4,4,5,5,5,5,6,6,6,6,6,6,7,7,7,7
	.byte 4,4,5,5,5,5,5,6,6,6,6,6,6,6,7,7
	.byte 4,4,5,5,5,5,5,6,6,6,6,6,6,6,6,7
	.byte 4,4,4,5,5,5,5,5,6,6,6,6,6,6,6,6
	.byte 4,4,4,5,5,5,5,5,5,6,6,6,6,6,6,6
	.byte 4,4,4,5,5,5,5,5,5,6,6,6,6,6,6,6
	.byte 4,4,4,5,5,5,5,5,5,5,6,6,6,6,6,6
	.byte 4,4,4,5,5,5,5,5,5,5,5,6,6,6,6,6


	BottomLeftLookup:

	.byte 8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
	.byte 12,10,9,9,9,9,8,8,8,8,8,8,8,8,8,8
	.byte 12,11,10,9,9,9,9,9,9,9,9,8,8,8,8,8
	.byte 12,11,11,10,10,9,9,9,9,9,9,9,9,9,9,9
	.byte 12,11,11,10,10,10,9,9,9,9,9,9,9,9,9,9
	.byte 12,11,11,11,10,10,10,10,9,9,9,9,9,9,9,9
	.byte 12,12,11,11,11,10,10,10,10,9,9,9,9,9,9,9
	.byte 12,12,11,11,11,10,10,10,10,10,10,9,9,9,9,9
	.byte 12,12,11,11,11,11,10,10,10,10,10,10,9,9,9,9
	.byte 12,12,11,11,11,11,11,10,10,10,10,10,10,10,9,9
	.byte 12,12,11,11,11,11,11,10,10,10,10,10,10,10,10,9
	.byte 12,12,12,11,11,11,11,11,10,10,10,10,10,10,10,10
	.byte 12,12,12,11,11,11,11,11,11,10,10,10,10,10,10,10
	.byte 12,12,12,11,11,11,11,11,11,10,10,10,10,10,10,10
	.byte 12,12,12,11,11,11,11,11,11,11,10,10,10,10,10,10
	.byte 12,12,12,11,11,11,11,11,11,11,11,10,10,10,10,10



	TopLeftLookup:

	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.byte 12,14,15,15,15,15,0,0,0,0,0,0,0,0,0,0
	.byte 12,13,14,15,15,15,15,15,15,15,15,0,0,0,0,0
	.byte 12,13,13,14,14,15,15,15,15,15,15,15,15,15,15,15
	.byte 12,13,13,14,14,14,15,15,15,15,15,15,15,15,15,15
	.byte 12,13,13,13,14,14,14,14,15,15,15,15,15,15,15,15
	.byte 12,12,13,13,13,14,14,14,14,15,15,15,15,15,15,15
	.byte 12,12,13,13,13,14,14,14,14,14,14,15,15,15,15,15
	.byte 12,12,13,13,13,13,14,14,14,14,14,14,15,15,15,15
	.byte 12,12,13,13,13,13,13,14,14,14,14,14,14,14,15,15
	.byte 12,12,13,13,13,13,13,14,14,14,14,14,14,14,14,15
	.byte 12,12,12,13,13,13,13,13,14,14,14,14,14,14,14,14
	.byte 12,12,12,13,13,13,13,13,13,14,14,14,14,14,14,14
	.byte 12,12,12,13,13,13,13,13,13,14,14,14,14,14,14,14
	.byte 12,12,12,13,13,13,13,13,13,13,14,14,14,14,14,14
	.byte 12,12,12,13,13,13,13,13,13,13,13,14,14,14,14,14


	SpriteLookupX:	.fill 27, 24 + (i * 8)
	SpriteLookupY:	.fill 19, 50 + (i * 8)
	
	SpriteX_LSB:
		.fill MAX_SPRITES, 0
	TargetSpriteX:
		.fill MAX_SPRITES, 0
	TargetSpriteY:
		.fill MAX_SPRITES, 0
	SpriteY_LSB:
		.fill MAX_SPRITES, 0

	PathID:
		.fill MAX_SPRITES, 0


