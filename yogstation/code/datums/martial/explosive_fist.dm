#define EXPLOSIVE_DISARM_COMBO "DD"

#define DETONATE_COMBO "HHDH"
#define PRE_DETONATE_COMBO "HH" 
#define ALMOST_DETONATE_COMBO "HHD" 

#define LIFEFORCE_TRADE_COMBO "DGDG" 
#define PRE_LIFEFORCE_TRADE_COMBO "DG" 
#define ALMOST_LIFEFORCE_TRADE_COMBO "DGD" 

#define IMMOLATE_COMBO "DHDG" 
#define PRE_IMMOLATE_COMBO "DH" 
#define ALMOST_IMMOLATE_COMBO "DHD" 


/datum/martial_art/explosive_fist
	name = "Explosive Fist"
	id =  MARTIALART_EXPLOSIVEFIST
	help_verb = /mob/living/carbon/human/proc/explosive_fist_help

/datum/martial_art/explosive_fist/can_use(mob/living/carbon/human/H)
	return isplasmaman(H)

/datum/martial_art/explosive_fist/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(A.a_intent == INTENT_GRAB && A!=D && (can_use(A))) // A!=D prevents grabbing yourself
		add_to_streak("G",D)
		if(check_streak(A,D)) //if a combo is made no grab upgrade is done
			return TRUE
		return FALSE
	else
		return FALSE

/datum/martial_art/explosive_fist/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	var/selected_zone = A.zone_selected
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/brute_block = D.run_armor_check(affecting, MELEE, 0)
	var/burn_block = D.run_armor_check(affecting, BOMB, 0)
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	playsound(get_turf(D), 'sound/effects/explosion1.ogg', 50, TRUE, -1)
	D.apply_damage(10, BRUTE, selected_zone, brute_block) 
	D.apply_damage(10, BURN, selected_zone, burn_block) 
	D.visible_message(span_danger("[A] [A.dna.species.attack_verb]s [D]!"), \
					  span_userdanger("[A] [A.dna.species.attack_verb]s you!"))
	log_combat(A, D, "[A.dna.species.attack_verb]s(Explosive Fist)")


/datum/martial_art/explosive_fist/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!(can_use(A)))
		return FALSE
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE  

/datum/martial_art/explosive_fist/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	if(findtext(streak, EXPLOSIVE_DISARM_COMBO))
		explosive_disarm(A,D)
		return TRUE
	if(findtext(streak, PRE_DETONATE_COMBO))
		detonate(A,D)
		return TRUE
	if(findtext(streak, PRE_LIFEFORCE_TRADE_COMBO))
		lifeforce_trade(A,D)
	if(findtext(streak,PRE_IMMOLATE_COMBO))
		return immolate(A,D)

/datum/martial_art/explosive_fist/proc/explosive_disarm(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/selected_zone = A.zone_selected
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, BOMB, 0)
	D.apply_damage(18, BURN, selected_zone, armor_block)
 
	var/obj/item/bodypart/affecting_p = A.get_bodypart(BODY_ZONE_CHEST) // p - plasmamen
	var/armor_block_p = A.run_armor_check(affecting_p, BOMB)
	A.apply_damage(10, BURN, BODY_ZONE_CHEST, armor_block_p) 

	D.Knockdown(3 SECONDS)
	playsound(D, 'sound/effects/explosion1.ogg', 50, TRUE, -1)
	A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
	log_combat(A, D, "blasts(Explosive Fist)")
	D.visible_message(span_danger("[A] blasts [D]!"), \
				span_userdanger("[A] blasts you!"))
	var/atom/throw_target = get_edge_target_turf(D, get_dir(A,D))
	D.throw_at(throw_target, rand(1,2), 7, A)
	streak = ""

/datum/martial_art/explosive_fist/proc/detonate(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak, DETONATE_COMBO))
		A.do_attack_animation(D, ATTACK_EFFECT_SMASH)
		log_combat(A, D, "detonates(Explosive Fist)")
		D.visible_message(span_danger("[A] detonates [D]!"), \
					span_userdanger("[A] detonates you!"))
		explosion(get_turf(D), -1, 0, 2, 0, 0, 2)
		D.IgniteMob()
		playsound(D, 'sound/effects/explosion1.ogg', 50, TRUE, -1)
		
		var/obj/item/bodypart/affecting = A.get_bodypart(BODY_ZONE_CHEST)
		var/armor_block = A.run_armor_check(affecting, BOMB)
		A.apply_damage(15, BRUTE, BODY_ZONE_CHEST, armor_block) 
		streak = ""

	else if(findtext(streak, ALMOST_DETONATE_COMBO))
		var/selected_zone = A.zone_selected
		var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
		var/armor_block = D.run_armor_check(affecting, MELEE, 0)
		A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
		playsound(D, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
		var/current_stamina_damage = D.getStaminaLoss()
		var/damage_to_deal = 55

		if(current_stamina_damage > 50)   ///We apply a stamina slowdown on our target, our do nothing!
			damage_to_deal = 0
		D.apply_damage(damage_to_deal, STAMINA, selected_zone, armor_block) 
		D.visible_message(span_danger("[A] activates [D]!"), \
						span_userdanger("[A] activates you!")) 
		log_combat(A, D, "activates(Explosive Fist)")
		D.adjust_fire_stacks(4)

	else 
		var/selected_zone = A.zone_selected
		var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
		var/brute_block = D.run_armor_check(affecting, MELEE, 0)
		var/burn_block = D.run_armor_check(affecting, BOMB, 0)
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		playsound(D, 'sound/effects/explosion1.ogg', 50, TRUE, -1)
		D.apply_damage(12, BRUTE, selected_zone, brute_block) 
		D.apply_damage(12, BURN, selected_zone, burn_block) 
		D.adjust_fire_stacks(2)
		D.visible_message(span_danger("[A] primes [D]!"), \
						span_userdanger("[A] primes you!"))		
		log_combat(A, D, "primes(Explosive Fist)")

/datum/martial_art/explosive_fist/proc/lifeforce_trade(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak, LIFEFORCE_TRADE_COMBO))
		if(A.get_item_by_slot(ITEM_SLOT_HEAD))
			A.do_attack_animation(D, ATTACK_EFFECT_SMASH)			
			playsound(get_turf(D), 'sound/weapons/cqchit2.ogg', 50, 1, -1)

			var/selected_zone = A.zone_selected
			var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
			var/brute_block = D.run_armor_check(affecting, MELEE, 0)
			var/burn_block = D.run_armor_check(affecting, BOMB, 0)
			D.apply_damage(25, BRUTE, selected_zone, brute_block) 
			D.apply_damage(25, BURN, selected_zone, burn_block) 

			var/obj/item/bodypart/affecting_p = A.get_bodypart(BODY_ZONE_CHEST)
			var/brute_block_p = A.run_armor_check(affecting_p, MELEE)
			var/burn_block_p = A.run_armor_check(affecting_p, BOMB)
			A.apply_damage(5, BRUTE, BODY_ZONE_CHEST, brute_block_p) 
			A.apply_damage(5, BURN, BODY_ZONE_CHEST, burn_block_p) 

			D.visible_message(span_danger("[A] headbutts [D]!"), \
							span_userdanger("[A] headbutts you!"))		
			log_combat(A, D, "headbutts(Explosive Fist)")
			streak = ""
		else
			if(A.grab_state < GRAB_NECK)
				A.grab_state = GRAB_NECK
			if(!(A.pulling == D))
				D.grabbedby(A, 1)
			D.visible_message(span_danger("[A] violently grabs [D]'s neck!"), \
							span_userdanger("[A] violently grabs your neck!"))		
			log_combat(A, D, "grabs by the neck(Explosive Fist)")
			playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, TRUE, -1)
			streak = ""
			A.adjust_fire_stacks(3)
			D.adjust_fire_stacks(3)
			A.IgniteMob()
			D.IgniteMob()
			proceed_lifeforce_trade(A, D)

	else if(findtext(streak, ALMOST_LIFEFORCE_TRADE_COMBO))
		A.do_attack_animation(D, ATTACK_EFFECT_DISARM)			
		playsound(get_turf(D), 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

		D.visible_message(span_danger("[A] staggers [D]!"), \
						span_userdanger("[A] staggers you!"))		
		log_combat(A, D, "staggers(Explosive Fist)")

		var/selected_zone = A.zone_selected
		var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(selected_zone))
		var/stamina_block = D.run_armor_check(affecting, MELEE, 0)
		var/burn_block = D.run_armor_check(affecting, BOMB, 0)
		D.apply_damage(20, STAMINA, selected_zone, stamina_block) 
		D.apply_damage(5, BURN, selected_zone, burn_block) 

		if(!D.has_movespeed_modifier(MOVESPEED_ID_SHOVE)) /// We apply a more long shove slowdown if our target doesn't already have one
			D.add_movespeed_modifier(MOVESPEED_ID_SHOVE, multiplicative_slowdown = SHOVE_SLOWDOWN_STRENGTH)
			addtimer(CALLBACK(D, /mob/living/carbon/human/proc/clear_shove_slowdown), 4 SECONDS)

		ADD_TRAIT(D, TRAIT_POOR_AIM, "martial")
		addtimer(CALLBACK(src, .proc/remove_stagger, D), 2 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
	else
		A.do_attack_animation(D, ATTACK_EFFECT_DISARM)

		var/selected_zone = A.zone_selected
		var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
		var/armor_block = D.run_armor_check(affecting, BOMB, 0)
		D.apply_damage(20, BURN, selected_zone, armor_block)
	
		var/obj/item/bodypart/affecting_p = A.get_bodypart(BODY_ZONE_CHEST)
		var/armor_block_p = A.run_armor_check(affecting_p, BOMB)
		A.apply_damage(5, BURN, BODY_ZONE_CHEST, armor_block_p) 

		D.visible_message(span_danger("[A] burns [D]!"), \
						span_userdanger("[A] burns you!"))		
		log_combat(A, D, "burns(Explosive Fist)")

/datum/martial_art/explosive_fist/proc/immolate(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak,IMMOLATE_COMBO))
		if(A.get_item_by_slot(ITEM_SLOT_HEAD))   //No helmets???
			streak = ""
			return FALSE
		else 
			for(var/mob/living/target in view_or_range(2, A, "range"))
				if(target == A)  
					continue
				if(get_dist(get_turf(A), get_turf(target)) <= 1)
					target.IgniteMob()  ///If we are close, we ignite, if not - take 30 burn damage
				else 
					target.adjustFireLoss(30)

			var/obj/item/bodypart/hed = D.get_bodypart(BODY_ZONE_HEAD)
			var/armor_block = D.run_armor_check(hed, BOMB)
			D.apply_damage(10, BURN, BODY_ZONE_HEAD, armor_block) 	
			D.emote("scream")		
			D.blur_eyes(4)

			var/obj/item/bodypart/affecting_p = A.get_bodypart(BODY_ZONE_CHEST)
			var/armor_block_p = A.run_armor_check(affecting_p, BOMB)
			A.apply_damage(15, BURN, BODY_ZONE_CHEST, armor_block_p) 

			A.visible_message(span_danger("[A] explodes violently!"), \
						span_userdanger("You unleash the flames from yourself!"))
			log_combat(A, D, "immolates(Explosive Fist)")	
			playsound(get_turf(A), 'sound/effects/explosion1.ogg', 50, TRUE, -1)			
	
	else if(findtext(streak,ALMOST_IMMOLATE_COMBO))
		for(var/mob/living/target in view_or_range(2, A, "range"))
			target.adjust_fire_stacks(5)
			var/selected_zone = A.zone_selected
			var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(A.zone_selected))
			var/burn_block = target.run_armor_check(affecting, BOMB, 0)
			var/brute_block = target.run_armor_check(affecting, MELEE, 0)
			target.apply_damage(10, BURN, selected_zone, burn_block)
			target.apply_damage(5, BRUTE, selected_zone, brute_block)
		D.visible_message(span_danger("[A] primes [D]!"), \
					span_userdanger("[A] primes you!"))
		log_combat(A, D, "primes(Explosive Fist)")	
		playsound(get_turf(D), 'sound/effects/explosion1.ogg', 50, TRUE, -1)


	else
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)

		var/selected_zone = A.zone_selected
		var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
		var/armor_block = D.run_armor_check(affecting, BOMB, 0)
		D.apply_damage(25, BURN, selected_zone, armor_block)
	
		var/obj/item/bodypart/affecting_p = A.get_bodypart(BODY_ZONE_CHEST) // p - plasmamen
		var/armor_block_p = A.run_armor_check(affecting_p, BOMB)
		A.apply_damage(5, BURN, BODY_ZONE_CHEST, armor_block_p) 

		D.visible_message(span_danger("[A] burns [D]!"), \
						span_userdanger("[A] burns you!"))		
		log_combat(A, D, "burns(Explosive Fist)")

	return TRUE

/datum/martial_art/explosive_fist/proc/proceed_lifeforce_trade(mob/living/carbon/human/A, mob/living/carbon/human/D)	
	if(!can_suck_life(A, D))
		return
	if(!do_mob(A, D, 1 SECONDS))
		return
	if(!can_suck_life(A, D))
		return
	if(prob(35))
		var/message = pick("You feel your life force being drained!", "It hurts!", "You stare into [A]'s expressionless skull and see only fire and death.")
		to_chat(D, span_userdanger(message))
	if(prob(25))
		D.emote("scream")
	var/dam = 2
	D.adjustFireLoss(dam)
	var/bruteloss = D.getBruteLoss()
	var/fireloss = D.getFireLoss()
	A.heal_overall_damage(bruteloss/2, fireloss/2, 0, CONSCIOUS, TRUE)
	to_chat(A, span_notice("You drain lifeforce from [D]"))
	proceed_lifeforce_trade(A, D)
	
/datum/martial_art/explosive_fist/proc/can_suck_life(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	if(A.get_item_by_slot(ITEM_SLOT_HEAD))
		return FALSE
	if(!A.pulling)
		return FALSE
	if(!(A.pulling == D))
		return FALSE
	if(A.grab_state < GRAB_NECK)
		return FALSE
	if(A.stat == DEAD || A.stat == UNCONSCIOUS)
		return FALSE
	if(D.stat == DEAD || D.stat == UNCONSCIOUS)
		return FALSE
	return TRUE

/datum/martial_art/explosive_fist/proc/remove_stagger(mob/living/carbon/human/D)
	REMOVE_TRAIT(D, TRAIT_POOR_AIM, "martial")

/mob/living/carbon/human/proc/explosive_fist_help()
	set name = "Remember the basics"
	set desc = "You try to remember some basic actions from the explosive fist art."
	set category = "Explosive Fist"
	to_chat(usr, "<b><i>You try to remember some basic actions from the explosive fist art.</i></b>")

	to_chat(usr, span_notice("<b>Harm Intent</b> Will deal 10 burn and 10 brute damage to people who you hit."))

	to_chat(usr, "[span_notice("Explosive disarm")]: Disarm Disarm. Finishing this combo will deal 10 damage to you and 18 to your target, aswell as throwing your target away and knocking down for three seconds.")
	to_chat(usr, "[span_notice("Detonate")]: Harm Harm Disarm Harm. Second strike will deal 12/12 brute/burn and apply 2 fire stacks to the target. Third strike will apply 4 fire stacks and deal some stamina damage if the target has less then 50 stamina damage. The final strike will ignite the target, make a light explosion and deal 15 damage to you.")
	to_chat(usr, "[span_notice("Life force trade")]: Disarm Grab Disarm Grab. Second strike will deal 20 damage to the target and 5 damage to you. Third strike will deall 20 stamina and 5 burn damage to the target, and will make it unable to use ranged weapons for 2 second as well as a more long shove slowdown. Finishing the combo with a headwear on will just deal 25/25 brute/burn damage to the target, and if you don't wear a helmet, you will instantly grab the target by a neck, aswell as start to drain life from them.")
	to_chat(usr, "[span_notice("Immolate")]: Disarm Disarm. Second strike will deal 25 burn damage to the target and 5 burn damage to you. Third strike will apply 5 fire stacks to EVERYONE in the range of 2 tiles. Finishing the combo will, if you don't wear any headwear, will deal 30 burn damage to anyone except you in the range of 2 tiles, or ignite them if they are close enough to you. You target will get additional 10 burn damage and get blurry vision.")