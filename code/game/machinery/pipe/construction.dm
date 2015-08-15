/*CONTENTS
Buildable pipes
Buildable meters
*/
/*
#define PIPE_SIMPLE_STRAIGHT	0
#define PIPE_SIMPLE_BENT		1
#define PIPE_HE_STRAIGHT		2
#define PIPE_HE_BENT			3
#define PIPE_CONNECTOR			4
#define PIPE_MANIFOLD			5
#define PIPE_JUNCTION			6
#define PIPE_UVENT				7
#define PIPE_MVALVE				8
#define PIPE_PUMP				9
#define PIPE_SCRUBBER			10
#define PIPE_GAS_FILTER			11
#define PIPE_GAS_MIXER			12
#define PIPE_PASSIVE_GATE       13
#define PIPE_VOLUME_PUMP        14
#define PIPE_HEAT_EXCHANGE      15
#define PIPE_DVALVE             16
#define PIPE_4WAYMANIFOLD       17
//Disposal piping numbers - do NOT hardcode these, use the defines
#define DISP_PIPE_STRAIGHT		0
#define DISP_PIPE_BENT			1
#define DISP_JUNCTION			2
#define DISP_JUNCTION_FLIP		3
#define DISP_YJUNCTION			4
#define DISP_END_TRUNK			5
#define DISP_END_BIN			6
#define DISP_END_OUTLET			7
#define DISP_END_CHUTE			8
#define DISP_SORTJUNCTION		9
#define DISP_SORTJUNCTION_FLIP	10
*/
/obj/item/pipe
	name = "pipe"
	desc = "A pipe"
	var/pipe_type = 0
	var/pipename
	force = 7
	icon = 'icons/obj/atmospherics/pipes/pipe_item.dmi'
	icon_state = "simple"
	item_state = "buildpipe"
	w_class = 3
	level = 2
	var/flipped = 0
	var/is_bent = 0

	var/global/list/pipe_types = list(
		PIPE_SIMPLE, \
		PIPE_MANIFOLD, \
		PIPE_4WAYMANIFOLD, \
		PIPE_HE, \
		PIPE_JUNCTION, \
		\
		PIPE_CONNECTOR, \
		PIPE_UVENT, \
		PIPE_SCRUBBER, \
		PIPE_HEAT_EXCHANGE, \
		\
		PIPE_PUMP, \
		PIPE_PASSIVE_GATE, \
		PIPE_VOLUME_PUMP, \
		PIPE_MVALVE, \
		PIPE_DVALVE, \
		\
		PIPE_GAS_FILTER, \
		PIPE_GAS_MIXER, \
	)

/obj/item/pipe/New(loc, pipe_type, dir, obj/machinery/atmospherics/make_from)
	..()
	if(make_from)
		src.dir = make_from.dir
		src.pipename = make_from.name
		src.color = make_from.color
		src.pipe_type = make_from.type

		var/obj/machinery/atmospherics/components/trinary/triP = make_from
		if(istype(triP) && triP.flipped)
			src.flipped = 1
			src.dir = turn(src.dir, -45)

	else
		src.pipe_type = pipe_type
		src.dir = dir

	if(!(pipe_type in pipe_types))
		for(var/P in pipe_types)
			if(ispath(pipe_type, P))
				pipe_type = P
				break

	if(!(src.dir in cardinal))
		is_bent = 1

	update()
	src.pixel_x = rand(-5, 5)
	src.pixel_y = rand(-5, 5)

//update the name and icon of the pipe item depending on the type
var/global/list/pipeID2State = list(
	"[PIPE_SIMPLE]"			 = "simple", \
	"[PIPE_MANIFOLD]"		 = "manifold", \
	"[PIPE_4WAYMANIFOLD]"	 = "manifold4w", \
	"[PIPE_HE]"				 = "he", \
	"[PIPE_JUNCTION]"		 = "junction", \
	\
	"[PIPE_CONNECTOR]"		 = "connector", \
	"[PIPE_UVENT]"			 = "uvent", \
	"[PIPE_SCRUBBER]"		 = "scrubber", \
	"[PIPE_HEAT_EXCHANGE]"	 = "heunary", \
	\
	"[PIPE_PUMP]"			 = "pump", \
	"[PIPE_PASSIVE_GATE]"	 = "passivegate", \
	"[PIPE_VOLUME_PUMP]"	 = "volumepump", \
	"[PIPE_MVALVE]"			 = "mvalve", \
	"[PIPE_DVALVE]"			 = "dvalve", \
	\
	"[PIPE_GAS_FILTER]"		 = "filter", \
	"[PIPE_GAS_MIXER]"		 = "mixer", \
)

/obj/item/pipe/proc/update()
	var/list/nlist = list(\
		"[PIPE_SIMPLE]" 		= "pipe", \
		"[PIPE_SIMPLE]_b" 		= "bent pipe", \
		"[PIPE_MANIFOLD]" 		= "manifold", \
		"[PIPE_4WAYMANIFOLD]" 	= "4-way manifold", \
		"[PIPE_HE]" 			= "h/e pipe", \
		"[PIPE_HE]_b" 			= "bent h/e pipe", \
		"[PIPE_JUNCTION]" 		= "junction", \
		\
		"[PIPE_CONNECTOR]" 		= "connector", \
		"[PIPE_UVENT]" 			= "vent", \
		"[PIPE_SCRUBBER]" 		= "scrubber", \
		"[PIPE_HEAT_EXCHANGE]" 	= "heat exchanger", \
		\
		"[PIPE_PUMP]" 			= "pump", \
		"[PIPE_PASSIVE_GATE]" 	= "passive gate", \
		"[PIPE_VOLUME_PUMP]" 	= "volume pump", \
		"[PIPE_MVALVE]" 		= "manual valve", \
		"[PIPE_DVALVE]" 		= "digital valve", \
		\
		"[PIPE_GAS_FILTER]" 	= "gas filter", \
		"[PIPE_GAS_MIXER]" 		= "gas mixer", \
		)
	name = nlist["[pipe_type][is_bent ? "_b" : ""]"] + " fitting"
	icon_state = pipeID2State["[pipe_type]"]

// rotate the pipe item clockwise

/obj/item/pipe/verb/rotate()
	set category = "Object"
	set name = "Rotate Pipe"
	set src in view(1)

	if ( usr.stat || usr.restrained() || !usr.canmove )
		return

	src.dir = turn(src.dir, -90)

	fixdir()

	return

/obj/item/pipe/verb/flip()
	set category = "Object"
	set name = "Flip Pipe"
	set src in view(1)

	if ( usr.stat || usr.restrained() || !usr.canmove )
		return

	if (pipe_type in list(PIPE_GAS_FILTER, PIPE_GAS_MIXER))
		src.dir = turn(src.dir, flipped ? 45 : -45)
		flipped = !flipped
		return

	src.dir = turn(src.dir, -180)

	fixdir()

	return

/obj/item/pipe/Move()
	..()
	if ((pipe_type in list (PIPE_SIMPLE, PIPE_HE)) && is_bent \
		&& (src.dir in cardinal))
		src.dir = src.dir|turn(src.dir, 90)
	else if ((pipe_type in list(PIPE_GAS_FILTER, PIPE_GAS_MIXER)) && flipped)
		src.dir = turn(src.dir, 45+90)
	fixdir()

// returns all pipe's endpoints
/*
/obj/item/pipe/proc/get_pipe_dir()
	if (!dir)
		return 0

	var/direct = dir
	if(flipped)
		direct = turn(dir, 45)

	var/flip = turn(direct, 180)
	var/cw = turn(direct, -90)
	var/acw = turn(direct, 90)

	switch(pipe_type)
		if(	PIPE_SIMPLE_STRAIGHT, \
			PIPE_HE_STRAIGHT, \
			PIPE_JUNCTION, \
			PIPE_PUMP, \
			PIPE_VOLUME_PUMP, \
			PIPE_PASSIVE_GATE, \
			PIPE_MVALVE, \
			PIPE_DVALVE \
		)
			return direct|flip
		if(PIPE_SIMPLE_BENT, PIPE_HE_BENT)
			return direct //dir|acw
		if(PIPE_CONNECTOR,PIPE_UVENT,PIPE_SCRUBBER,PIPE_HEAT_EXCHANGE)
			return direct
		if(PIPE_MANIFOLD)
			return flip|cw|acw
		if(PIPE_4WAYMANIFOLD)
			return NORTH|SOUTH|EAST|WEST
		if(PIPE_GAS_FILTER, PIPE_GAS_MIXER)
			return direct|flip|cw
	return 0

/obj/item/pipe/proc/get_pdir() //endpoints for regular pipes

	var/flip = turn(dir, 180)
//	var/cw = turn(dir, -90)
//	var/acw = turn(dir, 90)

	if (!(pipe_type in list(PIPE_HE_STRAIGHT, PIPE_HE_BENT, PIPE_JUNCTION)))
		return get_pipe_dir()
	switch(pipe_type)
		if(PIPE_HE_STRAIGHT,PIPE_HE_BENT)
			return 0
		if(PIPE_JUNCTION)
			return flip
	return 0

// return the h_dir (heat-exchange pipes) from the type and the dir

/obj/item/pipe/proc/get_hdir() //endpoints for h/e pipes

//	var/flip = turn(dir, 180)
//	var/cw = turn(dir, -90)

	switch(pipe_type)
		if(PIPE_HE_STRAIGHT)
			return get_pipe_dir()
		if(PIPE_HE_BENT)
			return get_pipe_dir()
		if(PIPE_JUNCTION)
			return dir
		else
			return 0
*/
/obj/item/pipe/proc/unflip(direction)
	if(!(direction in cardinal))
		return turn(direction, 45)

	return direction

//Helper to clean up dir
/obj/item/pipe/proc/fixdir()
	if((pipe_type in list (PIPE_SIMPLE, PIPE_HE, PIPE_MVALVE, PIPE_DVALVE)) && !is_bent)
		if(dir==SOUTH)
			dir = NORTH
		else if(dir==WEST)
			dir = EAST

/obj/item/pipe/attack_self(mob/user)
	return rotate()

/obj/item/pipe/attackby(obj/item/weapon/W, mob/user, params)

	//*
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if (!isturf(src.loc))
		return 1

	fixdir()
	if(pipe_type in list(PIPE_GAS_MIXER, PIPE_GAS_FILTER))
		dir = unflip(dir)

	var/obj/machinery/atmospherics/A = new pipe_type(src.loc)
	A.dir = src.dir
	A.SetInitDirections()

	for(var/obj/machinery/atmospherics/M in src.loc)
		if(M == A) //we don't want to check to see if it interferes with itself
			continue
		if(M.initialize_directions & A.GetInitDirections())	// matches at least one direction on either type of pipe
			user << "<span class='warning'>There is already a pipe at that location!</span>"
			qdel(A)
			return 1
	// no conflicts found

	if(pipename)
		A.name = pipename

	var/obj/machinery/atmospherics/components/trinary/T = A
	if(istype(T))
		T.flipped = flipped

	A.construction(src)

	/*
	switch(pipe_type)
		if(PIPE_SIMPLE_STRAIGHT, PIPE_SIMPLE_BENT)
			var/obj/machinery/atmospherics/pipe/simple/P = new( src.loc )
			P.construction(dir, pipe_dir, pipe_type, color)

		if(PIPE_HE_STRAIGHT, PIPE_HE_BENT)
			var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/P = new ( src.loc )
			P.initialize_directions_he = pipe_dir
			P.construction(dir, pipe_dir, pipe_type, color)

		if(PIPE_CONNECTOR)
			var/obj/machinery/atmospherics/components/unary/portables_connector/C = new( src.loc )
			if (pipename)
				C.name = pipename
			C.construction(dir, pipe_dir, pipe_type, color)

		if(PIPE_MANIFOLD)
			var/obj/machinery/atmospherics/pipe/manifold/M = new(loc)
			M.construction(dir, pipe_dir, pipe_type, color)

		if(PIPE_4WAYMANIFOLD)
			var/obj/machinery/atmospherics/pipe/manifold4w/M = new( src.loc )
			M.construction(dir, pipe_dir, pipe_type, color)

		if(PIPE_JUNCTION)
			var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/P = new ( src.loc )
			P.initialize_directions_he = src.get_hdir()
			P.construction(dir, get_pdir(), pipe_type, color)

		if(PIPE_UVENT)
			var/obj/machinery/atmospherics/components/unary/vent_pump/V = new( src.loc )
			V.construction(dir, pipe_dir, pipe_type, color)

		if(PIPE_MVALVE)
			var/obj/machinery/atmospherics/components/binary/valve/V = new(src.loc)
			if (pipename)
				V.name = pipename
			V.construction(dir, get_pdir(), pipe_type, color)

		if(PIPE_DVALVE)
			var/obj/machinery/atmospherics/components/binary/valve/digital/V = new(src.loc)
			if (pipename)
				V.name = pipename
			V.construction(dir, get_pdir(), pipe_type, color)

		if(PIPE_PUMP)
			var/obj/machinery/atmospherics/components/binary/pump/P = new(src.loc)
			P.construction(dir, pipe_dir, pipe_type, color)

		if(PIPE_GAS_FILTER, PIPE_GAS_MIXER)
			var/obj/machinery/atmospherics/components/trinary/P
			if(pipe_type == PIPE_GAS_FILTER)
				P = new /obj/machinery/atmospherics/components/trinary/filter(src.loc)
			else if(pipe_type == PIPE_GAS_MIXER)
				P = new /obj/machinery/atmospherics/components/trinary/mixer(src.loc)
			P.flipped = flipped
			if (pipename)
				P.name = pipename
			P.construction(unflip(dir), pipe_dir, pipe_type, color)

		if(PIPE_SCRUBBER)
			var/obj/machinery/atmospherics/components/unary/vent_scrubber/S = new(src.loc)
			if (pipename)
				S.name = pipename
			S.construction(dir, pipe_dir, pipe_type, color)

		if(PIPE_PASSIVE_GATE)
			var/obj/machinery/atmospherics/components/binary/passive_gate/P = new(src.loc)
			if (pipename)
				P.name = pipename
			P.construction(dir, pipe_dir, pipe_type, color)

		if(PIPE_VOLUME_PUMP)
			var/obj/machinery/atmospherics/components/binary/volume_pump/P = new(src.loc)
			if (pipename)
				P.name = pipename
			P.construction(dir, pipe_dir, pipe_type, color)

		if(PIPE_HEAT_EXCHANGE)
			var/obj/machinery/atmospherics/components/unary/heat_exchanger/C = new( src.loc )
			if (pipename)
				C.name = pipename
			C.construction(dir, pipe_dir, pipe_type, color)
*/
	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	user.visible_message( \
		"[user] fastens \the [src].", \
		"<span class='notice'>You fasten \the [src].</span>", \
		"<span class='italics'>You hear ratchet.</span>")

	qdel(src)	// remove the pipe item

	return
	 //TODO: DEFERRED

// ensure that setterm() is called for a newly connected pipeline



/obj/item/pipe_meter
	name = "meter"
	desc = "A meter that can be laid on pipes"
	icon = 'icons/obj/atmospherics/pipes/pipe_item.dmi'
	icon_state = "meter"
	item_state = "buildpipe"
	w_class = 4

/obj/item/pipe_meter/attackby(obj/item/weapon/W, mob/user, params)
	..()

	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if(!locate(/obj/machinery/atmospherics/pipe, src.loc))
		user << "<span class='warning'>You need to fasten it to a pipe!</span>"
		return 1
	new/obj/machinery/meter( src.loc )
	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	user << "<span class='notice'>You fasten the meter to the pipe.</span>"
	qdel(src)
