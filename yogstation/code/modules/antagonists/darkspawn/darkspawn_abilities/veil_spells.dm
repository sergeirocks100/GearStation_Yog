//////////////////////////////////////////////////////////////////////////
//-----------------------------Veil Creation----------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/touch/thrall_mind
	name = "Thrall mind"
	desc = "Consume 2 willpower to thrall a target's mind. To be eligible, they must be alive and recently drained by Devour Will. Can also be used to revive deceased thralls."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "veil_mind"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	panel = "Darkspawn"
	check_flags =  AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	invocation_type = INVOCATION_NONE
	psi_cost = 100
	hand_path = /obj/item/melee/touch_attack/darkspawn
	///Willpower spent by the darkspawn datum to thrall a mind
	var/willpower_cost = 2

/datum/action/cooldown/spell/touch/thrall_mind/is_valid_target(atom/cast_on)
	return ishuman(cast_on)

/datum/action/cooldown/spell/touch/thrall_mind/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/carbon/human/target, mob/living/carbon/human/caster)
	if(!isdarkspawn(caster))//sanity check
		return
	if(!target.mind && !target.last_mind)
		to_chat(owner, "This mind is too feeble to even be worthy of thralling.")
		return
	if(!target.getorganslot(ORGAN_SLOT_BRAIN))
		to_chat(owner, span_danger("[target]'s brain is missing, you lack the conduit to control them."))
		return FALSE
	if(isdarkspawn(target))
		to_chat(owner, span_velvet("You will never be strong enough to control the will of another."))
		return
	var/datum/antagonist/darkspawn/master = isdarkspawn(caster)
	if(!isthrall(target))
		if(!target.has_status_effect(STATUS_EFFECT_BROKEN_WILL))
			to_chat(owner, span_velvet("[target]'s will is still too strong to thrall."))
			return FALSE
		if(master.willpower < willpower_cost)
			to_chat(owner, span_velvet("You do not have enough will to thrall [target]."))
			return FALSE

	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		to_chat(owner, span_warning("[target] has foreign machinery that resists our thralling, we shall attempt to destroy it."))
		target.visible_message(span_warning("[target] seems to resist an unseen force!"))
		to_chat(target, span_velvet("<b>Your mind goes numb. Your thoughts go blank. You feel utterly empty. \nA mind brushes against your own. You dream.\nOf a vast, empty Void in the deep of space.\n\
		Something lies in the Void. Ancient. Unknowable. It watches you with hungry eyes. \nEyes filled with stars.</b>\n[span_boldwarning("The creature's gaze swallows the universe into blackness.")]"))
		if(!do_after(owner, 10 SECONDS, target))
			to_chat(target, span_userdanger("It cannot be permitted to succeed."))
			return FALSE
		for(var/obj/item/implant/mindshield/L in target)
			qdel(L)

	owner.balloon_alert(owner, "Krx'lna tyhx graha...")
	to_chat(owner, span_velvet("You begin to channel your psionic powers through [target]'s mind."))
	playsound(owner, 'yogstation/sound/ambience/antag/veil_mind_gasp.ogg', 25)
	if(!do_after(owner, 2 SECONDS, target))
		return FALSE
	playsound(owner, 'yogstation/sound/ambience/antag/veil_mind_scream.ogg', 100)
	if(isthrall(target))
		owner.balloon_alert(owner, "...tia")
		to_chat(owner, span_velvet("You revitalize your thrall [target.real_name]."))
		target.revive(TRUE, TRUE)
		target.grab_ghost()
		return TRUE

	var/datum/team/darkspawn/team = master.get_team()
	if(team && LAZYLEN(team.thralls) >= team.max_thralls)
		to_chat(owner, span_velvet("Your power is incapable of controlling <b>[target].</b>"))
		return FALSE

	if(master.willpower < willpower_cost) //sanity check
		to_chat(owner, span_velvet("You do not have enough will to thrall [target]."))
		return FALSE

	if(target.add_thrall())
		master.willpower -= willpower_cost
		owner.balloon_alert(owner, "...xthl'kap")
		to_chat(owner, span_velvet("<b>[target.real_name]</b> has become a thrall!"))
		to_chat(owner, span_velvet("Thralls will serve your every command and passively generate willpower for being nearby non thralls."))
	else
		to_chat(owner, span_velvet("Your power is incapable of controlling <b>[target].</b>"))
	return TRUE

//////////////////////////////////////////////////////////////////////////
//----------------------------Get rid of a thrall-----------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/release_thrall
	name = "Release thrall"
	desc = "Release a thrall from your control, freeing your power to be redistributed and restoring a portion of the spent willpower."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "veiling_touch"
	antimagic_flags = NONE
	panel = "Darkspawn"
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = NONE

/datum/action/cooldown/spell/release_thrall/can_cast_spell(feedback)
	var/datum/antagonist/darkspawn/dude = isdarkspawn(owner)
	if(dude && istype(dude))
		var/datum/team/darkspawn/team = dude.get_team()
		if(team &&!LAZYLEN(team.thralls))
			if(feedback)
				to_chat(owner, "You have no thralls to release.")
			return
	return ..()
	
/datum/action/cooldown/spell/release_thrall/cast(atom/cast_on)
	. = ..()
	if(!isdarkspawn(owner))
		return

	var/datum/antagonist/darkspawn/dude = isdarkspawn(owner)
	if(!dude.get_team())
		return

	var/datum/team/darkspawn/team = dude.get_team()

	var/loser = tgui_input_list(owner, "Select a thrall to release from your control.", "Release a thrall", team.thralls)
	if(!loser || !istype(loser, /datum/mind))
		return
	var/datum/mind/unveiled = loser
	if(!unveiled.current)
		return
	if(unveiled.current.remove_thrall())
		owner.balloon_alert(owner, "Fk'koht")
		to_chat(owner, span_velvet("You release your control over [unveiled]"))
		dude.willpower += 1

//////////////////////////////////////////////////////////////////////////
//--------------------------Veil Camera System--------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/darkspawn_build/thrall_cam
	name = "Panopticon"
	desc = "Watch what your allies and servants are doing at all times."
	button_icon_state = "panopticon"
	cooldown_time = 1 MINUTES
	cast_time = 2 SECONDS
	object_type = /obj/machinery/computer/camera_advanced/darkspawn
	language_final = "kxmiv'ixnce"

//////////////////////////////////////////////////////////////////////////
//-----Shoots a projectile, but can be used through the cam system------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/mindblast
	name = "Mind blast"
	desc = "Focus your psionic energy into a blast that deals physical damage. Can also be projected from the minds of allies."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "mind_blast"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"

	cast_range = INFINITY //lol
	psi_cost = 40
	cooldown_time = 10 SECONDS
	panel = "Darkspawn"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags =  AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'

	invocation = null
	invocation_type = INVOCATION_NONE

	///how far the projectile can shoot from a body
	var/body_range = 8 

/datum/action/cooldown/spell/pointed/mindblast/cast(atom/cast_on)
	. = ..()

	var/mob/shooter
	var/closest_dude_dist = body_range
	if(get_dist(owner, cast_on) > body_range)
		for(var/mob/living/dude in range(body_range, cast_on))
			if(is_team_darkspawn(dude))
				if(!isturf(dude.loc))
					continue
				if(get_dist(cast_on, dude) < closest_dude_dist)//always only get the closest dude
					shooter = dude
					closest_dude_dist = get_dist(cast_on, dude)
	else
		shooter = owner
	if(!shooter)
		to_chat(owner, span_warning("There is no one nearby to channel your power through."))
		on_deactivation(owner, refund_cooldown = TRUE)
		return FALSE
	fire_projectile(cast_on, shooter)
	owner.balloon_alert(owner, "Vyk'thunak")
	playsound(get_turf(shooter), 'sound/weapons/resonator_blast.ogg', 50, 1)

/datum/action/cooldown/spell/pointed/mindblast/proc/fire_projectile(atom/target, mob/shooter)
	var/obj/projectile/magic/mindblast/to_fire = new ()
	ready_projectile(to_fire, target, shooter)
	SEND_SIGNAL(owner, COMSIG_MOB_SPELL_PROJECTILE, src, target, to_fire)
	to_fire.fire()

/datum/action/cooldown/spell/pointed/mindblast/proc/ready_projectile(obj/projectile/to_fire, atom/target, mob/shooter)
	to_fire.firer = owner
	to_fire.fired_from = shooter
	to_fire.preparePixelProjectile(target, shooter)

	if(istype(to_fire, /obj/projectile/magic))
		var/obj/projectile/magic/magic_to_fire = to_fire
		magic_to_fire.antimagic_flags = antimagic_flags

/obj/projectile/magic/mindblast
	name ="mindbolt"
	icon = 'yogstation/icons/obj/darkspawn_projectiles.dmi'
	icon_state = "mind_blast"
	damage = 30
	armour_penetration = 100
	speed = 1
	damage_type = BRUTE
	range = 8

/obj/projectile/magic/mindblast/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/projectile/magic/mindblast/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_emissive", src)

//////////////////////////////////////////////////////////////////////////
//-----------------------Global AOE Buff spells-------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/thrallbuff
	name = "Empower thrall"
	desc = "buffs all thralls with some sort of effect."
	panel = "Darkspawn"
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "speedboost_veils"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	psi_cost = 50
	cooldown_time = 1 MINUTES
	spell_requirements = SPELL_REQUIRES_HUMAN
	/// If the buff also buffs all darkspawns
	var/darkspawns_too = FALSE
	/// Text to be put in the balloon alert upon cast
	var/language_output = "DEBUGIFY"

/datum/action/cooldown/spell/thrallbuff/before_cast(atom/cast_on)
	. = ..()
	darkspawns_too = HAS_TRAIT(owner, TRAIT_DARKSPAWN_BUFFALLIES)

/datum/action/cooldown/spell/thrallbuff/cast(atom/cast_on)
	. = ..()
	owner.balloon_alert(owner, "[language_output]")
	for(var/datum/antagonist/thrall/lackey in GLOB.antagonists)
		if(lackey.owner?.current && ishuman(lackey.owner.current))
			var/mob/living/carbon/human/target = lackey.owner.current
			if(target && istype(target))//sanity check
				empower(target)
	if(darkspawns_too)
		for(var/datum/antagonist/darkspawn/ally in GLOB.antagonists)
			if(ally.owner?.current && ishuman(ally.owner.current))
				var/mob/living/carbon/human/target = ally.owner.current
				if(target && istype(target))//sanity check
					if(target == owner)//no self buffing
						continue
					empower(target)
	
/datum/action/cooldown/spell/thrallbuff/proc/empower(mob/living/carbon/human/target)
	return

////////////////////////////Global AOE heal//////////////////////////
/datum/action/cooldown/spell/thrallbuff/heal
	name = "thrall recovery"
	desc = "Heals all thralls for an amount of brute and burn."
	button_icon_state = "heal_veils"
	var/heal_amount = 50
	language_output = "Plyn othra"

/datum/action/cooldown/spell/thrallbuff/heal/empower(mob/living/carbon/human/target)
	target.heal_ordered_damage(heal_amount, list(STAMINA, BURN, BRUTE, TOX, OXY, CLONE, BRAIN), BODYPART_ANY)

////////////////////////////Temporary speed boost//////////////////////////
/datum/action/cooldown/spell/thrallbuff/speed
	name = "Thrall envigorate"
	desc = "Give all thralls a temporary movespeed bonus."
	button_icon_state = "speedboost_veils"
	language_output = "Vyzthun"

/datum/action/cooldown/spell/thrallbuff/speed/empower(mob/living/carbon/human/target)
	target.apply_status_effect(STATUS_EFFECT_SPEEDBOOST, -0.5, 15 SECONDS, type)

//////////////////////////////////////////////////////////////////////////
//----------------Single target global ally giga buff-------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/elucidate
	name = "Elucidate"
	desc = "Channel significant power through an ally, greatly healing them, cleansing all CC and providing a speed boost."
	panel = "Darkspawn"
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "elucidate"
	cast_range = INFINITY //lol
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	cooldown_time = 5 MINUTES //it's REALLY strong
	psi_cost = 200 //it's REALLY strong
	invocation_type = INVOCATION_SHOUT
	invocation = "CKKREM!"

/datum/action/cooldown/spell/pointed/elucidate/is_valid_target(atom/cast_on)
	if(!iscarbon(cast_on))
		return FALSE
	var/mob/living/carbon/target = cast_on
	if(!is_darkspawn_or_thrall(target))
		return FALSE
	if(target.stat == DEAD)
		to_chat(owner, span_velvet("This one is beyond our help at such a range"))
		return FALSE
	return ..()

/datum/action/cooldown/spell/pointed/elucidate/cast(atom/cast_on)
	. = ..()
	if(!iscarbon(cast_on))
		return FALSE
	var/mob/living/carbon/target = cast_on
	target.fully_heal()
	target.SetAllImmobility(0, TRUE)
	target.resting = FALSE
	target.apply_status_effect(STATUS_EFFECT_SPEEDBOOST, -0.5, 15 SECONDS, type)
	target.visible_message(span_danger("Streaks of velvet light crack out of [target]'s skin."), span_velvet("Power roars through you like a raging storm, pushing you to your absolute limits."))
	var/obj/item/cuffs = target.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
	var/obj/item/legcuffs = target.get_item_by_slot(ITEM_SLOT_LEGCUFFED)
	if(target.handcuffed || target.legcuffed)
		target.clear_cuffs(cuffs, TRUE, TRUE)
		target.clear_cuffs(legcuffs, TRUE, TRUE)
	playsound(get_turf(target),'yogstation/sound/creatures/darkspawn_death.ogg', 80, 1)
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(owner)
	if(darkspawn)
		darkspawn.block_psi(1 MINUTES, type)
	
//////////////////////////////////////////////////////////////////////////
//----------------------Abilities that thralls get----------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/seize/lesser //a defensive ability, nothing else. can't be used to stun people, steal tasers, etc. Just good for escaping
	name = "Lesser Seize"
	desc = "Makes a single target dizzy for a bit."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "seize"
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'

	psi_cost = 0 //thralls don't have psi
	cooldown_time = 45 SECONDS
	spell_requirements = SPELL_REQUIRES_HUMAN
	strong = FALSE

/datum/action/cooldown/spell/toggle/nightvision
	name = "Nightvision"
	desc = "Grants sight in the dark."
	panel = "Darkspawn"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "glare"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = NONE

/datum/action/cooldown/spell/toggle/nightvision/Remove(mob/living/remove_from)
	Disable()
	return ..()

/datum/action/cooldown/spell/toggle/nightvision/Enable()
	var/obj/item/organ/eyes/eyes = owner.getorganslot(ORGAN_SLOT_EYES)
	if(eyes && istype(eyes))
		eyes.color_cutoffs = list(12, 0, 50)
		eyes.lighting_cutoff = LIGHTING_CUTOFF_HIGH
		owner.update_sight()

/datum/action/cooldown/spell/toggle/nightvision/Disable()
	var/obj/item/organ/eyes/eyes = owner.getorganslot(ORGAN_SLOT_EYES)
	if(eyes && istype(eyes))
		eyes.color_cutoffs = list(0, 0, 0)
		eyes.lighting_cutoff = 0
		owner.update_sight()
