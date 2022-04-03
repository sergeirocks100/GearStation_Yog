/datum/biome/jungleland
	var/cellular_noise_map_id = MED_DENSITY
	var/turf/closed_turf = /turf/closed/mineral/random
	var/list/dense_flora = list()
	var/list/loose_flora = list()
	var/loose_flora_density = 0 // from 0 to 100
	var/dense_flora_density = 100

/datum/biome/jungleland/generate_turf(turf/gen_turf,list/density_map)
	
	var/closed = text2num(density_map[cellular_noise_map_id][world.maxx * (gen_turf.y - 1) + gen_turf.x])
	var/chosen_turf 
	if(closed)
		chosen_turf = closed_turf
		spawn_dense_flora(gen_turf)
	else
		chosen_turf = turf_type
		spawn_loose_flora(gen_turf)

	. = gen_turf.ChangeTurf(chosen_turf, null, CHANGETURF_DEFER_CHANGE)

/datum/biome/jungleland/proc/spawn_dense_flora(turf/gen_turf)
	if(length(dense_flora)  && prob(dense_flora_density))
		var/obj/structure/flora = pickweight(dense_flora)
		new flora(gen_turf)
	
/datum/biome/jungleland/proc/spawn_loose_flora(turf/gen_turf)
	if(length(loose_flora) && prob(loose_flora_density))
		var/obj/structure/flora = pickweight(loose_flora)
		new flora(gen_turf)

/datum/biome/jungleland/barren_rocks
	turf_type = /turf/open/floor/grass/snow/basalt
	loose_flora = list(/obj/structure/flora/rock = 2,/obj/structure/flora/rock/pile = 2)
	loose_flora_density = 10
	cellular_noise_map_id = LOW_DENSITY

/datum/biome/jungleland/dry_swamp
	turf_type = /turf/open/floor/plating/dirt/dark
	closed_turf = /turf/open/floor/plating/ironsand
	dense_flora = list(/obj/structure/flora/rock = 2,/obj/structure/flora/rock/jungle = 1,/obj/structure/flora/rock/pile = 2)
	loose_flora = list(/obj/structure/flora/ausbushes/stalkybush = 2,/obj/structure/flora/rock = 2,/obj/structure/flora/rock/jungle = 2,/obj/structure/flora/rock/pile = 2,/obj/structure/flora/stump=2,/obj/structure/flora/tree/jungle = 1)
	dense_flora_density = 10
	loose_flora_density = 10

/datum/biome/jungleland/toxic_pit
	turf_type = /turf/open/floor/plating/dirt/dark
	closed_turf = /turf/open/water/toxic_pit
	loose_flora = list(/obj/structure/flora/ausbushes/stalkybush = 2,/obj/structure/flora/rock = 2,/obj/structure/flora/rock/jungle = 2,/obj/structure/flora/rock/pile = 2,/obj/structure/flora/stump=2,/obj/structure/flora/tree/jungle = 1)
	dense_flora = list(/obj/structure/flora/ausbushes/stalkybush = 1)
	loose_flora_density = 10
	dense_flora_density = 10

/datum/biome/jungleland/dying_forest
	turf_type = /turf/open/floor/plating/asteroid
	closed_turf = /turf/open/floor/plating/asteroid
	dense_flora = list(/obj/structure/flora/stump=1,/obj/structure/flora/tree/dead/jungle = 2,/obj/structure/flora/rock/jungle = 2,/obj/structure/flora/rock/pile = 2,/obj/structure/flora/rock = 2,/obj/structure/flora/tree/jungle/small = 1)
	dense_flora_density = 70


/datum/biome/jungleland/jungle
	turf_type = /turf/open/floor/plating/dirt
	closed_turf = /turf/open/floor/plating/dirt
	cellular_noise_map_id = HIGH_DENSITY
	dense_flora = list(/obj/structure/flora/tree/jungle/small = 2,/obj/structure/flora/tree/jungle = 2, /obj/structure/flora/rock/jungle = 1, /obj/structure/flora/junglebush = 1, /obj/structure/flora/junglebush/b = 1, /obj/structure/flora/junglebush/c = 1, /obj/structure/flora/junglebush/large = 1, /obj/structure/flora/rock/pile/largejungle = 1)
	loose_flora = list(/obj/structure/flora/grass/jungle = 2,/obj/structure/flora/grass/jungle/b = 2,/obj/structure/flora/grass/brown = 1,/obj/structure/flora/bush = 1,/obj/structure/flora/ausbushes = 1,/obj/structure/flora/ausbushes/leafybush = 1,/obj/structure/flora/ausbushes/sparsegrass = 1,/obj/structure/flora/ausbushes/fullgrass = 1)
	loose_flora_density = 60
