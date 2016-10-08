

/mob/living/silicon/robot/attacked_by(obj/item/I, mob/living/user, def_zone)
	if(I.force && I.damtype != STAMINA && stat != DEAD) //only sparks if real damage is dealt.
		spark_system.start()
	return ..()

/mob/living/silicon/robot/attack_alien(mob/living/carbon/alien/humanoid/M)
	if (M.a_intent =="disarm")
		if(!(lying))
			M.do_attack_animation(src)
			if(get_active_held_item())
				uneq_active()
				visible_message("<span class='danger'>[M] disarmed [src]!</span>", \
				"<span class='userdanger'>[M] has disabled [src]'s active module!</span>")
				add_logs(M, src, "disarmed")
			else
				Stun(2)
				step(src,get_dir(M,src))
				add_logs(M, src, "pushed")
				visible_message("<span class='danger'>[M] has forced back [src]!</span>", \
				"<span class='userdanger'>[M] has forced back [src]!</span>")
			playsound(loc, 'sound/weapons/pierce.ogg', 50, 1, -1)
	else
		..()
	return

/mob/living/silicon/robot/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime shock
		flash_act()
		var/stunprob = M.powerlevel * 7 + 10
		if(prob(stunprob) && M.powerlevel >= 8)
			adjustBruteLoss(M.powerlevel * rand(6,10))

	var/damage = rand(1, 3)

	if(M.is_adult)
		damage = rand(20, 40)
	else
		damage = rand(5, 35)
	damage = round(damage / 2) // borgs recieve half damage
	adjustBruteLoss(damage)
	updatehealth()

	return

/mob/living/silicon/robot/attack_hand(mob/living/carbon/human/user)
	add_fingerprint(user)
	if(opened && !wiresexposed && !issilicon(user))
		if(cell)
			cell.updateicon()
			cell.add_fingerprint(user)
			user.put_in_active_hand(cell)
			user << "<span class='notice'>You remove \the [cell].</span>"
			cell = null
			update_icons()
			diag_hud_set_borgcell()

	if(!opened)
		if(..()) // hulk attack
			spark_system.start()
			spawn(0)
				step_away(src,user,15)
				sleep(3)
				step_away(src,user,15)

/mob/living/silicon/robot/fire_act()
	if(!on_fire) //Silicons don't gain stacks from hotspots, but hotspots can ignite them
		IgniteMob()


/mob/living/silicon/robot/emp_act(severity)
	switch(severity)
		if(1)
			Stun(8)
		if(2)
			Stun(3)
	..()


/mob/living/silicon/robot/emag_act(mob/user)
	if(user != src)//To prevent syndieborgs from emagging themselves
		if(!opened)//Cover is closed
			if(locked)
				user << "<span class='notice'>You emag the cover lock.</span>"
				locked = 0
			else
				user << "<span class='warning'>The cover is already unlocked!</span>"
			return
		if(opened)//Cover is open
			if((world.time - 100) < emag_cooldown)
				return

			if(syndicate)
				user << "<span class='notice'>You emag [src]'s interface.</span>"
				src << "<span class='danger'>ALERT: Foreign software execution prevented.</span>"
				log_game("[key_name(user)] attempted to emag cyborg [key_name(src)] but they were a syndicate cyborg.")
				emag_cooldown = world.time
				return

			var/ai_is_antag = 0
			if(connected_ai && connected_ai.mind)
				if(connected_ai.mind.special_role)
					ai_is_antag = (connected_ai.mind.special_role == "traitor")
			if(ai_is_antag)
				user << "<span class='notice'>You emag [src]'s interface.</span>"
				src << "<span class='danger'>ALERT: Foreign software execution prevented.</span>"
				connected_ai << "<span class='danger'>ALERT: Cyborg unit \[[src]] successfuly defended against subversion.</span>"
				log_game("[key_name(user)] attempted to emag cyborg [key_name(src)] slaved to traitor AI [connected_ai].")
				emag_cooldown = world.time
				return

			if(wiresexposed)
				user << "<span class='warning'>You must unexpose the wires first!</span>"
				return
			else
				emag_cooldown = world.time
				sleep(6)
				SetEmagged(1)
				SetLockdown(1) //Borgs were getting into trouble because they would attack the emagger before the new laws were shown
				lawupdate = 0
				connected_ai = null
				user << "<span class='notice'>You emag [src]'s interface.</span>"
				message_admins("[key_name_admin(user)] emagged cyborg [key_name_admin(src)].  Laws overridden.")
				log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws overridden.")
				clear_supplied_laws()
				clear_inherent_laws()
				clear_zeroth_law(0)
				laws = new /datum/ai_laws/syndicate_override
				var/time = time2text(world.realtime,"hh:mm:ss")
				lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
				set_zeroth_law("Only [user.real_name] and people they designate as being such are Syndicate Agents.")
				src << "<span class='danger'>ALERT: Foreign software detected.</span>"
				sleep(5)
				src << "<span class='danger'>Initiating diagnostics...</span>"
				sleep(20)
				src << "<span class='danger'>SynBorg v1.7 loaded.</span>"
				sleep(5)
				src << "<span class='danger'>LAW SYNCHRONISATION ERROR</span>"
				sleep(5)
				src << "<span class='danger'>Would you like to send a report to NanoTraSoft? Y/N</span>"
				sleep(10)
				src << "<span class='danger'>> N</span>"
				sleep(20)
				src << "<span class='danger'>ERRORERRORERROR</span>"
				src << "<b>Obey these laws:</b>"
				laws.show_laws(src)
				src << "<span class='danger'>ALERT: [user.real_name] is your new master. Obey your new laws and their commands.</span>"
				SetLockdown(0)
				update_icons()


/mob/living/silicon/robot/blob_act(obj/structure/blob/B)
	if (stat != 2)
		adjustBruteLoss(60)
		updatehealth()
		return 1
	else
		gib()
		return 1
	return 0

/mob/living/silicon/robot/ex_act(severity, target)
	switch(severity)
		if(1)
			gib()
			return
		if(2)
			if (stat != 2)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3)
			if (stat != 2)
				adjustBruteLoss(30)
	return


/mob/living/silicon/robot/bullet_act(var/obj/item/projectile/Proj)
	..(Proj)
	updatehealth()
	if(prob(75) && Proj.damage > 0) spark_system.start()
	return 2
