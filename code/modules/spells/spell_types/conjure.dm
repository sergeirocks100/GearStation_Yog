/obj/effect/proc_holder/spell/aoe_turf/conjure
	name = "Conjure"
	desc = "This spell conjures objs of the specified types in range."

	var/list/summon_type = list() //determines what exactly will be summoned
	//should be text, like list("/mob/living/simple_animal/bot/ed209")

	var/summon_lifespan = 0 // 0=permanent, any other time in deciseconds
	var/summon_amt = 1 //amount of objects summoned
	var/summon_ignore_density = FALSE //if set to TRUE, adds dense tiles to possible spawn places
	var/summon_ignore_prev_spawn_points = TRUE //if set to TRUE, each new object is summoned on a new spawn point

	var/list/newVars = list() //vars of the summoned objects will be replaced with those where they meet
	//should have format of list("emagged" = 1,"name" = "Wizard's Justicebot"), for example

	var/cast_sound = 'sound/items/welder.ogg'

/obj/effect/proc_holder/spell/aoe_turf/conjure/cast(list/targets,mob/user = usr)
	playsound(get_turf(user), cast_sound, 50,1)
	for(var/turf/T in targets)
		if(T.density && !summon_ignore_density)
			targets -= T

	for(var/i=0,i<summon_amt,i++)
		if(!targets.len)
			break
		var/summoned_object_type = pick(summon_type)
		var/spawn_place = pick(targets)
		if(summon_ignore_prev_spawn_points)
			targets -= spawn_place
		if(ispath(summoned_object_type, /turf))
			var/turf/O = spawn_place
			var/N = summoned_object_type
			O.ChangeTurf(N, list(/turf/baseturf_bottom, /turf/open/floor/plating), flags = CHANGETURF_INHERIT_AIR)
		else
			var/atom/summoned_object = new summoned_object_type(spawn_place)

			for(var/varName in newVars)
				if(varName in newVars)
					summoned_object.vv_edit_var(varName, newVars[varName])
			summoned_object.flags_1 |= ADMIN_SPAWNED_1
			if(summon_lifespan)
				QDEL_IN(summoned_object, summon_lifespan)

			post_summon(summoned_object, user)

/obj/effect/proc_holder/spell/aoe_turf/conjure/proc/post_summon(atom/summoned_object, mob/user)
	return

/obj/effect/proc_holder/spell/aoe_turf/conjure/summonEdSwarm //test purposes - Also a lot of fun
	name = "Dispense Wizard Justice"
	desc = "This spell dispenses wizard justice."

	summon_type = list(/mob/living/simple_animal/bot/ed209)
	summon_amt = 10
	range = 3
	newVars = list("emagged" = 2, "remote_disabled" = 1,"shoot_sound" = 'sound/weapons/laser.ogg',"projectile" = /obj/item/projectile/beam/laser, "declare_arrests" = 0,"name" = "Wizard's Justicebot")

/obj/effect/proc_holder/spell/aoe_turf/conjure/linkWorlds
	name = "Link Worlds"
	desc = "A whole new dimension for you to play with! They won't be happy about it, though."
	invocation = "WTF"
	clothes_req = FALSE
	charge_max = 600
	cooldown_min = 200
	summon_type = list(/obj/structure/spawner/nether)
	summon_amt = 1
	range = 1
	cast_sound = 'sound/weapons/marauder.ogg'

/obj/effect/proc_holder/spell/targeted/conjure_item
	name = "Summon weapon"
	desc = "A generic spell that should not exist.  This summons an instance of a specific type of item, or if one already exists, un-summons it.  Summons into hand if possible."
	invocation_type = "none"
	include_user = TRUE
	range = -1
	clothes_req = FALSE
	var/obj/item/item
	var/item_type = /obj/item/bikehorn
	school = "conjuration"
	charge_max = 150
	cooldown_min = 10
	var/delete_old = TRUE //TRUE to delete the last summoned object if it's still there, FALSE for infinite item stream weeeee

/obj/effect/proc_holder/spell/targeted/conjure_item/cast(list/targets, mob/user = usr)
	if (delete_old && item && !QDELETED(item))
		QDEL_NULL(item)
	else
		for(var/mob/living/carbon/C in targets)
			if(C.dropItemToGround(C.get_active_held_item()))
				C.put_in_hands(make_item(), TRUE)

/obj/effect/proc_holder/spell/targeted/conjure_item/Destroy()
	if(item)
		qdel(item)
	return ..()

/obj/effect/proc_holder/spell/targeted/conjure_item/proc/make_item()
	item = new item_type
	return item

/obj/effect/proc_holder/spell/aoe_turf/horde
	name = "Horde"
	desc = "Bring all your existing bloodmen to you at the cost of 3% blood per bloodman or 5 brain damage per bloodman if you're a bloodless race."
	action_icon = 'icons/mob/actions/actions_cult.dmi'
	action_icon_state = "horde"
	var/list/summon_type = list("/mob/living/simple_animal/hostile/asteroid/hivelord/legion/bloodman")
	clothes_req = FALSE
	var/summon_lifespan = 0 
	var/summon_ignore_density = FALSE 
	var/summon_ignore_prev_spawn_points = TRUE 
	var/list/newVars = list()

/obj/effect/proc_holder/spell/aoe_turf/horde/cast(list/targets,mob/living/carbon/user = usr)
	var/list/directions = GLOB.alldirs.Copy()
	if(GLOB.bloodmen_list.len < 1)
		to_chat(user, span_notice("You don't have any minions to summon!"))
		return
	for(var/mob/living/simple_animal/hostile/asteroid/hivelord/legion/bloodman in GLOB.bloodmen_list)
		var/spawndir = pick_n_take(directions)
		var/turf/T = get_step(usr, spawndir)
		if(NOBLOOD in user.dna.species.species_traits)
			user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5)
			to_chat(usr, span_notice("<span class ='userdanger'>You can almost feel your brain writhing as you call your bloodmen to you.</span>"))
		else
			user.blood_volume -= 15
			to_chat(usr, span_notice("<span class ='userdanger'>You feel yourself becoming paler with every minion called.</span>"))
		if(T)
			bloodman.forceMove(T)
			playsound(usr, 'sound/magic/exit_blood.ogg', 100, 1)

/obj/effect/proc_holder/spell/aoe_turf/conjure/radiation_anomaly
	name = "Spawn Radiation Anomaly"
	desc = "Spawn a radiation anomaly, this one is too week to spawn a radioactive goat but can fire enough rad particles to heal you and damage others."
	action_background_icon_state = "bg_default"
	action_icon = 'icons/obj/projectiles.dmi'
	action_icon_state = "radiation_anomaly"
	clothes_req = FALSE
	charge_max = 90 SECONDS
	invocation = "none"
	invocation_type = "none"
	summon_type = list(/obj/effect/anomaly/radiation)
	summon_amt = 0

/obj/effect/proc_holder/spell/aoe_turf/conjure/radiation_anomaly/cast(list/targets, mob/user)
	. = ..()
	var/mob/living/simple_animal/hostile/retaliate/goat/radioactive/S = user
	var/obj/effect/anomaly/radiation/anomaly = new (S.loc, 150)
	anomaly.has_effect = FALSE
	playsound(S, 'sound/weapons/resonator_fire.ogg', 100, TRUE)
	S.visible_message(span_notice("You see \the radiation anomaly emerges from \the [S]."), span_notice("\The radiation anomaly emerges from your body."))
	notify_ghosts("The Radioactive Goat has spawned a radiation anomaly!", source = anomaly, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Radiation Anomaly Spawned!")
