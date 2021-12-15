/*
	Base infection structure type that is not meant to be spawned
*/

/obj/structure/infection
	name = "infection"
	icon = 'icons/mob/infection/infection.dmi'
	light_range = 4
	desc = "A thick carpet of writhing tendrils."
	density = FALSE
	spacemove_backup = TRUE
	opacity = 0
	anchored = TRUE
	layer = TABLE_LAYER
	CanAtmosPass = ATMOS_PASS_PROC
	max_integrity = 30
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 70)
	resistance_flags = ACID_PROOF
	// How many points the commander gets back when it removes an infection of that type. If less than 0, structure cannot be removed.
	var/point_return = 0
	// how much health this blob regens when pulsed
	var/health_regen = 5
	// how much time needs to pass before the infection can be pulsed again
	var/next_pulse = 0
	// time added to next_pulse
	var/pulse_cooldown = 20
	// multiplies incoming brute damage by this
	var/brute_resist = 0.75
	// multiplies incoming burn damage by this
	var/fire_resist = 0.5
	// if the infection blocks atmos and heat spread
	var/atmosblock = TRUE
	// the controlling overmind of this structure
	var/mob/camera/commander/overmind
	// the angles that the node will expand on first, used to give a uniform distribution
	var/list/angles = list()
	// the time this infection was created
	var/timecreated
	// the actual build time it takes for this structure to be built in deciseconds
	var/build_time = 0
	// if the infection is currently being used to create another type
	var/building = FALSE
	// upgrades for the type
	var/list/upgrades = list()
	// the types of upgrades
	var/list/upgrade_types = list()
	// adds all upgrades of this subtype to upgrade_types
	var/upgrade_subtype = null
	// menu handler for the upgrade menus
	var/datum/infection_menu/menu_handler
	// if this thing can be stepped on by non blobbies
	var/canpass_bypass = FALSE
	//how many crystals does this drop on being destroyed
	var/crystal_drop = 0
	// types of objects to eat
	var/list/types_to_eat = list(/obj/singularity,
								 /obj/singularity/energy_ball,
								 /obj/machinery/power/supermatter_crystal,
								 /obj/machinery/gravity_generator)

/obj/structure/infection/Initialize(mapload, owner_overmind)
	. = ..()
	if(owner_overmind)
		overmind = owner_overmind
	else if(GLOB.infection_commander)
		overmind = GLOB.infection_commander
	GLOB.infections += src //Keep track of the structure in the normal list either way
	setDir(pick(GLOB.cardinals))
	update_icon()
	if(atmosblock)
		air_update_turf(1)
	ConsumeTile()
	timecreated = world.time
	AddComponent(/datum/component/no_beacon_crossing)
	generate_upgrades()
	menu_handler = new /datum/infection_menu(src)

/*
	Generates the upgrades for the infection from the types
*/
/obj/structure/infection/proc/generate_upgrades()
	if(ispath(upgrade_subtype))
		upgrade_types += subtypesof(upgrade_subtype)
	for(var/upgrade_type in upgrade_types)
		upgrades += new upgrade_type()

/*
	Opens the evolution menu for the commander that clicked on this
*/
/obj/structure/infection/proc/evolve_menu(var/mob/camera/commander/C)
	if(C == overmind)
		menu_handler.ui_interact(overmind)

/*
	Automatically purchases the highest levels of every upgrade on this infection for free
*/
/obj/structure/infection/proc/max_upgrade()
	for(var/datum/infection_upgrade/U in upgrades)
		var/times = U.times
		for(var/i = 1 to times)
			U.do_upgrade(src)

/*
	When this is first created, do this
*/
/obj/structure/infection/proc/creation_action()
	return

/obj/structure/infection/Destroy()
	if(atmosblock)
		atmosblock = FALSE
		air_update_turf(1)
	GLOB.infections -= src //it's no longer in the all infections list either
	var/turf/T = get_turf(src)
	for(var/i in 1 to crystal_drop)
		new /obj/item/crystal_shards(T)
	var/list/stored_contents = list()
	if(T)
		stored_contents = T.contents
	. = ..()
	for(var/atom/movable/M in stored_contents)
		Uncrossed(M) // so the overlay and move speed effects don't stay after destruction

/obj/structure/infection/blob_act()
	return

/obj/structure/infection/singularity_act()
	return

/obj/structure/infection/tesla_act(power)
	. = ..()
	return

/*
	Attempts to eat nearby problem / important objects
*/

/obj/structure/infection/proc/eat_nearby()
	var/list/contents_adjacent = urange(1, src)
	var/to_eat = null
	for(var/type in types_to_eat)
		for(var/thing in contents_adjacent)
			if(istype(thing, type))
				to_eat = thing
				break
		if(to_eat)
			break
	if(to_eat)
		for(var/mob/M in range(10,src))
			if(M.client)
				flash_color(M.client, "#FB6B00", 1)
				shake_camera(M, 4, 3)
		playsound(src.loc, pick('sound/effects/curseattack.ogg', 'sound/effects/curse1.ogg', 'sound/effects/curse2.ogg', 'sound/effects/curse3.ogg', 'sound/effects/curse4.ogg',), 300, 1, pressure_affected = FALSE)
		visible_message("<span class='danger'[to_eat] is absorbed by the infection!</span>")
		qdel(to_eat)

/obj/structure/infection/singularity_pull()
	return

/obj/structure/infection/Adjacent(var/atom/neighbour)
	. = ..()
	if(.)
		var/result = 0
		var/direction = get_dir(src, neighbour)
		var/list/dirs = list("[NORTHWEST]" = list(NORTH, WEST), "[NORTHEAST]" = list(NORTH, EAST), "[SOUTHEAST]" = list(SOUTH, EAST), "[SOUTHWEST]" = list(SOUTH, WEST))
		for(var/A in dirs)
			if(direction == text2num(A))
				for(var/B in dirs[A])
					var/C = locate(/obj/structure/infection) in get_step(src, B)
					if(C)
						result++
		. -= result - 1

/obj/structure/infection/BlockSuperconductivity()
	return atmosblock

/obj/structure/infection/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSBLOB))
		return ..()
	return canpass_bypass

/obj/structure/infection/CanAtmosPass(turf/T)
	// override for shield blobs etc
	return !atmosblock

/obj/structure/infection/CanAStarPass(ID, dir, caller)
	. = FALSE
	if(ismovable(caller))
		var/atom/movable/mover = caller
		. = . || (mover.pass_flags & PASSBLOB)

/obj/structure/infection/Crossed(atom/movable/mover)
	. = ..()
	mover.inertia_dir = 0

/obj/structure/infection/update_icon() //Updates color based on overmind color if we have an overmind.
	if(overmind)
		add_atom_colour(overmind.infection_color, FIXED_COLOUR_PRIORITY)
	else
		remove_atom_colour(FIXED_COLOUR_PRIORITY)

/obj/structure/infection/process()
	Life()

/*
	Life, pretty much the same as process
*/
/obj/structure/infection/proc/Life()
	return

/*
	Resets the angles to expand on because you can't use initial() on lists
*/
/obj/structure/infection/proc/reset_angles()
	angles = list(0,15,30,45,60,75,90,105,120,135,150,165,180,195,210,225,240,255,270,285,300,315,330,345) // this is aids but you cant use initial() on lists so :shrug: i'd rather not loop

/*
	Expands normal infection in the area around this infection
*/
/obj/structure/infection/proc/Pulse_Area(mob/camera/commander/pulsing_overmind, claim_range = 6, count = 6, space_expand = FALSE)
	if(QDELETED(pulsing_overmind))
		pulsing_overmind = overmind
	Be_Pulsed()
	ConsumeTile()
	next_pulse = world.time + pulse_cooldown
	for(var/i = 1 to count)
		if(!angles.len)
			reset_angles()
		var/angle = pick(angles)
		angles -= angle
		angle += rand(-7, 7)
		var/turf/check = src
		for(var/j = 1 to claim_range)
			check = locate(src.x + cos(angle) * j, src.y + sin(angle) * j, src.z)
			if(!check || check.is_transition_turf())
				check = locate(src.x + cos(angle) * (j - 1), src.y + sin(angle) * (j - 1), src.z)
				break
		if(!check)
			continue
		var/list/toaffect = getline(src, check)
		var/obj/structure/infection/previous = src
		if(!toaffect)
			continue
		for(var/j = 2 to toaffect.len)
			var/obj/structure/infection/INF = locate(/obj/structure/infection) in toaffect[j]
			if(!INF)
				var/dir_to_next = get_dir(toaffect[j-1], toaffect[j])
				// okay i know we said we were totally going to expand to toaffect[j] but cardinals look cleaner (connectivity) so we'll check if those are empty
				var/turf/finalturf = get_final_expand_turf(toaffect[j-1], toaffect[j], dir_to_next)
				previous.expand(finalturf, overmind, space_expand)
				break
			if(iswallturf(INF.loc))
				INF.loc.blob_act(INF)
			INF.air_update_turf(1)
			INF.Be_Pulsed()
			INF.ConsumeTile()
			previous = INF

/*
	Correct the infection expansion to only occur at cardinals after we actually reach the end
	Done like this to save processing over the original blob which used rangeturfs (sucks for efficiency)
*/
/obj/structure/infection/proc/get_final_expand_turf(var/turf/lastturf, var/turf/finalturf, var/dir_to_next)
	var/list/checkturfs = list()
	if(dir_to_next in GLOB.diagonals)
		var/list/random_cardinals = GLOB.cardinals.Copy()
		while(random_cardinals.len)
			var/checkdir = pick_n_take(random_cardinals)
			if(dir_to_next & checkdir)
				checkturfs += get_step(lastturf, checkdir)
	for(var/turf/checkturf in checkturfs)
		if(locate(/obj/structure/infection) in checkturf.contents)
			continue
		return checkturf
	return finalturf

/*
	What happens when this infection structure is passed over by an expanding nodes lines
*/
/obj/structure/infection/proc/Be_Pulsed()
	obj_integrity = min(max_integrity, obj_integrity+health_regen)
	update_icon()
	var/turf/T = get_turf(src)
	if(istype(T, /turf/open/chasm) || istype(T, /turf/open/space))
		T = T.ChangeTurf(/turf/open/floor/plating)
		T.air_update_turf(1)

/*
	Consumes the contents of the tile this infection is on
*/
/obj/structure/infection/proc/ConsumeTile()
	eat_nearby()
	for(var/obj/O in loc)
		if(istype(O, /obj/structure/infection))
			continue
		if(istype(O, /obj/effect))
			continue
		if(ismecha(O))
			continue
	if(iswallturf(loc))
		loc.blob_act(src) //don't ask how a wall got on top of the core, just eat it

/*
	Attack animation for infection expansion
*/
/obj/structure/infection/proc/infection_attack_animation(atom/A = null) //visually attacks an atom
	var/obj/effect/temp_visual/infection/O = new /obj/effect/temp_visual/infection(src.loc)
	O.setDir(dir)
	if(overmind)
		O.color = overmind.infection_color
	if(A)
		O.do_attack_animation(A) //visually attack the whatever
	return O //just in case you want to do something to the animation.

/*
	Check if we can expand on the tile, then create a normal infection there
*/
/obj/structure/infection/proc/expand(turf/T = null, controller = null, space_expand = FALSE)
	infection_attack_animation(T)
	// do not expand to areas that are space, unless we're very lucky or the core
	if(isspaceturf(T) && !(locate(/obj/structure/lattice) in T) && !space_expand && !(locate(/obj/structure/beacon_generator) in T) && prob(80))
		return
	if(locate(/obj/structure/beacon_wall) in T.contents || locate(/obj/structure/infection) in T.contents)
		return
	var/obj/structure/infection/I = new /obj/structure/infection/normal(src.loc, (controller || overmind))
	I.density = TRUE
	if(T.Enter(I,src))
		I.density = initial(I.density)
		I.forceMove(T)
		I.update_icon()
		I.ConsumeTile()
		if(T.dynamic_lighting == FALSE)
			T.dynamic_lighting = TRUE
			T.lighting_build_overlay()
		T = T.ChangeTurf(/turf/open/floor/plating)
		T.air_update_turf(1)
		return I
	else
		T.blob_act(src)
		for(var/obj/structure/S in T)
			S.blob_act(src)
		for(var/obj/machinery/M in T)
			M.blob_act(src)
		qdel(I)
		return null

/obj/structure/infection/emp_act(severity)
	. = ..()
	return

/obj/structure/infection/ex_act(severity)
	take_damage(30/severity * 4, BRUTE, "bomb", 0)

/obj/structure/infection/extinguish()
	..()
	return

/obj/structure/infection/hulk_damage()
	return 15

/obj/structure/infection/attack_animal(mob/living/simple_animal/M)
	if(ROLE_INFECTION in M.faction) //sorry, but you can't kill the infection as an infectious creature
		return
	..()

/obj/structure/infection/attacked_by(obj/item/I, mob/living/user)
	if(ROLE_INFECTION in user.faction) //sorry, but you can't kill the infection as an infectious creature
		return
	..()

/obj/structure/infection/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, pick('sound/effects/picaxe1.ogg', 'sound/effects/picaxe2.ogg', 'sound/effects/picaxe3.ogg'), 50, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

/obj/structure/infection/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	switch(damage_type)
		if(BRUTE)
			damage_amount *= brute_resist
		if(BURN)
			damage_amount *= fire_resist
		if(CLONE)
		else
			return 0
	var/armor_block = 0
	if(damage_flag)
		armor_block = armor.getRating(damage_flag)
	damage_amount = round(damage_amount * (100 - armor_block)*0.01, 0.1)
	return damage_amount

/obj/structure/infection/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(. && obj_integrity > 0)
		update_icon()

/obj/structure/infection/obj_destruction(damage_flag)
	..()

/*
	Handles building times and animations
	Used for changing types of infection into other types
*/
/obj/structure/infection/proc/change_to(type, controller, structure_build_time)
	if(!ispath(type))
		throw EXCEPTION("change_to(): invalid type for infection")
		return
	if(building)
		return // no
	var/obj/structure/infection/I = new type(null, controller)
	if(structure_build_time == null)
		structure_build_time = I.build_time
	var/obj/effect/overlay/vis/newicon = new
	newicon.icon = initial(I.icon)
	newicon.icon_state = initial(I.icon_state)
	newicon.dir = initial(I.dir)
	newicon.pixel_x = initial(I.pixel_x)
	newicon.pixel_y = initial(I.pixel_y)
	newicon.layer = TABLE_LAYER
	if(overmind)
		newicon.color = overmind.infection_color
	var/default_transform = I.transform
	newicon.transform = I.transform.Scale(0.5, 0.5)
	animate(newicon, transform = default_transform, time = structure_build_time)
	vis_contents += newicon
	name = "building [I.name]"
	building = type
	density = TRUE
	brute_resist = 2
	fire_resist = 2
	qdel(I)
	sleep(structure_build_time)
	I = new type(src.loc, controller)
	I.creation_action()
	I.update_icon()
	I.setDir(dir)
	qdel(src)
	return I

/*
	The actual standard infection that is created when things expand
*/
/obj/structure/infection/normal
	name = "infection creep"
	icon_state = "normal"
	layer = TURF_LAYER
	light_range = 2
	obj_integrity = 25
	max_integrity = 25
	health_regen = 3
	canpass_bypass = TRUE
	// time in deciseconds for overlay on entering and exiting to fade in and fade out
	var/overlay_fade_time = 20

/obj/structure/infection/normal/evolve_menu(var/mob/camera/commander/C)
	return

/obj/structure/infection/normal/Crossed(atom/movable/mover)
	. = ..()
	if(istype(mover) && (mover.pass_flags & PASSBLOB))
		return TRUE
	if(ismob(mover))
		var/mob/M = mover
		M.add_movespeed_modifier(MOVESPEED_ID_INFECTION_STRUCTURE, update=TRUE, priority=100, multiplicative_slowdown=1)
		M.overlay_fullscreen("infectionvision", /obj/screen/fullscreen/curse/infection, 0.4)

/obj/structure/infection/normal/Uncrossed(atom/movable/mover)
	. = ..()
	if(!locate(/obj/structure/infection/normal) in get_turf(mover))
		if(ismob(mover))
			var/mob/M = mover
			M.remove_movespeed_modifier(MOVESPEED_ID_INFECTION_STRUCTURE, update = TRUE)
			M.clear_fullscreen("infectionvision", overlay_fade_time)

/obj/structure/infection/normal/update_icon()
	..()
	if(building)
		return
	if(obj_integrity <= 15)
		icon_state = "normal"
		name = "fragile infection creep"
		desc = "A thin lattice of slightly twitching tendrils."
	else if (overmind)
		icon_state = "normal"
		name = "infection"
		desc = "A thick carpet of writhing tendrils."
	else
		icon_state = "normal"
		name = "dead infection creep"
		desc = "A thick carpet of lifeless tendrils."
		light_range = 0
