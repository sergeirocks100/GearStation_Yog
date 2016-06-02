/*
The /tg/ codebase currently requires you to have 9 z-levels of the same size dimensions.
z-level order is important, the order you put them in inside this file will determine what z level number they are assigned ingame.
Names of z-level do not matter, but order does greatly, for instances such as checking alive status of revheads on z1

current as of 6/2/2016
z1 = station
z2 = centcomm
z3, z4, and z6 to z9 = empty space
z5 = mining
*/

#if !defined(MAP_FILE)

        #define TITLESCREEN "title" //Add an image in misc/fullscreen.dmi, and set this define to the icon_state, to set a custom titlescreen for your map

        #define MINETYPE "mining"

        #include "map_files\AsteroidStation\AsteroidStation.dmm"
        #include "map_files\generic\z2.dmm"
        #include "map_files\generic\z3.dmm"
        #include "map_files\generic\z4.dmm"
        #include "map_files\AsteroidStation\z5.dmm"
        #include "map_files\generic\z6.dmm"
        #include "map_files\generic\z7.dmm"
        #include "map_files\generic\z8.dmm"
        #include "map_files\generic\z9.dmm"
		//#include "map_files\generic\z10.dmm" If asteroid station ever moves to use lavaland, uncomment this line and add EMPTY_AREA_8 = CROSSLINKED to the config
        #define MAP_PATH "map_files/AsteroidStation"
        #define MAP_FILE "AsteroidStation.dmm"
        #define MAP_NAME "AsteroidStation"

		#define MAP_TRANSITION_CONFIG	list(MAIN_STATION = CROSSLINKED, CENTCOMM = SELFLOOPING, MINING = SELFLOOPING, EMPTY_AREA_1 = CROSSLINKED, EMPTY_AREA_2 = CROSSLINKED, EMPTY_AREA_3 = CROSSLINKED, EMPTY_AREA_4 = CROSSLINKED, EMPTY_AREA_5 = CROSSLINKED, EMPTY_AREA_6 = CROSSLINKED, EMPTY_AREA_7 = CROSSLINKED)

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring AsteroidStation.

#endif
