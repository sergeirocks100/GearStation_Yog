//Items for nuke theft traitor objective

//the nuke core - objective item
/obj/item/nuke_core
	name = "plutonium core"
	desc = "Extremely radioactive. Wear goggles."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "plutonium_core"
	var/pulse = 0
	var/cooldown = 0

/obj/item/nuke_core/process()
	if(cooldown < world.time - 40)
		cooldown = world.time
		for(var/mob/living/L in range(8,get_turf(src)))
			var/rads = 100 - get_dist(L,src)*7
			L.irradiate(rads)

//nuke core box, for carrying the core
/obj/item/nuke_core_container
	name = "nuke core container"
	desc = "Solid container for radioactive objects."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "core_container_empty"
	var/obj/item/nuke_core/core = null

/obj/item/nuke_core_container/proc/load(obj/item/nuke_core/ncore, obj/machinery/nuclearbomb/nuke)
	if(core)
		return 0
	SSobj.processing -= ncore
	ncore.loc = src
	core = ncore
	nuke.core = null
	icon_state = "core_container_loaded"
	return 1

//snowflake screwdriver, works as a key to start nuke theft, traitor only
/obj/item/weapon/screwdriver/nuke
	name = "screwdriver"
	desc = "A screwdriver with an ultra thin tip."

/obj/item/weapon/paper/nuke_instructions
	info = "How to break into a Nanotrasen self-destruct terminal and remove it's plutonium core:<br>\
	<ul>\
	<li>Use a screwdriver with a very thin tip (provided) to unscrew the terminal's front panel;</li>\
	<li>The insides of the terminal should be mostly hollow and you should have a clear way to the warhead's weak spot;</li>\
	<li>Use something to draw cut lines on the warhead, according to the provided plans;</li>\
	<li>With a welding tool, cut a hole in the warhead, following the previously drawn cut lines;</li>\
	<li>After you breach the warhead, you may notice the very subtle glow of the plutonium core;</li>\
	<li>Place the provided core container in the hole and poke the core until it falls into the container;</li>\
	<li>Once the core is inside the container, the container will lock shut. Deliver the container to your commander.</li>"

/obj/item/weapon/paper/nuke_plans
	info = "Nuclear warhead breaching plans:"