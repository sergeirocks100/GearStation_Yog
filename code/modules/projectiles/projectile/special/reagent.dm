/obj/projectile/reagent
	name = "\proper reagents"
	icon = 'icons/obj/chempuff.dmi'
	icon_state = ""
	damage_type = TOX
	damage = 0
	armor_flag = BIO
	nodamage = TRUE
	speed = 1.2 // slow projectile
	/// Reagent application methods
	var/transfer_methods = TOUCH
	var/list/reagents_list = list()

/obj/projectile/reagent/Initialize(mapload)
	. = ..()
	create_reagents(1000)

/obj/projectile/reagent/proc/update_reagents()
	if(!reagents.total_volume) // if it didn't already have reagents in it, fill it with the default reagents
		for(var/type in reagents_list)
			reagents.add_reagent(type, reagents_list[type])
	add_atom_colour(mix_color_from_reagents(reagents.reagent_list), FIXED_COLOUR_PRIORITY)

/obj/projectile/reagent/fire(angle, atom/direct_target)
	update_reagents()
	return ..()

/obj/projectile/reagent/on_hit(atom/target, blocked = FALSE)
	var/hit = ..()
	if(blocked < 100 && (hit & BULLET_ACT_HIT))
		log_combat(firer, target, "shot", src, addition = "with a projectile containing [reagents.log_list()]")
		reagents.reaction(target, transfer_methods)
	reagents.reaction(get_turf(target), transfer_methods)
	return hit


/// Water - for water guns! Just some harmless fun... right??
/obj/projectile/reagent/water
	name = "\proper water"
	reagents_list = list(/datum/reagent/water = 10)

/obj/projectile/reagent/water/update_reagents()
	. = ..()
	var/last_volume = 0
	for(var/datum/reagent/R as anything in reagents.reagent_list)
		if(R.volume > last_volume)
			last_volume = R.volume
			name = "\proper [lowertext(R.name)]"

/// Xeno neurotoxin
/obj/projectile/reagent/neurotoxin
	name = "neurotoxin spit"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "neurotoxin"
	reagents_list = list(/datum/reagent/toxin/staminatoxin/neurotoxin_alien = 10)
