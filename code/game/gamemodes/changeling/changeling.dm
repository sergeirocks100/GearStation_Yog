#define LING_FAKEDEATH_TIME					400 //40 seconds
#define LING_DEAD_GENETICDAMAGE_HEAL_CAP	50	//The lowest value of geneticdamage handle_changeling() can take it to while dead.
#define LING_ABSORB_RECENT_SPEECH			8	//The amount of recent spoken lines to gain on absorbing a mob

var/list/possible_changeling_IDs = list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega")

/datum/game_mode
	var/list/datum/mind/changelings = list()


/datum/game_mode/changeling
	name = "changeling"
	config_tag = "changeling"
	antag_flag = BE_CHANGELING
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4
	reroll_friendly = 1


	var/const/prob_int_murder_target = 50 // intercept names the assassination target half the time
	var/const/prob_right_murder_target_l = 25 // lower bound on probability of naming right assassination target
	var/const/prob_right_murder_target_h = 50 // upper bound on probability of naimg the right assassination target

	var/const/prob_int_item = 50 // intercept names the theft target half the time
	var/const/prob_right_item_l = 25 // lower bound on probability of naming right theft target
	var/const/prob_right_item_h = 50 // upper bound on probability of naming the right theft target

	var/const/prob_int_sab_target = 50 // intercept names the sabotage target half the time
	var/const/prob_right_sab_target_l = 25 // lower bound on probability of naming right sabotage target
	var/const/prob_right_sab_target_h = 50 // upper bound on probability of naming right sabotage target

	var/const/prob_right_killer_l = 25 //lower bound on probability of naming the right operative
	var/const/prob_right_killer_h = 50 //upper bound on probability of naming the right operative
	var/const/prob_right_objective_l = 25 //lower bound on probability of determining the objective correctly
	var/const/prob_right_objective_h = 50 //upper bound on probability of determining the objective correctly

	var/const/changeling_amount = 4 //hard limit on changelings if scaling is turned off

/datum/game_mode/changeling/announce()
	world << "<b>The current game mode is - Changeling!</b>"
	world << "<b>There are alien changelings on the station. Do not let the changelings succeed!</b>"

/datum/game_mode/changeling/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"

	var/num_changelings = 1

	if(config.changeling_scaling_coeff)
		num_changelings = max(1, min( round(num_players()/(config.changeling_scaling_coeff*2))+2, round(num_players()/config.changeling_scaling_coeff) ))
	else
		num_changelings = max(1, min(num_players(), changeling_amount))

	if(antag_candidates.len>0)
		for(var/i = 0, i < num_changelings, i++)
			if(!antag_candidates.len) break
			var/datum/mind/changeling = pick(antag_candidates)
			antag_candidates -= changeling
			changelings += changeling
			changeling.restricted_roles = restricted_jobs
			modePlayer += changelings
		return 1
	else
		return 0

/datum/game_mode/changeling/post_setup()
	for(var/datum/mind/changeling in changelings)
		log_game("[changeling.key] (ckey) has been selected as a changeling")
		changeling.current.make_changeling()
		changeling.special_role = "Changeling"
		forge_changeling_objectives(changeling)
		greet_changeling(changeling)
	..()
	return

/datum/game_mode/changeling/make_antag_chance(mob/living/carbon/human/character) //Assigns changeling to latejoiners
	var/changelingcap = min( round(joined_player_list.len/(config.changeling_scaling_coeff*2))+2, round(joined_player_list.len/config.changeling_scaling_coeff) )
	if(ticker.mode.changelings.len >= changelingcap) //Caps number of latejoin antagonists
		return
	if(ticker.mode.changelings.len <= (changelingcap - 2) || prob(100 - (config.changeling_scaling_coeff*2)))
		if(character.client.prefs.be_special & BE_CHANGELING)
			if(!jobban_isbanned(character.client, "changeling") && !jobban_isbanned(character.client, "Syndicate"))
				if(age_check(character.client))
					if(!(character.job in restricted_jobs))
						character.mind.make_Changling()

/datum/game_mode/proc/forge_changeling_objectives(datum/mind/changeling)
	//OBJECTIVES - random traitor objectives. Unique objectives "steal brain" and "identity theft".
	//No escape alone because changelings aren't suited for it and it'd probably just lead to rampant robusting
	//If it seems like they'd be able to do it in play, add a 10% chance to have to escape alone


	var/datum/objective/absorb/absorb_objective = new
	absorb_objective.owner = changeling
	absorb_objective.gen_amount_goal(6, 8)
	changeling.objectives += absorb_objective

	if(prob(60))
		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = changeling
		steal_objective.find_target()
		changeling.objectives += steal_objective
	else
		var/datum/objective/debrain/debrain_objective = new
		debrain_objective.owner = changeling
		debrain_objective.find_target()
		changeling.objectives += debrain_objective


	var/list/active_ais = active_ais()
	if(active_ais.len && prob(100/joined_player_list.len))
		var/datum/objective/destroy/destroy_objective = new
		destroy_objective.owner = changeling
		destroy_objective.find_target()
		changeling.objectives += destroy_objective
	else
		if(prob(70))
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = changeling
			kill_objective.find_target()
			changeling.objectives += kill_objective
		else
			var/datum/objective/maroon/maroon_objective = new
			maroon_objective.owner = changeling
			maroon_objective.find_target()
			changeling.objectives += maroon_objective

			if (!(locate(/datum/objective/escape) in changeling.objectives))
				var/datum/objective/escape/escape_with_identity/identity_theft = new
				identity_theft.owner = changeling
				identity_theft.target = maroon_objective.target
				identity_theft.update_explanation_text()
				changeling.objectives += identity_theft

	if (!(locate(/datum/objective/escape) in changeling.objectives))
		if(prob(50))
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = changeling
			changeling.objectives += escape_objective
		else
			var/datum/objective/escape/escape_with_identity/identity_theft = new
			identity_theft.owner = changeling
			identity_theft.find_target()
			changeling.objectives += identity_theft
	return

/datum/game_mode/proc/greet_changeling(datum/mind/changeling, you_are=1)
	if (you_are)
		changeling.current << "<span class='boldannounce'>You are [changeling.changeling.changelingID], a changeling! You have absorbed and taken the form of a human.</span>"
	changeling.current << "<span class='boldannounce'>Use say \":g message\" to communicate with your fellow changelings.</span>"
	changeling.current << "<b>You must complete the following tasks:</b>"

	if (changeling.current.mind)
		var/mob/living/carbon/human/H = changeling.current
		if(H.mind.assigned_role == "Clown")
			H << "You have evolved beyond your clownish nature, allowing you to wield weapons without harming yourself."
			H.dna.remove_mutation(CLOWNMUT)

	var/obj_count = 1
	for(var/datum/objective/objective in changeling.objectives)
		changeling.current << "<b>Objective #[obj_count]</b>: [objective.explanation_text]"
		obj_count++
	return

/*/datum/game_mode/changeling/check_finished()
	var/changelings_alive = 0
	for(var/datum/mind/changeling in changelings)
		if(!istype(changeling.current,/mob/living/carbon))
			continue
		if(changeling.current.stat==2)
			continue
		changelings_alive++

	if (changelings_alive)
		changelingdeath = 0
		return ..()
	else
		if (!changelingdeath)
			changelingdeathtime = world.time
			changelingdeath = 1
		if(world.time-changelingdeathtime > TIME_TO_GET_REVIVED)
			return 1
		else
			return ..()
	return 0*/

/datum/game_mode/proc/auto_declare_completion_changeling()
	if(changelings.len)
		var/text = "<br><font size=3><b>The changelings were:</b></font>"
		for(var/datum/mind/changeling in changelings)
			var/changelingwin = 1
			if(!changeling.current)
				changelingwin = 0

			text += printplayer(changeling)

			//Removed sanity if(changeling) because we -want- a runtime to inform us that the changelings list is incorrect and needs to be fixed.
			text += "<br><b>Changeling ID:</b> [changeling.changeling.changelingID]."
			text += "<br><b>Genomes Extracted:</b> [changeling.changeling.absorbedcount]"

			if(changeling.objectives.len)
				var/count = 1
				for(var/datum/objective/objective in changeling.objectives)
					if(objective.check_completion())
						text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <font color='green'><b>Success!</b></font>"
						feedback_add_details("changeling_objective","[objective.type]|SUCCESS")
					else
						text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <span class='danger'>Fail.</span>"
						feedback_add_details("changeling_objective","[objective.type]|FAIL")
						changelingwin = 0
					count++

			if(changelingwin)
				text += "<br><font color='green'><b>The changeling was successful!</b></font>"
				feedback_add_details("changeling_success","SUCCESS")
			else
				text += "<br><span class='boldannounce'>The changeling has failed.</span>"
				feedback_add_details("changeling_success","FAIL")
			text += "<br>"

		world << text


	return 1

/datum/changeling //stores changeling powers, changeling recharge thingie, changeling absorbed DNA and changeling ID (for changeling hivemind)
	var/list/stored_profiles = list() //list of datum/changelingprofile
	var/list/absorbed_dna = list()
	var/list/protected_dna = list() //dna that is not lost when capacity is otherwise full
	var/dna_max = 4 //How many extra DNA strands the changeling can store for transformation.
	var/absorbedcount = 1 //We would require at least 1 sample of compatible DNA to have taken on the form of a human.
	var/chem_charges = 20
	var/chem_storage = 50
	var/chem_recharge_rate = 0.5
	var/chem_recharge_slowdown = 0
	var/sting_range = 2
	var/changelingID = "Changeling"
	var/geneticdamage = 0
	var/isabsorbing = 0
	var/geneticpoints = 10
	var/purchasedpowers = list()
	var/mimicing = ""
	var/canrespec = 0
	var/changeling_speak = 0
	var/datum/dna/chosen_dna
	var/obj/effect/proc_holder/changeling/sting/chosen_sting

/datum/changeling/New(var/gender=FEMALE)
	..()
	var/honorific
	if(gender == FEMALE)	honorific = "Ms."
	else					honorific = "Mr."
	if(possible_changeling_IDs.len)
		changelingID = pick(possible_changeling_IDs)
		possible_changeling_IDs -= changelingID
		changelingID = "[honorific] [changelingID]"
	else
		changelingID = "[honorific] [rand(1,999)]"
	absorbed_dna.len = dna_max


/datum/changeling/proc/regenerate(var/mob/living/carbon/the_ling)
	if(istype(the_ling))
		if(the_ling.stat == DEAD)
			chem_charges = min(max(0, chem_charges + chem_recharge_rate - chem_recharge_slowdown), (chem_storage*0.5))
			geneticdamage = max(LING_DEAD_GENETICDAMAGE_HEAL_CAP,geneticdamage-1)
		else //not dead? no chem/geneticdamage caps.
			chem_charges = min(max(0, chem_charges + chem_recharge_rate - chem_recharge_slowdown), chem_storage)
			geneticdamage = max(0, geneticdamage-1)


/datum/changeling/proc/get_dna(dna_owner)
	for(var/datum/changelingprofile/prof in stored_profiles)
		if(dna_owner == prof.real_name)
			return prof

/datum/changeling/proc/has_dna(datum/dna/tDNA)
	for(var/datum/changelingprofile/prof in stored_profiles)
		if(tDNA.is_same_as(prof.dna))
			return 1
	return 0

/datum/changeling/proc/can_absorb_dna(mob/living/carbon/user, mob/living/carbon/human/target)
	var/datum/changelingprofile/prof = stored_profiles[1]
	if(prof.dna == user.dna)//If our current DNA is the stalest, we gotta ditch it.
		user << "<span class='warning'>We have reached our capacity to store genetic information! We must transform before absorbing more.</span>"
		return
	if(!target)
		return
	if((target.disabilities & NOCLONE) || (target.disabilities & HUSK))
		user << "<span class='warning'>DNA of [target] is ruined beyond usability!</span>"
		return
	if(!ishuman(target))//Absorbing monkeys is entirely possible, but it can cause issues with transforming. That's what lesser form is for anyway!
		user << "<span class='warning'>We could gain no benefit from absorbing a lesser creature.</span>"
		return
	if(has_dna(target.dna))
		user << "<span class='warning'>We already have this DNA in storage!</span>"
	if(!check_dna_integrity(target))
		user << "<span class='warning'>[target] is not compatible with our biology.</span>"
		return
	return 1

/datum/changeling/proc/add_profile(var/mob/living/human/H)
	var/datum/changelingprofile/prof = new()

	H.dna.real_name = H.real_name //Set this again, just to be sure that it's properly set.
	var/datum/dna/new_dna = new H.dna.type
	new_dna.uni_identity = H.dna.uni_identity
	new_dna.struc_enzymes = H.dna.struc_enzymes
	new_dna.real_name = H.dna.real_name
	new_dna.species = H.dna.species
	new_dna.features = H.dna.features
	new_dna.blood_type = H.dna.blood_type
	prof.dna = new_dna
	prof.name = H.real_name
	
	var/list/slots = list("head", "wear_mask", "back", "wear_suit", "w_uniform", "shoes", "belt", "gloves", "glasses", "ears", "wear_id", "s_store")
	for(var/slot in slots)
		var/obj/item/I = H.vars[slot]
		if(!I)
			continue
		prof.name_list[slot] = I.name
		prof.appearance_list[slot] = I.appearance
		prof.flags_cover_list[slot] = I.flags_cover
	
	stored_profiles += prof

/datum/changelingprofile
	name = "a bug"

	var/datum/dna/DNA = null
	var/list/name_list = list() //associative list of slotname = itemname
	var/list/appearance_list = list()
	var/list/flags_cover_list = list()
