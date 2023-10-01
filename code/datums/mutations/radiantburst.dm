/datum/mutation/human/radiantburst
	name = "Radiant Burst"
	desc = "An mutation hidden deep within ethereal genetic code that."
	quality = POSITIVE
	difficulty = 12
	locked = TRUE
	text_gain_indication = span_notice("There is no darkness, even when you close your eyes!")
	text_lose_indication = span_notice("The blinding light fades.")
	power_path = /datum/action/cooldown/spell/aoe/radiantburst
	instability = 30
	power_coeff = 1 //increases aoe
	synchronizer_coeff = 1 //prevents blinding
	energy_coeff = 1 //reduces cooldown
	conflicts = list(/datum/mutation/human/glow, /datum/mutation/human/glow/anti)

/datum/mutation/human/radiantburst/modify()
	. = ..()
	var/datum/action/cooldown/spell/aoe/radiantburst/to_modify = .
	if(!istype(to_modify)) // null or invalid
		return

	if(GET_MUTATION_SYNCHRONIZER(src) > 1)
		to_modify.safe = TRUE //don't blind yourself
	if(GET_MUTATION_ENERGY(src) > 1)
		to_modify.cooldown_time -= 5 SECONDS //blind more often
	if(GET_MUTATION_POWER(src) > 1)
		to_modify.aoe_radius += 2 //bigger blind

/datum/action/cooldown/spell/aoe/radiantburst
	name = "Radiant Burst"
	desc = "You release all the light that is within you"
	button_icon = 'icons/mob/actions/actions_clockcult.dmi'
	button_icon_state = "Kindle"
	active_icon_state = "Kindle"
	base_icon_state = "Kindle"
	aoe_radius = 3
	antimagic_flags = NONE
	spell_requirements = NONE
	school = SCHOOL_EVOCATION
	cooldown_time = 15 SECONDS
	sound = 'sound/magic/blind.ogg'
	var/safe = FALSE
	

/datum/action/cooldown/spell/aoe/radiantburst/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/mob/living/nearby_mob in view(aoe_radius, center))
		if(nearby_mob == owner && safe)
			continue
		things += nearby_mob

	return things

/datum/action/cooldown/spell/aoe/radiantburst/cast(atom/cast_on)
	. = ..()
	owner.visible_message(span_warning("[owner] releases a blinding light from within themselves."), span_notice("You release all the light within you."))
	flash_color(owner, flash_color = LIGHT_COLOR_HOLY_MAGIC, flash_time = 0.5 SECONDS)

/datum/action/cooldown/spell/aoe/radiantburst/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(ishuman(victim))
		var/mob/living/carbon/human/hurt = victim
		hurt.flash_act()//only strength of 1, so sunglasses protect from it
