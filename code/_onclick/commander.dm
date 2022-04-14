// Infection Commander Controls


/mob/camera/commander/ClickOn(var/atom/A, var/params) //Expand infection
	var/list/modifiers = params2list(params)
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"])
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return
	var/turf/T = get_turf(A)
	var/obj/structure/infection/I = locate(/obj/structure/infection) in T.contents
	if(I)
		I.evolve_menu(src)

/mob/camera/commander/MiddleClickOn(atom/A) //Rally spores
	var/turf/T = get_turf(A)
	if(T)
		rally_spores(T)

/mob/camera/commander/CtrlClickOn(atom/A)
	var/datum/action/cooldown/infection/creator/shield/S = locate(/datum/action/cooldown/infection/creator/shield) in actions
	var/turf/T = get_turf(A)
	if(T)
		S.fire(src, T)

/mob/camera/commander/AltClickOn(atom/A) //Remove an infection
	var/turf/T = get_turf(A)
	if(T)
		remove_infection(T)