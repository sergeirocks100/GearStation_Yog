/datum/map_template
	var/name = "Default Template Name"
	var/width = 0
	var/height = 0
	var/mappath = null
	var/mapfile = null

/datum/map_template/New(path = null, map = null, rename = null)
	if(path)
		mappath = path
		preload_size(mappath)
	if(map)
		mapfile = map
	if(rename)
		name = rename

/datum/map_template/proc/preload_size(path)
	var/quote = ascii2text(34)
	var/map_file = file2text(path)
	var/key_len = length(copytext(map_file,2,findtext(map_file,quote,2,0)))
	//assuming one map per file since more makes no sense for templates anyway
	var/mapstart = findtext(map_file,"\n(1,1,") //todo replace with something saner
	var/content = copytext(map_file,findtext(map_file,quote+"\n",mapstart,0)+2,findtext(map_file,"\n"+quote,mapstart,0)+1)
	var/line_len = length(copytext(content,1,findtext(content,"\n",2,0)))

	width = line_len/key_len
	height = length(content)/(line_len+1)

/datum/map_template/proc/load(turf/T, centered = FALSE)
	if(centered)
		T = locate(T.x - width/2 , T.y - height/2 , T.z)
	if(!T)
		return
	if(T.x+width > world.maxx)
		return
	if(T.y+height > world.maxy)
		return

	maploader.load_map(get_file(), T.x, T.y, T.z)
	//initialize
	for(var/A in block(T,locate(T.x+width, T.y+height, T.z)))
		var/turf/B = A
		for(var/atom/movable/AM in B)
			AM.initialize()
			if(istype(AM,/obj/structure/cable))
				var/obj/structure/cable/PC = AM
				if(!PC.powernet)
					var/datum/powernet/NewPN = new()
					NewPN.add_cable(PC)
					propagate_network(PC,PC.powernet)

	log_game("[name] loaded at at [T.x],[T.y],[T.z]")

/datum/map_template/proc/get_file()
	if(mapfile)
		return mapfile
	if(mappath)
		mapfile = file(mappath)
		return mapfile

/datum/map_template/proc/get_affected_turfs(turf/T, centered = FALSE)
	var/turf/placement = T
	if(centered)
		var/turf/corner = locate(placement.x - width/2, placement.y - height/2, placement.z)
		if(corner)
			placement = corner
	return block(placement, locate(placement.x + width, placement.y + height, placement.z))


/proc/preloadTemplates(path = "_maps/templates/") //see master controller setup
	var/list/filelist = flist(path)
	for(var/map in filelist)
		var/datum/map_template/T = new(path = "[path][map]", rename = "[map]")
		map_templates[T.name] = T

	preloadRuinTemplates()

/proc/preloadRuinTemplates()
	var/list/potentialSpaceRuins = generateMapList(filename = "config/spaceRuinConfig.txt")
	for(var/ruin in potentialSpaceRuins)
		var/datum/map_template/T = new(path = "[ruin]", rename = "[ruin]")
		space_ruins_templates[T.name] = T

	var/list/potentialLavaRuins = generateMapList(filename = "config/lavaRuinConfig.txt")
	for(var/ruin in potentialLavaRuins)
		var/datum/map_template/T = new(path = "[ruin]", rename = "[ruin]")
		lava_ruins_templates[T.name] = T