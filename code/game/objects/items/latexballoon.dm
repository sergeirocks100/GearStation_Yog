#define INFLATED "inflated"
#define POPPED "popped"
#define DEFLATED "deflated"

/obj/item/latexballoon
	name = "latex glove"
	desc = "Sterile and airtight."
	icon_state = "latexballoon"
	icon = 'icons/obj/toy.dmi'
	item_state = "lgloves"
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 7
	var/state = DEFLATED
	var/datum/gas_mixture/air_contents = null

/obj/item/latexballoon/Initialize(mapload)
	. = ..()
//	AddElement(/datum/element/atmos_sensitive, mapload)
//	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_HANDS)

/obj/item/latexballoon/proc/set_state(state_to_set)
	state = state_to_set
	update_appearance(UPDATE_ICON | UPDATE_DESC)

/obj/item/latexballoon/update_icon_state()
	. = ..()

	switch(state)
		if(INFLATED)
			icon_state = "latexballoon_blow"
			lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
			righthand_file = 'icons/mob/inhands/items_righthand.dmi'
			item_state = "latexballoon"
		if(POPPED)
			icon_state = "latexballoon_bursted"
			item_state = initial(item_state)
			lefthand_file = initial(lefthand_file)
			righthand_file = initial(righthand_file)

/obj/item/latexballoon/update_desc()
	. = ..()
	switch(state)
		if(INFLATED)
			desc = "It's a blown up latex glove on a string."
		if(POPPED)
			desc = "The remains of a latex glove."

/obj/item/latexballoon/proc/blow(obj/item/tank/tank, mob/user)
	if(state == POPPED)
		return

	air_contents = tank.remove_air_volume(3)

	if(isnull(air_contents))
		balloon_alert(user, "tank is empty!")
		return

	if(state == INFLATED)
		burst() // too much air, pop it!
		return

	playsound(src, 'sound/weapons/gunshot.ogg', 100, TRUE)

	balloon_alert(user, "you blow up the balloon!") // because it's a balloon obviously

	set_state(INFLATED)

///obj/item/latexballoon/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
//	return (exposed_temperature > T0C+100)

///obj/item/latexballoon/atmos_expose(datum/gas_mixture/air, exposed_temperature)
//	burst()

/obj/item/latexballoon/proc/burst()
	if (!air_contents || state != INFLATED)
		return

	set_state(POPPED)
	playsound(src, 'sound/weapons/gunshot.ogg', 100, TRUE)
	loc.assume_air(air_contents)

/obj/item/latexballoon/ex_act(severity, target)
	burst()
	switch(severity)
		if (EXPLODE_DEVASTATE)
			qdel(src)
		if (EXPLODE_HEAVY)
			if (prob(50))
				qdel(src)

/obj/item/latexballoon/bullet_act(obj/item/projectile/projectile)
	if(projectile.damage > 0)
		burst()

	return ..()

/obj/item/latexballoon/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/tank))
		var/obj/item/tank/air_tank = item
		blow(air_tank, user)
		return
	if(item.get_sharpness() || item.get_temperature())
		burst()
		return

	return ..()

#undef INFLATED
#undef POPPED
#undef DEFLATED
