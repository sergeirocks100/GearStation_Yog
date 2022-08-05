/mob/living/simple_animal/hostile/flockdrone
	name = "flock drone"
	desc = "A weird glowy thing."
	speak_emote = list("tones")
	initial_language_holder = /datum/language_holder/flock
	bubble_icon = "swarmer"
	mob_biotypes = MOB_ROBOTIC
	health = 30
	maxHealth = 30
	status_flags = CANPUSH
	icon_state = "drone"
	icon_living = "drone"
	icon_dead = "drone_dead"
	icon = 'icons/mob/flock_mobs.dmi'
	icon_gib = null
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	wander = TRUE
	harm_intent_damage = 10
	minbodytemp = 0
	maxbodytemp = 500
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	melee_damage_lower = 10
	melee_damage_upper = 10
	melee_damage_type = BRUTE
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	attacktext = "shocks"
	attack_sound = 'sound/effects/empulse.ogg'
	friendly = "pinches"
	speed = 1
	faction = list("flock")
	AIStatus = AI_ON
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_TINY
	ventcrawler = VENTCRAWLER_ALWAYS
	ranged = TRUE
	projectiletype = /obj/item/projectile/beam/disabler/flock
	ranged_cooldown_time = 15
	projectilesound = 'sound/weapons/laser.ogg'
	deathmessage = "explodes with a sharp pop!"
	light_color = LIGHT_COLOR_CYAN
	speech_span = SPAN_ROBOT
	hud_type = /datum/hud/living/flockdrone
	wanted_objects = list(/obj/item, /turf)
	unwanted_objects = list(/obj/item/disk/nuclear, /turf/closed/wall/feather, /turf/open/floor/feather) //We don't want to eat dat fukken disk and already flock'ed turfs
	search_objects = 1
	var/resources = 0
	var/max_resources = 100
	var/mob/camera/flocktrace/pilot
	var/datum/action/cooldown/flock/eject/sus
	var/datum/action/cooldown/flock/spawn_egg/egg


/mob/living/simple_animal/hostile/flockdrone/Initialize()
	. = ..()
	new /obj/item/radio/headset/silicon/ai(src)
	sus = new
	sus.Grant(src)
	egg = new
	egg.Grant(src)
	AddComponent(/datum/component/flock_compute, 10, TRUE)

/mob/living/simple_animal/hostile/flockdrone/OpenFire(atom/A)
	if(!ckey)
		handle_AI_intent_change(target)
	. = ..()

/mob/living/simple_animal/hostile/flockdrone/Shoot(atom/targeted_atom)
	if(a_intent == INTENT_HELP)
		projectiletype = /obj/item/projectile/beam/disabler/flock
	else 
		projectiletype = /obj/item/projectile/beam/flock
	return ..()

/mob/living/simple_animal/hostile/flockdrone/AttackingTarget()
	if(!ckey)
		handle_AI_intent_change(target)
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat == DEAD || L.IsStun() || L.IsImmobilized() || L.IsParalyzed() || L.IsUnconscious() || L.IsSleeping())
			L.flock_act(src)
			return
	else
		target.flock_act()
		return
	if(a_intent == INTENT_HELP)
		melee_damage_type = STAMINA
	else 
		melee_damage_type = initial(melee_damage_type)
	. = ..()
	if(. && isliving(target)) //We deal bonus 5 brute damage to living/alive targets. Always.
		var/mob/living/L = target
		if(L.stat == DEAD)
			return
		var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		var/armor = run_armor_check(affecting, MELEE, armour_penetration = src.armour_penetration)
		L.apply_damage(5, BRUTE, affecting, armor)

/mob/living/simple_animal/hostile/flockdrone/get_status_tab_items()
	. = ..()
	. += "Resources: [resources]/[max_resources]"

/mob/living/simple_animal/hostile/flockdrone/CanAllowThrough(atom/movable/O)
	. = ..()
	if(istype(O, /obj/item/projectile/beam/disabler/flock) || istype(O, /obj/item/projectile/beam/flock))//Allows for swarmers to fight as a group without wasting their shots hitting each other
		return TRUE
	if(isflockdrone(O))
		return TRUE

/mob/living/simple_animal/hostile/flockdrone/handle_automated_action()
	if(resources >= 100 && prob(10))
		egg.Trigger()
	if(health != maxHealth && isflockturf(loc) && prob(15))
		repair(src)
	return ..()

/mob/living/simple_animal/hostile/flockdrone/update_move_intent_slowdown()
	if(m_intent == MOVE_INTENT_WALK)
		to_chat(src, span_notice("You are now able to move through feather walls."))
		speed = initial(speed) + 2
	else
		speed = initial(speed)
	update_simplemob_varspeed()

/mob/living/simple_animal/hostile/flockdrone/Bump(atom/AM)
	. = ..()
	if(istype(AM, /turf/closed/wall/feather) && AM != loc && m_intent == MOVE_INTENT_WALK) 
		var/atom/movable/stored_pulling = pulling
		if(stored_pulling)
			stored_pulling.setDir(get_dir(stored_pulling.loc, loc))
			stored_pulling.forceMove(loc)
		forceMove(AM)
		if(stored_pulling)
			start_pulling(stored_pulling, supress_message = TRUE) 

/mob/living/simple_animal/hostile/flockdrone/proc/change_resources(var/amount, silent = FALSE)
	if(resources >= max_resources && amount > 0)
		if(!silent )
			to_chat(src, span_warning("You gain [amount] resources, but your storage is full!"))
			if(amount > 0)
				new /obj/item/flockcache (loc, amount)
		return
	resources += amount
	if(resources > max_resources)
		if(!silent )
			to_chat(src, span_warning("You gain [amount] resources, but [resources - max_resources] of them don't fit in your storage!"))
		new /obj/item/flockcache (loc, resources - max_resources)
		resources = max_resources
	else if(resources < 0)
		resources = 0
	else if(amount >= 0)
		if(!silent )
			to_chat(src, span_notice("You gain [amount] resources."))
	else 
		if(!silent )
			to_chat(src, span_notice("You spend [amount] resources."))
	if(hud_used && istype(hud_used, /datum/hud/living/flockdrone))
		var/datum/hud/living/flockdrone/flockhud = hud_used
		flockhud.resources.update_counter(resources)

/mob/living/simple_animal/hostile/flockdrone/AltClickOn(atom/target)
	. = ..()
	target.flock_act(src)

/mob/living/simple_animal/hostile/flockdrone/proc/repair(mob/living/simple_animal/hostile/flockdrone/user)
	if(stat == DEAD)
		return
	if(health >= maxHealth)
		visible_message(span_notice("[user] finishes repairing [user == src ? "itself" : src]!"), \
				span_notice("[user == src ? "You finish" : "[user] finishes"] repairing [user == src ? "yourself" : src]!"))
		return
	if(user.resources < 10)
		to_chat(user, span_notice("You don't have enough resources to repair [user == src ? "yourself" : src] further."))
		return
	if(!do_mob(user, src, 1 SECONDS))
		return
	heal_ordered_damage(10, list(BRUTE, BURN))
	visible_message(span_notice("[user] fixes some damage on [user == src ? "itself" : src]!"), \
			span_notice("[user == src ? "You fix" : "[user] fixes"] some damage on [user == src ? "yourself" : src]!"))
	user.change_resources(-10, TRUE)
	update_drone_icon()
	repair(user)

/mob/living/simple_animal/hostile/flockdrone/Life()
	. = ..()
	update_drone_icon()
	if((health/maxHealth*100 <= 50) && prob(pilot ? 10 : 4) && stat != DEAD)  //Non-sentient flockdudes bleed much more rare
		new /obj/effect/decal/cleanable/fluid (loc)

/mob/living/simple_animal/hostile/flockdrone/proc/update_drone_icon()
	if(stat == DEAD)
		icon_state = icon_dead
	else
		var/percentage = health/maxHealth * 100
		switch(percentage)
			if(75 to INFINITY)
				icon_state = "drone"
			if(50 to 74)
				icon_state = "drone-d1"
			if(0 to 50)
				icon_state = "drone-d2"

/mob/living/simple_animal/hostile/flockdrone/examine(mob/user)
	. = ..()
	if(!isflockdrone(user) && !isflocktrace(user))
		if(stat != DEAD)
			var/percentage = health/maxHealth * 100
			switch(percentage)
				if(75 to INFINITY)
					.+= span_alert("It looks lightly [pick("dented", "scratched", "beaten", "wobbly")].")
				if(50 to 74)
					.+= span_alert("It looks [pick("quite", "pretty", "rather")] [pick("dented", "busted", "messed up", "haggard")].")
				if(-INFINITY to 50)
					.+= span_alert("It looks [pick("really", "totally", "very", "all sorts of", "super")] [pick("mangled", "busted", "messed up", "broken", "haggard", "smashed up", "trashed")].")
	else
		. = span_swarmer("<span class='bold'>###=-</span> Ident confirmed, data packet received.")
		. += span_swarmer("<span class='bold'>ID:</span> [icon2html(src, user)] [pilot ? pilot.name : name]")
		. += span_swarmer("<span class='bold'>System Integrity:</span> [health/maxHealth * 100]")
		if(stat == DEAD)
			. += span_swarmer("<span class='bold'>Status:</span> DEAD")
		else if(pilot && client)
			. += span_swarmer("<span class='bold'>Status:</span> SAPIENT")
		else
			. += span_swarmer("<span class='bold'>Status:</span> TORPID")
		. += span_swarmer("<span class='bold'>Combat Mode:</span> [a_intent == INTENT_HARM ? "ON" : "OFF"]")
		. += span_swarmer("<span class='bold'>###=-</span>")

/mob/living/simple_animal/hostile/flockdrone/Process_Spacemove()
	return TRUE

/mob/living/simple_animal/hostile/flockdrone/spawn_gibs()
	new /obj/effect/gibspawner/flockdrone (drop_location(), src, get_static_viruses())

/mob/living/simple_animal/hostile/flockdrone/proc/handle_AI_intent_change(atom/targeted_atom)
	if(ishuman(targeted_atom) || ismonkey(targeted_atom))  //If the target is a stunable monke/human, we try to deal with it nonlethaly. If it isn't stunable, we try to kill it.
		var/mob/living/carbon/C = targeted_atom
		if(HAS_TRAIT(C, TRAIT_STUNIMMUNE) || HAS_TRAIT(C, TRAIT_STUNRESISTANCE) || HAS_TRAIT(C, TRAIT_ENEMY_OF_THE_FLOCK))
			a_intent_change(INTENT_HARM)
		else
			a_intent_change(INTENT_HELP)

	else if(ismecha(targeted_atom) || isliving(targeted_atom)) //If the target is a mech or a non-human/monke, we KILL IT
		a_intent_change(INTENT_HARM)

//////////////////////////////////////////////
//                                          //
//                PILOTING                  //
//                                          //
//////////////////////////////////////////////

/mob/living/simple_animal/hostile/flockdrone/proc/EjectPilot()
	if(!pilot)
		return
	mind.transfer_to(pilot)
	var/turf/location = get_turf(src)
	if(location && istype(location))
		pilot.forceMove(location)
	else
		pilot.forceMove(loc)
	mind.transfer_to(pilot)
	pilot = null
	if(AIStatus == AI_ON)
		toggle_ai()

/mob/living/simple_animal/hostile/flockdrone/proc/Posses(mob/user)
	if(!user)
		return
	if(pilot || mind)
		return
	user.forceMove(src)
	user.mind.transfer_to(src)
	pilot = user
	if(AIStatus != AI_ON)
		toggle_ai()
	
/mob/living/simple_animal/hostile/flockdrone/death(gibbed)
	EjectPilot()
	. = ..()

//////////////////////////////////////////////
//                                          //
//                 LASERS                   //
//                                          //
//////////////////////////////////////////////

/obj/item/projectile/beam/disabler/flock
	name = "flock disabler"
	damage = 25

/obj/item/projectile/beam/flock
	name = "flock laser"
	damage = 17

//////////////////////////////////////////////
//                                          //
//            RTS HOLY SHIT                 //
//                                          //
//////////////////////////////////////////////

/mob/living/simple_animal/hostile/flockdrone/attack_flocktrace(mob/camera/flocktrace/user, var/list/modifiers)
	if(!modifiers["middle"])
		if(!user.ckey)
			return
		if(ckey)
			if(!pilot)
				return
			if(!isflockmind(user))
				to_chat(user, span_warning("[src] is already piloted!"))
				return
			else
				if(isflockmind(pilot))
					return
				var/confirmation = input(user,"Do you want to posses an already controled drone? The current pilot will be ejected.","Confiramtion") in list("Yes", "No")
				if(confirmation == "No")
					return
				EjectPilot()
				Posses(user)
			return
		else
			var/confirmation = input(user,"Do you want to posses [src]?","Confiramtion") in list("Yes", "No")
			if(confirmation == "No")
				return
			Posses(user)
			return
	else if(isflockmind(user) && !ckey)
		var/order = input(user,"What order do you want to issue to [src]?") in list("Move", "Cancel Order", "Repair Self", "Spawn Egg", "Move/Run", "Nothing")
		switch(order)
			if("Move")
				new /datum/flock_command/move (user, src)
			if("Cancel Order")
				LoseTarget()
				Goto(get_turf(src))
				to_chat(user, span_notice("You order [src] to cancel it's current order."))
			if("Repair Self")
				to_chat(user, span_notice("You order [src] to attempt to repair itself."))
				flock_act(src)
			if("Spawn Egg")
				egg.Trigger()
				to_chat(user, span_notice("You order [src] to attempt to spawn an egg."))
			if("Move/Run")
				toggle_move_intent(src)
				to_chat(user, span_notice("You order [src] to switch is move intent."))
			if("Nothing")
				return
