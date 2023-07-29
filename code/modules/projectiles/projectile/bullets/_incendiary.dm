/obj/item/projectile/bullet/incendiary
	damage = 20
	var/fire_stacks = 4

/obj/item/projectile/bullet/incendiary/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(fire_stacks)
		M.ignite_mob()
	var/turf/open/target_turf = get_turf(target)
	if(istype(target_turf))
		target_turf.IgniteTurf(rand(8, 22))

/obj/item/projectile/bullet/incendiary/Move()
	. = ..()
	var/turf/location = get_turf(src)
	if(location)
		new /obj/effect/hotspot(location)
		location.hotspot_expose(700, 50, 1)
