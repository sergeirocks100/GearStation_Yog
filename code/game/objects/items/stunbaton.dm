#define STUNBATON_DISCHARGE_INTERVAL 13 //amount of active processes it takes for the stun baton to start discharging
/obj/item/melee/baton
	name = "stun baton"
	desc = "A stun baton for incapacitating people with."
	icon = 'icons/obj/weapons/baton.dmi'
	icon_state = "stunbaton"
	item_state = "baton"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("beaten")
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)

	var/cooldown_check = 0

	var/cooldown = 2 SECONDS
	var/stunforce = 100
	var/stamina_damage = 70
	var/status = 0
	var/obj/item/stock_parts/cell/cell
	var/hitcost = 1000
	var/throw_hit_chance = 35
	var/preload_cell_type //if not empty the baton starts with this type of cell
	var/cell_last_used = 0

/obj/item/melee/baton/get_cell()
	return cell

/obj/item/melee/baton/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is putting the live [name] in [user.p_their()] mouth! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (FIRELOSS)

/obj/item/melee/baton/Initialize()
	. = ..()
	if(preload_cell_type)
		if(!ispath(preload_cell_type,/obj/item/stock_parts/cell))
			log_mapping("[src] at [AREACOORD(src)] had an invalid preload_cell_type: [preload_cell_type].")
		else
			cell = new preload_cell_type(src)
	update_icon()

/obj/item/melee/baton/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..())
		return
	//Only mob/living types have stun handling
	if(status && prob(throw_hit_chance) && iscarbon(hit_atom))
		baton_stun(hit_atom)

/obj/item/melee/baton/loaded //this one starts with a cell pre-installed.
	preload_cell_type = /obj/item/stock_parts/cell/high

/obj/item/melee/baton/proc/deductcharge(chrgdeductamt)
	if(cell)
		//Note this value returned is significant, as it will determine
		//if a stun is applied or not
		. = cell.use(chrgdeductamt)
		if(status && cell.charge < hitcost)
			//we're below minimum, turn off
			status = 0
			update_icon()
			playsound(loc, "sparks", 75, 1, -1)
			STOP_PROCESSING(SSobj, src) // no more charge? stop checking for discharge


/obj/item/melee/baton/update_icon()
	if(status)
		icon_state = "[initial(icon_state)]_active"
	else if(!cell)
		icon_state = "[initial(icon_state)]_nocell"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/melee/baton/process()
	if(status)
		++cell_last_used // Will discharge in 13 processes if it is not turned off
		if(cell_last_used >= STUNBATON_DISCHARGE_INTERVAL)
			deductcharge(500)
			cell_last_used = 6 // Will discharge again in 7 processes if it is not turned off

/obj/item/melee/baton/examine(mob/user)
	. = ..()
	if(cell)
		. += span_notice("\The [src] is [round(cell.percent())]% charged.")
	else
		. += span_warning("\The [src] does not have a power source installed.")

/obj/item/melee/baton/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = W
		if(cell)
			to_chat(user, span_notice("[src] already has a cell."))
		else
			if(C.maxcharge < hitcost)
				to_chat(user, span_notice("[src] requires a higher capacity cell."))
				return
			if(!user.transferItemToLoc(W, src))
				return
			cell = W
			to_chat(user, span_notice("You install a cell in [src]."))
			update_icon()

	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(cell)
			cell.update_icon()
			cell.forceMove(get_turf(src))
			cell = null
			to_chat(user, span_notice("You remove the cell from [src]."))
			status = 0
			update_icon()
			STOP_PROCESSING(SSobj, src) // no cell, no charge; stop processing for on because it cant be on
	else
		return ..()

/obj/item/melee/baton/attack_self(mob/user)
	if(cell && cell.charge > hitcost)
		status = !status
		to_chat(user, span_notice("[src] is now [status ? "on" : "off"]."))
		playsound(loc, "sparks", 75, 1, -1)
		cell_last_used = 0
		if(status)
			START_PROCESSING(SSobj, src)
		else
			STOP_PROCESSING(SSobj, src)
	else
		status = 0
		if(!cell)
			to_chat(user, span_warning("[src] does not have a power source!"))
		else
			to_chat(user, span_warning("[src] is out of charge."))
	update_icon()
	add_fingerprint(user)

/obj/item/melee/baton/attack(mob/M, mob/living/carbon/human/user)
	if(status && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		user.visible_message(span_danger("[user] accidentally hits [user.p_them()]self with [src]!"), \
							span_userdanger("You accidentally hit yourself with [src]!"))
		user.Paralyze(stunforce*3)
		deductcharge(hitcost)
		return
	if(HAS_TRAIT(user, TRAIT_NO_STUN_WEAPONS))
		to_chat(user, span_warning("You can't seem to remember how this works!"))
		return
	//yogs edit begin ---------------------------------
	if(status && ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/stomach/ethereal/stomach = H.getorganslot(ORGAN_SLOT_STOMACH)
		if(istype(stomach))
			stomach.adjust_charge(20)
			to_chat(M,span_notice("You get charged by [src]."))
	//yogs edit end  ----------------------------------
	if(iscyborg(M))
		..()
		return


	if(ishuman(M))
		var/mob/living/carbon/human/L = M
		var/datum/martial_art/A = L.check_block()
		if(A)
			A.handle_counter(L, user)
			return

	if(user.a_intent != INTENT_HARM)
		if(status)
			if(cooldown_check <= world.time)
				if(baton_stun(M, user))
					user.do_attack_animation(M)
					return
			else
				to_chat(user, span_danger("The baton is still charging!"))
		else
			M.visible_message(span_warning("[user] has prodded [M] with [src]. Luckily it was off."), \
							span_warning("[user] has prodded you with [src]. Luckily it was off."))
	else
		if(status)
			if(cooldown_check <= world.time)
				baton_stun(M, user)
		..()


/obj/item/melee/baton/proc/baton_stun(mob/living/L, mob/user)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK)) //No message; check_shields() handles that
			playsound(L, 'sound/weapons/genhit.ogg', 50, 1)
			return 0
	if(iscyborg(loc))
		var/mob/living/silicon/robot/R = loc
		if(!R || !R.cell || !R.cell.use(hitcost))
			return 0
	else
		if(!deductcharge(hitcost))
			return 0

	var/trait_check = HAS_TRAIT(L, TRAIT_STUNRESISTANCE)

	var/obj/item/bodypart/affecting = L.get_bodypart(user.zone_selected)
	var/armor_block = L.run_armor_check(affecting, "energy")
	L.apply_damage(stamina_damage, STAMINA, user.zone_selected, armor_block)
	SEND_SIGNAL(L, COMSIG_LIVING_MINOR_SHOCK)
	var/current_stamina_damage = L.getStaminaLoss()

	if(current_stamina_damage >= 90)
		if(!L.IsParalyzed())
			to_chat(L, span_warning("You muscles seize, making you collapse[trait_check ? ", but your body quickly recovers..." : "!"]"))
		if(trait_check)
			L.Paralyze(stunforce * 0.1)
		else
			L.Paralyze(stunforce)
		L.Jitter(20)
		L.confused = max(8, L.confused)
		L.apply_effect(EFFECT_STUTTER, stunforce)
	else if(current_stamina_damage > 70)
		L.Jitter(10)
		L.confused = max(8, L.confused)
		L.apply_effect(EFFECT_STUTTER, stunforce)
	else if(current_stamina_damage >= 20)
		L.Jitter(5)
		L.apply_effect(EFFECT_STUTTER, stunforce)

	if(user)
		L.lastattacker = user.real_name
		L.lastattackerckey = user.ckey
		L.visible_message(span_danger("[user] has stunned [L] with [src]!"), \
								span_userdanger("[user] has stunned you with [src]!"))
		log_combat(user, L, "stunned")

	playsound(loc, 'sound/weapons/egloves.ogg', 50, 1, -1)

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.forcesay(GLOB.hit_appends)

	cooldown_check = world.time + cooldown

	return 1

/obj/item/melee/baton/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_SELF))
		deductcharge(1000 / severity)

//Makeshift stun baton. Replacement for stun gloves.
/obj/item/melee/baton/cattleprod
	name = "stunprod"
	desc = "An improvised stun baton."
	icon_state = "stunprod"
	item_state = "prod"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	force = 3
	throwforce = 5
	stunforce = 100
	stamina_damage = 45
	hitcost = 2000
	throw_hit_chance = 10
	slot_flags = ITEM_SLOT_BACK
	var/obj/item/assembly/igniter/sparkler = 0

/obj/item/melee/baton/cattleprod/Initialize()
	. = ..()
	sparkler = new (src)

/obj/item/melee/baton/cattleprod/baton_stun()
	if(sparkler.activate())
		..()

/obj/item/melee/baton/cattleprod/tactical
	name = "tactical stunprod"
	desc = "A cost-effective, mass-produced, tactical stun prod."
	preload_cell_type = /obj/item/stock_parts/cell/high/plus // comes with a cell
	color = "#aeb08c" // super tactical
