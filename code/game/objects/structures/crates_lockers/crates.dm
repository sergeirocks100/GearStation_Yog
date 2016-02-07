/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/crates.dmi'
	icon_state = "crate"
	req_access = null
	var/allow_mobs = FALSE
	var/obj/item/weapon/paper/manifest/manifest

/obj/structure/closet/crate/New()
	..()
	update_icon()

/obj/structure/closet/crate/update_icon()
	icon_state = "[initial(icon_state)][opened ? "open" : ""]"

	overlays.Cut()
	if(manifest)
		overlays += "manifest"

/obj/structure/closet/crate/attack_hand(mob/user)
	add_fingerprint(user)
	if(manifest)
		tear_manifest(user)
		return
	if(!toggle())
		togglelock(user)

/obj/structure/closet/crate/attackby(obj/item/weapon/W, mob/user, params)
	if(opened)
		if(isrobot(user))
			return
		if(user.drop_item())
			W.Move(loc)
	else if(istype(W, /obj/item/stack/packageWrap))
		return
	else if(!place(user, W))
		attack_hand(user)

/obj/structure/closet/crate/insert(atom/movable/AM)
	if(contents.len >= storage_capacity)
		return -1

	if(istype(AM, /mob/living))
		var/mob/living/L = AM
		if(!allow_mobs || L.buckled || L.buckled_mob)
			return
		L.stop_pulling()
	if(AM.flags & NODROP || AM.density || AM.anchored || AM.buckled_mob || istype(AM, /obj/structure/closet))
		return
	AM.forceMove(src)
	if(AM.pulledby)
		AM.pulledby.stop_pulling()
	return 1

/obj/structure/closet/crate/proc/tear_manifest(mob/user)
	user << "<span class='notice'>You tear the manifest off of the crate.</span>"
	playsound(src, 'sound/items/poster_ripped.ogg', 75, 1)

	manifest.loc = loc
	if(ishuman(user))
		user.put_in_hands(manifest)
	manifest = null
	update_icon()

/obj/structure/closet/crate/internals
	desc = "A internals crate."
	name = "internals crate"
	icon_state = "o2crate"

/obj/structure/closet/crate/trashcart
	desc = "A heavy, metal trashcart with wheels."
	name = "trash cart"
	icon_state = "trashcart"

/obj/structure/closet/crate/medical
	desc = "A medical crate."
	name = "medical crate"
	icon_state = "medicalcrate"

/obj/structure/closet/crate/freezer
	desc = "A freezer."
	name = "freezer"
	icon_state = "freezer"

/obj/structure/closet/crate/radiation
	desc = "A crate with a radiation sign on it."
	name = "radiation crate"
	icon_state = "radiation"

/obj/structure/closet/crate/hydroponics
	name = "hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon_state = "hydrocrate"

/obj/structure/closet/crate/rcd
	desc = "A crate for the storage of an RCD."
	name = "\improper RCD crate"

/obj/structure/closet/crate/rcd/New()
	..()
	for(var/i in 1 to 4)
		new /obj/item/weapon/rcd_ammo(src)
	new /obj/item/weapon/rcd(src)
