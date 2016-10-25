//Interdiction Lens: A powerful artifact that constantly disrupts electronics and drains power but, if it fails to find something to disrupt, turns off.
/obj/structure/destructible/clockwork/powered/interdiction_lens
	name = "interdiction lens"
	desc = "An ominous, double-pronged brass totem. There's a strange gemstone clasped between the pincers."
	clockwork_desc = "A powerful totem that constantly drains nearby electronics and funnels the power drained into nearby Sigils of Transmission."
	icon_state = "interdiction_lens"
	construction_value = 25
	active_icon = "interdiction_lens_active"
	inactive_icon = "interdiction_lens"
	break_message = "<span class='warning'>The lens flares a blinding violet before shattering!</span>"
	break_sound = 'sound/effects/Glassbr3.ogg'
	var/recharging = 0 //world.time when the lens was last used
	var/recharge_time = 1200 //if it drains no power and affects no objects, it turns off for two minutes
	var/disabled = FALSE //if it's actually usable
	var/interdiction_range = 14 //how large an area it drains and disables in

/obj/structure/destructible/clockwork/powered/interdiction_lens/examine(mob/user)
	..()
	user << "<span class='[recharging > world.time ? "nezbere_small":"brass"]'>Its gemstone [recharging > world.time ? "has been breached by writhing tendrils of blackness that cover the totem" \
	: "vibrates in place and thrums with power"].</span>"
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "<span class='nezbere_small'>If it fails to drain any electronics, it will disable itself for <b>[round(recharge_time/600, 1)]</b> minutes.</span>"

/obj/structure/destructible/clockwork/powered/interdiction_lens/toggle(fast_process, mob/living/user)
	..()
	if(active)
		SetLuminosity(4,2)
	else
		SetLuminosity(0)

/obj/structure/destructible/clockwork/powered/interdiction_lens/attack_hand(mob/living/user)
	if(user.canUseTopic(src, BE_CLOSE))
		if(disabled)
			user << "<span class='warning'>As you place your hand on the gemstone, cold tendrils of black matter crawl up your arm. You quickly pull back.</span>"
			return 0
		toggle(0, user)

/obj/structure/destructible/clockwork/powered/interdiction_lens/process()
	if(recharging > world.time)
		return
	if(disabled)
		visible_message("<span class='warning'>The writhing tendrils return to the gemstone, which begins to glow with power!</span>")
		flick("interdiction_lens_recharged", src)
		disabled = FALSE
		toggle(0)
	else
		var/successfulprocess = FALSE
		var/power_drained = 0
		var/list/atoms_to_test = list()
		for(var/A in spiral_range_turfs(interdiction_range, src))
			var/turf/T = A
			for(var/M in T)
				atoms_to_test |= M

			CHECK_TICK

		for(var/M in atoms_to_test)
			var/atom/movable/A = M
			if(!A || qdeleted(A))
				continue
			power_drained += A.power_drain(TRUE)

			if(istype(A, /obj/machinery/camera))
				var/obj/machinery/camera/C = A
				if(C.isEmpProof() || !C.status)
					continue
				successfulprocess = TRUE
				if(C.emped)
					continue
				C.emp_act(1)
			else if(istype(A, /obj/item/device/radio))
				var/obj/item/device/radio/O = A
				successfulprocess = TRUE
				if(O.emped || !O.on)
					continue
				O.emp_act(1)
			else if((isliving(A) && !is_servant_of_ratvar(A)) || istype(A, /obj/structure/closet) || istype(A, /obj/item/weapon/storage)) //other things may have radios in them but we don't care
				for(var/obj/item/device/radio/O in A.GetAllContents())
					successfulprocess = TRUE
					if(O.emped || !O.on)
						continue
					O.emp_act(1)

			CHECK_TICK

		if(power_drained && power_drained >= MIN_CLOCKCULT_POWER && return_power(power_drained))
			successfulprocess = TRUE
			playsound(src, 'sound/items/PSHOOM.ogg', 50, 1, interdiction_range-7, 1)

		if(!successfulprocess)
			visible_message("<span class='warning'>The gemstone suddenly turns horribly dark, writhing tendrils covering it!</span>")
			recharging = world.time + recharge_time
			flick("interdiction_lens_discharged", src)
			icon_state = "interdiction_lens_inactive"
			SetLuminosity(2,1)
			disabled = TRUE
