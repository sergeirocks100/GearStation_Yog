/obj/effect/proc_holder/changeling/fleshmend
	name = "Fleshmend"
	desc = "Our flesh rapidly regenerates, healing our wounds. Effectiveness decreases with quick, repeated use."
	helptext = "Heals a moderate amount of damage over a short period of time. Can be used while unconscious, and will alert nearby crew."
	chemical_cost = 25
	dna_cost = 2
	req_stat = UNCONSCIOUS
	var/recent_uses = 1 //The factor of which the healing should be divided by
	var/healing_ticks = 10
	 // The ideal total healing amount, divided by healing_ticks to get heal/tick
	var/total_healing = 100

/obj/effect/proc_holder/changeling/fleshmend/New()
	..()
	SSobj.processing.Add(src)

/obj/effect/proc_holder/changeling/fleshmend/Destroy()
	SSobj.processing.Remove(src)
	..()

/obj/effect/proc_holder/changeling/fleshmend/process()
	if(recent_uses > 1)
		recent_uses -= (1 / healing_ticks)
		recent_uses = max(recent_uses, 1)

//Starts healing you every second for 10 seconds. Can be used whilst unconscious.
/obj/effect/proc_holder/changeling/fleshmend/sting_action(mob/living/user)
	user << "<span class='notice'>We begin to heal rapidly.</span>"
	if(recent_uses > 1)
		user << "<span class='warning'>Our healing's effectiveness is reduced by quickly repeated use!</span>"
	spawn(0)
		recent_uses++
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.restore_blood()
			H.remove_all_embedded_objects()
		// The healing itself - doesn't heal toxin damage (that's anatomic panacea) and
		// effectiveness decreases with each use in a short timespan
		for(var/i = 0, i < healing_ticks, i++)
			if(user)
				var/healpertick = -(total_healing / healing_ticks)
				user.adjustBruteLoss(healpertick / recent_uses, 0)
				user.adjustOxyLoss(healpertick / recent_uses, 0)
				user.adjustFireLoss(healpertick / recent_uses, 0)
				user.updatehealth()
			sleep(10)

	feedback_add_details("changeling_powers","RR")
	return 1
