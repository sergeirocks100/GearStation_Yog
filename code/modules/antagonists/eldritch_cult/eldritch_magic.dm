/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash
	name = "Ashen Passage"
	desc = "A short range spell that allows you to pass unimpeded through walls."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "ash_shift"
	sound = null

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	exit_jaunt_sound = null
	jaunt_duration = 1.1 SECONDS
	jaunt_in_time = 1.3 SECONDS
	jaunt_out_time = 0.6 SECONDS
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/ash_shift
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/ash_shift/out
	

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash/do_steam_effects()
	return

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash/long
	name = "Ashen Walk"
	desc = "A long range spell that allows you pass unimpeded through multiple walls."
	jaunt_duration = 5 SECONDS

/obj/effect/temp_visual/dir_setting/ash_shift
	name = "ash_shift"
	icon = 'icons/mob/mob.dmi'
	icon_state = "ash_shift2"
	duration = 1.3 SECONDS

/obj/effect/temp_visual/dir_setting/ash_shift/out
	icon_state = "ash_shift"

/datum/action/cooldown/spell/touch/mansus_grasp
	name = "Mansus Grasp"
	desc = "A powerful combat initiation spell that deals massive stamina damage. It may have other effects if you continue your research..."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mansus_grasp"
	sound = 'sound/items/welder.ogg'

	school = SCHOOL_EVOCATION
	cooldown_time = 10 SECONDS

	invocation = "R'CH T'H TR'TH!"
	invocation_type = INVOCATION_SHOUT
	// Mimes can cast it. Chaplains can cast it. Anyone can cast it, so long as they have a hand.
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	hand_path = /obj/item/melee/touch_attack/mansus_fist

/datum/action/cooldown/spell/touch/mansus_grasp/is_valid_target(atom/cast_on)
	return TRUE // This baby can hit anything

/datum/action/cooldown/spell/touch/mansus_grasp/can_cast_spell(feedback = TRUE)
	return ..() && !!IS_HERETIC(owner)

/datum/action/cooldown/spell/touch/mansus_grasp/on_antimagic_triggered(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	victim.visible_message(
		span_danger("The spell bounces off of [victim]!"),
		span_danger("The spell bounces off of you!"),
	)

/datum/action/cooldown/spell/touch/mansus_grasp/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
//	if(!isliving(victim)) for now, makes heretic hand hit everything but it's for the best
//		return FALSE

	if(SEND_SIGNAL(caster, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, victim) & COMPONENT_BLOCK_HAND_USE)
		return FALSE

	if(isliving(victim))
		var/mob/living/living_hit = victim
		living_hit.apply_damage(10, BRUTE, wound_bonus = CANT_WOUND)
		if(iscarbon(victim))
			var/mob/living/carbon/carbon_hit = victim
			carbon_hit.adjust_timed_status_effect(4 SECONDS, /datum/status_effect/speech/slurring/heretic)
			carbon_hit.AdjustKnockdown(5 SECONDS)
			carbon_hit.adjustStaminaLoss(80)

	return TRUE

/obj/item/melee/touch_attack/mansus_fist
	name = "Mansus Grasp"
	desc = "A sinister looking aura that distorts the flow of reality around it. \
		Causes knockdown, minor bruises, and major stamina damage. \
		It gains additional beneficial effects as you expand your knowledge of the Mansus."
	icon_state = "mansus"
	item_state = "mansus"

/obj/item/melee/touch_attack/mansus_fist/ignition_effect(atom/A, mob/user)
	. = span_notice("[user] effortlessly snaps [user.p_their()] fingers near [A], igniting it with eldritch energies. Fucking badass!")
	remove_hand_with_no_refund(user)

/datum/action/cooldown/spell/pointed/mansus_ranged
	name = "Knowing Mansus Grasp"
	desc = "A powerful combat initiation spell that knocks down it's target and blurs their vision. It may have other effects if you continue your research..."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mansus_grasp"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	sound = 'sound/items/welder.ogg'
	school = SCHOOL_EVOCATION
	cooldown_time = 20 SECONDS

	invocation = "R'CH T'H TR'TH!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION
	cast_range = 3

	active_msg = "You prepare to grasp at someone with your mind..."

	/// How long you want to keep them down
	var/knockdown_duration = 2 SECONDS
	/// How long their eyes should be blurry for
	var/eye_blur_duration = 1 SECONDS
	/// How long their eyes should be blind for
	var/eye_blind_duration = 0

/datum/action/cooldown/spell/pointed/mansus_ranged/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(cast_on))
		return FALSE

	var/mob/living/carbon/human/human_target = cast_on
	return !is_blind(human_target)

/datum/action/cooldown/spell/pointed/mansus_ranged/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("You feel a light tap on your shoulder."))
		to_chat(owner, span_warning("The spell had no effect!"))
		return FALSE

	to_chat(cast_on, span_warning("Your mind cries out in pain!"))
	cast_on.Knockdown(knockdown_duration)
	cast_on.blur_eyes(eye_blur_duration)
	cast_on.blind_eyes(eye_blind_duration)
	return TRUE

/datum/action/cooldown/spell/pointed/mansus_ranged/upgraded
	name = "All Knowing Mansus Grasp"
	desc = "A powerful combat initiation spell that knocks down targets, blurs their vision, and temporarily blinds them. You have perfected this technique."
	button_icon_state = "mad_touch"

	cooldown_time = 25 SECONDS

	cast_range = 4

	eye_blur_duration = 2 SECONDS
	eye_blind_duration = 1 SECONDS


/datum/action/cooldown/spell/aoe/rust_conversion
	name = "Aggressive Spread"
	desc = "Spread rust onto nearby turfs, possibly destroying rusted walls."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "corrode"
	sound = 'sound/items/welder.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "A'GRSV SPR'D"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	aoe_radius = 3

/datum/action/cooldown/spell/aoe/rust_conversion/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/turf/nearby_turf in range(aoe_radius, center))
		things += nearby_turf

	return things

/datum/action/cooldown/spell/aoe/rust_conversion/cast_on_thing_in_aoe(turf/victim, atom/caster)
	// We have less chance of rusting stuff that's further
	var/distance_to_caster = get_dist(victim, caster)
	var/chance_of_not_rusting = (max(distance_to_caster, 1) - 1) * 100 / (aoe_radius + 1)

	if(prob(chance_of_not_rusting))
		return

	victim.rust_heretic_act()

/datum/action/cooldown/spell/aoe/rust_conversion/small
	name = "Rust Conversion"
	desc = "Spreads rust onto nearby surfaces."
	aoe_radius = 2

/datum/action/cooldown/spell/pointed/blood_siphon
	name = "Blood Siphon"
	desc = "A touch spell that heals your wounds while damaging the enemy. \
		It has a chance to transfer wounds between you and your enemy."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "blood_siphon"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	invocation = "FL'MS O'ET'RN'ITY"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	cast_range = 6

/datum/action/cooldown/spell/pointed/blood_siphon/can_cast_spell(feedback = TRUE)
	return ..() && isliving(owner)

/datum/action/cooldown/spell/pointed/blood_siphon/is_valid_target(atom/cast_on)
	return ..() && isliving(cast_on)

/datum/action/cooldown/spell/pointed/blood_siphon/cast(mob/living/cast_on)
	. = ..()
	playsound(owner, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	if(cast_on.can_block_magic())
		owner.balloon_alert(owner, "spell blocked!")
		cast_on.visible_message(
			span_danger("The spell bounces off of [cast_on]!"),
			span_danger("The spell bounces off of you!"),
		)
		return FALSE

	cast_on.visible_message(
		span_danger("[cast_on] turns pale as a red glow envelops [cast_on.p_them()]!"),
		span_danger("You pale as a red glow enevelops you!"),
	)

	var/mob/living/living_owner = owner
	cast_on.adjustBruteLoss(20)
	living_owner.adjustBruteLoss(-20)

	if(!cast_on.blood_volume || !living_owner.blood_volume)
		return TRUE

	cast_on.blood_volume -= 20
	if(living_owner.blood_volume < BLOOD_VOLUME_MAXIMUM(living_owner)) // we dont want to explode from casting
		living_owner.blood_volume += 20

	if(!iscarbon(cast_on) || !iscarbon(owner))
		return TRUE

	var/mob/living/carbon/carbon_target = cast_on
	var/mob/living/carbon/carbon_user = owner
	for(var/obj/item/bodypart/bodypart as anything in carbon_user.bodyparts)
		for(var/datum/wound/iter_wound as anything in bodypart.wounds)
			if(prob(50))
				continue
			var/obj/item/bodypart/target_bodypart = locate(bodypart.type) in carbon_target.bodyparts
			if(!target_bodypart)
				continue
			iter_wound.remove_wound()
			iter_wound.apply_wound(target_bodypart)
	
	return TRUE

// Shoots a straight line of rusty stuff ahead of the caster, what rust monsters get
/datum/action/cooldown/spell/basic_projectile/rust_wave
	name = "Patron's Reach"
	desc = "Fire a rust spreading projectile in front of you, dealing toxin damage to whatever it hits."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "rust_wave"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 35 SECONDS

	invocation = "SPR'D TH' WO'D"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	projectile_type = /obj/item/projectile/magic/aoe/rust_wave

/obj/item/projectile/magic/aoe/rust_wave
	name = "Patron's Reach"
	icon_state = "eldritch_projectile"
	alpha = 180
	damage = 30
	damage_type = TOX
	nodamage = FALSE
	hitsound = 'sound/weapons/punch3.ogg'
	ignored_factions = list("heretics")
	range = 15
	speed = 1

/obj/item/projectile/magic/aoe/rust_wave/Moved(atom/OldLoc, Dir)
	. = ..()
	playsound(src, 'sound/items/welder.ogg', 75, TRUE)
	var/list/turflist = list()
	var/turf/T1
	turflist += get_turf(src)
	T1 = get_step(src,turn(dir,90))
	turflist += T1
	turflist += get_step(T1,turn(dir,90))
	T1 = get_step(src,turn(dir,-90))
	turflist += T1
	turflist += get_step(T1,turn(dir,-90))
	for(var/X in turflist)
		if(!X || prob(25))
			continue
		var/turf/T = X
		T.rust_heretic_act()

/datum/action/cooldown/spell/basic_projectile/rust_wave/short
	name = "Lesser Patron's Reach"
	projectile_type = /obj/item/projectile/magic/aoe/rust_wave/short

/obj/item/projectile/magic/aoe/rust_wave/short
	range = 7
	speed = 2

/datum/action/cooldown/spell/pointed/cleave
	name = "Cleave"
	desc = "Causes severe bleeding on a target and people around them"
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "cleave"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 35 SECONDS

	invocation = "CL'VE"
	invocation_type = INVOCATION_WHISPER

	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	cast_range = 4

	/// The radius of the cleave effect
	var/cleave_radius = 1
	/// What type of wound we apply
	var/wound_type = /datum/wound/slash/critical/cleave

/datum/action/cooldown/spell/pointed/cleave/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/cleave/cast(mob/living/carbon/human/cast_on)
	. = ..()
	for(var/mob/living/carbon/human/victim in range(cleave_radius, cast_on))
		if(victim == owner || IS_HERETIC(victim) || IS_HERETIC_MONSTER(victim))
			continue
		if(victim.can_block_magic(antimagic_flags))
			victim.visible_message(
				span_danger("[victim]'s flashes in a firey glow, but repels the blaze!"),
				span_danger("Your body begins to flash a firey glow, but you are protected!!")
			)
			continue

		if(!victim.blood_volume)
			continue

		victim.visible_message(
			span_danger("[victim]'s veins are shredded from within as an unholy blaze erupts from [victim.p_their()] blood!"),
			span_danger("Your veins burst from within and unholy flame erupts from your blood!")
		)

		var/obj/item/bodypart/bodypart = pick(victim.bodyparts)
		var/datum/wound/slash/crit_wound = new wound_type()
		crit_wound.apply_wound(bodypart)
		victim.apply_damage(20, BURN, wound_bonus = CANT_WOUND)

		new /obj/effect/temp_visual/cleave(get_turf(victim))

	return TRUE

/datum/action/cooldown/spell/pointed/cleave/long
	name = "Deeper Cleave"
	cooldown_time = 65 SECONDS

// Currently unused.
/datum/action/cooldown/spell/touch/mad_touch
	name = "Touch of Madness"
	desc = "Strange energies engulf your hand, you feel even the sight of them would cause a headache if you didn't understand them."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mad_touch"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND

/datum/action/cooldown/spell/touch/mad_touch/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	if(!ishuman(victim))
		return FALSE

	var/mob/living/carbon/human/human_victim = victim
	if(!human_victim.mind || IS_HERETIC(human_victim))
		return FALSE

	if(human_victim.can_block_magic(antimagic_flags))
		victim.visible_message(
			span_danger("The spell bounces off of [victim]!"),
			span_danger("The spell bounces off of you!"),
		)
		return FALSE

	to_chat(caster, span_warning("[human_victim.name] has been cursed!"))
	SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "gates_of_mansus", /datum/mood_event/gates_of_mansus)
	return TRUE

// Currently unused - releases streams of fire around the caster.
/datum/action/cooldown/spell/pointed/ash_beams
	name = "Nightwatcher's Rite"
	desc = "A powerful spell that releases five streams of eldritch fire towards the target."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "flames"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	invocation = "F'RE"
	invocation_type = INVOCATION_WHISPER
	
	cooldown_time = 30 SECONDS
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	/// The length of the flame line spit out.
	var/flame_line_length = 15

/datum/action/cooldown/spell/pointed/ash_beams/is_valid_target(atom/cast_on)
	return TRUE

/datum/action/cooldown/spell/pointed/ash_beams/cast(atom/target)
	. = ..()
	var/static/list/offsets = list(-25, -10, 0, 10, 25)
	for(var/offset in offsets)
		INVOKE_ASYNC(src, PROC_REF(fire_line), owner, line_target(offset, flame_line_length, target, owner))

/datum/action/cooldown/spell/pointed/ash_beams/proc/line_target(offset, range, atom/at, atom/user)
	if(!at)
		return
	var/angle = ATAN2(at.x - user.x, at.y - user.y) + offset
	var/turf/T = get_turf(user)
	for(var/i in 1 to range)
		var/turf/check = locate(user.x + cos(angle) * i, user.y + sin(angle) * i, user.z)
		if(!check)
			break
		T = check
	return (getline(user, T) - get_turf(user))

/datum/action/cooldown/spell/pointed/ash_beams/proc/fire_line(atom/source, list/turfs)
	var/list/hit_list = list()
	for(var/turf/T in turfs)
		if(istype(T, /turf/closed))
			break

		for(var/mob/living/L in T.contents)
			if(L.anti_magic_check())
				L.visible_message(span_danger("The fire parts in front of [L]!"),span_danger("As the fire approaches it splits off to avoid contact with you!"))
				continue
			if(L in hit_list || L == source)
				continue
			hit_list += L
			L.adjustFireLoss(20)
			to_chat(L, span_userdanger("You're hit by [source]'s fire blast!"))

		new /obj/effect/hotspot(T)
		T.hotspot_expose(700,50,1)
		// deals damage to mechs
		for(var/obj/mecha/M in T.contents)
			if(M in hit_list)
				continue
			hit_list += M
			M.take_damage(45, BURN, MELEE, 1)
		sleep(0.15 SECONDS)

/datum/action/cooldown/spell/shapeshift/eldritch
	name = "Shapechange"
	desc = "A spell that allows you to take on the form of another creature, gaining their abilities. \
		After making your choice, you will be unable to change to another."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"

	school = SCHOOL_FORBIDDEN
	invocation = "SH'PE"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	possible_shapes = list(
		/mob/living/simple_animal/mouse,\
		/mob/living/simple_animal/pet/dog/corgi,\
		/mob/living/simple_animal/hostile/carp/megacarp,\
		/mob/living/simple_animal/pet/fox,\
		/mob/living/simple_animal/hostile/netherworld/migo,\
		/mob/living/simple_animal/bot/medbot,\
		/mob/living/simple_animal/pet/cat 
	)

/datum/action/cooldown/spell/emp/eldritch
	name = "Entropic Pulse"
	desc = "A spell that causes a large EMP around you, disabling electronics."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "E'P"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	emp_heavy = 6
	emp_light = 10

/// Creates one, large, expanding ring of fire around the caster, which does not follow them.
/datum/action/cooldown/spell/fire_cascade
	name = "Lesser Fire Cascade"
	desc = "Heats the air around you."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "fire_ring"
	sound = 'sound/items/welder.ogg'

	school = SCHOOL_FORBIDDEN
	invocation = "C'SC'DE"
	invocation_type = INVOCATION_WHISPER

	cooldown_time = 30 SECONDS
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	/// The radius the flames will go around the caster.
	var/flame_radius = 4

/datum/action/cooldown/spell/fire_cascade/cast(atom/cast_on)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(fire_cascade), get_turf(cast_on), flame_radius)

/// Spreads a huge wave of fire in a radius around us, staggered between levels
/datum/action/cooldown/spell/fire_cascade/proc/fire_cascade(atom/centre, flame_radius = 1)
	for(var/i in 0 to flame_radius)
		for(var/turf/nearby_turf as anything in spiral_range_turfs(i + 1, centre))
			new /obj/effect/hotspot(nearby_turf)
			nearby_turf.hotspot_expose(750, 50, 1)
			for(var/mob/living/fried_living in nearby_turf.contents - centre)
				fried_living.apply_damage(5, BURN)
		stoplag(0.3 SECONDS)

/datum/action/cooldown/spell/fire_cascade/big
	name = "Greater Fire Cascade"
	flame_radius = 6

/datum/action/cooldown/spell/list_target/telepathy/eldritch
	name = "Eldritch Telepathy"
	school = SCHOOL_FORBIDDEN
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND

/// Creates a constant Ring of Fire around the caster for a set duration of time, which follows them.
/datum/action/cooldown/spell/fire_sworn
	name = "Oath of Fire"
	desc = "Engulf yourself in a cloak of flames for a minute. The flames are harmless to you, but dangerous to anyone else."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "fire_ring"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 70 SECONDS
	
	invocation = "FL'MS"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	/// The radius of the fire ring
	var/fire_radius = 1
	/// How long it the ring lasts
	var/duration = 1 MINUTES

/datum/action/cooldown/spell/fire_sworn/Remove(mob/living/remove_from)
	remove_from.remove_status_effect(/datum/status_effect/fire_ring)
	return ..()

/datum/action/cooldown/spell/fire_sworn/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/fire_sworn/cast(mob/living/cast_on)
	. = ..()
	cast_on.apply_status_effect(/datum/status_effect/fire_ring, duration, fire_radius)

/// Simple status effect for adding a ring of fire around a mob.
/datum/status_effect/fire_ring
	id = "fire_ring"
	tick_interval = 0.1 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	/// The radius of the ring around us.
	var/ring_radius = 1

/datum/status_effect/fire_ring/on_creation(mob/living/new_owner, duration = 1 MINUTES, radius = 1)
	src.duration = duration
	src.ring_radius = radius
	return ..()

/datum/status_effect/fire_ring/tick(delta_time, times_fired)
	if(QDELETED(owner) || owner.stat == DEAD)
		qdel(src)
		return

	if(!isturf(owner.loc))
		return

	for(var/turf/nearby_turf as anything in RANGE_TURFS(1, owner))
		new /obj/effect/hotspot(nearby_turf)
		nearby_turf.hotspot_expose(750, 25 * delta_time, 1)
		for(var/mob/living/fried_living in nearby_turf.contents - owner)
			fried_living.apply_damage(2.5 * delta_time, BURN)


/datum/action/cooldown/spell/worm_contract
	name = "Force Contract"
	desc = "Forces all the worm parts to collapse onto a single turf"
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "worm_contract"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	invocation_type = INVOCATION_NONE
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

/datum/action/cooldown/spell/worm_contract/cast(mob/living/user)
	. = ..()
	if(!istype(user,/mob/living/simple_animal/hostile/eldritch/armsy))
		to_chat(user, span_userdanger("You try to contract your muscles but nothing happens..."))
		return
	var/mob/living/simple_animal/hostile/eldritch/armsy/armsy = user
	armsy.contract_next_chain_into_single_tile()

/obj/effect/temp_visual/cleave
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cleave"
	duration = 6

/obj/effect/temp_visual/eldritch_smoke
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "smoke"
	duration = 1 SECONDS

/datum/action/cooldown/spell/aoe/fiery_rebirth
	name = "Nightwatcher's Rebirth"
	desc = "A spell that extinguishes you drains nearby heathens engulfed in flames of their life force, \
		healing you for each victim drained. Those in critical condition \
		will have the last of their vitality drained, killing them."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "smoke"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 1 MINUTES

	invocation = "GL'RY T' TH' N'GHT'W'TCH'ER"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

/datum/action/cooldown/spell/aoe/fiery_rebirth/cast(mob/living/carbon/human/cast_on)
	cast_on.extinguish_mob()
	return ..()

/datum/action/cooldown/spell/aoe/fiery_rebirth/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/mob/living/carbon/nearby_mob in range(aoe_radius, center))
		if(nearby_mob == owner || nearby_mob == center)
			continue
		if(!nearby_mob.mind || !nearby_mob.client)
			continue
		if(IS_HERETIC(nearby_mob) || IS_HERETIC_MONSTER(nearby_mob))
			continue
		if(nearby_mob.stat == DEAD || !nearby_mob.on_fire)
			continue

		things += nearby_mob

	return things

/datum/action/cooldown/spell/aoe/fiery_rebirth/cast_on_thing_in_aoe(mob/living/carbon/victim, mob/living/carbon/human/caster)
	new /obj/effect/temp_visual/eldritch_smoke(victim.drop_location())

	//This is essentially a death mark, use this to finish your opponent quicker.
	if(victim.stat == UNCONSCIOUS && !HAS_TRAIT(victim, TRAIT_NODEATH))
		victim.death()
	victim.apply_damage(20, BURN)

	// Heal the caster for every victim damaged
	caster.adjustBruteLoss(-10, FALSE)
	caster.adjustFireLoss(-10, FALSE)
	caster.adjustToxLoss(-10, FALSE)
	caster.adjustOxyLoss(-10, FALSE)
	caster.adjustStaminaLoss(-10)


/datum/action/cooldown/spell/pointed/manse_link
	name = "Manse Link"
	desc = "This spell allows you to pierce through reality and connect minds to one another \
		via your Mansus Link. All minds connected to your Mansus Link will be able to communicate discreetly across great distances."
	background_icon_state = "bg_heretic"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mansus_link"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 20 SECONDS

	invocation = "PI'RC' TH' M'ND."
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	cast_range = 7

	/// The time it takes to link to a mob.
	var/link_time = 6 SECONDS

/datum/action/cooldown/spell/pointed/manse_link/New(Target)
	. = ..()
	if(!istype(Target, /datum/component/mind_linker))
		stack_trace("[name] ([type]) was instantiated on a non-mind_linker target, this doesn't work.")
		qdel(src)

/datum/action/cooldown/spell/pointed/manse_link/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	return isliving(cast_on)

/datum/action/cooldown/spell/pointed/manse_link/before_cast(mob/living/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	// If we fail to link, cancel the spell.
	if(!do_linking(cast_on))
		return . | SPELL_CANCEL_CAST

/**
* The actual process of linking [linkee] to our network.
*/
/datum/action/cooldown/spell/pointed/manse_link/proc/do_linking(mob/living/linkee)
	var/datum/component/mind_linker/linker = target
	if(linkee.stat == DEAD)
		to_chat(owner, span_warning("They're dead!"))
		return FALSE
	to_chat(owner, span_notice("You begin linking [linkee]'s mind to yours..."))
	to_chat(linkee, span_warning("You feel your mind being pulled somewhere... connected... intertwined with the very fabric of reality..."))
	if(!do_after(owner, link_time, linkee))
		to_chat(owner, span_warning("You fail to link to [linkee]'s mind."))
		to_chat(linkee, span_warning("The foreign presence leaves your mind."))
		return FALSE
	if(QDELETED(src) || QDELETED(owner) || QDELETED(linkee))
		return FALSE
	if(!linker.link_mob(linkee))
		to_chat(owner, span_warning("You can't seem to link to [linkee]'s mind."))
		to_chat(linkee, span_warning("The foreign presence leaves your mind."))
		return FALSE
	return TRUE

// Given to heretic monsters.
/datum/action/cooldown/spell/pointed/blind/eldritch
	name = "Eldritch Blind"
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"

	school = SCHOOL_FORBIDDEN
	invocation = "E'E'S"
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	cast_range = 10

/obj/effect/temp_visual/dir_setting/entropic
	icon = 'icons/effects/160x160.dmi'
	icon_state = "entropic_plume"
	duration = 3 SECONDS

/obj/effect/temp_visual/dir_setting/entropic/setDir(dir)
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_x = -64
		if(SOUTH)
			pixel_x = -64
			pixel_y = -128
		if(EAST)
			pixel_y = -64
		if(WEST)
			pixel_y = -64
			pixel_x = -128

/obj/effect/glowing_rune
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "small_rune_1"
	layer = LOW_SIGIL_LAYER

/obj/effect/glowing_rune/Initialize(mapload)
	. = ..()
	pixel_y = rand(-6,6)
	pixel_x = rand(-6,6)
	icon_state = "small_rune_[rand(12)]"
	update_appearance(UPDATE_ICON)

// Shoots out in a wave-like, what rust heretics themselves get
/datum/action/cooldown/spell/cone/staggered/entropic_plume
	name = "Entropic Plume"
	desc = "Spews forth a disorienting plume that causes enemies to strike each other, briefly blinds them(increasing with range) and poisons them(decreasing with range), while also spreading rust in the path of the plume."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "entropic_plume"
	sound = 'sound/magic/forcewall.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "'NTR'P'C PL'M'"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION
	
	cone_levels = 5
	respect_density = TRUE

/datum/action/cooldown/spell/cone/staggered/entropic_plume/cast(atom/cast_on)
	. = ..()
	new /obj/effect/temp_visual/dir_setting/entropic(get_step(cast_on, cast_on.dir), cast_on.dir)

/datum/action/cooldown/spell/cone/staggered/entropic_plume/do_turf_cone_effect(turf/target_turf, atom/caster, level)
	target_turf.rust_heretic_act()

/datum/action/cooldown/spell/cone/staggered/entropic_plume/do_mob_cone_effect(mob/living/victim, atom/caster, level)
	. = ..()
	if(victim.anti_magic_check() || IS_HERETIC(victim) || IS_HERETIC_MONSTER(victim))
		return
	victim.apply_status_effect(STATUS_EFFECT_AMOK)
	victim.apply_status_effect(STATUS_EFFECT_CLOUDSTRUCK, (level * 1 SECONDS))
	if(iscarbon(victim))
		var/mob/living/carbon/carbon_victim = victim
		carbon_victim.reagents?.add_reagent(/datum/reagent/eldritch, min(1, 6 - level))

/datum/action/cooldown/spell/cone/staggered/entropic_plume/calculate_cone_shape(current_level)
	if(current_level == cone_levels)
		return 5
	else if(current_level == cone_levels - 1)
		return 3
	else
		return 2

// Action for Raw Prophets that boosts up or shrinks down their sight range.
/datum/action/innate/expand_sight
	name = "Expand Sight"
	desc = "Boosts your sight range considerably, allowing you to see enemies from much further away."
	background_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "eye"
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	/// How far we expand the range to.
	var/boost_to = 5
	/// A cooldown for the last time we toggled it, to prevent spam.
	COOLDOWN_DECLARE(last_toggle)

/datum/action/innate/expand_sight/IsAvailable(feedback = FALSE)
	return ..() && COOLDOWN_FINISHED(src, last_toggle)

/datum/action/innate/expand_sight/Activate()
	active = TRUE
	owner.client?.view_size.setTo(boost_to)
	playsound(owner, pick('sound/hallucinations/i_see_you1.ogg', 'sound/hallucinations/i_see_you2.ogg'), 50, TRUE, ignore_walls = FALSE)
	COOLDOWN_START(src, last_toggle, 8 SECONDS)

/datum/action/innate/expand_sight/Deactivate()
	active = FALSE
	owner.client?.view_size.resetToDefault()
	COOLDOWN_START(src, last_toggle, 4 SECONDS)

/datum/action/cooldown/spell/aoe/immobilize/famished_roar
	name = "Famished Roar"
	desc = "An AOE roar spell that immobilizes all nearby people."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/humble/actions_humble.dmi'
	button_icon_state = "void_magnet"
	sound = 'yogstation/sound/magic/demented_outburst_scream.ogg'
	var/obj/effect/sparkle_path = /obj/effect/temp_visual/gravpush
	school = SCHOOL_FORBIDDEN
	invocation = "GR' RO'AR"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION
	aoe_radius = 4

	cooldown_time = 1 MINUTES

/datum/action/cooldown/spell/aoe/immobilize/famished_roar/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/atom/movable/nearby_movable in view(aoe_radius, center))
		if(nearby_movable == owner || nearby_movable == center)
			continue
		if(nearby_movable.anchored)
			continue

		things += nearby_movable

	return things

/datum/action/cooldown/spell/aoe/immobilize/famished_roar/cast_on_thing_in_aoe(atom/movable/victim, atom/caster)
	if(ismob(victim))
		var/mob/victim_mob = victim
		if(victim_mob.can_block_magic(antimagic_flags))
			return

	var/dist_from_caster = get_dist(victim, caster)

	if(dist_from_caster == 0)
		if(isliving(victim))
			var/mob/living/victim_living = victim
			victim_living.Immobilize(6 SECONDS)
			victim_living.adjustBruteLoss(25)
			victim_living.adjustEarDamage(30)
			to_chat(victim, span_userdanger("Your body shakes with fear infront of [caster]!"))
	else
		if(sparkle_path)
			// Created sparkles will disappear on their own
			new sparkle_path(get_turf(victim), get_dir(caster, victim))

		if(isliving(victim))
			var/mob/living/victim_living = victim
			victim_living.Immobilize(3 SECONDS)
			victim_living.adjustBruteLoss(5)
			victim_living.adjustEarDamage(30)
			to_chat(victim, span_userdanger("You're frozen in fear of [caster]!"))

/datum/action/cooldown/spell/pointed/projectile/lightningbolt/eldritchbolt
	name = "Eldritch Bolt"
	desc = "Fire a bolt of Eldritch energy that will strike the target, dealing moderate burn damage."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon_state = "lightning"
	active_overlay_icon_state = "bg_spell_border_active_yellow"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	sound = 'sound/magic/lightningbolt.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "EL'RICH BL'AS'T"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	base_icon_state = "lightning"
	active_msg = "You energize your hands with raw power!"
	deactive_msg = "You let the energy flow out of your hands back into yourself..."
	projectile_type = /obj/item/projectile/magic/aoe/lightning/eldritch
	
	bolt_range = 7
	bolt_power = 1000

/datum/action/cooldown/spell/pointed/phase_jump/obfuscation
	name = "Mental Obfuscation"
	desc = "A short range targeted teleport."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mansus_link"
	ranged_mousepointer = 'icons/effects/mouse_pointers/phase_jump.dmi'

	school = SCHOOL_FORBIDDEN

	cooldown_time = 25 SECONDS
	cast_range = 7
	invocation = "PH'ASE"
	invocation_type = INVOCATION_WHISPER
	active_msg = span_notice("You prepare to warp everyone's vision.")
	deactive_msg = span_notice("You relax your mind.")
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

/datum/action/cooldown/spell/pointed/projectile/assault
	name = "Amygdala Assault"
	desc = "Blast a single ray of concentrated mental energy at a target, dealing high brute damage if they are caught in it"
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/obj/hand_of_god_structures.dmi'
	button_icon_state = "ward-red"

	sound = 'sound/weapons/resonator_blast.ogg'
	cast_range = 7
	cooldown_time = 25 SECONDS
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	invocation = "D'O'DGE TH'IS!"
	invocation_type = INVOCATION_SHOUT

	projectile_type = /obj/item/projectile/heretic_assault

/datum/action/cooldown/spell/pointed/void_phase
	name = "Void Phase"
	desc = "Let's you blink to your pointed destination, causes 3x3 aoe damage bubble \
		around your pointed destination and your current location. \
		It has a minimum range of 3 tiles and a maximum range of 9 tiles."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "voidblink"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "RE'L'TY PH'S'E."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	cast_range = 5
	/// The minimum range to cast the phase.
	var/min_cast_range = 3
	/// The radius of damage around the void bubble
	var/damage_radius = 1

/datum/action/cooldown/spell/pointed/void_phase/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	if(owner && get_dist(get_turf(owner), get_turf(cast_on)) < min_cast_range)
		cast_on.balloon_alert(owner, "too close!")
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/void_phase/cast(atom/cast_on)
	. = ..()
	var/turf/source_turf = get_turf(owner)
	var/turf/targeted_turf = get_turf(cast_on)

	cause_aoe(source_turf, /obj/effect/temp_visual/voidin)
	cause_aoe(targeted_turf, /obj/effect/temp_visual/voidout)

	do_teleport(
		owner,
		targeted_turf,
		precision = 1,
		no_effects = TRUE,
		channel = TELEPORT_CHANNEL_MAGIC,
	)

/// Does the AOE effect of the blink at the passed turf
/datum/action/cooldown/spell/pointed/void_phase/proc/cause_aoe(turf/target_turf, effect_type = /obj/effect/temp_visual/voidin)
	new effect_type(target_turf)
	playsound(target_turf, 'sound/magic/voidblink.ogg', 60, FALSE)
	for(var/mob/living/living_mob in range(damage_radius, target_turf))
		if(IS_HERETIC_OR_MONSTER(living_mob) || living_mob == owner)
			continue
		if(living_mob.can_block_magic(antimagic_flags))
			continue
		living_mob.apply_damage(40, BRUTE, wound_bonus = CANT_WOUND)

/obj/effect/temp_visual/voidin
	icon = 'icons/effects/96x96.dmi'
	icon_state = "void_blink_in"
	alpha = 150
	duration = 6
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/voidout
	icon = 'icons/effects/96x96.dmi'
	icon_state = "void_blink_out"
	alpha = 150
	duration = 6
	pixel_x = -32
	pixel_y = -32

/datum/action/cooldown/spell/cone/staggered/cone_of_cold/void
	name = "Void Blast"
	desc = "Fires a cone of chilling void in front of you, freezing everything in its path. \
		Enemies in the cone of the blast will be damaged slightly, slowed, and chilled overtime. \
		The ground hit will be iced over and slippery - \
		though they may thaw shortly if used in room temperature."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon_state = "icebeam"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "FR'ZE!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	// In room temperature, the ice won't last very long
	// ...but in space / freezing rooms, it will stick around
	turf_freeze_type = TURF_WET_PERMAFROST
	unfreeze_turf_duration = 15 SECONDS
	// Applies an "infinite" version of basic void chill
	// (This stacks with mansus grasp's void chill)
	frozen_status_effect_path = /datum/status_effect/void_chill/lasting
	unfreeze_mob_duration = 15 SECONDS
	// Does a smidge of damage
	on_freeze_brute_damage = 12
	on_freeze_burn_damage = 10
	// Also freezes stuff (Which will likely be unfrozen similarly to turfs)
	unfreeze_object_duration = 15 SECONDS

/datum/action/cooldown/spell/cone/staggered/cone_of_cold/void/do_mob_cone_effect(mob/living/target_mob, atom/caster, level)
	if(IS_HERETIC_OR_MONSTER(target_mob))
		return

	return ..()

/datum/action/cooldown/spell/aoe/slip/void
	name = "Diamond Dust"
	desc = "Causes the floor within 2 tiles to become frozen."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/humble/actions_humble.dmi'
	button_icon_state = "blind"

	invocation = "OBL'VION!"
	invocation_type = INVOCATION_SHOUT

	cooldown_time = 50 SECONDS
	aoe_radius = 2
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

/datum/action/cooldown/spell/aoe/slip/void/cast_on_thing_in_aoe(turf/open/target)
	target.MakeSlippery(TURF_WET_PERMAFROST, 15 SECONDS, 15 SECONDS)

/datum/action/cooldown/spell/aoe/void_pull
	name = "Void Pull"
	desc = "Calls the void, damaging, knocking down, and stunning people nearby. \
		Distant foes are also pulled closer to you (but not damaged)."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "voidpull"
	sound = 'sound/magic/voidblink.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 40 SECONDS

	invocation = "BR'NG F'RTH TH'M T' M'."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	aoe_radius = 7
	/// The radius of the actual damage circle done before cast
	var/damage_radius = 1
	/// The radius of the stun applied to nearby people on cast
	var/stun_radius = 4

// Before the cast, we do some small AOE damage around the caster
/datum/action/cooldown/spell/aoe/void_pull/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	new /obj/effect/temp_visual/voidin(get_turf(cast_on))

	// Before we cast the actual effects, deal AOE damage to anyone adjacent to us
	for(var/mob/living/nearby_living as anything in get_things_to_cast_on(cast_on, damage_radius))
		nearby_living.apply_damage(30, BRUTE, wound_bonus = CANT_WOUND)

/datum/action/cooldown/spell/aoe/void_pull/get_things_to_cast_on(atom/center, radius_override = 1)
	var/list/things = list()
	for(var/mob/living/nearby_mob in view(radius_override || aoe_radius, center))
		if(nearby_mob == owner || nearby_mob == center)
			continue
		// Don't grab people who are tucked away or something
		if(!isturf(nearby_mob.loc))
			continue
		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue
		if(nearby_mob.can_block_magic(antimagic_flags))
			continue

		things += nearby_mob

	return things

// For the actual cast, we microstun people nearby and pull them in
/datum/action/cooldown/spell/aoe/void_pull/cast_on_thing_in_aoe(mob/living/victim, atom/caster)
	// If the victim's within the stun radius, they're stunned / knocked down
	if(get_dist(victim, caster) < stun_radius)
		victim.AdjustKnockdown(3 SECONDS)
		victim.AdjustParalyzed(0.5 SECONDS)

	// Otherwise, they take a few steps closer
	for(var/i in 1 to 3)
		victim.forceMove(get_step_towards(victim, caster))
