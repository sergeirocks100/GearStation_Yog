/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's a card-locked storage unit."
	locked = TRUE
	icon_state = "secure"
	max_integrity = 250
	armor = list("melee" = 30, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)
	secure = TRUE
	var/obj/item/electronics/airlock/electronics

/obj/structure/closet/secure_closet/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == "melee" && damage_amount < 20)
		return 0
	. = ..()

/obj/structure/closet/secure_closet/CheckParts(list/parts_list)
	. = ..()
	electronics = locate(/obj/item/electronics/airlock) in parts_list
	if(electronics)
		req_access = electronics.accesses
		qdel(electronics)
