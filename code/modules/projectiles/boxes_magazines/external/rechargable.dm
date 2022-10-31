//Laser Rifle

/obj/item/ammo_box/magazine/recharge
	name = "power pack"
	desc = "A rechargeable, detachable battery that serves as a magazine for laser rifles."
	icon_state = "oldrifle"
	ammo_type = /obj/item/ammo_casing/caseless/laser
	caliber = LASER
	max_ammo = 20

/obj/item/ammo_box/magazine/recharge/update_icon()
	..()
	desc = "[initial(desc)] It has [stored_ammo.len] shot\s left."
	if(ammo_count())
		icon_state = "oldrifle"
	else
		icon_state = "oldrifle_empty"

/obj/item/ammo_box/magazine/recharge/attack_self() //No popping out the "bullets"
	return
