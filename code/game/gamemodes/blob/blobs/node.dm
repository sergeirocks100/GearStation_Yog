/obj/structure/blob/node
	name = "blob node"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blank_blob"
	desc = "A large, pulsating yellow mass."
	health = 200
	maxhealth = 200
	health_regen = 3
	point_return = 25


/obj/structure/blob/node/New(loc)
	blob_nodes += src
	START_PROCESSING(SSobj, src)
	..(loc)

/obj/structure/blob/node/scannerreport()
	return "Gradually expands and sustains nearby blob spores and blobbernauts."

/obj/structure/blob/node/update_icon()
	cut_overlays()
	color = null
	var/image/I = new('icons/mob/blob.dmi', "blob")
	if(overmind)
		I.color = overmind.blob_reagent_datum.color
	src.add_overlay(I)
	var/image/C = new('icons/mob/blob.dmi', "blob_node_overlay")
	src.add_overlay(C)

/obj/structure/blob/node/Destroy()
	blob_nodes -= src
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/blob/node/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	exposed_temperature *= 0.75
	..()

/obj/structure/blob/node/Life()
	Pulse_Area(overmind, 10, 3, 2)
	color = null
