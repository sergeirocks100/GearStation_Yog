/*
	Menu system that handles most upgrades for infection gamemode
*/

/datum/infection_menu
	// Name that displays on the evolution shop
	var/name = "Evolution Menu"
	// The actual thing that we are trying to upgrade
	var/atom/upgrading
	// stores the ui we have open
	var/datum/tgui/ui

/datum/infection_menu/New(upgrading)
	src.upgrading = upgrading
	if(istype(upgrading, /obj/structure/infection))
		return ..()
	if(istype(upgrading, /mob/living/simple_animal/hostile/infection/infectionspore/sentient))
		return ..()
	if(istype(upgrading, /mob/camera/commander))
		return ..()
	return INITIALIZE_HINT_QDEL

/*
	Gets the evolution list for the different types of things that can upgrade
*/
/datum/infection_menu/proc/get_evolution_list()
	if(istype(upgrading, /obj/structure/infection))
		var/obj/structure/infection/I = upgrading
		return I.upgrades
	if(istype(upgrading, /mob/living/simple_animal/hostile/infection/infectionspore/sentient))
		var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/S = upgrading
		return S.upgrades
	if(istype(upgrading, /mob/camera/commander))
		var/mob/camera/commander/C = upgrading
		return C.unlockable_actions
	return

/*
	Gets the points left that can be used to upgrade
*/
/datum/infection_menu/proc/get_points_left()
	if(istype(upgrading, /obj/structure/infection))
		var/obj/structure/infection/I = upgrading
		return I.overmind.infection_points
	if(istype(upgrading, /mob/living/simple_animal/hostile/infection/infectionspore/sentient))
		var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/S = upgrading
		return S.upgrade_points
	if(istype(upgrading, /mob/camera/commander))
		var/mob/camera/commander/C = upgrading
		return C.upgrade_points
	return 0

/*
	Tries to purchase the upgrade with the points the user has
*/
/datum/infection_menu/proc/try_purchase(point_cost)
	if(istype(upgrading, /obj/structure/infection))
		var/obj/structure/infection/I = upgrading
		return I.overmind.can_buy(point_cost)
	if(istype(upgrading, /mob/living/simple_animal/hostile/infection/infectionspore/sentient))
		var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/S = upgrading
		return S.can_upgrade(point_cost)
	if(istype(upgrading, /mob/camera/commander))
		var/mob/camera/commander/C = upgrading
		return C.can_upgrade(point_cost)
	return FALSE

/datum/infection_menu/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "infection_menu", name, 900, 480, master_ui, state)
		ui.open()
	src.ui = ui

/datum/infection_menu/ui_data(mob/user)
	var/list/data = list()

	var/points_remaining = get_points_left()
	data["evolution_points"] = points_remaining

	var/list/upgrades = list()

	for(var/datum/infection_upgrade/evolution in get_evolution_list())
		var/point_cost = evolution.cost
		if(point_cost <= 0)
			continue

		var/list/AL = list()
		AL["name"] = evolution.name
		AL["desc"] = evolution.description
		AL["owned"] = evolution.times <= 0
		AL["times"] = evolution.times
		AL["upgrade_cost"] = point_cost
		AL["can_purchase"] = (points_remaining >= point_cost && !QDELETED(upgrading))

		upgrades += list(AL)

	data["upgrades"] = upgrades

	return data

/datum/infection_menu/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("evolve")
			var/evolution_name = params["name"]
			for(var/datum/infection_upgrade/evolution in get_evolution_list())
				if(evolution.name == evolution_name && evolution.times)
					if(try_purchase(evolution.cost))
						evolution.do_upgrade(upgrading)