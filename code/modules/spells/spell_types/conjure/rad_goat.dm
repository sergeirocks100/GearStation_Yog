/datum/action/cooldown/spell/conjure/radiation_anomaly
	name = "Spawn Radiation Anomaly"
	desc = "Spawn a radiation anomaly, summon your brothers!"
	button_icon = 'icons/obj/projectiles.dmi'
	button_icon_state = "radiation_anomaly"
	sound = 'sound/weapons/resonator_fire.ogg'

	school = SCHOOL_CONJURATION
	cooldown_time = 10 SECONDS

	invocation_type = INVOCATION_SHOUT
	invocation = "UNGA"
	spell_requirements = NONE

	summon_type = list(/obj/effect/anomaly/radiation)
	summon_radius = 0

/datum/action/cooldown/spell/conjure/radiation_anomaly/post_summon(atom/summoned_object, atom/cast_on)
	if(!istype(summoned_object, /obj/effect/anomaly/radiation))
		return
	var/obj/effect/anomaly/radiation/anomaly = summoned_object
	anomaly.spawn_goat = TRUE
	owner.visible_message(span_notice("You see the radiation anomaly emerges from the [owner]."), span_notice("The radiation anomaly emerges from your body."))
	notify_ghosts("The Radioactive Goat has spawned a radiation anomaly!", source = anomaly, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Radiation Anomaly Spawned!")
