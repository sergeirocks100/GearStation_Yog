//Ambience types

#define GENERIC list('sound/ambience/ambigen1.ogg','sound/ambience/ambigen3.ogg',\
								'sound/ambience/ambigen4.ogg','sound/ambience/ambigen5.ogg',\
								'sound/ambience/ambigen6.ogg','sound/ambience/ambigen7.ogg',\
								'sound/ambience/ambigen8.ogg','sound/ambience/ambigen9.ogg',\
								'sound/ambience/ambigen10.ogg','sound/ambience/ambigen11.ogg',\
								'sound/ambience/ambigen12.ogg','sound/ambience/ambigen14.ogg','sound/ambience/ambigen15.ogg')

#define HOLY list('sound/ambience/ambicha1.ogg','sound/ambience/ambicha2.ogg','sound/ambience/ambicha3.ogg',\
										'sound/ambience/ambicha4.ogg', 'sound/ambience/ambiholy.ogg', 'sound/ambience/ambiholy2.ogg',\
										'sound/ambience/ambiholy3.ogg')

#define HIGHSEC list('sound/ambience/ambidanger.ogg', 'sound/ambience/ambidanger2.ogg')

#define RUINS list('sound/ambience/ambimine.ogg', 'sound/ambience/ambicave.ogg', 'sound/ambience/ambiruin.ogg',\
									'sound/ambience/ambiruin2.ogg',  'sound/ambience/ambiruin3.ogg',  'sound/ambience/ambiruin4.ogg',\
									'sound/ambience/ambiruin5.ogg',  'sound/ambience/ambiruin6.ogg',  'sound/ambience/ambiruin7.ogg',\
									'sound/ambience/ambidanger.ogg', 'sound/ambience/ambidanger2.ogg', 'sound/ambience/ambitech3.ogg',\
									'sound/ambience/ambimystery.ogg', 'sound/ambience/ambimaint1.ogg')

#define ENGINEERING list('sound/ambience/ambisin1.ogg','sound/ambience/ambisin2.ogg','sound/ambience/ambisin3.ogg','sound/ambience/ambisin4.ogg',\
										'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg', 'sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambitech3.ogg')

#define MINING list('sound/ambience/ambimine.ogg', 'sound/ambience/ambicave.ogg', 'sound/ambience/ambiruin.ogg',\
											'sound/ambience/ambiruin2.ogg',  'sound/ambience/ambiruin3.ogg',  'sound/ambience/ambiruin4.ogg',\
											'sound/ambience/ambiruin5.ogg',  'sound/ambience/ambiruin6.ogg',  'sound/ambience/ambiruin7.ogg',\
											'sound/ambience/ambidanger.ogg', 'sound/ambience/ambidanger2.ogg', 'sound/ambience/ambimaint1.ogg',\
											'sound/ambience/ambilava1.ogg', 'sound/ambience/ambilava2.ogg', 'sound/ambience/ambilava3.ogg')

#define MEDICAL list('sound/ambience/ambinice.ogg')

#define SPOOKY list('sound/ambience/ambimo1.ogg','sound/ambience/ambimo2.ogg','sound/ambience/ambiruin7.ogg','sound/ambience/ambiruin6.ogg',\
										'sound/ambience/ambiodd.ogg', 'sound/ambience/ambimystery.ogg')

#define SPACE list('sound/ambience/ambispace.ogg', 'sound/ambience/ambispace2.ogg', 'sound/ambience/title2.ogg', 'sound/ambience/ambiatmos.ogg')

#define MAINTENANCE list('sound/ambience/ambimaint1.ogg', 'sound/ambience/ambimaint2.ogg', 'sound/ambience/ambimaint3.ogg', 'sound/ambience/ambimaint4.ogg',\
											'sound/ambience/ambimaint5.ogg', 'sound/voice/lowHiss2.ogg', 'sound/voice/lowHiss3.ogg', 'sound/voice/lowHiss4.ogg', 'sound/ambience/ambitech2.ogg' )

#define AWAY_MISSION list('sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiruin.ogg',\
									'sound/ambience/ambiruin2.ogg',  'sound/ambience/ambiruin3.ogg',  'sound/ambience/ambiruin4.ogg',\
									'sound/ambience/ambiruin5.ogg',  'sound/ambience/ambiruin6.ogg',  'sound/ambience/ambiruin7.ogg',\
									'sound/ambience/ambidanger.ogg', 'sound/ambience/ambidanger2.ogg', 'sound/ambience/ambimaint.ogg',\
									'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg', 'sound/ambience/ambiodd.ogg')

#define REEBE list('sound/ambience/ambireebe1.ogg', 'sound/ambience/ambireebe2.ogg', 'sound/ambience/ambireebe3.ogg')

#define CREEPY_SOUNDS list('sound/effects/ghost.ogg', 'sound/effects/ghost2.ogg', 'sound/effects/heart_beat.ogg', 'sound/effects/screech.ogg',\
	'sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/behind_you2.ogg', 'sound/hallucinations/far_noise.ogg', 'sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg',\
	'sound/hallucinations/growl3.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg', 'sound/hallucinations/i_see_you1.ogg', 'sound/hallucinations/i_see_you2.ogg',\
	'sound/hallucinations/look_up1.ogg', 'sound/hallucinations/look_up2.ogg', 'sound/hallucinations/over_here1.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg',\
	'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/turn_around2.ogg', 'sound/hallucinations/veryfar_noise.ogg', 'sound/hallucinations/wail.ogg')

GLOBAL_LIST_INIT(ambient_assoc,list(
	AMBIENCE_GENERIC = GLOB.GENERIC,
	AMBIENCE_HOLY = GLOB.HOLY,
	AMBIENCE_DANGER = GLOB.HIGHSEC,
	AMBIENCE_RUINS = GLOB.RUINS,
	AMBIENCE_ENGI = GLOB.ENGINEERING,
	AMBIENCE_MINING = GLOB.MINING,
	AMBIENCE_MEDICAL = GLOB.MEDICAL,
	AMBIENCE_SPOOKY = GLOB.SPOOKY,
	AMBIENCE_MAINT = GLOB.MAINTENANCE,
	AMBIENCE_AWAY = GLOB.AWAY_MISSION,
	AMBIENCE_REEBE = GLOB.REEBE,
	AMBIENCE_CREEPY = GLOB.CREEPY_SOUNDS,
	AMBIENCE_NONE = list()))


GLOBAL_LIST_INIT(ambient_music_assoc, list(
	AMBIENCE_SPACE = GLOB.SPACE
))
