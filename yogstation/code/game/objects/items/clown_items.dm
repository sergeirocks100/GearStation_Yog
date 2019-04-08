/obj/item/soap/infinite
	desc = "A heavy duty bar of Nanotrasen brand soap. Smells of plasma."
	grind_results = list("plasma" = 10, "lye" = 10)
	icon_state = "soapnt"
	cleanspeed = 28
	uses = INFINITY

/obj/item/bikehorn/rubber_pigeon
	name = "Rubber Pigeon"
	desc = "Rubber chickens are so 2316."
	icon = 'yogstation/icons/obj/items.dmi'
	icon_state = "rubber_pigeon"
	item_state = "rubber_pigeon"
	attack_verb = list("Pigeoned")

/obj/item/bikehorn/rubber_pigeon/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('yogstation/sound/items/rubber_pigeon.ogg'=1), 200) //hmmmm yes that should do it
