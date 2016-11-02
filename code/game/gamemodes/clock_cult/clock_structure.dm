//The base clockwork structure. Can have an alternate desc and will show up in the list of clockwork objects.
/obj/structure/destructible/clockwork
	name = "meme structure"
	desc = "Some frog or something, the fuck?"
	var/clockwork_desc //Shown to servants when they examine
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "rare_pepe"
	anchored = 1
	density = 1
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/repair_amount = 5 //how much a proselytizer can repair each cycle
	var/can_be_repaired = TRUE //if a proselytizer can repair it at all
	break_message = "<span class='warning'>The frog isn't a meme after all!</span>" //The message shown when a structure breaks
	break_sound = 'sound/magic/clockwork/anima_fragment_death.ogg' //The sound played when a structure breaks
	debris = list(/obj/item/clockwork/alloy_shards/large = 1, \
	/obj/item/clockwork/alloy_shards/medium = 2, \
	/obj/item/clockwork/alloy_shards/small = 3) //Parts left behind when a structure breaks
	var/construction_value = 0 //How much value the structure contributes to the overall "power" of the structures on the station

/obj/structure/destructible/clockwork/New()
	..()
	change_construction_value(construction_value)
	all_clockwork_objects += src

/obj/structure/destructible/clockwork/Destroy()
	change_construction_value(-construction_value)
	all_clockwork_objects -= src
	return ..()

/obj/structure/destructible/clockwork/narsie_act()
	if(take_damage(rand(25, 50), BRUTE) && src) //if we still exist
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(src, "update_atom_colour", 8)

/obj/structure/destructible/clockwork/examine(mob/user)
	var/can_see_clockwork = is_servant_of_ratvar(user) || isobserver(user)
	if(can_see_clockwork && clockwork_desc)
		desc = clockwork_desc
	..()
	desc = initial(desc)
	if(!(resistance_flags & INDESTRUCTIBLE))
		var/t_It = p_they(TRUE)
		var/t_is = p_are()
		var/servant_message = "[t_It] [t_is] at <b>[obj_integrity]/[max_integrity]</b> integrity"
		var/heavily_damaged = FALSE
		var/healthpercent = (obj_integrity/max_integrity) * 100
		if(healthpercent < 50)
			heavily_damaged = TRUE
		if(can_see_clockwork)
			user << "<span class='[heavily_damaged ? "alloy":"brass"]'>[servant_message][heavily_damaged ? "!":"."]</span>"

/obj/structure/destructible/clockwork/hulk_damage()
	return 20


//for the ark and Ratvar
/obj/structure/destructible/clockwork/massive
	name = "massive construct"
	desc = "A very large construction."
	layer = MASSIVE_OBJ_LAYER
	density = FALSE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/structure/destructible/clockwork/massive/New()
	..()
	poi_list += src

/obj/structure/destructible/clockwork/massive/Destroy()
	poi_list -= src
	return ..()

/obj/structure/destructible/clockwork/massive/singularity_pull(S, current_size)
	return


//the base clockwork machinery, which is not actually machines, but happens to use power
/obj/structure/destructible/clockwork/powered
	var/obj/machinery/power/apc/target_apc
	var/active = FALSE
	var/needs_power = TRUE
	var/active_icon = null //icon_state while process() is being called
	var/inactive_icon = null //icon_state while process() isn't being called

/obj/structure/destructible/clockwork/powered/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		var/powered = total_accessable_power()
		user << "<span class='[powered ? "brass":"alloy"]'>It has access to <b>[powered == INFINITY ? "INFINITY":"[powered]"]W</b> of power.</span>"

/obj/structure/destructible/clockwork/powered/Destroy()
	SSfastprocess.processing -= src
	SSobj.processing -= src
	return ..()

/obj/structure/destructible/clockwork/powered/process()
	var/powered = total_accessable_power()
	return powered == PROCESS_KILL ? 25 : powered //make sure we don't accidentally return the arbitrary PROCESS_KILL define

/obj/structure/destructible/clockwork/powered/proc/toggle(fast_process, mob/living/user)
	if(user)
		if(!is_servant_of_ratvar(user))
			return FALSE
		user.visible_message("<span class='notice'>[user] [active ? "dis" : "en"]ables [src].</span>", "<span class='brass'>You [active ? "dis" : "en"]able [src].</span>")
	active = !active
	if(active)
		icon_state = active_icon
		if(fast_process)
			START_PROCESSING(SSfastprocess, src)
		else
			START_PROCESSING(SSobj, src)
	else
		icon_state = inactive_icon
		if(fast_process)
			STOP_PROCESSING(SSfastprocess, src)
		else
			STOP_PROCESSING(SSobj, src)
	return TRUE


/obj/structure/destructible/clockwork/powered/proc/total_accessable_power() //how much power we have and can use
	if(!needs_power || ratvar_awakens)
		return INFINITY //oh yeah we've got power why'd you ask

	var/power = 0
	power += accessable_apc_power()
	power += accessable_sigil_power()
	return power

/obj/structure/destructible/clockwork/powered/proc/accessable_apc_power()
	var/power = 0
	var/area/A = get_area(src)
	var/area/targetAPCA
	for(var/obj/machinery/power/apc/APC in apcs_list)
		var/area/APCA = get_area(APC)
		if(APCA == A)
			target_apc = APC
	if(target_apc)
		targetAPCA = get_area(target_apc)
		if(targetAPCA != A)
			target_apc = null
		else if(target_apc.cell)
			var/apccharge = target_apc.cell.charge
			if(apccharge >= MIN_CLOCKCULT_POWER)
				power += apccharge
	return power

/obj/structure/destructible/clockwork/powered/proc/accessable_sigil_power()
	var/power = 0
	for(var/obj/effect/clockwork/sigil/transmission/T in range(1, src))
		power += T.power_charge
	return power


/obj/structure/destructible/clockwork/powered/proc/try_use_power(amount) //try to use an amount of power
	if(!needs_power || ratvar_awakens)
		return 1
	if(amount <= 0)
		return FALSE
	var/power = total_accessable_power()
	if(!power || power < amount)
		return FALSE
	return use_power(amount)

/obj/structure/destructible/clockwork/powered/proc/use_power(amount) //we've made sure we had power, so now we use it
	var/sigilpower = accessable_sigil_power()
	var/list/sigils_in_range = list()
	for(var/obj/effect/clockwork/sigil/transmission/T in range(1, src))
		sigils_in_range |= T
	while(sigilpower && amount >= MIN_CLOCKCULT_POWER)
		for(var/S in sigils_in_range)
			var/obj/effect/clockwork/sigil/transmission/T = S
			if(amount >= MIN_CLOCKCULT_POWER && T.modify_charge(MIN_CLOCKCULT_POWER))
				sigilpower -= MIN_CLOCKCULT_POWER
				amount -= MIN_CLOCKCULT_POWER
	var/apcpower = accessable_apc_power()
	while(apcpower >= MIN_CLOCKCULT_POWER && amount >= MIN_CLOCKCULT_POWER)
		if(target_apc.cell.use(MIN_CLOCKCULT_POWER))
			apcpower -= MIN_CLOCKCULT_POWER
			amount -= MIN_CLOCKCULT_POWER
			target_apc.charging = 1
			target_apc.chargemode = TRUE
			target_apc.update()
			target_apc.update_icon()
			target_apc.updateUsrDialog()
		else
			apcpower = 0
	if(amount)
		return FALSE
	else
		return TRUE

/obj/structure/destructible/clockwork/powered/proc/return_power(amount) //returns a given amount of power to all nearby sigils or if there are no sigils, to the APC
	if(amount <= 0)
		return FALSE
	var/list/sigils_in_range = list()
	for(var/obj/effect/clockwork/sigil/transmission/T in range(1, src))
		sigils_in_range |= T
	if(!sigils_in_range.len && (!target_apc || !target_apc.cell))
		return FALSE
	if(sigils_in_range.len)
		while(amount >= MIN_CLOCKCULT_POWER)
			for(var/S in sigils_in_range)
				var/obj/effect/clockwork/sigil/transmission/T = S
				if(amount >= MIN_CLOCKCULT_POWER && T.modify_charge(-MIN_CLOCKCULT_POWER))
					amount -= MIN_CLOCKCULT_POWER
	if(target_apc && target_apc.cell && target_apc.cell.give(amount))
		target_apc.charging = 1
		target_apc.chargemode = TRUE
		target_apc.update()
		target_apc.update_icon()
		target_apc.updateUsrDialog()
	return TRUE
