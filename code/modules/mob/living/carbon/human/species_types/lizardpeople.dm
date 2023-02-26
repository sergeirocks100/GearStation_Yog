/datum/species/lizard
	// Reptilian humanoids with scaled skin and tails.
	name = "Lizardperson"
	plural_form = "Lizardfolk"
	id = "lizard"
	say_mod = "hisses"
	default_color = "00FF00"
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,HAS_FLESH,HAS_BONE,HAS_TAIL)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_REPTILE)
	mutant_bodyparts = list("tail_lizard", "snout", "spines", "horns", "frills", "body_markings", "legs")
	mutanttongue = /obj/item/organ/tongue/lizard
	mutanttail = /obj/item/organ/tail/lizard
	coldmod = 1.75 //Desert-born race
	heatmod = 0.75 //Desert-born race
	payday_modifier = 0.6 //Negatively viewed by NT
	default_features = list("mcolor" = "0F0", "tail_lizard" = "Smooth", "snout" = "Round", "horns" = "None", "frills" = "None", "spines" = "None", "body_markings" = "None", "legs" = "Normal Legs")
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/lizard
	skinned_type = /obj/item/stack/sheet/animalhide/lizard
	exotic_bloodtype = "L"
	disliked_food = SUGAR | VEGETABLES
	liked_food = MEAT | GRILLED | SEAFOOD | MICE
	inert_mutation = FIREBREATH
	deathsound = 'sound/voice/lizard/deathsound.ogg'
	screamsound = 'yogstation/sound/voice/lizardperson/lizard_scream.ogg' //yogs - lizard scream
	wings_icon = "Dragon"
	species_language_holder = /datum/language_holder/lizard
	var/heat_stunmod = 0
	var/last_heat_stunmod = 0
	var/regrowtimer

	smells_like = "putrid scales"

/datum/species/lizard/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_lizard_name(gender)

	var/randname = lizard_name(gender)

	if(lastname)
		randname += " [lastname]"

	return randname


/datum/species/lizard/handle_environment(datum/gas_mixture/environment, mob/living/carbon/human/H)
	..()
	last_heat_stunmod = heat_stunmod  //Saves previous mod
	if(H.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		heat_stunmod = 1		//lizard gets faster when warm
	else if(H.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT && !HAS_TRAIT(H, TRAIT_RESISTCOLD))
		switch(H.bodytemperature)
			if(200 to BODYTEMP_COLD_DAMAGE_LIMIT)	//but slower
				heat_stunmod = -1
			if(120 to 200)
				heat_stunmod = -2		//and slower
			else
				heat_stunmod = -3		//and sleepier as they get colder
	else
		heat_stunmod = 0
	var/heat_stun_mult = 1.1**(last_heat_stunmod - heat_stunmod) //1.1^(difference between last and current values)
	if(heat_stun_mult != 1) 		//If they're the same 1.1^0 is 1, so no change, if we go up we divide by 1.1	
		stunmod *= heat_stun_mult 	//however many times, and if it goes down we multiply by 1.1
						//This gets us an effective stunmod of 0.91, 1, 1.1, 1.21, 1.33, based on temp

/datum/species/lizard/spec_life(mob/living/carbon/human/H)
	. = ..()
	if((H.client && H.client.prefs.read_preference(/datum/preference/toggle/mood_tail_wagging)) && !is_wagging_tail() && H.mood_enabled)
		var/datum/component/mood/mood = H.GetComponent(/datum/component/mood)
		if(!istype(mood) || !(mood.shown_mood >= MOOD_LEVEL_HAPPY2)) 
			return
		var/chance = 0
		switch(mood.shown_mood)
			if(0 to MOOD_LEVEL_SAD4)
				chance = -0.1
			if(MOOD_LEVEL_SAD4 to MOOD_LEVEL_SAD3)
				chance = -0.01
			if(MOOD_LEVEL_HAPPY2 to MOOD_LEVEL_HAPPY3)
				chance = 0.001
			if(MOOD_LEVEL_HAPPY3 to MOOD_LEVEL_HAPPY4)
				chance = 0.1
			if(MOOD_LEVEL_HAPPY4 to INFINITY)
				chance = 1
		if(prob(abs(chance)))
			switch(SIGN(chance))
				if(1)
					H.emote("wag")
				if(-1)
					stop_wagging_tail(H)
	if(!H.getorganslot(ORGAN_SLOT_TAIL) && !regrowtimer)
		regrowtimer = addtimer(CALLBACK(src, .proc/regrow_tail, H), 20 MINUTES, TIMER_UNIQUE)

/datum/species/lizard/proc/regrow_tail(mob/living/carbon/human/H)
	if(!H.getorganslot(ORGAN_SLOT_TAIL) && H.stat != DEAD)
		mutant_bodyparts |= "tail_lizard"
		H.visible_message("[H]'s tail regrows.","You feel your tail regrow.")
	
/datum/species/lizard/get_species_description()
	return "The first sentient beings encountered by the SIC outside of the Sol system, vuulen are the most \
		commonly encountered non-human species in SIC space. Despite being one of the most integrated species in the SIC, they \
		are also one of the most heavily discriminated against."

/datum/species/lizard/get_species_lore()
	return list(
		"Born on the planet of Sangris, vuulen evolved from raptor-like creatures and quickly became the \
		dominant species thanks to the warm climate of the planet and their intelligence combined with relatively \
		dexterous claws. Vuulen developed similarly to humans technologically and geopolitically, mastering fire, \
		agriculture, writing, metalworking, architecture, and the applications of plasma; empires rose and fell; \
		varied and rich cultures emerged and grew. By the time first contact occurred between humans and vuulen, \
		the latter were a kind of medieval age, having even dabbled with the bluespace crystals naturally present \
		on the planet, albeit without success.",
 
		"The SIC was highly interested in Sangris for two reasons when it was discovered. The first was the \
		discovery of sapient life. The second was the great plethora of plasma and bluespace located on the planet. \
		A diplomatic team was quickly assembled, but the first contact turned violent. Afterwards, the SIC waged war \
		to conquer Sangris, doing so in a year due to the gap of technology and size between the two civilizations. \
		The remaining vuulek powers were assimilated into the newly-formed Opsillian Republic, and humans began populating the \
		planet. Vuulen were not citizens of the SIC, but still under its control through the Opsillian Republic. \
		Slavery was common, and most slaves were pressed into hazardous conditions in the collection or processing \
		of several of the planet's rich plasma veins. As time went on, the vuulen became gradually more accepted into \
		the human society. Finally, in 2463, the official interdiction of slavery was passed, and vuulen became full \
		citizens of the SIC. The Opsillian Republic went from a mere puppet state to a somewhat independent and legitimate government, \
		though many human companies continued to exploit vuulen as workers, as labor laws for non-humans \
		offered significantly less privilege than what would be expected.",
 
		"Vuulek communities are organized in clans, though their impact on the culture of the individuals is limited. \
		They tend to live like humans due to their colonization,  only occasionally practicing some of \
		their clan traditions. Despite efforts to integrate vuulen into the SIC through establishments such \
		as habituation stations, a certain pridefulness nonetheless survived amongst vuulen, as they're often \
		eager to prove their worth and qualities. In addition, strength and honor are still values commonly held \
		by vuulen. Awareness of the past atrocities committed against vuulen by the SIC vary greatly \
		between individuals, both amongst humans and vuulen.",
 
		"Today, the vuulek societies have been almost completely assimilated in the SIC, \
		and vuulen are now considered SIC citizens and claim almost all the same rights as humans \
		do. However, lawyers still struggle in rigged courts to try and claim a sense of equality \
		for all those who exist in the SIC as honest citizens. Humans and vuulen exist side by side \
		across the SIC in harmony, but without much fraternity. While full-blown hostility is rare, \
		prejudice is common.",
	)

// Override for the default temperature perks, so we can give our specific "cold blooded" perk.
/datum/species/lizard/create_pref_temperature_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "thermometer-empty",
		SPECIES_PERK_NAME = "Cold-blooded",
		SPECIES_PERK_DESC = "Lizardpeople have higher tolerance for hot temperatures, but lower \
			tolerance for cold temperatures. Additionally, they cannot self-regulate their body temperature - \
			they are as cold or as warm as the environment around them is. Stay warm!",
	))

	return to_add

/*
 Lizard subspecies: ASHWALKERS
*/
/datum/species/lizard/ashwalker
	name = "Ash Walker"
	id = "ashlizard"
	limbs_id = "lizard"
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,DIGITIGRADE,HAS_FLESH,HAS_BONE,HAS_TAIL)
	inherent_traits = list(TRAIT_NOGUNS) //yogs start - ashwalkers have special lungs and actually breathe
	mutantlungs = /obj/item/organ/lungs/ashwalker
	breathid = "n2" // yogs end
	species_language_holder = /datum/language_holder/lizard/ash

// yogs start - Ashwalkers now have ash immunity
/datum/species/lizard/ashwalker/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.weather_immunities |= "ash"

/datum/species/lizard/ashwalker/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.weather_immunities -= "ash"

/*
 Lizard subspecies: DRACONIDS
 These guys only come from the dragon's blood bottle from lavaland. They're basically just lizards with all-around marginally better stats and fire resistance.
 Sadly they only get digitigrade legs. Can't have everything!
*/
/datum/species/lizard/draconid	
	name = "Draconid"
	id = "draconid"
	limbs_id = "lizard"
	fixed_mut_color = "A02720" 	//Deep red
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,DIGITIGRADE,HAS_FLESH,HAS_BONE,HAS_TAIL)
	inherent_traits = list(TRAIT_RESISTHEAT)	//Dragons like fire
	burnmod = 0.8
	brutemod = 0.9 //something something dragon scales
	punchdamagelow = 3
	punchdamagehigh = 12
	punchstunthreshold = 12	//+2 claws of powergaming

/datum/species/lizard/draconid/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.weather_immunities |= "ash"

/datum/species/lizard/draconid/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.weather_immunities -= "ash"

// yogs end

/datum/species/lizard/has_toes()
	return TRUE
