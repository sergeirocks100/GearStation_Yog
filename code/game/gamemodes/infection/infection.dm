/datum/game_mode/infection
	name = "infection"
	config_tag = "infection"
	report_type = "infection"
	false_report_weight = 10
	required_players = 50 // this is an all out station war
	required_enemies = 8
	recommended_enemies = 8
	antag_flag = ROLE_INFECTION
	enemy_minimum_age = 14 // these should be somewhat experienced players for an all out war mode
	round_ends_with_antag_death = TRUE

	announce_span = "danger"
	announce_text = "An infectious core is approaching on a meteor in an attempt to consume the station!\n\
	<span class='danger'>Infection</span>: Destroy the defensive beacons to consume the station.\n\
	<span class='notice'>Crew</span>: Defend long enough until you find a way to destroy the core."

	// spores picked before setup to be antagonists
	var/list/pre_spores = list()

	// datum type for the infection commander
	var/commander_datum_type = /datum/antagonist/infection

	// datum type for a basic infection spore
	var/spore_datum_type = /datum/antagonist/infection/spore

/datum/game_mode/infection/pre_setup()
	if(!GLOB.infection_spawns.len)
		setup_error = "No infection core spawnpoints found"
		return FALSE
	if(!GLOB.beacon_spawns.len)
		setup_error = "No infection beacon spawnpoints found"
		return FALSE
	var/n_spores = min(CEILING(num_players() / 7, 1), antag_candidates.len)
	if(n_spores >= required_enemies || GLOB.Debug2)
		for(var/i in 1 to n_spores)
			var/datum/mind/new_spore = pick_n_take(antag_candidates)
			pre_spores += new_spore
			new_spore.assigned_role = "Infectious Creature"
			new_spore.special_role = "Infectious Creature"
			log_game("[key_name(new_spore)] has been selected to be apart of the infection")
		return TRUE
	else
		setup_error = "Not enough infection candidates"
		return FALSE
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/infection/post_setup()
	//Assign leader
	var/datum/mind/leader = pre_spores[1] // what a lucky boy gets to be the commander
	leader.add_antag_datum(commander_datum_type)
	//Assign the remaining operatives
	for(var/i in 2 to pre_spores.len)
		var/datum/mind/spore_mind = pre_spores[i]
		spore_mind.add_antag_datum(spore_datum_type)
	return ..()

/datum/game_mode/infection/check_finished()
	// true if commander is dead, or if beacons are destroyed (handled in antagonist win check)
	return isnull(GLOB.infection_commander)

/datum/game_mode/infection/generate_report()
	return "An extremely dangerous infectious core was recently shot out into space at incredible speed after some form of planetary explosion. \
			Typically these cores are restricted to dead planets where they will be unable to expand, as there is no currently known way to destroy them. \
			We cannot currently track the cores location at this time as it seems to have noticed and evolved to stop us, now seemingly invisible to any of our methods. \
			It is believed that we will be able to spot the core once it enters any solar system, giving very little time to prepare against it. \
			Ensure that you are prepared at all times to fight back as evacuation requests will be denied due to the danger of spreading this infection."

/datum/game_mode/infection/send_intercept()
	return // handled in the antagonist due to it being round changing (consumes the whole station)