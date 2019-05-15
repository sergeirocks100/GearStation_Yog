/datum/component/random_crits
	var/crit_damage = 0
	var/crit_force = 0
	var/crit_rate = 5
	var/crit_rate_max = 70
	var/crit_rate_increase = 10 //% crit chance per hit
	var/crit_dropoff_coeff = 0.6 //% of crit chance remaining after dropoff

/datum/component/random_crits/Initialize(force)
	crit_force = force
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/on_attack)
	crit_damage = crit_force * 2 //random crits deal 3x damage
	START_PROCESSING(SSobj,src)

/datum/component/random_crits/proc/on_attack(datum/source, mob/living/target, mob/user)
	if(prob(crit_rate))
		target.apply_damage(crit_damage, BRUTE, user.zone_selected, 0)
		user.visible_message("<span class='danger'>[user]'s [parent] scores a random crit!!</span>")
	if(!target.stat && target.ckey)
		crit_rate += crit_rate_increase
		if(crit_rate > crit_rate_max)
			crit_rate = crit_rate_max

/datum/component/random_crits/process()
	crit_rate = crit_rate * crit_dropoff_coeff
	if(crit_rate < initial(crit_rate))
		crit_rate = initial(crit_rate)
