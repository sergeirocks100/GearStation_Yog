/datum/disease/transformation/melting
	name = "Melting Disease"
	cure_text = "An injection of frost oil."
	cures = list(/datum/reagent/consumable/frostoil)
	cure_chance = 5
	spread_flags = DISEASE_SPREAD_AIRBORNE
	agent = "M.L. Microorganisms"
	desc = "This disease breaks down and converts the body to slime, giving the sensation of \"burning\"."
	severity = DISEASE_SEVERITY_BIOHAZARD
	visibility_flags = 0
	stage1	= list()
	stage2	= list("You feel hot.", "You feel weak.")
	stage3	= list("<span class='danger'>Something is burning inside of you!</span>", "Your skin feels off.")
	stage4	= list("<span class='danger'>You're burning apart in your own skin!</span>", "<span class='danger'>You feel yourself breaking down...</span>", "<span class='danger'>Your skin is dripping.</span>")
	stage5	= list("<span class='userdanger'>IT BURNS!</span>")
	new_form = /mob/living/simple_animal/hostile/melted
	infectable_biotypes = list(MOB_ORGANIC)
	process_dead = TRUE
	var/mob/living/simple_animal/hostile/melting/creator
	//bantype = "Melting" antag ban! duh!

/datum/disease/transformation/melting/Initialize(mapload, mob_source)
	. = ..()
	creator = mob_source
	var/list/new_agent_name = list()
	for(var/word in splittext(name," "))
		new_agent_name += "[copytext(word, 1, 2)]."
	new_agent_name += " Microorganisms"
	agent = jointext(new_agent_name, "")

/datum/disease/transformation/melting/stage_act()
	var/obj/item/organ/heart/slime/slimeheart = affected_mob.getorganslot(ORGAN_SLOT_HEART)
	if(istype(slimeheart))
		return //champions are not affected by the disease
	..()
	switch(stage)
		if(2)
			if(prob(4))
				to_chat(affected_mob, "<span class='danger'>You feel a burning pain in your chest.</span>")
				affected_mob.adjustToxLoss(2)
		if(3)
			if(affected_mob.stat == DEAD)
				do_disease_transformation(affected_mob)
			if(prob(6))
				to_chat(affected_mob, "<span class='danger'>You feel a burning pain in your chest.</span>")
				affected_mob.adjustToxLoss(2)
			if(prob(4))
				return
				//goo vomit
				affected_mob.adjustCloneLoss(5)
		if(4)
			if(affected_mob.stat == UNCONSCIOUS)
				do_disease_transformation(affected_mob)
			affected_mob.slurring += 2
			if(prob(10))
				//goo vomit
				affected_mob.adjustCloneLoss(5)
		if(5)
			do_disease_transformation(affected_mob)

/datum/disease/transformation/melting/do_disease_transformation(mob/living/affected_mob)
	var/mob/living/simple_animal/hostile/melted/new_slime = ..()
	if(!new_slime)
		return
	new_slime.creator = creator