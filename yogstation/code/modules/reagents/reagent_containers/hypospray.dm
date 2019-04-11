/obj/item/reagent_containers/hypospray/mixi
	name = "QMC Bicaridine Injector"
	desc = "A quick-mix capital combat injector loaded with bicaridine."
	amount_per_transfer_from_this = 5
	icon_state = "combat_hypo"
	volume = 50
	list_reagents = list("bicaridine" = 50)

/obj/item/reagent_containers/hypospray/derm
	name = "QMC Kelotane Injector"
	desc = "A quick-mix capital combat injector loaded with kelotane."
	amount_per_transfer_from_this = 5
	icon_state = "combat_hypo"
	volume = 50
	list_reagents = list("kelotane" = 50)
	
/obj/item/reagent_containers/hypospray/medipen/stimpack/large
	name = "stimpack injector"
	desc = "Contains two heavy doses of stimulants."
	icon = 'yogstation/icons/obj/syringe.dmi'
	icon_state = "stimpakpen"
	volume = 50
	amount_per_transfer_from_this = 25
	list_reagents = list("stimulants" = 50)

/obj/item/reagent_containers/hypospray/medipen/stimpack/large/update_icon()
	if(reagents.total_volume > 25)
		icon_state = initial(icon_state)
	else if(reagents.total_volume)
		icon_state = "[initial(icon_state)]25"
	else
		icon_state = "[initial(icon_state)]0"