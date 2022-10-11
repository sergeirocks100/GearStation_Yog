/obj/item/reagent_containers/food/snacks/bait
	name = "development bait"
	desc = "if you see this, get help"
	icon = 'yogstation/icons/obj/fishing/fishing.dmi'
	icon_state = "bait_worm"
	tastes = list("sour, rotten water" = 1)
	foodtype = GROSS //probably dont eat it
	var/fishing_power = 10

/obj/item/reagent_containers/food/snacks/bait/apprentice
	name = "apprentice bait"
	desc = "A basic bait for an aspiring fisherman"
	icon_state = "bait_1"
	fishing_power = 10

/obj/item/reagent_containers/food/snacks/bait/journeyman
	name = "journeyman bait"
	desc = "Advanced bait that only a skilled fisherman can use"
	icon_state = "bait_2"
	fishing_power = 20

/obj/item/reagent_containers/food/snacks/bait/master
	name = "master bait"
	desc = "A masterfully crafted bait that only a master in fishing can harness"
	icon_state = "bait_3"
	fishing_power = 30

/obj/item/reagent_containers/food/snacks/bait/master/Initialize(mapload) //HEE HEEE HAHAHAHAHH  HEEHEH E E EHEEE
	. = ..()
	if(prob(1))
		desc = "Don't you dare say it"

/obj/item/reagent_containers/food/snacks/bait/worm
	name = "worm bait"
	desc = "Might be able to catch a lizard with this..."
	icon_state = "bait_worm"
	fishing_power = 15

/obj/item/reagent_containers/food/snacks/bait/leech
	name = "leech"
	desc = "What isn't fun about a little recycling?"
	icon_state = "leech"
	fishing_power = 20

/obj/item/reagent_containers/food/snacks/bait/type
	name = "type bait"
	desc = "Are you talking to me?"
	icon_state = "bait_t"
	fishing_power = 25
