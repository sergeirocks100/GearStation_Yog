/datum/round_event_control/spawn_swarmer
	name = "Spawn Swarmer Shell"
	typepath = /datum/round_event/spawn_swarmer
	weight = 7
	max_occurrences = 1 //Only once okay fam
	earliest_start = 30 MINUTES
	min_players = 15

/datum/round_event/spawn_swarmer

/datum/round_event/spawn_swarmer/start()
	if(find_swarmer())
		return FALSE
	var/list/obj/machinery/gravity_generator/main/gens = GLOB.gravity_generators["[pick(SSmapping.levels_by_trait(ZTRAIT_STATION))]"]
	if(!gens.len)
		return FALSE
	new /obj/effect/mob_spawn/swarmer(get_turf(pick(gens)))
	if(prob(25)) //25% chance to announce it to the crew
		var/swarmer_report = "<span class='big bold'>[command_name()] High-Priority Update</span>"
		swarmer_report += "<br><br>Our long-range sensors have detected an odd signal emanating from your station's gravity generator. We recommend immediate investigation of your gravity generator, as something may have come through." //Magnets man who knows how they work!
		print_command_report(swarmer_report, announce=TRUE)

/datum/round_event/spawn_swarmer/proc/find_swarmer()
	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		if(istype(L, /mob/living/simple_animal/hostile/swarmer) && L.client) //If there is a swarmer with an active client, we've found our swarmer
			return TRUE
	return FALSE
