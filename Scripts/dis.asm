//
// Galaxian (C) 1979 NAMCO.
//
// Reverse engineering work by Scott Tunstall, Paisley, Scotland. 
// Tools used: MAME debugger & Visual Studio Code text editor.
// Date: 7 July 2019.  
// 
// Please send any questions, corrections and updates to scott.tunstall@ntlworld.com
//
// Be sure to check out my reverse engineering work for Robotron 2084 and Scramble too, 
// at http://seanriddle.com/robomame.asm and http://seanriddle.com/scramble.asm asm respectively.
//
// Finally:
// If you'd like to show appreciation for this work by buying me a coffee, feel free: https://ko-fi.com/scotttunstall
// I'd be equally happy if you donated to Parkinsons UK or Chest Heart And Stroke (CHAS) Scotland.
// Thanks.  

/*
Conventions: 

NUMBERS
=======

The term "@ $" means "at memory address in hexadecimal". 
e.g. @ $1234 means "refer to memory address 1234" or "program code @ memory location 1234" 

The term "#$" means "immediate value in hexadecimal". It's a habit I have kept from 6502 days.
e.g. #$60 means "immediate value of 60 hex" (96 decimal)

If I don't prefix a number with $ or #$ in my comments, treat the value as a decimal number.


LABELS
======
I have a labelling convention in place to help you identify the important parts of the code quicker.
Any subroutine labelled with the SCRIPT_ , DISPLAY_ or HANDLE_ prefix are critical "top-level" functions responsible 
for calling a series of "lower-level" functions to achieve a given result.   

If this helps you any, think of the "top level" as the main entry point to code that achieves a specific purpose.  

Routines prefixed HANDLE_ manage a particular aspect of the game.
    For example, HANDLE_PLAYER_MOVE is the core routine for reading the player joystick and moving the player ship. 
    HANDLE_PLAYER_SHOOT is the core routine for reading the player fire button and spawning a bullet.

I expect the purpose of DISPLAY_ is obvious.

SCRIPTS are documented below - see docs for SCRIPT_NUMBER ($4005)


ARRAYS, LISTS, TABLES
=====================

The terms "entry", "slot", "item", "record" when used in an array, list or table context all mean the same thing.
I try to be consistent with my terminology but obviously with a task this size that might not be the case.

Unless I specify otherwise, I all indexes into arrays/lists/tables are zero-based, 
meaning element [0] is the first element, [1] the second, [2] the third and so on.

FLAGS
=====
The terms "Clear", "Reset", "Unset" in a flag context all mean the flag is set to zero.
                                                                               

COORDINATES
===========

X,Y refer to the X and Y axis in a 2D coordinate system, where X is horizontal and Y is vertical.

The Galaxian monitor is rotated 90 degrees. This means that:
a) updating the hardware Y position of a sprite presents itself to the player as changing the horizontal position.
   To make a sprite appear to move left, you would increment its Y position.
   To make a sprite appear to move right, you would decrement its Y position.

b) updating the hardware X position of a sprite presents itself to the player as changing the vertical position. 
   To make a sprite appear to move up, you would decrement its X position.
   To make a sprite appear to move down, you would increment its X position.

So when you see code updating the Y coordinate when you would expect X to be updated, or vice versa, you now know why.

For info about the Galaxian video hardware see: https://github.com/mamedev/mame/blob/master/src/mame/video/galaxian.cpp
*/


Copied from MAME4All documentation: https://github.com/squidrpi/mame4all-pi/blob/master/src/drivers/galaxian.cpp
Some corrections applied from: https://github.com/mamedev/mame/blob/master/src/mame/drivers/galaxian.cpp

Galaxian/Moon Cresta memory map.
Compiled from information provided by friends and Uncles on RGVAC.

Add 0x4000 to all addresses except for the ROM for Moon Cresta.
            AAAAAA
            111111AAAAAAAAAA     DDDDDDDD   Schem   function
HEX         5432109876543210 R/W 76543210   name
0000-3FFF                                           Game ROM
4000-47FF                                           Working ram
5000-57FF   01010AAAAAAAAAAA R/W DDDDDDDD   !Vram   Character ram           
5800-583F   01011AAAAAAAAAAA R/W DDDDDDDD   !OBJRAM Screen attributes
5840-585F   01011AAAAAAAAAAA R/W DDDDDDDD   !OBJRAM Sprites
5860-5FFF   01011AAAAAAAAAAA R/W DDDDDDDD   !OBJRAM Bullets
6000        0110000000000000 R   -------D   !SW0    coin1
6000        0110000000000000 R   ------D-   !SW0    coin2
6000        0110000000000000 R   -----D--   !SW0    p1 left
6000        0110000000000000 R   ----D---   !SW0    p1 right
6000        0110000000000000 R   ---D----   !SW0    p1shoot
6000        0110000000000000 R   --D-----   !SW0    upright/cocktail
6000        0110000000000000 R   -D------   !SW0    test
6000        0110000000000000 R   D-------   !SW0    service
6000        0110000000000001 W   -------D   !DRIVER lamp 1
6001        0110000000000001 W   -------D   !DRIVER lamp 2
6002        0110000000000001 W   -------D   !DRIVER coin lockout
6003        0110000000000011 W   -------D   !DRIVER coin control
6004        0110000000000100 W   -------D   !DRIVER Background lfo freq bit0
6005        0110000000000101 W   -------D   !DRIVER Background lfo freq bit1
6006        0110000000000110 W   -------D   !DRIVER Background lfo freq bit2
6007        0110000000000111 W   -------D   !DRIVER Background lfo freq bit3
6800        0110100000000000 R   -------D   !SW1    1p start
6800        0110100000000000 R   ------D-   !SW1    2p start
6800        0110100000000000 R   -----D--   !SW1    p2 left
6800        0110100000000000 R   ----D---   !SW1    p2 right
6800        0110100000000000 R   ---D----   !SW1    p2 shoot
6800        0110100000000000 R   --D-----   !SW1    no used
6800        0110100000000000 R   -D------   !SW1    dip sw1
6800        0110100000000000 R   D-------   !SW1    dip sw2
6800        0110100000000000 W   -------D   !SOUND  reset background F1
                                                    (1=reset ?)
6801        0110100000000001 W   -------D   !SOUND  reset background F2
6802        0110100000000010 W   -------D   !SOUND  reset background F3
6803        0110100000000011 W   -------D   !SOUND  player hit
6804        0110100000000100 W   -------D   !SOUND  not used
6805        0110100000000101 W   -------D   !SOUND  shoot on/off
6806        0110100000000110 W   -------D   !SOUND  Vol of f1
6807        0110100000000111 W   -------D   !SOUND  Vol of f2

7000        0111000000000000 R   -------D   !DIPSW  dip sw 3
7000        0111000000000000 R   ------D-   !DIPSW  dip sw 4
7000        0111000000000000 R   -----D--   !DIPSW  dip sw 5
7000        0111000000000000 R   ----D---   !DIPSW  dip s2 6
7001/B000/1 0111000000000001 W   -------D   9Nregen NMIon
7002        Unused - thanks to Phil Murray for letting me know
7003        Unused
7004        0111000000000100 W   -------D   9Nregen stars on  
7006        0111000000000110 W   -------D   9Nregen hflip
7007        0111000000000111 W   -------D   9Nregen vflip
Note: 9n reg,other bits  used on moon cresta for extra graphics rom control.
7800        0111100000000000 R   --------   !wdr    watchdog reset
7800        0111100000000000 W   DDDDDDDD   !pitch  Sound Fx base frequency
*/

/*
DIP SWITCH SETTINGS

Taken from: http://arcarc.xmission.com/PDF_Arcade_Bally_Midway/Galaxian_Parts_and_Operating_Manual_(Feb_1980).pdf

METHOD OF PLAY:
                              SW.1          SW.2
1 COIN = 1 PLAY               OFF           OFF
2 COINS = 1 PLAY              ON            OFF
1 COIN = 2 PLAYS              OFF           ON
FREE PLAY                     ON            ON 


BONUS GALIXIP (PLAYER SHIP) - the manual above is not correct with the Namco Galaxian ROM. After doing some research,
here are the correct DIP switch settings: 


                              SW.3          SW.4
7000                          OFF           OFF  
10000                         ON            OFF
12000                         OFF           ON
20000                         ON            ON


NUMBER OF GALIXIP PER GAME
                               SW.5
2 GALIXIP PER GAME             OFF
3 GALIXIP PER GAME             ON

*/


/*
And now, the main game code.... enjoy.
*/

DIP_SWITCH_1_2_STATE                EQU $4000         // holds state of dip switches 1 & 2 in bits 0 & 1.
COIN_COUNT                          EQU $4001         // counts up to number of coins per credit as set by dip switches. When it reaches that value, resets to 0 
NUM_CREDITS                         EQU $4002         // number of credits
COIN_CONTROL                        EQU $4003         // is used to output to DRIVER|COIN CONTROL (see $1974)
UNPROCESSED_COINS                   EQU $4004         // bumps up when coin inserted. See $190B and $1931.

//
// The game follows what I call "scripts". A SCRIPT is a predefined sequence of STAGES (ie: subroutines) that implement an overall goal.
// The whole game is script-driven, from attract mode to the game itself.
//
// The NMI interrupt handler uses SCRIPT_NUMBER ($4005) to identify what script to run and, depending on the script, SCRIPT_STAGE ($400A) to 
// determine what subroutine to call to do the work for that stage of the script.  When the subroutine has completed its work, 
// it increments SCRIPT_STAGE which is akin to, "OK, I'm done// proceed to next stage of script".
//
// For example, a script for HELLO WORLD might be implemented as three stages:
// 1. Display Hello World on screen. Set SCRIPT_STAGE to 2.
// 2. Wait for key. Set SCRIPT_STAGE to 3 after key pressed.
// 3. Terminate program.
//
// When I've finished working out what all the scripts do, I'll replace the Hello World above with a real example from the game.
//
//
// The main take-aways from the above are:
// 1. The whole game is driven by the NMI interrupt.
// 2. Script stage and number are really just indexes into jump tables. 
//
// see $00CA for the NMI script handler. 

SCRIPT_NUMBER                       EQU $4005         // 0-based index into pointer table beginning @ $00CE
IS_GAME_IN_PLAY                     EQU $4006         // If set to 1, game is in play with a human in control.
IS_GAME_OVER                        EQU $4007         // Set to 1 when GAME OVER message appears. TODO: Check if set any other place than GAME OVER 
TEMP_COUNTER_1                      EQU $4008         // temporary counter used for delays, such as waiting before transitioning to next stage of a script
TEMP_COUNTER_2                      EQU $4009         // temporary counter used for delays

SCRIPT_STAGE                        EQU $400A         // Identifies what stage of the script we are at.  
                                                      // 0-based index into script tables located @ $0164, $0400, $0540, $0785
TEMP_CHAR_RAM_PTR                   EQU $400B         // pointer to character RAM. Used by screen-related routines (e.g. power on colour test) to remember where to plot characters on next call.
                                                                                                           
CURRENT_PLAYER                      EQU $400D         // 0 = PLAYER ONE, 1 = PLAYER TWO
IS_TWO_PLAYER_GAME                  EQU $400E         // 0 = One player game, 1 = 2 player game 
IS_COCKTAIL                         EQU $400F         // 0 = upright, 1 = Cocktail 
PORT_STATE_6000                     EQU $4010         // copy of state for memory address 6000 (SW0)          
PORT_STATE_6800                     EQU $4011         // copy of state for memory address 6800 (SW1 & SOUND)
PORT_STATE_7000                     EQU $4012         // copy of state for memory address 7000 (DIPSW)

PREV_PORT_STATE_6000                EQU $4013         // holds the previous state of memory address 6000 (SW0)  
PREV_PORT_STATE_6800                EQU $4014         // holds the previous state of memory address 6800 (SW1 & SOUND)
PREV_PREV_PORT_STATE_6000           EQU $4015         // holds the previous, previous (!) state of memory address 6000 (SW0) 
PREV_PREV_PREV_STATE_6000           EQU $4016         // holds the previous, previous, previous state of memory address 6000 (SW0)

DISPLAY_IS_COCKTAIL_P2              EQU $4018         // set to 1 when in cocktail mode and it's player 2's turn, so the screen's upside down.
PUSH_START_BUTTON_COUNTER           EQU $4019         // On inserting credit or GAME OVER: if you have credit, how long to wait before PUSH START BUTTON appears.  
DIAGNOSTIC_MESSAGE_TYPE             EQU $401A         // Read by the NMI handler. Refer to code @1BCD for docs.  

RAND_NUMBER                         EQU $401E         // TENTATIVE NAME. Random number used in tests and in-game 
DIP_SWITCH_5_STATE                  EQU $401F         // holds cached state of dip switch 5 in bit 0

// Object RAM back buffer. 
// Colour attributes, scroll offsets and sprite state are held in this buffer and updated by the game. 
// When all the updates are complete and ready to be presented on screen to the player, 
// the back buffer is copied to the hardware's OBJRAM by an LDIR operation - see $0079.
// Effectively all colours, scroll and sprites are updated as part of a single operation.
// This back buffering technique is still used today in modern games.
//
// The back buffer is organised thus:
//
// From $4020 - 405f: column scroll and colour attributes. Maps directly to $5800 - $583F. 
//    Note: Even numbered addresses hold scroll offsets, odd numbered addresses colour attributes. 
// From $4060 - 407F: 8 entries of type INFLIGHT_ALIEN_SPRITE. Maps directly to $5840 - $585F.
// From $4080 - 409F: alien bullets and player bullet sprite state. Maps directly to $5860 - $587F. 

OBJRAM_BACK_BUF                     EQU $4020            
OBJRAM_BACK_BUF_SPRITES             EQU $4060 

//struct INFLIGHT_ALIEN_SPRITE
//{
//   BYTE Y//                      
//   BYTE Code//                   // bits 0..5: sprite frame. bit 6 set = XFlip. bit 7 set = YFlip
//   BYTE Colour//
//   BYTE X//                      
//} - sizeof(INFLIGHT_ALIEN_SPRITE) is 4 bytes


OBJRAM_BACK_BUF_BULLETS             EQU $4080
    OBJRAM_BUF_PLAYER_BULLET_Y      EQU $409D
    OBJRAM_BUF_PLAYER_BULLET_X      EQU $409F
OBJRAM_BACK_BUF_END                 EQU $409F                        


PLAYER_ONE_SCORE                      EQU $40A2       // stored as 3 BCD bytes, 2 digits per byte: $40A2 = last 2 digits of score (tens), $40A3 = 3rd & 4th digits, $40A4 = 1st & 2nd
                                                      // e.g. a score of 123456 would be stored like so:
                                                      // $40A2: 56
                                                      // $40A3: 34
                                                      // $40A4: 12

PLAYER_TWO_SCORE                      EQU $40A5       // stored as 3 BCD bytes, 2 digits per byte: same format & order as PLAYER_ONE_SCORE
HI_SCORE                            EQU $40A8         // stored as 3 BCD bytes, 2 digits per byte: same format & order as PLAYER_ONE_SCORE

CAN_BLINK_1UP_2UP                   EQU $40AB         // When IS_GAME_IN_PLAY is set to 1, this flag is set to 1 to allow 1UP or 2UP to "blink". See @$20A7
BONUS_GALIXIP_FOR                   EQU $40AC         // stored as BCD in 1 byte. e.g. 07 = bonus galixip for 7000, 20 = bonus galixip for 20000. 
PLAYER_ONE_AWARDED_EXTRA_LIFE         EQU $40AD       // Set to 1 if player one has been awarded an extra life. No more extra lives will be given. 
PLAYER_TWO_AWARDED_EXTRA_LIFE         EQU $40AE       // Set to 1 if player two has been awarded an extra life. No more extra lives will be given. 


IS_COLUMN_SCROLLING                 EQU $40B0         // Set to 1 if a column is being scrolled. For example when points are scrolled into view on the WE ARE THE GALAXIANS screen
COLUMN_SCROLL_ATTR_BACKBUF_PTR      EQU $40B1         // pointer to scroll attribute data to update in OBJRAM_BACK_BUF. 
COLUMN_SCROLL_NEXT_CHAR_PTR         EQU $40B3         // pointer to ordinal of next character to scroll on
COLUMN_SCROLL_CHAR_RAM_PTR          EQU $40B5         // pointer to character RAM where next character will be plotted. 


// Phil Murray (PhilMurr on UKVAC) gave me a heads up on this.  
//
// $40C0 to $40FF is reserved for a circular queue. The queue is comprised of byte pairs representing a command and parameter.
// NB: I term the byte pair a *Queue Entry* in the code @$08f2 and $200A.
//
// As 64 bytes are reserved for the queue, that means 32 commands and parameters can be stored. 
//
// The memory layout of the queue is quite simple.
// 
// $40C0: command A
// $40C1: parameter for command A 
// $40C2: command B
// $40C3: parameter for command B
// $40C4: command C
// $40C5: parameter for command C
// ..and so on.
//
// See docs @ $08f2 for info about what commands are available, and how to add commands to the queue.
// See docs @ $200A for info about how commands are processed.
//


CIRC_CMD_QUEUE_PTR_LO           EQU $40A0             // low byte of a pointer to a (hopefully) vacant entry in the circular queue. See $08F2 
CIRC_CMD_QUEUE_PROC_LO          EQU $40A1             // low byte of a pointer to the next entry in the circular queue to be processed. See $200C
CIRC_CMD_QUEUE_START            EQU $40C0
CIRC_CMD_QUEUE_END              EQU $40FF


//
// ALIEN_SWARM_FLAGS (name subject to change) is an array 128 bytes in size.   
// Each byte contains a bit flag indicating the presence of an alien at a given position.
// If you start a new game in MAME, then open the debugger and view memory location 4100 (hex) you will see this:
//
// 4100:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  
// 4110:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  
// 4120:  00 00 00 01 01 01 01 01 01 01 01 01 01 00 00 00  
// 4130:  00 00 00 01 01 01 01 01 01 01 01 01 01 00 00 00  
// 4140:  00 00 00 01 01 01 01 01 01 01 01 01 01 00 00 00  
// 4150:  00 00 00 00 01 01 01 01 01 01 01 01 00 00 00 00  
// 4160:  00 00 00 00 00 01 01 01 01 01 01 00 00 00 00 00  
// 4170:  00 00 00 00 00 00 01 00 00 01 00 00 00 00 00 00

112
96

01110000   00001110.       
01100000   00001100.  
01010000.  00001010.  10. flagship
01000000.  00001000.  8.  red
00110000.  00000110.  6.  purple
00100000.  00000100.  4   blue
00010000.  00000010.  2   blue
00000000.  00000000.  0   blue

//1
// This is the representation of the swarm in memory! 01 means "an alien is here" and 00 means "nothing here".
// The memory representation is upside down *and* flipped horizontally.  
//
// To visualise it properly, turn the dump above upside down using your favourite text editor, erase the "00"s and you get:
// 4170:                    01       01                       // flagships
// 4160:                 01 01 01 01 01 01                    // red
// 4150:              01 01 01 01 01 01 01 01                 // purple
// 4140:           01 01 01 01 01 01 01 01 01 01              // blue
// 4130:           01 01 01 01 01 01 01 01 01 01              // blue
// 4120:           01 01 01 01 01 01 01 01 01 01              // blue
// 
// Look familiar? 
//
//  

ALIEN_SWARM_FLAGS                   EQU $4100         // 128 bytes, occupying $4100 to $417F in RAM


// When it's player 1's turn, the packed swarm definition PLAYER_ONE_PACKED_SWARM_DEF is unpacked to ALIEN_SWARM_FLAGS and the fields comprising PLAYER_ONE_STATE ($4190-4197) 
// are written to their counterparts in CURRENT_PLAYER_STATE (see docs @$4218)                
PLAYER_ONE_PACKED_SWARM_DEF           EQU $4180       // Used to track state of the swarm for player one, e.g. so swarm can be restored after player two's turn is over 
PLAYER_ONE_STATE                      EQU $4190
PLAYER_ONE_DIFFICULTY_COUNTER_1       EQU $4190         
PLAYER_ONE_DIFFICULTY_COUNTER_2       EQU $4191
PLAYER_ONE_DIFFICULTY_EXTRA_VALUE     EQU $4192           
PLAYER_ONE_DIFFICULTY_BASE_VALUE      EQU $4193         
PLAYER_ONE_LEVEL                      EQU $4194
PLAYER_ONE_LIVES                      EQU $4195
PLAYER_ONE_FLAGSHIP_SURVIVOR_COUNT    EQU $4196         
PLAYER_ONE_LFO_FREQ_BITS              EQU $4197         


// When it's player 2's turn, the packed swarm definition PLAYER_TWO_PACKED_SWARM_DEF is unpacked to ALIEN_SWARM_FLAGS and the fields comprising PLAYER_TWO_STATE ($41B0-41B7) 
// are written to their counterparts in CURRENT_PLAYER_STATE (see docs @$4218)                
PLAYER_TWO_PACKED_SWARM_DEF           EQU $41A0       // Used to track state of the swarm for player two, e.g. so swarm can be restored after player one's turn is over
PLAYER_TWO_STATE                      EQU $41B0
PLAYER_TWO_DIFFICULTY_COUNTER_1       EQU $41B0         
PLAYER_TWO_DIFFICULTY_COUNTER_2       EQU $41B1
PLAYER_TWO_DIFFICULTY_EXTRA_VALUE     EQU $41B2           
PLAYER_TWO_DIFFICULTY_BASE_VALUE      EQU $41B3         
PLAYER_TWO_LEVEL                      EQU $41B4
PLAYER_TWO_LIVES                      EQU $41B5
PLAYER_TWO_FLAGSHIP_SURVIVOR_COUNT    EQU $41B6         
PLAYER_TWO_LFO_FREQ_BITS              EQU $41B7         


SOUND_VOL                           EQU $41C0         // Bit 0 and 1 are written to !SOUND Vol of F1 and !SOUND Vol of F2 respectively. See $1712
PITCH_SOUND_FX_BASE_FREQ            EQU $41C1         // used to write to !pitch  Sound Fx base frequency. See $171F
ENABLE_ALIEN_ATTACK_SOUND           EQU $41C2         // When set to 1, turns on alien attack noise, see $17D0
UNKNOWN_SOUND_41C3                  EQU $41C3          
UNKNOWN_SOUND_41C4                  EQU $41C4         // Seems to affect the pitch of the alien attack noise. 

PLAY_EXTRA_LIFE_SOUND               EQU $41C7         // when set to 1, play the sound of an extra life being awarded. See $184F
EXTRA_LIFE_SOUND_COUNTER            EQU $41C8            
PLAY_PLAYER_CREDIT_SOUND            EQU $41C9         // when set to 1, play the sound of player credits being added. See $1876
PLAYER_CREDIT_SOUND_COUNTER         EQU $41CA         // The higher the value, the longer the player credit sound plays.
                                    EQU $41CB          
PLAY_PLAYER_SHOOT_SOUND             EQU $41CC         // When set to 1, play the sound of the player's bullet. See $1723
IS_COMPLEX_SOUND_PLAYING            EQU $41CD         // When set to 1, a sequence of sounds, or a melody, is playing. 
PLAYER_SHOOT_SOUND_COUNTER          EQU $41CE         // The higher the value, the longer the player spaceship bullet sound plays.
                                    EQU $41CF 
RESET_SWARM_SOUND_TEMPO             EQU $41D0         // When set to 1, resets the tempo of the "swarm" sound to slow again. See $1898
PLAY_GAME_START_MELODY              EQU $41D1         // When set to 1, plays the game start tune. 
                                    EQU $41D2         // sound related
COMPLEX_SOUND_POINTER               EQU $41D3         // If music or complex sound effect is playing, this points to the current sound/musical note being played. See $1782
                                    EQU $41D5         // Used to set !Pitch Sound FX base frequency
DELAY_BEFORE_NEXT_SOUND             EQU $41D6         // counter. When counts to zero the next sound/musical note is played. See $177B
ALIEN_DEATH_SOUND                   EQU $41DF         // Tentative name. When set to $06: plays alien death sound. When set to $16, plays flagship death sound. See @$1819
                                    EQU $41E8

// HAVE_ALIENS_IN_ROW_FLAGS is an array of 6 bytes. Each byte contains a bit flag specifying if there are any aliens on a given row.
HAVE_ALIENS_IN_ROW_FLAGS            EQU $41E8
NEVER_USED_ROW_1                    EQU $41E8
NEVER_USED_ROW_2                    EQU $41E9

HAVE_ALIENS_IN_6TH_ROW              EQU $41EA         // flag set to 1 if there are any aliens in the bottom row (blue aliens)
HAVE_ALIENS_IN_5TH_ROW              EQU $41EB         // flag set to 1 if there are any aliens in the 5th row (blue aliens)
HAVE_ALIENS_IN_4TH_ROW              EQU $41EC         // flag set to 1 if there are any aliens in the 4th row (blue aliens)
HAVE_ALIENS_IN_3RD_ROW              EQU $41ED         // flag set to 1 if there are any aliens in the 3rd row (purple aliens)
HAVE_ALIENS_IN_2ND_ROW              EQU $41EE         // flag set to 1 if there are any aliens in the 2nd row (red aliens)
HAVE_ALIENS_IN_TOP_ROW              EQU $41EF         // flag set to 1 if there are any aliens in the top row (flagships)


// ALIEN_IN_COLUMN_FLAGS is an array 16 bytes in size. Each byte contains a bit flag specifying if there are any aliens in a specific column. 
// IMPORTANT: The flags are ordered from rightmost column of aliens to the leftmost. Only 10 of the flags are used.
// 
// In a nutshell:
// $41F0..$41F2: unused. Always set to 0.
// $41F3: set to 1 if any aliens are in the rightmost column of the swarm.
// $41F4: set to 1 if any aliens are in the 2nd rightmost column of the swarm.
// $41F5: set to 1 if any aliens are in the 3rd rightmost column of the swarm.
// ..
// $41FC: set to 1 if any aliens are in the leftmost column of the swarm.
// $41FD..$41FF: unused. Always set to 0.
//
// The flags have three purposes: 
// 1: To halt the swarm when a bullet is getting too close (see $0936)
// 2: to calculate how far the swarm can scroll before it needs to change direction (see $093E)
// 3: to find aliens at the swarm edges to attack the player (see code from $137B onwards) 
//
//
// To further clarify in case there's any confusion, let's assume you've just started the game and you're on the first level. 
// You haven't shot anything yet. The alien swarm will be in the following formation:
//
//      F  F                     F = Flagship row  
//     RRRRRR                    R = Red alien row
//    PPPPPPPP                   P = Purple alien row
//   BBBBBBBBBB                  B = Blue alien row
//   BBBBBBBBBB
//   BBBBBBBBBB 
//
// Press PAUSE in MAME and open the memory debugger at location $41F0.
// The flags will look like so in the MAME memory window:
// 00 00 00 01 01 01 01 01 01 01 01 01 01 00 00 00
//
// You'll note that there are 10 flags set to TRUE (01) in a row. That is because the bottommost row has 10 blue aliens. 
// If you were to shoot the blue aliens in the rightmost column, you would see the first 01 (at memory address $41F3) turn into a 0, 
// meaning that column no longer contains any aliens. 
// 
// 0 is also written to the flags when the only alien in a column breaks off from the swarm to attack the player.
// 
                                           
ALIEN_IN_COLUMN_FLAGS               EQU $41F0          
ALIEN_IN_COLUMN_FLAGS_END           EQU $41FF     


HAS_PLAYER_SPAWNED                  EQU $4200         // set to 1 when player has spawned. (Also set in attract mode) 
IS_PLAYER_DYING                     EQU $4201         // set to 1 when player is in the process of exploding horribly. See $1327
PLAYER_Y                            EQU $4202         // Player Y coordinate. Used to set scroll offsets for column containing ship characters. See $0865
 
IS_PLAYER_HIT                       EQU $4204         // When set to 1, player has been hit by a missile or collided with an alien.         
PLAYER_EXPLOSION_COUNTER            EQU $4205         // Only evaluated when IS_PLAYER_DYING is set to 1. Determines how long the player explosion animation lasts. 
                                                      // When it counts down to 0, explosion animation stops. See $132C
PLAYER_EXPLOSION_ANIM_FRAME         EQU $4206         // Set by $12FE 
HAS_PLAYER_BULLET_BEEN_FIRED        EQU $4208         // set 1 when the player has fired a bullet and the bullet is still onscreen. See $08BC
PLAYER_BULLET_X                     EQU $4209         // Current X coordinate of player bullet. 
PLAYER_BULLET_Y                     EQU $420A         // Current Y coordinate of player bullet. 
IS_PLAYER_BULLET_DONE               EQU $420B         // set 1 when player bullet goes as far as it can upscreen (see $08CD), or hits an alien (see $0B4F & $125B).

SWARM_DIRECTION                     EQU $420D         // Direction of swarm (really? //) )  0 = Moving left, 1 = moving right . See $0945              
SWARM_SCROLL_VALUE                  EQU $420E         // 16 bit value. Used to set the scroll values for the character columns containing the swarm.                            
SWARM_SCROLL_MAX_EXTENTS            EQU $4210         // Used to limit the scrolling of the swarm so no alien goes "off screen". See $09CE 

// INFLIGHT_ALIEN_SHOOT_EXACT_X and MINFLIGHT_ALIEN_SHOOT_RANGE_MUL are used to determine if an alien can shoot a bullet. See $0E54 for information.
INFLIGHT_ALIEN_SHOOT_RANGE_MUL      EQU $4213         // Range multiplier.   
INFLIGHT_ALIEN_SHOOT_EXACT_X        EQU $4214         // Exact X coordinate that calculated value must match for alien to shoot.

ALIENS_ATTACK_FROM_RIGHT_FLANK      EQU $4215         // Flag used to determine what side of swarm aliens break off from. (0=break from left, 1=break from right). See $136f and $1426 
                                    EQU $4217         // 

// $4218 - $421F holds important, albeit transient, state for the current player such as number of lives and difficulty level.
CURRENT_PLAYER_STATE                EQU $4218                    

// These 2 counters are used to gradually increase the DIFFICULTY_EXTRA_VALUE over time. See $14F3 for algorithm details.
DIFFICULTY_COUNTER_1                EQU $4218         // Counts down to zero. 
DIFFICULTY_COUNTER_2                EQU $4219         // Counts down to zero. When it reaches zero, DIFFICULTY_EXTRA_VALUE is incremented.

// These values determine how often aliens attack (see $1524 and $1583), and how many can attack at one time (see $1352). 
DIFFICULTY_EXTRA_VALUE              EQU $421A         // DIFFICULTY_EXTRA_VALUE is incremented during the level. Maximum value of 7. See $1509.  
DIFFICULTY_BASE_VALUE               EQU $421B         // DIFFICULTY_BASE_VALUE is incremented when you complete a level. Maximum value of 7. See $1656.

PLAYER_LEVEL                        EQU $421C         // Current player's level. Starts from 0. Add 1 to get true value. See $252C.
PLAYER_LIVES                        EQU $421D         // current player's lives
FLAGSHIP_SURVIVOR_COUNT             EQU $421E         // When starting a new level, how many surviving flagships can we bring over from the previous level? Maximum value 2.  See $166C
LFO_FREQ_BITS                       EQU $421F         // Value used to set !DRIVER Background lfo frequency ports (0-3) for the "swarm" noise

CURRENT_PLAYER_STATE_END            EQU $421F                

HAVE_NO_ALIENS_IN_SWARM             EQU $4220         // Set to 1 when $4100 - $417F are set to 0. Aliens are either all dead, or are in flight and out of the swarm. See $0A0F
HAVE_NO_BLUE_OR_PURPLE_ALIENS       EQU $4221         // When set to 1, all the blue and purple aliens have died, or are in flight. See $09FA and $1571  
LEVEL_COMPLETE                      EQU $4222         // When set to 1, the level is treated as complete. See @$1621, $1637
NEXT_LEVEL_DELAY_COUNTER            EQU $4223         // After all aliens have fled or been killed, this counts down to give the player breathing space. When it hits 0, the next wave starts. See $1637
HAVE_AGGRESSIVE_ALIENS              EQU $4224         // when set to 1, inflight aliens will not return to swarm and keep attacking player until they die - or you die. See $16B8
HAVE_NO_INFLIGHT_OR_DYING_ALIENS    EQU $4225         // When set to 1, there are no aliens inflight, or dying. See $06BC
HAVE_NO_INFLIGHT_ALIENS             EQU $4226         // When set to 1, no aliens have broken off from the swarm to attack the player.
CAN_ALIEN_ATTACK                    EQU $4228         // When set to 1, a single alien should break off from the swarm to attack the player. See $1344.
CAN_FLAGSHIP_OR_RED_ALIENS_ATTACK   EQU $4229         // When set to 1, a flagship should attack the player, with an escort if possible. If no flagships alive, send red aliens.  See $140C.
FLAGSHIP_ESCORT_COUNT               EQU $422A         // Number of red aliens escorting the flagship. Max value of 2. See $0D58.

// When you shoot an enemy flagship in flight that this puts the aliens into a state of "shock" where they are afraid to leave the swarm for a while.
// No aliens will leave the swarm while $422B is set to 1 and $422C is non-zero. 
IS_FLAGSHIP_HIT                     EQU $422B         // Set to 1 when you've shot a flagship in flight. See $127C  
ALIENS_IN_SHOCK_COUNTER             EQU $422C         // When $422B is set to 1, this counter decrements. When it hits 0, $422B will be set to 0, meaning aliens can leave the swarm again.  
FLAGSHIP_SCORE_FACTOR               EQU $422D         // When you shoot a flagship, this is used to compute your score. Couldn't think of a better name! See $127C

ENABLE_FLAGSHIP_ATTACK_SECONDARY_COUNTER      EQU $422E         // when set to 1, FLAGSHIP_ATTACK_SECONDARY_COUNTER is allowed to decrement.             
FLAGSHIP_ATTACK_SECONDARY_COUNTER   EQU $422F         // Counts down to 0. When reaches zero, CAN_FLAGSHIP_OR_RED_ALIENS_ATTACK will be set to 1.

DISABLE_SWARM_ANIMATION             EQU $4238         // When set to 1, alien swarm won't animate. See $2067 for docs. 
ATTRACT_MODE_FAKE_CONTROLLER        EQU $423F         // used to simulate a players movements on the ATTRACT MODE screen. Contains bit values that map to SW0.
ATTRACT_MODE_SCROLL_ID              EQU $4241         // Identifies what points values are being scrolled in on attract mode. 1:Flagship. 2: Red Alien. 3: Purple alien. 4: Blue alien. 

// These 2 counters are used to determine when a flagship is permitted to attack.  See $156A.
FLAGSHIP_ATTACK_MASTER_COUNTER_1    EQU $4245          
FLAGSHIP_ATTACK_MASTER_COUNTER_2    EQU $4246          

// ALIEN_ATTACK_COUNTERS is an array of BYTE counters that control when aliens (but not flagships) break off from the swarm to attack. 
// ALIEN_ATTACK_MASTER_COUNTER at $424A is the first element of the array. The secondary counters are stored in $424B to $425A. 
// The ALIEN_ATTACK_MASTER_COUNTER acts as a gateway to the secondary counters// only when the master counter reaches zero will the secondary counters in the array be decremented.
// If any of the secondary counters reach zero, an alien will attack the player. See $1532 for more info.
ALIEN_ATTACK_COUNTERS               EQU $424A  
ALIEN_ATTACK_MASTER_COUNTER         EQU $424A
ALIEN_ATTACK_SECONDARY_COUNTERS     EQU $425B         
ALIEN_ATTACK_SECONDARY_COUNTERS_END EQU $425A     


TIMING_VARIABLE                     EQU $425F         // Perpetually decremented by the NMI handler. Routines use this variable to determine when to execute.
                                                         

// ENEMY_BULLETS is an array of type ENEMY_BULLET. 
//
// The array occupies memory locations $4260 - $42A5// It is thus 70 bytes in size. 
// As an ENEMY_BULLET record only requires 5 bytes, this means that there's room for 14 enemy bullets in the array.
//

struct ENEMY_BULLET
{
    BYTE IsActive//
    BYTE X//
    BYTE YL//                                       // low byte of the Y coordinate. Used to represent "fractional part" of Y coordinate
    BYTE YH//                                       // high byte of the Y coordinate.  
    BYTE YDelta//                                   // packed delta to add to YH *and* YL. Bit 7 = sign bit. Bits 0-6 = delta. See @$0AA1.                                  
} - sizeof(ENEMY_BULLET) is 5 bytes

ENEMY_BULLETS                       EQU $4260
ENEMY_BULLETS_START                 EQU $4260                                                                        
ENEMY_BULLETS_END                   EQU $42A5



// INFLIGHT_ALIENS is an array of type INFLIGHT_ALIEN. 
// An "Inflight alien" is my term for an alien that has broken off from the main swarm body to attack the player. 
//
// The array occupies memory locations $42B0 - $43AF// It is thus 256 bytes in size. 
// As the INFLIGHT_ALIEN type is 32 bytes in size, this means that there's room for 8 entries in the array. 
//
// Slot 0 in the array is actually reserved for misc use, such as when you shoot an alien in the swarm body and an 
// explosion animation needs a free sprite to play. (See: $0B52 for an example of this)
//
// Slot  1 is reserved for the flagship. 
// Slots 2 and 3 are reserved for the flagship's escorts.
// Slots 4,5,6,7 are reserved for individual attacking aliens.
//
// This means there can be 7 aliens in flight maximum. 
//
//  

//
// struct INFLIGHT_ALIEN
{
  0    BYTE IsActive//                        // Set to 1 when the alien is to be processed. 
  1    BYTE IsDying//                         // Set to 1 when the alien is in the process of exploding.
  2    BYTE StageOfLife                      // See $0CD6 for details. 
  3    BYTE X//                               // X coordinate
  4    BYTE Y//                               // Y coordinate. 
  5    BYTE AnimationFrame// 
  6    BYTE ArcClockwise                     // Set to 1 if the alien will rotate clockwise as it leaves the swarm or loops the loop. See $0D71 and $101F
  7    BYTE IndexInSwarm                     // index of alien within ALIEN_SWARM_FLAGS array
  8    BYTE ???                              // Unused
  9    BYTE PivotYValue                      // When alien is attacking, this value + $19 produces INFLIGHT_ALIEN.Y coordinate. See $0DF6
  A    BYTE ???                              // Unused
  B    BYTE ???                              // Unused
  C    BYTE ???                              // Unused 
  D    BYTE ???                              // Unused
  E    BYTE ???                              // Unused
  F    BYTE AnimFrameStartCode               // Base animation frame number to which a number is added to compute sprite "code"
  10   BYTE TempCounter1                     // Counter used for various timing purposes
  11   BYTE TempCounter2                     // Secondary counter for various timing purposes
  12   BYTE DeathAnimCode                    // when IsDying is set to 1, specifies the animation frame to display. See @$0C9F
  13   BYTE ArcTableLsb                      // LSB of pointer into INFLIGHT_ALIEN_ARC_TABLE @$1E00. See docs @$0D71 and $1E00.
  14   BYTE ???                              // Unused  
  15   BYTE ???                              // Unused
  16   BYTE Colour
  17   BYTE SortieCount                      // Number of times the alien has reached the bottom of the screen then resumed attack on the player. Reset to 0 when rejoins swarm. See $0E9D.
  18   BYTE Speed                            // Value from 0..3. The higher the number the faster the alien moves. See $116B. 
  19   BYTE PivotYValueAdd                   // Signed number which is added to INFLIGHT_ALIEN.PivotYValue to produce INFLIGHT_ALIEN.Y. See $0DF6
  1A   BYTE ???                              
  1B   BYTE ???                                
  1C   BYTE ???
  1D   BYTE ???
  1E   BYTE ???                                
  1F   BYTE ???                              
}  - sizeof(INFLIGHT_ALIEN) is 32 bytes


INFLIGHT_ALIENS                     EQU $42B0
INFLIGHT_ALIENS_END                 EQU $43AF


0000: AF            xor  a
0001: 32 01 70      ld   ($7001),a           // write to regen NMIon
0004: C3 55 1A      jp   $1A55
0007: FF            rst  $38



ASSERT_NOT_GAME_OVER:
0008: 3A 07 40      ld   a,($4007)           // read IS_GAME_OVER flag
000B: 0F            rrca                     // move flag into carry
000C: D0            ret  nc                  // if flag was 1, carry is set, it's GAME OVER, return
000D: 33            inc  sp                  // increment sp by 2..  
000E: 33            inc  sp                  // ..effectively discarding the return address on the stack
000F: C9            ret                      // and we're done

//
// Fill memory from HL to HL+B with value A.
//
// expects:
// A = value to write
// B = count
// HL = pointer 
//
// Returns:
// A same as on entry
// HL will be HL+ B
// B will be 0

0010: 77            ld   (hl),a
0011: 23            inc  hl
0012: 10 FC         djnz $0010
0014: C9            ret


0015: FF            rst  $38
0016: 9F            sbc  a,a
0017: FF            rst  $38


0018: 77            ld   (hl),a
0019: 23            inc  hl
001A: 10 FC         djnz $0018
001C: 0D            dec  c
001D: 20 F9         jr   nz,$0018
001F: C9            ret


//
// Return the byte at HL + A.
// i.e: in BASIC this would be akin to: result = PEEK (HL + A)
//
// expects:
// A = offset
// HL = pointer
//
// returns:
// A = the contents of (HL + A)
//

0020: 85            add  a,l                 // a+=l
0021: 6F            ld   l,a                 
0022: 3E 00         ld   a,$00               
0024: 8C            adc  a,h                 
0025: 67            ld   h,a                 // effectively: HL = HL + A. Now hl is set to point to byte to read
0026: 7E            ld   a,(hl)              // load a with contents of (HL)
0027: C9            ret

//
// Jump to instruction in table.
//
// Immediately after the RST 28 call, there must be a table of pointers to code.
// A is a zero-based index into the table.
// 
// Expects:
// A = index. Is multiplied by 2 to form an offset into the succeeding table.
// 
//

0028: 87            add  a,a                 // multiply A by 2. 
0029: E1            pop  hl                  // pop return address off stack into HL
002A: 5F            ld   e,a
002B: 16 00         ld   d,$00               // extend A into DE. Now DE = offset into table
002D: 19            add  hl,de               // Effectively, HL = HL + offset into table
002E: 5E            ld   e,(hl)              // load E from table
002F: 23            inc  hl                
0030: 56            ld   d,(hl)              // load D from table. Now DE = a pointer to code.
0031: EB            ex   de,hl               // 
0032: E9            jp   (hl)                // Jump to code specified by table entry.

0033: FF            rst  $38
0034: FF            rst  $38
0035: FF            rst  $38
0036: FF            rst  $38
0037: FF            rst  $38


0038: C3 00 00      jp   $0000
003B: FF            rst  $38


//
// A very primitive pseudo-random number generator.
//

GENERATE_RANDOM_NUMBER:
003C: 3A 1E 40      ld   a,($401E)          
003F: 47            ld   b,a
0040: 87            add  a,a
0041: 87            add  a,a
0042: 80            add  a,b
0043: 3C            inc  a
0044: 32 1E 40      ld   ($401E),a
0047: C9            ret

//
// Used by the aliens to determine what way to face when flying down, and what delta enemy bullets take
//
// Expects:
// A = distance
// D = X coordinate
//

CALCULATE_TANGENT:
0048: 0E 00         ld   c,$00
004A: 06 08         ld   b,$08
004C: BA            cp   d
004D: 38 01         jr   c,$0050
004F: 92            sub  d
0050: 3F            ccf
0051: CB 11         rl   c
0053: CB 1A         rr   d
0055: 10 F5         djnz $004C
0057: C9            ret

0058: FF            rst  $38
0059: FF            rst  $38
005A: FF            rst  $38
005B: FF            rst  $38
005C: FF            rst  $38
005D: FF            rst  $38
005E: FF            rst  $38
005F: FF            rst  $38
0060: FF            rst  $38
0061: FF            rst  $38
0062: FF            rst  $38
0063: FF            rst  $38
0064: FF            rst  $38
0065: 8D            adc  a,l


//
// Non Maskable Interrupt (NMI) handler.
//
// Thanks to Phil Murray (PhilMurr on UKVAC) for pointing out the significance of memory address $66 to me.
// It's been a while since I looked at Z80 hardware... :)
//

0066: F5            push af
0067: C5            push bc
0068: D5            push de
0069: E5            push hl
006A: DD E5         push ix
006C: FD E5         push iy
006E: AF            xor  a
006F: 32 01 70      ld   ($7001),a           // Write to regen NMIon. This must disable further NMIs until the handler is done.
0072: 3A 1A 40      ld   a,($401A)           // read DIAGNOSTIC_MESSAGE_TYPE
0075: A7            and  a                   // test if zero
0076: C2 CD 1B      jp   nz,$1BCD            // if not zero, goto $1BCD - perform a diagnostic test

// update screen in one go - IMPORTANT
0079: 21 20 40      ld   hl,$4020            // pointer to OBJRAM_BACK_BUF buffer held in RAM
007C: 11 00 58      ld   de,$5800            // start of screen attribute RAM
007F: 01 80 00      ld   bc,$0080            // number of bytes to copy from OBJRAM_BACK_BUF 
0082: ED B0         ldir                     // update screen & sprites in one go

// read ports and stash values read in RAM
0084: 3A 00 78      ld   a,($7800)           // kick the watchdog
0087: 3A 15 40      ld   a,($4015)           // read previous, previous state of port 6000 (SW0)
008A: 32 16 40      ld   ($4016),a           // and write to PREV_PREV_PREV_STATE_6000 
008D: 3A 13 40      ld   a,($4013)           // read previous state of port 6000 (SW0)
0090: 32 15 40      ld   ($4015),a           // and write to PREV_PREV_PORT_STATE_6000  
0093: 2A 10 40      ld   hl,($4010)          // read state of 6000 (SW0) and 6800 (SW1 & SOUND)
0096: 22 13 40      ld   ($4013),hl          // and write to previous state value
0099: 3A 00 70      ld   a,($7000)           // read state of DIPSW
009C: 32 12 40      ld   ($4012),a           // and write to PORT_STATE_7000 holder
009F: 3A 00 68      ld   a,($6800)           // read start button, p2 control, dipsw 1/2 state 
00A2: 32 11 40      ld   ($4011),a           // and write to PORT_STATE_6800 holder
00A5: 3A 00 60      ld   a,($6000)           // read coin, p1 control, test & service state
00A8: 32 10 40      ld   ($4010),a           // and write to PORT_STATE_6000 holder

// check if TEST pressed
00AB: CB 77         bit  6,a                 // read TEST bit
00AD: C2 00 00      jp   nz,$0000            // if bit set, goto $0000 - redo test sequence

// if TEST not pressed
00B0: 21 5F 42      ld   hl,$425F            // pointer to TIMING_VARIABLE
00B3: 35            dec  (hl)                // decrement value
                     
00B4: CD EF 18      call $18EF               // call CHECK_IF_COIN_INSERTED
00B7: CD 31 19      call $1931               // call HANDLE_UNPROCESSED_COINS
00BA: CD 7C 19      call $197C               // call HANDLE_COIN_LOCKOUT
00BD: CD F5 16      call $16F5               // call HANDLE_SOUND
00C0: CD 98 18      call $1898               // call HANDLE_SWARM_SOUND
00C3: CD C0 18      call $18C0               // call HANDLE_TEXT_SCROLL

// invoke script [SCRIPT_NUMBER]
00C6: 21 D8 00      ld   hl,$00D8            // return address
00C9: E5            push hl                  // save it on the stack. RET will return to $00D8 
00CA: 3A 05 40      ld   a,($4005)           // read SCRIPT_NUMBER
00CD: EF            rst  $28                 // jump to code @ $00CE + (A*2)

SCRIPT_TABLE:
00CE: 
     E6 00          // $00E6   (SCRIPT_ZERO)    
     56 01          // $0156   (SCRIPT_ONE)
     F2 03          // $03F2   (SCRIPT_TWO)
     36 05          // $0536   (SCRIPT_THREE)
     7B 07          // $077B   (SCRIPT_FOUR)


00D8: FD E1         pop  iy
00DA: DD E1         pop  ix
00DC: E1            pop  hl
00DD: D1            pop  de
00DE: C1            pop  bc
00DF: 3E 01         ld   a,$01
00E1: 32 01 70      ld   ($7001),a           // Write to regen NMIon. I think this will re-enable NMIs.
00E4: F1            pop  af
00E5: C9            ret



//
// 
// 
//
//

SCRIPT_ZERO:
// clear [TEMP_COUNTER_1] rows on screen.
00E6: 2A 0B 40      ld   hl,($400B)          // Read TEMP_CHAR_RAM_PTR. This holds character RAM to start clearing from
00E9: 06 20         ld   b,$20               // #$20 (32 decimal) bytes to fill in a row
00EB: 3E 10         ld   a,$10               // ordinal of empty character
00ED: D7            rst  $10                 // Clear entire row of characters
00EE: 22 0B 40      ld   ($400B),hl          // save in TEMP_CHAR_RAM_PTR
00F1: 21 08 40      ld   hl,$4008            // load HL with address of TEMP_COUNTER_1
00F4: 35            dec  (hl)                // decrement value
00F5: C0            ret  nz                  // if counter hasn't hit zero, return

00F6: 2D            dec  l                   // point HL to IS_GAME_OVER
00F7: 36 01         ld   (hl),$01               
00F9: 2D            dec  l                   // point HL to IS_GAME_IN_PLAY
00FA: 36 00         ld   (hl),$00             
00FC: 2D            dec  l                   // point HL to SCRIPT_NUMBER
00FD: 36 01         ld   (hl),$01 

00FF: AF            xor  a
0100: 32 0A 40      ld   ($400A),a           // reset SCRIPT_STAGE to 0

0103: 3A 11 40      ld   a,($4011)           // read PORT_STATE_6800
0106: 07            rlca                     // move dip sw1 & dip sw2 state...
0107: 07            rlca                     // ...into bits 0 & 1 of register a
0108: E6 03         and  $03
010A: 32 00 40      ld   ($4000),a           // and store into DIP_SWITCH_1_2_STATE

010D: 3A 12 40      ld   a,($4012)           // read PORT_STATE_7000 
0110: E6 04         and  $04                 // mask in state of dip switch 5
0112: 0F            rrca                     // move bit into...
0113: 0F            rrca                     // bit 0 of register a
0114: 32 1F 40      ld   ($401F),a           // and store it in DIP_SWITCH_5_STATE

0117: 11 1B 05      ld   de,$051B            // load DE with address of PACKED_DEFAULT_SWARM_DEFINITION
011A: CD 46 06      call $0646               // call UNPACK_ALIEN_SWARM

// set IS_COCKTAIL flag from !SW0    upright/cocktail
011D: 3A 10 40      ld   a,($4010)           // read PORT_STATE_6000
0120: E6 20         and  $20                 // read upright/cocktail bit                  
0122: 07            rlca                     // move bit from bit 5.. 
0123: 07            rlca
0124: 07            rlca                     // ..to bit 0.
0125: 32 0F 40      ld   ($400F),a           // and store to IS_COCKTAIL

// read DIP switches to calculate value of BONUS GALAXIP
0128: 3A 00 70      ld   a,($7000)           // read state of dip switch 3,4,5,6
012B: E6 03         and  $03                 // mask in state of dip switches 3 & 4
012D: 21 52 01      ld   hl,$0152
0130: E7            rst  $20                 // call routine to fetch value @ HL + A 
0131: 32 AC 40      ld   ($40AC),a           // write BONUS GALIXIP @ value  

// Set screen attribute colours then display "1UP" and "HIGH SCORE" 
0134: CD 95 05      call $0595               // call SET_COLOUR_ATTRIBUTES_TABLE_1
0137: 3E 01         ld   a,$01
0139: 32 40 53      ld   ($5340),a           // poke "1" to character RAM
013C: 3E 25         ld   a,$25
013E: 32 20 53      ld   ($5320),a           // poke "U" to character RAM
0141: 3E 20         ld   a,$20
0143: 32 00 53      ld   ($5300),a           // poke "P" to character RAM - text "1UP" now drawn
0146: 11 04 06      ld   de,$0604            // command: PRINT_TEXT, parameter: 4 (index of "HIGH SCORE")
0149: CD F2 08      call $08F2               // call QUEUE_COMMAND 
014C: 11 03 05      ld   de,$0503            : command: DISPLAY_SCORE_COMMAND , parameter: 3 (Displays player scores and high score)
014F: C3 F2 08      jp   $08F2               // jump to QUEUE COMMAND

// Values for BONUS GALIXIP. 7 = 7000, 10 = 10000, 12 =12000, 20 = 20000
0152: 07 10 12 20 


//
// Script ONE is responsible for managing the attract mode.
//
//
//

SCRIPT_ONE:
0156: CD 0D 09      call $090D               // call HANDLE_SWARM_MOVEMENT  
0159: CD 8E 09      call $098E               // call SET_ALIEN_PRESENCE_FLAGS
015C: 21 D7 03      ld   hl,$03D7            // return address 
015F: E5            push hl                  // push return address onto the stack
0160: 3A 0A 40      ld   a,($400A)           // read SCRIPT_STAGE       
0163: EF            rst  $28                 // jump to code @ $0164 + (A*2)

0164: 
      8C 01         // $018C (DISPLAY_GAME_OVER_AND_REMAINING_CREDIT_1)
      BE 01         // $01BE (SET_PUSH_START_BUTTON_COUNTER)
      C6 01         // $01C6 (HIDE_SWARM_AND_PREPARE_TO_CLEAR_SCREEN) 
      E1 01         // $01E1 (CLEAR_SCREEN_BEFORE_WE_ARE_THE_GALAXIANS_INTRO)
      18 02         // $0218 (DISPLAY_WE_ARE_THE_GALAXIANS_INTRO)
      3F 02         // $023F (SCROLL_ON_CONVOY_CHARGER_POINTS)
      67 02         // $0267 (DISPLAY_NAMCO_LOGO) 
      8E 02         // $028E (BLINK_CONVOY_CHARGER_POINTS)
      C6 01         // $01C6 (HIDE_SWARM_AND_PREPARE_TO_CLEAR_SCREEN) 
      9D 02         // $029D (CLEAR_WE_ARE_GALAXIANS_SCREEN_AND_DISPLAY_GAME_OVER)
      D1 02         // $02D1 (DISPLAY_GAME_OVER_AND_REMAINING_CREDIT_2)
      2E 03         // $032E (WAIT_FOR_TEMP_COUNTER_2_THEN_ADVANCE_TO_NEXT_STAGE) 
      E8 02         // $02E8 (CLEAR_ALIEN_SWARM_AND_SUSPEND_SWARM_ANIMATION)
      FD 02         // $02FD (CREATE_ATTRACT_MODE_ALIEN_SWARM)
      14 06         // $0614 (HANDLE_SPAWN_PLAYER)
      61 06         // $0661 (HANDLE_MAIN_GAME_LOGIC)
      D8 06         // $06D8 (HANDLE_PLAYER_ONE_KILLED)
      2E 03         // $032E (WAIT_FOR_TEMP_COUNTER_2_THEN_ADVANCE_TO_NEXT_STAGE)
      22 03         // $0322 (SET_SCRIPT_STAGE_TO_1)
      00 00         



//
// Enables starfield, displays GAME OVER and the amount of credit remaining.
//
//

DISPLAY_GAME_OVER_AND_REMAINING_CREDIT_1:      
018C: 11 01 07      ld   de,$0701            // command: BOTTOM_OF_SCREEN_INFO_COMMAND, parameter: 1 (invokes DISPLAY_AVAILABLE_CREDIT)
018F: CD F2 08      call $08F2               // call QUEUE_COMMAND
0192: 11 00 06      ld   de,$0600            // command: PRINT_TEXT, parameter: 0 (index of GAME OVER)
0195: CD F2 08      call $08F2               // call QUEUE_COMMAND
0198: 3E 01         ld   a,$01
019A: 32 07 40      ld   ($4007),a           // set IS_GAME_OVER flag
019D: 32 04 70      ld   ($7004),a           // enable stars
01A0: 32 02 70      ld   ($7002),a           // Does nothing      
01A3: 32 03 70      ld   ($7003),a           // Does nothing
01A6: 21 0A 40      ld   hl,$400A            // pointer to SCRIPT_STAGE
01A9: 34            inc  (hl)                // advance to next stage
01AA: AF            xor  a
01AB: 32 19 40      ld   ($4019),a           // clear PUSH_START_BUTTON_COUNTER
01AE: 32 0D 40      ld   ($400D),a           // set CURRENT_PLAYER to 0 (player one)
01B1: 32 0E 40      ld   ($400E),a           // clear IS_TWO_PLAYER_GAME
01B4: 32 06 40      ld   ($4006),a           // clear IS_GAME_IN_PLAY
01B7: 21 60 10      ld   hl,$1060
01BA: 22 08 40      ld   ($4008),hl          // set TEMP_COUNTER_1 and TEMP_COUNTER_2 
01BD: C9            ret


//
//
//

SET_PUSH_START_BUTTON_COUNTER:
01BE: 3E 01         ld   a,$01
01C0: 32 19 40      ld   ($4019),a           // set PUSH_START_BUTTON_COUNTER
01C3: C3 36 03      jp   $0336               // jump to WAIT_FOR_TEMP_COUNTERS


//
//
//

HIDE_SWARM_AND_PREPARE_TO_CLEAR_SCREEN:
01C6: 21 00 41      ld   hl,$4100            // load HL with address of ALIEN_SWARM_FLAGS
01C9: 06 80         ld   b,$80               // sizeof(ALIEN_SWARM_FLAGS) array
01CB: AF            xor  a                   
01CC: D7            rst  $10                 // Clear all alien swarm flags 
01CD: 32 5F 42      ld   ($425F),a           // set TIMING_VARIABLE
01D0: 32 24 42      ld   ($4224),a           // reset HAVE_AGGRESSIVE_ALIENS flag
01D3: 21 02 50      ld   hl,$5002            // address of column 2 in character RAM
01D6: 22 0B 40      ld   ($400B),hl          // write to TEMP_CHAR_RAM_PTR
01D9: 21 09 40      ld   hl,$4009            // load HL with address of TEMP_COUNTER_2
01DC: 36 20         ld   (hl),$20            // set counter 
01DE: 2C            inc  l                   // bump HL to $400A (SCRIPT_STAGE)
01DF: 34            inc  (hl)                // advance to next part of script.
01E0: C9            ret


//
// This piece of code clears all of the screen except the HUD (score, credits inserted etc)
//

CLEAR_SCREEN_BEFORE_WE_ARE_THE_GALAXIANS_INTRO:
01E1: 2A 0B 40      ld   hl,($400B)          // load HL with contents of TEMP_CHAR_RAM_PTR
01E4: 06 1C         ld   b,$1C               // We want to clear #$1C (28 characters) on this row 
01E6: 3E 10         ld   a,$10               // ordinal for empty character
01E8: D7            rst  $10                 // Clear 28 characters from row
01E9: 11 04 00      ld   de,$0004            // As a row is 32 characters wide, to get to start of next row...
01EC: 19            add  hl,de               // ... we need to add 4 characters.
01ED: 22 0B 40      ld   ($400B),hl          // write to TEMP_CHAR_RAM_PTR
01F0: 21 09 40      ld   hl,$4009            // load HL with address of TEMP_COUNTER_2  
01F3: 35            dec  (hl)                // decrement value of counter
01F4: C0            ret  nz                  // if value is not zero then exit 

01F5: 2C            inc  l                   // bump HL to $400A (SCRIPT_STAGE)
01F6: 34            inc  (hl)                // advance to next part of script.
01F7: 21 40 04      ld   hl,$0440
01FA: 22 08 40      ld   ($4008),hl          // set TEMP_COUNTER_1 and TEMP_COUNTER_2 in one go

01FD: AF            xor  a
01FE: 06 30         ld   b,$30
0200: 21 00 42      ld   hl,$4200
0203: D7            rst  $10                 // Clear from $4200-422F
0204: 32 06 70      ld   ($7006),a           // reset regen hflip
0207: 32 07 70      ld   ($7007),a           // reset regen vflip
020A: 32 18 40      ld   ($4018),a           // reset DISPLAY_IS_COCKTAIL_P2
020D: 3E 01         ld   a,$01
020F: 32 38 42      ld   ($4238),a           // set DISABLE_SWARM_ANIMATION flag. 
0212: 21 B1 1D      ld   hl,$1DB1            // pointer to COLOUR_ATTRIBUTE_TABLE_3
0215: C3 98 05      jp   $0598               // jump to SET_COLOUR_ATTRIBUTES


//
// Displays the following:
//
// WE ARE THE GALAXIANS
// MISSION: DESTROY ALIENS
// - SCORE ADVANCE TABLE -
// CONVOY CHARGER

DISPLAY_WE_ARE_THE_GALAXIANS_INTRO:
0218: CD 63 03      call $0363               // call HANDLE_ALIEN_SWARM_SCROLL_RESET
021B: 21 08 40      ld   hl,$4008            // load HL with address of TEMP_COUNTER_1
021E: 35            dec  (hl)
021F: C0            ret  nz
0220: 36 50         ld   (hl),$50            // reset counter
0222: 2C            inc  l                   // bump HL to TEMP_COUNTER_2
0223: 16 06         ld   d,$06               // Command: PRINT_TEXT

// HL now points to a number between 1 and 4. This identifies a text string we want to print: 
// 1: CONVOY CHARGER             
// 2: SCORE ADVANCE TABLE
// 3: MISSION: DESTROY ALIENS    
// 4: WE ARE THE GALAXIANS
0225: 7E            ld   a,(hl)              // read value from TEMP_COUNTER_2 
0226: 82            add  a,d                 // add 6 to it to give us an index for PRINT_TEXT
0227: 5F            ld   e,a                 // set parameter
0228: CD F2 08      call $08F2               // call QUEUE_COMMAND
022B: 35            dec  (hl)                // bump TEMP_COUNTER_2 to index of next string to print
022C: C0            ret  nz

022D: 2C            inc  l                   // bump HL to $400A (SCRIPT_STAGE)
022E: 34            inc  (hl)                // advance to next stage
022F: 21 20 04      ld   hl,$0420
0232: 22 08 40      ld   ($4008),hl          // set TEMP_COUNTER_1 and TEMP_COUNTER_2 in one go

// hide all sprites 
0235: 21 B0 42      ld   hl,$42B0            // address of INFLIGHT_ALIENS
0238: AF            xor  a
0239: 47            ld   b,a
023A: D7            rst  $10                 // Fill the entire INFLIGHT_ALIENS array with zero
023B: 32 41 42      ld   ($4241),a           // set ATTRACT_MODE_SCROLL_ID
023E: C9            ret



//
//
//
//

SCROLL_ON_CONVOY_CHARGER_POINTS:
023F: CD 63 03      call $0363               // call HANDLE_ALIEN_SWARM_SCROLL_RESET
0242: CD BE 0B      call $0BBE               // call HANDLE_INFLIGHT_ALIEN_SPRITE_UPDATE
0245: CD C3 0C      call $0CC3               // call HANDLE_INFLIGHT_ALIENS
0248: CD 67 03      call $0367               // call HANDLE_DRAW_CONVOY_CHARGER_POINTS
024B: 21 08 40      ld   hl,$4008            // load HL with address of TEMP_COUNTER_1
024E: 35            dec  (hl)
024F: C0            ret  nz
0250: 36 D2         ld   (hl),$D2

// get ready to scroll the next alien sprite and associated points values on screen
0252: 2C            inc  l                   // bump HL to point to TEMP_COUNTER_2
0253: CD 41 03      call $0341               // call INIT_CONVOY_CHARGER_SPRITE
0256: EB            ex   de,hl
0257: 21 41 42      ld   hl,$4241            // pointer to ATTRACT_MODE_SCROLL_ID
025A: 34            inc  (hl)                // set id to next thing to scroll on
025B: EB            ex   de,hl
025C: 35            dec  (hl)                // dec TEMP_COUNTER_2
025D: C0            ret  nz                  // return if not zero

025E: 36 D2         ld   (hl),$D2
0260: 2C            inc  l                   // point HL to SCRIPT_STAGE
0261: 34            inc  (hl)                // increment script stage 
0262: AF            xor  a
0263: 32 58 40      ld   ($4058),a           // write to scroll offset in OBJRAM_BACK_BUF
0266: C9            ret



DISPLAY_NAMCO_LOGO:
0267: CD 63 03      call $0363               // call HANDLE_ALIEN_SWARM_SCROLL_RESET
026A: CD BE 0B      call $0BBE               // call HANDLE_INFLIGHT_ALIEN_SPRITE_UPDATE
026D: CD C3 0C      call $0CC3               // call HANDLE_INFLIGHT_ALIENS 
0270: CD 67 03      call $0367               // call HANDLE_DRAW_CONVOY_CHARGER_POINTS

// wait until TEMP_COUNTER_2 reaches 0
0273: 21 09 40      ld   hl,$4009            // load HL with address of TEMP_COUNTER_2
0276: 35            dec  (hl)
0277: C0            ret  nz
0278: 2C            inc  l                   // bump HL to point to SCRIPT_STAGE
0279: 34            inc  (hl)                // advance to next stage
027A: AF            xor  a
027B: 32 58 40      ld   ($4058),a           // set scroll offset in OBJRAM_BACK_BUF
027E: 21 40 11      ld   hl,$1140
0281: 22 08 40      ld   ($4008),hl          // set TEMP_COUNTER_1 and TEMP_COUNTER_2 in one go
0284: 21 41 42      ld   hl,$4241            // pointer to ATTRACT_MODE_SCROLL_ID
0287: 34            inc  (hl)
0288: 11 0F 06      ld   de,$060F            // command: PRINT_TEXT, parameter: #$0F (Displays NAMCO logo)
028B: C3 F2 08      jp   $08F2               // jump to QUEUE COMMAND               


//
//
//
//
//

BLINK_CONVOY_CHARGER_POINTS:
028E: CD 63 03      call $0363               // call HANDLE_ALIEN_SWARM_SCROLL_RESET
0291: CD BE 0B      call $0BBE               // call HANDLE_INFLIGHT_ALIEN_SPRITE_UPDATE
0294: CD C3 0C      call $0CC3               // call HANDLE_INFLIGHT_ALIENS
0297: CD 67 03      call $0367               // call DISPLAY_CONVOY_CHARGER_POINTS
029A: C3 36 03      jp   $0336               // jump to WAIT_FOR_TEMP_COUNTERS



//
// Cleanup for the "WE ARE THE GALAXIANS" page.
//
// Clears the screen. Hides the sprites. Displays GAME OVER.
//

CLEAR_WE_ARE_GALAXIANS_SCREEN_AND_DISPLAY_GAME_OVER:
029D: CD 63 03      call $0363               // call HANDLE_ALIEN_SWARM_SCROLL_RESET
// clear everything except HUD
02A0: 2A 0B 40      ld   hl,($400B)          // read contents of TEMP_CHAR_RAM_PTR. Now HL = pointer to row to clear 
02A3: 06 1C         ld   b,$1C               // we want to clear $1C (28 decimal) characters
02A5: 3E 10         ld   a,$10               // ordinal of empty character
02A7: D7            rst  $10                 // Clear 28 characters on column   
02A8: 11 04 00      ld   de,$0004            // As the screen is 32 characters wide, we need to add 4 to get to...
02AB: 19            add  hl,de               // the start of the next column
02AC: 22 0B 40      ld   ($400B),hl          // Update TEMP_CHAR_RAM_PTR 

// wait until TEMP_COUNTER_2 reaches 0
02AF: 21 09 40      ld   hl,$4009            // load HL with address of TEMP_COUNTER_2
02B2: 35            dec  (hl)
02B3: C0            ret  nz
02B4: 2C            inc  l                   // bump HL to point to SCRIPT_STAGE
02B5: 34            inc  (hl)                // advance to next stage of script

// clear INFLIGHT_ALIENS array. 
02B6: 21 B0 42      ld   hl,$42B0            // load HL with address of INFLIGHT_ALIENS
02B9: AF            xor  a
02BA: 47            ld   b,a
02BB: D7            rst  $10                 // Fill B bytes of memory from HL with value in A.  

// hide all sprites & bullets
02BC: 21 60 40      ld   hl,$4060            // pointer to OBJRAM_BACK_BUF_SPRITES
02BF: 06 40         ld   b,$40               // 
02C1: D7            rst  $10                 // clear sprite and bullet information from back buffer  

// display GAME OVER
02C2: 21 40 04      ld   hl,$0440 
02C5: 22 08 40      ld   ($4008),hl          // set TEMP_COUNTER_1 and TEMP_COUNTER_2
02C8: CD 95 05      call $0595               // call SET_COLOUR_ATTRIBUTES_TABLE_1
02CB: 11 00 06      ld   de,$0600            // command: PRINT_TEXT, parameter: 0 (index of "GAME OVER")
02CE: C3 F2 08      jp   $08F2               // jump to QUEUE COMMAND               



//
// Displays GAME over and the amount of credit remaining.
//
// See also: DISPLAY_GAME_OVER_AND_REMAINING_CREDIT_1 @ $018C
//

DISPLAY_GAME_OVER_AND_REMAINING_CREDIT_2:
02D1: 11 01 07      ld   de,$0701            // command: BOTTOM_OF_SCREEN_INFO_COMMAND , calls DISPLAY_AVAILABLE_CREDIT
02D4: CD F2 08      call $08F2               // call QUEUE_COMMAND
02D7: 11 00 06      ld   de,$0600            // command: PRINT_TEXT, parameter: 0 (index of "GAME OVER")
02DA: CD F2 08      call $08F2               // call QUEUE_COMMAND
02DD: 21 0A 40      ld   hl,$400A            // load HL with address of SCRIPT_STAGE
02E0: 34            inc  (hl)                // advance to next stage of script
02E1: 21 60 10      ld   hl,$1060
02E4: 22 08 40      ld   ($4008),hl          // set TEMP_COUNTER_1 and TEMP_COUNTER_2 
02E7: C9            ret



//
// Clears the alien swarm from the screen.
//
//

CLEAR_ALIEN_SWARM_AND_SUSPEND_SWARM_ANIMATION:
02E8: 21 00 41      ld   hl,$4100            // load HL with address of ALIEN_SWARM_FLAGS
02EB: 06 80         ld   b,$80               // sizeof(ALIEN_SWARM_FLAGS)
02ED: AF            xor  a
02EE: D7            rst  $10                 // Reset all flags in ALIEN_SWARM_FLAGS array  
02EF: 32 5F 42      ld   ($425F),a           // clear TIMING_VARIABLE
02F2: 32 38 42      ld   ($4238),a           // clear DISABLE_SWARM_ANIMATION
02F5: 21 09 40      ld   hl,$4009            // load HL with address of TEMP_COUNTER_2
02F8: 36 40         ld   (hl),$40
02FA: C3 93 05      jp   $0593               // advance to next stage of script



//
//
//
//
//

CREATE_ATTRACT_MODE_ALIEN_SWARM:
02FD: 11 1B 05      ld   de,$051B            // load DE with address of PACKED_DEFAULT_SWARM_DEFINITION
0300: CD 46 06      call $0646               // call UNPACK_ALIEN_SWARM
0303: EB            ex   de,hl               // now HL = pointer to DEFAULT_PLAYER_STATE ($052B)
0304: 11 18 42      ld   de,$4218            // load DE with address of CURRENT_PLAYER_STATE 
0307: 01 08 00      ld   bc,$0008            // sizeof (CURRENT_PLAYER_STATE)
030A: ED B0         ldir                     // reset current player state to default
030C: AF            xor  a
030D: 32 5F 42      ld   ($425F),a           // reset TIMING_VARIABLE

// Give the demo player 1 life 
0310: 3C            inc  a
0311: 32 1D 42      ld   ($421D),a           // set PLAYER_LIVES
0314: 21 0A 40      ld   hl,$400A            // pointer to SCRIPT_STAGE
0317: 34            inc  (hl)                // advance to next stage of script            
0318: 2C            inc  l                   // bump HL to point to TEMP_CHAR_RAM_PTR
0319: 36 96         ld   (hl),$96
031B: 21 40 06      ld   hl,$0640
031E: 22 45 42      ld   ($4245),hl          // set FLAGSHIP_ATTACK_MASTER_COUNTER_1 and FLAGSHIP_ATTACK_MASTER_COUNTER_2
0321: C9            ret


//
//
//
//
//

SET_SCRIPT_STAGE_TO_1:
0322: 3E 01         ld   a,$01
0324: 32 0A 40      ld   ($400A),a           // set SCRIPT_STAGE to 1
0327: 21 03 03      ld   hl,$0303            
032A: 22 08 40      ld   ($4008),hl          // set TEMP_COUNTER_1 and TEMP_COUNTER_2
032D: C9            ret


//
// Decrements value in TEMP_COUNTER_2. When counter value hits zero, advance script to next stage.
// 

WAIT_FOR_TEMP_COUNTER_2_THEN_ADVANCE_TO_NEXT_STAGE:
032E: 21 09 40      ld   hl,$4009            // load HL with address of TEMP_COUNTER_2
0331: 35            dec  (hl)                // decrement value of counter
0332: C0            ret  nz                  // return if counter is !=0
0333: 2C            inc  l                   // bump HL to point to $401A (SCRIPT_STAGE)
0334: 34            inc  (hl)                // advance script to next stage
0335: C9            ret



//
// Decrements value in TEMP_COUNTER_1. When counter value hits zero, reset value of TEMP_COUNTER_1 to $3C (60 decimal)
// and then decrement value of TEMP_COUNTER_2. 
//
// When value of TEMP_COUNTER_2 hits zero, advance script to next stage.
//

WAIT_FOR_TEMP_COUNTERS:
0336: 21 08 40      ld   hl,$4008             // load HL with address of TEMP_COUNTER_1
0339: 35            dec  (hl)                 // decrement value of counter
033A: C0            ret  nz                   // return if counter is !=0
033B: 36 3C         ld   (hl),$3C             // reset counter to $3C (50 decimal)
033D: 2C            inc  l                    // bump HL to point to TEMP_COUNTER_2
033E: C3 31 03      jp   $0331                // and go check if that counter has counted down to 0 yet 


//
// This routine is responsible for positioning alien sprites off screen ready to be scrolled onto the CONVOY CHARGER points table.
// Once the positioning is done, the sprite is "handed over" to the routine @ $109B.
//
// Expects: HL points to TEMP_COUNTER_2
//
// The value in TEMP_COUNTER_2 specifies what type of alien we are scrolling on:
//
// 4: Flagship
// 3: Red alien
// 2: Purple alien
// 1: Blue alien
//

INIT_CONVOY_CHARGER_SPRITE:
0341: 7E            ld   a,(hl)              // read type of alien to scroll on          
0342: D9            exx                      // note: alternate register switch doesn't affect A
0343: 3D            dec  a                   // convert A into a 0-based index                   
0344: 47            ld   b,a                                   
0345: 0F            rrca                     // multiply A..
0346: 0F            rrca
0347: 0F            rrca                     // ..by 32 (which is sizeof(INFLIGHT_ALIEN))
0348: 5F            ld   e,a                 //
0349: 16 00         ld   d,$00               // Now DE = offset 
034B: 21 30 43      ld   hl,$4330            // HL = address of INFLIGHT_ALIENS[3]
034E: 19            add  hl,de               // Add offset to HL. HL now points to INFLIGHT_ALIEN record we're using to scroll sprite on with
034F: 36 01         ld   (hl),$01            // set INFLIGHT_ALIEN.IsActive to 1 
0351: 2C            inc  l                 
0352: 36 00         ld   (hl),$00            // reset INFLIGHT_ALIEN.IsDying 
0354: 2C            inc  l
0355: 36 0D         ld   (hl),$0D            // set INFLIGHT_ALIEN.StageOfLife to INFLIGHT_ALIEN_CONVOY_CHARGER_SET_COLOUR_POS_ANIM
0357: 2C            inc  l
0358: 2C            inc  l
0359: 36 00         ld   (hl),$00            // set INFLIGHT_ALIEN.Y to position offscreen
035B: 2C            inc  l
035C: 36 0C         ld   (hl),$0C            // set INFLIGHT_ALIEN.AnimationFrame
035E: 2C            inc  l
035F: 2C            inc  l
0360: 70            ld   (hl),b              // set INFLIGHT_ALIEN.IndexInSwarm 
0361: D9            exx
0362: C9            ret


//
// The alien swarm scrolling in the attract mode has changed scroll values for some columns, 
// and these scroll values need to be reset before we can print text like "WE ARE THE GALAXIANS" "MISSION: DESTROY ALIENS"
// in those columns. If we don't reset the scroll values, the text will probably be off-centre and not look good.
//

HANDLE_ALIEN_SWARM_SCROLL_RESET:
0363: AF            xor  a                   // reset scroll offset to 0
0364: C3 72 09      jp   $0972               // call SET_SWARM_SCROLL_OFFSET


//
// Handles the drawing and blinking of the CONVOY CHARGER points values in the demo.
//

DISPLAY_CONVOY_CHARGER_POINTS:
0367: 3A 41 42      ld   a,($4241)           // read ATTRACT_MODE_SCROLL_ID
036A: A7            and  a                   // test if zero
036B: C8            ret  z                   // if its zero, not time to scroll anything in yet, return
036C: 3D            dec  a                   
036D: C8            ret  z

036E: 47            ld   b,a
036F: 3A 5F 42      ld   a,($425F)           // read TIMING_VARIABLE
0372: 4F            ld   c,a                 // save it in C 
0373: E6 3F         and  $3F                 // mask in bits 0..5. Now A is a value from 0..63 decimal.
0375: 28 49         jr   z,$03C0             // if bits 0..5 are not set, call CLEAR_DEMO_CONVOY_CHARGER_POINTS

0377: FE 20         cp   $20                 // If A is not exactly $20..
0379: C0            ret  nz                  // .. exit

// When we get here, we need to compute what flagship scores we are going to draw. 
// We basically take the value in TIMING_VARIABLE, AND the value by 3 to give an index value in range of 0..3, then
// multiply the index by 3 to give an offset into the flagship score table @$039A.  
// The end result is cycling flagship values.
037A: 79            ld   a,c                 // A = TIMING_VARIABLE saved in C
037B: 07            rlca                     
037C: 07            rlca               
037D: E6 03         and  $03                 // now A is a value from 0..3. A is now an index into table @$039A 
037F: 4F            ld   c,a                 // multiply A...
0380: 87            add  a,a                 //   
0381: 81            add  a,c                 // .. by 3
0382: 5F            ld   e,a 
0383: 16 00         ld   d,$00               // extend A into DE. Now DE is an offset to add to HL

0385: 21 9A 03      ld   hl,$039A            // pointer to Flagship score table
0388: 19            add  hl,de
0389: 11 93 51      ld   de,$5193            // address in character RAM
038C: CD AF 03      call $03AF               // call DRAW_3_CHARACTERS
038F: 05            dec  b
0390: C8            ret  z

// The alien scores are static and don't cycle, so we just draw them straight from the table 
0391: 21 A6 03      ld   hl,$03A6            // pointer to Alien score table
0394: CD AF 03      call $03AF               // call DRAW_3_CHARACTERS
0397: 10 FB         djnz $0394
0399: C9            ret


// The tables @$039A and $03A6 represent the points values displayed beneath the SCORE ADVANCE TABLE.
// These values are NOT BCD! They are ordinals for characters to be POKEd directly to character RAM.

// This table is for the Flagship
039A: 
01 05 00            // 150 
02 00 00            // 200
03 00 00            // 300
08 00 00            // 800

// This table is for the normal aliens
// Note: 10 is a space (empty) character
03A6: 
01 00 00            // 100   
10 08 00            //  80   
10 06 00            //  60    


//
// Draw 3 characters in the same *column*.
// Because the Galaxian monitor is turned on its side, the characters look like they are on the same row.
// 
// Expects:
// HL to point to 3 bytes defining the characters to draw 
// DE to point to character RAM to draw to
//

DRAW_3_CHARACTERS:
03AF: 0E 03         ld   c,$03               // number of characters to draw       
03B1: 7E            ld   a,(hl)              // read character to draw  
03B2: 12            ld   (de),a              // write to character RAM
03B3: 23            inc  hl                  // bump to next character
03B4: 7B            ld   a,e                 // get LSB of character RAM address 
03B5: D6 20         sub  $20                 // subtract #$20 (32 decimal) from it. Now DE points to character in same column, row above 
03B7: 5F            ld   e,a                 // 
03B8: 0D            dec  c                   // decrement counter of characters to draw. 
03B9: C2 B1 03      jp   nz,$03B1            // if counter !=0, more characters are to be drawn, goto $03B1
03BC: C6 62         add  a,$62               
03BE: 5F            ld   e,a                 // Add #$62 (98 decimal) to DE. Now DE is back on row we started drawing from.
03BF: C9            ret


//
// In the demo mode, this erases all of the points values underneath the text "CHARGER"
//

CLEAR_DEMO_CONVOY_CHARGER_POINTS:
03C0: 21 93 51      ld   hl,$5193            // address in character RAM
03C3: 11 E0 FF      ld   de,$FFE0            // offset to add to character RAM address  (-32 decimal.)
03C6: 0E 03         ld   c,$03               // 3 characters to erase
03C8: 3E 10         ld   a,$10               // ordinal of empty character
03CA: 77            ld   (hl),a              // write empty character to screen       
03CB: 19            add  hl,de               // add offset. HL now points to character a row above, same column               
03CC: 0D            dec  c                   // decrement count of characters to erase
03CD: C2 CA 03      jp   nz,$03CA            // if not done goto $03CA
03D0: 7D            ld   a,l
03D1: C6 62         add  a,$62
03D3: 6F            ld   l,a
03D4: 10 F0         djnz $03C6
03D6: C9            ret


//
//
//
//
//

03D7: 3A 02 40      ld   a,($4002)           // read NUM_CREDITS
03DA: A7            and  a                   // check if zero
03DB: C8            ret  z                   // return if no credits

03DC: 21 05 40      ld   hl,$4005            // load HL with address of SCRIPT_NUMBER
03DF: 34            inc  (hl)                // advance to next script
03E0: 2C            inc  l              
03E1: 2C            inc  l                   // bump HL to point to IS_GAME_OVER
03E2: 36 00         ld   (hl),$00            // set IS_GAME_OVER to 0
03E4: AF            xor  a
03E5: 32 0A 40      ld   ($400A),a           // set SCRIPT_STAGE to 0
03E8: 32 C2 41      ld   ($41C2),a           // set ENABLE_ALIEN_ATTACK_SOUND to 0
03EB: 32 DF 41      ld   ($41DF),a           // set ALIEN_DEATH_SOUND to 0
03EE: 32 B0 40      ld   ($40B0),a           // clear IS_COLUMN_SCROLLING flag
03F1: C9            ret



//
// Credit has been inserted. Now wait for a start button to be pushed.
//
//
//

SCRIPT_TWO:
03F2: CD 0D 09      call $090D               // call HANDLE_SWARM_MOVEMENT
03F5: CD 8E 09      call $098E               // call SET_ALIEN_PRESENCE_FLAGS
03F8: 21 92 04      ld   hl,$0492            // address of HANDLE_START_BUTTONS
03FB: E5            push hl
03FC: 3A 0A 40      ld   a,($400A)           // read SCRIPT_STAGE
03FF: EF            rst  $28                 // jump to code @ $0400 + (A*2)

0400: 
    08 04           // $0408                  // INIT_0408
    30 04           // $0430                  // WAIT_BEFORE_DISPLAYING_PUSH_START_BUTTON
    43 04           // $0443                  // DISPLAY_PUSH_START_BUTTON_AND_BONUS_GALIXIP_FOR
    73 04           // $0473                  // BLINK_LAMPS_IF_CREDIT_INSERTED





INIT_0408:
0408: 21 91 1D      ld   hl,$1D91            // pointer to COLOUR_ATTRIBUTE_TABLE_2
040B: CD 98 05      call $0598               // call SET_COLOUR_ATTRIBUTES

// hide all sprites
040E: 21 60 40      ld   hl,$4060            // load HL with address of OBJRAM_BACK_BUF_SPRITES
0411: 06 40         ld   b,$40               
0413: AF            xor  a
0414: D7            rst  $10                 // Fill B bytes of memory from HL with value in A. 

// hide all bullets and inflight aliens
0415: 21 60 42      ld   hl,$4260            // load HL with address of ENEMY_BULLETS_START
0418: D7            rst  $10                 // Fill B bytes of memory from HL with value in A.  
0419: 06 50         ld   b,$50
041B: D7            rst  $10                 // Fill B bytes of memory from HL with value in A. 

041C: 32 38 42      ld   ($4238),a           // clear DISABLE_SWARM_ANIMATION     
041F: 32 B0 40      ld   ($40B0),a           // clear IS_COLUMN_SCROLLING  
0422: 21 02 50      ld   hl,$5002            // point to address in character RAM (3rd character of top row)
0425: 22 0B 40      ld   ($400B),hl          // set TEMP_CHAR_RAM_PTR
0428: 21 09 40      ld   hl,$4009            // load HL with address of TEMP_COUNTER_2
042B: 36 10         ld   (hl),$10            // set countdown to $10 (16 decimal)
042D: 2C            inc  l                   // bump HL to point to SCRIPT_STAGE
042E: 34            inc  (hl)                // advance to next stage of script
042F: C9            ret



WAIT_BEFORE_DISPLAYING_PUSH_START_BUTTON:
0430: 21 19 40      ld   hl,$4019            // pointer to PUSH_START_BUTTON_COUNTER
0433: 35            dec  (hl)                // decrement counter
0434: C2 73 04      jp   nz,$0473            // if non zero, goto BLINK_LAMPS_IF_CREDIT_INSERTED 

// counter's hit zero, go to next stage of script.
0437: 21 0A 40      ld   hl,$400A            // pointer to SCRIPT_STAGE
043A: 34            inc  (hl)                // advance to next stage of script
043B: 21 00 41      ld   hl,$4100            // load HL with address of ALIEN_SWARM_FLAGS
043E: 06 80         ld   b,$80               // sizeof(ALIEN_SWARM_FLAGS)
0440: AF            xor  a                  
0441: D7            rst  $10                 // Fill B bytes of memory from HL with value in A.  
0442: C9            ret




DISPLAY_PUSH_START_BUTTON_AND_BONUS_GALIXIP_FOR:
0443: 2A 0B 40      ld   hl,($400B)          // Get pointer to row to clear from TEMP_CHAR_RAM_PTR
0446: 06 1C         ld   b,$1C               // #$1C (28 decimal) characters to clear
0448: 3E 10         ld   a,$10               // Ordinal for empty space character
044A: D7            rst  $10                 // Fill B bytes of memory from HL with value in A. 
044B: 11 04 00      ld   de,$0004            // We've done 28 characters. Need 4 more to move to next row.
044E: 19            add  hl,de               // Adjust HL to point to start of next row
044F: 06 1C         ld   b,$1C               // #$1C (28 decimal) characters to clear
0451: D7            rst  $10                 // Fill B bytes of memory from HL with value in A.  
0452: 19            add  hl,de               // Adjust HL to point to start of next row
0453: 22 0B 40      ld   ($400B),hl          // And update TEMP_CHAR_RAM_PTR pointer 

// wait for TEMP_COUNTER_2 to reach 0
0456: 21 09 40      ld   hl,$4009            // load HL with address of TEMP_COUNTER_2
0459: 35            dec  (hl)
045A: C0            ret  nz

// then move to next stage of script
045B: 2C            inc  l                   // bump HL to point to SCRIPT_STAGE
045C: 34            inc  (hl)                // advance to next stage of script

// reset screen orientation to defaults                                                          
045D: AF            xor  a
045E: 32 06 70      ld   ($7006),a           // set regen hflip
0461: 32 07 70      ld   ($7007),a           // set regen vflip
0464: 32 18 40      ld   ($4018),a           // set DISPLAY_IS_COCKTAIL_P2

// display BONUS GALIXIP FOR and PUSH START BUTTON messages
0467: 11 02 07      ld   de,$0702            // command: BOTTOM_OF_SCREEN_INFO_COMMAND , parameter: 2 (invokes DISPLAY_BONUS_GALAXIP_FOR)
046A: CD F2 08      call $08F2               // call QUEUE_COMMAND
046D: 11 01 06      ld   de,$0601            // command: PRINT_TEXT, parameter: 1 (index of "PUSH START BUTTON")
0470: CD F2 08      call $08F2               // call QUEUE_COMMAND




//
// 
// Make the lamps on the arcade cabinet blink if credit(s) available. 
//
//

BLINK_LAMPS_IF_CREDITS:
0473: 3A 5F 42      ld   a,($425F)           // read TIMING_VARIABLE
0476: E6 20         and  $20                 // mask in bit 5
0478: 28 11         jr   z,$048B             // if bit 5 is not set, turn off the lamps

// Does player have credit? If not, then don't turn the lamps on.
047A: 3A 02 40      ld   a,($4002)           // read NUM_CREDITS
047D: A7            and  a                   // test if credits is 0
047E: C8            ret  z                   // return if no credits 

// turn the lamps on to show you have credit
047F: 47            ld   b,a
0480: 3E 01         ld   a,$01
0482: 32 00 60      ld   ($6000),a           // turn on lamp 1         
0485: 05            dec  b
0486: C8            ret  z
0487: 32 01 60      ld   ($6001),a           // turn on lamp 2
048A: C9            ret

// turn lamps off
048B: 32 00 60      ld   ($6000),a           // turn on/off lamp 1
048E: 32 01 60      ld   ($6001),a           // turn on/off lamp 2
0491: C9            ret




//
//
// Handle 1P or 2P being pressed.
//
// Notes:
// 1P = deducts 1 credit.
// 2P = deducts 2 credits
//

HANDLE_START_BUTTONS:
0492: 3A 11 40      ld   a,($4011)           // read PORT_STATE_6800
0495: CB 47         bit  0,a                 // test for 1P START button being hit
0497: 20 59         jr   nz,$04F2            // if button is hit, goto 1P_START_BUTTON_HANDLER
0499: CB 4F         bit  1,a                 // test for 2P START button being hit
049B: C8            ret  z

// The following piece of code executes when 2P START button is pushed
2P_START_BUTTON_HANDLER:
049C: 3A 02 40      ld   a,($4002)           // read NUM_CREDITS
049F: FE 02         cp   $02                 // do we have at least 2 credits for a 2 player game?
04A1: D8            ret  c                   // if credits < 2, then we don't have enough credit, return
04A2: D6 02         sub  $02                 // otherwise, reduce credits by 2
04A4: 32 02 40      ld   ($4002),a           // and update NUM_CREDITS with remainder

// initialise player 2's state (lives etc) to defaults
04A7: 21 1B 05      ld   hl,$051B            // load HL with address of DEFAULT_PLAYER_STATE
04AA: 11 A0 41      ld   de,$41A0            // load DE with address of PLAYER_TWO_STATE
04AD: 01 20 00      ld   bc,$0020            // sizeof (PLAYER_TWO_STATE)
04B0: ED B0         ldir

// if dip switch 5 is on, then player 2 gets 3 lives
04B2: 3A 1F 40      ld   a,($401F)           // read DIP_SWITCH_5_STATE
04B5: 0F            rrca                     // move bit 0 into carry
04B6: DC 0F 05      call c,$050F             // if carry is set, call AWARD_PLAYER_TWO_THREE_LIVES
04B9: 21 00 01      ld   hl,$0100            // CURRENT_PLAYER will be set to 0, IS_TWO_PLAYER_GAME set to 1
04BC: 22 0D 40      ld   ($400D),hl          // set CURRENT_PLAYER, and IS_TWO_PLAYER_GAME 

// Create alien swarm and load default settings for player 1 
04BF: 21 1B 05      ld   hl,$051B            // load HL with address of PACKED_DEFAULT_SWARM_DEFINITION
04C2: 11 80 41      ld   de,$4180            // load DE with address of PLAYER_ONE_PACKED_SWARM_DEF
04C5: 01 20 00      ld   bc,$0020            // sizeof (PLAYER_ONE_PACKED_SWARM_DEF)+sizeof(PLAYER_ONE_STATE)
04C8: ED B0         ldir

// if dip switch 5 is on, then player 1 gets 3 lives
04CA: 3A 1F 40      ld   a,($401F)           // read DIP_SWITCH_5_STATE
04CD: 0F            rrca                     // move bit 0 into carry
04CE: DC 15 05      call c,$0515             // if carry is set, call AWARD_PLAYER_ONE_THREE_LIVES

04D1: AF            xor  a
04D2: 32 0A 40      ld   ($400A),a           // set SCRIPT_STAGE to 0
04D5: 3E 03         ld   a,$03
04D7: 32 05 40      ld   ($4005),a           // set SCRIPT_NUMBER to 3
04DA: 3E 01         ld   a,$01
04DC: 32 06 40      ld   ($4006),a           // set IS_GAME_IN_PLAY
04DF: 32 D1 41      ld   ($41D1),a

// Display high score, reset P1 and P2's score to 0
04E2: 11 04 06      ld   de,$0604            // command: PRINT_TEXT, parameter: 4 (index of "HIGH SCORE")
04E5: CD F2 08      call $08F2               // call QUEUE_COMMAND
04E8: 11 00 04      ld   de,$0400            // command: RESET_SCORE_COMMAND, parameter: 0 (reset player 1's score and clear life awarded)
04EB: CD F2 08      call $08F2               // call QUEUE_COMMAND
04EE: 1C            inc  e                   // command: RESET_SCORE_COMMAND, parameter: 1 (reset player 2's score and clear life awarded)
04EF: C3 F2 08      jp   $08F2               // jump to QUEUE COMMAND


//
// Called when 1P START is pressed
//

1P_START_BUTTON_HANDLER:
04F2: 3A 02 40      ld   a,($4002)           // read number of credits
04F5: A7            and  a                   // test if number of credits is zero
04F6: 28 11         jr   z,$0509             // if number of credits is zero, goto $0509
04F8: 3D            dec  a                   // otherwise reduce number of credits by 1
04F9: 32 02 40      ld   ($4002),a           // and store back in credit counter
04FC: 21 A0 41      ld   hl,$41A0            // load HL with address of PLAYER_TWO_PACKED_SWARM_DEF
04FF: 06 20         ld   b,$20               // sizeof(PLAYER_TWO_PACKED_SWARM_DEF) + sizeof(PLAYER_TWO_STATE)
0501: AF            xor  a                   // 
0502: D7            rst  $10                 // clear player 2 swarm & state as we're not using them
0503: 21 00 00      ld   hl,$0000            // CURRENT_PLAYER will be set to 0, IS_TWO_PLAYER_GAME set to 0
0506: C3 BC 04      jp   $04BC               // go set CURRENT_PLAYER, and IS_TWO_PLAYER_GAME.

0509: 3E 01         ld   a,$01
050B: 32 05 40      ld   ($4005),a           // set SCRIPT_NUMBER to 1
050E: C9            ret



// Only called if Dip Switch 5 is set to ON
AWARD_PLAYER_TWO_THREE_LIVES:
050F: 3E 03         ld   a,$03
0511: 32 B5 41      ld   ($41B5),a           // Set number of lives for player 2
0514: C9            ret


// Only called if Dip Switch 5 is set to ON
AWARD_PLAYER_ONE_THREE_LIVES:
0515: 3E 03         ld   a,$03
0517: 32 95 41      ld   ($4195),a           // Set number of lives for player 1
051A: C9            ret



DEFAULT_SWARM_DEFINITION_AND_PLAYER_STATE    // EQU $051B:
    PACKED_DEFAULT_SWARM_DEFINITION:
    // The first 16 bytes defining the default alien swarm. 
    // For information on how the bytes are unpacked, please see docs @ $0646
    051B: 00 00 00 00 F8 1F F8 1F F8 1F F0 0F E0 07 40 02            

    // When starting a new game, these are the default values 
    DEFAULT_PLAYER_STATE:
    052B: 3C                                 // Default value for DIFFICULTY_COUNTER_1 
    052C: 14                                 // Default value for DIFFICULTY_COUNTER_2
    00 02 00 02 00 0F 00 00 00            


//
// This script is responsible for managing PLAYER 1's game. 
//
//
//

SCRIPT_THREE:
0536: CD 0D 09      call $090D               // call HANDLE_SWARM_MOVEMENT
0539: CD 8E 09      call $098E               // call SET_ALIEN_PRESENCE_FLAGS
053C: 3A 0A 40      ld   a,($400A)
053F: EF            rst  $28                 // jump to code @ $0540 + (A*2)
0540: 
      50 05         // $0550   
      83 05         // $0583 (CLEAR_ROW_OF_SCREEN)
      A5 05         // $05A5 (PLAYER_ONE_INIT)
      05 06         // $0605 (CLEAR_PLAYER_TEXT)
      14 06         // $0614 (HANDLE_SPAWN_PLAYER)
      61 06         // $0661 (HANDLE_MAIN_GAME_LOGIC)                  
      D8 06         // $06D8 (HANDLE_PLAYER_ONE_KILLED)
      3D 07         // $073D (SWITCH_TO_PLAYER_TWO)


//
0550: 21 00 41      ld   hl,$4100            // load HL with address of ALIEN_SWARM_FLAGS
0553: 06 80         ld   b,$80               // sizeof (ALIEN_SWARM_FLAGS)
0555: AF            xor  a
0556: 32 00 60      ld   ($6000),a           // clear !DRIVER lamp 1
0559: 32 01 60      ld   ($6001),a           // clear !DRIVER lamp 2
055C: D7            rst  $10                 // Clear the alien swarm 

055D: 32 5F 42      ld   ($425F),a           // set TIMING_VARIABLE

0560: 21 00 42      ld   hl,$4200            // pointer to HAS_PLAYER_SPAWNED. Also start of player state
0563: 06 17         ld   b,$17               // $17 (23 decimal) bytes to clear 
0565: D7            rst  $10                 // Clear all player state    
0566: 2C            inc  l
0567: 06 18         ld   b,$18
0569: D7            rst  $10                 // Fill B bytes of memory from HL with value in A.
056A: 21 60 42      ld   hl,$4260            // load HL with address of ENEMY_BULLETS_START
056D: 06 46         ld   b,$46
056F: D7            rst  $10                 // Fill B bytes of memory from HL with value in A.
0570: 3E 01         ld   a,$01
0572: 32 26 42      ld   ($4226),a           // set HAVE_NO_INFLIGHT_ALIENS flag

0575: 21 0A 40      ld   hl,$400A            // load HL with address of SCRIPT_STAGE
0578: 34            inc  (hl)                // advance to next stage of script
0579: 2D            dec  l                   // now HL points to TEMP_COUNTER_2
057A: 36 20         ld   (hl),$20            // load counter with $20 (32 decimal)
057C: 21 00 50      ld   hl,$5000            // pointer to start of character RAM
057F: 22 0B 40      ld   ($400B),hl          // store in TEMP_CHAR_RAM_PTR
0582: C9            ret



CLEAR_ROW_OF_SCREEN:
0583: 2A 0B 40      ld   hl,($400B)          // read TEMP_CHAR_RAM_PTR
0586: 06 20         ld   b,$20               // $20 (32 decimal) characters in a row
0588: 3E 10         ld   a,$10               // ordinal of empty character
058A: D7            rst  $10                 // Clear row of characters
058B: 22 0B 40      ld   ($400B),hl          // update TEMP_CHAR_RAM_PTR
058E: 21 09 40      ld   hl,$4009            // load HL with address of TEMP_COUNTER_2
0591: 35            dec  (hl)                // decrement counter
0592: C0            ret  nz                  // return if not zero
0593: 2C            inc  l                   // bump HL to point to $400A (SCRIPT_STAGE)
0594: 34            inc  (hl)                // advance to next stage of script

SET_COLOUR_ATTRIBUTES_TABLE_1:
0595: 21 71 1D      ld   hl,$1D71            // pointer to COLOUR_ATTRIBUTE_TABLE_1

SET_COLOUR_ATTRIBUTES:
0598: 11 21 40      ld   de,$4021            // address of first attribute in OBJRAM_BACK_BUF 
059B: 06 20         ld   b,$20               // we're setting attributes for all 32 columns in the row
059D: 7E            ld   a,(hl)              // read attribute value from ROM 
059E: 12            ld   (de),a              // write to attribute value in OBJRAM_BACK_BUF
059F: 23            inc  hl                  // bump HL to next value in ROM
05A0: 1C            inc  e                   // Add 2 to DE..
05A1: 1C            inc  e                   // .. so that it points to the next attribute value
05A2: 10 F9         djnz $059D               // and do until b==0
05A4: C9            ret


//
// Player one's turn is about to commence. 
//

PLAYER_ONE_INIT:
// restore alien swarm to what it was last turn 
05A5: 11 80 41      ld   de,$4180            // load DE with address of PLAYER_ONE_PACKED_SWARM_DEF
05A8: CD 46 06      call $0646               // call UNPACK_ALIEN_SWARM
// copy player 1's state (ie: game settings) to current player state
05AB: EB            ex   de,hl               // now HL = pointer to PLAYER_ONE_STATE
05AC: 11 18 42      ld   de,$4218            // load DE with address of CURRENT_PLAYER_STATE
05AF: 01 08 00      ld   bc,$0008            // sizeof(CURRENT_PLAYER_STATE)
05B2: ED B0         ldir                     // write P1 player state 
// reset any game settings 
05B4: AF            xor  a
05B5: 32 5F 42      ld   ($425F),a           // set TIMING_VARIABLE
05B8: 32 20 42      ld   ($4220),a           // clear HAVE_NO_ALIENS_IN_SWARM flag
05BB: 32 06 70      ld   ($7006),a           // reset regen hflip
05BE: 32 07 70      ld   ($7007),a           // reset regen vflip
05C1: 32 18 40      ld   ($4018),a           // reset DISPLAY_IS_COCKTAIL_P2
05C4: 21 0A 40      ld   hl,$400A            // load HL with address of SCRIPT_STAGE
05C7: 34            inc  (hl)                // advance to next stage in script
05C8: 2D            dec  l                   // bump HL to address of TEMP_COUNTER_2
05C9: 36 96         ld   (hl),$96            // set counter value
05CB: 21 40 06      ld   hl,$0640
05CE: 22 45 42      ld   ($4245),hl          // set FLAGSHIP_ATTACK_MASTER_COUNTER_1 and FLAGSHIP_ATTACK_MASTER_COUNTER_2
// if its not demo mode, display the scores
05D1: 3A 06 40      ld   a,($4006)           // read IS_GAME_IN_PLAY
05D4: 0F            rrca                     // move flag into carry
05D5: D0            ret  nc                  // return if game is not in play
05D6: 3A 0E 40      ld   a,($400E)           // read IS_TWO_PLAYER_GAME
05D9: 0F            rrca                     // move bit 0 into carry
05DA: 38 20         jr   c,$05FC             // if carry is set, we're in a 2 player game, goto $05FC
// the next 2 lines are only executed if its a one player game
05DC: 11 00 05      ld   de,$0500            // command: DISPLAY_SCORE_COMMAND, parameter: 0  (Displays Player 1's score)
05DF: CD F2 08      call $08F2               // call QUEUE_COMMAND
// the remaining lines are executed regardless of number of players 
05E2: 1E 02         ld   e,$02               // command: DISPLAY_SCORE_COMMAND, parameter: 2  (invokes DISPLAY_HIGH_SCORE)
05E4: CD F2 08      call $08F2               // call QUEUE_COMMAND
05E7: 14            inc  d                   // command: PRINT_TEXT, parameter: 2 (index of "PLAYER ONE") 
05E8: CD F2 08      call $08F2               // call QUEUE_COMMAND
05EB: 1E 04         ld   e,$04               // command: PRINT_TEXT, parameter: 4 (index of "HIGH SCORE")
05ED: CD F2 08      call $08F2               // call QUEUE_COMMAND
05F0: 11 03 07      ld   de,$0703            // command: BOTTOM_OF_SCREEN_INFO_COMMAND, calls DISPLAY_PLAYER_SHIPS_REMAINING
05F3: CD F2 08      call $08F2               // call QUEUE_COMMAND
05F6: 11 00 07      ld   de,$0700            // command: BOTTOM_OF_SCREEN_INFO_COMMAND, calls DISPLAY_LEVEL_FLAGS
05F9: C3 F2 08      jp   $08F2               // jump to QUEUE COMMAND

// Called when we're in a two player game. Displays player one's score, player two's score and high score.
05FC: 11 03 05      ld   de,$0503            // command: DISPLAY_SCORE_COMMAND, parameter: 3 (invokes DISPLAY_ALL_SCORES)
05FF: CD F2 08      call $08F2               // call QUEUE_COMMAND
0602: C3 E2 05      jp   $05E2               // go display high score, ships remaining




//
//
// Remove the text "PLAYER ONE" / "PLAYER TWO" from the screen.
//
//

CLEAR_PLAYER_TEXT:
0605: 21 09 40      ld   hl,$4009            // load HL with address of TEMP_COUNTER_2
0608: 35            dec  (hl)
0609: C0            ret  nz
060A: 36 14         ld   (hl),$14
060C: 2C            inc  l                   // bump HL to point to $400A (SCRIPT_STAGE)
060D: 34            inc  (hl)                // advance to next stage of script
// the text "PLAYER ONE" and "PLAYER TWO" are plotted to the same character cells  
060E: 11 82 06      ld   de,$0682            // command: PRINT_TEXT, parameter: #$82 - clear "PLAYER ONE" from screen 
0611: C3 F2 08      jp   $08F2               // jump to QUEUE COMMAND




HANDLE_SPAWN_PLAYER:
// Wait until its time to spawn the player
0614: 21 09 40      ld   hl,$4009            // load HL with address of TEMP_COUNTER_2
0617: 35            dec  (hl)               
0618: C0            ret  nz
0619: 36 0A         ld   (hl),$0A            // reset TEMP_COUNTER_2
061B: 2C            inc  l                   // bump HL to point to $400A (SCRIPT_STAGE)
061C: 34            inc  (hl)                // advance to next stage of script

// Spawn the player
061D: 21 01 00      ld   hl,$0001
0620: 22 00 42      ld   ($4200),hl          // set HAS_PLAYER_SPAWNED to 1, IS_PLAYER_DYING to 0
0623: 3E 80         ld   a,$80
0625: 32 02 42      ld   ($4202),a           // set PLAYER_Y        
 
0628: 21 E3 15      ld   hl,$15E3            // load HL with address of ALIEN_ATTACK_COUNTER_DEFAULT_VALUES
062B: 11 4A 42      ld   de,$424A            // load DE with address of ALIEN_ATTACK_COUNTERS
062E: 01 10 00      ld   bc,$0010            // sizeof(ALIEN_ATTACK_COUNTERS) array
0631: ED B0         ldir                     // reset all counters to their default values

0633: AF            xor  a
0634: 32 58 40      ld   ($4058),a           // reset scroll offset in OBJRAM_BACK_BUF
0637: 32 5A 40      ld   ($405A),a           // reset scroll offset in OBJRAM_BACK_BUF

// Draw lives left
063A: 11 03 07      ld   de,$0703            // command: BOTTOM_OF_SCREEN_INFO_COMMAND, calls DISPLAY_PLAYER_SHIPS_REMAINING
063D: CD F2 08      call $08F2               // call QUEUE_COMMAND
0640: 11 00 02      ld   de,$0200            // command: DISPLAY_PLAYER_COMMAND, parameter: 0 (invokes DRAW_PLAYER_SHIP)
0643: C3 F2 08      jp   $08F2               // jump to QUEUE COMMAND


// This code unpacks a packed swarm definition to the ALIEN_SWARM_FLAGS array.
//
// Expects:
// DE = pointer to 16 packed bytes that define the swarm.    
//
// Returns:
// HL = $4180  (pointer to PLAYER_ONE_STATE)
//


// Let's take a look at the default swarm definition located @$051B. This is the "template" that is used to define the swarm when you
// start the game or reach the next level.
// 
// The swarm definition is as follows:
// 00 00 00 00 F8 1F F8 1F F8 1F F0 0F E0 07 40 02  
//
// Not much there, is there? In order to understand how these bytes define the swarm, pair bytes like so:
// 00 00 
// 00 00 
// 00 00 
// 00 00 
// F8 1F 
// F8 1F 
// F8 1F 
// F0 0F 
// E0 07 
// 40 02  
//
// Next take each pair and *swap* the bytes. So "F8 1F" becomes "1F F8", "F0 0F" becomes "0F F0" and so on.
// Treat the byte pairs as 16 bit WORDs, convert into their binary equivalents and you get: 
// 0000 ->   0000000000000000
// 0000 ->   0000000000000000
// 0000 ->   0000000000000000
// 0000 ->   0000000000000000
// 1FF8 ->   0001111111111000 
// 1FF8 ->   0001111111111000 
// 1FF8 ->   0001111111111000 
// 0FF0 ->   0000111111110000 
// 07E0 ->   0000011111100000 
// 0240 ->   0000001001000000 
//
// Notice the pattern? That's the outline of the alien swarm upside down. See the 2 flagships?
//
//
// for (byte b=0// b<16// b++)
// {
//     for (byte i=0// i<8// i++)
//     {
//        Test bit i of byte read from (de)
//
//        If bit set, write 1 to (hl) - this creates an alien in the swarm
//        else write 0 to (hl)
//
//        increment hl
//     }
//     increment de
// }

UNPACK_ALIEN_SWARM:
0646: 21 00 41      ld   hl,$4100            // load HL with address of ALIEN_SWARM_FLAGS
0649: 06 10         ld   b,$10               // There's 16 bytes to be unpacked to 128 flags
064B: 0E 01         ld   c,$01

064D: 1A            ld   a,(de)              // read from (de) 
064E: A1            and  c                   // test if bit is set
064F: 28 0B         jr   z,$065C             // if bit is not set, goto $065C 
0651: 36 01         ld   (hl),$01            // bit is set, write 1 to (hl) - create an alien 
0653: 23            inc  hl                  // bump hl to next byte
0654: CB 01         rlc  c                   // rotate c left one bit
0656: 30 F5         jr   nc,$064D            // if bit 7 of C wasn't set, goto $064D
0658: 13            inc  de                  // move to next byte
0659: 10 F2         djnz $064D               // do until b ==0
065B: C9            ret
065C: 36 00         ld   (hl),$00            // write 0 to (hl) 
065E: C3 53 06      jp   $0653               // 


HANDLE_MAIN_GAME_LOGIC:
0661: CD 37 08      call $0837               // call HANDLE_PLAYER_MOVE
0664: CD 98 08      call $0898               // call HANDLE_PLAYER_BULLET
0667: CD 74 0A      call $0A74               // call HANDLE_ENEMY_BULLETS
066A: CD C3 0C      call $0CC3               // call HANDLE_INFLIGHT_ALIENS
066D: CD BE 0B      call $0BBE               // call HANDLE_INFLIGHT_ALIEN_SPRITE_UPDATE
0670: CD 32 0A      call $0A32               // call HANDLE_PLAYER_SHOOT
0673: CD 0B 0B      call $0B0B               // call HANDLE_SWARM_ALIEN_TO_PLAYER_BULLET_COLLISION_DETECTION
0676: CD 77 0B      call $0B77               // call HANDLE_PLAYER_TO_ENEMY_BULLET_COLLISION_DETECTION
0679: CD 27 12      call $1227               // call HANDLE_INFLIGHT_ALIEN_TO_PLAYER_BULLET_COLLISION_DETECTION
067C: CD 9E 12      call $129E               // call HANDLE_PLAYER_TO_INFLIGHT_ALIEN_COLLISION_DETECTION
067F: CD E5 08      call $08E5               // call HANDLE_PLAYER_BULLET_EXPIRED
0682: CD 0C 14      call $140C               // call HANDLE_FLAGSHIP_ATTACK
0685: CD 44 13      call $1344               // call HANDLE_SINGLE_ALIEN_ATTACK
0688: CD E1 13      call $13E1               // call SET_ALIEN_ATTACK_FLANK
068B: CD F3 14      call $14F3               // call HANDLE_LEVEL_DIFFICULTY
068E: CD ED 12      call $12ED               // call HANDLE_PLAYER_HIT
0691: CD 27 13      call $1327               // call HANDLE_PLAYER_DYING
0694: CD A6 16      call $16A6               // Doesn't actually do anything
0697: CD 15 15      call $1515               // call CHECK_IF_ALIEN_CAN_ATTACK
069A: CD 55 15      call $1555               // call UPDATE_ATTACK_COUNTERS
069D: CD C3 15      call $15C3               // call CHECK_IF_FLAGSHIP_CAN_ATTACK
06A0: CD F4 15      call $15F4               // call HANDLE_CALC_INFLIGHT_ALIEN_SHOOTING_DISTANCE
06A3: CD 21 16      call $1621               // call CHECK_IF_LEVEL_IS_COMPLETE
06A6: CD 37 16      call $1637               // call HANDLE_LEVEL_COMPLETE
06A9: CD B8 16      call $16B8               // call HANDLE_ALIEN_AGGRESSIVENESS
06AC: CD 88 16      call $1688               // call HANDLE_SHOCKED_SWARM
06AF: CD 8E 19      call $198E               // call HANDLE_SIMULATE_PLAYER_IN_ATTRACT_MODE

// OK, this part of the main game loop determines under what circumstances we can end the level.
// First we check the status of the player and the player bullet. Are they visible?
06B2: 3A 08 42      ld   a,($4208)           // read HAS_PLAYER_BULLET_BEEN_FIRED flag
06B5: 2A 00 42      ld   hl,($4200)          // read both HAS_PLAYER_SPAWNED and IS_PLAYER_DYING flags in one go              
06B8: B4            or   h                   // combine all three flags..
06B9: B5            or   l                   // into 1. If any of the three is set, A will be 1
06BA: 0F            rrca                     // Test if A was set to 1.
06BB: D8            ret  c                   // Return if player bullet has been fired, or player has spawned or is dying 

// Wait until all aliens are dead.
06BC: 3A 25 42      ld   a,($4225)           // read HAVE_NO_INFLIGHT_OR_DYING_ALIENS
06BF: 0F            rrca                     // move flag value into carry. 
06C0: D0            ret  nc                  // if carry flag is not set, then that means there are still aliens attacking or going through a death animation

// wait until all enemy bullets are off screen.
06C1: 21 60 42      ld   hl,$4260            // load HL with address of ENEMY_BULLETS_START
06C4: 11 05 00      ld   de,$0005            // sizeof (ENEMY_BULLET)
06C7: 06 0E         ld   b,$0E               // #$0E (14 decimal) bullets max to process
06C9: AF            xor  a                   // clear A
06CA: B6            or   (hl)                // read ENEMY_BULLET.IsActive flag. set A to 1 if bullet is active. 
06CB: 19            add  hl,de
06CC: 10 FC         djnz $06CA               // repeat until B==0
06CE: 0F            rrca                     // are there any bullets still active on screen? If so, carry will be set
06CF: D8            ret  c                   // yes, bullets still active, return

// OK, when we get here, the level is complete. We can go to the next level. 
06D0: 21 09 40      ld   hl,$4009            // load HL with address of TEMP_COUNTER_2
06D3: 35            dec  (hl)
06D4: C0            ret  nz
06D5: 2C            inc  l                   // bump HL to point to address of SCRIPT_STAGE
06D6: 34            inc  (hl)                // advance to next stage of script
06D7: C9            ret



//
// Player 1 has just been killed.
// 
// See also: $07E8
                               
HANDLE_PLAYER_ONE_KILLED:
06D8: 21 0A 40      ld   hl,$400A            // load HL with pointer to SCRIPT_STAGE

06DB: 3A 1D 42      ld   a,($421D)           // read PLAYER_LIVES 
06DE: A7            and  a                   // test if zero
06DF: 20 20         jr   nz,$0701            // if player 1 has lives remaining, goto $0701

// OK, player 1 has no lives. What about player 2?
06E1: 3A B5 41      ld   a,($41B5)           // read PLAYER_TWO_LIVES
06E4: A7            and  a                   // test if zero
06E5: 28 3B         jr   z,$0722             // if player 2 has no lives, goto GAME_OVER

// player 1 has no lives. If its not a 2 player game, then its GAME OVER.
06E7: 3A 0E 40      ld   a,($400E)           // read IS_TWO_PLAYER_GAME
06EA: A7            and  a                   // test if zero
06EB: 28 35         jr   z,$0722             // if zero, it's not a 2 player game, goto GAME_OVER

// OK, its a 2 player game and player 2 has some lives. 
06ED: 34            inc  (hl)                // bump to next stage of the script
06EE: 2D            dec  l                   // now HL points to $4009 (TEMP_COUNTER_2)
06EF: 36 82         ld   (hl),$82            // set counter 
                                                       
06F1: 3A 06 40      ld   a,($4006)           // read IS_GAME_IN_PLAY
06F4: 0F            rrca                     // move flag into carry
06F5: D0            ret  nc                  // return if game is not in play

// Display PLAYER ONE GAME OVER
06F6: 11 02 06      ld   de,$0602            // command: PRINT_TEXT, parameter: 2 (index of "PLAYER ONE")
06F9: CD F2 08      call $08F2               // call QUEUE_COMMAND
06FC: 1E 00         ld   e,$00               // index of "GAME OVER"
06FE: C3 F2 08      jp   $08F2               // jump to QUEUE COMMAND

// Player one's been killed. Is it player two's turn now? 
0701: 3A B5 41      ld   a,($41B5)           // read PLAYER_TWO_LIVES
0704: A7            and  a                   // test if zero
0705: 28 0B         jr   z,$0712             // 
0707: 3A 0E 40      ld   a,($400E)           // read IS_TWO_PLAYER_GAME
070A: A7            and  a                   // test if flag is set
070B: 28 05         jr   z,$0712             // if its not a two player game goto $0712
070D: 34            inc  (hl)                // bump to next stage of the script
070E: 2D            dec  l                   // now HL points to $4009 (TEMP_COUNTER_2)
070F: 36 50         ld   (hl),$50            // set counter
0711: C9            ret

// If we get here, either its a single player game or player two has lost all their lives.
0712: 3A 06 40      ld   a,($4006)           // read IS_GAME_IN_PLAY
0715: 0F            rrca                     // move bit 0 into carry
0716: 30 05         jr   nc,$071D            // if carry is not set, game is not in play, goto $071D
0718: 36 04         ld   (hl),$04            // set SCRIPT_STAGE to 4
071A: C3 0E 07      jp   $070E

071D: 36 0E         ld   (hl),$0E            //set SCRIPT_STAGE to $0E (14 decimal) 
071F: C3 0E 07      jp   $070E


//
// Player 1 and player 2 have used up all their lives.
//

GAME_OVER:
0722: 3A 06 40      ld   a,($4006)           // read IS_GAME_IN_PLAY
0725: 0F            rrca                     // move bit 0 into carry
0726: 30 E5         jr   nc,$070D            // if carry is not set, game is not in play, goto $070D
0728: 3E 01         ld   a,$01
072A: 32 05 40      ld   ($4005),a           // set SCRIPT_NUMBER to 1
072D: AF            xor  a
072E: 32 06 40      ld   ($4006),a           // clear IS_GAME_IN_PLAY
0731: 32 0A 40      ld   ($400A),a           // clear SCRIPT_STAGE
0734: CD B5 1C      call $1CB5               // call RESET_SOUND
0737: 11 00 06      ld   de,$0600            // command: PRINT_TEXT, parameter: 0 (index of "GAME OVER")
073A: C3 F2 08      jp   $08F2               // jump to QUEUE COMMAND  



//
// Player one has died. It's player two's turn now.
//

SWITCH_TO_PLAYER_TWO:
073D: 21 09 40      ld   hl,$4009            // load HL with address of TEMP_COUNTER_2
0740: 35            dec  (hl)                // decrement counter
0741: C0            ret  nz                  // return if count !=0
0742: 2C            inc  l                   // bump HL to point to SCRIPT_STAGE
0743: AF            xor  a
0744: 77            ld   (hl),a              
0745: 32 22 42      ld   ($4222),a           // reset LEVEL_COMPLETE flag
0748: 32 2B 42      ld   ($422B),a           // reset IS_FLAGSHIP_HIT flag

// preserve state of the swarm so that it can be restored for player one's next turn. 
074B: 11 80 41      ld   de,$4180            // load DE with pointer to PLAYER_ONE_PACKED_SWARM_DEF
074E: CD 64 07      call $0764               // call PACK_ALIEN_SWARM

// save rest of player state so it can be restored too.
0751: 21 18 42      ld   hl,$4218            // load HL with address of CURRENT_PLAYER_STATE
0754: 01 08 00      ld   bc,$0008
0757: ED B0         ldir                     // update player one's state

// OK, now execute script to handle player two.
0759: 3E 01         ld   a,$01
075B: 32 0D 40      ld   ($400D),a           // set CURRENT_PLAYER to 1 (Player TWO)
075E: 3E 04         ld   a,$04
0760: 32 05 40      ld   ($4005),a           // set SCRIPT_NUMBER to 4
0763: C9            ret


//
// Packs the 128 byte array that defines the alien swarm into a 16 byte buffer.
//
// This is used when a player dies and the game has to persist (ie: remember) the current state of the alien swarm 
// before the other player's turn starts. 
//
// See also UNPACK_ALIEN_SWARM which unpacks the 16 byte buffer back into ALIEN_SWARM_FLAGS.
//
// 
// Expects:
// DE = pointer to 16 byte buffer.  
//

PACK_ALIEN_SWARM:
0764: 21 00 41      ld   hl,$4100            // load HL with address of ALIEN_SWARM_FLAGS
0767: 06 10         ld   b,$10               // buffer is $10 (16 decimal) bytes in length
0769: 0E 01         ld   c,$01               
076B: AF            xor  a                   
076C: CB 46         bit  0,(hl)              
076E: 28 01         jr   z,$0771             
0770: B1            or   c                   
0771: 23            inc  hl                  
0772: CB 01         rlc  c                   
0774: 30 F6         jr   nc,$076C            
0776: 12            ld   (de),a        
0777: 13            inc  de            
0778: 10 F1         djnz $076B
077A: C9            ret



//
// This script is responsible for managing PLAYER 2's game.
//
//
//

SCRIPT_FOUR:
077B: CD 0D 09      call $090D               // call HANDLE_SWARM_MOVEMENT
077E: CD 8E 09      call $098E               // call SET_ALIEN_PRESENCE_FLAGS
0781: 3A 0A 40      ld   a,($400A)
0784: EF            rst  $28                 // jump to code @ $0785 + (A*2)

0785: 
      50 05         // $0550   
      83 05         // $0583 (CLEAR_ROW_OF_SCREEN)
      95 07         // $0795 (PLAYER_TWO_INIT)
      05 06         // $0605 (CLEAR_PLAYER_TEXT)
      14 06         // $0614 (HANDLE_SPAWN_PLAYER)
      61 06         // $0661 (HANDLE_MAIN_GAME_LOGIC)
      E8 07         // $07E8 (HANDLE_PLAYER_TWO_KILLED)
      18 08         // $0818 (SWITCH_TO_PLAYER_ONE)


//
// Player two's turn is about to commence. 
//


PLAYER_TWO_INIT:
// restore alien swarm to what it was last turn 
0795: 11 A0 41      ld   de,$41A0            // address of PLAYER_TWO_PACKED_SWARM_DEF
0798: CD 46 06      call $0646               // call UNPACK_ALIEN_SWARM
// copy player two's state (ie: game settings) to current player state
079B: EB            ex   de,hl               // now HL = pointer to PLAYER_TWO_STATE
079C: 11 18 42      ld   de,$4218            // load DE with address of CURRENT_PLAYER_STATE 
079F: 01 08 00      ld   bc,$0008
07A2: ED B0         ldir                     // move player 2's state to CURRENT_PLAYER_STATE 

// reset any game settings 
07A4: AF            xor  a
07A5: 32 5F 42      ld   ($425F),a           // set TIMING_VARIABLE
07A8: 32 20 42      ld   ($4220),a           // clear HAVE_NO_ALIENS_IN_SWARM flag.

// if the cabinet is cocktail, flip the screen for player two
07AB: 3A 0F 40      ld   a,($400F)           // read IS_COCKTAIL
07AE: A7            and  a                   // test if its zero (meaning UPRIGHT)
07AF: 28 09         jr   z,$07BA             // if its upright, goto $07BA          
07B1: 32 18 40      ld   ($4018),a           // set DISPLAY_IS_COCKTAIL_P2 to true
07B4: 32 06 70      ld   ($7006),a           // enable "regen hflip" which hardware flips the screen horizontally 
07B7: 32 07 70      ld   ($7007),a           // enable "regen vflip" which hardware flips the screen vertically

07BA: 21 0A 40      ld   hl,$400A            // load HL with address of SCRIPT_STAGE
07BD: 34            inc  (hl)                // advance to next stage
07BE: 2D            dec  l                   // bump HL to point to TEMP_COUNTER_2
07BF: 36 96         ld   (hl),$96            // set counter
07C1: 21 30 08      ld   hl,$0830
07C4: 22 45 42      ld   ($4245),hl          // set FLAGSHIP_ATTACK_MASTER_COUNTER_1 and FLAGSHIP_ATTACK_MASTER_COUNTER_2

// if its not demo mode, display the scores
07C7: 3A 06 40      ld   a,($4006)           // read IS_GAME_IN_PLAY
07CA: 0F            rrca                     // move bit 0 into carry
07CB: D0            ret  nc                  // return if game is not in play
07CC: 11 03 05      ld   de,$0503            // command: DISPLAY_SCORE_COMMAND, parameter: 3 (invokes DISPLAY_ALL_SCORES)
07CF: CD F2 08      call $08F2               // call QUEUE_COMMAND
07D2: 11 03 06      ld   de,$0603            // command: PRINT_TEXT, parameter: 3 (index of "PLAYER TWO")
07D5: CD F2 08      call $08F2               // call QUEUE_COMMAND
07D8: 1C            inc  e                   // index of "HIGH SCORE" 
07D9: CD F2 08      call $08F2               // call QUEUE_COMMAND
07DC: 11 03 07      ld   de,$0703            // command: BOTTOM_OF_SCREEN_INFO_COMMAND, parameter: 3 (invokes DISPLAY_PLAYER_SHIPS_REMAINING)
07DF: CD F2 08      call $08F2               // call QUEUE_COMMAND
07E2: 11 00 07      ld   de,$0700            // command: BOTTOM_OF_SCREEN_INFO_COMMAND, parameter: 0 (invokes DISPLAY_LEVEL_FLAGS) 
07E5: C3 F2 08      jp   $08F2               // jump to QUEUE COMMAND


//
// Player 2 has just been killed.
//
// See also: $06D8 (HANDLE_PLAYER_ONE_KILLED)
//

HANDLE_PLAYER_TWO_KILLED:
07E8: 21 0A 40      ld   hl,$400A            // load HL with address of SCRIPT_STAGE
07EB: 3A 1D 42      ld   a,($421D)           // read PLAYER_LIVES
07EE: A7            and  a                   // test if zero 
07EF: 20 1B         jr   nz,$080C            // if player 2 has lives remaining, goto $080C

// OK, player 1 has no lives. What about player 1?
07F1: 3A 95 41      ld   a,($4195)           // read PLAYER_ONE_LIVES 
07F4: A7            and  a                   // test if zero
07F5: CA 22 07      jp   z,$0722             // if player one is out of lives then that means GAME OVER for both players, goto $0722

// player 1 has some lives left
07F8: 34            inc  (hl)                // increment SCRIPT_STAGE
07F9: 2D            dec  l                   // bump HL to point to TEMP_COUNTER_2
07FA: 36 82         ld   (hl),$82            // set value of counter

// are we in demo mode?
07FC: 3A 06 40      ld   a,($4006)           // read IS_GAME_IN_PLAY flag 
07FF: 0F            rrca                     // move flag into carry
0800: D0            ret  nc                  // return if game is not in play

// Display PLAYER TWO GAME OVER
0801: 11 03 06      ld   de,$0603            // command: PRINT_TEXT, parameter: 3 (index of "PLAYER TWO") 
0804: CD F2 08      call $08F2               // call QUEUE_COMMAND
0807: 1E 00         ld   e,$00               // index of text string "GAME OVER"
0809: C3 F2 08      jp   $08F2               // jump to QUEUE COMMAND

// Player two's been killed. Is it player one's turn now? 
080C: 3A 95 41      ld   a,($4195)           // read PLAYER_ONE_LIVES        
080F: A7            and  a                   // test if zero
0810: CA 12 07      jp   z,$0712             // if zero, goto $0712
0813: 34            inc  (hl)                // increment SCRIPT_STAGE
0814: 2D            dec  l                   // bump HL to point to TEMP_COUNTER_2  
0815: 36 50         ld   (hl),$50
0817: C9            ret


//
//
// Called when player two has died and it's now player one's turn.
//
//

SWITCH_TO_PLAYER_ONE:
0818: 21 09 40      ld   hl,$4009            // load HL with address of TEMP_COUNTER_2
081B: 35            dec  (hl)
081C: C0            ret  nz

081D: 2C            inc  l                   // bump HL to point to SCRIPT_STAGE
081E: AF            xor  a
081F: 77            ld   (hl),a              // set SCRIPT_STAGE to 0

0820: 32 0D 40      ld   ($400D),a           // set CURRENT_PLAYER to 0 (player one)
0823: 3E 03         ld   a,$03
0825: 32 05 40      ld   ($4005),a           // set SCRIPT_NUMBER

// preserve state of the swarm so that it can be restored for player two's next turn. 
0828: 11 A0 41      ld   de,$41A0            // Address of PLAYER_TWO_PACKED_SWARM_DEF
082B: CD 64 07      call $0764               // call PACK_ALIEN_SWARM to convert the swarm into bit flags and write to DE

// save rest of player state so it can be restored too.
082E: 21 18 42      ld   hl,$4218            // load HL with address of CURRENT_PLAYER_STATE
0831: 01 08 00      ld   bc,$0008
0834: ED B0         ldir                     // preserve player two's state
0836: C9            ret



//
// Read player joystick/ movement controls and move player ship accordingly.
// As stated in DISPLAY_PLAYER_COMMAND ($215F), the player ship isn't a sprite, its 4x4 characters.
// When you move the ship, the columns containing the ship are scrolled.
// 
// See also:
// HANDLE_PLAYER_SHOOT.
//

HANDLE_PLAYER_MOVE:
0837: 21 00 42      ld   hl,$4200            // load HL with address of HAS_PLAYER_SPAWNED flag
083A: CB 46         bit  0,(hl)              // has player spawned?
083C: 28 39         jr   z,$0877             // no, goto SPAWN_PLAYER_OR_DIE
083E: 2C            inc  l
083F: 2C            inc  l                   // now HL points to PLAYER_Y

// are we in demo mode?
0840: 3A 06 40      ld   a,($4006)           // read IS_GAME_IN_PLAY      
0843: 0F            rrca                     // move bit 0 into carry. If carry is now set, the game is in play.
0844: D2 92 08      jp   nc,$0892            // carry not set, game is not in play, goto $0892 to simulate moving player ship in attract mode
0847: 3A 18 40      ld   a,($4018)           // read DISPLAY_IS_COCKTAIL_P2 flag
084A: 0F            rrca                     // move bit 0 into carry
084B: 38 3F         jr   c,$088C             // if carry is set, we're in cocktail mode and it's player 2 in control. Goto $088C

// read movement controls
084D: 3A 10 40      ld   a,($4010)           // read PORT_STATE_6000
0850: 47            ld   b,a                 // save a copy in B
0851: CB 5F         bit  3,a                 // has MOVE RIGHT been pushed?
0853: 28 06         jr   z,$085B             // no, goto TEST_JOYSTICK_PUSHED_LEFT

// player pushed stick right
0855: 7E            ld   a,(hl)              // load PLAYER_Y into A           
0856: FE 17         cp   $17                 // compare to #$17 (23 decimal) 
0858: 38 01         jr   c,$085B             // if A < #$17 then player is at far right screen edge and can go no further, goto $085B
085A: 35            dec  (hl)                // decrement PLAYER_Y (moving ship RIGHT: remember, the monitor is flipped 90 degrees)

TEST_JOYSTICK_PUSHED_LEFT:
085B: CB 50         bit  2,b                 // has MOVE LEFT been pushed?  
085D: 28 06         jr   z,$0865             // No, goto $0865

// player pushed stick left
085F: 7E            ld   a,(hl)              // get Y coordinate of player ship into A
0860: FE E9         cp   $E9                 // compare to #$E9 (233 decimal)
0862: 30 01         jr   nc,$0865            // if A>= #$E9 then player is at far left screen edge and can go no further, goto $0865
0864: 34            inc  (hl)                // increment PLAYER_Y (moving ship LEFT)

// set scroll value for columns containing the player ship characters
SET_PLAYER_SHIP_SCROLL_OFFSET:
0865: 7E            ld   a,(hl)              // get ship Y coordinate into A            
0866: 2F            cpl                      // flip the bits
0867: C6 80         add  a,$80               // add an offset. Now we have a scroll value in A.
0869: 0E 06         ld   c,$06               // set colour of player ship
086B: 21 54 40      ld   hl,$4054            // set hl to point to first column containing player ship pseudosprite. 

// the players ship is 2x2 characters when alive, 4x4 when its exploding. We need to set the scroll offset for the 4 columns.
086E: 06 04         ld   b,$04               // we're doing 4 columns
0870: 77            ld   (hl),a              // write scroll offset to OBJRAM_BACK_BUF (see docs @top)
0871: 2C            inc  l                   // bump pointer to colour value for column
0872: 71            ld   (hl),c              // write colour to OBJRAM_BACK_BUF (see docs @ top) 
0873: 2C            inc  l                   // bump pointer to scroll offset value for column
0874: 10 FA         djnz $0870               // do until b==0
0876: C9            ret

// if we get here, then either the player hasn't spawned, or the player is hit.
SPAWN_PLAYER_OR_DIE:
0877: 2C            inc  l                   // point HL to IS_PLAYER_DYING flag
0878: CB 46         bit  0,(hl)              // test flag
087A: 20 06         jr   nz,$0882            // if flag is set, player will die, goto PLAYER_EXPLOSION_INIT

// spawn player
087C: 2C            inc  l                   // otherwise, point HL to PLAYER_Y
087D: 36 00         ld   (hl),$00            // set value of PLAYER_Y to 0
087F: C3 65 08      jp   $0865               // and set the scroll for the player ship

// if we get here, the player is about to explode. 
PLAYER_EXPLOSION_INIT: 
0882: 2C            inc  l                   // point HL to PLAYER_Y
0883: 7E            ld   a,(hl)              // read value of PLAYER_Y
0884: 2F            cpl                        
0885: C6 80         add  a,$80               // add an offset. Now we have a scroll value in A.
0887: 0E 07         ld   c,$07               // colour value (see $0872)
0889: C3 6B 08      jp   $086B               // and set the scroll offsets and colour values for the exploding ship


088C: 3A 11 40      ld   a,($4011)           // read PORT_STATE_6800
088F: C3 50 08      jp   $0850               // now test player 2's movement stick

// In ATTRACT MODE, this piece of code supplies faked joystick movements and FIRE button presses to the player move logic.
// The player spaceship looks like someone is controlling it.
0892: 3A 3F 42      ld   a,($423F)           // read bit flags from ATTRACT_MODE_FAKE_CONTROLLER.
0895: C3 50 08      jp   $0850




//
// This routine is responsible for moving the player bullet, and positioning the player bullet sprite.
//
//

HANDLE_PLAYER_BULLET:
0898: CD BC 08      call $08BC               // call POSITION_PLAYER_BULLET
089B: 2A 09 42      ld   hl,($4209)          // load value of PLAYER_BULLET_Y  into H, PLAYER_BULLET_X into L        
089E: 3A 18 40      ld   a,($4018)           // read DISPLAY_IS_COCKTAIL_P2
08A1: 0F            rrca                     // move bit 0 into carry. 
08A2: 38 0D         jr   c,$08B1             // If carry is set, then player 2 is playing and its a cocktail cab: goto $08B1.

// This code updates the bullet sprite state in the OBJRAM back buffer. 
08A4: 7D            ld   a,l                 // load A with PLAYER_BULLET_X
08A5: 2F            cpl
08A6: C6 FC         add  a,-4                // subtract 4 
08A8: 32 9F 40      ld   ($409F),a           // update OBJRAM_BUF_PLAYER_BULLET_X 
08AB: 7C            ld   a,h                 // load A with PLAYER_BULLET_Y
08AC: 2F            cpl
08AD: 32 9D 40      ld   ($409D),a           // update OBJRAM_BUF_PLAYER_BULLET_Y
08B0: C9            ret

// this code only runs when the game is in cocktail mode and it's player 2 playing.
// It takes into account the screen is upside down and positions the player bullet properly.
08B1: 7D            ld   a,l
08B2: 3D            dec  a
08B3: 32 9F 40      ld   ($409F),a           // update OBJRAM_BUF_PLAYER_BULLET_X
08B6: 7C            ld   a,h
08B7: 2F            cpl
08B8: 32 9D 40      ld   ($409D),a           // update OBJRAM_BUF_PLAYER_BULLET_Y
08BB: C9            ret



//
// If the player bullet has not been fired, position it just above the player ship.
//
// Otherwise, move player bullet upscreen. When bullet reaches its limit, set IS_PLAYER_BULLET_DONE flag to 1.
//

POSITION_PLAYER_BULLET:
08BC: 21 08 42      ld   hl,$4208            // pointer to HAS_PLAYER_BULLET_BEEN_FIRED flag 
08BF: CB 46         bit  0,(hl)              // test if flag is set
08C1: 23            inc  hl                  // HL now points to PLAYER_BULLET_X
08C2: 28 0F         jr   z,$08D3             // if player has not fired, goto POSITION_PLAYER_BULLET_ABOVE_SHIP

// player bullet has been fired. Subtract 4 from its X coordinate and check if its gone off screen.
08C4: 7E            ld   a,(hl)              // get X coordinate of bullet
08C5: D6 04         sub  $04                 // subtract 4, moving bullet UP the screen
08C7: 77            ld   (hl),a              // update X coordinate of bullet
08C8: D6 0E         sub  $0E                 // 
08CA: D6 04         sub  $04h                // subtract 18 (decimal) total from X coordinate
08CC: D0            ret  nc                  // if there's no carry, then the players bullet has not reached its limit

// player bullet has gone offscreen
08CD: 3E 01         ld   a,$01               
08CF: 32 0B 42      ld   ($420B),a           // set IS_PLAYER_BULLET_DONE flag
08D2: C9            ret

// the player bullet isn't fired, so place it above the player ship.
POSITION_PLAYER_BULLET_ABOVE_SHIP:
08D3: 36 DC         ld   (hl),$DC            // set PLAYER_BULLET_X
08D5: 2C            inc  l                   // point HL to PLAYER_BULLET_Y
08D6: 3A 00 42      ld   a,($4200)           // read HAS_PLAYER_SPAWNED flag
08D9: CB 47         bit  0,a                 // test if player has spawned
08DB: 28 05         jr   z,$08E2             // no, player has not spawned, goto $08E2
08DD: 3A 02 42      ld   a,($4202)           // read PLAYER_Y
08E0: 77            ld   (hl),a              // and write to PLAYER_BULLET_Y
08E1: C9            ret

// player hasn't spawned. Hide the bullet!
08E2: 36 00         ld   (hl),$00            // write 0 to PLAYER_BULLET_Y
08E4: C9            ret


//
// Check if the player bullet has gone all the way upscreen. If so, allow player to shoot again.
//

CHECK_IF_PLAYER_BULLET_IS_DONE:
08E5: 3A 0B 42      ld   a,($420B)           // read IS_PLAYER_BULLET_DONE flag
08E8: 0F            rrca                     // move bit 0 into carry. If carry is set then the player bullet's gone as far as it can.
08E9: D0            ret  nc                  // if no carry, then return. 
08EA: AF            xor  a
08EB: 32 0B 42      ld   ($420B),a           // reset the IS_PLAYER_BULLET_DONE flag
08EE: 32 08 42      ld   ($4208),a           // reset HAS_PLAYER_BULLET_BEEN_FIRED flag. Player can shoot again.
08F1: C9            ret



//
// Try to insert into the circular command queue located @ $40C0. (CIRC_CMD_QUEUE_START)
// if insert is not possible, exit function immediately.
//
// Expects:
// D is a command number (0..7) 
// E is a parameter to pass to the command. 
//
// $40A0 contains the low byte of a pointer to a (hopefully) free entry in the queue.  
//
// REMARKS:
//
// Value in D                Action it invokes 
// ===============================================================
// 0                         Invokes DRAW_ALIEN_COMMAND
// 1                         Invokes DELETE_ALIEN_COMMAND
// 2:                        Invokes DISPLAY_PLAYER_COMMAND
// 3:                        Invokes UPDATE_PLAYER_SCORE_COMMAND
// 4:                        Invokes RESET_SCORE_COMMAND
// 5:                        Invokes DISPLAY_SCORE_COMMAND
// 6:                        Invokes PRINT_TEXT 
// 7:                        Invokes BOTTOM_OF_SCREEN_INFO_COMMAND
// 
// The purpose of the parameter in E depends on the command.
//
// SEE ALSO:
// The code @ $200C which processes the entries in the queue.

// ALGORITHM:
// 1. Form a pointer to an entry in the circular queue using #$40 as the high byte of the pointer
//    and the contents of $40A0 (CIRC_CMD_QUEUE_PTR_LO) as the low byte. 
// 2. Read a byte from the queue entry the pointer points to 
// 3. IF bit 7 of the byte is unset, then the queue entry is in use, we can't insert. Exit function.  
// 4. ELSE:
//    4a) store register DE at the pointer
//    4b) bump pointer to next queue entry 
// 5. Exit function

QUEUE_COMMAND:
08F2: E5            push hl
08F3: 26 40         ld   h,$40               // set high byte of address
08F5: 3A A0 40      ld   a,($40A0)           // read CIRC_CMD_QUEUE_PTR_LO          
08F8: 6F            ld   l,a                 // set low byte of address. Now HL = pointer to entry in circular queue.
08F9: CB 7E         bit  7,(hl)              // read byte from address and test bit 7
08FB: 28 0E         jr   z,$090B             // if bit 7 not set, this entry cannot be used, goto $090B and exit
08FD: 72            ld   (hl),d              // write DE...
08FE: 2C            inc  l
08FF: 73            ld   (hl),e
0900: 2C            inc  l                   // to (HL)
0901: 7D            ld   a,l                 // 
0902: FE C0         cp   $C0                 // compare low byte of address in HL to #$C0. 
0904: 30 02         jr   nc,$0908            // if A > #$C0 (192 decimal) then we've not hit the end of the circular queue, goto $0908
0906: 3E C0         ld   a,$C0               // otherwise, we're past the end of the queue, reset queue pointer high byte to #$C0 (192 decimal)
0908: 32 A0 40      ld   ($40A0),a           // update CIRC_CMD_QUEUE_PTR_LO to point to next queue entry
090B: E1            pop  hl
090C: C9            ret



// This routine does two things:
//
// 1. Stops the swarm from moving if the player bullet gets too close to an alien in the swarm 
// 2. Sets the scroll registers for the columns containing the swarm
// 
// Before I investigated this code, I never noticed the swarm stops - now I can't not notice it.
// If you want the aliens to just not care about their own safety, type the following into the debugger: maincpu.mw@$093C=0 
//

HANDLE_SWARM_MOVEMENT:
090D: 21 08 42      ld   hl,$4208            // point HL to HAS_PLAYER_BULLET_BEEN_FIRED flag
0910: CB 46         bit  0,(hl)              // test bit 0. 
0912: 28 2A         jr   z,$093E             // If player hasn't fired, goto $093E 
0914: 2C            inc  l                   // point HL to PLAYER_BULLET_X
0915: 7E            ld   a,(hl)              // read X coordinate of bullet
0916: D6 22         sub  $22
0918: FE 50         cp   $50                 // compare to $50 (80 decimal)
091A: 30 22         jr   nc,$093E            // if greater than $50, goto $093E

091C: 2C            inc  l                   // point HL to PLAYER_BULLET_Y
091D: 3A 0E 42      ld   a,($420E)           // read SWARM_SCROLL_VALUE
0920: 96            sub  (hl)                // subtract from value in PLAYER_BULLET_Y
0921: ED 44         neg                      // A = 256-A   
0923: 47            ld   b,a
0924: C6 02         add  a,$02
0926: E6 0F         and  $0F
0928: FE 03         cp   $03
092A: 30 12         jr   nc,$093E            // if A >= #$03 goto $093E

092C: 78            ld   a,b
092D: 0F            rrca
092E: 0F            rrca
092F: 0F            rrca
0930: 0F            rrca
0931: E6 0F         and  $0F                 // now A identifies the column of the swarm the player bullet is in
0933: 5F            ld   e,a
0934: 16 00         ld   d,$00
0936: 21 F0 41      ld   hl,$41F0            // load HL with address of ALIEN_IN_COLUMN_FLAGS
0939: 19            add  hl,de              
093A: CB 46         bit  0,(hl)              // are there any aliens in this column?
093C: 20 4A         jr   nz,$0988            // yes, make the swarm stand still!

// move the swarm, and make it change direction once its hit a screen edge 
093E: 2A 0E 42      ld   hl,($420E)          // read SWARM_SCROLL_VALUE
0941: ED 5B 10 42   ld   de,($4210)          // read SWARM_SCROLL_MAX_EXTENTS
0945: 3A 0D 42      ld   a,($420D)           // read SWARM_DIRECTION
0948: A7            and  a                   // test if its zero
0949: 20 12         jr   nz,$095D            // if not zero, swarm is moving right, goto $095D

// swarm is moving left
094B: CB 7C         bit  7,h                 
094D: 20 04         jr   nz,$0953
094F: 7D            ld   a,l
0950: BB            cp   e
0951: 30 2A         jr   nc,$097D            // jp to MAKE_SWARM_MOVE_RIGHT
0953: 3A 5F 42      ld   a,($425F)           // read TIMING_VARIABLE
0956: E6 03         and  $03                 // mask in bits 0 & 1
0958: C0            ret  nz                  // if either bit is set, return
0959: 23            inc  hl                  // increment scroll value. Swarm will move left (but in reality, a pixel down).
095A: C3 6C 09      jp   $096C

// swarm is moving right
095D: CB 7C         bit  7,h                 // test bit 7
095F: 28 04         jr   z,$0965
0961: 7D            ld   a,l
0962: BA            cp   d
0963: 38 1E         jr   c,$0983             // jp to MAKE_SWARM_MOVE_LEFT
0965: 3A 5F 42      ld   a,($425F)           // read TIMING_VARIABLE
0968: E6 03         and  $03                 // mask in bits 0 & 1
096A: C0            ret  nz                  // if either bit is set, return. 
096B: 2B            dec  hl                  // decrement scroll value. Swarm will move right (in reality, a pixel up).


// if you want the swarm to be static, or tinker with the scroll, fill $096C to $096E with NOP instructions. 
096C: 22 0E 42      ld   ($420E),hl          // set SWARM_SCROLL_VALUE 
096F: 7D            ld   a,l                 
0970: ED 44         neg                      // A = 256-A


//
// This is used to scroll the alien swarm from side to side.
//
// Expects:
// register A: Scroll offset value
//

SET_SWARM_SCROLL_OFFSET:
0972: 21 28 40      ld   hl,$4028            // pointer to attribute and column scroll data held in OBJRAM_BACK_BUF
0975: 06 09         ld   b,$09               // we're doing 9 columns.
0977: 77            ld   (hl),a              // write value into scroll offset in OBJRAM_BACK_BUF. 
0978: 2C            inc  l
0979: 2C            inc  l                   // bump HL to next scroll offset address in OBJRAM_BACK_BUF
097A: 10 FB         djnz $0977
097C: C9            ret


MAKE_SWARM_MOVE_RIGHT:
097D: 3E 01         ld   a,$01
097F: 32 0D 42      ld   ($420D),a           // set SWARM_DIRECTION to 1. Swarm now moves right.
0982: C9            ret

MAKE_SWARM_MOVE_LEFT:
0983: AF            xor  a
0984: 32 0D 42      ld   ($420D),a           // set SWARM_DIRECTION to 0. Swarm now moves left.
0987: C9            ret

0988: 2A 0E 42      ld   hl,($420E)          // read SWARM_SCROLL_VALUE
098B: C3 6F 09      jp   $096F


//
// This routine sets the following flags:  
//
// ALIEN_IN_COLUMN_FLAGS
// HAVE_ALIENS_IN_6TH_ROW
// HAVE_ALIENS_IN_5TH_ROW
// HAVE_ALIENS_IN_4TH_ROW
// HAVE_ALIENS_IN_3RD_ROW
// HAVE_ALIENS_IN_2ND_ROW
// HAVE_ALIENS_IN_TOP_ROW
// HAVE_NO_BLUE_OR_PURPLE_ALIENS
// HAVE_NO_ALIENS_IN_SWARM 
// HAVE_NO_INFLIGHT_ALIENS
// HAVE_NO_INFLIGHT_OR_DYING_ALIENS
// 
// It also sets the values for SWARM_SCROLL_MAX_EXTENTS. 

SET_ALIEN_PRESENCE_FLAGS:     // TENTATIVE NAME - If anyone can think of anything better, give me a shout
098E: AF            xor  a
098F: 11 E8 41      ld   de,$41E8     
0992: 12            ld   (de),a              // clear $41E8
0993: 1C            inc  e                    
0994: 12            ld   (de),a              // clear $41E9
0995: 1C            inc  e                   // DE now = $41EA (address of HAVE_ALIENS_IN_IN_ROW_FLAGS)

// This part of the code determines if there are any aliens on a given row.
// It will set the corresponding flag in the HAVE_ALIENS_IN_ROW_FLAGS array.
// it works from the bottom row of aliens to the top.
0996: 0E 06         ld   c,$06               // there are 6 rows of aliens. Used as a row counter.
0998: 21 23 41      ld   hl,$4123            // pointer to bottom right alien in ALIEN_SWARM_FLAGS

099B: 06 0A         ld   b,$0A               // There's $0A (10 decimal) aliens max per row
099D: AF            xor  a                   // clear A. 
099E: B6            or   (hl)                // If an alien is present, A will now be set to 1.
099F: 2C            inc  l                   // move to next flag
09A0: 10 FC         djnz $099E               // repeat tests until B == 0.

09A2: 12            ld   (de),a              // store alien presence flag in HAVE_ALIENS_IN_[]_ROW flag
09A3: 1C            inc  e                   // bump DE to point to next HAVE_ALIENS_IN_[]_ROW flag
09A4: 7D            ld   a,l          
09A5: C6 06         add  a,$06
09A7: 6F            ld   l,a                 // Add 6 to HL. Now HL points to flags for row of aliens above previous    
09A8: 0D            dec  c                   // decrement row counter
09A9: C2 9B 09      jp   nz,$099B            // if not all rows of aliens have been processed, goto $099B

// when we get here, DE points to $41F0, which is the start of the ALIEN_IN_COLUMN_FLAGS array.
09AC: AF            xor  a
09AD: 12            ld   (de),a              // clear first entry of ALIEN_IN_COLUMN_FLAGS. 
09AE: 1C            inc  e
09AF: 12            ld   (de),a              // clear second entry of ALIEN_IN_COLUMN_FLAGS.
09B0: 1C            inc  e
09B1: 12            ld   (de),a              // clear second entry of ALIEN_IN_COLUMN_FLAGS.
09B2: 1C            inc  e

09B3: 21 23 41      ld   hl,$4123            // pointer to bottom right alien in ALIEN_SWARM_FLAGS 
09B6: 0E 0A         ld   c,$0A               // There's $0A (10 decimal) columns of aliens 

// Working from the rightmost column of aliens to the left, check each column for presence of aliens and
// set/clear respective flag in ALIEN_IN_COLUMN_FLAGS array accordingly. 
09B8: D5            push de
09B9: 11 10 00      ld   de,$0010            // offset to add to HL to point to alien in row above, same column.
09BC: 06 06         ld   b,$06               // 6 rows of aliens. Used as a row counter.
09BE: AF            xor  a
09BF: B6            or   (hl)                // If an alien is present, A will now be set to 1.
09C0: 19            add  hl,de               // Point HL to alien in row above, same column.
09C1: 10 FC         djnz $09BF               // Repeat until all 6 rows of aliens have been scanned
09C3: D1            pop  de
09C4: 12            ld   (de),a              // set/clear flag in ALIEN_IN_COLUMN_FLAGS
09C5: 1C            inc  e                   // bump DE to point to next entry in ALIEN_IN_COLUMN_FLAGS

// we've scanned all the aliens in a column. 
// We now want to scan the next column of aliens to the immediate *left* of the column we just scanned. 
09C6: 7D            ld   a,l
09C7: D6 5F         sub  $5F
09C9: 6F            ld   l,a                 // now HL points to bottom alien in next column of aliens to check  
09CA: 0D            dec  c                   // decrement counter for number of columns left to process            
09CB: C2 B8 09      jp   nz,$09B8            // if we've not done all the columns, goto $09B8

// the following code works out how far to the left the swarm can move. Or should I say, how far the swarm can be scrolled down.
// TODO: I'll come back to this code later, but at the moment there's bigger fish to fry with this game, so I'll just leave bare bones here.
09CE: 21 FC 41      ld   hl,$41FC            // load HL with a pointer to flag for the leftmost column of aliens in ALIEN_IN_COLUMN_FLAGS
09D1: 06 0A         ld   b,$0A               // There's $0A (10 decimal) columns of aliens 
09D3: 1E 22         ld   e,$22
09D5: CB 46         bit  0,(hl)              // Test the flag. Is there an alien in the column?
09D7: 20 09         jr   nz,$09E2            // yes, goto $09E2
09D9: 2D            dec  l                   // bump HL to point to flag for column to left
09DA: 7B            ld   a,e
09DB: C6 10         add  a,$10
09DD: 5F            ld   e,a
09DE: 10 F5         djnz $09D5

// now work out how far to the right the swarm can move. 
09E0: 1E 22         ld   e,$22
09E2: 21 F3 41      ld   hl,$41F3            // load HL with a pointer to flag for the rightmost column of aliens in ALIEN_IN_COLUMN_FLAGS
09E5: 06 0A         ld   b,$0A               // There's $0A (10 decimal) columns of aliens
09E7: 16 E0         ld   d,$E0
09E9: CB 46         bit  0,(hl)              // Test the flag. Is there an alien in the column?
09EB: 20 09         jr   nz,$09F6            // yes, goto $09F6
09ED: 2C            inc  l
09EE: 7A            ld   a,d
09EF: D6 10         sub  $10
09F1: 57            ld   d,a
09F2: 10 F5         djnz $09E9
09F4: 16 E0         ld   d,$E0
09F6: ED 53 10 42   ld   ($4210),de          // set SWARM_SCROLL_MAX_EXTENTS

// Check if any of the bottom 4 rows of aliens (blue & purple) have any aliens in them. *Aliens from those rows that are in flight don't count*
09FA: 21 EA 41      ld   hl,$41EA            // load HL with pointer to HAVE_ALIENS_IN_6TH_ROW
09FD: 0E 01         ld   c,$01
09FF: 06 04         ld   b,$04               // we want to do 4 rows of aliens
0A01: AF            xor  a
0A02: B6            or   (hl)                // test if there's an alien present on the row
0A03: 2C            inc  l                   // bump HL to point to flag for row above 
0A04: 10 FC         djnz $0A02               // repeat until b==0
0A06: A9            xor  c                   // 
0A07: 32 21 42      ld   ($4221),a           // set HAVE_NO_BLUE_OR_PURPLE_ALIENS flag

// HL = pointer to HAVE_ALIENS_IN_2ND_ROW
0A0A: A9            xor  c                   // if A was 1, set it to 0, and vice versa
0A0B: B6            or   (hl)                // if any aliens in red row set A to 1  *Red aliens in flight don't count*
0A0C: 2C            inc  l                   // bump HL to point to HAVE_ALIENS_IN_TOP_ROW
0A0D: B6            or   (hl)                // if any aliens in flagship row set A to 1   *Flagships that are in flight don't count*
0A0E: A9            xor  c                   // if A was 1, set it to 0, and vice versa
0A0F: 32 20 42      ld   ($4220),a           // set/reset HAVE_NO_ALIENS_IN_SWARM flag.

// Check if we have any aliens "in-flight" attacking the player.
// We skip the first entry in the INFLIGHT_ALIENS array because the first entry is reserved for misc use (see docs above INFLIGHT_ALIEN struct)
// and should not be treated as a "real" flying alien.
0A12: 21 D0 42      ld   hl,$42D0            // pointer to INFLIGHT_ALIENS_START+sizeof(INFLIGHT_ALIEN). Effectively skipping first INFLIGHT_ALIEN. 
0A15: 11 20 00      ld   de,$0020            // sizeof(INFLIGHT_ALIEN)
0A18: 06 07         ld   b,$07               // 7 aliens to process in the list
0A1A: AF            xor  a                   // clear A
0A1B: B6            or   (hl)                // Set A to 1 if alien is active
0A1C: 19            add  hl,de               // bump HL to point to next INFLIGHT_ALIEN structure in the array
0A1D: 10 FC         djnz $0A1B               // repeat until B==0
0A1F: A9            xor  c                   // if no aliens are in flight, A will be set to 1.  Else A is set 0. 
0A20: 32 26 42      ld   ($4226),a           // set/reset HAVE_NO_INFLIGHT_ALIENS flag 

// Check if we have any aliens "in-flight" or dying 
0A23: A9            xor  c                   // 
0A24: 21 B1 42      ld   hl,$42B1            // pointer to first IsDying flag of INFLIGHT_ALIENS array.
0A27: 06 08         ld   b,$08               // test all 8 slots
0A29: B6            or   (hl)                // if INFLIGHT_ALIEN.IsDying is set to 1, set A to 1.
0A2A: 19            add  hl,de               // bump HL to point to next INFLIGHT_ALIEN structure in the array
0A2B: 10 FC         djnz $0A29               // repeat until B==0
0A2D: A9            xor  c                   // 
0A2E: 32 25 42      ld   ($4225),a           // set/reset HAVE_NO_INFLIGHT_OR_DYING_ALIENS
0A31: C9            ret




HANDLE_PLAYER_SHOOT:
0A32: 3A 00 42      ld   a,($4200)           // read HAS_PLAYER_SPAWNED flag
0A35: 0F            rrca                     // move bit 0 into carry
0A36: D0            ret  nc                  // if player has not spawned, return
0A37: 3A 08 42      ld   a,($4208)           // read HAS_PLAYER_BULLET_BEEN_FIRED flag
0A3A: 0F            rrca                     // move bit 0 into carry
0A3B: D8            ret  c                   // if carry is set, missile has already been fired, can't shoot again.
0A3C: 3A 06 40      ld   a,($4006)           // read IS_GAME_IN_PLAY flag
0A3F: 0F            rrca                     // move bit 0 into carry
0A40: 30 26         jr   nc,$0A68            // if no carry, game is not in play, so this is demo mode, goto $0A68
0A42: 3A 18 40      ld   a,($4018)           // read DISPLAY_IS_COCKTAIL_P2 flag
0A45: 0F            rrca                     // move bit 0 into carry
0A46: 38 15         jr   c,$0A5D             // if we're player 2 and we're playing on a cocktail machine, goto $0A5D 
0A48: 3A 13 40      ld   a,($4013)           // read PREV_PORT_STATE_6000 
0A4B: 2F            cpl
0A4C: 47            ld   b,a
0A4D: 3A 10 40      ld   a,($4010)           // read PORT_STATE_6000
0A50: A0            and  b
0A51: E6 10         and  $10                 // test state of SHOOT button
0A53: C8            ret  z                   // return if not held down
0A54: 3E 01         ld   a,$01
0A56: 32 08 42      ld   ($4208),a           // set HAS_PLAYER_BULLET_BEEN_FIRED flag
0A59: 32 CC 41      ld   ($41CC),a           // set PLAY_PLAYER_SHOOT_SOUND flag 
0A5C: C9            ret

// We come here if it's player 2's turn and the game is in cocktail mode.
0A5D: 3A 14 40      ld   a,($4014)           // read PREV_PORT_STATE_6800
0A60: 2F            cpl
0A61: 47            ld   b,a
0A62: 3A 11 40      ld   a,($4011)           // read PORT_STATE_6800
0A65: C3 50 0A      jp   $0A50               // go check if shoot button for player 2's controls is held down.


// We're in demo mode. We need to simulate the player firing at the aliens.
0A68: 3A 5F 42      ld   a,($425F)           // read TIMING_VARIABLE
0A6B: E6 1F         and  $1F                 // mask in bits 0..5
0A6D: C0            ret  nz                  // if result is not zero, then return
0A6E: 3E 01         ld   a,$01
0A70: 32 08 42      ld   ($4208),a           // set HAS_PLAYER_BULLET_BEEN_FIRED flag
0A73: C9            ret



//
// Move enemy bullets and position enemy bullet sprites
//
//
//

HANDLE_ENEMY_BULLETS:
0A74: DD 21 60 42   ld   ix,$4260            // load IX with address of ENEMY_BULLETS_START
0A78: 3A 5F 42      ld   a,($425F)           // read TIMING_VARIABLE
0A7B: 0F            rrca                     // move bit 0 into carry
0A7C: 38 0B         jr   c,$0A89             // if TIMING_VARIABLE is an odd number, goto $0A89
0A7E: DD 34 01      inc  (ix+$01)            // Increment ENEMY_BULLET.X by 2.. 
0A81: DD 34 01      inc  (ix+$01)            // 

0A84: 11 05 00      ld   de,$0005            // sizeof(ENEMY_BULLET)
0A87: DD 19         add  ix,de
0A89: FD 21 81 40   ld   iy,$4081            // pointer to OBJRAM_BACK_BUF_BULLETS
0A8D: 06 07         ld   b,$07               // number of bullets

// main bullet loop
0A8F: DD CB 00 46   bit  0,(ix+$00)          // test ENEMY_BULLET.IsActive flag
0A93: 28 27         jr   z,$0ABC             // if enemy bullet is not active, goto $0ABC
0A95: DD 7E 01      ld   a,(ix+$01)          // read ENEMY_BULLET.X 
0A98: C6 02         add  a,$02               // bullet will move 2 pixels
0A9A: DD 77 01      ld   (ix+$01),a          // update ENEMY_BULLET.X
0A9D: C6 04         add  a,$04               // tentatively add 4 to the X coordinate. If a carry occurs, enemy bullet is at bottom of screen 
0A9F: 38 1B         jr   c,$0ABC             // enemy bullet is at bottom of screen so needs to be deactivated, goto $0ABC

// split ENEMY_BULLET.YDelta into its sign and delta, then add to YH and YL respectively. 
0AA1: DD 6E 02      ld   l,(ix+$02)          // read ENEMY_BULLET.YL
0AA4: DD 66 03      ld   h,(ix+$03)          // read ENEMY_BULLET.YH
0AA7: DD 5E 04      ld   e,(ix+$04)          // read ENEMY_BULLET.YDelta 
0AAA: CB 13         rl   e                   // move bit 7 of E (sign bit) into carry. Shift YDelta bits left into bits 1..7.                  
0AAC: 9F            sbc  a,a                 // A = 0 - carry
0AAD: 57            ld   d,a                 // if bit 7 of E was set, D will be $FF, else 0.
0AAE: 19            add  hl,de               
0AAF: DD 75 02      ld   (ix+$02),l          // set ENEMY_BULLET.YL
0AB2: DD 74 03      ld   (ix+$03),h          // set ENEMY_BULLET.YH
0AB5: 7C            ld   a,h                 // get ENEMY_BULLET.YH coordinate into A
0AB6: C6 10         add  a,$10               // add #$10 (16 decimal) . 
0AB8: FE 20         cp   $20                 // compare to $20 (32 decimal)
0ABA: 30 0A         jr   nc,$0AC6            // if >= 32 decimal, bullet is still onscrene, goto $0AC6

// bullet is offscreen, deactivate it
0ABC: AF            xor  a
0ABD: DD 77 00      ld   (ix+$00),a          // set ENEMY_BULLET.IsActive flag (disables bullet)
0AC0: DD 77 01      ld   (ix+$01),a          // set ENEMY_BULLET.X to 0 
0AC3: DD 77 03      ld   (ix+$03),a          // set ENEMY_BULLET.YH to 0

// we now need to position the actual enemy bullet sprites.
0AC6: 3A 18 40      ld   a,($4018)           // read DISPLAY_IS_COCKTAIL_P2
0AC9: 0F            rrca                     // move flag into carry
0ACA: 38 29         jr   c,$0AF5             // if carry is set, it's a cocktail setup and player 2's turn, goto $0AF5

0ACC: DD 7E 01      ld   a,(ix+$01)          // read ENEMY_BULLET.X 
0ACF: 2F            cpl                      // A = (255 - A) 
0AD0: 3D            dec  a                   // A = A-1
0AD1: FD 77 02      ld   (iy+$02),a          // write to OBJRAM_BACK_BUF_BULLETS sprite state

// looks to me like there's a hardware "feature" where the Y coordinate of alien bullets 5-7 needs adjusted by 1 so the sprite is positioned correctly.
// if anyone can tell me why, drop me a line. Thanks!
0AD4: DD 7E 03      ld   a,(ix+$03)          // read ENEMY_BULLET.YH 
0AD7: 2F            cpl                      // A = (255 - A) 
0AD8: 4F            ld   c,a
0AD9: 78            ld   a,b                 // get index of enemy bullet we are processing into A
0ADA: FE 05         cp   $05                 // are we processing bullet #5 or more?
0ADC: 38 01         jr   c,$0ADF             // no, goto $0ADF
0ADE: 0C            inc  c                   // adjust Y coordinate
0ADF: FD 71 00      ld   (iy+$00),c          // write to OBJRAM_BACK_BUF_BULLETS sprite Y coordinate

0AE2: 11 05 00      ld   de,$0005            // sizeof(ENEMY_BULLET)
0AE5: DD 19         add  ix,de               // bump IX to point to next ENEMY_BULLET in ENEMY_BULLETS array
0AE7: DD 34 01      inc  (ix+$01)            // increment ENEMY_BULLET.X
0AEA: DD 34 01      inc  (ix+$01)            // twice, to make it move 2 pixels

0AED: DD 19         add  ix,de               // bump IX to point to next ENEMY_BULLET in ENEMY_BULLETS array
0AEF: 1D            dec  e                   // DE is now 4  
0AF0: FD 19         add  iy,de               // bump IY to point to state of next sprite in OBJRAM_BACK_BUF_BULLETS
0AF2: 10 9B         djnz $0A8F               // repeat until B ==0
0AF4: C9            ret

// called if we have a cocktail display and it's player 2's turn. 
0AF5: DD 7E 01      ld   a,(ix+$01)
0AF8: D6 04         sub  $04
0AFA: FD 77 02      ld   (iy+$02),a
0AFD: DD 7E 03      ld   a,(ix+$03)
0B00: 2F            cpl
0B01: 4F            ld   c,a
0B02: 78            ld   a,b
0B03: FE 05         cp   $05
0B05: 38 D8         jr   c,$0ADF
0B07: 0D            dec  c
0B08: C3 DF 0A      jp   $0ADF



//
// Check if the player's bullet has hit any aliens in the swarm.
// If so, delete the shot alien from the swarm, kick off a dying animation, and update player score with relevant points value. 
//

HANDLE_SWARM_ALIEN_TO_PLAYER_BULLET_COLLISION_DETECTION:
0B0B: 21 08 42      ld   hl,$4208            // pointer to HAS_PLAYER_BULLET_BEEN_FIRED  
0B0E: CB 46         bit  0,(hl)              // test bit 0. If it's set, player is shooting.
0B10: C8            ret  z                   // if zero flag is set, that means player is not shooting. Return.
0B11: 23            inc  hl                  // bump HL to point to PLAYER_BULLET_X
0B12: 7E            ld   a,(hl)              // read value of PLAYER_BULLET_X
0B13: FE 68         cp   $68                 // 
0B15: D0            ret  nc                  // if X coordinate >= #$68 (104 decimal) then bullet is not near swarm yet, so exit
0B16: D6 1E         sub  $1E                 // if X coordinate < #$1E (30 decimal) then bullet has passed the swarm, this subtraction will cause a carry.. 
0B18: D8            ret  c                   // .. so exit.

// OK, we have to check if an alien has been hit
0B19: 06 06         ld   b,$06               // number of rows of aliens
0B1B: D6 07         sub  $07
0B1D: D8            ret  c
0B1E: D6 05         sub  $05
0B20: 38 03         jr   c,$0B25             
0B22: 10 F7         djnz $0B1B
0B24: C9            ret

// B =  row index from 1 to 6. Identifies which row of aliens to check for player bullet collisions. 
// 1 = blue row of aliens closest to player// 6 = flagship row
0B25: 23            inc  hl                  // bump HL to point to PLAYER_BULLET_Y
0B26: 3A 0E 42      ld   a,($420E)           // read SWARM_SCROLL_VALUE
0B29: 96            sub  (hl)
0B2A: ED 44         neg
0B2C: 4F            ld   c,a
0B2D: E6 0F         and  $0F                 // mask in low nibble
0B2F: D6 02         sub  $02
0B31: FE 0B         cp   $0B
0B33: D0            ret  nc
0B34: 04            inc  b
0B35: 79            ld   a,c
0B36: E6 F0         and  $F0                 // mask in high nibble
0B38: 80            add  a,b
0B39: 0F            rrca
0B3A: 0F            rrca
0B3B: 0F            rrca
0B3C: 0F            rrca
0B3D: 5F            ld   e,a                
0B3E: 16 00         ld   d,$00               // DE is now an offset into the ALIEN_SWARM_FLAGS table
0B40: 21 00 41      ld   hl,$4100            // load HL with address of ALIEN_SWARM_FLAGS
0B43: 19            add  hl,de               // add offset to HL. Now HL points to a flag which determines if an alien is present
0B44: CB 46         bit  0,(hl)              // test flag. If bit 0 is set, our bullet has hit an alien. 
0B46: C8            ret  z                   // bit 0 is not set, we haven't shot an alien, so exit
0B47: 72            ld   (hl),d              // We've hit an alien! Clear flag to indicate alien is dead.
0B48: 16 01         ld   d,$01               // command id for DELETE_ALIEN_COMMAND
0B4A: 5D            ld   e,l                 // parameter: index of alien to delete from swarm
0B4B: CD F2 08      call $08F2               // call QUEUE_COMMAND 
0B4E: 7A            ld   a,d
0B4F: 32 0B 42      ld   ($420B),a           // set IS_PLAYER_BULLET_DONE flag to 1, so player can shoot again

// we'll use the misc entry in the INFLIGHT_ALIENS array to display our explosion as a sprite
0B52: 32 B1 42      ld   ($42B1),a           // set INFLIGHT_ALIEN.IsDying to 1
0B55: AF            xor  a
0B56: 32 B2 42      ld   ($42B2),a           // set INFLIGHT_ALIEN.StageOfLife to 0
0B59: 2A 09 42      ld   hl,($4209)          // read PLAYER_BULLET_X and PLAYER_BULLET_Y  in one go
0B5C: 22 B3 42      ld   ($42B3),hl          // set INFLIGHT_ALIEN.X and INFLIGHT_ALIEN.Y  to bullet coordinates
0B5F: 16 03         ld   d,$03               // command id for UPDATE_PLAYER_SCORE_COMMAND (see $08f2)
0B61: 7B            ld   a,e                 // read index of alien that was just killed
0B62: FE 50         cp   $50                 // was the alien killed in the bottom 3 ranks? (Blue aliens, most common type)
0B64: 38 0C         jr   c,$0B72             // if index is < $50 (128 decimal) then yes, its a blue alien, goto $0B72

// only get here if you've shot a higher-ranking alien
0B66: E6 70         and  $70                 // Mask out the column number of the killed alien from the index. 
// Now A is $50 (purple alien row),$60 (red row),$70 (flagship row)
0B68: 0F            rrca
0B69: 0F            rrca
0B6A: 0F            rrca
0B6B: 0F            rrca                     // Divide A by 16 decimal. 
0B6C: D6 04         sub  $04                 // Subtract 4 to compute parameter for UPDATE_PLAYER_SCORE_COMMAND  
0B6E: 5F            ld   e,a                 // set parameter for UPDATE_PLAYER_SCORE_COMMAND 
0B6F: C3 F2 08      jp   $08F2               // jump to QUEUE COMMAND. Player score will be updated.

// You've just shot a lowly blue alien. 
0B72: 1E 00         ld   e,$00               // parameter for UPDATE_PLAYER_SCORE_COMMAND - adds 30 points to player score
0B74: C3 F2 08      jp   $08F2               // jump to QUEUE COMMAND. Player score will be updated.


//
// Iterate through list of active enemy bullets and test if they have hit the player.
// 

HANDLE_PLAYER_TO_ENEMY_BULLET_COLLISION_DETECTION:
0B77: 3A 00 42      ld   a,($4200)           // read HAS_PLAYER_SPAWNED flag
0B7A: 0F            rrca                     // move bit 0 into carry
0B7B: D0            ret  nc                  // if carry is not set, then player has not spawned. Return.
0B7C: DD 21 60 42   ld   ix,$4260            // point IX to ENEMY_BULLETS_START
0B80: 11 05 00      ld   de,$0005            // sizeof(ENEMY_BULLET) struct
0B83: 06 0E         ld   b,$0E               // length of ENEMY_BULLETS array 
0B85: CD 8D 0B      call $0B8D               // call TEST_IF_ENEMY_BULLET_HIT_PLAYER
0B88: DD 19         add  ix,de
0B8A: 10 F9         djnz $0B85
0B8C: C9            ret


//
// Check if an enemy bullet hit the player's ship.
//
// Expects: 
// E = 5
// IX  = pointer to ENEMY_BULLET structure
//

TEST_IF_ENEMY_BULLET_HIT_PLAYER:
0B8D: DD CB 00 46   bit  0,(ix+$00)          // read ENEMY_BULLET.IsActive
0B91: C8            ret  z                   // return if bullet is not active

0B92: DD 7E 01      ld   a,(ix+$01)          // read ENEMY_BULLET.X coordinate 
0B95: C6 1F         add  a,$1F               // player ship is 32 pixels high.. 
0B97: 93            sub  e                   // subtract 5
0B98: 38 10         jr   c,$0BAA
0B9A: D6 09         sub  $09
0B9C: D0            ret  nc
0B9D: 3A 02 42      ld   a,($4202)           // read PLAYER_Y 
0BA0: DD 96 03      sub  (ix+$03)            // subtract ENEMY_BULLET.Y coordinate
0BA3: 83            add  a,e                 // add 5
0BA4: FE 0B         cp   $0B
0BA6: D0            ret  nc
0BA7: C3 B4 0B      jp   $0BB4               // bullet has hit player
0BAA: 3A 02 42      ld   a,($4202)           // read PLAYER_Y
0BAD: DD 96 03      sub  (ix+$03)            // subtract ENEMY_BULLET.Y coordinate
0BB0: C6 02         add  a,$02
0BB2: BB            cp   e
0BB3: D0            ret  nc

// Player's been hit.. deactivate enemy bullet and set hit flag.
0BB4: DD 36 00 00   ld   (ix+$00),$00        // clear ENEMY_BULLET.IsActive flag. 
0BB8: 3E 01         ld   a,$01
0BBA: 32 04 42      ld   ($4204),a           // set IS_PLAYER_HIT flag. Player will explode.          
0BBD: C9            ret



//
// This important routine is responsible for handling the enemy sprites in the game. 
// It reads the position, colour and animation frame of each item in the INFLIGHT_ALIENS array and 
// projects it into the relevant INFLIGHT_ALIEN_SPRITE of OBJRAM_BACK_BUF_SPRITES. 
//
// In plain English: the sprite back buffer is filled by this routine :) 
// 

HANDLE_INFLIGHT_ALIEN_SPRITE_UPDATE:
0BBE: 3A 18 40      ld   a,($4018)           // read DISPLAY_IS_COCKTAIL_P2
0BC1: 0F            rrca                     // move flag into carry
0BC2: 38 2E         jr   c,$0BF2             // if flag is set, goto $0BF2

0BC4: DD 21 B0 42   ld   ix,$42B0            // load IX with address of INFLIGHT_ALIENS
0BC8: FD 21 60 40   ld   iy,$4060            // load IY with address of OBJRAM_BACK_BUF_SPRITES

// for the first 3 alien sprites, their Y coordinates need to be offset 7 pixels vertically so that the hardware can render them correctly.
0BCC: 06 03         ld   b,$03               // number of sprites to set sprite state for
0BCE: 0E 07         ld   c,$07               // set pixel offset to 7
0BD0: CD 20 0C      call $0C20               // call SET_SPRITE_STATE               
0BD3: 11 20 00      ld   de,$0020            // sizeof (INFLIGHT_ALIEN)
0BD6: DD 19         add  ix,de               // bump IX to point to next alien entry
0BD8: 11 04 00      ld   de,$0004            // sizeof (INFLIGHT_ALIEN_SPRITE)
0BDB: FD 19         add  iy,de               // bump IY to point to next sprite entry in OBJRAM_BACK_BUF_SPRITES
0BDD: 10 F1         djnz $0BD0

// for the next 5 alien sprites, their Y coordinates need to be offset 8 pixels vertically.
0BDF: 06 05         ld   b,$05               // number of sprites to set sprite state for
0BE1: 0C            inc  c                   // adjust pixel offset to be 8
0BE2: CD 20 0C      call $0C20               // call SET_SPRITE_STATE
0BE5: 11 20 00      ld   de,$0020            // sizeof (INFLIGHT_ALIEN)
0BE8: DD 19         add  ix,de               // bump IX to point to next alien entry
0BEA: 11 04 00      ld   de,$0004            // sizeof (INFLIGHT_ALIEN_SPRITE)
0BED: FD 19         add  iy,de               // bump IY to point to next sprite entry in OBJRAM_BACK_BUF_SPRITES
0BEF: 10 F1         djnz $0BE2
0BF1: C9            ret

// called when display is cocktail. I'm not going to look at this routine until everything else is done...
0BF2: DD 21 B0 42   ld   ix,$42B0            // load IX with address of INFLIGHT_ALIENS
0BF6: FD 21 60 40   ld   iy,$4060            // load IY with address of OBJRAM_BACK_BUF_SPRITES
0BFA: 06 03         ld   b,$03
0BFC: 0E 09         ld   c,$09
0BFE: CD 20 0C      call $0C20               // call SET_SPRITE_STATE
0C01: 11 20 00      ld   de,$0020
0C04: DD 19         add  ix,de
0C06: 11 04 00      ld   de,$0004
0C09: FD 19         add  iy,de
0C0B: 10 F1         djnz $0BFE
0C0D: 06 05         ld   b,$05
0C0F: 0D            dec  c
0C10: CD 20 0C      call $0C20               // call SET_SPRITE_STATE
0C13: 11 20 00      ld   de,$0020
0C16: DD 19         add  ix,de
0C18: 11 04 00      ld   de,$0004
0C1B: FD 19         add  iy,de
0C1D: 10 F1         djnz $0C10
0C1F: C9            ret


//
// Extract the colour, position, animation frame information from an INFLIGHT_ALIEN structure
// and project it into a INFLIGHT_ALIEN_SPRITE.
//
// Expects:
// C = pixel adjustment for Y coordinate
// IX = pointer to INFLIGHT_ALIEN structure to extract information from
// IY = pointer to INFLIGHT_ALIEN_SPRITE structure to be filled
//

SET_SPRITE_STATE:
0C20: DD CB 00 46   bit  0,(ix+$00)          // test INFLIGHT_ALIEN.IsActive
0C24: CA 98 0C      jp   z,$0C98             // if alien is not active, goto SET_INACTIVE_OR_DYING_SPRITE_STATE
0C27: DD 7E 16      ld   a,(ix+$16)          // read INFLIGHT_ALIEN.Colour
0C2A: FD 77 02      ld   (iy+$02),a          // write to INFLIGHT_ALIEN_SPRITE.Colour
0C2D: DD 7E 03      ld   a,(ix+$03)          // read INFLIGHT_ALIEN.X
0C30: D6 08         sub  $08
0C32: FD 77 03      ld   (iy+$03),a          // write to INFLIGHT_ALIEN_SPRITE.X
0C35: DD 7E 04      ld   a,(ix+$04)          // read INFLIGHT_ALIEN.Y 
0C38: 2F            cpl                      // flip bits  
0C39: 91            sub  c                   // subtract pixel adjustment
0C3A: FD 77 00      ld   (iy+$00),a          // write to INFLIGHT_ALIEN_SPRITE.Y 

// Determine what way the alien is facing and set the sprite XFlip/YFlip/Code properties accordingly
//
// Important point to remember: non-flagship aliens are like bats. They hang upside down in the swarm.
// If you want to see what the sprites look like before being flipped, refer to my sprite grabs @ 
// http://seanriddle.com/galaxiansprites.html

0C3D: DD 7E 05      ld   a,(ix+$05)          // read INFLIGHT_ALIEN.AnimationFrame
0C40: A7            and  a                   // set flags 
0C41: F2 58 0C      jp   p,$0C58

0C44: FE FA         cp   $FA                 // compare to -6 
0C46: FA 82 0C      jp   m,$0C82

// alien is between an angle of 90 and 180 degrees (as player sees it)
0C49: 2F            cpl
0C4A: C6 12         add  a,$12
0C4C: F6 40         or   $40                 // set X-Flip bit for sprite
0C4E: DD 86 0F      add  a,(ix+$0f)          // add in INFLIGHT_ALIEN.AnimFrameStartCode
0C51: FD 77 01      ld   (iy+$01),a          // write to INFLIGHT_ALIEN_SPRITE.Code
0C54: FD 34 03      inc  (iy+$03)            // increment INFLIGHT_ALIEN_SPRITE.X
0C57: C9            ret

0C58: FE 06         cp   $06
0C5A: F2 6E 0C      jp   p,$0C6E

// alien is between an angle of 180 and 270 degrees (as player sees it)
0C5D: C6 11         add  a,$11
0C5F: F6 C0         or   $C0                 // set X-Flip and Y-Flip bits for sprite
0C61: DD 86 0F      add  a,(ix+$0f)          // add in INFLIGHT_ALIEN.AnimFrameStartCode
0C64: FD 77 01      ld   (iy+$01),a          // write to INFLIGHT_ALIEN_SPRITE.Code
0C67: FD 34 03      inc  (iy+$03)            // increment INFLIGHT_ALIEN_SPRITE.X
0C6A: FD 34 00      inc  (iy+$00)            // increment INFLIGHT_ALIEN_SPRITE.Y 
0C6D: C9            ret

0C6E: FE 0C         cp   $0C
0C70: F2 90 0C      jp   p,$0C90

// alien is between an angle of 270-360 degrees (as player sees it)
0C73: 2F            cpl
0C74: C6 1E         add  a,$1E
0C76: F6 80         or   $80                  // set Y-Flip bit for sprite
0C78: DD 86 0F      add  a,(ix+$0f)           // add in INFLIGHT_ALIEN.AnimFrameStartCode
0C7B: FD 77 01      ld   (iy+$01),a           // write to INFLIGHT_ALIEN_SPRITE.Code
0C7E: FD 34 00      inc  (iy+$00)             // increment INFLIGHT_ALIEN_SPRITE.Y 
0C81: C9            ret

0C82: FE F4         cp   $F4
0C84: FA 94 0C      jp   m,$0C94

// alien is between an angle of 0-90 degrees (as player sees it)
0C87: C6 1D         add  a,$1D
0C89: DD 86 0F      add  a,(ix+$0f)           // add in INFLIGHT_ALIEN.AnimFrameStartCode
0C8C: FD 77 01      ld   (iy+$01),a           // write to INFLIGHT_ALIEN_SPRITE.Code
0C8F: C9            ret

0C90: D6 18         sub  $18
0C92: 18 AC         jr   $0C40

0C94: C6 18         add  a,$18
0C96: 18 A8         jr   $0C40


//
// Jumped to from SET_SPRITE_STATE when the INFLIGHT_ALIEN is inactive or dying.
//
// Expects:
// C = pixel adjustment for Y coordinate
// IX = pointer to INFLIGHT_ALIEN structure
// IY = pointer to INFLIGHT_ALIEN_SPRITE structure

SET_INACTIVE_OR_DYING_SPRITE_STATE:
0C98: DD CB 01 46   bit  0,(ix+$01)          // test INFLIGHT_ALIEN.IsDying flag
0C9C: CA BA 0C      jp   z,$0CBA             // if the alien has finally expired, goto $0CBA

// alien is dying
0C9F: FD 36 02 07   ld   (iy+$02),$07        // set INFLIGHT_ALIEN_SPRITE.Colour
0CA3: DD 7E 03      ld   a,(ix+$03)          // read INFLIGHT_ALIEN.X
0CA6: D6 08         sub  $08
0CA8: FD 77 03      ld   (iy+$03),a          // set INFLIGHT_ALIEN_SPRITE.X
0CAB: DD 7E 04      ld   a,(ix+$04)          // read INFLIGHT_ALIEN.Y 
0CAE: 2F            cpl
0CAF: 91            sub  c                   // subtract pixel adjustment value
0CB0: FD 77 00      ld   (iy+$00),a          // set INFLIGHT_ALIEN_SPRITE.Y 
0CB3: DD 7E 12      ld   a,(ix+$12)          // read INFLIGHT_ALIEN.DyingAnimFrameCode
0CB6: FD 77 01      ld   (iy+$01),a          // set INFLIGHT_ALIEN_SPRITE.Code 
0CB9: C9            ret

// This alien has died. Move sprite off-screen
0CBA: FD 36 03 F8   ld   (iy+$03),$F8        // set INFLIGHT_ALIEN_SPRITE.X to value offscreen
0CBE: FD 36 00 F8   ld   (iy+$00),$F8        // set INFLIGHT_ALIEN_SPRITE.Y to value offscreen
0CC2: C9            ret



//
// This routine is responsible for processing all 8 elements in the INFLIGHT_ALIENS array. 
//

HANDLE_INFLIGHT_ALIENS:
0CC3: DD 21 B0 42   ld   ix,$42B0            // load IX with address of INFLIGHT_ALIENS
0CC7: 11 20 00      ld   de,$0020            // sizeof(INFLIGHT_ALIEN)
0CCA: 06 08         ld   b,$08               // 1 misc + 7 attacking aliens to process
0CCC: D9            exx
0CCD: CD D6 0C      call $0CD6               // call HANDLE_INFLIGHT_ALIEN_STAGE_OF_LIFE
0CD0: D9            exx
0CD1: DD 19         add  ix,de               // bump IX to point to next INFLIGHT_ALIEN structure
0CD3: 10 F7         djnz $0CCC               // do while b!=0
0CD5: C9            ret




//
// Like humans, inflight aliens go through stages of life. They leave home, attack humans, maybe do a loop the loop,
// then (maybe) return home. Just like we do!
// 
// This routine is used to invoke actions appropriate for the alien's stage of life.
//
// Expects:
// IX = pointer to INFLIGHT_ALIEN structure.
//

HANDLE_INFLIGHT_ALIEN_STAGE_OF_LIFE:
0CD6: DD CB 01 46   bit  0,(ix+$01)          // test INFLIGHT_ALIEN.IsDying flag
0CDA: C2 E4 10      jp   nz,$10E4            // if alien is dying, goto HANDLE_INFLIGHT_ALIEN_DYING
0CDD: DD CB 00 46   bit  0,(ix+$00)          // test INFLIGHT_ALIEN.IsActive flag 
0CE1: C8            ret  z                   // exit if not active

// We need to determine what stage of life the inflight alien is at, then call the appropriate function to
// tell it how to behave. 

0CE2: DD 7E 02      ld   a,(ix+$02)          // read INFLIGHT_ALIEN.StageOfLife 
0CE5: EF            rst  $28                 // jump to code @ $0CE6 + (A*2)
0CE6: 
      06 0D         // $0D06                  // INFLIGHT_ALIEN_PACKS_BAGS
      71 0D         // $0D71                  // INFLIGHT_ALIEN_FLIES_IN_ARC
      D1 0D         // $0DD1                  // INFLIGHT_ALIEN_READY_TO_ATTACK
      2B 0E         // $0E2B                  // INFLIGHT_ALIEN_ATTACKING_PLAYER
      6B 0E         // $0E6B                  // INFLIGHT_ALIEN_NEAR_BOTTOM_OF_SCREEN
      99 0E         // $0E99                  // INFLIGHT_ALIEN_REACHED_BOTTOM_OF_SCREEN
      07 0F         // $0F07                  // INFLIGHT_ALIEN_RETURNING_TO_SWARM
      3C 0F         // $0F3C                  // INFLIGHT_ALIEN_CONTINUING_ATTACK_RUN_FROM_TOP_OF_SCREEN 
      66 0F         // $0F66                  // INFLIGHT_ALIEN_FULL_SPEED_CHARGE 
      AF 0F         // $0FAF                  // INFLIGHT_ALIEN_ATTACKING_PLAYER_AGGRESSIVELY
      1F 10         // $101F                  // INFLIGHT_ALIEN_LOOP_THE_LOOP
      8E 10         // $108E                  // INFLIGHT_ALIEN_COMPLETE_LOOP
      91 10         // $1091                  // INFLIGHT_ALIEN_UNKNOWN_1091
      9B 10         // $109B                  // INFLIGHT_ALIEN_CONVOY_CHARGER_SET_COLOUR_POS_ANIM
      C2 10         // $10C2                  // INFLIGHT_ALIEN_CONVOY_CHARGER_START_SCROLL  
      D8 10         // $10D8                  // INFLIGHT_ALIEN_CONVOY_CHARGER_DO_SCROLL



//
// An alien's just about to break away from the swarm. It's leaving home! 
// Before it can do so, we need to set up an INFLIGHT_ALIEN structure with defaults. 
//
// Expects:
// IX = pointer to INFLIGHT_ALIEN structure
//

INFLIGHT_ALIEN_PACKS_BAGS:
0D06: DD 36 17 00   ld   (ix+$17),$00        // clear INFLIGHT_ALIEN.SortieCount 
0D0A: 3E 01         ld   a,$01
0D0C: 32 C2 41      ld   ($41C2),a           // set ENABLE_ALIEN_ATTACK_SOUND to 1.
0D0F: CD 47 11      call $1147               // call SET_INFLIGHT_ALIEN_START_POSITION
0D12: DD 5E 07      ld   e,(ix+$07)          // set command parameter to INFLIGHT_ALIEN.IndexInSwarm
0D15: 16 01         ld   d,$01               // command: DELETE_ALIEN_COMMAND
0D17: CD F2 08      call $08F2               // call QUEUE_COMMAND
0D1A: 7B            ld   a,e                 // load A with INFLIGHT_ALIEN.IndexInSwarm
0D1B: E6 70         and  $70                 // keep the row start, remove the column number
0D1D: 21 D1 1D      ld   hl,$1DD1
0D20: 0F            rrca                     // divide the row offset...
0D21: 0F            rrca
0D22: 0F            rrca                     // .. by 8.
0D23: 5F            ld   e,a
0D24: 16 00         ld   d,$00               // Extend A into DE
0D26: 19            add  hl,de               // HL = $1DD1 + (row number of alien /8)
0D27: 7E            ld   a,(hl)
0D28: DD 77 16      ld   (ix+$16),a          // set INFLIGHT_ALIEN.Colour

0D2B: 23            inc  hl
0D2C: 7E            ld   a,(hl)
0D2D: DD 77 18      ld   (ix+$18),a          // set INFLIGHT_ALIEN.Speed

0D30: 7B            ld   a,e
0D31: FE 0E         cp   $0E                 // flagship?
0D33: 28 23         jr   z,$0D58             // yes, goto $0D58

0D35: DD 36 0F 00   ld   (ix+$0f),$00        // set INFLIGHT_ALIEN.AnimFrameStartCode
0D39: DD 36 10 03   ld   (ix+$10),$03        // set INFLIGHT_ALIEN.TempCounter1 to speed of animation (higher number = slower)
0D3D: DD 36 11 0C   ld   (ix+$11),$0C        // set INFLIGHT_ALIEN.TempCounter2 to total number of animation frames 
0D41: DD 36 13 00   ld   (ix+$13),$00        // set INFLIGHT_ALIEN.ArcTableLsb
0D45: DD 34 02      inc  (ix+$02)            // set INFLIGHT_ALIEN.StageOfLife to INFLIGHT_ALIEN_FLIES_IN_ARC

0D48: DD CB 06 46   bit  0,(ix+$06)          // test INFLIGHT_ALIEN.ArcClockwise
0D4C: 20 05         jr   nz,$0D53            // if alien will be facing right when it breaks away from swarm, goto $0D53
0D4E: DD 36 05 0C   ld   (ix+$05),$0C        // set INFLIGHT_ALIEN.AnimationFrame
0D52: C9            ret

0D53: DD 36 05 F4   ld   (ix+$05),$F4        // set INFLIGHT_ALIEN.AnimationFrame
0D57: C9            ret

// This code is called for flagships. We need to count how many escorts we have.
0D58: DD 36 0F 18   ld   (ix+$0f),$18        // set INFLIGHT_ALIEN.AnimFrameStartCode
0D5C: AF            xor  a
0D5D: DD CB 20 46   bit  0,(ix+$20)          // test if we have an escort
0D61: 28 01         jr   z,$0D64             // no, goto $0D64
0D63: 3C            inc  a                   // increment escort count 
0D64: DD CB 40 46   bit  0,(ix+$40)          // test if we have an escort
0D68: 28 01         jr   z,$0D6B             // no, goto $0D6B
0D6A: 3C            inc  a                   // increment escort count
0D6B: 32 2A 42      ld   ($422A),a           // set FLAGSHIP_ESCORT_COUNT
0D6E: C3 39 0D      jp   $0D39               // finalise setting up flagship



//
// This function is used to animate an inflight alien flying in a 90 degree arc. 
// It is called when an alien is breaking off from the swarm to attack the player, 
// or when it is completing the last 90 degrees of a 360 degree loop the loop. 
// As soon as the arc is complete, the alien's stage of life is set to
// INFLIGHT_ALIEN_READY_TO_ATTACK.
//
// Expects:
// IX = pointer to INFLIGHT_ALIEN that is breaking away from swarm.
//

INFLIGHT_ALIEN_FLIES_IN_ARC:
0D71: DD 6E 13      ld   l,(ix+$13)          // read INFLIGHT_ALIEN.ArcTableLsb
0D74: 26 1E         ld   h,$1E               // Now HL points to an entry in INFLIGHT_ALIEN_ARC_TABLE at $1E00. 
0D76: DD 7E 03      ld   a,(ix+$03)          // read INFLIGHT_ALIEN.X 
0D79: 86            add  a,(hl)              // add in X delta from table
0D7A: DD 77 03      ld   (ix+$03),a          // update INFLIGHT_ALIEN.X
0D7D: 2C            inc  l                   // bump HL to Y coordinate in table 
0D7E: DD CB 06 46   bit  0,(ix+$06)          // test INFLIGHT_ALIEN.ArcClockwise
0D82: 20 24         jr   nz,$0DA8            // if alien is facing right, goto $0DA8

// alien that is leaving swarm to attack player will arc up and left.
// HL = pointer to table defining arc (see $1E00 for table layout)
0D84: DD 7E 04      ld   a,(ix+$04)          // load A with INFLIGHT_ALIEN.Y 
0D87: 86            add  a,(hl)              // add in Y delta from table                       
0D88: DD 77 04      ld   (ix+$04),a          // update INFLIGHT_ALIEN.Y 
0D8B: C6 07         add  a,$07
0D8D: FE 0E         cp   $0E                 // is the alien off-screen?
0D8F: 38 3B         jr   c,$0DCC             // if A< #$0E, its gone off screen, so make alien return to swarm from top of screen.
0D91: 2C            inc  l                   // bump HL to point to next X,Y coordinate pair in table
0D92: DD 75 13      ld   (ix+$13),l          // and update INFLIGHT_ALIEN.ArcTableLsb
// Tempcounter1 = delay before changing animation frame
// Tempcounter2 = number of animation frames left to do 
0D95: DD 35 10      dec  (ix+$10)            // decrement INFLIGHT_ALIEN.TempCounter1
0D98: C0            ret  nz
0D99: DD 36 10 04   ld   (ix+$10),$04        // reset INFLIGHT_ALIEN.TempCounter1
0D9D: DD 35 05      dec  (ix+$05)            // update INFLIGHT_ALIEN.AnimationFrame to rotate the alien left
0DA0: DD 35 11      dec  (ix+$11)            // decrement INFLIGHT_ALIEN.TempCounter2 
0DA3: C0            ret  nz                  // if we've not done all of the animation frames, exit

// OK, we've done all of the animation frames. The alien's ready to attack the player.
0DA4: DD 34 02      inc  (ix+$02)            // set stage of alien's life to INFLIGHT_ALIEN_READY_TO_ATTACK
0DA7: C9            ret

// alien that is leaving swarm to attack player is arcing up and right
// HL = pointer to table defining arc
// IX = pointer to INFLIGHT_ALIEN structure
0DA8: DD 7E 04      ld   a,(ix+$04)          // read INFLIGHT_ALIEN.Y 
0DAB: 96            sub  (hl)                // read Y delta from table and subtract from INFLIGHT_ALIEN.Y 
0DAC: DD 77 04      ld   (ix+$04),a          // update INFLIGHT_ALIEN.Y 
0DAF: C6 07         add  a,$07
0DB1: FE 0E         cp   $0E                 // is the alien off-screen?
0DB3: 38 17         jr   c,$0DCC             // if A < #$0E, its gone off screen, so make alien return to swarm from top of screen. 
0DB5: 2C            inc  l                   // bump HL to point to next X,Y coordinate pair in table
0DB6: DD 75 13      ld   (ix+$13),l          // and update INFLIGHT_ALIEN.ArcTableLsb
// Tempcounter1 = delay before changing animation frame
// Tempcounter2 = number of animation frames left to do 
0DB9: DD 35 10      dec  (ix+$10)            // decrement INFLIGHT_ALIEN.TempCounter1
0DBC: C0            ret  nz
0DBD: DD 36 10 04   ld   (ix+$10),$04        // reset INFLIGHT_ALIEN.TempCounter1
0DC1: DD 34 05      inc  (ix+$05)            // update INFLIGHT_ALIEN.AnimationFrame to rotate the alien right
0DC4: DD 35 11      dec  (ix+$11)            // decrement INFLIGHT_ALIEN.TempCounter2
0DC7: C0            ret  nz                  // if we've not done all of the animation frames, exit

// OK, we've done all of the animation frames. The alien's ready to attack the player.
0DC8: DD 34 02      inc  (ix+$02)            // move to next stage of alien's life
0DCB: C9            ret                 

// if we get here, an alien leaving the swarm has gone offscreen. It will return to the swarm from the top of the screen.
0DCC: DD 36 02 05   ld   (ix+$02),$05        // set INFLIGHT_ALIEN.StageOfLife 
0DD0: C9            ret



//
// An alien that has just completed an arc animation (see docs @ $0D71 and $101F) is now ready to attack the player. 
//
// Expects:
// IX = pointer to INFLIGHT_ALIEN that will attack
//

INFLIGHT_ALIEN_READY_TO_ATTACK:
0DD1: DD 34 03      inc  (ix+$03)            // increment INFLIGHT_ALIEN.X
0DD4: DD 7E 07      ld   a,(ix+$07)          // read INFLIGHT_ALIEN.IndexInSwarm
0DD7: E6 70         and  $70                 // keep the row, remove the column
0DD9: FE 60         cp   $60                 // is this a red alien?
0DDB: 28 43         jr   z,$0E20             // yes, goto $0E20

INFLIGHT_ALIEN_DEFINE_FLIGHTPATH:
0DDD: 3A 02 42      ld   a,($4202)           // read PLAYER_Y 
0DE0: 47            ld   b,a
0DE1: DD 7E 04      ld   a,(ix+$04)          // read INFLIGHT_ALIEN.Y 
0DE4: 90            sub  b                   // A = INFLIGHT_ALIEN.Y  - PLAYER_Y
0DE5: 38 28         jr   c,$0E0F             // if alien is to right of player, goto $0E0F

// alien is to left of player
// A = signed number representing distance in pixels between alien Y and player Y. 
0DE7: 1F            rra                      // divide distance by 2     
0DE8: C6 10         add  a,$10               // add $10 (16 decimal) to product
// clamp A between $30 and $70
0DEA: FE 30         cp   $30                 // compare to 48 (decimal)
0DEC: 30 02         jr   nc,$0DF0            // if A>=48 goto $0DF0
0DEE: 3E 30         ld   a,$30
0DF0: FE 70         cp   $70                 // compare to 112 (decimal)  NB: 112 is half the screen height in pixels
0DF2: 38 02         jr   c,$0DF6
0DF4: 3E 70         ld   a,$70

// PivotYValue is a Y coordinate to pivot around. You could think of it like the "origin" Y coordinate. 
// PivotYValueAdd is a delta (offset) to add to PivotYValue to produce the correct Y coordinate of the alien.
//
// PivotYValueAdd will increment if the player is to the left of the alien when it leaves the swarm,
// or decrement if the player is to the right. 

0DF6: DD 77 19      ld   (ix+$19),a          // set INFLIGHT_ALIEN.PivotYValueAdd
0DF9: DD 96 04      sub  (ix+$04)            // subtract INFLIGHT_ALIEN.Y 
0DFC: ED 44         neg
0DFE: DD 77 09      ld   (ix+$09),a          // set INFLIGHT_ALIEN.PivotYValue. Now PivotYValue + PivotYValueAdd = INFLIGHT_ALIEN.Y
0E01: AF            xor  a
0E02: DD 77 1A      ld   (ix+$1a),a
0E05: DD 77 1B      ld   (ix+$1b),a
0E08: DD 77 1C      ld   (ix+$1c),a

0E0B: DD 34 02      inc  (ix+$02)             // set stage of life to INFLIGHT_ALIEN_ATTACKING_PLAYER or INFLIGHT_ALIEN_ATTACKING_PLAYER_AGGRESSIVELY
0E0E: C9            ret

// alien is to right of player
// A = signed number representing distance in pixels between alien and player. 
0E0F: 1F            rra                       // perform a shift right, with sign bit preserved
0E10: D6 10         sub  $10
// clamp A between -48 and -112 decimal
0E12: FE D0         cp   $D0                  // compare to -48 (decimal)
0E14: 38 02         jr   c,$0E18
0E16: 3E D0         ld   a,$D0             
0E18: FE 90         cp   $90                  // compare to -112 (decimal)  NB: 112 is half the screen height in pixels
0E1A: 30 DA         jr   nc,$0DF6
0E1C: 3E 90         ld   a,$90
0E1E: 18 D6         jr   $0DF6


0E20: 3A D0 42      ld   a,($42D0)           // address of INFLIGHT_ALIENS[1].IsActive
0E23: 0F            rrca                     // move flag into carry
0E24: 30 B7         jr   nc,$0DDD            // if not set then we are not part of a convoy, goto INFLIGHT_ALIEN_DEFINE_FLIGHTPATH

// make the alien accompany the flagship as part of a convoy. The PivotYValueAdd of the alien is the same as the flagship,
// so it will fly the same path.
0E26: 3A E9 42      ld   a,($42E9)           // read flagship INFLIGHT_ALIENS[1].PivotYValueAdd  
0E29: 18 CB         jr   $0DF6


//
// This is probably the most important routine for the INFLIGHT_ALIEN. 
//
// It is responsible for making an INFLIGHT_ALIEN fly down the screen, dropping bombs when it can.
//
// Expects:
// IX = pointer to INFLIGHT_ALIEN structure
//

INFLIGHT_ALIEN_ATTACKING_PLAYER:
0E2B: DD 34 03      inc  (ix+$03)            // increment INFLIGHT_ALIEN.X 
0E2E: CD 6B 11      call $116B               // call UPDATE_INFLIGHT_ALIEN_YADD
0E31: DD 7E 09      ld   a,(ix+$09)          // load A with INFLIGHT_ALIEN.PivotYValue
0E34: DD 86 19      add  a,(ix+$19)          // add in INFLIGHT_ALIEN.PivotYValueAdd to produce a Y coordinate                                                   
0E37: DD 77 04      ld   (ix+$04),a          // write to INFLIGHT_ALIEN.Y 
0E3A: C6 07         add  a,$07
0E3C: FE 0E         cp   $0E
0E3E: 38 24         jr   c,$0E64             // if the alien has gone off the side of the screen, return to swarm
0E40: DD 7E 03      ld   a,(ix+$03)          // load A with INFLIGHT_ALIEN.X
0E43: C6 48         add  a,$48
0E45: 38 20         jr   c,$0E67             // if the alien is nearing the bottom of the screen, speed it up!
0E47: 3A 00 42      ld   a,($4200)           // read HAS_PLAYER_SPAWNED
0E4A: 0F            rrca                     // move flag into carry
0E4B: D0            ret  nc                  // return if player has not spawned
0E4C: CD B0 11      call $11B0               // call CALCULATE_INFLIGHT_ALIEN_LOOKAT_ANIM_FRAME

// alien won't shoot at you if a flagship has been hit
0E4F: 3A 2B 42      ld   a,($422B)           // read IS_FLAGSHIP_HIT
0E52: 0F            rrca                     // move flag into carry
0E53: D8            ret  c                   // return if flagship was hit

// Can this alien start shooting at you?
//
// code from $0E54-0E63 is akin to:
//
// byte yToCheck = INFLIGHT_ALIEN.X//
// for (byte l=0// l<INFLIGHT_ALIEN_SHOOT_RANGE_MUL//l++)
// {
//     if (yToCheck == INFLIGHT_ALIEN_SHOOT_EXACT_X)
//        goto TRY SPAWN_ENEMY_BULLET//
//     else
//        yToCheck+=0x19//
// }
//

0E54: 2A 13 42      ld   hl,($4213)          // get INFLIGHT_ALIEN_SHOOT_EXACT_X into H and INFLIGHT_ALIEN_SHOOT_RANGE_MUL into L
0E57: DD 7E 03      ld   a,(ix+$03)          // read INFLIGHT_ALIEN.X

0E5A: BC            cp   h                   // compare A to INFLIGHT_ALIEN_SHOOT_EXACT_X 
0E5B: CA E0 11      jp   z,$11E0             // if equal, jump to TRY_SPAWN_ENEMY_BULLET
0E5E: C6 19         add  a,$19               // add $19 (25 decimal) to A
0E60: 2D            dec  l                   // and try again...
0E61: 20 F7         jr   nz,$0E5A            // until L is 0.
0E63: C9            ret


// If only one of these INCs are called (see $0E45), INFLIGHT_ALIEN.StageOfLife will be set to INFLIGHT_ALIEN_NEAR_BOTTOM_OF_SCREEN.
// If both these INCs are called (see $0E3E), set INFLIGHT_ALIEN.StageOfLife to INFLIGHT_ALIEN_REACHED_BOTTOM_OF_SCREEN. 
0E64: DD 34 02      inc  (ix+$02)      
0E67: DD 34 02      inc  (ix+$02)
0E6A: C9            ret


//
// When an alien is close to the horizontal plane where the player resides, it speeds up to zoom by (or into) the player.
//
// Expects:
// IX = pointer to INFLIGHT_ALIEN structure
//

INFLIGHT_ALIEN_NEAR_BOTTOM_OF_SCREEN:
0E6B: 3A 5F 42      ld   a,($425F)           // read TIMING_VARIABLE
0E6E: E6 01         and  $01                 // ..now A is either 0 or 1.
0E70: 3C            inc  a                   // ..now A is either 1 or 2. 
0E71: DD 86 03      add  a,(ix+$03)          // Add either 1 or 2 pixels to INFLIGHT_ALIEN.X
0E74: DD 77 03      ld   (ix+$03),a          // and update INFLIGHT_ALIEN.X
0E77: D6 06         sub  $06
0E79: FE 03         cp   $03                 // has alien gone off the bottom of the screen?
0E7B: 38 18         jr   c,$0E95             // yes, goto $0E95

0E7D: CD 6B 11      call $116B               // call UPDATE_INFLIGHT_ALIEN_YADD 
0E80: DD 7E 19      ld   a,(ix+$19)          // read INFLIGHT_ALIEN.PivotYValueAdd        
0E83: A7            and  a                   // set flags - we are interested if its a minus value
0E84: FA 90 0E      jp   m,$0E90             // if the PivotYValueAdd is a negative value, goto $0E90

0E87: DD 86 09      add  a,(ix+$09)          // add INFLIGHT_ALIEN.PivotYValue 
0E8A: 38 09         jr   c,$0E95             // carry flag set if alien has gone off side of screen,  goto $0E95

0E8C: DD 77 04      ld   (ix+$04),a          // set INFLIGHT_ALIEN.Y 
0E8F: C9            ret

0E90: DD 86 09      add  a,(ix+$09)          // add INFLIGHT_ALIEN.PivotYValue
0E93: 38 F7         jr   c,$0E8C

// alien's went off the bottom or the side of the screen. 
0E95: DD 34 02      inc  (ix+$02)            // now call INFLIGHT_ALIEN_REACHED_BOTTOM_OF_SCREEN stage of life.
0E98: C9            ret


//
// An inflight alien has flown past the player and left the bottom of the visible screen. 
// 
//
// If the alien is not a flagship, it will always return to the top of the screen.
// Then, its behaviour is determined by flag state:
// 
//    If the HAS_PLAYER_SPAWNED flag is clear, the alien will rejoin the swarm. 
//
//    If both of the HAVE_AGGRESSIVE_ALIENS and HAVE_NO_BLUE_OR_PURPLE_ALIENS flags are clear, 
//    the alien will rejoin the swarm.
//
//    Otherwise, if the criteria above is not satisfied, the alien will keep attacking the player.  
//    
//        
// If the alien is a flagship, then the rules described @ $0EDA (INFLIGHT_ALIEN_FLAGSHIP_REACHED_BOTTOM_OF_SCREEN) apply. 
//
// Expects:
// IX = pointer to INFLIGHT_ALIEN structure
//

INFLIGHT_ALIEN_REACHED_BOTTOM_OF_SCREEN:
0E99: DD 36 03 08   ld   (ix+$03),$08        // set INFLIGHT_ALIEN.X to position at very top of screen
0E9D: DD 34 17      inc  (ix+$17)            // increment INFLIGHT_ALIEN.SortieCount
0EA0: DD 36 05 00   ld   (ix+$05),$00        // clear INFLIGHT_ALIEN.AnimationFrame

// what type of alien are we dealing with?
0EA4: DD 7E 07      ld   a,(ix+$07)          // read INFLIGHT_ALIEN.IndexInSwarm  
0EA7: E6 70         and  $70                 // remove the column number from the index, keep the row
0EA9: FE 70         cp   $70                 // is this alien a flagship?
0EAB: 28 2D         jr   z,$0EDA             // yes, goto INFLIGHT_ALIEN_FLAGSHIP_REACHED_BOTTOM_OF_SCREEN

//if the player has not spawned, the alien will return to the swarm.
0EAD: 3A 00 42      ld   a,($4200)           // read HAS_PLAYER_SPAWNED
0EB0: 0F            rrca                     // move flag into carry
0EB1: 30 23         jr   nc,$0ED6            // if player has not spawned yet, goto $0ED6 - aliens return to swarm

//  if HAVE_AGGRESSIVE_ALIENS OR HAVE_NO_BLUE_OR_PURPLE_ALIENS flags are set, the alien will keep attacking (see $0EBF).
//  otherwise the alien returns to the swarm (see $0ED3 and $0F07)
0EB3: 3A 24 42      ld   a,($4224)           // read HAVE_AGGRESSIVE_ALIENS flag
0EB6: A7            and  a                   // test flag
0EB7: 20 06         jr   nz,$0EBF            // if aliens are aggressive, make alien reappear at top of screen, keep attacking 
0EB9: 3A 21 42      ld   a,($4221)           // read HAVE_NO_BLUE_OR_PURPLE_ALIENS
0EBC: A7            and  a                   // test flag             
0EBD: 28 17         jr   z,$0ED6             // if we do have any blue or purple aliens, goto $0ED6 - aliens return to swarm

// alien reappears at top of screen and will keep attacking - it will not return to swarm. 
// add some unpredictability to where it reappears, so that player can't wait for it and shoot it easily
0EBF: DD 7E 04      ld   a,(ix+$04)          // read INFLIGHT_ALIEN.Y 
0EC2: 1F            rra                      // divide by 2 (don't worry about carry, it was cleared by AND above)
0EC3: 4F            ld   c,a                 // preserve in C              
0EC4: CD 3C 00      call $003C               // call GENERATE_RANDOM_NUMBER
0EC7: E6 1F         and  $1F                 // ensure random number is between 0..31 decimal
0EC9: 81            add  a,c                 
0ECA: C6 20         add  a,$20               
0ECC: DD 77 04      ld   (ix+$04),a          // set INFLIGHT_ALIEN.Y   
0ECF: DD 36 10 28   ld   (ix+$10),$28        // set INFLIGHT_ALIEN.TempCounter1 for INFLIGHT_ALIEN_UNKNOWN_OF3C to use.

// if both of these incs are called, the stage of life will be set to INFLIGHT_ALIEN_CONTINUING_ATTACK_RUN_FROM_TOP_OF_SCREEN. 
// if only the inc @ $0ED6 is invoked (see $0EB1), then the stage of life will be set to INFLIGHT_ALIEN_RETURNING_TO_SWARM.
0ED3: DD 34 02      inc  (ix+$02)            // increment INFLIGHT_ALIEN.StageOfLife
0ED6: DD 34 02      inc  (ix+$02)            // increment INFLIGHT_ALIEN.StageOfLife
0ED9: C9            ret


//
// A flagship has gone off screen.
//
// If the flagship had an escort, it will return to the top of the screen to fight again.
// If the flagship had no escort, it will flee the level. 
// A maximum of 2 fleeing flagships can be carried over to the next level.
//
// Expects:
// IX = pointer to INFLIGHT_ALIEN structure
//

INFLIGHT_ALIEN_FLAGSHIP_REACHED_BOTTOM_OF_SCREEN:
0EDA: 3A 2A 42      ld   a,($422A)           // read FLAGSHIP_ESCORT_COUNT
0EDD: A7            and  a                   // test if flagship actually had any escort!
0EDE: 20 12         jr   nz,$0EF2            // if flagship has escort, goto INFLIGHT_ALIEN_COUNT_FLAGSHIP_ESCORTS

// This flagship has no escort. It has escaped the level. 
// Deactivate the INFLIGHT_ALIEN record, and check if this flagship can be carried over to the next wave.
0EE0: DD 36 00 00   ld   (ix+$00),$00        // reset INFLIGHT_ALIEN.IsActive
0EE4: 3A 1E 42      ld   a,($421E)           // read FLAGSHIP_SURVIVOR_COUNT
0EE7: 3C            inc  a                   // add another one to the survivor count!
0EE8: FE 03         cp   $03                 // have we got 3 surviving flagships?
0EEA: 38 02         jr   c,$0EEE             // if we have less than 3, that's OK, goto $0EEE

// We seem to have 3 flagships but only 2 flagships are allowed to be carried over...
0EEC: 3E 02         ld   a,$02               // clamp surviving flagship count to 2.

0EEE: 32 1E 42      ld   ($421E),a           // set FLAGSHIP_SURVIVOR_COUNT
0EF1: C9            ret

// count how many aliens were escorting the flagship. 
INFLIGHT_ALIEN_COUNT_FLAGSHIP_ESCORTS:
0EF2: AF            xor  a
0EF3: DD CB 20 46   bit  0,(ix+$20)          // test IsActive flag of first escort  
0EF7: 28 01         jr   z,$0EFA             // 
0EF9: 3C            inc  a                   // increment escort count
0EFA: DD CB 40 46   bit  0,(ix+$40)          // test IsActive flag of second escort
0EFE: 28 01         jr   z,$0F01
0F00: 3C            inc  a                   // increment escort count
0F01: 32 2A 42      ld   ($422A),a           // set FLAGSHIP_ESCORT_COUNT
0F04: C3 AD 0E      jp   $0EAD               // make flagship reappear at top of screen



//
// An alien has either flown off the side or the bottom of the screen, and is returning to the swarm.
// 
// Expects:
// IX = pointer to INFLIGHT_ALIEN structure           
//

INFLIGHT_ALIEN_RETURNING_TO_SWARM:
0F07: DD 46 03      ld   b,(ix+$03)          // keep copy of INFLIGHT_ALIEN.X in B as SET_INFLIGHT_ALIEN_START_POSITION changes it 
0F0A: 04            inc  b                   
0F0B: CD 47 11      call $1147               // call SET_INFLIGHT_ALIEN_START_POSITION to determine where alien needs to go  

// INFLIGHT_ALIEN.Y  and INFLIGHT_ALIEN.X have been changed by SET_INFLIGHT_ALIEN_START_POSITION
0F0E: DD 7E 03      ld   a,(ix+$03)          // A = destination INFLIGHT_ALIEN.X
0F11: DD 70 03      ld   (ix+$03),b          // restore INFLIGHT_ALIEN.X back to what it was before
0F14: 90            sub  b                   // OK, how far away is this alien from where it wants to be?
0F15: 28 14         jr   z,$0F2B             // distance is zero, it's got where it wants to be, goto INFLIGHT_ALIEN_BACK_IN_SWARM
0F17: FE 19         cp   $19                 // 25 pixels away?
0F19: D0            ret  nc                  // if distance is more than $19 (25 decimal), not near enough to destination, so exit
0F1A: E6 01         and  $01                 // is distance an odd number?
0F1C: C0            ret  nz                  // yes, so exit

// Alien is less than 25 pixels away from its destination back in the swarm.
// We now need to determine what way to rotate the sprite so that it returns to the swarm upside-down, bat-style. 
0F1D: DD CB 06 46   bit  0,(ix+$06)          // read INFLIGHT_ALIEN.ArcClockwise
0F21: 20 04         jr   nz,$0F27             

0F23: DD 34 05      inc  (ix+$05)            // update INFLIGHT_ALIEN.AnimationFrame to rotate the alien right
0F26: C9            ret

0F27: DD 35 05      dec  (ix+$05)            // update INFLIGHT_ALIEN.AnimationFrame to rotate the alien left
0F2A: C9            ret

// alien has returned to swarm. Remove sprite and substitute sprite with characters.
INFLIGHT_ALIEN_BACK_IN_SWARM:
0F2B: DD 36 00 00   ld   (ix+$00),$00        // set INFLIGHT_ALIEN.IsActive to 0 - will hide sprite (see $0C98)
0F2F: 26 41         ld   h,$41               // MSB of ALIEN_SWARM_FLAGS address 
0F31: DD 6E 07      ld   l,(ix+$07)          // Now HL = pointer to address in ALIEN_SWARM_FLAGS where alien belongs
0F34: 16 00         ld   d,$00               // command: DRAW_ALIEN_COMMAND
0F36: 36 01         ld   (hl),$01            // mark flag in ALIEN_SWARM_FLAGS as "occupied". Our alien's back in the swarm!
0F38: 5D            ld   e,l                 // E = index of alien in swarm
0F39: C3 F2 08      jp   $08F2               // jump to QUEUE COMMAND. Alien will be drawn in its place in the swarm.


//
// Called when aliens are aggressive and refuse to return to the swarm.
//
// This routine makes the alien fly from the top of the screen for [TempCounter1] pixels vertically.
// During this time it won't shoot, but it will gravitate towards the player's horizontal position (as the player sees it).
// 
// The trigger for this stage of life is when:
//     HAVE_AGGRESSIVE_ALIENS is set OR 
//     HAVE_NO_BLUE_OR_PURPLE_ALIENS flag is set 
// 
//

INFLIGHT_ALIEN_CONTINUING_ATTACK_RUN_FROM_TOP_OF_SCREEN:
0F3C: DD 34 03      inc  (ix+$03)            // increment INFLIGHT_ALIEN.X

// 
0F3F: 3A 02 42      ld   a,($4202)           // read PLAYER_Y      
0F42: DD 96 04      sub  (ix+$04)            // subtract INFLIGHT_ALIEN.Y 

0F45: ED 44         neg                      
0F47: 17            rla                      // A = A * 2
0F48: 5F            ld   e,a
0F49: 9F            sbc  a,a                 // A= 0 - Carry flag
0F4A: 57            ld   d,a
0F4B: CB 13         rl   e
0F4D: CB 12         rl   d                   // DE = DE * 2
0F4F: DD 66 04      ld   h,(ix+$04)
0F52: DD 6E 09      ld   l,(ix+$09)          // INFLIGHT_ALIEN.PivotYValue
0F55: A7            and  a                   // Clear carry flag because..
0F56: ED 52         sbc  hl,de               // ..there's no sub hl,de instruction in Z80 and we dont want a carry
0F58: DD 74 04      ld   (ix+$04),h          // update INFLIGHT_ALIEN.Y 
0F5B: DD 75 09      ld   (ix+$09),l          // update INFLIGHT_ALIEN.PivotYValue
0F5E: DD 35 10      dec  (ix+$10)            // counter was set @ $0ECF
0F61: C0            ret  nz

0F62: DD 34 02      inc  (ix+$02)            // set INFLIGHT_ALIEN.StageOfLife to INFLIGHT_ALIEN_FULL_SPEED_CHARGE
0F65: C9            ret



//
// The inflight alien is now going to fly at full speed and zigzag to make it harder to shoot. 
// It won't drop bombs, but it will gravitate towards the player.
//
// When the alien gets to the vertical (as the player sees it) centre of the screen, the alien will loop
// the loop if there's enough space to do so. 
//
// After the loop is complete, the alien will start shooting.
//

INFLIGHT_ALIEN_FULL_SPEED_CHARGE:
0F66: DD 34 03      inc  (ix+$03)            // increment INFLIGHT_ALIEN.X

// first check the X coordinate to see if the alien is in the centre 
0F69: DD 7E 03      ld   a,(ix+$03)          // read INFLIGHT_ALIEN.X 
0F6C: D6 60         sub  $60                                         
0F6E: FE 40         cp   $40
0F70: 30 09         jr   nc,$0F7B            // if INFLIGHT_ALIEN.X-$60 >= $40, we're not centre horizontally   

// next thing we need to do is check if we have enough space for a loop.
0F72: DD 7E 04      ld   a,(ix+$04)          // read INFLIGHT_ALIEN.Y 
0F75: D6 60         sub  $60
0F77: FE 40         cp   $40
0F79: 38 0C         jr   c,$0F87             // yes, we have space, make alien loop the loop

// otherwise, make the alien veer erratically. 
0F7B: CD DD 0D      call $0DDD               // call INFLIGHT_ALIEN_DEFINE_FLIGHTPATH
0F7E: DD 36 18 03   ld   (ix+$18),$03        // set INFLIGHT_ALIEN.Speed to maximum!
0F82: DD 36 10 64   ld   (ix+$10),$64        // set INFLIGHT_ALIEN.TempCounter1
0F86: C9            ret
                     
 
0F87: DD 34 02      inc  (ix+$02)
0F8A: DD 34 02      inc  (ix+$02)            // set INFLIGHT_ALIEN.StageOfLife to INFLIGHT_ALIEN_LOOP_THE_LOOP 
0F8D: DD 36 10 03   ld   (ix+$10),$03        // set INFLIGHT_ALIEN.TempCounter1 to delay before changing animation frame
0F91: DD 36 11 0C   ld   (ix+$11),$0C        // set INFLIGHT_ALIEN.TempCounter2 to number of animation frames in total
0F95: DD 36 05 00   ld   (ix+$05),$00        // set INFLIGHT_ALIEN.AnimationFrame
0F99: DD 36 13 00   ld   (ix+$13),$00        // set INFLIGHT_ALIEN.ArcTableLsb 
0F9D: 3A 02 42      ld   a,($4202)           // read PLAYER_Y 
0FA0: DD 96 04      sub  (ix+$04)            // subtract INFLIGHT_ALIEN.Y 
0FA3: 38 05         jr   c,$0FAA             // if player to right of alien, make alien loop the loop clockwise

// alien will perform an anti-clockwise loop
0FA5: DD 36 06 00   ld   (ix+$06),$00        // reset INFLIGHT_ALIEN.ArcClockwise
0FA9: C9            ret

0FAA: DD 36 06 01   ld   (ix+$06),$01        // set INFLIGHT_ALIEN.ArcClockwise 
0FAE: C9            ret



//
// You've killed a lot of the alien's friends. It's going to keep coming after you until one of you dies.
//
//
//

INFLIGHT_ALIEN_ATTACKING_PLAYER_AGGRESSIVELY:
0FAF: DD 34 03      inc  (ix+$03)            // increment INFLIGHT_ALIEN.X
0FB2: CD 6B 11      call $116B               // call UPDATE_INFLIGHT_ALIEN_YADD
0FB5: DD 7E 17      ld   a,(ix+$17)          // read INFLIGHT_ALIEN.SortieCount           
0FB8: FE 04         cp   $04                 // has the alien made it past the player 4 times?
0FBA: 28 48         jr   z,$1004             // yes, exactly 4 times, *maybe* make alien closer to player                                                                 
0FBC: 30 4D         jr   nc,$100B            // more than 4 times, make aliens hug player closer 

0FBE: DD 7E 09      ld   a,(ix+$09)          // INFLIGHT_ALIEN.PivotYValue
0FC1: DD 86 19      add  a,(ix+$19)          // Add INFLIGHT_ALIEN.PivotYValueAdd 
0FC4: DD 77 04      ld   (ix+$04),a          // set INFLIGHT_ALIEN.Y 

// has alien wandered off left or right side of screen as player sees it?
0FC7: C6 07         add  a,$07
0FC9: FE 0E         cp   $0E
0FCB: 38 29         jr   c,$0FF6             // alien has gone off side of screen, goto $0FF6

// is alien near bottom of the screen?
0FCD: DD 7E 03      ld   a,(ix+$03)          // read INFLIGHT_ALIEN.X
0FD0: C6 40         add  a,$40               // 
0FD2: 38 27         jr   c,$0FFB             // if adding $40 pixels to X gives a result >255, then alien is near bottom of screen, goto $0FFB
0FD4: DD 35 10      dec  (ix+$10)
0FD7: 28 27         jr   z,$1000
0FD9: 3A 00 42      ld   a,($4200)           // read HAS_PLAYER_SPAWNED
0FDC: 0F            rrca                     // move flag into carry
0FDD: D0            ret  nc                  // return if player has not spawned
0FDE: CD B0 11      call $11B0               // call CALCULATE_INFLIGHT_ALIEN_LOOKAT_ANIM_FRAME
0FE1: 3A 2B 42      ld   a,($422B)           // read IS_FLAGSHIP_HIT
0FE4: 0F            rrca                     // move flag into carry
0FE5: D8            ret  c                   // return if flagship has been hit

// OK, can this alien start firing at you? Exact duplicate of code @$0E54, look there for docs on how algorithm works. 
0FE6: 2A 13 42      ld   hl,($4213)          // get INFLIGHT_ALIEN_SHOOT_EXACT_X into H and INFLIGHT_ALIEN_SHOOT_RANGE_MUL into L
0FE9: DD 7E 03      ld   a,(ix+$03)          
0FEC: BC            cp   h
0FED: CA E0 11      jp   z,$11E0             // jump to TRY_SPAWN_ENEMY_BULLET
0FF0: C6 19         add  a,$19
0FF2: 2D            dec  l                   
0FF3: 20 F7         jr   nz,$0FEC
0FF5: C9            ret

0FF6: DD 36 02 05   ld   (ix+$02),$05        // set INFLIGHT_ALIEN.StageOfLife to INFLIGHT_ALIEN_REACHED_BOTTOM_OF_SCREEN
0FFA: C9            ret

0FFB: DD 36 02 04   ld   (ix+$02),$04        // set INFLIGHT_ALIEN.StageOfLife to INFLIGHT_ALIEN_NEAR_BOTTOM_OF_SCREEN
0FFF: C9            ret

1000: DD 35 02      dec  (ix+$02)
1003: C9            ret


// If we get here, the alien has survived exactly 4 continuous sorties.     
1004: 3A 5F 42      ld   a,($425F)           // read TIMING_VARIABLE
1007: E6 01         and  $01                 // is the number odd?
1009: 28 B3         jr   z,$0FBE             // no, the number's even, it's business as usual, goto $0FBE

// If we get here, the alien is going to "hug" the player a little bit closer than he might like.
// Note: This routine is *always* called if the alien survives 5 continuous sorties or more. 
100B: 3A 02 42      ld   a,($4202)           // read PLAYER_Y 
100E: DD 96 09      sub  (ix+$09)            // subtract INFLIGHT_ALIEN.PivotYValue
1011: 38 06         jr   c,$1019             if a carry occurred, alien is, as player sees it, to left of player ship

// Make the alien's pivot Y coordinate a bit closer to the player...
1013: DD 34 09      inc  (ix+$09)            // Update INFLIGHT_ALIEN.PivotYValue
1016: C3 BE 0F      jp   $0FBE

1019: DD 35 09      dec  (ix+$09)            // Update INFLIGHT_ALIEN.PivotYValue
101C: C3 BE 0F      jp   $0FBE



//
// Aggressive aliens sometimes do a 360 degree loop to taunt the player.
//
// This routine rotates the alien 270 degrees. The remaining 90 degrees is done by the INFLIGHT_ALIEN_FLIES_IN_ARC routine. 
//
// Expects:  
// IX = pointer to INFLIGHT_ALIEN structure
//

INFLIGHT_ALIEN_LOOP_THE_LOOP:
101F: DD 6E 13      ld   l,(ix+$13)          // load L with INFLIGHT_ALIEN.ArcTableLsb
1022: 26 1E         ld   h,$1E               // MSB of INFLIGHT_ALIEN_ARC_TABLE                 

// Now HL is a pointer to an entry in the INFLIGHT_ALIEN_ARC_TABLE (see docs @ $1E00)
1024: DD 7E 03      ld   a,(ix+$03)          // load INFLIGHT_ALIEN.X          
1027: 96            sub  (hl)                // subtract X component from table  
1028: DD 77 03      ld   (ix+$03),a

102B: 2C            inc  l

102C: DD CB 06 46   bit  0,(ix+$06)          // is this alien going to do a clockwise loop?
1030: 20 2E         jr   nz,$1060            // yes, goto INFLIGHT_ALIEN_LOOPING_CLOCKWISE

// Alien is performing a counter-clockwise loop-the-loop maneuvre
1032: DD 7E 04      ld   a,(ix+$04)          // read INFLIGHT_ALIEN.Y
1035: 96            sub  (hl)                // subtract Y component from INFLIGHT_ALIEN_ARC_TABLE
1036: DD 77 04      ld   (ix+$04),a          // set INFLIGHT_ALIEN.Y 
1039: 2C            inc  l                   // bump HL to point to next X,Y pair in INFLIGHT_ALIEN_ARC_TABLE
103A: DD 75 13      ld   (ix+$13),l          // set INFLIGHT_ALIEN.ArcTableLsb
103D: DD 35 10      dec  (ix+$10)            // decrement INFLIGHT_ALIEN.TempCounter1 
1040: C0            ret  nz

// When INFLIGHT_ALIEN.TempCounter1 counts down to zero, its time to change the animation frame
1041: DD 36 10 04   ld   (ix+$10),$04        // reset INFLIGHT_ALIEN.TempCounter1 
1045: DD 35 05      dec  (ix+$05)            // change sprite frame to appear to rotate LEFT

// INFLIGHT_ALIEN.TempCounter2 is used to count down number of animation frames left
1048: DD 35 11      dec  (ix+$11)            // decrement INFLIGHT_ALIEN.TempCounter2
104B: C0            ret  nz                  // return if we haven't done 

// we've done 270 degrees rotation, hand off the remaining 90 to the INFLIGHT_ALIEN_FLIES_IN_ARC 
104C: DD 34 02      inc  (ix+$02)            // bump INFLIGHT_ALIEN.StageOfLife to INFLIGHT_ALIEN_COMPLETE_LOOP
104F: DD 36 10 03   ld   (ix+$10),$03        // set INFLIGHT_ALIEN.TempCounter1 to delay before changing animation frame
1053: DD 36 11 0C   ld   (ix+$11),$0C        // set INFLIGHT_ALIEN.TempCounter2 to number of animation frames
1057: DD 36 05 0C   ld   (ix+$05),$0C        // set INFLIGHT_ALIEN.AnimationFrame
105B: DD 36 13 00   ld   (ix+$13),$00        // set INFLIGHT_ALIEN.ArcTableLsb
105F: C9            ret


// Alien is performing a clockwise loop-the-loop maneuvre
INFLIGHT_ALIEN_LOOPING_CLOCKWISE:
1060: DD 7E 04      ld   a,(ix+$04)          // read INFLIGHT_ALIEN.Y
1063: 86            add  a,(hl)              // add Y component from INFLIGHT_ALIEN_ARC_TABLE
1064: DD 77 04      ld   (ix+$04),a          // set INFLIGHT_ALIEN.Y
1067: 2C            inc  l                   // bump HL to point to next X,Y pair in INFLIGHT_ALIEN_ARC_TABLE
1068: DD 75 13      ld   (ix+$13),l          // set INFLIGHT_ALIEN.ArcTableLsb
106B: DD 35 10      dec  (ix+$10)
106E: C0            ret  nz

// When INFLIGHT_ALIEN.TempCounter1 counts down to zero, its time to change the animation frame
106F: DD 36 10 04   ld   (ix+$10),$04        reset INFLIGHT_ALIEN.TempCounter1 
1073: DD 34 05      inc  (ix+$05)            // change sprite frame to appear to rotate RIGHT
1076: DD 35 11      dec  (ix+$11)
1079: C0            ret  nz

// we've done 270 degrees rotation, hand off the remaining 90 to the INFLIGHT_ALIEN_FLIES_IN_ARC
107A: DD 34 02      inc  (ix+$02)            // bump INFLIGHT_ALIEN.StageOfLife to INFLIGHT_ALIEN_COMPLETE_LOOP
107D: DD 36 10 03   ld   (ix+$10),$03        // set INFLIGHT_ALIEN.TempCounter1 to delay before changing animation frame
1081: DD 36 11 0C   ld   (ix+$11),$0C        // set INFLIGHT_ALIEN.TempCounter2 to number of animation frames
1085: DD 36 05 F4   ld   (ix+$05),$F4        // set INFLIGHT_ALIEN.AnimationFrame
1089: DD 36 13 00   ld   (ix+$13),$00        // set INFLIGHT_ALIEN.ArcTableLsb
108D: C9            ret


INFLIGHT_ALIEN_COMPLETE_LOOP:
108E: C3 71 0D      jp   $0D71               // jump to INFLIGHT_ALIEN_FLIES_IN_ARC


INFLIGHT_ALIEN_UNKNOWN_1091:
1091: DD 34 03      inc  (ix+$03)            // update INFLIGHT_ALIEN.X
1094: DD 36 02 08   ld   (ix+$02),$08        // set INFLIGHT_ALIEN.StageOfLife to INFLIGHT_ALIEN_FULL_SPEED_CHARGE
1098: C3 7B 0F      jp   $0F7B               



//
// Set the colour, X coordinate and animation frame of the INFLIGHT_ALIEN to be scrolled on
// beneath CONVOY CHARGER.
// 
// Expects:
// IX = pointer to INFLIGHT_ALIEN structure 
//
//

INFLIGHT_ALIEN_CONVOY_CHARGER_SET_COLOUR_POS_ANIM:
109B: DD 7E 07      ld   a,(ix+$07)          // read INFLIGHT_ALIEN.IndexInSwarm
// Value in A now identifies type of alien:
// 3: Flagship
// 2: Red alien
// 1: Purple alien
// 0: Blue alien
109E: 2F            cpl                       // flip the bits
109F: E6 03         and  $03

// now A is 0..3, where:
// 0: Flagship
// 1: Red alien
// 2: Purple alien
// 3: Blue alien
10A1: 47            ld   b,a
10A2: 3C            inc  a                   // ensure colour value is nonzero 
10A3: DD 77 16      ld   (ix+$16),a          // set INFLIGHT_ALIEN.Colour
10A6: 07            rlca                     // multiply A..
10A7: 07            rlca
10A8: 07            rlca
10A9: 07            rlca                     // .. by 16
10AA: C6 8C         add  a,$8C               // X coord = $8C + (A * 16)
10AC: DD 77 03      ld   (ix+$03),a          // set INFLIGHT_ALIEN.X
10AF: DD 36 10 18   ld   (ix+$10),$18        // set INFLIGHT_ALIEN.TempCounter1
10B3: DD 34 02      inc  (ix+$02)            // advance alien to its next stage of life
10B6: DD 36 0F 00   ld   (ix+$0f),$00        // set INFLIGHT_ALIEN.AnimFrameStartCode
10BA: 78            ld   a,b
10BB: A7            and  a                   // flagship?
10BC: C0            ret  nz                  // return if not

// This is a flagship, the animation frame start is different from the other aliens
10BD: DD 36 0F 18   ld   (ix+$0f),$18        // set INFLIGHT_ALIEN.AnimFrameStartCode
10C1: C9            ret



// On the WE ARE THE GALAXIANS.. CONVOY CHARGER attract mode page,
// start scrolling an alien sprite onto screen, and print its associated points values  
//
// Expects:
// IX = pointer to INFLIGHT_ALIEN structure
//

INFLIGHT_ALIEN_CONVOY_CHARGER_START_SCROLL:
10C2: DD 34 04      inc  (ix+$04)            // keep incrementing INFLIGHT_ALIEN.Y..            
10C5: DD 35 10      dec  (ix+$10)            // ..until this counter hits zero.   
10C8: C0            ret  nz

10C9: DD 7E 07      ld   a,(ix+$07)          // read INFLIGHT_ALIEN.IndexInSwarm
10CC: C6 4B         add  a,$4B               // set bit 6 to indicate the text needs to be scrolled on
10CE: 5F            ld   e,a
10CF: 16 06         ld   d,$06               // command is PRINT_TEXT
10D1: CD F2 08      call $08F2               // call QUEUE_COMMAND
10D4: DD 34 02      inc  (ix+$02)            // advance to next stage of alien's life
10D7: C9            ret



//
// Scroll alien sprite onto screen    
//
// Expects:
// IX = pointer to INFLIGHT_ALIEN structure
//

INFLIGHT_ALIEN_CONVOY_CHARGER_DO_SCROLL:
10D8: DD 7E 04      ld   a,(ix+$04)          // read INFLIGHT_ALIEN.Y
10DB: D6 C8         sub  $C8
10DD: FE 05         cp   $05                  
10DF: D8            ret  c
10E0: DD 34 04      inc  (ix+$04)            // update INFLIGHT_ALIEN.Y
10E3: C9            ret



//
// Called when the alien is dying.
//

HANDLE_INFLIGHT_ALIEN_DYING:
10E4: DD 7E 02      ld   a,(ix+$02)
10E7: EF            rst  $28                 // jump to code @ $10E8 + (A*2)
10E8: 

      F0 10         // $10F0                  // INFLIGHT_ALIEN_DYING_SETUP_ANIM_AND_SOUND    
      12 11         // $1112                  // INFLIGHT_ALIEN_DYING_DISPLAY_EXPLOSION
      3D 11         // $113D                  // INFLIGHT_ALIEN_DYING_FINALLY_BUYS_FARM
      46 11         // $1146                  // just a pointer to a RET command


//
// Set up a dying alien's death animation and sound effect.
//
// Expects: 
// IX = pointer to INFLIGHT_ALIEN structure

INFLIGHT_ALIEN_DYING_SETUP_ANIM_AND_SOUND:
10F0: DD 36 10 04   ld   (ix+$10),$04        // set INFLIGHT_ALIEN.TempCounter1 to speed of death animation (lower = faster)
10F4: DD 36 11 04   ld   (ix+$11),$04        // set INFLIGHT_ALIEN.TempCounter2 to number of times to repeat death animation
10F8: DD 36 12 1C   ld   (ix+$12),$1C        // set INFLIGHT_ALIEN.DyingAnimFrameCode
10FC: DD 34 02      inc  (ix+$02)            // bump INFLIGHT_ALIEN.StageOfLife to next stage
10FF: DD 7E 07      ld   a,(ix+$07)          // read INFLIGHT_ALIEN.IndexInSwarm
1102: FE 70         cp   $70                 // is this a flagship?
1104: 30 06         jr   nc,$110C            // yes, goto $110C to play flagship hit sound
1106: 3E 07         ld   a,$07
1108: 32 DF 41      ld   ($41DF),a           // play sound effect of alien hit
110B: C9            ret

// play flagship hit sound
110C: 3E 17         ld   a,$17
110E: 32 DF 41      ld   ($41DF),a           // play sound effect of flagship hit
1111: C9            ret


//
// Show the dying alien explosion animation.
//
// Expects: 
// IX = point to INFLIGHT_ALIEN structure
//

INFLIGHT_ALIEN_DYING_DISPLAY_EXPLOSION:
1112: DD 35 10      dec  (ix+$10)            // decrement INFLIGHT_ALIEN.TempCounter1 
1115: C0            ret  nz                  // if counter hasn't reached zero, not time to update explosion animation frame yet
1116: DD 36 10 04   ld   (ix+$10),$04        // reset animation counter. Higher number = slower explosion animation speed
111A: DD 34 12      inc  (ix+$12)            // bump INFLIGHT_ALIEN.DyingAnimFrameCode to next frame
111D: DD 35 11      dec  (ix+$11)            // decrement INFLIGHT_ALIEN.TempCounter1 which holds count of frames left to show 
1120: C0            ret  nz                  // if we've not shown all the explosion frames, exit

1121: DD 7E 07      ld   a,(ix+$07)          // read INFLIGHT_ALIEN.IndexInSwarm
1124: FE 70         cp   $70                 // is this a flagship?
1126: 30 05         jr   nc,$112D            // yes, goto DISPLAY_FLAGSHIP_POINTS_VALUE
1128: DD 36 01 00   ld   (ix+$01),$00        // alien's not a flagship, so just clear INFLIGHT_ALIEN.IsDying to say "we've finished dying, thanks". 
112C: C9            ret


//
// After you shoot a flagship, display its points value for a while.
//

DISPLAY_FLAGSHIP_POINTS_VALUE:
112D: DD 36 10 32   ld   (ix+$10),$32        // set INFLIGHT_ALIEN.TempCounter1 to length of time to keep points on screen
1131: 3A 2D 42      ld   a,($422D)           // read FLAGSHIP_SCORE_FACTOR. 3 = full (800) points
1134: C6 20         add  a,$20
1136: DD 77 12      ld   (ix+$12),a          // set INFLIGHT_ALIEN.DyingAnimFrameCode 
1139: DD 34 02      inc  (ix+$02)            // set INFLIGHT_ALIEN.StageOfLife (or death, should I say.)
113C: C9            ret


// keeps points value on screen until counter hits zero.
//
// After that, the alien is officially dead and the INFLIGHT_ALIEN structure is ready for re-use by another (living) attacking alien.
//
INFLIGHT_ALIEN_DYING_FINALLY_BUYS_FARM:
113D: DD 35 10      dec  (ix+$10)            // decrement INFLIGHT_ALIEN.TempCounter1 
1140: C0            ret  nz                  // if points value countdown isn't zero, exit
1141: DD 36 01 00   ld   (ix+$01),$00        // clear INFLIGHT_ALIEN.IsDying flag.   
1145: C9            ret


1146: C9            ret


//
// When an alien breaks off from the swarm to attack the player, the characters it occupies in the swarm are deleted and an alien sprite is substituted.
// This function calculates a starting X and Y coordinate for the sprite.
//
// This function is also used by INFLIGHT_ALIEN_RETURNING_TO_SWARM (see $0F07) to determine where in the swarm a returning alien should fly to. 
//
//
// Expects:
// IX to point to an INFLIGHT_ALIEN structure.
//     (IX + 7) to be the index of the alien in the ALIEN_SWARM_FLAGS array.
//
// 

SET_INFLIGHT_ALIEN_START_POSITION:
1147: DD 7E 07      ld   a,(ix+$07)          // read INFLIGHT_ALIEN.IndexInSwarm
114A: E6 70         and  $70                 // compute row that alien is in
114C: 0F            rrca
114D: 4F            ld   c,a
114E: 0F            rrca
114F: 81            add  a,c
1150: ED 44         neg
1152: C6 7C         add  a,$7C
1154: DD 77 03      ld   (ix+$03),a          // set INFLIGHT_ALIEN.X

1157: DD 7E 07      ld   a,(ix+$07)          // read INFLIGHT_ALIEN.IndexInSwarm
115A: E6 0F         and  $0F                 // compute column that alien is in
115C: 07            rlca
115D: 07            rlca
115E: 07            rlca
115F: 07            rlca                     // multiply by 16..
1160: C6 07         add  a,$07
1162: 4F            ld   c,a
1163: 3A 0E 42      ld   a,($420E)           // read SWARM_SCROLL_VALUE   
1166: 81            add  a,c                    
1167: DD 77 04      ld   (ix+$04),a          // set INFLIGHT_ALIEN.Y 
116A: C9            ret


//
// This routine helps move an attacking INFLIGHT_ALIEN.
//
// I'll be honest, I don't know exactly how it works. I've had the guys from my work (Lambo & Phil) look at this with me,
// and some of the guys from the https://www.facebook.com/groups/z80asm/ as well. When I figure it out, I'll document it.
//
// The key is in the mutation of IX+$19, INFLIGHT_ALIEN.PivotYValueAdd 
// 
// Expects:
// IX = pointer to INFLIGHT_ALIEN structure
// 

//
// To monitor the input parameters type the following into the MAME debugger:
// bp 117E,1,{printf "IX=%04X:   H=%01X L=%01X D=%01X E=%01X", IX,H,L,D,E// g}
//

UPDATE_INFLIGHT_ALIEN_YADD:
116B: DD 7E 18      ld   a,(ix+$18)          // read INFLIGHT_ALIEN.Speed
116E: E6 03         and  $03                 
1170: 3C            inc  a                   // now A is between 1 and 4.
1171: 47            ld   b,a

1172: DD 66 19      ld   h,(ix+$19)          // read INFLIGHT_ALIEN.PivotYValueAdd
1175: DD 6E 1A      ld   l,(ix+$1a)
1178: DD 56 1B      ld   d,(ix+$1b)
117B: DD 5E 1C      ld   e,(ix+$1c)

117E: 7D            ld   a,l

// Part 1 - do H
117F: 4C            ld   c,h                 // preserve H in C
1180: 87            add  a,a           
1181: 30 01         jr   nc,$1184

1183: 25            dec  h
1184: 82            add  a,d
1185: 57            ld   d,a
1186: 3E 00         ld   a,$00
1188: 8C            adc  a,h

// I *think* this is to ensure that the signed byte in H never loses its sign.
// If it's positive it'll stay positive. If it's negative, it'll stay negative.
1189: FE 80         cp   $80                 
118B: 20 01         jr   nz,$118E

118D: 79            ld   a,c
118E: 67            ld   h,a

// Part 2 - now do L
118F: 4D            ld   c,l                 // preserve L in C  
1190: ED 44         neg
1192: 87            add  a,a
1193: 30 01         jr   nc,$1196

1195: 2D            dec  l

1196: 83            add  a,e
1197: 5F            ld   e,a
1198: 3E 00         ld   a,$00
119A: 8D            adc  a,l
119B: FE 80         cp   $80
119D: 20 01         jr   nz,$11A0

119F: 79            ld   a,c

11A0: 6F            ld   l,a                 // restore L from C

11A1: 10 DB         djnz $117E

11A3: DD 74 19      ld   (ix+$19),h
11A6: DD 75 1A      ld   (ix+$1a),l
11A9: DD 72 1B      ld   (ix+$1b),d
11AC: DD 73 1C      ld   (ix+$1c),e
11AF: C9            ret



//
// Calculate the animation frame that makes an attacking alien "look" directly at the player. 
// 
// Expects:
// IX = pointer to INFLIGHT_ALIEN structure with valid X and Y fields.
//
// Returns:
//  INFLIGHT_ALIEN.AnimationFrame is updated
//

CALCULATE_INFLIGHT_ALIEN_LOOKAT_ANIM_FRAME:
11B0: 3E F0         ld   a,$F0               //  
11B2: DD 96 03      sub  (ix+$03)            // subtract from INFLIGHT_ALIEN.X
11B5: 57            ld   d,a
11B6: 3A 02 42      ld   a,($4202)           // read PLAYER_Y 
11B9: DD 96 04      sub  (ix+$04)            // subtract from INFLIGHT_ALIEN.Y 
11BC: 38 07         jr   c,$11C5             
11BE: CD D0 11      call $11D0
11C1: DD 77 05      ld   (ix+$05),a          // set INFLIGHT_ALIEN.AnimationFrame          
11C4: C9            ret

11C5: ED 44         neg
11C7: CD D0 11      call $11D0
11CA: ED 44         neg
11CC: DD 77 05      ld   (ix+$05),a          // set INFLIGHT_ALIEN.AnimationFrame
11CF: C9            ret


11D0: CD 48 00      call $0048               // call CALCULATE_TANGENT
11D3: 79            ld   a,c
11D4: A7            and  a
11D5: F2 DA 11      jp   p,$11DA
11D8: 3E 80         ld   a,$80
11DA: 07            rlca
11DB: 07            rlca
11DC: 07            rlca
11DD: E6 07         and  $07
11DF: C9            ret


//
// Try to spawn an enemy bullet. 
//
// Expects:
// IX = pointer to INFLIGHT_ALIEN struct
//
// Cheat:
// If you want to stop the aliens from firing, type the following into the MAME debugger:
// maincpu.mb@11E0 = C9 

TRY_SPAWN_ENEMY_BULLET:
11E0: 11 05 00      ld   de,$0005            // sizeof(ENEMY_BULLET)
11E3: 21 60 42      ld   hl,$4260            // load HL with address of ENEMY_BULLETS_START
11E6: 06 0E         ld   b,$0E               // there are 14 elements in the ENEMY_BULLETS_START array
11E8: CB 46         bit  0,(hl)              // test if bullet is active
11EA: 28 04         jr   z,$11F0             // if its not active, then we can use this slot to spawn an enemy bullet, goto $11F0
11EC: 19            add  hl,de               // otherwise bump HL to point to next enemy bullet in the array
11ED: 10 F9         djnz $11E8               // repeat until B==0
11EF: C9            ret


//
// Spawn an enemy bullet.
//
// Expects:
// IX = pointer to INFLIGHT_ALIEN structure. Identifies the alien firing the bullet.
// HL = pointer to ENEMY_BULLET structure. Contains info about the spawned bullet. 
//

SPAWN_ENEMY_BULLET:
11F0: 36 01         ld   (hl),$01            // set ENEMY_BULLET.IsActive to 1 (true)
11F2: 23            inc  hl                  // bump HL to point to ENEMY_BULLET.X
11F3: DD 7E 03      ld   a,(ix+$03)          // read INFLIGHT_ALIEN.X coordinate
11F6: 77            ld   (hl),a              // set X coordinate of bullet to be same as alien
11F7: 3E F0         ld   a,$F0               // load A with -16 (decimal)
11F9: 96            sub  (hl)                // A = X coordinate of bullet + 16 
11FA: 57            ld   d,a
11FB: 23            inc  hl
11FC: 23            inc  hl                  // bump HL to point to ENEMY_BULLET.YH
11FD: DD 7E 04      ld   a,(ix+$04)          // read INFLIGHT_ALIEN.Y  coordinate
1200: 77            ld   (hl),a              // set Y coordinate of bullet to be same as alien
1201: 23            inc  hl                  // bump HL to point to ENEMY_BULLET.YDelta
1202: 3A 02 42      ld   a,($4202)           // read PLAYER_Y   
1205: DD 96 04      sub  (ix+$04)            // subtract from INFLIGHT_ALIEN.Y  coordinate       
1208: 38 05         jr   c,$120F             // 
120A: CD 18 12      call $1218               // call COMPUTE_ENEMY_BULLET_DELTA
120D: 77            ld   (hl),a              // set ENEMY_BULLET.YDelta 
120E: C9            ret


120F: ED 44         neg                      // A = Math.Abs(A)
1211: CD 18 12      call $1218               // call COMPUTE_ENEMY_BULLET_DELTA
1214: ED 44         neg                      // make bullet fly to right 
1216: 77            ld   (hl),a              // set ENEMY_BULLET.YDelta 
1217: C9            ret


//
// Unlike the player's bullet, enemy bullets don't always fly in a straight line. 
//

COMPUTE_ENEMY_BULLET_DELTA:
1218: CD 48 00      call $0048               // call CALCULATE_TANGENT
121B: CD 3C 00      call $003C               // call GENERATE_RANDOM_NUMBER
121E: E6 1F         and  $1F                 // clamp number to 0..31 decimal
1220: 81            add  a,c
1221: C6 06         add  a,$06
1223: F0            ret  p
1224: 3E 7F         ld   a,$7F
1226: C9            ret




HANDLE_INFLIGHT_ALIEN_TO_PLAYER_BULLET_COLLISION_DETECTION:
1227: 3A 08 42      ld   a,($4208)           // read HAS_PLAYER_BULLET_BEEN_FIRED flag
122A: 0F            rrca                     // move flag into carry
122B: D0            ret  nc                  // return if player is not shooting
122C: DD 21 D0 42   ld   ix,$42D0            // pointer to INFLIGHT_ALIENS_START
1230: 11 20 00      ld   de,$0020            // sizeof(INFLIGHT_ALIEN)
1233: 06 07         ld   b,$07               // length of INFLIGHT_ALIENS array
1235: D9            exx
1236: CD 3F 12      call $123F               // call TEST_IF_PLAYER_BULLET_HIT_INFLIGHT_ALIEN   
1239: D9            exx
123A: DD 19         add  ix,de               // bump IX to point to next INFLIGHT_ALIEN
123C: 10 F7         djnz $1235
123E: C9            ret




//
// Player bullet to attacking alien collision detection.
//
// IX = pointer to INFLIGHT_ALIEN structure
//

TEST_IF_PLAYER_BULLET_HIT_INFLIGHT_ALIEN:
123F: DD CB 00 46   bit  0,(ix+$00)          // Test INFLIGHT_ALIEN.IsActive flag
1243: C8            ret  z                   // return if not set
1244: 2A 09 42      ld   hl,($4209)          // read PLAYER_BULLET_X and PLAYER_BULLET_Y 
1247: DD 7E 03      ld   a,(ix+$03)          // read INFLIGHT_ALIEN.X
124A: 95            sub  l                   // subtract from value of PLAYER_BULLET_X 
124B: C6 02         add  a,$02               
124D: FE 06         cp   $06
124F: D0            ret  nc
1250: DD 7E 04      ld   a,(ix+$04)          // read INFLIGHT_ALIEN.Y  
1253: 94            sub  h                   // subtract from value of PLAYER_BULLET_Y 
1254: C6 05         add  a,$05
1256: FE 0C         cp   $0C
1258: D0            ret  nc

// if we get here, the player bullet has hit an alien inflight.
1259: 3E 01         ld   a,$01
125B: 32 0B 42      ld   ($420B),a           // set IS_PLAYER_BULLET_DONE to 1.
125E: DD 36 00 00   ld   (ix+$00),$00        // set INFLIGHT_ALIEN.IsActive to 0.  
1262: DD 36 01 01   ld   (ix+$01),$01        // set INFLIGHT_ALIEN.IsDying to 1.
1266: DD 36 02 00   ld   (ix+$02),$00        // set INFLIGHT_ALIEN.StageOfLife to 0.
126A: 11 04 03      ld   de,$0304            // command ID: UPDATE_PLAYER_SCORE_COMMAND, parameter: 4 

// We now need to identify what rank this alien is so we can add its points value to the player score.
126D: 01 50 03      ld   bc,$0350            // B= count, C = index into ALIEN_SWARM_FLAGS array to compare against
1270: DD 7E 07      ld   a,(ix+$07)          // load a with INFLIGHT_ALIEN.IndexInSwarm to find out what rank this alien is.
1273: B9            cp   c                   // compare A with $50 (80 decimal)  
1274: DA F2 08      jp   c,$08F2             // if A<$50 jump to QUEUE_COMMAND with command ID: UPDATE_PLAYER_SCORE_COMMAND 
1277: 1C            inc  e                   // increment parameter passed to command - giving a higher score value
1278: D6 10         sub  $10                 // subtract 10 (16 decimal) to "go down" a rank
127A: 10 F7         djnz $1273               // repeat until B==0. Only flagships will go to B==0.

// If we get here, we've shot an attacking flagship. 
// First we activate a timer that prevents aliens from leaving the swarm for a while. This simulates the swarm being "stunned". 
// We then calculate how many of the flagships escorts have been killed so we can update the player score accordingly. 
// For max points, a flagship must have 2 escorts and the escorts must be killed before the flagship.
127C: 21 01 F0      ld   hl,$F001
127F: 22 2B 42      ld   ($422B),hl          // set IS_FLAGSHIP_HIT to 1, and ALIENS_IN_SHOCK_COUNTER to $F0 (240 decimal)                    
1282: 3A 2A 42      ld   a,($422A)           // read FLAGSHIP_ESCORT_COUNT 
1285: FE 02         cp   $02                 // do we have 2 aliens escorting the flagship?
1287: CC 92 12      call z,$1292             // yes, call ASSERT_BOTH_FLAGSHIP_ESCORTS_ARE_ALIVE
128A: 32 2D 42      ld   ($422D),a           // set FLAGSHIP_SCORE_FACTOR. If 3, then you get full points for killing the flagship + escort.               
128D: 83            add  a,e
128E: 5F            ld   e,a                 // set command parameter
128F: C3 F2 08      jp   $08F2               // QUEUE_COMMAND with command ID: UPDATE_PLAYER_SCORE_COMMAND

// We need to test if both the flagship's escorts are alive.
// If both are dead, then when this function returns, A will be set to 3. 
ASSERT_BOTH_FLAGSHIP_ESCORTS_ARE_ALIVE:
1292: DD CB 20 46   bit  0,(ix+$20)          // test if first escort is alive   
1296: C0            ret  nz                  // return if alive
1297: DD CB 40 46   bit  0,(ix+$40)          // test if second escort is alive   
129B: C0            ret  nz                  // return if alive

// both escorts have been killed (or the flagship didn't have 2 escorts to start with)
129C: 3C            inc  a                   // both 
129D: C9            ret


//
// Iterate through list of inflight aliens and test if they have hit the player.
//

HANDLE_PLAYER_TO_INFLIGHT_ALIEN_COLLISION_DETECTION:
129E: 3A 00 42      ld   a,($4200)           // read HAS_PLAYER_SPAWNED
12A1: 0F            rrca                     // move flag into carry
12A2: D0            ret  nc                  // return if carry not set
12A3: DD 21 D0 42   ld   ix,$42D0            // pointer to INFLIGHT_ALIENS[1]
12A7: 11 20 00      ld   de,$0020            // sizeof(INFLIGHT_ALIEN)
12AA: 06 07         ld   b,$07               // 7 aliens to test collision with
12AC: D9            exx
12AD: CD B6 12      call $12B6               // call TEST_IF_INFLIGHT_ALIEN_HIT_PLAYER
12B0: D9            exx
12B1: DD 19         add  ix,de               // bump IX to point to next INFLIGHT_ALIEN in array
12B3: 10 F7         djnz $12AC               // repeat until B==0
12B5: C9            ret



//
// Check if a flying alien has hit the player's ship.
//
// If so:
// IS_PLAYER_HIT will be set to 1.
//
// Expects: 
// IX = pointer to INFLIGHT_ALIEN structure 
//

TEST_IF_INFLIGHT_ALIEN_HIT_PLAYER:
12B6: DD CB 00 46   bit  0,(ix+$00)          // read INFLIGHT_ALIEN.IsActive flag
12BA: C8            ret  z                   // exit if alien isn't active

12BB: DD 7E 03      ld   a,(ix+$03)          // read INFLIGHT_ALIEN.X
12BE: C6 21         add  a,$21
12C0: D6 05         sub  $05
12C2: 38 16         jr   c,$12DA
12C4: D6 0C         sub  $0C
12C6: D0            ret  nc                  // return if >=$0C

12C7: 3A 02 42      ld   a,($4202)           // read PLAYER_Y 
12CA: DD 96 04      sub  (ix+$04)            // subtract INFLIGHT_ALIEN.Y 
12CD: C6 0A         add  a,$0A
12CF: FE 15         cp   $15
12D1: D0            ret  nc                  // return if >=$15

// kill player and alien
12D2: 3E 01         ld   a,$01
12D4: 32 04 42      ld   ($4204),a           // set IS_PLAYER_HIT flag. 
12D7: C3 5E 12      jp   $125E               // and we need to kill the alien as well

12DA: 3A 02 42      ld   a,($4202)           // read PLAYER_Y 
12DD: DD 96 04      sub  (ix+$04)            // subtract INFLIGHT_ALIEN.Y 
12E0: C6 07         add  a,$07
12E2: FE 0F         cp   $0F
12E4: D0            ret  nc                  // return if >=$0f

// kill player and alien
12E5: 3E 01         ld   a,$01
12E7: 32 04 42      ld   ($4204),a           // set IS_PLAYER_HIT flag. 
12EA: C3 5E 12      jp   $125E               // and we need to kill the alien as well



// 
//  Handles the player being hit by an INFLIGHT_ALIEN (see $12B6) or ENEMY_BULLET (see $0B8D).
// 

HANDLE_PLAYER_HIT:
12ED: 21 04 42      ld   hl,$4204            // pointer to IS_PLAYER_HIT flag
12F0: CB 46         bit  0,(hl)              // test flag to see if player has been hit. 
12F2: C8            ret  z                   // bit is not set so player not hit, return

// OK, player's hit. 
12F3: 36 00         ld   (hl),$00            // clear IS_PLAYER_HIT flag
12F5: 21 00 01      ld   hl,$0100             
12F8: 22 00 42      ld   ($4200),hl          // Clear HAS_PLAYER_SPAWNED and set IS_PLAYER_DYING flags

// Draw first frame of player exploding
12FB: 21 0A 04      ld   hl,$040A
12FE: 22 05 42      ld   ($4205),hl          // set PLAYER_EXPLOSION_COUNTER and PLAYER_EXPLOSION_ANIM_FRAME
1301: 11 05 02      ld   de,$0205            // command: DISPLAY_PLAYER_COMMAND, parameter: 5 (invokes DRAW_PLAYER_SHIP_EXPLODING)
1304: CD F2 08      call $08F2               // call QUEUE_COMMAND

// reduce level of difficulty
1307: 3A 1A 42      ld   a,($421A)           // read DIFFICULTY_EXTRA_VALUE
130A: A7            and  a                   // test if its zero
130B: 28 01         jr   z,$130E             // if zero, then - wait a second, why is it updating an already zero field? Should be: jr z, $1311     
130D: 3D            dec  a                   // reduce game difficulty slightly
130E: 32 1A 42      ld   ($421A),a           // update DIFFICULTY_EXTRA_VALUE

// decrement number of player lives
1311: 21 1D 42      ld   hl,$421D            // pointer to address of PLAYER_LIVES
1314: 35            dec  (hl)                // reduce number of lives
1315: 7E            ld   a,(hl)              // read number of lives
1316: FE 06         cp   $06                 // compare to 6
1318: 38 02         jr   c,$131C             // if < 6 then goto $131C
131A: 36 05         ld   (hl),$05            // otherwise, clamp number of lives max to 5 (is this anti-hack code?)
131C: 3A 06 40      ld   a,($4006)           // read IS_GAME_IN_PLAY
131F: 0F            rrca                     // move flag into carry
1320: D0            ret  nc                  // return if game is not in play

// Make player BOOM! sound
1321: 3E 01         ld   a,$01
1323: 32 03 68      ld   ($6803),a           // make PLAYER HIT noise
1326: C9            ret




// Draws player explosion, stops player hit sound when done.

HANDLE_PLAYER_DYING:
1327: 3A 01 42      ld   a,($4201)           // read IS_PLAYER_DYING flag
132A: 0F            rrca                     // move flag into carry. If player is dying carry is set
132B: D0            ret  nc                  // return if player is not dying. 
// wait for explosion delay to count to zero
132C: 21 05 42      ld   hl,$4205            // point HL to PLAYER_EXPLOSION_COUNTER
132F: 35            dec  (hl)                // decrement value
1330: C0            ret  nz                  // if counter hasn't hit 0, then explosion animation can continue, return.
1331: 36 0A         ld   (hl),$0A            // otherwise reset PLAYER_EXPLOSION_COUNTER value to its default #$0A (10 decimal)

// draw explosion animation
1333: 23            inc  hl                  // bump HL to point to PLAYER_EXPLOSION_ANIM_FRAME     
1334: 16 02         ld   d,$02               // command 2: DISPLAY_PLAYER_COMMAND
1336: 5E            ld   e,(hl)              // read the animation frame value  
1337: CD F2 08      call $08F2               // call QUEUE_COMMAND
133A: 35            dec  (hl)                // decrement the animation frame value
133B: C0            ret  nz                  // if its not zero, the player dying animation hasn't finished, so return 
133C: AF            xor  a                   // Otherwise, the player explosion animation has reached its end, so....

// clear IS_PLAYER_DYING flag when animation done and stop player explosion sound
133D: 32 01 42      ld   ($4201),a           // clear IS_PLAYER_DYING flag
1340: 32 03 68      ld   ($6803),a           // clear !SOUND  player hit
1343: C9            ret



//
// Try to send a single alien to attack the player.
//
// If we have flagships in the swarm, then only purple and blue aliens can be sent to attack by this routine.
// If we have no flagships in the swarm, then red aliens can also be sent to attack. (See $13BD)
//
// Flagships and escorts are handled by HANDLE_FLAGSHIP_ATTACK.
//
//
// Cheat (of a sort):
// if you want to make this game very difficult, type the following into the MAME debugger: 
// maincpu.mb@1359 = 8
// maincpu.pb@421A = 7
// maincpu.pb@421B = 7
//

HANDLE_SINGLE_ALIEN_ATTACK:
1344: 3A 28 42      ld   a,($4228)           // read CAN_ALIEN_ATTACK flag
1347: 0F            rrca                     // move flag into carry
1348: D0            ret  nc                  // return if flag is not set
1349: AF            xor  a
134A: 32 28 42      ld   ($4228),a           // reset flag
134D: 3A 20 42      ld   a,($4220)           // read HAVE_NO_ALIENS_IN_SWARM flag.
1350: 0F            rrca                     // move flag into carry
1351: D8            ret  c                   // return if no aliens are in the swarm.

// The difficulty level specifies how many aliens can be attacking the player at one time.
1352: 2A 1A 42      ld   hl,($421A)          // load H with DIFFICULTY_BASE_VALUE and L with DIFFICULTY_EXTRA_VALUE
1355: 7C            ld   a,h                 // 
1356: 85            add  a,l                 // add DIFFICULTY_EXTRA_VALUE to DIFFICULTY_BASE_VALUE 
1357: 1F            rra                      // divide by 2.
1358: FE 04         cp   $04                 // is result < 4?
135A: 38 02         jr   c,$135E             // yes, goto $135E.
135C: 3E 03         ld   a,$03               // Clamp maximum number of INFLIGHT_ALIEN slots to scan to 3.
135E: 3C            inc  a                   // ensure that slots to scan is in range of 1..4

// Scan a specified number of slots (up to 4) in the INFLIGHT_ALIENS array, starting from the *last* slot and working back.
// Take the first slot that has clear IsActive and IsDying flags.
// A = number of slots to scan
135F: 47            ld   b,a                  // save number of slots to scan in B
1360: 21 91 43      ld   hl,$4391             // point HL to last INFLIGHT_ALIEN.IsDying flag in INFLIGHT_ALIENS array
1363: 11 E1 FF      ld   de,$FFE1             // load DE with -31, which is sizeof(INFLIGHT_ALIEN)-1
1366: 7E            ld   a,(hl)               // read INFLIGHT_ALIEN.IsDying flag
1367: 2B            dec  hl                   // bump HL to point to INFLIGHT_ALIEN.IsActive flag  
1368: B6            or   (hl)                 // combine flags. We want A to be 0, to indicate INFLIGHT_ALIEN slot is not in use. 
1369: 28 04         jr   z,$136F              // OK, we have an unused slot, goto $136F
136B: 19            add  hl,de
136C: 10 F8         djnz $1366                // repeat until we've scanned all the slots we're allowed to
136E: C9            ret

// If we get here, HL points to an unused INFLIGHT_ALIEN record that will be repurposed for our soon-to-be attacking alien. 
// HL = pointer to unused INFLIGHT_ALIEN structure
136F: E5            push hl
1370: DD E1         pop  ix                   // IX = HL
1372: 3A 15 42      ld   a,($4215)            // read ALIENS_ATTACK_FROM_RIGHT_FLANK flag
1375: DD 77 06      ld   (ix+$06),a           // update INFLIGHT_ALIEN.ArcClockwise flag
1378: A7            and  a                    // test if flag is set  
1379: 20 30         jr   nz,$13AB             // if flag is set, goto FIND_FIRST_OCCUPIED_SWARM_COLUMN_START_FROM_RIGHT

// If we get here, we want an alien to break off from the left flank of the swarm.
// We now need to find an alien in the swarm able to attack the player. 
// Find first occupied column of aliens starting from the leftmost column.
FIND_FIRST_OCCUPIED_SWARM_COLUMN_START_FROM_LEFT:
137B: 21 FC 41      ld   hl,$41FC             // address of flag for leftmost alien in ALIEN_IN_COLUMN_FLAGS 
137E: 01 0A 00      ld   bc,$000A             // 10 aliens maximum on a row         
1381: 3E 01         ld   a,$01                // we are scanning for a value of 1, meaning "column occupied"
1383: ED B9         cpdr                      // scan $41FC down to $41F3 for value #$01. 
1385: C0            ret  nz                   // if we have no aliens in the swarm (all flags are 0) - return
1386: E0            ret  po                   // if BC has overflowed, return

1387: 1E 3F         ld   e,$3F
1389: 2C            inc  l                    // adjust L because CPDR will have decremented it one time too many 

// HL now points to an entry in ALIEN_IN_COLUMN_FLAGS where we have an alien present.
// If we have flagships in the swarm, then only purple and blue aliens can be sent to attack by this routine.
// If we have no flagships in the swarm, then any remaining red aliens are also considered. (See $13BD)
TRY_FIND_ALIEN_TO_ATTACK:
138A: 3A EF 41      ld   a,($41EF)            // load a with HAVE_ALIENS_IN_TOP_ROW flag
138D: 0F            rrca                      // move flag into carry
138E: 30 2D         jr   nc,$13BD             // if no flagships in swarm, goto INIT_SCAN_FROM_RED_ALIEN_ROW

// we have flagships, so send a purple or blue alien.
INIT_SCAN_FROM_PURPLE_ALIEN_ROW:
1390: 16 04         ld   d,$04                // number of rows to scan (1 purple + 3 blue)
1392: 26 41         ld   h,$41                // MSB of ALIEN_SWARM_FLAGS address 
1394: 7D            ld   a,l                  
1395: E6 0F         and  $0F                  // A = index of column containing alien 
1397: C6 50         add  a,$50                // effectively: HL = $4150 + (L & 0x0f)       
1399: 6F            ld   l,a                  // HL now points to slot for purple alien in ALIEN_SWARM_FLAGS

// HL now points to a slot in ALIEN_SWARM_FLAGS. D is a row counter.
// If the slot is occupied, the occupying alien will be sent to attack the player.
// If the slot is unoccupied, we'll scan the same column in the rows beneath until we find an occupied slot or we've done D rows.  
// If we find an alien, we'll send it to attack the player.
SCAN_SPECIFIC_COLUMN_FOR_D_ROWS:
139A: 42            ld   b,d                  // set B to number of rows to scan
139B: CB 46         bit  0,(hl)               // test for presence of alien in ALIEN_SWARM_FLAGS              
139D: 20 2F         jr   nz,$13CE             // if there's an alien present, its "volunteered" to attack, goto $13CE 
139F: 7D            ld   a,l                  
13A0: D6 10         sub  $10                  // sizeof(row in ALIEN_SWARM_FLAGS)
13A2: 6F            ld   l,a                  // bump HL to point to alien in row beneath
13A3: 10 F6         djnz $139B                // repeat until B==0

// OK, We've scanned the entire column and not found an alien. This means that ALIEN_IN_COLUMN_FLAGS isn't truthful,
// and we need to resort to desperate measures. 
// 
// ** I've not seen this block of code called, and I think it might be legacy or debug **  
//
// Bump HL to point to the purple alien in the column to the right of the one we just scanned. We'll scan that column.  
13A5: 83            add  a,e                  // add $3F to A.  
13A6: 6F            ld   l,a                  // Now HL points to purple alien slot
13A7: 0D            dec  c                    // decrement count of columns remaining that we *can* scan
13A8: 20 F0         jr   nz,$139A             // if non-zero, repeat the column scan
13AA: C9            ret


// If we get here, we want an alien to break off from the right flank of the swarm.
// We now need to find an alien in the swarm willing to attack the player. 
// Find first occupied column of aliens starting from the rightmost column.
FIND_FIRST_OCCUPIED_SWARM_COLUMN_START_FROM_RIGHT:
13AB: 21 F3 41      ld   hl,$41F3            // address of flag for rightmost column of aliens 
13AE: 01 0A 00      ld   bc,$000A            // 10 aliens maximum on a row  
13B1: 3E 01         ld   a,$01               // we are scanning for a value of 1, meaning "column occupied"
13B3: ED B1         cpir                     // scan $41F3 up to $41F3 for value #$01. 
13B5: C0            ret  nz                  // if we have no aliens in the swarm - return
13B6: E0            ret  po                  // if BC has overflowed, return

// we've found an occupied column
13B7: 1E 41         ld   e,$41
13B9: 2D            dec  l
13BA: C3 8A 13      jp   $138A               // jump to TRY_FIND_ALIEN_TO_ATTACK:


// Called when no flagships present in flagship row. This means we can send any alien, including red, into the attack.
INIT_SCAN_FROM_RED_ALIEN_ROW:
13BD: 16 05         ld   d,$05                // number of rows of aliens to scan 
13BF: 26 41         ld   h,$41                // MSB of ALIEN_SWARM_FLAGS address 
13C1: 7D            ld   a,l
13C2: E6 0F         and  $0F                  // A = index of column   
13C4: C6 60         add  a,$60                // effectively: HL = $4150 + (L & 0x0f)
13C6: 6F            ld   l,a                  // HL now points to slot for red alien in ALIEN_SWARM_FLAGS
13C7: 7B            ld   a,e
13C8: C6 10         add  a,$10
13CA: 5F            ld   e,a
13CB: C3 9A 13      jp   $139A                // jump to SCAN_SPECIFIC_COLUMN_FOR_D_ROWS


//
// Expects:
// HL = pointer to occupied entry in ALIEN_SWARM_FLAGS
// IX = pointer to vacant INFLIGHT_ALIEN structure
//

13CE: 36 00         ld   (hl),$00
13D0: DD 75 07      ld   (ix+$07),l          // set INFLIGHT_ALIEN.IndexInSwarm
13D3: DD 36 00 01   ld   (ix+$00),$01        // set INFLIGHT_ALIEN.IsActive 
13D7: DD 36 02 00   ld   (ix+$02),$00        // set INFLIGHT_ALIEN.StageOfLife
13DB: 16 01         ld   d,$01               // command: DELETE_ALIEN_COMMAND
13DD: 5D            ld   e,l                 // parameter: index of alien in swarm
13DE: C3 F2 08      jp   $08F2               // jump to QUEUE COMMAND



//
// Sets the flank that aliens, including flagships, will attack from.
// 
// If you replace $13F3-13F5, $13FF-1401, $1408-140A with zero (NOP), you can then tinker with the flag in $4215 and control 
// what side the aliens attack from.
//

SET_ALIEN_ATTACK_FLANK:
13E1: 2A 0E 42      ld   hl,($420E)          // read SWARM_SCROLL_VALUE
13E4: ED 5B 10 42   ld   de,($4210)          // read SWARM_SCROLL_MAX_EXTENTS
13E8: CB 7C         bit  7,h                 
13EA: 28 0B         jr   z,$13F7

13EC: 7D            ld   a,l
13ED: 92            sub  d
13EE: FE 1C         cp   $1C
13F0: 30 11         jr   nc,$1403            // if A>$1C, attack from a random flank
13F2: AF            xor  a
13F3: 32 15 42      ld   ($4215),a           // reset ALIENS_ATTACK_FROM_RIGHT_FLANK flag. Aliens will now attack from left side of swarm.
13F6: C9            ret

13F7: 7B            ld   a,e
13F8: 95            sub  l
13F9: FE 1C         cp   $1C
13FB: 30 06         jr   nc,$1403            // if A>$1C, attack from a random flank
13FD: 3E 01         ld   a,$01
13FF: 32 15 42      ld   ($4215),a           // set ALIENS_ATTACK_FROM_RIGHT_FLANK flag. Aliens will now attack from right side of swarm.
1402: C9            ret

// Attack from left or right flank, chosen at random
1403: CD 3C 00      call $003C               // call GENERATE_RANDOM_NUMBER
1406: E6 01         and  $01                 // mask in bit 0, so A is either 0 or 1
1408: 32 15 42      ld   ($4215),a           // set/reset ALIENS_ATTACK_FROM_RIGHT_FLANK flag. 
140B: C9            ret




//
// This routine checks if a flagship and escort can break from a given flank to attack the player.
// 
// The flank is determined by the ALIENS_ATTACK_FROM_RIGHT_FLANK flag ($4215).
//
// If a flagship exists on the specified flank, send the flagship to attack.  
// If there's red aliens in *close proximity* to the flagship, send a maximum of 2 as an escort.
//
// If there are no flagships on the specified flank, try to send a single red alien from the flank instead.
//
// Notes:
// A flagship can attack when:
//     HAVE_NO_ALIENS_IN_SWARM is set to 0 AND
//     HAS_PLAYER_SPAWNED is set to 1 AND
//     The CAN_FLAGSHIP_OR_RED_ALIENS_ATTACK is set to 1 AND
//     INFLIGHT_ALIENS[1] is available for use
//
//
// Cheat:
// If you type into the MAME debugger: 
// maincpu.mb@140C=C9
//
// The flagships stop attacking you completely.
//

HANDLE_FLAGSHIP_ATTACK:
140C: 3A 20 42      ld   a,($4220)           // read HAVE_NO_ALIENS_IN_SWARM flag           
140F: 0F            rrca                     // move flag into carry
1410: D8            ret  c                   // return if no aliens in the swarm.
1411: 3A 00 42      ld   a,($4200)           // read HAS_PLAYER_SPAWNED
1414: 0F            rrca                     // move flag into carry
1415: D0            ret  nc                  // return if player has not spawned.
1416: 3A 29 42      ld   a,($4229)           // read CAN_FLAGSHIP_OR_RED_ALIENS_ATTACK
1419: 0F            rrca                     // move flag into carry
141A: D0            ret  nc                  // return if flag is not set
141B: AF            xor  a
141C: 32 29 42      ld   ($4229),a           // reset CAN_FLAGSHIP_OR_RED_ALIENS_ATTACK flag

// Test if the slot in INFLIGHT_ALIENS reserved for the flagship is in use. If so - do nothing.
141F: 2A D0 42      ld   hl,($42D0)          // read from INFLIGHT_ALIENS[1] which is the 2nd array element
1422: 7C            ld   a,h                 // Load A with INFLIGHT_ALIEN.IsDying flag
1423: B5            or   l                   // OR with INFLIGHT_ALIEN.IsActive flag
1424: 0F            rrca                     // if alien is active or dying, carry will be set
1425: D8            ret  c                   // return if alien is active or dying - the slot for the flagship is in use.

// from what side should the flagship/red aliens attack from?
1426: 3A 15 42      ld   a,($4215)           // read ALIENS_ATTACK_FROM_RIGHT_FLANK flag
1429: 4F            ld   c,a                 // C is used to set INFLIGHT_ALIEN.ArcClockwise flag @ $1466
142A: 0F            rrca                     // move flag into carry
142B: DA BE 14      jp   c,$14BE             // if attacking from right flank, jump to TRY_FIND_FLAGSHIP_OR_RED_ALIEN_TO_ATTACK_FROM_RIGHT_FLANK


TRY_FIND_FLAGSHIP_OR_RED_ALIEN_TO_ATTACK_FROM_LEFT_FLANK:
142E: 21 79 41      ld   hl,$4179            // load HL with pointer to leftmost flagship in ALIEN_SWARM_FLAGS
1431: 06 04         ld   b,$04               // scan 4 slots max in the ALIEN_SWARM_FLAGS array to find a flagship
1433: CB 46         bit  0,(hl)              // test if a flagship is present
1435: 20 3B         jr   nz,$1472            // if we have found a flagship, goto INIT_FLAGSHIP_ATTACK_FROM_LEFT_FLANK
1437: 2D            dec  l                   // move to next potential flagship
1438: 10 F9         djnz $1433               // repeat until B==0

// If we can't get a flagship, then we scan the red alien row from left to right to find a red alien to attack.
143A: 2E 6A         ld   l,$6A               // load HL with pointer to leftmost red alien in ALIEN_SWARM_FLAGS
143C: 06 04         ld   b,$04               // scan first 4 red aliens 
143E: CB 46         bit  0,(hl)              // test if an alien is present
1440: 20 04         jr   nz,$1446            // if we have found a red alien, goto TRY_INIT_INFLIGHT_ALIEN
1442: 2D            dec  l                   // bump HL to point to slot of sibling alien
1443: 10 F9         djnz $143E               // repeat until B==0
1445: C9            ret

// 
// Scan the last 4 entries in the INFLIGHT_ALIENS array for an unused slot. 
// If all 4 slots at the end of the array are already in use, exit.
// Otherwise re-use the lastmost free slot for an attacking alien.
//
// Expects:
// HL = pointer to a bit flag in ALIEN_IN_SWARM_FLAGS
//

TRY_INIT_INFLIGHT_ALIEN:
1446: DD 21 90 43   ld   ix,$4390            // address of very last INFLIGHT_ALIEN record in INFLIGHT_ALIENS array 
144A: 11 E0 FF      ld   de,$FFE0            // -32 decimal, which is -sizeof(INFLIGHT_ALIEN)
144D: 06 04         ld   b,$04               
144F: DD 7E 00      ld   a,(ix+$00)          // load A with INFLIGHT_ALIEN.IsActive flag
1452: DD B6 01      or   (ix+$01)            // OR A with INFLIGHT_ALIEN.IsDying flag
1455: 28 05         jr   z,$145C             // if the slot is not used for an active or dying alien, goto INIT_INFLIGHT_ALIEN
1457: DD 19         add  ix,de               // subtract sizeof(INFLIGHT_ALIEN) from IX, to bump IX to previous INFLIGHT_ALIEN record
1459: 10 F4         djnz $144F
145B: C9            ret

//
// Remove an alien from the swarm, and create an inflight alien in its place.
// 
// Expects:
// C = direction alien will break away from swarm. 0 = left, 1 = right
// HL = pointer to entry in ALIEN_SWARM_FLAGS 
// IX = pointer to INFLIGHT_ALIEN struct of alien 
//

INIT_INFLIGHT_ALIEN:
145C: 36 00         ld   (hl),$00            // clear flag in ALIEN_SWARM_FLAGS - effectively removing it from swarm            
145E: DD 36 00 01   ld   (ix+$00),$01        // set INFLIGHT_ALIEN.IsActive
1462: DD 36 02 00   ld   (ix+$02),$00        // reset INFLIGHT_ALIEN.StageOfLife
1466: DD 71 06      ld   (ix+$06),c          // set INFLIGHT_ALIEN.ArcClockwise
1469: DD 75 07      ld   (ix+$07),l          // set INFLIGHT_ALIEN.IndexInSwarm
146C: 16 01         ld   d,$01               // command: DELETE_ALIEN_COMMAND
146E: 5D            ld   e,l                 // parameter: index of alien to delete from the swarm 
146F: C3 F2 08      jp   $08F2               // jump to QUEUE_COMMAND


//
// Given a pointer to a flagship entry in the ALIEN_SWARM_FLAGS array, 
// scan for red aliens in close proximity to the flagship that can be used as an escort.
// Initialise INFLIGHT_ALIEN records for the flagship and any escort as well. 
//
// Expects:
// HL = pointer to entry in flagship row of ALIEN_SWARM_FLAGS
//

INIT_FLAGSHIP_ATTACK_FROM_LEFT_FLANK:
1472: DD 21 D0 42   ld   ix,$42D0            // pointer to INFLIGHT_ALIENS_START+sizeof(INFLIGHT_ALIEN)
1476: CD 5C 14      call $145C               // call INIT_INFLIGHT_ALIEN to make flagship take flight and leave the swarm 
1479: 7D            ld   a,l
147A: D6 0F         sub  $0F     
147C: 6F            ld   l,a                 // bump HL to point at red alien directly below and to right of flagship
147D: FD 21 F0 42   ld   iy,$42F0            // pointer to INFLIGHT_ALIENS_START+(sizeof(INFLIGHT_ALIEN) * 2)
1481: 06 03         ld   b,$03               // we're scanning 3 entries in red aliens row max             
1483: 0E 02         ld   c,$02               // But we only want 2 red aliens as an escort.  
1485: CB 46         bit  0,(hl)              // test for presence of red alien
1487: C4 8E 14      call nz,$148E            // if we have a red alien, try to create an inflight alien  
148A: 2D            dec  l                   // bump HL to point to slot of sibling alien 
148B: 10 F8         djnz $1485               // repeat until B==0
148D: C9            ret

// HL = pointer to entry in ALIEN_SWARM_FLAGS
148E: CD 9B 14      call $149B               // call TRY_INIT_ESCORT_INFLIGHT_ALIEN
1491: 11 20 00      ld   de,$0020            // sizeof(INFLIGHT_ALIEN)
1494: FD 19         add  iy,de               // bump IY to point to next member of INFLIGHT_ALIENS array
1496: 0D            dec  c                   // reduce count of red aliens left to check for use as escort
1497: C0            ret  nz                  // return if we have all the escort we need
1498: 06 01         ld   b,$01
149A: C9            ret


//
// Try to create an escort for a flagship. 
//
// Expects:
// HL = pointer to red alien in ALIEN_SWARM_FLAGS that could be escort
// IX = pointer to INFLIGHT_ALIEN structure (used for flagship)
// IY = pointer to INFLIGHT_ALIEN structure (will be used for escort) 
//
// If the INFLIGHT_ALIEN pointed to by IY is not occupied by an active or dying alien, then
// the record is re-used and marked as active. 
// Otherwise this routine exits.

TRY_INIT_ESCORT_INFLIGHT_ALIEN:
149B: FD CB 00 46   bit  0,(iy+$00)          // test INFLIGHT_ALIEN.IsActive
149F: C0            ret  nz                  // return if flag is set
14A0: FD CB 01 46   bit  0,(iy+$01)          // test INFLIGHT_ALIEN.IsDying
14A4: C0            ret  nz                  // return if flag is set

// OK, we can use the INFLIGHT_ALIEN slot at IY. Let's remove the alien from the swarm
// and create 
14A5: 36 00         ld   (hl),$00            // clear flag in ALIEN_SWARM_FLAGS
14A7: FD 36 00 01   ld   (iy+$00),$01        // set INFLIGHT_ALIEN.IsActive
14AB: FD 36 02 00   ld   (iy+$02),$00        // reset INFLIGHT_ALIEN.StageOfLife
14AF: DD 7E 06      ld   a,(ix+$06)          // read flagship's INFLIGHT_ALIEN.ArcClockwise
14B2: FD 77 06      ld   (iy+$06),a          // set escort INFLIGHT_ALIEN.ArcClockwise so it breaks away in formation.
14B5: FD 75 07      ld   (iy+$07),l          // set escort INFLIGHT_ALIEN.IndexInSwarm
14B8: 16 01         ld   d,$01               // command: DELETE_ALIEN_COMMAND
14BA: 5D            ld   e,l                 // parameter: index of alien to delete from the swarm
14BB: C3 F2 08      jp   $08F2               // jump to QUEUE_COMMAND


TRY_FIND_FLAGSHIP_OR_RED_ALIEN_TO_ATTACK_FROM_RIGHT_FLANK:
14BE: 21 76 41      ld   hl,$4176            // load HL with pointer to rightmost flagship in ALIEN_SWARM_FLAGS
14C1: 06 04         ld   b,$04               // scan max of 4 flagships in array
14C3: CB 46         bit  0,(hl)              // test if a flagship is present
14C5: 20 10         jr   nz,$14D7            // if we have found a flagship, goto INIT_FLAGSHIP_ATTACK_FROM_RIGHT_FLANK
14C7: 2C            inc  l                   // otherwise try looking for a flagship to immediate left
14C8: 10 F9         djnz $14C3               // repeat until B==0

// If we can't find a single flagship, then we try the red alien row. 
14CA: 2E 65         ld   l,$65               // load HL with pointer to rightmost red alien in ALIEN_SWARM_FLAGS array
14CC: 06 04         ld   b,$04               // scan max of 4 slots in array 
14CE: CB 46         bit  0,(hl)              // test if red alien is present
14D0: C2 46 14      jp   nz,$1446            // if we have found a red alien, goto $1446
14D3: 2C            inc  l                   // bump HL to point to slot of sibling alien
14D4: 10 F8         djnz $14CE               // repeat until B==0
14D6: C9            ret


// Near duplicate of INIT_FLAGSHIP_ATTACK_FROM_LEFT_FLANK @$1472, except for the right flank. 
//
// Given a pointer to a flagship entry in the ALIEN_SWARM_FLAGS array, 
// scan for red aliens in close proximity to the flagship that can be used as an escort.
// Initialise INFLIGHT_ALIEN records for the flagship and any escort as well. 
//
// Expects:
// HL = pointer to flag in ALIEN_SWARM_FLAGS representing flagship
//

INIT_FLAGSHIP_ATTACK_FROM_RIGHT_FLANK:
14D7: DD 21 D0 42   ld   ix,$42D0            // pointer to INFLIGHT_ALIENS_START+sizeof(INFLIGHT_ALIEN) 
14DB: CD 5C 14      call $145C               // Remove an alien from the swarm, and create an inflight alien in its place.
14DE: 7D            ld   a,l
14DF: D6 11         sub  $11                 // bump HL to point at red alien directly below and to right of flagship
14E1: 6F            ld   l,a                 
14E2: FD 21 F0 42   ld   iy,$42F0            // pointer to INFLIGHT_ALIENS_START+(sizeof(INFLIGHT_ALIEN) * 2)
14E6: 06 03         ld   b,$03
14E8: 0E 02         ld   c,$02
14EA: CB 46         bit  0,(hl)              // do we have a red alien?
14EC: C4 8E 14      call nz,$148E
14EF: 2C            inc  l
14F0: 10 F8         djnz $14EA
14F2: C9            ret



//
// Increase game difficulty as the level goes on.
//

HANDLE_LEVEL_DIFFICULTY:
14F3: 3A 00 42      ld   a,($4200)           // read HAS_PLAYER_SPAWNED
14F6: 0F            rrca                     // move flag into carry
14F7: D0            ret  nc                  // return if player has not spawned
14F8: 3A 2B 42      ld   a,($422B)           // read IS_FLAGSHIP_HIT
14FB: 0F            rrca                     // move flag into carry
14FC: D8            ret  c                   // return if flagship has been hit

// wait until DIFFICULTY_COUNTER_1 counts down to zero.
14FD: 21 18 42      ld   hl,$4218            // load HL with address of DIFFICULTY_COUNTER_1
1500: 35            dec  (hl)                // decrement counter
1501: C0            ret  nz
1502: 36 3C         ld   (hl),$3C            // reset counter

// DIFFICULTY_COUNTER_1 has reached zero and reset. Decrement DIFFICULTY_COUNTER_2.
1504: 23            inc  hl                  // bump HL to DIFFICULTY_COUNTER_2
1505: 35            dec  (hl)                // decrement counter
1506: C0            ret  nz
1507: 36 14         ld   (hl),$14            // reset counter 

// DIFFICULTY_COUNTER_2 has reached zero. Now up the difficulty level, if we can.
1509: 23            inc  hl                  // bump HL to $421A (DIFFICULTY_EXTRA_VALUE)
150A: 7E            ld   a,(hl)              // read DIFFICULTY_EXTRA_VALUE
150B: FE 07         cp   $07                 // has it reached its maximum value of 7?
150D: C8            ret  z                   // return if so
150E: 30 02         jr   nc,$1512            // if A >= 7 , goto $1512

1510: 34            inc  (hl)                // increment DIFFICULTY_EXTRA_VALUE  
1511: C9            ret

1512: 36 07         ld   (hl),$07            // clamp DIFFICULTY_EXTRA_VALUE to 7
1514: C9            ret


//
// Check if an alien can attack the player.
// For flagships, see $15C3 
//

CHECK_IF_ALIEN_CAN_ATTACK:
1515: 3A 00 42      ld   a,($4200)           // read HAS_PLAYER_SPAWNED
1518: 0F            rrca                     // move flag into carry
1519: D0            ret  nc                  // return if player has not spawned
151A: 3A 20 42      ld   a,($4220)           // read HAVE_NO_ALIENS_IN_SWARM flag
151D: 0F            rrca                     // move flag into carry
151E: D8            ret  c                   // return if we don't have any aliens in the swarm
151F: 3A 2B 42      ld   a,($422B)           // read IS_FLAGSHIP_HIT
1522: 0F            rrca                     // move flag into carry
1523: D8            ret  c                   // return if the flagship has been hit

// Use DIFFICULTY_EXTRA_VALUE and DIFFICULTY_BASE_VALUE to calculate how many secondary counters in the ALIEN_ATTACK_COUNTERS array
// we can decrement. The more counters = the higher probability one of them will count down to zero = higher probability an alien attacks.
1524: 2A 1A 42      ld   hl,($421A)          // load H with DIFFICULTY_BASE_VALUE and L with DIFFICULTY_EXTRA_VALUE
1527: 7C            ld   a,h                 // A = DIFFICULTY_BASE_VALUE value
1528: FE 02         cp   $02
152A: 30 01         jr   nc,$152D            // if DIFFICULTY_BASE_VALUE >=2, goto $152D
152C: AF            xor  a
152D: 85            add  a,l                 // Add DIFFICULTY_EXTRA_VALUE to DIFFICULTY_BASE_VALUE 
152E: E6 0F         and  $0F                 // Ensure value is between 0 and 15
1530: 3C            inc  a                   // Add 1 to ensure it's between 1..16 
1531: 47            ld   b,a                 // B now contains number of counters to decrement

// Decrement ALIEN_ATTACK_MASTER_COUNTER. When it hits zero, we can decrement secondary counters in the ALIEN_ATTACK_MASTER_COUNTERS array.
1532: 21 4A 42      ld   hl,$424A            // load HL with address of ALIEN_ATTACK_MASTER_COUNTER
1535: 11 E3 15      ld   de,$15E3            // load DE with address of ALIEN_ATTACK_COUNTER_DEFAULT_VALUES
1538: 35            dec  (hl)                // decrement ALIEN_ATTACK_MASTER_COUNTER 
1539: 28 05         jr   z,$1540             // if its hit zero, goto $1540 to decrement [B] counters 
153B: AF            xor  a
153C: 32 28 42      ld   ($4228),a           // reset CAN_ALIEN_ATTACK flag. No alien will attack.
153F: C9            ret

// When we get here, ALIEN_ATTACK_MASTER_COUNTER is zero. 
// B specifies how many secondary counters in the ALIEN_ATTACK_COUNTERS array we can decrement. (Max value of 16)
// DE points to a default value to reset the ALIEN_ATTACK_MASTER_COUNTER back to. 
1540: 0E 00         ld   c,$00
1542: 1A            ld   a,(de)              // read default value from table @ $15E3      
1543: 77            ld   (hl),a              // Reset ALIEN_ATTACK_MASTER_COUNTER to its default value

// Decrement B counters in the ALIEN_ATTACK_COUNTERS array. 
// If any of the counters hit zero, reset the counter to its default value and set the CAN_ALIEN_ATTACK flag to 1.
1544: 23            inc  hl                  // bump HL to next secondary counter 
1545: 13            inc  de                  // bump DE to address containing default value to reset secondary counter to when zero 
1546: 35            dec  (hl)                // decrement secondary counter  
1547: CC DF 15      call z,$15DF             // if the secondary counter reaches zero, reset the counter and increment C. Alien will attack!
154A: 10 F8         djnz $1544               // repeat until B==0

// if C is set to a nonzero value then that means that a secondary counter has reached zero. Its time for an alien to attack. 
154C: 79            ld   a,c
154D: A7            and  a                   // test if A is zero 
154E: C8            ret  z                   // exit if so
154F: 3E 01         ld   a,$01 
1551: 32 28 42      ld   ($4228),a           // set CAN_ALIEN_ATTACK flag. Alien will break off from the swarm
1554: C9            ret



//
// This routine is responsible for determining when flagships can attack.
//
//

UPDATE_ATTACK_COUNTERS:
1555: 3A 00 42      ld   a,($4200)           // read HAS_PLAYER_SPAWNED
1558: 0F            rrca                     // move flag into carry
1559: D0            ret  nc                  // return if player has not spawned
155A: 3A EF 41      ld   a,($41EF)           // read HAVE_ALIENS_IN_TOP_ROW 
155D: 0F            rrca                     // move flag into carry
155E: D0            ret  nc                  // return if we have no flagships
155F: 3A 2B 42      ld   a,($422B)           // read IS_FLAGSHIP_HIT 
1562: 0F            rrca                     // move flag into carry
1563: D8            ret  c                   // return if a flagship has been hit
1564: 3A 06 40      ld   a,($4006)           // read IS_GAME_IN_PLAY
1567: 0F            rrca                     // move flag into carry
1568: 30 3D         jr   nc,$15A7            // if game is not in play, goto $15A7      

// wait until FLAGSHIP_ATTACK_MASTER_COUNTER_1 counts down to zero.
156A: 21 45 42      ld   hl,$4245            // load HL with address of FLAGSHIP_ATTACK_MASTER_COUNTER_1
156D: 35            dec  (hl)                // decrement counter
156E: C0            ret  nz                  // exit if counter is not zero
156F: 36 3C         ld   (hl),$3C            // reset counter

// if we have no blue or purple aliens, we don't need to bother with the FLAGSHIP_ATTACK_MASTER_COUNTER_2 countdown. 
1571: 3A 21 42      ld   a,($4221)           // read HAVE_NO_BLUE_OR_PURPLE_ALIENS 
1574: 0F            rrca                     // move flag into carry
1575: 38 2C         jr   c,$15A3             // if there's no blue or purple aliens left, goto $15A3

// otherwise, wait until FLAGSHIP_ATTACK_MASTER_COUNTER_2 counts down to 0.
1577: 23            inc  hl                  // bump HL to FLAGSHIP_ATTACK_MASTER_COUNTER_2
1578: 35            dec  (hl)                // decrement counter
1579: C0            ret  nz                  // return if its not counteed down to zero.
157A: 34            inc  (hl)                // set FLAGSHIP_ATTACK_MASTER_COUNTER_2 to 1

// count how many "extra" flagships we have carried over from previous waves (maximum of 2)
157B: 2A 77 41      ld   hl,($4177)          // point to usually empty flagship entry in ALIEN_SWARM_FLAGS. 
157E: 7C            ld   a,h                 
157F: 85            add  a,l                 // A now = number of *extra* flagships we have                 
1580: E6 03         and  $03                 // ensure that number is between 0..3. (it should be between 0..2 anyway)
1582: 4F            ld   c,a                 // save count of extra flagships in C

// use difficulty settings and count of extra flagships to compute countdown before flagship attack
1583: 2A 1A 42      ld   hl,($421A)          // load H with DIFFICULTY_BASE_VALUE and L with DIFFICULTY_EXTRA_VALUE
1586: 7C            ld   a,h
1587: 85            add  a,l                 // Add DIFFICULTY_BASE_VALUE to DIFFICULTY_EXTRA_VALUE
1588: C8            ret  z                   // exit if both DIFFICULTY_BASE_VALUE and DIFFICULTY_EXTRA_VALUE are 0

1589: 0F            rrca                     // divide A..                     
158A: 0F            rrca                     // by 4
158B: E6 03         and  $03                 // clamp A to 3 maximum.
158D: 2F            cpl                      // A = 255-A.
158E: C6 0A         add  a,$0A               // ensure that A is between $06 and $09
1590: 91            sub  c                   // subtract count of extra flagships
1591: 32 46 42      ld   ($4246),a           // set FLAGSHIP_ATTACK_MASTER_COUNTER_2

// set timer for when flagship will definitely attack.
1594: 07            rlca
1595: 07            rlca
1596: 32 2F 42      ld   ($422F),a           // set FLAGSHIP_ATTACK_SECONDARY_COUNTER

1599: 07            rlca
159A: 32 4A 42      ld   ($424A),a           // set ALIEN_ATTACK_MASTER_COUNTER

// enable timer for flagship to attack.
159D: 3E 01         ld   a,$01
159F: 32 2E 42      ld   ($422E),a           // set ENABLE_FLAGSHIP_ATTACK_SECONDARY_COUNTER
15A2: C9            ret

15A3: 3E 02         ld   a,$02
15A5: 18 ED         jr   $1594


// Called when game is not in play
15A7: 21 45 42      ld   hl,$4245            // load HL with address of FLAGSHIP_ATTACK_MASTER_COUNTER_1
15AA: 35            dec  (hl)               
15AB: C0            ret  nz
15AC: 36 3C         ld   (hl),$3C 
15AE: 23            inc  hl                  // load HL with address of FLAGSHIP_ATTACK_MASTER_COUNTER_2
15AF: 35            dec  (hl)
15B0: C0            ret  nz
15B1: 36 05         ld   (hl),$05

15B3: 3E 5A         ld   a,$5A
15B5: 32 2F 42      ld   ($422F),a           // set FLAGSHIP_ATTACK_SECONDARY_COUNTER

15B8: 3E 2D         ld   a,$2D
15BA: 32 4A 42      ld   ($424A),a           // set ALIEN_ATTACK_MASTER_COUNTER

15BD: 3E 01         ld   a,$01
15BF: 32 2E 42      ld   ($422E),a           // set ENABLE_FLAGSHIP_ATTACK_SECONDARY_COUNTER
15C2: C9            ret


//
// Determines if a flagship can be permitted to attack.
//
// If so, CAN_FLAGSHIP_OR_RED_ALIENS_ATTACK is set to 1.
//


CHECK_IF_FLAGSHIP_CAN_ATTACK:
15C3: 21 2E 42      ld   hl,$422E            // read ENABLE_FLAGSHIP_ATTACK_SECONDARY_COUNTER
15C6: CB 46         bit  0,(hl)              // test flag
15C8: C8            ret  z                   // return if not allowed to count down

// wait until FLAGSHIP_ATTACK_SECONDARY_COUNTER counts down to zero.
15C9: 23            inc  hl                  // bump HL to FLAGSHIP_ATTACK_SECONDARY_COUNTER
15CA: 35            dec  (hl)                // decrement counter
15CB: C0            ret  nz                  // return if counter hasn't reached zero

15CC: 2B            dec  hl                  // bump HL to ENABLE_FLAGSHIP_ATTACK_SECONDARY_COUNTER flag 
15CD: 36 00         ld   (hl),$00            // reset flag
15CF: 3A 00 42      ld   a,($4200)           // read HAS_PLAYER_SPAWNED
15D2: 0F            rrca                     // move flag into carry
15D3: D0            ret  nc                  // return if player has not spawned

// check if we have any flagship
15D4: 3A EF 41      ld   a,($41EF)           // read HAVE_ALIENS_IN_TOP_ROW flag
15D7: 0F            rrca                     // move flag bit into carry
15D8: D0            ret  nc                  // return if no flagships

// yes, we have flagships, set CAN_FLAGSHIP_OR_RED_ALIENS_ATTACK flag
15D9: 3E 01         ld   a,$01
15DB: 32 29 42      ld   ($4229),a           // set CAN_FLAGSHIP_OR_RED_ALIENS_ATTACK
15DE: C9            ret


// A= *DE//
// *HL = A//
// C++
15DF: 1A            ld   a,(de)
15E0: 77            ld   (hl),a
15E1: 0C            inc  c
15E2: C9            ret


// Default values for the corresponding entries in the ALIEN_ATTACK_COUNTERS array.
// e.g. $424A's default value is 5, $424B's default value is $2F, $424C's default is $43...
// When any counter hits zero, it is reset to its default value.
ALIEN_ATTACK_COUNTER_DEFAULT_VALUES: 
15E3:  05 2F 43 77 71 6D 67 65 4F 49 43 3D 3B 35 2B 29


//
// This routine calculates how far away from the player inflight aliens can be before they can start shooting at you.
// 
// The minimum shooting distance increases as more aliens are killed, making the aliens shoot more often.
//  
// See also: $0E54

HANDLE_CALC_INFLIGHT_ALIEN_SHOOTING_DISTANCE:
15F4: 21 E8 41      ld   hl,$41E8            // load HL with address of HAVE_ALIENS_IN_ROW_FLAGS
15F7: 06 04         ld   b,$04               // we're testing potentially 4 pairs of rows.
15F9: 3A 1B 42      ld   a,($421B)           // read DIFFICULTY_BASE_VALUE
15FC: A7            and  a                   // test if zero
15FD: 20 16         jr   nz,$1615            // if non-zero, which it always is, goto $1615

// These two lines of code appear never to be called. This must be for an EASY difficulty level we've not seen.
15FF: 1E 01         ld   e,$01               // multiplier = 1
1601: 16 84         ld   d,$84               // exact X coordinate  

1603: CB 46         bit  0,(hl)              // test for alien presence
1605: 20 09         jr   nz,$1610            // if alien is present, goto $1610

1607: 23            inc  hl                  // bump HL to flag for next row 
1608: CB 46         bit  0,(hl)              // test flag 
160A: 20 04         jr   nz,$1610            // if flag is set, goto $1610

160C: 23            inc  hl                  // bump to next entry in HAVE_ALIENS_IN_ROW_FLAGS
160D: 1C            inc  e                   // increment multiplier (see $0E54 for clarification on how its used)
160E: 10 F3         djnz $1603

1610: ED 53 13 42   ld   ($4213),de          // set INFLIGHT_ALIEN_SHOOT_EXACT_X to D, INFLIGHT_ALIEN_SHOOT_RANGE_MUL to E
1614: C9            ret

1615: 1E 02         ld   e,$02               // multiplier = 2
1617: 16 9D         ld   d,$9D               // exact X coordinate 
1619: 18 E8         jr   $1603

// TODO: I can't find anything calling this. Is this debug code left over?
161B: 1E 03         ld   e,$03
161D: 16 B6         ld   d,$B6
161F: 18 E2         jr   $1603


//
// LEVEL_COMPLETE is set to 1 by this function when: 
// HAVE_NO_ALIENS_IN_SWARM is set to 1 AND
// HAVE_NO_INFLIGHT_OR_DYING_ALIENS is set to 1 AND
// LEVEL_COMPLETE is clear 
               //

               CHECK_IF_LEVEL_IS_COMPLETE:
               1621: 3A 20 42      ld   a,($4220)           // read HAVE_NO_ALIENS_IN_SWARM
               1624: 0F            rrca                     // move flag bit into carry
               1625: D0            ret  nc                  // return if flag is not set, meaning that there are aliens left in the swarm
               1626: 3A 25 42      ld   a,($4225)           // read HAVE_NO_INFLIGHT_OR_DYING_ALIENS
               1629: 0F            rrca                     // move flag bit into carry
               162A: D0            ret  nc                  // return if flag is not set, meaning that there are aliens attacking, or dying
               162B: 3A 22 42      ld   a,($4222)           // read LEVEL_COMPLETE
               162E: 0F            rrca                     // move flag bit into carry
               162F: D8            ret  c                   // return if flag is not set
               1630: 21 01 00      ld   hl,$0001
               1633: 22 22 42      ld   ($4222),hl          // set LEVEL_COMPLETE to 1 and NEXT_LEVEL_DELAY_COUNTER to 0.                  
               1636: C9            ret



               HANDLE_LEVEL_COMPLETE:
               1637: 21 22 42      ld   hl,$4222            // load HL with address of LEVEL_COMPLETE
               163A: CB 46         bit  0,(hl)              // test flag 
               163C: C8            ret  z                   // return if level is not complete

               // OK, level is complete. Wait until NEXT_LEVEL_DELAY_COUNTER to reach 0. 
               163D: 23            inc  hl                  // bump HL to point to NEXT_LEVEL_DELAY_COUNTER
               163E: 35            dec  (hl)                // decrement count
               163F: C0            ret  nz                  // return if count is !=0

               1640: 2B            dec  hl                  // bump HL to point to LEVEL_COMPLETE again.
               1641: 36 00         ld   (hl),$00            // clear LEVEL_COMPLETE flag.

               1643: 11 1B 05      ld   de,$051B            // load DE with address of PACKED_DEFAULT_SWARM_DEFINITION
               1646: CD 46 06      call $0646               // call UNPACK_ALIEN_SWARM 
               1649: AF            xor  a
               164A: 32 1A 42      ld   ($421A),a           // reset DIFFICULTY_EXTRA_VALUE
               164D: 32 5F 42      ld   ($425F),a           // reset TIMING_VARIABLE
               1650: 21 01 00      ld   hl,$0001
               1653: 22 0E 42      ld   ($420E),hl          // set SWARM_SCROLL_VALUE

               // increase game difficulty level, if we can.
               1656: 2A 1B 42      ld   hl,($421B)          // load H with PLAYER_LEVEL and L with DIFFICULTY_BASE_VALUE
               1659: 24            inc  h                   // increment player level 
               165A: 7D            ld   a,l                 // load A with DIFFICULTY_BASE_VALUE
               165B: FE 07         cp   $07                 // are we at max difficulty?
               165D: 28 03         jr   z,$1662             // yes, goto $1662
               165F: 30 22         jr   nc,$1683            // edge case: we're above max difficulty! So clamp difficulty level to 7.
               1661: 3C            inc  a                   // otherwise, increment DIFFICULTY_BASE_VALUE
               1662: 6F            ld   l,a
               1663: 22 1B 42      ld   ($421B),hl          // update PLAYER_LEVEL and DIFFICULTY_BASE_VALUE

               1666: 11 00 07      ld   de,$0700            // command: BOTTOM_OF_SCREEN_INFO_COMMAND, parameter: 0 (DISPLAY_LEVEL_FLAGS)
               1669: CD F2 08      call $08F2               // call QUEUE_COMMAND. 

               // How many flagships survived from the last round? If so, they need to be added into the swarm before the level starts.
               166C: 3A 1E 42      ld   a,($421E)           // get value of FLAGSHIP_SURVIVOR_COUNT into A
               166F: A7            and  a                   // Did any flagships survive from the last round?
               1670: C8            ret  z                   // Return if no flagships survived.
               1671: 21 77 41      ld   hl,$4177            // load HL with address of free slot in flagship row of ALIEN_SWARM_FLAGS
               1674: 36 01         ld   (hl),$01            // create a flagship!
               1676: 3D            dec  a                   //   
               1677: 32 1E 42      ld   ($421E),a           // set value of FLAGSHIP_SURVIVOR_COUNT
               167A: C8            ret  z                   // return if zero. 
               167B: 23            inc  hl                  // bump HL to address of next free slot in flagship row 
               167C: 36 01         ld   (hl),$01            // create a flagship!
               167E: AF            xor  a                
               167F: 32 1E 42      ld   ($421E),a           // clear value of FLAGSHIP_SURVIVOR_COUNT
               1682: C9            ret



               CLAMP_DIFFICULTY_LEVEL:
               1683: 3E 07         ld   a,$07               // maximum value for DIFFICULTY_BASE_VALUE
               1685: C3 62 16      jp   $1662               // set DIFFICULTY_BASE_VALUE 


//
// When you shoot a flagship, the swarm goes into shock for a short period of time. No aliens will break off to attack you.
//

HANDLE_SHOCKED_SWARM:
1688: 21 2B 42      ld   hl,$422B            // load HL with address of IS_FLAGSHIP_HIT flag     
168B: CB 46         bit  0,(hl)              // test flag
168D: C8            ret  z                   // return if flagship has not been hit
168E: 3A 24 42      ld   a,($4224)           // read HAVE_AGGRESSIVE_ALIENS flag
1691: A7            and  a                   // test flag
1692: 20 0B         jr   nz,$169F            // if flag is set, goto $169F 
1694: 3A 21 42      ld   a,($4221)           // read HAVE_NO_BLUE_OR_PURPLE_ALIENS
1697: A7            and  a                   // test flag
1698: 20 05         jr   nz,$169F            // if flag is set, goto $169F
169A: 3A 26 42      ld   a,($4226)           // read HAVE_NO_INFLIGHT_ALIENS
169D: 0F            rrca                     // move flag into carry
169E: D0            ret  nc                  // return if some aliens are inflight
169F: 23            inc  hl                  // bump HL to address of ALIENS_IN_SHOCK_COUNTER
16A0: 35            dec  (hl)                // decrement counter. When it hits zero, aliens will snap out of it!
16A1: C0            ret  nz                  // exit routine if counter non-zero
16A2: 2B            dec  hl                  // bump HL to address of IS_FLAGSHIP_HIT
16A3: 36 00         ld   (hl),$00            // clear flag. Aliens can break off from the swarm to attack again.
16A5: C9            ret

//
// Looks like this might be legacy code imported from an older game// it writes to a port that does nothing
//

16A6: 3A 07 40      ld   a,($4007)            // read IS_GAME_OVER flag
16A9: 0F            rrca                      // move bit 0 into carry
16AA: D8            ret  c                    // if carry set, return
16AB: 21 DF 41      ld   hl,$41DF
16AE: 7E            ld   a,(hl)
16AF: A7            and  a
16B0: C8            ret  z
16B1: 0F            rrca
16B2: 0F            rrca
16B3: 32 04 68      ld   ($6804),a            // Does nothing - this port is not connected
16B6: 35            dec  (hl)
16B7: C9            ret


//
// You may have noticed that when you're close to obliterating the swarm, that the background swarm noises
// get fewer and fewer, until there's no background noise, just the sound of attacking aliens and your bullets.
// This is the routine that handles the background noises. But this isn't the most important thing the routine does. 
// 
// Tucked away here is more important code, which affects the aliens aggressiveness. If you have 3 aliens or less
// in the swarm (inflight aliens don't count), the aliens are enraged and will be far more aggressive.
// Any aliens that take flight to attack you (inflight aliens) will never return to the swarm and keep attacking
// until either you or they are dead.
//
// If you wish to artificially enforce aggressiveness, pause the game and input the following into the MAME debugger:
//
// maincpu.mb@16e3=c9
// maincpu.mb@16e7=c9
// maincpu.pb@4224=1       // note the .pb, not .mb
//
// This will make the aliens attack you constantly - even when you start a new level.

HANDLE_ALIEN_AGGRESSIVENESS:
16B8: 3A 07 40      ld   a,($4007)           // read IS_GAME_OVER flag
16BB: 0F            rrca                     // move flag into carry
16BC: D8            ret  c                   // return if GAME OVER   
16BD: 21 23 41      ld   hl,$4123            // load HL with address of very first alien in ALIEN_SWARM_FLAGS
16C0: 11 06 00      ld   de,$0006            // DE is an offset to add to HL after processing a row of aliens
16C3: 4B            ld   c,e                 // Conveniently, E is also number of rows of aliens in swarm! (6) 
16C4: 3E 01         ld   a,$01               // A is going to be used to total the number of aliens in the swarm 
16C6: 06 0A         ld   b,$0A               // 10 aliens maximum per row
16C8: 86            add  a,(hl)              
16C9: 2C            inc  l                   // bump HL to point to next alien in ALIEN_SWARM_FLAGS
16CA: 10 FC         djnz $16C8               // repeat until all aliens in the row have been done
16CC: 19            add  hl,de               // make HL point to first alien in row above 
16CD: 0D            dec  c                   // do rows until C==0
16CE: C2 C6 16      jp   nz,$16C6

// When we get here, A = total number of aliens left alive in the swarm + 1
16D1: 21 00 68      ld   hl,$6800            // load HL with address of !SOUND  reset background F1 port
16D4: 06 03         ld   b,$03               // number of ports to write to maximum 
16D6: 3D            dec  a                   // decrement total by 1 
16D7: 28 14         jr   z,$16ED             // if total is zero, goto $16ED 

// This piece of code writes 1 to !SOUND  reset background F1 to F3 
16D9: 36 01         ld   (hl),$01            // 
16DB: 2C            inc  l
16DC: 10 F8         djnz $16D6

16DE: FE 02         cp   $02                 //                  
16E0: 38 05         jr   c,$16E7             // 
16E2: AF            xor  a
16E3: 32 24 42      ld   ($4224),a           // clear HAVE_AGGRESSIVE_ALIENS flag
16E6: C9            ret

// This piece of code is only called when there are 3 aliens or less in the swarm.
// It makes the aliens extremely aggressive!
16E7: 3E 01         ld   a,$01
16E9: 32 24 42      ld   ($4224),a           // set HAVE_AGGRESSIVE_ALIENS flag
16EC: C9            ret

// This piece of code writes 0 to !SOUND  reset background F1 to F3
16ED: 36 00         ld   (hl),$00
16EF: 2C            inc  l
16F0: 10 FB         djnz $16ED
16F2: C3 DE 16      jp   $16DE



//
// Main sound handler 
//
//

HANDLE_SOUND:
16F5: AF            xor  a
16F6: 32 C0 41      ld   ($41C0),a           // clear SOUND_VOL
16F9: 3D            dec  a
16FA: 32 C1 41      ld   ($41C1),a           // set PITCH_SOUND_FX_BASE_FREQ value
16FD: CD 47 17      call $1747               // call HANDLE_GAME_START_MELODY
1700: CD D0 17      call $17D0               // call HANDLE_ALIEN_ATTACK_SOUND
1703: CD 19 18      call $1819               // call HANDLE_ALIEN_DEATH_SOUND
1706: CD 5D 17      call $175D               // call HANDLE_COMPLEX_SOUNDS
1709: CD 4F 18      call $184F               // call HANDLE_EXTRA_LIFE_SOUND
170C: CD 76 18      call $1876               // call HANDLE_COIN_INSERT_SOUND
170F: CD 23 17      call $1723               // call HANDLE_PLAYER_SHOOTING_SOUND
1712: 3A C0 41      ld   a,($41C0)           // load A with value of SOUND_VOL
1715: 32 06 68      ld   ($6806),a           // Write to !SOUND Vol of F1
1718: 0F            rrca
1719: 32 07 68      ld   ($6807),a           // Write to !SOUND Vol of f2
171C: 3A C1 41      ld   a,($41C1)           // read PITCH_SOUND_FX_BASE_FREQ value
171F: 32 00 78      ld   ($7800),a           // Write to !Pitch Sound FX base frequency
1722: C9            ret



HANDLE_PLAYER_SHOOTING_SOUND:
1723: 3A CC 41      ld   a,($41CC)           // read PLAY_PLAYER_SHOOT_SOUND flag 
1726: 3D            dec  a                   // decrement value
1727: C2 33 17      jp   nz,$1733            // if the value is nonzero now then it wasn't set to 1 before, so don't play the sound. Goto $1733
172A: 32 CC 41      ld   ($41CC),a           // a is zero, so this sets the shoot flag to false. 
172D: 3E 08         ld   a,$08               // this value here appears to affect the length of the shoot sound. Higher value = longer
172F: 32 CE 41      ld   ($41CE),a           // set PLAYER_SHOOT_SOUND_COUNTER
1732: C9            ret

1733: 3A CE 41      ld   a,($41CE)           // read PLAYER_SHOOT_SOUND_COUNTER 
1736: A7            and  a                   // test if zero
1737: CA 43 17      jp   z,$1743             // if it is zero, goto $1743, which will turn the player shoot sound off
173A: 3D            dec  a                   // reduce counter value by 1.
173B: 32 CE 41      ld   ($41CE),a           // and write updated count back.
173E: 3A 07 40      ld   a,($4007)           // read IS_GAME_OVER flag
1741: EE 01         xor  $01
1743: 32 05 68      ld   ($6805),a           // !SOUND shoot on/off
1746: C9            ret


//
// Plays the GAME START tune.
//

HANDLE_GAME_START_MELODY:
1747: 3A D1 41      ld   a,($41D1)           // read PLAY_GAME_START_MELODY flag
174A: 3D            dec  a                   // if was set to 1, this dec will set zero flag
174B: C0            ret  nz                  // return if PLAY_GAME_START_MELODY wasn't set
174C: 32 D1 41      ld   ($41D1),a           // clear PLAY_GAME_START_MELODY flag
174F: 3C            inc  a
1750: 32 D2 41      ld   ($41D2),a
1753: 32 D6 41      ld   ($41D6),a
1756: 21 68 1E      ld   hl,$1E68
1759: 22 D3 41      ld   ($41D3),hl          // set COMPLEX_SOUND_POINTER
175C: C9            ret




182D: 32 CF 41      ld   ($41CF),a
1830: 32 D6 41      ld   ($41D6),a
1833: 21 BD 1E      ld   hl,$1EBD
1836: 22 D3 41      ld   ($41D3),hl


//
// TODO: Wondering if I should change this label to HANDLE_MONOPHONIC_SOUNDS... maybe best to KISS. 
//
//

HANDLE_COMPLEX_SOUNDS:
175D: 21 D2 41      ld   hl,$41D2
1760: CD 6C 17      call $176C
1763: 21 CF 41      ld   hl,$41CF
1766: CD 6C 17      call $176C
1769: 21 CD 41      ld   hl,$41CD            // pointer to address of IS_COMPLEX_SOUND_PLAYING
176C: 7E            ld   a,(hl)              // read flag
176D: A7            and  a                   // is flag set?
176E: C8            ret  z                   // No, a complex sound isn't playing, so return
176F: EB            ex   de,hl               // OK, now DE = $41CD
1770: 3E 02         ld   a,$02
1772: 32 C0 41      ld   ($41C0),a           // Set value of SOUND_VOL
1775: 3A D5 41      ld   a,($41D5)
1778: 32 C1 41      ld   ($41C1),a           // Set PITCH_SOUND_FX_BASE_FREQ

// wait until counter has hit 0 before getting next musical note or sound effect to play.
177B: 3A D6 41      ld   a,($41D6)           // read DELAY_BEFORE_NEXT_SOUND
177E: 3D            dec  a                   // decrement countdown
177F: C2 A2 17      jp   nz,$17A2            // if count hasn't hit zero, then goto $17A2

// OK, counter is zero, we get musical note or sound effect to play.
1782: 2A D3 41      ld   hl,($41D3)          // read COMPLEX_SOUND_POINTER
1785: 7E            ld   a,(hl)              // read sound to play
1786: FE E0         cp   $E0                 // is this the end of sound marker?
1788: 28 1C         jr   z,$17A6             // if so, then we've finished playing our sounds, goto $17A6
178A: 23            inc  hl                  // bump HL to point to next sound
178B: 22 D3 41      ld   ($41D3),hl          // update COMPLEX_SOUND_POINTER
178E: 47            ld   b,a
178F: E6 1F         and  $1F
1791: 21 A9 17      ld   hl,$17A9
1794: E7            rst  $20                 // call routine to fetch value @ HL + A
1795: 32 D5 41      ld   ($41D5),a
1798: 78            ld   a,b
1799: E6 E0         and  $E0
179B: 07            rlca
179C: 07            rlca
179D: 07            rlca
179E: 21 C8 17      ld   hl,$17C8
17A1: E7            rst  $20                 // call routine to fetch value @ HL + A
17A2: 32 D6 41      ld   ($41D6),a           // set DELAY_BEFORE_NEXT_SOUND
17A5: C9            ret

// DE = $41CD
17A6: AF            xor  a
17A7: 12            ld   (de),a              // Indicate free to play more sounds
17A8: C9            ret

//
//
//
//
//

17A9: FF            rst  $38
17AA: 00            nop
17AB: 40            ld   b,b
17AC: 55            ld   d,l
17AD: 5F            ld   e,a
17AE: 68            ld   l,b
17AF: 70            ld   (hl),b
17B0: 80            add  a,b
17B1: 8E            adc  a,(hl)
17B2: 9A            sbc  a,d
17B3: A0            and  b
17B4: AA            xor  d
17B5: B4            or   h
17B6: B8            cp   b
17B7: C0            ret  nz
17B8: C7            rst  $00
17B9: CD D0 D5      call $D5D0
17BC: DA DC E0      jp   c,$E0DC
17BF: 1C            inc  e
17C0: 35            dec  (hl)
17C1: 87            add  a,a
17C2: A5            and  l
17C3: C4 D3 CA      call nz,$CAD3
17C6: E3            ex   (sp),hl
17C7: E6 


17C8: 01 02 04 08 10 20 40 00            


//
// This routine is responsible for making the "Wheeew" noise as the alien attackers fly down the screen.
// No, I'm not going to call this routine "HANDLE_WHEEW_SOUND" although I was tempted //)
//

HANDLE_ALIEN_ATTACK_SOUND:
17D0: 3A 06 40      ld   a,($4006)           // read IS_GAME_IN_PLAY
17D3: 0F            rrca                     // move bit 0 into carry. If game is in play, carry is set
17D4: D0            ret  nc                  // if carry is not set, game's not in play, return
17D5: 21 C2 41      ld   hl,$41C2
17D8: 7E            ld   a,(hl)
17D9: 3D            dec  a
17DA: C2 E5 17      jp   nz,$17E5
17DD: 77            ld   (hl),a
17DE: 21 02 A0      ld   hl,$A002
17E1: 22 C3 41      ld   ($41C3),hl
17E4: C9            ret

17E5: 3A 26 42      ld   a,($4226)           // read HAVE_NO_INFLIGHT_ALIENS
17E8: 0F            rrca                     // move flag into carry
17E9: D8            ret  c                   // return if there are no aliens in flight
17EA: 23            inc  hl                  // bump HL to point to UNKNOWN_SOUND_41C3
17EB: 3A 5F 42      ld   a,($425F)           // read TIMING_VARIABLE
17EE: 0F            rrca                     // move bit 0 into carry
17EF: 38 10         jr   c,$1801             
17F1: 3A C4 41      ld   a,($41C4)
17F4: FE 60         cp   $60
17F6: 30 01         jr   nc,$17F9
17F8: 34            inc  (hl)
17F9: A7            and  a
17FA: CA 01 18      jp   z,$1801
17FD: 3D            dec  a
17FE: 32 C4 41      ld   ($41C4),a
1801: 7E            ld   a,(hl)
1802: E6 03         and  $03
1804: C2 0C 18      jp   nz,$180C
1807: 3E 60         ld   a,$60
1809: C3 15 18      jp   $1815
180C: 0F            rrca
180D: 3A C4 41      ld   a,($41C4)
1810: 30 03         jr   nc,$1815
1812: C6 60         add  a,$60
1814: 1F            rra
1815: 32 C1 41      ld   ($41C1),a           // Set PITCH_SOUND_FX_BASE_FREQ
1818: C9            ret


//
// Plays the sound of an alien or a flagship when hit.
//
// No death sound will be played if either of the IS_GAME_IN_PLAY or IS_COMPLEX_SOUND_PLAYING flags are set.
//

HANDLE_ALIEN_DEATH_SOUND:
1819: 3A 06 40      ld   a,($4006)           // read IS_GAME_IN_PLAY
181C: 0F            rrca                     // move flag into carry                     
181D: D0            ret  nc                  // if game is not in play, we won't play sound.                

181E: 3A DF 41      ld   a,($41DF)
1821: FE 06         cp   $06                 // Do we want to play the ALIEN DEATH sound?       
1823: C2 3A 18      jp   nz,$183A            // no, goto $183A

1826: 3A CD 41      ld   a,($41CD)           // read IS_COMPLEX_SOUND_PLAYING flag    
1829: 0F            rrca                     // move                                                          
182A: D8            ret  c

182B: 3E 01         ld   a,$01
182D: 32 CF 41      ld   ($41CF),a
1830: 32 D6 41      ld   ($41D6),a
1833: 21 BD 1E      ld   hl,$1EBD
1836: 22 D3 41      ld   ($41D3),hl
1839: C9            ret

183A: FE 16         cp   $16                 // Do we want to play the FLAGSHIP DEATH sound?                 
183C: C0            ret  nz                  // if not, return
183D: AF            xor  a
183E: 32 CF 41      ld   ($41CF),a
1841: 3C            inc  a
1842: 32 CD 41      ld   ($41CD),a
1845: 32 D6 41      ld   ($41D6),a
1848: 21 DF 1E      ld   hl,$1EDF
184B: 22 D3 41      ld   ($41D3),hl
184E: C9            ret

//
//
//
//
//

HANDLE_EXTRA_LIFE_SOUND:
184F: 2A C7 41      ld   hl,($41C7)
1852: CB 45         bit  0,l                 // read PLAY_EXTRA_LIFE_SOUND flag.
1854: CA 5E 18      jp   z,$185E             // if flag is not set, goto $185E.
1857: 21 00 80      ld   hl,$8000            // store 0 in PLAY_EXTRA_LIFE_SOUND and $80 in EXTRA_LIFE_SOUND_COUNTER
185A: 22 C7 41      ld   ($41C7),hl      
185D: C9            ret

// play the extra life sound
185E: 7C            ld   a,h                 // read EXTRA_LIFE_SOUND_COUNTER
185F: A7            and  a                   // test if value is 0.
1860: C8            ret  z                   // return if value is indeed 0.
1861: 3D            dec  a                   // decrement counter
1862: 32 C8 41      ld   ($41C8),a           // update EXTRA_LIFE_SOUND_COUNTER
1865: E6 04         and  $04             
1867: CA 6C 18      jp   z,$186C
186A: 3E 81         ld   a,$81
186C: 3D            dec  a
186D: 32 C1 41      ld   ($41C1),a           // Set PITCH_SOUND_FX_BASE_FREQ
1870: 3E 01         ld   a,$01
1872: 32 C0 41      ld   ($41C0),a           // set SOUND_VOL
1875: C9            ret




HANDLE_COIN_INSERT_SOUND:
1876: 21 C9 41      ld   hl,$41C9            // address of PLAY_PLAYER_CREDIT_SOUND flag
1879: 7E            ld   a,(hl)              // read flag
187A: 3D            dec  a                   
187B: C2 86 18      jp   nz,$1886            // if PLAY_PLAYER_CREDIT_SOUND was not set to 1, goto $1886
187E: 77            ld   (hl),a              // clear flag. 
187F: 21 20 00      ld   hl,$0020            // duration to play sound
1882: 22 CA 41      ld   ($41CA),hl
1885: C9            ret

// play the credit sound
1886: 23            inc  hl                  // bump HL to $41CA, which is address of PLAYER_CREDIT_SOUND_COUNTER               
1887: 7E            ld   a,(hl)              // read value of count
1888: A7            and  a                   // test if its zero
1889: C8            ret  z                   // if its zero, return 
188A: 35            dec  (hl)                // reduce counter
188B: 23            inc  hl                  // bump HL to $41CB
188C: 7E            ld   a,(hl)
188D: C6 04         add  a,$04             
188F: 77            ld   (hl),a
1890: 32 C1 41      ld   ($41C1),a           // Set PITCH_SOUND_FX_BASE_FREQ
1893: AF            xor  a
1894: 32 C0 41      ld   ($41C0),a           // set SOUND_VOL
1897: C9            ret

//
//
// This piece of code is used to make the sound of the swarm "angrier" as the level goes on.
// The longer the level takes to complete, the faster and angrier the swarm is.
// 
//

HANDLE_SWARM_SOUND:
1898: 3A D0 41      ld   a,($41D0)           // read RESET_SWARM_SOUND_TEMPO flag
189B: A7            and  a                   // test if zero
189C: 28 08         jr   z,$18A6             // if zero, goto $18A6
189E: AF            xor  a                   // clear A
189F: 32 D0 41      ld   ($41D0),a           // reset RESET_SWARM_SOUND_TEMPO flag
18A2: 3E 0F         ld   a,$0F               // Maximum (slowest) Tempo setting
18A4: 18 0C         jr   $18B2

18A6: 3A 5F 42      ld   a,($425F)           // read TIMING_VARIABLE
18A9: C6 01         add  a,$01               // add 1 to it
18AB: D0            ret  nc                  // return if no carry. This means the following code will only fire when A == #$FF (255 decimal)
18AC: 3A 1F 42      ld   a,($421F)           // read LFO_FREQ_BITS
18AF: A7            and  a                   // test if zero
18B0: C8            ret  z                   // return if zero
18B1: 3D            dec  a                   // otherwise reduce by 1
18B2: 32 1F 42      ld   ($421F),a           // and update LFO_FREQ_BITS 
18B5: 06 04         ld   b,$04               // We're writing to 4 ports
18B7: 21 04 60      ld   hl,$6004            // !DRIVER Background lfo freq bit0
18BA: 77            ld   (hl),a              // write to port. Only bit 0 of register A matters
18BB: 23            inc  hl                  // bump to next port
18BC: 0F            rrca                     // shift all bits in A one place to right
18BD: 10 FB         djnz $18BA              
18BF: C9            ret


//
// This routine is responsible for scrolling on the SCORE ADVANCE TABLE items.  
// It is not responsible for scrolling the actual alien swarm.
// 

HANDLE_TEXT_SCROLL:
18C0: 3A B0 40      ld   a,($40B0)           // read IS_COLUMN_SCROLLING flag
18C3: 0F            rrca                     // move flag value into carry
18C4: D0            ret  nc                  // return if flag was not set
18C5: 2A B1 40      ld   hl,($40B1)          // Load HL with pointer to scroll attribute data in OBJRAM_BACK_BUF.  
18C8: 7E            ld   a,(hl)              // read scroll value

// We only want to scroll on a new character every 8th pixel. The code below effectively checks if (scroll offset MODULO 8 == 0)
18C9: E6 07         and  $07                 // mask in bits 0..2. We now have a value from 0..7 in A.
18CB: 20 1B         jr   nz,$18E8            // if A is not zero, we don't scroll on a new character yet, goto $18E8.  

18CD: EB            ex   de,hl               // swap HL and DE. This preserves value of HL elsewhere without requiring a PUSH or a store
18CE: 2A B3 40      ld   hl,($40B3)          // HL now is pointer to a character to be scrolled onto screen      
18D1: 7E            ld   a,(hl)              // read character to scroll on
18D2: FE 3F         cp   $3F                 // is this a terminating byte marking the end of the characters to scroll on?
18D4: 28 11         jr   z,$18E7             // if so, goto $18E7

18D6: 23            inc  hl                  // bump pointer to next character 
18D7: 22 B3 40      ld   ($40B3),hl          // and update COLUMN_SCROLL_NEXT_CHAR_PTR pointer 
18DA: D6 30         sub  $30
18DC: 2A B5 40      ld   hl,($40B5)          // get character RAM address to plot character at 
18DF: 77            ld   (hl),a              // store character into character RAM

18E0: 01 E0 FF      ld   bc,$FFE0            // load BC with -32 decimal 
18E3: 09            add  hl,bc               // Add offset to HL. HL now points to character in row above, same column. 
18E4: 22 B5 40      ld   ($40B5),hl          // And update pointer 

18E7: EB            ex   de,hl               // now HL points to scroll attribute data in OBJRAM_BACK_BUF  
18E8: 35            dec  (hl)                // update scroll offset value
18E9: C0            ret  nz                  // exit if scroll offset value is not zero

18EA: AF            xor  a                   // We've scrolled as much as we need to. Stop the scroll.
18EB: 32 B0 40      ld   ($40B0),a           // clear IS_COLUMN_SCROLLING flag
18EE: C9            ret



CHECK_IF_COIN_INSERTED:
18EF: 3A 00 40      ld   a,($4000)           // read stored state of dip switch 1 & 2
18F2: FE 03         cp   $03                 // are dip switches set to FREE PLAY?
18F4: 28 21         jr   z,$1917             // yes, free play enabled, so goto $1917: we don't need to check if coins are inserted
18F6: 21 10 40      ld   hl,$4010            // pointer to PORT_STATE_6000 value
18F9: 7E            ld   a,(hl)              // read value
18FA: 2C            inc  l 
18FB: 2C            inc  l
18FC: 2C            inc  l                   // bump HL to $4013, which is PREV_PORT_STATE_6000 value
18FD: B6            or   (hl)                // combine bits set for current state of port 6000 with bits set from previous state
18FE: 2C            inc  l
18FF: 2C            inc  l                   // bump HL to $4015, which is PREV_PREV_PORT_STATE_6000 value
1900: 2F            cpl                      // flip bits
1901: A6            and  (hl)
1902: 2C            inc  l                   // bump HL to $4016, which is PREV_PREV_PREV_PORT_STATE_6000 value.
1903: A6            and  (hl)
1904: CB 7F         bit  7,a                 // read SERVICE state
1906: 20 16         jr   nz,$191E            // if SERVICE is pressed, goto $191E
1908: E6 03         and  $03                 // mask in COIN 1 & COIN 2 bits, discard rest
190A: C8            ret  z                   // if neither bits are set, meaning no coins inserted, return
190B: 21 04 40      ld   hl,$4004            // address of UNPROCESSED_COINS counter
190E: 34            inc  (hl)                // increment UNPROCESSED_COINS counter
190F: CB 47         bit  0,a                 // test COIN 1 state
1911: C8            ret  z                   // return if no coin inserted
1912: E6 02         and  $02                 // test COIN 2 state
1914: C8            ret  z                   // return if no coin inserted
1915: 34            inc  (hl)                // increment UNPROCESSED_COINS counter
1916: C9            ret

// Only comes here if we have FREE PLAY enabled in the dip switches
1917: 21 00 09      ld   hl,$0900
191A: 22 01 40      ld   ($4001),hl          // set COIN_COUNT to 1 and NUM_CREDITS to 9.
191D: C9            ret

//
// This is called when SERVICE is pressed. 
// 

191E: 21 02 40      ld   hl,$4002            // address of NUM_CREDITS
1921: 7E            ld   a,(hl)              // read number of credits
1922: FE 63         cp   $63                 // compare to 99 (decimal)
1924: D0            ret  nc                  // if A < 99 decimal, return
1925: 34            inc  (hl)                // otherwise, increment number of credits
1926: 3E 01         ld   a,$01
1928: 32 C9 41      ld   ($41C9),a           // Play sound of credit being added
192B: 11 01 07      ld   de,$0701            // command: BOTTOM_OF_SCREEN_INFO_COMMAND, parameter: 1 (invokes DISPLAY_AVAILABLE_CREDIT)
192E: C3 F2 08      jp   $08F2               // jump to QUEUE_COMMAND



HANDLE_UNPROCESSED_COINS:
1931: 21 03 40      ld   hl,$4003            // COIN_CONTROL
1934: 7E            ld   a,(hl)              // Read value
1935: A7            and  a                   // test if zero. Zero means we process unprocessed coins
1936: 20 3C         jr   nz,$1974            // if non-zero goto $1974 - don't bother processing coins.
1938: 2C            inc  l                   // point HL to UNPROCESSED_COINS 
1939: B6            or   (hl)                // Do we have any coins left unprocessed?
193A: C8            ret  z                   // Return if no coins left to be processed.
193B: 35            dec  (hl)                // Otherwise, decrement UNPROCESSED_COINS
193C: 2D            dec  l                   // point HL to $4003, COIN_CONTROL
193D: 36 0F         ld   (hl),$0F            // reset COIN_CONTROL
193F: 3A 00 40      ld   a,($4000)           // read stored state of dip switches 1 & 2
1942: FE 03         cp   $03                 // are both switches set, meaning FREE PLAY?
1944: C8            ret  z                   // yes, so return - we don't bother about coins or credits in this case.
1945: 3D            dec  a                   // have we set dip switches to TWO COINS = 1 PLAY? If so, A will be 0
1946: 28 1C         jr   z,$1964             // yes, goto $1964 to handle TWO COINS 1 PLAY

// Nice piece of code @$194C to add two credits if required with only one CALL. Spot it?   
1948: 21 02 40      ld   hl,$4002            // point HL to NUM_CREDITS
194B: 3D            dec  a                   // have we set dip switches to ONE COIN = 2 PLAYS? If so, A will be 0  
194C: CC 4F 19      call z,$194F             // call code immediately after to add 1 credit, then return from CALL to add another credit!
194F: 7E            ld   a,(hl)              // read number of credits              
1950: FE 63         cp   $63                 // have we reached 99 credits (decimal)?
1952: C8            ret  z                   // yes, so exit, no more credits allowed
1953: 30 0C         jr   nc,$1961            // if we have more than 99 credits (decimal) then goto $1961 - clamp credits to 99.
1955: 34            inc  (hl)                // increment credit count
1956: 3E 01         ld   a,$01
1958: 32 C9 41      ld   ($41C9),a           // Set PLAY_PLAYER_CREDIT_SOUND flag to 1. I think you can guess what this does //)
195B: 11 01 07      ld   de,$0701            // command: BOTTOM_OF_SCREEN_INFO_COMMAND, parameter: 1 (invokes DISPLAY_AVAILABLE_CREDIT)
195E: C3 F2 08      jp   $08F2               // jump to QUEUE_COMMAND

1961: 36 63         ld   (hl),$63            // set NUM_CREDITS to 99 decimal.
1963: C9            ret

// Called when dip switches are set to TWO COINS ONE PLAY
1964: 21 01 40      ld   hl,$4001            // load HL with address of COIN_COUNT
1967: CB 46         bit  0,(hl)              // Have we only inserted one coin? 
1969: 28 06         jr   z,$1971             // if bit test fails, we've not inserted any coins yet, goto $1971
196B: 36 00         ld   (hl),$00            // reset COIN_COUNT to say we've acknowledged coins and awarded extra credit
196D: 2C            inc  l                   // bump HL to point to NUM_CREDITS      
196E: C3 4F 19      jp   $194F               // call routine to add a credit

// Called to reset COIN_COUNT to 1. 
1971: 36 01         ld   (hl),$01
1973: C9            ret


// HL = $4003 (COIN_CONTROL)
1974: 0F            rrca
1975: 0F            rrca
1976: 0F            rrca
1977: 32 03 60      ld   ($6003),a        // write to DRIVER|COIN CONTROL
197A: 35            dec  (hl)
197B: C9            ret


//
// Coin lockout is where an arcade cabinet can physically stop more coins from being inserted.
// This code here prevents the user inserting coins to gain more than 9 credits. 
//

HANDLE_COIN_LOCKOUT:
197C: 3A 02 40      ld   a,($4002)           // read NUM_CREDITS
197F: FE 09         cp   $09                 // compare to 9
1981: 30 06         jr   nc,$1989            // if we have >= 9 credits, goto $1989
1983: 3E 01         ld   a,$01
1985: 32 02 60      ld   ($6002),a           // write to !DRIVER | COIN LOCKOUT
1988: C9            ret
1989: AF            xor  a
198A: 32 02 60      ld   ($6002),a           // write to !DRIVER | COIN LOCKOUT
198D: C9            ret




HANDLE_SIMULATE_PLAYER_IN_ATTRACT_MODE:
198E: 3A 5F 42      ld   a,($425F)           // read TIMING_VARIABLE
1991: C6 09         add  a,$09
1993: E6 1F         and  $1F
1995: C0            ret  nz
1996: 3A 07 40      ld   a,($4007)           // read IS_GAME_OVER flag
1999: 0F            rrca                     // move flag into carry
199A: D0            ret  nc                  // return if its not GAME OVER
199B: 3A 00 42      ld   a,($4200)           // read HAS_PLAYER_SPAWNED
199E: 0F            rrca                     // move flag into carry
199F: D0            ret  nc                  // return if player has not spawned yet

19A0: DD 21 D0 42   ld   ix,$42D0            // pointer to INFLIGHT_ALIENS_START + sizeof(INFLIGHT_ALIEN)
19A4: 06 00         ld   b,$00
19A6: D9            exx
19A7: 11 20 00      ld   de,$0020            // sizeof(INFLIGHT_ALIEN)
19AA: 06 07         ld   b,$07               // 7 aliens to process
19AC: D9            exx
19AD: DD 66 03      ld   h,(ix+$03)          // H = INFLIGHT_ALIEN.X
19B0: DD 6E 04      ld   l,(ix+$04)          // L = INFLIGHT_ALIEN.Y 
19B3: DD 4E 1A      ld   c,(ix+$1a)
19B6: CD 12 1A      call $1A12
19B9: D9            exx
19BA: DD 19         add  ix,de               // bump IX to next INFLIGHT_ALIEN 
19BC: 10 EE         djnz $19AC


19BE: DD 21 60 42   ld   ix,$4260            // load IX with address of ENEMY_BULLETS_START
19C2: 11 05 00      ld   de,$0005            // sizeof(ENEMY_BULLET)
19C5: 06 07         ld   b,$07               // number of enemy bullets
19C7: D9            exx
19C8: DD 66 01      ld   h,(ix+$01)          // H = ENEMY_BULLET.X
19CB: DD 6E 03      ld   l,(ix+$03)          // L = ENEMY_BULLET.YH
19CE: DD 4E 04      ld   c,(ix+$04)          // C = ENEMY_BULLET.YDelta
19D1: CD 12 1A      call $1A12
19D4: D9            exx
19D5: DD 19         add  ix,de               // bump IX to next ENEMY_BULLET
19D7: 10 EE         djnz $19C7

19D9: D9            exx
19DA: 3A 02 42      ld   a,($4202)           // read PLAYER_Y
19DD: 4F            ld   c,a
19DE: 3A 0E 42      ld   a,($420E)           // read SWARM_SCROLL_VALUE
19E1: C6 80         add  a,$80
19E3: 91            sub  c                   // subtract player Y 
19E4: CB 2F         sra  a                   // divide A.... 
19E6: CB 2F         sra  a                   // 
19E8: CB 2F         sra  a                   // 
19EA: CB 2F         sra  a                   // 
19EC: CB 2F         sra  a                   // .. by 32, preserving sign bit
19EE: 80            add  a,b
19EF: CB 2F         sra  a
19F1: 4F            ld   c,a
19F2: CD 3C 00      call $003C               // call GENERATE_RANDOM_NUMBER. Now A = pseudorandom number
19F5: 41            ld   b,c
19F6: 87            add  a,a
19F7: 9F            sbc  a,a
19F8: 20 01         jr   nz,$19FB
19FA: 3C            inc  a
19FB: 80            add  a,b
19FC: C6 01         add  a,$01
19FE: FA 0E 1A      jp   m,$1A0E
1A01: FE 02         cp   $02
1A03: 30 05         jr   nc,$1A0A            
1A05: AF            xor  a
1A06: 32 3F 42      ld   ($423F),a           // set ATTRACT_MODE_FAKE_CONTROLLER value. Ship will move under AI control
1A09: C9            ret

1A0A: 3E 04         ld   a,$04               // simulates player moving LEFT (bit maps to !SW0   p1 left)
1A0C: 18 F8         jr   $1A06               // go set ATTRACT_MODE_FAKE_CONTROLLER 

1A0E: 3E 08         ld   a,$08               // simulates player moving RIGHT (bit maps to !SW0    p1 right)
1A10: 18 F4         jr   $1A06               // go set ATTRACT_MODE_FAKE_CONTROLLER 




//
// This is used in the attract mode to help the simulated player dodge bullets.
//
// Expects:
// IX = pointer to INFLIGHT_ALIEN or ENEMY_BULLET
// H = X coordinate of alien or bullet
// L = Y coordinate of alien or bullet
// C = YDelta of alien/bullet
//
// Returns:
//

1A12: DD CB 00 46   bit  0,(ix+$00)          // test INFLIGHT_ALIEN.IsActive flag
1A16: C8            ret  z                   // exit if alien is not active
1A17: 7C            ld   a,h                 // get X coordinate of alien/bullet
1A18: D6 80         sub  $80                 // subtract 128 decimal
1A1A: D8            ret  c                   // if there's a carry, the alien's not far enough down the screen to be a threat, return                       

1A1B: 1E 00         ld   e,$00
1A1D: D6 34         sub  $34                 // subtract $34 from X coordinate
1A1F: 38 04         jr   c,$1A25
1A21: 1C            inc  e
1A22: D6 34         sub  $34
1A24: D0            ret  nc

1A25: 3A 02 42      ld   a,($4202)           // read PLAYER_Y 
1A28: 95            sub  l                   // subtract Y coordinate of alien/bullet
1A29: D6 40         sub  $40
1A2B: FE 80         cp   $80
1A2D: D0            ret  nc                  // return if A >= $80

1A2E: E6 60         and  $60
1A30: 6F            ld   l,a
                            
1A31: 79            ld   a,c                 // A = YDelta
1A32: E6 80         and  $80
1A34: B5            or   l
1A35: 0F            rrca
1A36: 0F            rrca
1A37: 0F            rrca
1A38: 0F            rrca
1A39: B3            or   e
1A3A: 5F            ld   e,a
1A3B: 16 00         ld   d,$00
1A3D: 21 45 1A      ld   hl,$1A45
1A40: 19            add  hl,de
1A41: 7E            ld   a,(hl)
1A42: 80            add  a,b
1A43: 47            ld   b,a
1A44: C9            ret



1A45: 02 03 FE 02 FF FE 00 FF 00 01 01 02 02 FE FE 03            



//
// Called from $0004.
// 
//
//

INITIALISE_SYSTEM:

// Clear screen 
1A55: 21 00 50      ld   hl,$5000            // address of character RAM
1A58: 06 04         ld   b,$04               // the number of bytes we need to write to clear the screen, divided by 256
1A5A: 3E 10         ld   a,$10               // ordinal of empty character 
1A5C: 77            ld   (hl),a              // write character to screen
1A5D: 2C            inc  l                   // increment low byte of character RAM address to write to
1A5E: C2 5C 1A      jp   nz,$1A5C            // do while low byte is !=0 
1A61: 24            inc  h                   // increment high byte of screen address to write to
1A62: 3A 00 78      ld   a,($7800)           // Kick the watchdog
1A65: 10 F3         djnz $1A5A               // decrement b and if !=0 goto $1A5A

// clear attributes and reset scroll values
1A67: 21 00 58      ld   hl,$5800            // start of screen attribute RAM
1A6A: AF            xor  a                   // clear a 
1A6B: 77            ld   (hl),a              // write 0 to screen attribute RAM. Will both set colour to 0 and reset column scroll.
1A6C: 2C            inc  l                   // increment low byte of attribute RAM address to write to                    
1A6D: C2 6B 1A      jp   nz,$1A6B            // if low byte of pointer has not wrapped to 0, goto $1A6B

// Disable lamps and reset coin control
1A70: AF            xor  a                   // clear a
1A71: 21 00 60      ld   hl,$6000            // pointer to !DRIVER lamp 1
1A74: 06 04         ld   b,$04               // 4 ports to write to, from $6000 - $6003
1A76: 77            ld   (hl),a              // write 0 to port. 
1A77: 23            inc  hl                  // bump HL to point to next port
1A78: 10 FC         djnz $1A76               // do until all ports written to

// Set !DRIVER Background lfo freq bits 0-3 to 1
// HL currently points to $6004, which is !DRIVER Background lfo freq bit0
1A7A: 3C            inc  a                   // set A to 1
1A7B: 06 04         ld   b,$04               // 4 ports to write to, from $6004 - $6007
1A7D: 77            ld   (hl),a              // write to port
1A7E: 23            inc  hl                  // bump HL to point to next port
1A7F: 10 FC         djnz $1A7D               // do until all ports written to

// writes zero to all !SOUND ports
1A81: AF            xor  a                   // clear a
1A82: 06 08         ld   b,$08               // 8 ports to write to, from $6800 - $6807
1A84: 21 00 68      ld   hl,$6800            // pointer to !SOUND reset background F1   
1A87: 77            ld   (hl),a              // write to port
1A88: 23            inc  hl                  // bump HL to point to next port
1A89: 10 FC         djnz $1A87               // do until all ports written to

// writes zero to 9Nregen NMIon, 9Nregen stars on, 9Nregen hflip, 9Nregen vflip
1A8B: 06 08         ld   b,$08
1A8D: 21 01 70      ld   hl,$7001            // pointer to 9Nregen NMIon
1A90: 77            ld   (hl),a              // write to port
1A91: 23            inc  hl                  // bump HL to point to next port
1A92: 10 FC         djnz $1A90

1A94: 3D            dec  a                   // set a to #$FF (255 decimal)
1A95: 32 00 78      ld   ($7800),a           // write to !pitch  Sound Fx base frequency

// Write a batch of bytes with calculated values to an area of working RAM ($4000 - $43FF).
// When the batch has been written, read each byte back and compare to calculated values.
// if the bytes written and read back don't match, you have a RAM error and "BAD RAM 1" will be displayed.

// do the write phase
1A98: 0E 20         ld   c,$20               // number of times to repeat RAM tests
1A9A: 21 00 40      ld   hl,$4000            // pointer to start of RAM
1A9D: 06 04         ld   b,$04               // total number of bytes to write, divided by 256
1A9F: 79            ld   a,c                 // initial seed value 
1AA0: C6 2F         add  a,$2F               // Add #$2F (47 decimal) to seed value

1AA2: 77            ld   (hl),a              // write byte to working RAM
1AA3: 2C            inc  l                   // increment low byte of RAM pointer
1AA4: C2 A0 1A      jp   nz,$1AA0            // if low byte of pointer has not wrapped to 0, goto $1AA0
1AA7: 3C            inc  a                   // increment value of byte to write to RAM
1AA8: 24            inc  h                   // increment high byte of RAM pointer 
1AA9: 10 F5         djnz $1AA0               // do until B==0

// now do the read (verify) phase
1AAB: 21 00 40      ld   hl,$4000            // pointer to start of RAM
1AAE: 06 04         ld   b,$04               // total number of bytes to verify, divided by 256
1AB0: 79            ld   a,c                 // initial seed value 
1AB1: C6 2F         add  a,$2F               // add #$2F (47 decimal) to A, as write phase did
1AB3: BE            cp   (hl)                // compare byte to test RAM integrity
1AB4: 20 45         jr   nz,$1AFB            // if they don't match, there's a RAM error, goto $1AFB
1AB6: 2C            inc  l                   // increment low byte of RAM pointer
1AB7: C2 B1 1A      jp   nz,$1AB1            // if low byte of pointer has not wrapped to 0, goto $1AA0
1ABA: 3C            inc  a                   // increment value of byte expected to be read from RAM
1ABB: 24            inc  h                   // increment high byte of RAM pointer 
1ABC: 10 F3         djnz $1AB1               // do until B==0

1ABE: 3A 00 78      ld   a,($7800)           // Kick the watchdog
1AC1: 0D            dec  c                   // decrement counter of how many times to repeat RAM write and test phases
1AC2: C2 9A 1A      jp   nz,$1A9A            // if the counter !=0, then goto $1A9A

// Write a batch of bytes with calculated values to character RAM ($5000 - $53FF) 
// When the batch has been written, read each byte back and compare to calculated values. 
// If the bytes written and read back don't match, you have a character RAM error and "BAD RAM 2" will be displayed.
// 

// do the character RAM write phase
1AC5: 31 00 44      ld   sp,$4400
1AC8: 0E 20         ld   c,$20               // number of times to repeat RAM tests
1ACA: 21 00 50      ld   hl,$5000            // pointer to character RAM
1ACD: 06 04         ld   b,$04               // total number of bytes to write, divided by 256
1ACF: 79            ld   a,c                 // initial seed value 
1AD0: C6 2F         add  a,$2F               // Add #$2F (47 decimal) to seed value
1AD2: 77            ld   (hl),a              // write byte to character RAM
1AD3: 2C            inc  l                   // increment low byte of RAM pointer
1AD4: C2 D0 1A      jp   nz,$1AD0            // if low byte of pointer has not wrapped to 0, goto $1AD0
1AD7: 3C            inc  a                   // increment value of byte to write to character RAM
1AD8: 24            inc  h                   // increment high byte of RAM pointer 
1AD9: 10 F5         djnz $1AD0               // do until B==0
1ADB: 3A 00 78      ld   a,($7800)           // Kick the watchdog

// now do the character RAM read (verify) phase
1ADE: 21 00 50      ld   hl,$5000            // pointer to character RAM
1AE1: 06 04         ld   b,$04               // total number of bytes to verify, divided by 256
1AE3: 79            ld   a,c                 // initial seed value 
1AE4: C6 2F         add  a,$2F               // add #$2F (47 decimal) to A, as write phase did 
1AE6: BE            cp   (hl)                // compare byte to test character RAM integrity
1AE7: 20 16         jr   nz,$1AFF            // if they don't match, there's a character RAM error, goto $1AFB
1AE9: 2C            inc  l                   // increment low byte of character RAM pointer
1AEA: C2 E4 1A      jp   nz,$1AE4            // if low byte of pointer has not wrapped to 0, goto $1AE4
1AED: 3C            inc  a                   // increment value of byte expected to be read from RAM
1AEE: 24            inc  h                   // increment high byte of RAM pointer 
1AEF: 10 F3         djnz $1AE4               // do until B==0
1AF1: 3A 00 78      ld   a,($7800)           // Kick the watchdog
1AF4: 0D            dec  c
1AF5: C2 CA 1A      jp   nz,$1ACA
1AF8: C3 70 1B      jp   $1B70


// 
// Display "BAD RAM 1" on screen.
//
// This message means there's an error in working memory.
//

DISPLAY_BAD_RAM_1:
1AFB: 3E 01         ld   a,$01               // Error code for BAD RAM 1
1AFD: 18 05         jr   $1B04               // jump to DISPLAY_BAD_RAM_MESSAGE

//
// Display "BAD RAM 2" on screen.
//
// This message means there's an error in the character RAM memory.
// 

BAD_RAM_2:
1AFF: CD 5D 1B      call $1B5D               // call CLEAR_SCREEN
1B02: 3E 02         ld   a,$02               // Error code for BAD RAM 2

//
// Displays "BAD RAM [value in register A]" 
//

DISPLAY_BAD_RAM_MESSAGE:
1B04: 32 F3 51      ld   ($51F3),a           // write number stored in A to screen 
1B07: 11 2D 1B      ld   de,$1B2D            // address of text string "BAD RAM" in reverse

// Called to display "BAD RAM [n]" or "BAD ROM [n]""
DISPLAY_BAD_RAM_OR_ROM_MESSAGE:
1B0A: 21 33 52      ld   hl,$5233            // character RAM address to print text at
1B0D: 01 20 00      ld   bc,$0020            // offset to add to character RAM address after every character drawn
1B10: D9            exx                      // swap to external registers. We want to use B in the other set for a counter
1B11: 06 07         ld   b,$07               // there's 7 characters in "BAD RAM" (including the space between words)
1B13: D9            exx                      // swap back to "normal" registers. 
1B14: 1A            ld   a,(de)              // read character          
1B15: 77            ld   (hl),a              // write to character RAM
1B16: 09            add  hl,bc               // add offset. Now HL points to character beneath. 
1B17: 13            inc  de                  // bump pointer to next character 
1B18: D9            exx                      // swap to external registers. B now has count of characters left to draw.
1B19: 10 F8         djnz $1B13               // Decrement B and if not 0, goto $1B13 to plot remaining characters.
1B1B: AF            xor  a
1B1C: 32 01 70      ld   ($7001),a           // Set flag for NMI to read
1B1F: 3A 00 78      ld   a,($7800)           // Kick the watchdog
1B22: 3A 00 60      ld   a,($6000)           // read coin, p1 control, test & service state
1B25: E6 40         and  $40                 // mask in !SW0 TEST button bit
1B27: C2 1B 1B      jp   nz,$1B1B            // if TEST button is pressed, goto $1B1B. I think this is a bug. Should be jp Z.
1B2A: C3 00 00      jp   $0000               // ... do self test again. Doesn't give user long to see the text!!!

1B2D:
// Text for "BAD RAM" - in reverse. Not ASCII so you won't see it in the MAME debugger.
// M  A  R     D  A  B
 1D 11 22 10 14 11 12
 

 //
 // A = checksum that caused ROM test to fail
 //
 //

ROM_CHECKSUM_ERROR:
1B34: 4F            ld   c,a                 // load C with incorrect checksum
1B35: 3A 00 60      ld   a,($6000)           // read coin, p1 control, test & service state 
1B38: 47            ld   b,a
1B39: 3A 00 68      ld   a,($6800)           // read start button, p2 control, dipsw 1/2 state 
1B3C: A0            and  b
1B3D: E6 04         and  $04
1B3F: 28 10         jr   z,$1B51
1B41: 79            ld   a,c                 // load A with incorrect checksum
1B42: E6 0F         and  $0F                 // mask in lower nibble
1B44: 32 D3 51      ld   ($51D3),a           // write to character RAM
1B47: 79            ld   a,c
1B48: 0F            rrca
1B49: 0F            rrca
1B4A: 0F            rrca
1B4B: 0F            rrca
1B4C: E6 0F         and  $0F
1B4E: 32 F3 51      ld   ($51F3),a           // write to character RAM
1B51: 11 56 1B      ld   de,$1B56            // address of text "BAD ROM" in reverse
1B54: 18 B4         jr   $1B0A               // call DISPLAY_BAD_RAM_OR_ROM_MESSAGE


1B56: 
// Text for "BAD ROM" - in reverse. Not ASCII so you won't see it in the MAME debugger.
// M  O  R     D  A  B
 1D 1F 22 10 14 11 12 



CLEAR_SCREEN:
1B5D: 21 00 50      ld   hl,$5000            // start address of character RAM 
1B60: 06 04         ld   b,$04               // total number of bytes in character RAM, divided by 256
1B62: 3E 10         ld   a,$10               // ordinal for empty character 
1B64: 77            ld   (hl),a              // write character
1B65: 2C            inc  l
1B66: C2 64 1B      jp   nz,$1B64
1B69: 24            inc  h
1B6A: 3A 00 78      ld   a,($7800)           // Kick the watchdog
1B6D: 10 F3         djnz $1B62
1B6F: C9            ret



//
// ROM checksum
//
//

ROM_CHECKSUM:
1B70: CD 5D 1B      call $1B5D               // call CLEAR_SCREEN
1B73: 21 00 00      ld   hl,$0000            // point HL to start of ROM
1B76: 06 28         ld   b,$28               // B holds number of bytes we need to read  
1B78: AF            xor  a                   // A will be used to hold checksum
1B79: 86            add  a,(hl)              // add byte read from ROM to checksum value
1B7A: 2C            inc  l                   // increment low byte of ROM pointer
1B7B: C2 79 1B      jp   nz,$1B79            // if low byte has not wrapped to 0, goto $1B79
1B7E: 24            inc  h                   // Otherwise increment high byte of ROM pointer
1B7F: 4F            ld   c,a                 // Save current checksum value in C
1B80: 3A 00 78      ld   a,($7800)           // Kick the watchdog
1B83: 79            ld   a,c                 // Restore current checksum value from C
1B84: 10 F3         djnz $1B79               // Loop until B == 0
1B86: A7            and  a                   // Test if checksum total is 0
1B87: C2 34 1B      jp   nz,$1B34            // If checksum total is not 0, then display BAD ROM message

// When we get here, all the diagnostic tests have succeeded. 
// There are no errors, and the game can start proper.

ALL_TESTS_HAVE_PASSED:
1B8A: 21 00 40      ld   hl,$4000            // Start of working RAM
1B8D: 06 C0         ld   b,$C0
1B8F: D7            rst  $10                 // Fill B bytes of memory from HL with value in A.
1B90: 3D            dec  a
1B91: 06 40         ld   b,$40
1B93: D7            rst  $10                 // Fill B bytes of memory from HL with value in A.
1B94: AF            xor  a
1B95: D7            rst  $10                 // Fill B bytes of memory from HL with value in A.
1B96: D7            rst  $10                 // Fill B bytes of memory from HL with value in A.
1B97: 06 A0         ld   b,$A0
1B99: D7            rst  $10                 // Fill B bytes of memory from HL with value in A.
1B9A: 32 01 70      ld   ($7001),a           // clear 9Nregen NMIon
1B9D: 32 05 70      ld   ($7005),a
1BA0: 32 06 70      ld   ($7006),a           // set "regen hflip" to 0
1BA3: 32 07 70      ld   ($7007),a           // set "regen vflip" to 0
1BA6: 32 18 40      ld   ($4018),a           // set DISPLAY_IS_COCKTAIL_P2 to 0
1BA9: 3A 00 78      ld   a,($7800)           // Kick the watchdog
1BAC: 3E 20         ld   a,$20
1BAE: 32 08 40      ld   ($4008),a           // set TEMP_COUNTER_1
1BB1: 3E 03         ld   a,$03
1BB3: 32 1A 40      ld   ($401A),a           // set DIAGNOSTIC_MESSAGE_TYPE to 1.
1BB6: 21 C0 C0      ld   hl,$C0C0            
1BB9: 22 A0 40      ld   ($40A0),hl          // reset CIRC_CMD_QUEUE_PTR_LO and CIRC_CMD_QUEUE_PROC_LO
1BBC: 3E 01         ld   a,$01
1BBE: 32 04 70      ld   ($7004),a           // Set 9Nregen stars on. Starry background now appears 
1BC1: 32 02 70      ld   ($7002),a           // Does nothing
1BC4: 32 03 70      ld   ($7003),a           // Does nothing
1BC7: 32 01 70      ld   ($7001),a           // Enable 9Nregen NMIon
1BCA: C3 00 20      jp   $2000


//
//
// This is invoked by the NMI when the contents of $401A (DIAGNOSTIC_MESSAGE_TYPE) are non-zero.
//
// Value in A                        Action taken
// =================================================================================================================
// 1                                 Invokes HANDLE_SERVICE_MODE (displays Dip switch settings, performs sound test)
// 2                                 Invokes CHARACTER_RAM_COLOUR_TEST (displays a coloured grid)
// 3                                 Invokes OBJRAM_TEST: test attributes & sprites for (value held in $4008) times
// Any other value                   Back to self-test
//
//

HANDLE_DIAGNOSTICS:
1BCD: 21 D8 00      ld   hl,$00D8            // address of exit code in NMI handler
1BD0: E5            push hl                  // push return address onto stack. When RET hit, this will be jumped to
1BD1: 3D            dec  a
1BD2: CA 3A 1C      jp   z,$1C3A             // if A was 1 on entry, goto $1C3A (HANDLE_SERVICE_MODE)
1BD5: 3D            dec  a
1BD6: CA 28 1D      jp   z,$1D28             // if A was 2 on entry, goto $1D28
1BD9: 3D            dec  a
1BDA: C2 00 00      jp   nz,$0000            // if value is !=0 then back to self-test


// Write a batch of bytes with calculated values to an area of OBJRAM ($5800 - $58FF).
// When the batch has been written, read each byte back and compare to calculated values.
// if the bytes written and read back don't match, you have an OBJECT RAM error and "BAD RAM 3" will be displayed.

OBJRAM_TEST:
// First write random values to OBJRAM
1BDD: 21 00 58      ld   hl,$5800            // Start of OBJRAM
1BE0: 3A 1E 40      ld   a,($401E)           // use RAND_NUMBER as our seed number.
1BE3: 77            ld   (hl),a              // write to OBJRAM
1BE4: C6 2F         add  a,$2F               // add #$2F (47 decimal) to number just written
1BE6: 2C            inc  l                   // increment low byte of OBJRAM pointer
1BE7: C2 E3 1B      jp   nz,$1BE3            // if low byte has not wrapped to 0, goto $1BE3

// Second, read values from OBJRAM and verify.
1BEA: 3A 1E 40      ld   a,($401E)           // use RAND_NUMBER as our seed number.            
1BED: BE            cp   (hl)                // read from OBJRAM and compare 
1BEE: 20 3C         jr   nz,$1C2C            // if the value read from OBJRAM doesn't match what we expect, goto DISPLAY_BAD_RAM_3
1BF0: C6 2F         add  a,$2F               // add #$2F (47 decimal) to number just written
1BF2: 2C            inc  l                   // increment low byte of OBJRAM pointer
1BF3: C2 ED 1B      jp   nz,$1BED            // if low byte has not wrapped to 0, goto $1BED

1BF6: 3A 00 78      ld   a,($7800)           // Kick the watchdog
1BF9: CD 3C 00      call $003C               // call GENERATE_RANDOM_NUMBER
1BFC: 21 08 40      ld   hl,$4008            // pointer to count of how many times to repeat test
1BFF: 35            dec  (hl)                // decrement value 
1C00: C0            ret  nz                  // if value is 0, return, no more tests to do
1C01: AF            xor  a
1C02: 21 00 58      ld   hl,$5800            // Start of OBJRAM
1C05: 47            ld   b,a                 // 
1C06: D7            rst  $10                 // Fill $5800 to $5900 inclusive with value in A.
1C07: 3E 01         ld   a,$01
1C09: 32 06 40      ld   ($4006),a           // set IS_GAME_IN_PLAY
1C0C: 32 1A 40      ld   ($401A),a
1C0F: 32 00 60      ld   ($6000),a           // write to !DRIVER lamp 1
1C12: 32 01 60      ld   ($6001),a           // write to !DRIVER lamp 2
1C15: 32 02 60      ld   ($6002),a           // write to !DRIVER lamp 3
1C18: 32 26 42      ld   ($4226),a
1C1B: 32 5F 42      ld   ($425F),a           // set TIMING_VARIABLE
1C1E: 32 38 42      ld   ($4238),a
1C21: 3E 1F         ld   a,$1F
1C23: 32 13 52      ld   ($5213),a           // write "O" to screen
1C26: 3E 1B         ld   a,$1B
1C28: 32 F3 51      ld   ($51F3),a           // write "K" to screen
1C2B: C9            ret



DISPLAY_BAD_RAM_3:
1C2C: 21 00 58      ld   hl,$5800            // Start of OBJRAM
1C2F: AF            xor  a                   // value to write
1C30: 77            ld   (hl),a              // write to OBJRAM
1C31: 2C            inc  l                   // increment low byte of pointer
1C32: C2 30 1C      jp   nz,$1C30            // if low byte has not wrapped to 0, goto $1C30
1C35: 3E 03         ld   a,$03               // error number
1C37: C3 04 1B      jp   $1B04               // Jump to DISPLAY_BAD_RAM_MESSAGE, to display BAD RAM 3




HANDLE_SERVICE_MODE:
1C3A: CD F5 16      call $16F5               // call HANDLE_SOUND
1C3D: CD A6 16      call $16A6               // does nothing - must be legacy.
1C40: 3A 00 78      ld   a,($7800)           // Kick the watchdog 
1C43: 3A 00 60      ld   a,($6000)           // read coin, p1 control, test & service state
1C46: 47            ld   b,a                 // save bits in B as A will be corrupted by succeeding operations
1C47: E6 83         and  $83                 // mask in coin1, coin2 and service bits
1C49: 28 05         jr   z,$1C50             // if coin1 or coin2 are not held down, goto $1C50
1C4B: 3E 01         ld   a,$01
1C4D: 32 C9 41      ld   ($41C9),a           // set PLAY_PLAYER_CREDIT_SOUND
1C50: 3A 00 68      ld   a,($6800)           // read start button, p2 control, dipsw 1/2 state 
1C53: 4F            ld   c,a                 // save state in C
1C54: E6 03         and  $03                 // mask in the 1p START and 2p START button states
1C56: 28 05         jr   z,$1C5D             // if no buttons held down, goto $1C5D
1C58: 3E 16         ld   a,$16
1C5A: 32 DF 41      ld   ($41DF),a           // play the sound made when you shoot a Flagship in flight
1C5D: 78            ld   a,b                 // Now A = coin, p1 control, test & service state
1C5E: B1            or   c                   // combine bits with C, which holds start button, p2 control, dipsw 1/2 state 
1C5F: E6 0C         and  $0C                 // mask in the controller bits. Tests if P1 or P2's controllers have been moved left or right
1C61: 28 05         jr   z,$1C68             // if no controllers have been moved, goto $1C68
1C63: 3E 06         ld   a,$06               // otherwise... 
1C65: 32 DF 41      ld   ($41DF),a           // play the sound made when you shoot an alien
1C68: 78            ld   a,b                 // Now A = coin, p1 control, test & service state
1C69: B1            or   c                   // combine bits with C, which holds start button, p2 control, dipsw 1/2 state 
1C6A: E6 10         and  $10                 // mask in the bit for SHOOT 
1C6C: 28 05         jr   z,$1C73             // if no shoot button is pressed, goto $1C73
1C6E: 3E 01         ld   a,$01               // 
1C70: 32 CC 41      ld   ($41CC),a           // set PLAY_PLAYER_SHOOT_SOUND flag

// handle METHOD OF PLAY
1C73: 3A 00 68      ld   a,($6800)           // read start button, p2 control, dipsw 1/2 state 
1C76: 07            rlca                     // move bits 6 & 7 (the state of dip switches 1 & 2)..   
1C77: 07            rlca                     // .. to bits 0 & 1.
1C78: E6 03         and  $03                 // mask in bits 0 & 1, discard everything else.
1C7A: CD CF 1C      call $1CCF               // call DISPLAY_DIP_SWITCH_SETTINGS

// handle BONUS GALIXIP
1C7D: 3A 00 70      ld   a,($7000)           // read state of dip switch 3,4,5,6  
1C80: E6 03         and  $03                 // mask in state of dip switches 3 & 4
1C82: C6 04         add  a,$04
1C84: CD CF 1C      call $1CCF               // call DISPLAY_DIP_SWITCH_SETTINGS

// handle NUMBER OF GALIXIP PER GAME
1C87: 3A 00 70      ld   a,($7000)           // read state of dip switch 3,4,5,6
1C8A: 0F            rrca                     // move bit 2 (the state of dip switch 5)..   
1C8B: 0F            rrca                     // .. to bit 0
1C8C: E6 01         and  $01                 // mask in bit 0, discard everything else
1C8E: C6 08         add  a,$08
1C90: CD CF 1C      call $1CCF               // call DISPLAY_DIP_SWITCH_SETTINGS

1C93: 3A 00 60      ld   a,($6000)           // read coin, p1 control, test & service state   
1C96: E6 40         and  $40                 // read TEST bit
1C98: C0            ret  nz                  // if bit set, return
1C99: AF            xor  a
1C9A: 32 06 40      ld   ($4006),a           // clear IS_GAME_IN_PLAY
1C9D: 3E 02         ld   a,$02
1C9F: 32 1A 40      ld   ($401A),a           // set SCRIPT_STAGE
1CA2: 21 10 30      ld   hl,$3010
1CA5: 22 08 40      ld   ($4008),hl          // set TEMP_COUNTER_1 and TEMP_COUNTER_2 in one go
1CA8: 21 00 50      ld   hl,$5000            // HL = pointer to character RAM
1CAB: 22 0B 40      ld   ($400B),hl          // set TEMP_CHAR_RAM_PTR
1CAE: AF            xor  a
1CAF: 21 00 60      ld   hl,$6000            // point HL to !SW0 
1CB2: 06 04         ld   b,$04
1CB4: D7            rst  $10                 // Fill B bytes of memory from HL with value in A.    

RESET_SOUND:
1CB5: 3E 01         ld   a,$01
1CB7: 21 04 60      ld   hl,$6004            // Address of !DRIVER Background lfo freq bit0
1CBA: 06 04         ld   b,$04
1CBC: D7            rst  $10                 // Fill B bytes of memory from HL with value in A.
1CBD: AF            xor  a
1CBE: 06 08         ld   b,$08
1CC0: 21 00 68      ld   hl,$6800
1CC3: D7            rst  $10                 // Fill B bytes of memory from HL with value in A.
1CC4: 06 05         ld   b,$05
1CC6: 21 01 70      ld   hl,$7001
1CC9: D7            rst  $10                 // Fill B bytes of memory from HL with value in A.
1CCA: 3D            dec  a
1CCB: 32 00 78      ld   ($7800),a
1CCE: C9            ret

//
// Expects:
//
// a = a value from 0..9.
//    
// Value in register A               Displayed on screen
// =====================================================
// 0                                 "1 COIN 1 CREDIT"  
// 1                                 "2 COINS 1 CREDIT" 
// 2                                 "1 COIN 2 CREDITS"
// 3                                 "FREE PLAY"" 
// 4                                 "BONUS  7000" 
// 5                                 "BONUS 10000" 
// 6                                 "BONUS 12000"  
// 7                                 "BONUS 20000" 
// 8                                 "GALIXIP 2" 
// 9                                 "GALIXIP 3"

DISPLAY_DIP_SWITCH_SETTINGS:
1CCF: 47            ld   b,a
1CD0: 87            add  a,a                 // 
1CD1: 87            add  a,a                 // 
1CD2: 80            add  a,b                 // a*=5. (There's 5 bytes per entry in the DIP_SWITCH_SETTINGS_TEXT table.)
1CD3: 5F            ld   e,a
1CD4: 16 00         ld   d,$00               // DE is now offset into DIP_SWITCH_SETTINGS_TEXT table.
1CD6: 21 F6 1C      ld   hl,$1CF6            // pointer to DIP_SWITCH_SETTINGS_TEXT table
1CD9: 19            add  hl,de               // hl+=de. Now HL points to an entry in the table @ 1CF6.

1CDA: 06 02         ld   b,$02               // we want to push 2 values onto stack
1CDC: 5E            ld   e,(hl)              // load E from DIP_SWITCH_SETTINGS_TEXT table               
1CDD: 23            inc  hl
1CDE: 56            ld   d,(hl)              // load D from DIP_SWITCH_SETTINGS_TEXT table
1CDF: 23            inc  hl
1CE0: D5            push de                  // save de on stack. 
1CE1: 10 F9         djnz $1CDC               // do until values pushed on stack

1CE3: 46            ld   b,(hl)              // read count of characters to draw from table
1CE4: D9            exx                      // swap to external Z80 registers
1CE5: E1            pop  hl                  // and pop the 2 values from the stack
1CE6: D1            pop  de
// now HL = pointer to character RAM
// and DE = pointer to text to write
1CE7: 01 E0 FF      ld   bc,$FFE0            // BC = -32 decimal
1CEA: D9            exx                      // swap to "normal" Z80 registers
1CEB: D9            exx
1CEC: 1A            ld   a,(de)              // read character to print  
1CED: D6 30         sub  $30
1CEF: 77            ld   (hl),a              // poke character into character RAM
1CF0: 13            inc  de                       
1CF1: 09            add  hl,bc               // bump character RAM pointer to point to character above one just plotted
1CF2: D9            exx
1CF3: 10 F6         djnz $1CEB
1CF5: C9            ret


//
// Each entry in the table takes 5 bytes:
//
// The first 2 bytes are a pointer to characters to be drawn on screen.
// The next 2 bytes are a pointer to character RAM. The characters will be plotted vertically from that address.
// The last byte is the number of characters to draw.
//

DIP_SWITCH_SETTINGS_TEXT:

1CF6:  
12 1F D6 52 10                               // 1 COIN 1 CREDIT  
22 1F D6 52 10                               // 2 COINS 1 CREDIT 
32 1F D6 52 10                               // 1 COIN 2 CREDITS
42 1F D6 52 10                               // FREE PLAY 

52 1F D8 52 0B                               // BONUS  7000 
5D 1F D8 52 0B                               // BONUS 10000 
68 1F D8 52 0B                               // BONUS 12000  
73 1F D8 52 0B                               // BONUS 20000 


7E 1F DA 52 09                               // GALIXIP 2 
87 1F DA 52 09                               // GALIXIP 3



//
// Character RAM and colour test.
// Displayed, very briefly, on startup.
//
// Value in $4008: represents how many columns of grids you want to display.

CHARACTER_RAM_COLOUR_TEST: 
1D28: 21 08 40      ld   hl,$4008            // load HL with address of TEMP_COUNTER_1
1D2B: 3A 00 78      ld   a,($7800)           // Kick the watchdog
1D2E: 7E            ld   a,(hl)             
1D2F: A7            and  a                   // test if zero
1D30: CA 51 1D      jp   z,$1D51    
1D33: D9            exx
1D34: 2A 0B 40      ld   hl,($400B)          // 
1D37: 06 10         ld   b,$10               // Render 16 pairs of characters on a row..
1D39: 36 30         ld   (hl),$30            // plot top right of square character
1D3B: 23            inc  hl
1D3C: 36 32         ld   (hl),$32            // plot bottom right of square character
1D3E: 23            inc  hl
1D3F: 10 F8         djnz $1D39

1D41: 06 10         ld   b,$10
1D43: 36 34         ld   (hl),$34            // plot top left of square character
1D45: 23            inc  hl
1D46: 36 36         ld   (hl),$36            // plot bottom left of square character
1D48: 23            inc  hl
1D49: 10 F8         djnz $1D43

1D4B: 22 0B 40      ld   ($400B),hl          // set TEMP_CHAR_RAM_PTR
1D4E: D9            exx
1D4F: 35            dec  (hl)                // decrement value in TEMP_COUNTER_1
1D50: C0            ret  nz

1D51: 23            inc  hl                  // bump HL to address of TEMP_COUNTER_2
1D52: 7E            ld   a,(hl)              // read value of TEMP_COUNTER_2
1D53: A7            and  a                   // test if its zero
1D54: 28 02         jr   z,$1D58             // if it's zero, goto $1D58
1D56: 35            dec  (hl)                // otherwise decrement value of TEMP_COUNTER_2
1D57: C0            ret  nz                  // return if value isn't zero.

1D58: 3A 00 60      ld   a,($6000)           // read coin, p1 control, test & service state
1D5B: E6 40         and  $40                 // mask in TEST bit
1D5D: C0            ret  nz                  // return if TEST is on
1D5E: 21 00 50      ld   hl,$5000            // pointer to start of character RAM 
1D61: 22 0B 40      ld   ($400B),hl          // set TEMP_CHAR_RAM_PTR
1D64: 3E 20         ld   a,$20
1D66: 32 08 40      ld   ($4008),a           // set TEMP_COUNTER_1
1D69: AF            xor  a
1D6A: 32 1A 40      ld   ($401A),a           // set DIAGNOSTIC_MESSAGE_TYPE
1D6D: 32 05 40      ld   ($4005),a           // set SCRIPT_NUMBER
1D70: C9            ret



// Referenced by code @ $0595
COLOUR_ATTRIBUTE_TABLE_1:
1D71:  00 05 00 00 01 01 02 03 03 04 04 04 04 00 00 00  
1D81:  00 00 00 05 05 05 05 05 00 00 06 06 06 06 06 06          

// Referenced by code @ $0408
COLOUR_ATTRIBUTE_TABLE_2:
1D91:  00 05 00 00 01 01 02 03 03 04 04 04 04 00 00 00  ................
1DA1:  06 06 06 06 06 06 05 06 06 06 06 06 06 06 06 06  ................

// Referenced by code @ $0212
COLOUR_ATTRIBUTE_TABLE_3:
1DB1:  00 05 00 00 01 01 02 03 05 04 05 04 04 00 00 00  ................
1DC1:  00 06 06 06 06 06 06 06 06 06 00 00 07 07 06 06  ................

// Referenced by code @ $0D1D
1DD1:  00 00 00 00 04 01 04 02 04 01 03 03 02 02 01 02  ................

1DE1: 00            nop
1DE2: 00            nop
1DE3: 00            nop
1DE4: 00            nop
1DE5: 00            nop
1DE6: 00            nop
1DE7: 00            nop
1DE8: 00            nop
1DE9: 00            nop
1DEA: 00            nop
1DEB: 00            nop
1DEC: 00            nop
1DED: 00            nop
1DEE: 00            nop
1DEF: 00            nop
1DF0: 00            nop
1DF1: 00            nop
1DF2: 00            nop
1DF3: 00            nop
1DF4: 00            nop
1DF5: 00            nop
1DF6: 00            nop
1DF7: 00            nop
1DF8: 00            nop
1DF9: 00            nop
1DFA: 00            nop
1DFB: 00            nop
1DFC: 00            nop
1DFD: 00            nop
1DFE: 00            nop
1DFF: 00            nop


//
// Defines the arc to perform a loop the loop maneuvre. 
// Referenced by code @$0D71 and $101F.
//
// The table comprises byte pairs:
//   byte 0: signed offset to add to INFLIGHT_ALIEN.X
//   byte 1: unsigned offset to add to *or* subtract from (depends on which way alien is facing when it breaks off from swarm) INFLIGHT_ALIEN.Y 
//
INFLIGHT_ALIEN_ARC_TABLE:
1E00:  FF 00 FF 00 FF 00 FF 01 FF 00 FF 00 FF 01 FF 00  
1E10:  FF 01 FF 00 00 01 FF 00 FF 01 00 01 FF 00 00 01  
1E20:  FF 01 00 01 FF 01 00 01 00 01 FF 01 00 01 00 01  
1E30:  00 01 00 01 00 01 00 01 01 01 00 01 00 01 01 01  
1E40:  00 01 01 01 00 01 01 00 00 01 01 01 01 00 00 01  
1E50:  01 00 01 01 01 00 01 01 01 00 01 00 01 01 01 00  
1E60:  01 00 01 00 01 00 01                           

//
// GAME START tune. Referenced by $1756
//

1E68:  11 10 0F 0E 0D 0C 0B 0A 09 08 07 41 42 41 42 45  
1E78:  42 45 47 45 47 6A 60 41 42 41 42 45 42 45 47 45  
1E88:  47 6A 60 45 23 24 23 24 23 24 23 24 23 24 23 24  
1E98:  23 24 23 24 02 03 05 06 07 08 09 0A 02 03 05 06  
1EA8:  07 08 09 0A 02 03 05 06 07 08 09 0A 02 03 05 06  
1EB8:  07 08 09 0A E0 

//
// ALIEN DEATH sound effect. Referenced by $1833
//

1EBD:  08 07 06 05 03 02 08 07 06 05 03 02 02 03 05 06  
1ECD:  07 08 09 0A 0B 0C 0D 0E 0F 10 0F 0E 0D 0C 0B 0C  
1EDD:  0D E0 


//
// FLAGSHIP DEATH sound effect. Referenced by $1848
//

1EDF:  02 17 16 01 16 02 03 05 06 07 18 20 07 06 05 03  
1EEF:  02 03 06 07 08 09 0A 19 20 0A 09 08 07 08 0A 0B  
1EFF:  0C 0D 0E 1A 20 0E 0D 0C 0B 0A 0B 0D 0E 0F 10 11  
1F0F:  1B 3C E0 



1F12:  31 40 43 4F 49 4E 40 31 40 43 52 45 44 49 54 40  1@COIN@1@CREDIT@
1F22:  32 40 43 4F 49 4E 53 40 31 40 43 52 45 44 49 54  2@COINS@1@CREDIT
1F32:  31 40 43 4F 49 4E 40 32 40 43 52 45 44 49 54 53  1@COIN@2@CREDITS
1F42:  46 52 45 45 40 50 4C 41 59 40 40 40 40 40 40 40  FREE@PLAY@@@@@@@
1F52:  42 4F 4E 55 53 40 40 37 30 30 30 42 4F 4E 55 53  BONUS@@7000BONUS
1F62:  40 31 30 30 30 30 42 4F 4E 55 53 40 31 32 30 30  @10000BONUS@1200
1F72:  30 42 4F 4E 55 53 40 32 30 30 30 30 47 41 4C 41  0BONUS@20000GALA
1F82:  58 49 50 40 32 47 41 4C 41 58 49 50 40 33        XIP@2GALAXIP@3

1F90: 00            nop
1F91: 00            nop
1F92: 00            nop
1F93: 00            nop
1F94: 00            nop
1F95: 00            nop
1F96: 00            nop
1F97: 00            nop
1F98: 00            nop
1F99: 00            nop
1F9A: 00            nop
1F9B: 00            nop
1F9C: 00            nop
1F9D: 00            nop
1F9E: 00            nop
1F9F: 00            nop
1FA0: 00            nop
1FA1: 00            nop
1FA2: 00            nop
1FA3: 00            nop
1FA4: 00            nop
1FA5: 00            nop
1FA6: 00            nop
1FA7: 00            nop
1FA8: 00            nop
1FA9: 00            nop
1FAA: 00            nop
1FAB: 00            nop
1FAC: 00            nop
1FAD: 00            nop
1FAE: 00            nop
1FAF: 00            nop
1FB0: 00            nop
1FB1: 00            nop
1FB2: 00            nop
1FB3: 00            nop
1FB4: 00            nop
1FB5: 00            nop
1FB6: 00            nop
1FB7: 00            nop
1FB8: 00            nop
1FB9: 00            nop
1FBA: 00            nop
1FBB: 00            nop
1FBC: 00            nop
1FBD: 00            nop
1FBE: 00            nop
1FBF: 00            nop
1FC0: 00            nop
1FC1: 00            nop
1FC2: 00            nop
1FC3: 00            nop
1FC4: 00            nop
1FC5: 00            nop
1FC6: 00            nop
1FC7: 00            nop
1FC8: 00            nop
1FC9: 00            nop
1FCA: 00            nop
1FCB: 00            nop
1FCC: 00            nop
1FCD: 00            nop
1FCE: 00            nop
1FCF: 00            nop
1FD0: 00            nop
1FD1: 00            nop
1FD2: 00            nop
1FD3: 00            nop
1FD4: 00            nop
1FD5: 00            nop
1FD6: 00            nop
1FD7: 00            nop
1FD8: 00            nop
1FD9: 00            nop
1FDA: 00            nop
1FDB: 00            nop
1FDC: 00            nop
1FDD: 00            nop
1FDE: 00            nop
1FDF: 00            nop
1FE0: 00            nop
1FE1: 00            nop
1FE2: 00            nop
1FE3: 00            nop
1FE4: 00            nop
1FE5: 00            nop
1FE6: 00            nop
1FE7: 00            nop
1FE8: 00            nop
1FE9: 00            nop
1FEA: 00            nop
1FEB: 00            nop
1FEC: 00            nop
1FED: 00            nop
1FEE: 00            nop
1FEF: 00            nop
1FF0: 00            nop
1FF1: 00            nop
1FF2: 00            nop
1FF3: 00            nop
1FF4: 00            nop
1FF5: 00            nop
1FF6: 00            nop
1FF7: 00            nop
1FF8: 00            nop
1FF9: 00            nop
1FFA: 00            nop
1FFB: 00            nop
1FFC: 00            nop
1FFD: 00            nop
1FFE: 00            nop
1FFF: 00            nop


// reset all player-related state including score, high score
2000: 21 A2 40      ld   hl,$40A2            // pointer to player 1 state
2003: 06 1E         ld   b,$1E               // number of bytes to write
2005: 36 00         ld   (hl),$00            // write 0 
2007: 23            inc  hl
2008: 10 FB         djnz $2005               // repeat until b==0



//
// Process the circular command queue starting @ $40C0 (CIRC_CMD_QUEUE_START)
//
// Notes:
// The value in $40A1 (I have named it CIRC_CMD_QUEUE_PROC_LO) is the low byte of a pointer to the first entry in 
// the queue to be processed. The high byte of the pointer is always #$40.
// 
// In a circular queue, the first entry to be processed is not necessarily the head of the queue. 
// The first entry to be processed could be anywhere in the queue. 
//
//
// TODO: Detail algorithm

PROCESS_CIRCULAR_COMMAND_QUEUE:
200A: 26 40         ld   h,$40               // high byte of pointer to queue entry be processed
200C: 3A A1 40      ld   a,($40A1)           // read CIRC_CMD_QUEUE_PROC_LO
200F: 6F            ld   l,a                 // now HL = pointer to a queue entry in the queue to be processed 
2010: 7E            ld   a,(hl)              // read command number from queue entry into A. 
2011: 87            add  a,a                 // multiply A by 2 to form an offset into jump table @$203D
2012: 30 05         jr   nc,$2019            // if no carry, then we have a valid command number, goto $2019
2014: CD 67 20      call $2067               // call HANDLE_SWARM_ANIMATION
2017: 18 F1         jr   $200A               // process next entry in circular queue

2019: E6 0F         and  $0F                 // mask in lower nibble
201B: 4F            ld   c,a
201C: 06 00         ld   b,$00               // extend A into BC. BC is now the offset to add to $203D (see code @ $2030)
201E: 36 FF         ld   (hl),$FF            // write #$FF (255 decimal) to first byte of byte pair, to mark it as "free"
2020: 2C            inc  l
2021: 5E            ld   e,(hl)              // read parameter value from queue entry into E. 
2022: 36 FF         ld   (hl),$FF            // write #$FF (255 decimal) to second byte of byte pair, to mark it as "free"
2024: 2C            inc  l
2025: 7D            ld   a,l                 
2026: FE C0         cp   $C0                 // is HL == $4100? If so, comparing L (which will be 0) to #$C0 (192 decimal) will set the carry flag. 
2028: 30 02         jr   nc,$202C            // if carry is not set, then we have not reached the end of the queue ($4100), goto $202C
202A: 3E C0         ld   a,$C0               // otherwise, we have reached end of queue. 
202C: 32 A1 40      ld   ($40A1),a           // Set lo byte of pointer to $C0 ($40C0 = start of circular queue)
202F: 7B            ld   a,e                 // Now A = parameter to command
2030: 21 3D 20      ld   hl,$203D            // pointer to jump table beginning @ $203D
2033: 09            add  hl,bc               // now HL = pointer to entry in jump table
2034: 5E            ld   e,(hl)
2035: 23            inc  hl
2036: 56            ld   d,(hl)              // DE = pointer read from jump table
2037: 21 0A 20      ld   hl,$200A            // return address to go to (entry point of PROCESS_CIRCULAR_COMMAND_QUEUE)
203A: E5            push hl                  // push it onto stack, so when we hit a RET it'll return to $200A
203B: EB            ex   de,hl               // Swap HL and DE round so that HL is pointer read from jump table
203C: E9            jp   (hl)                // jump to code pointed to by (HL)


203D: 
    55 20           // pointer to code @ $2055  (DRAW_ALIEN_COMMAND)
    5E 20           // pointer to code @ $205E  (DELETE_ALIEN_COMMAND) 
    5F 21           // pointer to code @ $215F  (DISPLAY_PLAYER_COMMAND)
    A6 21           // pointer to code @ $21A6  (UPDATE_PLAYER_SCORE_COMMAND)
    FE 21           // pointer to code @ $21FE  (RESET_SCORE_COMMAND)
    31 22           // pointer to code @ $2231  (DISPLAY_SCORE_COMMAND)
    F1 22           // pointer to code @ $22F1  (PRINT_TEXT)
    B7 24           // pointer to code @ $24B7  (DISPLAY_BOTTOM_OF_SCREEN)


204D: E4 7B 73      call po,$737B
2050: 8E            adc  a,(hl)
2051: 10 FF         djnz $2052
2053: FF            rst  $38
2054: FF            rst  $38



//
// Called when an alien rejoins the swarm.
// 

DRAW_ALIEN_COMMAND:
2055: CD E1 20      call $20E1               // call GET_ALIEN_CHAR_RAM_ADDR
2058: CD 04 21      call $2104               // call CHOOSE_ANIMATION_FRAME_FOR_ALIEN_REJOINING_SWARM
205B: C3 31 21      jp   $2131               // jump to DRAW_ALIEN



//
// Called to delete an alien because it's either been killed or it's broken off for an attack.
//

DELETE_ALIEN_COMMAND:
205E: CD E1 20      call $20E1               // call GET_ALIEN_CHAR_RAM_ADDR
2061: DA 83 25      jp   c,$2583             // jump to PLOT_CHARACTERS_2_BY_2_ASCENDING
2064: C3 A7 25      jp   $25A7               // plot two spaces in the same column 


//
// Animates the alien swarm. 
// 
// Can be disabled by setting $4238 (DISABLE_SWARM_ANIMATION) flag to 1.
// 
// Note:
// The WE ARE THE GALAXIANS attract mode screen requires the DISABLE_SWARM_ANIMATION flag set
// because the text overlays where the swarm would be and we don't want it corrupted by the animation routine.
//

HANDLE_SWARM_ANIMATION:
2067: 3A 5F 42      ld   a,($425F)           // read TIMING_VARIABLE
206A: 47            ld   b,a
206B: E6 0F         and  $0F                 // mask in lower nibble
206D: 28 2D         jr   z,$209C             // if lower nibble is 0, goto HANDLE_1UP_2UP_BLINKING 

// A = column of aliens to animate (0-15)
206F: 21 20 41      ld   hl,$4120            // load HL with pointer to bottommost row of aliens in ALIEN_SWARM_FLAGS
2072: 85            add  a,l
2073: 6F            ld   l,a                 // Now HL points to bottommost alien in the column
2074: 3A 38 42      ld   a,($4238)           // read DISABLE_SWARM_ANIMATION flag  
2077: 0F            rrca                     // move bit 0 into carry
2078: D8            ret  c                   // if flag was set, return

// animate each alien in the column
2079: 0E 10         ld   c,$10               // sizeof a row of aliens in ALIEN_SWARM_FLAGS
207B: 06 06         ld   b,$06               // number of rows of aliens to process. 
207D: C5            push bc
207E: E5            push hl
207F: 7D            ld   a,l
2080: CB 46         bit  0,(hl)              // test flag in ALIEN_SWARM_FLAGS to see if alien is present
2082: 20 05         jr   nz,$2089            // if alien is present, goto $2089

2084: CD 5E 20      call $205E               // call DELETE_ALIEN_COMMAND to erase the alien from the screen
2087: 18 0B         jr   $2094

2089: CD E1 20      call $20E1               // call GET_ALIEN_CHAR_RAM_ADDR
208C: 0E 00         ld   c,$00               // load randomness value (see docs for CALCULATE_ALIEN_ANIMATION_FRAME_INDEX)
208E: CD 1D 21      call $211D               // call CALCULATE_ALIEN_ANIMATION_FRAME_INDEX
2091: CD 31 21      call $2131               // call DRAW_ALIEN

2094: E1            pop  hl
2095: C1            pop  bc
2096: 7D            ld   a,l
2097: 81            add  a,c                 
2098: 6F            ld   l,a                 // HL = HL + 16 decimal. Now HL points to alien above, in same column
2099: 10 E2         djnz $207D               // repeat until all rows of aliens done
209B: C9            ret



//
// When the game has a human in control, make 1UP or 2UP "blink".
//
// 1UP never blinks during attract mode, presumably because it distracts the viewer's attention.
//

HANDLE_1UP_2UP_BLINKING:
209C: 3A 06 40      ld   a,($4006)           // read IS_GAME_IN_PLAY flag
209F: A7            and  a                   // test if zero
20A0: 28 05         jr   z,$20A7             // if flag is not set, goto $20A7
20A2: 32 AB 40      ld   ($40AB),a           // set CAN_BLINK_1UP_2UP flag 
20A5: 18 05         jr   $20AC               // goto BLINK_1UP_or_2UP_TEXT


20A7: 3A AB 40      ld   a,($40AB)           // read CAN_BLINK_1UP_2UP
20AA: A7            and  a                   // test if zero
20AB: C8            ret  z                   // if flag is not set, return

//
// This code makes the 1UP or 2UP text blink during the game.
//
// Expects: 
// B = any number (sourced from TIMING_VARIABLE @ $425F). 
//

BLINK_1UP_OR_2UP_TEXT:
20AC: 3A 0D 40      ld   a,($400D)           // read CURRENT_PLAYER
20AF: CD 4E 21      call $214E               // get character RAM address for where 1UP or 2UP is printed
20B2: 11 E0 FF      ld   de,$FFE0            // load DE with -32 decimal
20B5: CB 60         bit  4,b                 // test bit 4 of timing variable value
20B7: 28 14         jr   z,$20CD             // if not set, then draw "1UP" or "2UP"

// erase "1UP" or "2UP" for current player
20B9: 3E 10         ld   a,$10               // ordinal for empty space character
20BB: 77            ld   (hl),a              // erase first character of "1UP" or "2UP"
20BC: 19            add  hl,de               // bump HL to point to character directly above
20BD: 77            ld   (hl),a              // erase second character  
20BE: 19            add  hl,de               // bump HL to point to character directly above
20BF: 77            ld   (hl),a              // erase third character 

20C0: 3A 0E 40      ld   a,($400E)           // read IS_TWO_PLAYER_GAME 
20C3: A7            and  a                   // test flag
20C4: C8            ret  z                   // return if not a two-player game 
20C5: 3A 0D 40      ld   a,($400D)           // read CURRENT_PLAYER 
20C8: EE 01         xor  $01                 // swap between player one and two (0= Player One, 1=Player 2)
20CA: CD 4E 21      call $214E               // get character RAM address for where 1UP or 2UP is printed

// plot "1UP" or "2UP" 
20CD: 3C            inc  a                   // A now is the ordinal for the "1" or "2" character 
20CE: 77            ld   (hl),a              // write "1" or "2"
20CF: 19            add  hl,de
20D0: 36 25         ld   (hl),$25            // 'U'
20D2: 19            add  hl,de
20D3: 36 20         ld   (hl),$20            // 'P'
20D5: CB 60         bit  4,b
20D7: C0            ret  nz
20D8: 3A 06 40      ld   a,($4006)           // read IS_GAME_IN_PLAY
20DB: A7            and  a                   
20DC: C0            ret  nz                  // if game is in play, return
20DD: 32 AB 40      ld   ($40AB),a           // clear CAN_BLINK_1UP_2UP flag.
20E0: C9            ret


// Get character RAM address of alien in swarm. 
//
// Expects:
// A = index of alien in swarm (0-127)
//
// Returns: 
// B = A on entry
// HL = pointer to screen RAM where alien should be plotted
// Carry flag = set if alien is on an "odd" row
// 
// Screen address is calculated as follows:
// Flagship:              $5004 + (column index * $40)      
// Red alien:             $5006 + (column index * $40)      
// Purple alien:          $5007 + (column index * $40)
// Blue alien top row:    $5009 + (column index * $40)
// Blue alien middle row: $500A + (column index * $40)
// Blue alien bottom row: $500C + (column index * $40)
//
// Carry is set when A identifies a Flagship, Purple, Blue Alien Mid row alien. 
//
// I could spend more time figuring out exactly how this code works, but I don't think the benefit outweighs the 
// effort. It's one of those algorithms where I look at it and just don't "get it". I figure if you want to patch it, 
// you could easily create a lookup table - and the lookup table approach would probably be faster than this method.
  
GET_ALIEN_CHAR_RAM_ADDR:
20E1: 47            ld   b,a                 // preserve A in B 
20E2: E6 0F         and  $0F                 // now A is the column index of the alien (0-15). *Clears carry*
20E4: 0F            rrca                     // move bit 0 & bit 1..
20E5: 0F            rrca                     // ..into bits 6 & 7 respectively.
20E6: 4F            ld   c,a
20E7: E6 03         and  $03
20E9: 67            ld   h,a

20EA: 79            ld   a,c
20EB: E6 C0         and  $C0                 
20ED: 6F            ld   l,a

20EE: 78            ld   a,b                 // restore alien index from B (see @$20E1)  
20EF: 0F            rrca                     // divide A..
20F0: 0F            rrca
20F1: 0F            rrca
20F2: 0F            rrca                     // by 16. Now A is a row index.
20F3: E6 07         and  $07                 // Ensure A falls between 0 and 7. >7 is invalid. *also clears carry flag*  
// row 7 = flagship row.  row 2 = blue alien bottom row 
20F5: 4F            ld   c,a                 // save row index in C.
20F6: 1F            rra                      // divide row index by 2. if row index is odd, then set carry flag

// very important that we preserve the carry flag here, because DRAW_ALIEN @ 2131 needs it
20F7: F5            push af
20F8: 89            adc  a,c
20F9: 2F            cpl
20FA: E6 0F         and  $0F
20FC: 85            add  a,l
20FD: 6F            ld   l,a
20FE: 11 00 50      ld   de,$5000            // start of character RAM
2101: 19            add  hl,de
2102: F1            pop  af

2103: C9            ret


//
// This code is called when an alien returns to the swarm and an animation frame needs to be chosen.
//
// Expects:
// B = index of alien (0-127) 
//

CHOOSE_ANIMATION_FRAME_FOR_ALIEN_REJOINING_SWARM:
2104: F5            push af
2105: 78            ld   a,b                 // A = index of alien
2106: FE 70         cp   $70                 // is the index < $70 (112 decimal)
2108: 38 04         jr   c,$210E             // yes, index < $70, goto $210E
210A: 06 80         ld   b,$80               // this is a flagship row - set bit 7 so code @$213F knows   
210C: F1            pop  af
210D: C9            ret

210E: E6 0F         and  $0F                 // A = A MODULO 16. Now A = column of alien
2110: 47            ld   b,a                 // make B = column of alien
2111: 3A 5F 42      ld   a,($425F)           // read TIMING_VARIABLE
2114: E6 0F         and  $0F                 // mask in bits 0..3
2116: 0E 00         ld   c,$00
2118: B8            cp   b
2119: 30 01         jr   nc,$211C            // if A> B goto $211C
211B: 0D            dec  c                   //   
211C: F1            pop  af


// All aliens, except flagships, have 4 possible animation frames. 
//
// This routine calculates an index which is used to look up the correct animation from a table.
//
// Expects: 
// B = index of alien (0-127) 
// C = value to add to calculated index, to make animation frames vary.
//
// Returns:
// B = animation frame index from 0..3

CALCULATE_ALIEN_ANIMATION_FRAME_INDEX:
211D: F5            push af
211E: 78            ld   a,b                 // A now = index of alien
211F: FE 70         cp   $70                 // is the index >= $70 (112 decimal) ?
2121: 30 E7         jr   nc,$210A            // yes, then this is a flagship row, they don't animate, goto $210A
2123: 3A 5F 42      ld   a,($425F)           // read TIMING_VARIABLE
2126: 0F            rrca                     // rotate A..
2127: 0F            rrca
2128: 0F            rrca
2129: 0F            rrca                     // 4 bits right.
212A: 80            add  a,b                 // add in index of alien
212B: 81            add  a,c                 // add in "randomness" value
212C: E6 03         and  $03                 // ensure animation frame index is between 0..3
212E: 47            ld   b,a                 // set B to animation frame index
212F: F1            pop  af
2130: C9            ret



// Draws alien [B] where B is an index into the ALIEN_SWARM_FLAGS array.
//
// For odd rows in the swarm (ie: flagship, purple aliens, blue middle row) the aliens occupy 2 columns x 2 rows of characters.
// For even rows, each alien in the row occupies 1 column and 2rows of characters.
//
//
// Expects:
// B = animation frame index
// HL = character RAM address to plot alien 
// Carry flag = if set, draw characters on odd row  

DRAW_ALIEN:
2131: EB            ex   de,hl
2132: 38 09         jr   c,$213D             // if carry is set, we're drawing an odd row

2134: 21 57 21      ld   hl,$2157            // load HL with pointer to ALIEN_SWARM_CHARACTERS_SET_1x2
2137: 78            ld   a,b                 // load A with animation frame index
2138: E7            rst  $20                 // call routine to fetch value @ HL + A
2139: EB            ex   de,hl
213A: C3 A9 25      jp   $25A9               // jump to PLOT_TWO_CHARACTERS_IN_SAME_COLUMN

// if we get here, we're drawing an "odd" row 
213D: 78            ld   a,b                 // load A with animation frame index
213E: A7            and  a                   // test if its zero
213F: F2 46 21      jp   p,$2146             // if bit 7 is not set (see docs @ $210A) then its not a flagship we're drawing, goto $2146
2142: 3E A4         ld   a,$A4               // starting character for flagship
2144: 18 04         jr   $214A               // draw the flagship

2146: 21 5B 21      ld   hl,$215B            // load HL with address of ALIEN_SWARM_CHARACTERS_SET_2x2 list 
2149: E7            rst  $20                 // call routine to fetch value @ HL + A
214A: EB            ex   de,hl
214B: C3 85 25      jp   $2585               // jump to PLOT_CHARACTERS_2_BY_2_ASCENDING


//
// Expects:
// A = player index
//
// Returns:
// HL = pointer to where first character of 1UP or 2UP will be plotted
//

214E: 21 40 53      ld   hl,$5340            // 1UP
2151: A7            and  a
2152: C8            ret  z
2153: 21 E0 50      ld   hl,$50E0            // 2UP
2156: C9            ret

// start ordinals of characters for 1x2 aliens (see docs @ $2131 and $25A9)
ALIEN_SWARM_CHARACTERS_SET_1x2:
2157: 41 35 41 31

// star ordinals of characters for 2x2 aliens (see docs @ $2131 and $2585)
ALIEN_SWARM_CHARACTERS_SET_2x2:
215B: 44 38 44 3C


//
// Value in register A       Action taken
// =================================================================
// 0:                        Draw player ship in normal, alive state
// 1:                        Erase player ship
// Any other:                Render player ship as exploding
//
// NOTE:
// The player ship isn't a sprite. It's comprised of 4x4 characters. 
//
//

DISPLAY_PLAYER_COMMAND:
215F: A7            and  a                   // test if A is 0
2160: 28 39         jr   z,$219B             // if A is 0, goto DRAW_PLAYER_SHIP
2162: 3D            dec  a                  
2163: 28 22         jr   z,$2187             // if A was 1 on entry, goto ERASE_PLAYER_SHIP
2165: 3D            dec  a      

DRAW_PLAYER_SHIP_EXPLODING:
2166: 87            add  a,a                 // multiply A... 
2167: 87            add  a,a
2168: 87            add  a,a
2169: 87            add  a,a                 // .. by 16 
216A: 2F            cpl
216B: E6 30         and  $30
216D: C6 C0         add  a,$C0
216F: 21 DA 51      ld   hl,$51DA            // character RAM address for top right of explosion
2172: CD 85 25      call $2585               // call PLOT_CHARACTERS_2_BY_2_ASCENDING
2175: 21 DC 51      ld   hl,$51DC            // character RAM address for bottom right of explosion
2178: CD 85 25      call $2585               // call PLOT_CHARACTERS_2_BY_2_ASCENDING
217B: 21 1A 52      ld   hl,$521A            // character RAM address for top left of explosion
217E: CD 85 25      call $2585               // call PLOT_CHARACTERS_2_BY_2_ASCENDING
2181: 21 1C 52      ld   hl,$521C            // character RAM address for bottom left of explosion
2184: C3 85 25      jp   $2585               // call PLOT_CHARACTERS_2_BY_2_ASCENDING

ERASE_PLAYER_SHIP:
2187: 21 DA 51      ld   hl,$51DA
218A: 11 1C 00      ld   de,$001C            // offset to add to HL after drawing characters
218D: 0E 04         ld   c,$04               // row counter: 4 characters high
218F: 06 04         ld   b,$04               // column counter: 4 characters wide
2191: 36 40         ld   (hl),$40            // ordinal for empty character
2193: 23            inc  hl                  // bump to next character on same column
2194: 10 FB         djnz $2191               // do until B==0
2196: 19            add  hl,de               // add offset to HL to point to row beneath
2197: 0D            dec  c                   // decrement row counter
2198: 20 F5         jr   nz,$218F            // if row counter is not 0, goto $218F
219A: C9            ret

DRAW_PLAYER_SHIP:
219B: CD 87 21      call $2187               // erase existing ship or explosion
219E: 3E 60         ld   a,$60               // ordinal of first character to plot
21A0: 21 FC 51      ld   hl,$51FC            // character RAM address
21A3: C3 85 25      jp   $2585               // jump to PLOT_CHARACTERS_2_BY_2_ASCENDING


//
//
// Value in register A       Points added to score
// ===============================================
// 0                         30 
// 1                         40 
// 2                         50 
// 3                         60 
// 4                         70 
// 5                         80 
// 6                         90 
// 7                         100 
// 8                         150 
// 9                         200 
// 10                        300 
// 11                        800 

UPDATE_PLAYER_SCORE_COMMAND:
21A6: 4F            ld   c,a                 // save A in C as the rst corrupts A
21A7: CF            rst  $08                 // assert that it's not GAME OVER 

21A8: CD 90 22      call $2290               // call LEA_DE_OF_CURRENT_PLAYER_SCORE. Now DE = pointer to current player's score
21AB: 79            ld   a,c                 // restore A (points value ID) from C
21AC: 81            add  a,c                 // And then multiply ..
21AD: 81            add  a,c                 // .. A by 3.
21AE: 4F            ld   c,a                   
21AF: 06 00         ld   b,$00               // Extend A into BC. Now BC is an offset into ALIEN_SCORE_TABLE 
21B1: 21 D0 22      ld   hl,$22D0            // pointer to ALIEN_SCORE_TABLE  
21B4: 09            add  hl,bc               // now HL points to an entry in the score table. 
21B5: A7            and  a                   // clear carry flag
21B6: 06 03         ld   b,$03               // Players score is 3 bytes in size
21B8: 1A            ld   a,(de)              // read byte from players score
21B9: 8E            adc  a,(hl)              // add byte from the score table
21BA: 27            daa                      // ensure that the result is valid BCD
21BB: 12            ld   (de),a              // update player score
21BC: 13            inc  de                  // bump to next BCD digits in players score
21BD: 23            inc  hl                  // bump to next BCD digits in alien score
21BE: 10 F8         djnz $21B8               // repeat until all digits in player score have been updated.
21C0: 1B            dec  de                  // point to first 2 digits of player score
21C1: D5            push de
21C2: 1B            dec  de                  // point to 3rd and 4th digits of player score
21C3: 67            ld   h,a                 // load H with first two digits of player score  
21C4: 1A            ld   a,(de)              
21C5: 6F            ld   l,a                 // load L with 3rd and 4th digits of player score
21C6: 29            add  hl,hl
21C7: 29            add  hl,hl
21C8: 29            add  hl,hl
21C9: 29            add  hl,hl               // multiply HL * 16, which shifts all bits left 4 places.  
21CA: 7C            ld   a,h
21CB: 21 AC 40      ld   hl,$40AC            // read BONUS_GALIXIP_FOR value                
21CE: BE            cp   (hl)                    
21CF: D4 9C 22      call nc,$229C            // call AWARD_EXTRA_LIFE if our score is higher
21D2: 13            inc  de
21D3: 3A 0D 40      ld   a,($400D)           // read CURRENT_PLAYER  
21D6: CD 56 22      call $2256               // call DECIDE_TO_DISPLAY_PLAYER_ONE_OR_PLAYER_TWO_SCORE
21D9: D1            pop  de
21DA: 21 AA 40      ld   hl,$40AA            // point to last byte (first 2 digits) of HI_SCORE
21DD: 06 03         ld   b,$03               // Players score is 3 bytes in size
21DF: 1A            ld   a,(de)              // read byte from player score
21E0: BE            cp   (hl)                // compare to byte from high score
21E1: D8            ret  c                   // if byte read is lower than the byte from high score, not new high score, so return 
21E2: 20 05         jr   nz,$21E9            // if byte is different, we have a new high score, goto $21E9
21E4: 1B            dec  de                  // otherwise, bump de 
21E5: 2B            dec  hl                  // and bump hl
21E6: 10 F7         djnz $21DF               // repeat until b==0
21E8: C9            ret


UPDATE_HIGH_SCORE:
21E9: CD 90 22      call $2290               // Now DE = pointer to current player score
21EC: 21 A8 40      ld   hl,$40A8            // address of high score
21EF: 06 03         ld   b,$03               // high score occupies 3 bytes
21F1: 1A            ld   a,(de)              // read byte from player score
21F2: 77            ld   (hl),a              // update byte in high score              
21F3: 13            inc  de                  // bump DE to point to next byte in player score
21F4: 23            inc  hl                  // bump HL to point to next byte in high score
21F5: 10 FA         djnz $21F1
21F7: 1B            dec  de
21F8: DD 21 41 52   ld   ix,$5241            // character RAM address where HIGH SCORE will be drawn
21FC: 18 63         jr   $2261               // jump to PLOT_SCORE_CHARACTERS


//
// Expects:
//
// A is a command.
//                           
// Value in register A       What it represents
// ==================================================================================================
// 0                         Reset player 1's score to 0 and clear PLAYER_ONE_AWARDED_EXTRA_LIFE flag.  
// 1                         Reset player 2's score to 0 and clear PLAYER_TWO_AWARDED_EXTRA_LIFE flag.
// 2                         Reset high score to 0
// 3                         Do all of the above 

RESET_SCORE_COMMAND:
21FE: FE 03         cp   $03                
2200: 30 26         jr   nc,$2228           // if A>= 3 then goto RESET_ALL_SCORES_AND_EXTRA_LIFE_FLAGS
2202: F5            push af
2203: 21 A2 40      ld   hl,$40A2           // address of PLAYER_ONE_SCORE
2206: 11 AD 40      ld   de,$40AD           // address of PLAYER_ONE_AWARDED_EXTRA_LIFE
2209: A7            and  a                  // test if A is 0
220A: 28 0E         jr   z,$221A            // if A was 0 on entry, goto $221A and reset player 1's score

220C: 21 A5 40      ld   hl,$40A5           // address of PLAYER_TWO_SCORE           
220F: 11 AE 40      ld   de,$40AE           // address of PLAYER_TWO_AWARDED_EXTRA_LIFE 
2212: 3D            dec  a                  // if A was 1 on entry, then zero flag will be set after dec.
2213: 28 05         jr   z,$221A            // if zero flag is set, then A was 1 on entry, goto $221A and reset player 2's score
2215: 21 A8 40      ld   hl,$40A8           // address of HI_SCORE
2218: 5D            ld   e,l
2219: 54            ld   d,h                // DE = HL
221A: 36 00         ld   (hl),$00           // clear first byte
221C: 23            inc  hl
221D: 36 00         ld   (hl),$00           // clear second byte
221F: 23            inc  hl
2220: 36 00         ld   (hl),$00           // clear third byte
2222: EB            ex   de,hl
2223: 36 00         ld   (hl),$00           // reset the AWARDED_EXTRA_LIFE flag
2225: F1            pop  af
2226: 18 09         jr   $2231              // Goto DISPLAY_SCORE_COMMAND to display reset scores.

RESET_ALL_SCORES_AND_EXTRA_LIFE_FLAGS:
2228: 3D            dec  a
2229: F5            push af
222A: CD FE 21      call $21FE
222D: F1            pop  af
222E: C8            ret  z
222F: 18 F7         jr   $2228


 
//
// Value in register A       What it represents
// =====================================================
// 0                         Display Player one's score 
// 1                         Display Player two's score 
// 2                         Display high score.
// 3                         Do all of the above.
//

DISPLAY_SCORE_COMMAND:
2231: FE 03         cp   $03
2233: 30 18         jr   nc,$224D            // if A>= #$03, goto $224D, DISPLAY_ALL_SCORES
2235: A7            and  a                   // test if A is 0
2236: 11 A4 40      ld   de,$40A4            // pointer to last 2 BCD digits of PLAYER_ONE_SCORE
2239: 28 1B         jr   z,$2256             // if A is 0, goto $2256 (DECIDE_TO_DISPLAY_PLAYER_ONE_OR_PLAYER_TWO_SCORE)
223B: 3D            dec  a                   // if A was 1 on entry, then Z flag is now set
223C: 20 0A         jr   nz,$2248             
223E: 3A 0E 40      ld   a,($400E)           // read IS_TWO_PLAYER_GAME
2241: A7            and  a                   // test if zero
2242: C8            ret  z                   // if it's zero, then we're just in a single player game, return
2243: 11 A7 40      ld   de,$40A7            // pointer to last 2 BCD digits of PLAYER_TWO_SCORE
2246: 18 0E         jr   $2256               // goto DECIDE_TO_DISPLAY_PLAYER_ONE_OR_PLAYER_TWO_SCORE

DISPLAY_HIGH_SCORE:
2248: 11 AA 40      ld   de,$40AA            // pointer to last 2 BCD digits of HI_SCORE
224B: 18 AB         jr   $21F8

// This displays player scores and high scores
DISPLAY_ALL_SCORES:
224D: 3D            dec  a
224E: F5            push af
224F: CD 31 22      call $2231
2252: F1            pop  af
2253: C8            ret  z
2254: 18 F7         jr   $224D

// 
// Expects:
//
// Value in register A       Action taken                     
// ====================================================
// 0                         Display player one's score       
// 1                         Display player two's score
//      
// DE = pointer to *last* byte of 3 BCD bytes representing a score (ie: player 1 score, player 2 score)

DECIDE_TO_DISPLAY_PLAYER_ONE_OR_PLAYER_TWO_SCORE:
2256: DD 21 81 53   ld   ix,$5381            // pointer to character RAM location for player one's score
225A: A7            and  a                   // test if A is 0.   
225B: 28 04         jr   z,$2261             // if A is 0 then we want to draw player one's score, goto $2261
225D: DD 21 21 51   ld   ix,$5121            // pointer to character RAM location for player two's score


//
// Plot score to the screen. 
//
// Expects:
//
// DE = pointer to *last* byte of 3 BCD bytes representing a score (ie: player 1 score, player 2 score, or high score)
//      See docs for PLAYER_ONE_SCORE to understand how scores are packed as BCD 
//
// IX = pointer to character RAM to begin plotting characters from
//
//

PLOT_SCORE_CHARACTERS:
2261: 21 E0 FF      ld   hl,$FFE0            // load HL with $FFE0 (-32 decimal) 
2264: EB            ex   de,hl               // now HL = pointer to score bytes, DE = offset to add to screen address after plot     
2265: 06 03         ld   b,$03               // a score is 3 bytes in size..                
2267: 0E 04         ld   c,$04               // max number of leading zeros that can be skipped. For example,
                                             // when you start the game you have a score of zero. It renders as "00". 
                                             // So this says "skip the first 4 zeros in the score, but display the rest"
2269: 7E            ld   a,(hl)              // read BCD digits from score byte
226A: 0F            rrca                     // move high nibble (first digit of BCD number)...
226B: 0F            rrca
226C: 0F            rrca
226D: 0F            rrca                     // into lower nibble (second digit). 
226E: CD 79 22      call $2279               // call PLOT_LOWER_NIB_AS_DIGIT to plot the first digit                 
2271: 7E            ld   a,(hl)
2272: CD 79 22      call $2279               // call PLOT_LOWER_NIB_AS_DIGIT to plot the second digit 
2275: 2B            dec  hl                  // bump to *previous* BCD byte
2276: 10 F1         djnz $2269               // do until all BCD digits in score have been drawn
2278: C9            ret


// Pokes a digit of the score to character RAM.
//
// Expects:
//
// Lower nibble of A: BCD digit to be plotted as a character on screen 
// C = max number of leading zero digits in the score that can be skipped. 
// If C is 0, zero digits will always be drawn
// IX = pointer to character RAM where digit will be plotted.

PLOT_LOWER_NIB_AS_DIGIT:
2279: E6 0F         and  $0F                 // mask in lower nibble
227B: 28 04         jr   z,$2281             // if the lower nibble is zero, goto $2281

// OK, we have a nonzero digit. 
227D: 0E 00         ld   c,$00               // tell the plot routine to draw all digits, even if they are zero, from now on
227F: 18 07         jr   $2288               // go plot the character

// we have a zero digit. Do we print it, or print a space instead?
2281: 79            ld   a,c                 // how many zero digits can we skip over?   
2282: A7            and  a                   // test if A is zero
2283: 28 03         jr   z,$2288             // if we can't skip over any more leading zero digits, then goto $2288 to draw "0". 

// Otherwise, we are skipping a leading "0" digit and will print an empty space in its stead..
2285: 3E 80         ld   a,$80               // when added to $90 this will produce $10 (16 decimal) - ordinal for empty character
2287: 0D            dec  c                   // decrement count of leading zeros we are allowed to ignore

2288: C6 90         add  a,$90               // transform A into ordinal of character to be plotted
228A: DD 77 00      ld   (ix+$00),a          // plot character for score to screen
228D: DD 19         add  ix,de               // now IX points to character directly above one just plotted
228F: C9            ret


//
// Load DE with the [effective] address of the current player's score.
// 

LEA_DE_OF_CURRENT_PLAYER_SCORE:
2290: 11 A2 40      ld   de,$40A2            // address of PLAYER_ONE_SCORE
2293: 3A 0D 40      ld   a,($400D)           // read CURRENT_PLAYER           
2296: A7            and  a                   // test if zero
2297: C8            ret  z                   // if it is zero, then current player is player one. Return.
2298: 11 A5 40      ld   de,$40A5            // address of PLAYER_TWO_SCORE
229B: C9            ret





AWARD_EXTRA_LIFE:
229C: 3A 0D 40      ld   a,($400D)           // load CURRENT_PLAYER into A
229F: 21 AD 40      ld   hl,$40AD            // load HL with address of PLAYER_ONE_AWARDED_EXTRA_LIFE flag.
22A2: 85            add  a,l
22A3: 6F            ld   l,a                 // Now HL points to either PLAYER_ONE_AWARDED_EXTRA_LIFE or PLAYER_TWO_AWARDED_EXTRA_LIFE 
22A4: CB 46         bit  0,(hl)              // Test if current player has already had a bonus live given to them.
22A6: C0            ret  nz                  // if flag is set, then return. Player gets no more extra lives.

// player awarded extra life
22A7: 36 01         ld   (hl),$01            // Set "Player has had his extra life" flag
22A9: 3E 01         ld   a,$01
22AB: 32 C7 41      ld   ($41C7),a           // set PLAY_EXTRA_LIFE_SOUND flag.
22AE: 21 1D 42      ld   hl,$421D            // pointer to PLAYER_LIVES
22B1: 34            inc  (hl)                // increment number of lives
22B2: 46            ld   b,(hl)              // read number of player lives into B



DISPLAY_PLAYER_SHIPS_REMAINING:
22B3: 21 9E 53      ld   hl,$539E            // address in character RAM
22B6: 0E 05         ld   c,$05
22B8: 3A 00 42      ld   a,($4200)           // read HAS_PLAYER_SPAWNED
22BB: A7            and  a                   // test if flag is set
22BC: 28 03         jr   z,$22C1                       
22BE: 05            dec  b
22BF: 28 08         jr   z,$22C9
22C1: 3E 66         ld   a,$66
22C3: CD 93 25      call $2593               // plot 2X2 characters
22C6: 0D            dec  c
22C7: 10 F8         djnz $22C1
22C9: 0D            dec  c
22CA: F8            ret  m
22CB: CD 91 25      call $2591               // plot spaces to screen
22CE: 18 F9         jr   $22C9



// Score values for aliens here....  see $21B1

ALIEN_SCORE_TABLE:
22D0: 
30 00 00            // 30 PTS
40 00 00            // 40 PTS
50 00 00            // 50 PTS
60 00 00            // 60 PTS
70 00 00            // 70 PTS
80 00 00            // 80 PTS
00 01 00            // 100 PTS
50 01 00            // 150 PTS
00 02 00            // 200 PTS
00 03 00            // 300 PTS
00 08 00            // 800 PTS


//
// A = index of string to print
//
// Bit 6 set: scroll this text onto screen
// Bit 7 set: clear this text
//
// Value in A (ANDed with $3F)       Text printed
// =============================================================
// 0                                 GAME OVER
// 1                                 PUSH START BUTTON  
// 2                                 PLAYER ONE 
// 3                                 PLAYER TWO 
// 4                                 HIGH SCORE
// 5                                 CREDIT
// 6                                 BONUS GALIXIP FOR   000 PTS
// 7                                 CONVOY CHARGER 
// 8                                 - SCORE ADVANCE TABLE -
// 9                                 MISSION: DESTROY ALIENS
// A                                 WE ARE THE GALAXIANS
// B                                 30       60  PTS 
// C                                 40       80  PTS
// D                                 50      100  PTS
// E                                 60      300  PTS
// F                                 NAMCO logo
// 10                                FREE PLAY

PRINT_TEXT:
22F1: 21 5C 23      ld   hl,$235C            // HL = address of TEXTPTRS  
22F4: 87            add  a,a                 // A = A * 2.   This may affect C and PO flags. 
22F5: F5            push af      
22F6: E6 3F         and  $3F                 // mask in bits 0..5. Now A = a value in range of 0..63
22F8: 5F            ld   e,a     
22F9: 16 00         ld   d,$00               // Extend A into DE 
22FB: 19            add  hl,de               // HL now points to an entry in the TEXTPTRS lookup table.
22FC: 5E            ld   e,(hl) 
22FD: 23            inc  hl
22FE: 56            ld   d,(hl)              // DE now holds a pointer to a character string to print. See docs @$235C  
22FF: EB            ex   de,hl               // HL = pointer to character string. DE we don't care about, it will be overwritten.                
2300: 5E            ld   e,(hl)              
2301: 23            inc  hl
2302: 56            ld   d,(hl)              // DE = *HL. Now DE holds character RAM address to print text at
2303: 23            inc  hl
2304: EB            ex   de,hl               // Now HL = pointer to character RAM, DE = pointer to text to print
2305: 01 E0 FF      ld   bc,$FFE0            // offset to add to HL after every character write. (-32 in decimal)
2308: F1            pop  af
2309: 38 0E         jr   c,$2319
230B: FA 23 23      jp   m,$2323             // if minus flag is set, then we want to scroll text onto screen - goto $2323

// HL = pointer to character RAM
// DE = pointer to character to write
230E: 1A            ld   a,(de)              // read character to be drawn   
230F: D6 30         sub  $30                 
2311: FE 0F         cp   $0F                 // is this the string terminator, #$3F?
2313: C8            ret  z                   // yes, so exit routine
2314: 77            ld   (hl),a              // write character to character RAM
2315: 13            inc  de                  // bump DE to point to next character
2316: 09            add  hl,bc               // Add offset to screen address so that next character is drawn at correct location.   
2317: 18 F5         jr   $230E               // and continue

// I'll stick my neck out and guess this code is to erase text that was drawn previously.
2319: 1A            ld   a,(de)
231A: FE 3F         cp   $3F
231C: C8            ret  z
231D: 36 40         ld   (hl),$40
231F: 13            inc  de
2320: 09            add  hl,bc
2321: 18 F6         jr   $2319



//
// Set text up for scrolling. Invoked by $230B within PRINT_TEXT
//
// HL = pointer to character RAM
// DE = pointer to text string to render
//

2323: 22 B5 40      ld   ($40B5),hl          // store pointer to character RAM in COLUMN_SCROLL_CHAR_RAM_PTR
2326: EB            ex   de,hl               // now HL = pointer to text string, DE = pointer to character RAM 
2327: 22 B3 40      ld   ($40B3),hl          // store pointer to next char to scroll on in COLUMN_SCROLL_NEXT_CHAR_PTR
232A: 7B            ld   a,e                 // get low byte of character RAM address into A
232B: E6 1F         and  $1F                 // mask in bits 0..4. Effectively A = A mod #$20 (32 decimal). A now represents a column index from 0-31.
232D: 47            ld   b,a                 // save column index in B.
// compute offset into OBJRAM_BACK_BUF
232E: 87            add  a,a                 // A=A*2. This is because attribute RAM requires 2 bytes per column. 
232F: C6 20         add  a,$20               // add $20 (32 decimal) as OBJRAM_BACK_BUF starts at $4020
2331: 6F            ld   l,a                 // 
2332: 26 40         ld   h,$40               // now HL = a pointer to scroll attribute value in OBJRAM_BACK_BUF 
2334: 22 B1 40      ld   ($40B1),hl          // set COLUMN_SCROLL_ATTR_BACKBUF_PTR
2337: E5            push hl                  // save pointer to scroll offset attribute on the stack

2338: CB 3B         srl  e
233A: CB 3B         srl  e
233C: 7A            ld   a,d                
233D: E6 03         and  $03
233F: 0F            rrca
2340: 0F            rrca
2341: B3            or   e
2342: E6 F8         and  $F8
2344: 4F            ld   c,a                 // C = scroll offset to write to OBJRAM_BACK_BUF 

// we're going to clear this line ready for scrolling text on.
2345: 21 00 50      ld   hl,$5000            // HL = start of character RAM
2348: 78            ld   a,b                 // restore column index from B (see @$232D)
2349: 85            add  a,l                 
234A: 6F            ld   l,a                 // Add column index to L. Now HL = pointer to column to clear
234B: 11 20 00      ld   de,$0020            // offset to add to HL. $20 (32 decimal) characters per row
234E: 43            ld   b,e                 // B = count of how many characters need to be cleared by DJNZ loop
234F: 36 10         ld   (hl),$10            // write empty space character
2351: 19            add  hl,de               // add offset to HL. Now HL points to same column next row down
2352: 10 FB         djnz $234F
2354: E1            pop  hl                  // restore attribute pointer from the stack
2355: 71            ld   (hl),c              // write initial scroll offset to OBJRAM_BACK_BUF
2356: 3E 01         ld   a,$01
2358: 32 B0 40      ld   ($40B0),a           // set IS_COLUMN_SCROLLING flag
235B: C9            ret



//
// The TEXTPTRS table is a lookup table comprised of pointers to text strings.
//
// The text strings are always organised thus:
//
// First 2 bytes: pointer to character RAM to print text at.
// Subsequent bytes: characters to print, terminated by #$3F (63 decimal)
//
// For example, lets take the first entry in the table, 7E 23.
//
// 7E 23 forms memory address $237E. 

// Note: I suggest you open a memory window in the MAME debugger and view 237E, it'll make this a lot easier to follow.
//
// The first 2 bytes stored at $237E are 96 and 52. This forms a character RAM address of $5296, where the first character will be drawn.
// The subsequent bytes represent the string "GAME OVER" in (mostly) ASCII. The $3F after the "R" terminates the string.
//


TEXTPTRS:                                     
235C: 7E 23                                  // GAME OVER
      8B 23                                  // PUSH START BUTTON  
      9F 23                                  // PLAYER ONE 
      AC 23                                  // PLAYER TWO 
      B9 23                                  // HIGH SCORE
      C6 23                                  // CREDIT
      D1 23                                  // BONUS GALIXIP FOR   000 PTS  
      EF 23                                  // CONVOY CHARGER 
      01 24                                  // - SCORE ADVANCE TABLE -
      1B 24                                  // MISSION: DESTROY ALIENS
      35 24                                  // WE ARE THE GALAXIANS
      4C 24                                  // 30       60  PTS 
      61 24                                  // 40       80  PTS
      76 24                                  // 50      100  PTS
      8B 24                                  // 60      300  PTS
      A0 24                                  // NAMCO logo
      AB 24                                  // FREE PLAY

237E: 96            
237F: 52            

2380:  47 41 4D 45 40 40 4F 56 45 52 3F F1 52 50 55 53  GAME@@OVER?.RPUS
2390:  48 40 53 54 41 52 54 40 42 55 54 54 4F 4E 3F 94  H@START@BUTTON?.
23A0:  52 50 4C 41 59 45 52 40 30 4E 45 3F 94 52 50 4C  RPLAYER@0NE?.RPL
23B0:  41 59 45 52 40 54 57 4F 3F 80 52 48 49 47 48 40  AYER@TWO?.RHIGH@
23C0:  53 43 4F 52 45 3F 7F 53 43 52 45 44 49 54 40 40  SCORE?.SCREDIT@@
23D0:  3F 98 53 42 4F 4E 55 53 40 47 41 4C 41 58 49 50  ?.SBONUS@GALAXIP
23E0:  40 46 4F 52 40 40 40 30 30 30 40 D0 D1 D2 3F D1  @FOR@@@000@...?.
23F0:  52 43 4F 4E 56 4F 59 40 40 43 48 41 52 47 45 52  RCONVOY@@CHARGER
2400:  3F 4F 53 5B 40 53 43 4F 52 45 40 41 44 56 41 4E  ?OS[@SCORE@ADVAN
2410:  43 45 40 54 41 42 4C 45 40 5B 3F 69 53 4D 49 53  CE@TABLE@[?iSMIS
2420:  53 49 4F 4E D3 40 44 45 53 54 52 4F 59 40 41 4C  SION.@DESTROY@AL
2430:  49 45 4E 53 3F 27 53 57 45 40 41 52 45 40 54 48  IENS?'SWE@ARE@TH
2440:  45 40 47 41 4C 41 58 49 41 4E 53 3F D9 52 40 40  E@GALAXIANS?.R@@
2450:  33 30 40 40 40 40 40 40 40 36 30 40 40 D0 D1 D2  30@@@@@@@60@@...
2460:  3F D7 52 40 40 34 30 40 40 40 40 40 40 40 38 30  ?.R@@40@@@@@@@80
2470:  40 40 D0 D1 D2 3F D5 52 40 40 35 30 40 40 40 40  @@...?.R@@50@@@@
2480:  40 40 31 30 30 40 40 D0 D1 D2 3F D3 52 40 40 36  @@100@@...?.R@@6
2490:  30 40 40 40 40 40 40 33 30 30 40 40 D0 D1 D2 3F  0@@@@@@300@@...?
24A0:  7C 52 CA CB CC CD CE CF 9E 9F 3F 7F 53 46 52 45  |R........?.SFRE
24B0:  45 40 50 4C 41 59 3F A7 28 66 3D 28 2E 3D 28 08  E@PLAY?.(f=(.=(.
24B6:  3F            



//
// Selects information to be displayed at the bottom of the screen.
//
// On entry:
// A identifies what to be displayed.
//
// Value in A                Action taken                                                                 See also 
// ===============================================================================================================================================
// 0                         The player advances to the next level and the red level flags are redrawn.   See: $2520 (DISPLAY_LEVEL_FLAGS)
// 1                         Display FREE PLAY or CREDIT n at bottom left of screen.                      See: $24EB (DISPLAY_AVAILABLE_CREDIT)
// 2                         Display BONUS GALAXIP FOR (nnnnn) PTS on screen.                             See: $24C8 (DISPLAY_BONUS_GALAXIP_FOR)
// Any other value           Display player ships remaining at bottom left of screen.                     See: $22B3 (DISPLAY_PLAYER_SHIPS_REMAINING)
//

DISPLAY_BOTTOM_OF_SCREEN:
24B7: A7            and  a                   // test if parameter is zero
24B8: 28 66         jr   z,$2520             // if parameter is 0, goto $2520 (DISPLAY_LEVEL_FLAGS)
24BA: 3D            dec  a
24BB: 28 2E         jr   z,$24EB             // if parameter was 1 then goto $24EB (DISPLAY_AVAILABLE_CREDIT)
24BD: 3D            dec  a
24BE: 28 08         jr   z,$24C8             // if parameter was 2 then goto $24C8 (DISPLAY_BONUS_GALAXIP_FOR) 
24C0: 3A 1D 42      ld   a,($421D)           // read number of lives for current player
24C3: 47            ld   b,a
24C4: CF            rst  $08                 // assert that it's not GAME OVER (TODO: verify this)
24C5: C3 B3 22      jp   $22B3               // goto DISPLAY_PLAYER_SHIPS_REMAINING


//
// Displays the text string BONUS GALAXIP FOR (nnnnn) on screen.
//

DISPLAY_BONUS_GALIXIP_FOR:
24C8: 3A AC 40      ld   a,($40AC)           // read BONUS GALIXIP FOR value
24CB: FE FF         cp   $FF                 // check if there is any bonus. I think this code is redundant.
24CD: C8            ret  z                   // if no bonus, then return

24CE: 3E 06         ld   a,$06               // index of BONUS GALIXIP FOR 0000 PTS text string
24D0: CD F1 22      call $22F1               // display text on screen
24D3: 3A AC 40      ld   a,($40AC)           // read BONUS GALIXIP value
24D6: E6 0F         and  $0F                 // mask in low nibble
24D8: 32 38 51      ld   ($5138),a           // write value to character RAM
24DB: 3A AC 40      ld   a,($40AC)           // read BONUS GALIXIP value
24DE: E6 F0         and  $F0                 // mask in high nibble
24E0: 20 01         jr   nz,$24E3            // if it's !=0, goto $24E3
24E2: 3C            inc  a
24E3: 0F            rrca                     // move high nibble...
24E4: 0F            rrca
24E5: 0F            rrca
24E6: 0F            rrca                     // ... into lower nibble, so that A is now a number from 0..9
24E7: 32 58 51      ld   ($5158),a           // and POKE number to screen RAM, displaying single digit in correct place
24EA: C9            ret                      // we're out


//
// Displays either FREE PLAY or CREDIT (n) at bottom left of screen
//

DISPLAY_AVAILABLE_CREDIT:
24EB: 3A 06 40      ld   a,($4006)           // read IS_GAME_IN_PLAY flag           
24EE: 0F            rrca                     // move flag into carry
24EF: D8            ret  c                   // if the game is in play, return.
24F0: 3A 11 40      ld   a,($4011)           // read PORT_STATE_6800
24F3: E6 C0         and  $C0                 // mask in dip switch 1 & 2 state
24F5: FE C0         cp   $C0                 // are both dip switches on?
24F7: 3E 10         ld   a,$10               // index of text string "FREE PLAY"
24F9: CA F1 22      jp   z,$22F1             // call PRINT_TEXT

// if we get here, then we're not in FREE PLAY mode. We will display number of credits on screen.
24FC: 3E 05         ld   a,$05               // index of text string "CREDIT"
24FE: CD F1 22      call $22F1               // call PRINT_TEXT
2501: 3A 02 40      ld   a,($4002)           // read number of credits
2504: FE 63         cp   $63                 // compare to 99 decimal
2506: 38 02         jr   c,$250A             // if A <99 then goto $250A
2508: 3E 63         ld   a,$63               // clamp number of credits to 99
250A: CD 69 25      call $2569               // call CONVERT_A_TO_BCD. Now A = BCD equivalent of what it was
250D: 47            ld   b,a                 // save credits as BCD in B
250E: E6 F0         and  $F0                 // mask in high nibble, which is first digit of BCD
2510: 28 07         jr   z,$2519             // if the first digit is 0, goto $2519. We don't display it.
2512: 0F            rrca                     // shift high nibble...
2513: 0F            rrca
2514: 0F            rrca
2515: 0F            rrca                     // to low nibble.. converting first BCD digit to decimal.
2516: 32 9F 52      ld   ($529F),a           // Write first digit of credits to character RAM
2519: 78            ld   a,b                 // get credits as BCD into A again. We preserved it in B @$250D
251A: E6 0F         and  $0F                 // mask in low nibble, which is second digit of BCD. Converts second BCD digit to decimal.
251C: 32 7F 52      ld   ($527F),a           // Write second digit of credits to character RAM 
251F: C9            ret                      


//
// Called when the player has completed the level.
//
// This routine:
//    Resets the swarm tempo//
//    increments the player level (48 levels maximum)//
//    Draws level flags. 
//

DISPLAY_LEVEL_FLAGS:
2520: CF            rst  $08                 // assert that it's not GAME OVER (TODO: verify this)
2521: 3A 20 42      ld   a,($4220)           // read HAVE_NO_ALIENS_IN_SWARM
2524: A7            and  a                   // test if flag is set
2525: 28 05         jr   z,$252C             // if flag is not set, goto $252C
2527: 3E 01         ld   a,$01
2529: 32 D0 41      ld   ($41D0),a           // set RESET_SWARM_SOUND_TEMPO flag to 1. The swarm tempo will be slow again. 

252C: 3A 1C 42      ld   a,($421C)           // read PLAYER_LEVEL.
252F: 3C            inc  a                   // increment it.
2530: FE 30         cp   $30                 // Compare to #$30 (48 decimal)
2532: 38 02         jr   c,$2536             // if A < 48, goto $2536
2534: 3E 30         ld   a,$30               // Level 48 is the limit.
// A = level number (0-48)
2536: CD 69 25      call $2569               // convert A to BCD. Now A = BCD equivalent 

// A = level number in BCD            
2539: F5            push af
253A: 21 7E 50      ld   hl,$507E            // address in character RAM to start drawing flags at
253D: E6 F0         and  $F0                 // mask in high nibble
253F: 28 10         jr   z,$2551             // if the high nibble is zero, then goto $2551

// Calculate how many "10" flags we are going to draw
2541: 0F            rrca                     // shift bits in high nibble of BCD number....
2542: 0F            rrca
2543: 0F            rrca
2544: 0F            rrca                     // to lower nibble.
2545: 47            ld   b,a                 // B now holds the number of red "10" flags to draw at the bottom right of the screen.
2546: 0E 10         ld   c,$10               // C is a count of how much space, in characters, we have to plot flags. We start with #$10 (16 decimal) 
2548: 3E 68         ld   a,$68               // ordinal of first character of "10" flag to plot
254A: CD 85 25      call $2585               // plot the flag with "10" on it
254D: 0D            dec  c                   // A "10" flag takes up 2 spaces..
254E: 0D            dec  c                   // ..so reduce C by 2.
254F: 10 F7         djnz $2548               // repeat until B==0
2551: F1            pop  af

// Calculate how many normal red flags we are going to draw
// A=level number in BCD
2552: E6 0F         and  $0F                 // mask in lower nibble of BCD number. Now A represents how many flags we are going to draw.
2554: 47            ld   b,a                 // B = number of flags to draw
2555: 11 1F 00      ld   de,$001F            // offset to add to HL after every flag drawn.
2558: 28 08         jr   z,$2562             // if we don't have any flags to draw then goto $2562
255A: 3E 6C         ld   a,$6C               // ordinal of first character to plot
255C: CD A0 25      call $25A0               // draw the normal flag on character map
255F: 0D            dec  c                   // A normal flag takes up just 1 character space, so reduce C by 1
2560: 10 F8         djnz $255A               // repeat until B == 0

// if we get here, we want to erase any flags left from the previous level
2562: 0D            dec  c                   // decrement "space for characters remaining" count in C
2563: F8            ret  m                   // return if c has become a negative value. 
2564: CD 9E 25      call $259E               // plot spaces to overwrite any existing flags
2567: 18 F9         jr   $2562


//
// Convert value in register A to BCD equivalent 
// 
// For example, if you pass in $63 (99 decimal) in A, this function will return 99 BCD
// 
// Expects:
// A = non BCD value, from 0..99
//
// Returns:
// A = BCD equivalent
// 
// Thanks to Slavo Labsky for his help deciphering the strange "add a,$00" instruction, which resets the half-carry flag.  

CONVERT_A_TO_BCD:
2569: 47            ld   b,a                 // preserve A in B register
256A: E6 0F         and  $0F                 // mask in low nibble
256C: C6 00         add  a,$00               // clears the half carry flag which might affect DAA
256E: 27            daa
256F: 4F            ld   c,a                 // store result in C
2570: 78            ld   a,b                 // restore A to its original value
2571: E6 F0         and  $F0                 // mask in high nibble
2573: 28 0B         jr   z,$2580             // if high nibble is zero we don't care, goto $2580
2575: 0F            rrca                     // shift high nibble...
2576: 0F            rrca
2577: 0F            rrca
2578: 0F            rrca                     // ... into lower nibble
2579: 47            ld   b,a                 // and store in B.
// Final product is (B * 16 ) + C
257A: AF            xor  a                   // clear A
257B: C6 16         add  a,$16               // Add 16 hex (which in BCD terms is 16 decimal) to A  (so A will progress in BCD from 0->16->32->48... )
257D: 27            daa
257E: 10 FB         djnz $257B               // and repeat until B is 0.
2580: 81            add  a,c                 // add in value of lower nibble preserved @$256f  
2581: 27            daa                      // ensure A is a valid BCD number
2582: C9            ret                      // and we're out



2583: 3E 2C         ld   a,$2C               // space character

//
// Draw 4 characters in a 2 x 2 layout. 
//
// register A is the ordinal of the first character to draw. 
// The next 3 characters are derived automatically by incrementing A after each character drawn.
//
// Expects:
// A = ordinal of first character to poke to character RAM. 
// HL = pointer to character RAM address
// 
// Resulting layout is:
//
// A   |  A+1
// ----------
// A+2 |  A+3
//

PLOT_CHARACTERS_2_BY_2_ASCENDING:
2585: D5            push de
2586: 11 1F 00      ld   de,$001F            // load de with 31 decimal. This is the width of a row, in characters, minus 1.
2589: CD A0 25      call $25A0               // plot 2 characters on same row... 
258C: CD A0 25      call $25A0               // and 2 characters on the next row 
258F: D1            pop  de
2590: C9            ret


//
// Draw 4 characters in a 2 x 2 layout. 
//
// register A is the ordinal of the first character to draw. 
//
// Expects:
// A = ordinal of first character to poke to character RAM. 
// HL = pointer to character RAM address
// 
// Resulting layout is:
//
// A-2 |  A-1
// ----------
// A   |  A+1

PLOT_CHARACTERS_2_BY_2_DESCENDING:
2591: 3E 2E         ld   a,$2E
2593: D5            push de
2594: 11 DF FF      ld   de,$FFDF            // load de with -33 decimal as signed word
2597: CD A0 25      call $25A0               // plot 2 characters on one row..
259A: C6 FC         add  a,$FC               // subtract 4 from A
259C: 18 EE         jr   $258C               // plot 2 characters on row above


259E: 3E 2C         ld   a,$2C               // space character


//
// Plots 2 contiguous characters on same row
// register A is the ordinal of the first character to draw. A+1 is drawn in the next column.
//
// Expects:
// A = ordinal of first character to plot
// HL = pointer to character RAM where first character will be plotted
// DE = offset to add to HL after both characters have been plotted
//
// Returns:
// HL = updated pointer to character RAM
//

PLOT_TWO_CHARS_ON_SAME_ROW:
25A0: 77            ld   (hl),a              // plot first character
25A1: 3C            inc  a                   // increment A
25A2: 23            inc  hl                  // bump HL to next address in RAM
25A3: 77            ld   (hl),a              // plot second character
25A4: 3C            inc  a
25A5: 19            add  hl,de               // add offset in DE to HL
25A6: C9            ret


25A7: 3E 2C         ld   a,$2C               // space character

//
// Plots 2 characters in the same column, one beneath the other.
//
// register A is the ordinal of the first character to draw. A+2 is drawn in the same column of the row beneath.
//
// Expects:
// A = ordinal of first character to plot
// HL = pointer to character RAM where first character will be plotted
//

PLOT_TWO_CHARACTERS_IN_SAME_COLUMN:
25A9: D5            push de
25AA: 11 20 00      ld   de,$0020            // each row is comprised of $20 (32 decimal) characters...
25AD: 77            ld   (hl),a              // plot first character        
25AE: C6 02         add  a,$02
25B0: 19            add  hl,de               // bump HL to point to the character at the row beneath
25B1: 77            ld   (hl),a              // plot second character
25B2: D1            pop  de
25B3: C9            ret

// From 25B4 - 3fff, it's just NOPs