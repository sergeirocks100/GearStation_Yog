/*
	Legendary weapons, the only weapons strong enough to actually damage the infection core, also come with some cool and unique boons to the player side
*/

/obj/item/infectionkiller
	name = "infection killer"
	desc = "This should not be seen, post an issue on github."
	icon = 'icons/mob/infection/legendary_weapons.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = INDESTRUCTIBLE
	light_range = 4
	layer = ABOVE_ALL_MOB_LAYER
	// if the item should actually be treated as a real legendary, and not just a temporary item
	var/is_item = TRUE

/obj/item/infectionkiller/Initialize(mapload)
	. = ..()
	if(is_item)
		notify_ghosts("The Legendary Weapon [name] Was Found!", source = src, action = NOTIFY_ORBIT, header = "Legendary Weapon")
		if(GLOB.infection_core)
			priority_announce("The Legendary Item \"[name]\" has been discovered somewhere on the station.\n\n\
							   The bluespace radiation present inside the item allows it to be detected by standard issue GPS units.\n\
							   We believe this item contains enough power to destroy the infection core.",
							   "CentCom Exotic Materials Research Division", 'sound/magic/summonitems_generic.ogg')
		AddComponent(/datum/component/stationloving, FALSE, FALSE)
		var/obj/item/gps/internal/legendary/L = new /obj/item/gps/internal/legendary(src)
		L.gpstag = "Legendary [name] Signal"
		var/obj/item/beacon/B = new /obj/item/beacon(src)
		B.name = "Legendary [name] Beacon"
		B.renamed = TRUE

/obj/item/gps/internal/legendary
	icon_state = null
	gpstag = "Legendary Signal"
	desc = "Holds immense power."
	invisibility = 100

/obj/item/infectionkiller/blob_act()
	return

/obj/item/infectionkiller/ex_act(severity)
	return

/obj/item/infectionkiller/can_be_pulled(user, grab_state, force)
	if(isliving(user))
		var/mob/living/L = user
		if(L.faction.Find(ROLE_INFECTION))
			to_chat(L, "<span class='warning'>You feel yourself start to disintegrate as you touch the radiant object!</span>")
			playsound(get_turf(L), 'sound/effects/supermatter.ogg', 50, 1)
			L.adjustBruteLoss(30)
			return FALSE
	return ..()

/obj/item/infectionkiller/melee_attack_chain(mob/user, atom/target, params)
	if(istype(target, /obj/structure/infection))
		before_structure_attack(target, user)
	else if(isliving(target))
		var/mob/living/L = target
		if(L.faction.Find(ROLE_INFECTION))
			before_mob_attack(target, user)
	. = ..()

/obj/item/infectionkiller/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(istype(target, /obj/structure/infection))
		after_structure_attack(target, user)
	else if(isliving(target))
		var/mob/living/L = target
		if(L.faction.Find(ROLE_INFECTION))
			after_mob_attack(target, user)
	. = ..()
/*
	Is called before an infection mob is attacked
*/
/obj/item/infectionkiller/proc/before_mob_attack(mob/living/M, mob/living/user)
	return

/*
	Is called before an infection structure is attacked
*/
/obj/item/infectionkiller/proc/before_structure_attack(obj/O, mob/living/user)
	return

/*
	Is called after the infection structure has been attacked
*/
/obj/item/infectionkiller/proc/after_structure_attack(obj/O, mob/living/user)
	return

/*
	Is called after the infection mob was attacked
*/
/obj/item/infectionkiller/proc/after_mob_attack(mob/living/M, mob/living/user)
	return

/obj/item/infectionkiller/excaliju
	name = "Excaliju"
	desc = "An ancient sword with several runes carved along the blade. Deathblows to infested creatures massively increase its damage for 5 seconds."
	icon_state = "excaliju"
	item_state = "excaliju"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/wpnHit1.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	force = 25
	armour_penetration = 50
	block_chance = 75
	sharpness = SHARP_EDGED
	// time until the proc ends
	var/proctime = 0
	// variable that stores if the mob was alive before we attacked it
	var/before_was_alive

/*
	Checks if the sword is procced, which allows it to do incredible amounts of damage
*/
/obj/item/infectionkiller/excaliju/proc/is_procced()
	if(proctime > world.time)
		return TRUE
	return FALSE

/*
	Plays a sound and starts the proc when you kill an infection mob with this sword, only shows the text if the proc has ended and is starting again
*/
/obj/item/infectionkiller/excaliju/proc/proc_start(mob/living/M, mob/living/user)
	playsound(src.loc, 'sound/weapons/wpnProc.ogg', 300, 1, vary = FALSE, pressure_affected = FALSE)
	if(!is_procced() && prob(20))
		to_chat(user, "<span class='colossus'><b>[pick("DEATH FEARS ME!","PROTECT THE SHRINE!","OLDDD MAAAN WILLAKERRRS!")]</b></span>")
	proctime = world.time + 50 // 5 seconds of big ass damage to other infection mobs if you manage to kill one infection mob, chain procs
	addtimer(CALLBACK(src, .proc/proc_end), 50)

/*
	Ends the proc and plays a sound to indicate so
*/
/obj/item/infectionkiller/excaliju/proc/proc_end()
	if(is_procced())
		return
	playsound(src.loc, 'sound/weapons/emitter2.ogg', 300, 1, vary = FALSE, pressure_affected = FALSE)

/obj/item/infectionkiller/excaliju/before_mob_attack(mob/living/M, mob/living/user)
	before_was_alive = (M && M.stat != DEAD) // you gotta kill it to get the big power boost
	if(is_procced())
		src.force *= 5

/obj/item/infectionkiller/excaliju/after_mob_attack(mob/living/M, mob/living/user)
	src.force = initial(force)
	if(!M || M.stat == DEAD && before_was_alive)
		proc_start(M, user)

/obj/item/infectionkiller/excaliju/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(is_procced())
		user.changeNext_move(CLICK_CD_MELEE * 0.25)

/obj/item/infectionkiller/drill
	name = "Drill of Legends"
	desc = "A glowing golden drill, bluespace energies infused into the drill bit allow it to slice thick infection with ease."
	icon_state = "drilloflegends"
	item_state = "drilloflegends"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	force = 30
	armour_penetration = 100
	tool_behaviour = TOOL_MINING
	toolspeed = 0.01
	usesound = list('sound/effects/picaxe1.ogg', 'sound/effects/picaxe2.ogg', 'sound/effects/picaxe3.ogg')
	attack_verb = list("hit", "pierced", "sliced", "attacked")

/obj/item/infectionkiller/staff
	name = "Golden Staff of the Honkmother"
	desc = "The golden staff of the honkmother, containing a stable bluespace portal to a clown monastary on clown planet."
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "honker"
	item_state = "honker"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	color = "#ffbb00"
	force = 25
	hitsound = list('sound/items/airhorn.ogg')
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	actions_types = list(/datum/action/item_action/summon_clowns)

/datum/action/item_action/summon_clowns
	name = "Summon Sentient Clown"
	desc = "Take a clown out of this staff to help you fight, and reclaim the clown motherland."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "clown"
	// stores the clowns created by the action
	var/list/clowns_created = list()
	// max clowns available at a time
	var/max_clowns = 5
	// cooldown time for clowns
	var/cooldown_time = 0
	// cooldown time added for clown spawning in deciseconds
	var/cooldown_time_added = 150
	// possible mobs to be spawned from the staff, weighted list, higher number means more chance to be picked
	var/list/possible_mobs = list(/mob/living/simple_animal/hostile/retaliate/clown/clownhulk=2,
						/mob/living/simple_animal/hostile/retaliate/clown/longface=3,
						/mob/living/simple_animal/hostile/retaliate/clown/clownhulk/chlown=2,
						/mob/living/simple_animal/hostile/retaliate/clown/mutant/blob=3,
						/mob/living/simple_animal/hostile/retaliate/clown/clownhulk/destroyer=2,
						/mob/living/simple_animal/hostile/retaliate/clown/fleshclown=2,
						/mob/living/simple_animal/hostile/retaliate/clown/clownhulk/honcmunculus=2,
						/mob/living/simple_animal/hostile/retaliate/clown/mutant=2)

/datum/action/item_action/summon_clowns/IsAvailable()
	// get rid of clowns that don't exist anymore
	for(var/mob/living/SM in clowns_created)
		if(!SM || SM.stat == DEAD)
			clowns_created -= SM
	return (cooldown_time <= world.time) && (clowns_created.len < max_clowns) && ..()

/datum/action/item_action/summon_clowns/Trigger()
	if(..())
		// people are going to try and use it as often as possible anyways, might as well just apply the full cooldown whether it works or not
		cooldown_time = world.time + cooldown_time_added
		UpdateButtonIcon()
		to_chat(owner, "<span class='warning'>You reach into the staff to pull out a clown...</span>")
		var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as a summoned clown?", ROLE_SENTIENCE, null, ROLE_SENTIENCE, 50, POLL_IGNORE_CLOWN_STAFF_SUMMON) //players must answer rapidly // see poll_ignore.dm
		if(LAZYLEN(candidates))
			var/mob/dead/observer/C = pick(candidates)
			var/picked_type = pickweight(possible_mobs)
			var/mob/living/simple_animal/SM = new picked_type(owner.loc)
			SM.loot = list(/obj/effect/gibspawner/human)
			SM.key = C.key
			clowns_created += SM
			to_chat(SM, "<span class='userdanger'>You are grateful to be chosen to reclaim the clown motherland! Serve and assist [owner.real_name] and the station in defeating the infection as your first task!</span>")
			to_chat(owner, "<span class='notice'>And you pull [SM] out of the staff! It worked!</span>")
		else
			to_chat(owner, "<span class='notice'>You can't find a clown in the staff!</span>")
	sleep(cooldown_time_added)
	UpdateButtonIcon()

/obj/item/infectionkiller/tonic
	name = "Spinel Tonic"
	desc = "An ancient recreational substance, when imbibed it boosts the drinker's physical capabilities to near godhood. Gives stunproofing, speed, and a strong unarmed attack."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "atomicbombglass"
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	color = "#000080"

/obj/item/infectionkiller/tonic/attack(mob/living/M, mob/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		to_chat(H, "<span class='colossus'><b>YOU FEEL LIKE A GOD.</b></span>")
		H.AddComponent(/datum/component/superpowers, -1, FALSE, FALSE, /obj/item/infectionkiller/tonicfists, /obj/item/infectionkiller/tonic)
		qdel(src, force=TRUE)
		return
	. = ..()

/obj/item/infectionkiller/tonicfists
	name = "Tonic Powered Fists"
	desc = "H-He's fast!"
	icon = 'icons/effects/blood.dmi'
	icon_state = "bloodhand_left"
	force = 30
	color = "#000080"
	is_item = FALSE

/obj/item/infectionkiller/tonicfists/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	user.changeNext_move(CLICK_CD_MELEE * 0.25)
