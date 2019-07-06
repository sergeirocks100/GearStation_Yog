/obj/item/reagent_containers/food/condiment/cinnamon
	name = "cinnamon shaker"
	desc = "A spice obtained from the bark of a cinnamomum tree"
	icon_state = "cinnamonshaker"
	list_reagents = list("cinnamon" = 50)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/cinnamon/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is attempting the cinnamon challenge! It looks like he's trying to commit suicide!</span>")
	return OXYLOSS