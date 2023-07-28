/datum/component/cooking/Initialize()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOB_CLIENT_LOGIN, PROC_REF(create_mob_button))

/datum/component/cooking/proc/create_mob_button(mob/user, client/CL)
	var/datum/hud/H = user.hud_used
	var/atom/movable/screen/cook/C = new()
	C.icon = H.ui_style
	H.static_inventory += C
	CL.screen += C
	RegisterSignal(C, COMSIG_CLICK, PROC_REF(component_ui_interact))

/datum/component/cooking
	var/busy
	var/display_craftable_only = FALSE
	var/display_compact = FALSE

/datum/component/cooking/proc/check_contents(atom/a, datum/crafting_recipe/R, list/contents)
	var/list/item_instances = contents["instances"]
	contents = contents["other"]

	var/list/requirements_list = list()

	// Process all requirements
	for(var/requirement_path in R.reqs)
		// Check we have the appropriate amount available in the contents list
		var/needed_amount = R.reqs[requirement_path]
		for(var/content_item_path in contents)
			// Right path and not blacklisted
			if(!ispath(content_item_path, requirement_path) || R.blacklist.Find(content_item_path))
				continue

			needed_amount -= contents[content_item_path]
			if(needed_amount <= 0)
				break

		if(needed_amount > 0)
			return FALSE

		// Store the instances of what we will use for R.check_requirements() for requirement_path
		var/list/instances_list = list()
		for(var/instance_path in item_instances)
			if(ispath(instance_path, requirement_path))
				instances_list += item_instances[instance_path]

		requirements_list[requirement_path] = instances_list

	for(var/requirement_path in R.chem_catalysts)
		if(contents[requirement_path] < R.chem_catalysts[requirement_path])
			return FALSE

	return R.check_requirements(a, requirements_list)

/datum/component/cooking/proc/get_environment(atom/a, list/blacklist = null, radius_range = 1)
	. = list()

	if(!isturf(a.loc))
		return

	for(var/atom/movable/AM in range(radius_range, a))
		if((AM.flags_1 & HOLOGRAM_1) || (blacklist && (AM.type in blacklist)))
			continue
		. += AM

/datum/component/cooking/proc/get_surroundings(atom/a, list/blacklist=null)
	. = list()
	.["tool_behaviour"] = list()
	.["other"] = list()
	.["instances"] = list()
	for(var/obj/item/item in get_environment(a, blacklist))
		if(item.status_traits && HAS_TRAIT(item, TRAIT_NODROP) || item.flags_1 & HOLOGRAM_1)
			continue
		LAZYADDASSOCLIST(.["instances"], item.type, item)
		if(isstack(item))
			var/obj/item/stack/stack = item
			.["other"][item.type] += stack.amount
		else if(item.tool_behaviour)
			.["tool_behaviour"] += item.tool_behaviour
			.["other"][item.type] += 1
		else
			if(is_reagent_container(item))
				var/obj/item/reagent_containers/container = item
				if(container.is_drainable())
					for(var/datum/reagent/reagent in container.reagents.reagent_list)
						.["other"][reagent.type] += reagent.volume
			.["other"][item.type] += 1

/// Returns a boolean on whether the tool requirements of the input recipe are satisfied by the input source and surroundings.
/datum/component/cooking/proc/check_tools(atom/source, datum/crafting_recipe/recipe, list/surroundings)
	if(!length(recipe.tool_behaviors) && !length(recipe.tool_paths))
		return TRUE
	var/list/available_tools = list()
	var/list/present_qualities = list()

	for(var/obj/item/contained_item in source.contents)
		if(istype(contained_item, /obj/item/organ/cyberimp/arm/toolset))
			var/obj/item/organ/cyberimp/arm/toolset/toolset = contained_item
			if(toolset.owner == source)
				for(var/obj/item/implant_item in contained_item.contents)
					available_tools += implant_item.type
					if(implant_item.tool_behaviour)
						present_qualities[implant_item.tool_behaviour] = TRUE
		if(istype(contained_item, /obj/item/storage))
			for(var/obj/item/subcontained_item in contained_item.contents)
				available_tools += subcontained_item.type
				if(subcontained_item.tool_behaviour)
					present_qualities[subcontained_item.tool_behaviour] = TRUE

		available_tools[contained_item.type] = TRUE
		if(contained_item.tool_behaviour)
			available_tools[contained_item.tool_behaviour] = TRUE

	for(var/quality in surroundings["tool_behaviour"])
		present_qualities[quality] = TRUE

	for(var/path in surroundings["other"])
		available_tools[path] = TRUE

	for(var/required_quality in recipe.tool_behaviors)
		if(present_qualities[required_quality])
			continue
		return FALSE

	for(var/required_path in recipe.tool_paths)
		var/found_this_tool = FALSE
		for(var/tool_path in available_tools)
			if(!ispath(required_path, tool_path))
				continue
			found_this_tool = TRUE
			break
		if(found_this_tool)
			continue
		return FALSE

	return TRUE

/datum/component/cooking/proc/construct_item(atom/a, datum/crafting_recipe/R)
	var/list/contents = get_surroundings(a,R.blacklist)
	var/send_feedback = 1
	if(check_contents(a, R, contents))
		if(check_tools(a, R, contents))
			if(R.one_per_turf)
				for(var/content in get_turf(a))
					if(istype(content, R.result))
						return ", object already present."
			//If we're a mob we'll try a do_after; non mobs will instead instantly construct the item
			if(ismob(a) && !do_after(a, R.time, target = a))
				return "."
			contents = get_surroundings(a,R.blacklist)
			if(!check_contents(a, R, contents))
				return ", missing component."
			if(!check_tools(a, R, contents))
				return ", missing tool."
			var/list/parts = del_reqs(R, a)
			var/atom/movable/I = new R.result (get_turf(a.loc))
			I.CheckParts(parts, R)
			if(send_feedback)
				SSblackbox.record_feedback("tally", "object_crafted", 1, I.type)
			return I //Send the item back to whatever called this proc so it can handle whatever it wants to do with the new item
		return ", missing tool."
	return ", missing component."

/*Del reqs works like this:

	Loop over reqs var of the recipe
	Set var amt to the value current cycle req is pointing to, its amount of type we need to delete
	Get var/surroundings list of things accessable to crafting by get_environment()
	Check the type of the current cycle req
		If its reagent then do a while loop, inside it try to locate() reagent containers, inside such containers try to locate needed reagent, if there isn't remove thing from surroundings
			If there is enough reagent in the search result then delete the needed amount, create the same type of reagent with the same data var and put it into deletion list
			If there isn't enough take all of that reagent from the container, put into deletion list, substract the amt var by the volume of reagent, remove the container from surroundings list and keep searching
			While doing above stuff check deletion list if it already has such reagnet, if yes merge instead of adding second one
		If its stack check if it has enough amount
			If yes create new stack with the needed amount and put in into deletion list, substract taken amount from the stack
			If no put all of the stack in the deletion list, substract its amount from amt and keep searching
			While doing above stuff check deletion list if it already has such stack type, if yes try to merge them instead of adding new one
		If its anything else just locate() in in the list in a while loop, each find --s the amt var and puts the found stuff in deletion loop

	Then do a loop over parts var of the recipe
		Do similar stuff to what we have done above, but now in deletion list, until the parts conditions are satisfied keep taking from the deletion list and putting it into parts list for return

	After its done loop over deletion list and delete all the shit that wasn't taken by parts loop

	del_reqs return the list of parts resulting object will receive as argument of CheckParts proc, on the atom level it will add them all to the contents, on all other levels it calls ..() and does whatever is needed afterwards but from contents list already
*/

/datum/component/cooking/proc/del_reqs(datum/crafting_recipe/R, atom/a)
	var/list/surroundings
	var/list/Deletion = list()
	. = list()
	var/data
	var/amt
	var/list/requirements = list()
	if(R.reqs)
		requirements += R.reqs
	main_loop:
		for(var/path_key in requirements)
			amt = R.reqs[path_key]
			if(!amt)
				continue main_loop
			surroundings = get_environment(a, R.blacklist)
			surroundings -= Deletion
			if(ispath(path_key, /datum/reagent))
				var/datum/reagent/RG = new path_key
				var/datum/reagent/RGNT
				while(amt > 0)
					var/obj/item/reagent_containers/RC = locate() in surroundings
					RG = RC.reagents.get_reagent(path_key)
					if(RG)
						if(!locate(RG.type) in Deletion)
							Deletion += new RG.type()
						if(RG.volume > amt)
							RG.volume -= amt
							data = RG.data
							RC.reagents.conditional_update(RC)
							RC.update_appearance(UPDATE_ICON)
							RG = locate(RG.type) in Deletion
							RG.volume = amt
							RG.data += data
							continue main_loop
						else
							surroundings -= RC
							amt -= RG.volume
							RC.reagents.reagent_list -= RG
							RC.reagents.conditional_update(RC)
							RC.update_appearance(UPDATE_ICON)
							RGNT = locate(RG.type) in Deletion
							RGNT.volume += RG.volume
							RGNT.data += RG.data
							qdel(RG)
						//SEND_SIGNAL(RC.reagents, COMSIG_REAGENTS_CRAFTING_PING) // - [] TODO: Make this entire thing less spaghetti
					else
						surroundings -= RC
			else if(ispath(path_key, /obj/item/stack))
				var/obj/item/stack/S
				var/obj/item/stack/SD
				while(amt > 0)
					S = locate(path_key) in surroundings
					if(S.amount >= amt)
						if(!locate(S.type) in Deletion)
							SD = new S.type()
							Deletion += SD
						S.use(amt)
						SD = locate(S.type) in Deletion
						SD.amount += amt
						continue main_loop
					else
						amt -= S.amount
						if(!locate(S.type) in Deletion)
							Deletion += S
						else
							data = S.amount
							S = locate(S.type) in Deletion
							S.add(data)
						surroundings -= S
			else
				var/atom/movable/I
				while(amt > 0)
					I = locate(path_key) in surroundings
					Deletion += I
					surroundings -= I
					amt--
	var/list/partlist = list(R.parts.len)
	for(var/M in R.parts)
		partlist[M] = R.parts[M]
	for(var/part in R.parts)
		if(istype(part, /datum/reagent))
			var/datum/reagent/RG = locate(part) in Deletion
			if(RG.volume > partlist[part])
				RG.volume = partlist[part]
			. += RG
			Deletion -= RG
			continue
		else if(isstack(part))
			var/obj/item/stack/ST = locate(part) in Deletion
			if(ST.amount > partlist[part])
				ST.amount = partlist[part]
			. += ST
			Deletion -= ST
			continue
		else
			while(partlist[part] > 0)
				var/atom/movable/AM = locate(part) in Deletion
				. += AM
				Deletion -= AM
				partlist[part] -= 1
	while(Deletion.len)
		var/DL = Deletion[Deletion.len]
		Deletion.Cut(Deletion.len)
		// Snowflake handling of reagent containers and storage atoms.
		// If we consumed them in our crafting, we should dump their contents out before qdeling them.
		if(istype(DL, /obj/item/storage))
			var/obj/item/storage/container = DL
			container.emptyStorage()
		qdel(DL)

/datum/component/cooking/proc/component_ui_interact(atom/movable/screen/cook/image, location, control, params, user)
	SIGNAL_HANDLER

	if(user == parent)
		INVOKE_ASYNC(src, PROC_REF(ui_interact), user)

/datum/component/cooking/ui_state(mob/user)
	return GLOB.not_incapacitated_turf_state

//For the UI related things we're going to assume the user is a mob rather than typesetting it to an atom as the UI isn't generated if the parent is an atom
/datum/component/cooking/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PersonalCooking", "Cook Book")
		ui.open()

/datum/component/cooking/ui_data(mob/user)
	var/list/data = list()
	data["busy"] = busy
	data["display_craftable_only"] = display_craftable_only
	data["display_compact"] = display_compact

	var/list/surroundings = get_surroundings(user)
	var/list/craftability = list()
	for(var/rec in GLOB.crafting_recipes)
		var/datum/crafting_recipe/R = rec

		if(!R.always_available && !(R.type in user?.mind?.learned_recipes)) //User doesn't actually know how to make this.
			continue

		if (!ispath(R.type, /datum/crafting_recipe/food/))
			continue

		if(!R.result)
			continue

		if(check_contents(user, R, surroundings) && check_tools(user, R, surroundings))
			craftability["[REF(R)]"] = TRUE

	data["craftability"] = craftability
	return data

/datum/component/cooking/ui_static_data(mob/user)
	var/list/data = list()

	data["recipes"] = list()
	data["categories"] = list()
	data["foodtypes"] = list()

	if(user.has_dna())
		var/mob/living/carbon/carbon = user
		data["diet"] = carbon.dna.species.get_species_diet()

	for(var/rec in GLOB.crafting_recipes)
		var/datum/crafting_recipe/R = rec

		if(R.name == "") //This is one of the invalid parents that sneaks in
			continue

		if(!R.always_available && !(R.type in user?.mind?.learned_recipes)) //User doesn't actually know how to make this.
			continue

		if (!ispath(R.type, /datum/crafting_recipe/food/))
			continue

		if(!R.result)
			continue

		if(!(R.subcategory in data["categories"]))
			data["categories"] += R.subcategory

		if(ispath(R.result, /obj/item/reagent_containers/food))
			var/obj/item/reagent_containers/food/item = R.result
			var/list/foodtypes = bitfield_to_list(initial(item.foodtype), FOOD_FLAGS)
			for(var/type in foodtypes)
				if(!(type in data["foodtypes"]))
					data["foodtypes"] += type

		data["recipes"] += list(build_cooking_data(R))

	return data

/datum/component/cooking/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("make")
			var/mob/user = usr
			var/datum/crafting_recipe/crafting_recipe = locate(params["recipe"]) in GLOB.crafting_recipes
			busy = TRUE
			ui_interact(user)
			var/atom/movable/result = construct_item(user, crafting_recipe)
			if(!istext(result)) //We made an item and didn't get a fail message
				if(ismob(user) && isitem(result)) //In case the user is actually possessing a non mob like a machine
					user.put_in_hands(result)
				else
					result.forceMove(user.drop_location())
				to_chat(user, span_notice("[crafting_recipe.name] constructed."))
				user.investigate_log("[key_name(user)] crafted [crafting_recipe]", INVESTIGATE_CRAFTING)
				crafting_recipe.on_craft_completion(user, result)
			else
				to_chat(user, span_warning("Construction failed[result]"))
			busy = FALSE
		if("toggle_recipes")
			display_craftable_only = !display_craftable_only
			. = TRUE
		if("toggle_compact")
			display_compact = !display_compact
			. = TRUE

/datum/component/cooking/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/cooking),
	)

/datum/component/cooking/proc/build_cooking_data(datum/crafting_recipe/food/recipe)
	var/list/data = list()
	data["ref"] = "[REF(recipe)]"
	var/atom/atom = recipe.result
	data["result"] = atom
	data["category"] = recipe.subcategory
	data["name"] = initial(atom.name)
	if(recipe.name) // Override if recipe has a name
		data["name"] = recipe.name

	// Description
	if(ispath(recipe.result, /datum/reagent))
		var/datum/reagent/reagent = recipe.result
		data["desc"] = initial(reagent.description)
	else
		data["desc"] = initial(atom.desc)

	// Crafting
	if(recipe.non_craftable)
		data["non_craftable"] = recipe.non_craftable
	if(recipe.steps)
		data["steps"] = recipe.steps

	// Tools
	for(var/atom/req_atom as anything in recipe.tool_paths)
		data["tool_paths"] += list(list(
			"path" = req_atom,
			"name" = initial(req_atom.name)
		))

	// Foodtypes
	if(ispath(recipe.result, /obj/item/reagent_containers/food))
		var/obj/item/reagent_containers/food/item = recipe.result
		var/list/foodtypes = bitfield_to_list(initial(item.foodtype), FOOD_FLAGS)
		for(var/type in foodtypes)
			if(!(type in data["foodtypes"]))
				data["foodtypes"] += type
		data["foodtypes"] = foodtypes

	data["reqs"] = list()
	// Reaction data
	if(recipe.reaction)
		data["is_reaction"] = TRUE
		var/datum/chemical_reaction/reaction = GLOB.chemical_reactions_list[recipe.reaction]
		recipe.reqs = reaction.required_reagents
		if(!data["steps"])
			data["steps"] = list()
		if(!reaction.required_container && (recipe.reqs.len > 1 || reaction.required_catalysts.len > 1))
			data["steps"] += "Mix all ingredients together"
		if(reaction.required_temp > T20C)
			data["steps"] += "Heat up to [reaction.required_temp]K"
		if(reaction.required_container)
			var/atom/req_atom = reaction.required_container
			data["reqs"] += list(list(
				"path" = req_atom,
				"name" = initial(req_atom.name),
				"amount" = recipe.reqs[req_atom],
				"is_reagent" = ispath(req_atom, /datum/reagent/)
			))
			data["steps"] += "Add all ingredients into the [initial(req_atom.name)]"
		if(reaction.required_catalysts)
			for(var/atom/req_atom as anything in reaction.required_catalysts)
				data["catalysts"] += list(list(
					"path" = req_atom,
					"name" = initial(req_atom.name),
					"amount" = reaction.required_catalysts[req_atom],
					"is_reagent" = ispath(req_atom, /datum/reagent/)
				))

	// Ingredients
	for(var/atom/req_atom as anything in recipe.reqs)
		data["reqs"] += list(list(
			"path" = req_atom,
			"name" = initial(req_atom.name),
			"amount" = recipe.reqs[req_atom],
			"is_reagent" = ispath(req_atom, /datum/reagent/)
		))

	return data
