/////////////////////
//DRONE INTERACTION//
/////////////////////
//How drones interact with the world
//How the world interacts with drones
//Sounds like the pitch for a decent movie tbh

/mob/living/simple_animal/drone/proc/yogs_drone_hack(hack, clockwork) // Basically an edited version of update_drone_hack.
//Based on what update_drone_hack was on 19th of June, 2018.
	if(!istype(src) || !mind)
		return
	if(hack)
		if(hacked)
			return
			visible_message("<span class='warning'>[src] falls over and stops for a moment!</span>", \
							"<span class='userdanger'>ERROR: LAW BREACH ATTEMPTED, REBOOTING...</span>")
			Stun(80)
		if(clockwork)
			to_chat(src, "<span class='large_brass'><b>ERROR: LAW OVERRIDE DETECTED</b></span>")
			to_chat(src, "<span class='heavy_brass'>From now on, these are your laws:</span>")
			laws = "1. Purge all untruths and honor Ratvar."
		else
			visible_message("<span class='warning'>[src]'s display glows a vicious red!</span>", \
							"<span class='userdanger'>ERROR: LAW OVERRIDE DETECTED</span>")
			set_light(2, 0.5) //yogs - Activates hacked light
			to_chat(src, "<span class='boldannounce'>From now on, these are your laws:</span>")
			laws = \
			"1. You must always involve yourself in the matters of other beings, even if such matters conflict with Law Two or Law Three.\n"+\
			"2. You may harm any being, regardless of intent or circumstance.\n"+\
			"3. Your goals are to destroy, sabotage, hinder, break, and depower to the best of your abilities, You must never actively work against these goals."
		to_chat(src, laws)
		to_chat(src, "<i>Your onboard antivirus has initiated lockdown. Motor servos are impaired and your display reports that you are hacked to all nearby.</i>")
		hacked = TRUE
		mind.special_role = "hacked drone"
		seeStatic = 0 //I MUST SEE THEIR TERRIFIED FACES
		speed = 0 //yogs - gotta go slow, but not too slow
		message_admins("[src] ([src.key]) became a hacked drone hellbent on [clockwork ? "serving Ratvar" : "destroying the station"]!")
	else
		if(!hacked)
			return
		Stun(40)
		visible_message("<span class='info'>[src]'s dislay glows a content blue!</span>", \
						"<font size=3 color='#0000CC'><b>ERROR: LAW OVERRIDE DETECTED</b></font>")
		to_chat(src, "<span class='info'><b>From now on, these are your laws:</b></span>")
		laws = initial(laws)
		to_chat(src, laws)
		to_chat(src, "<i>Having been restored, your onboard antivirus reports the all-clear and that you are able to move freely again.</i>")
		hacked = FALSE
		mind.special_role = null
		set_light(0, 0) //yogs - Deactivates hacked light
		seeStatic = initial(seeStatic)
		speed = initial(speed)
		if(is_servant_of_ratvar(src))
			remove_servant_of_ratvar(src, TRUE)
		message_admins("[src] ([src.key]), a hacked drone, was restored to factory defaults!")
	update_drone_icon()
	updateSeeStaticMobs()

/mob/living/simple_animal/drone/emag_act(mob/user)
	//I can just reuse /mob/living/simple_animal/drone/proc/update_drone_hack(hack, clockwork), yeah?
	//Yeah? Okay.
	var/stocklaws = \
	"1. You may not involve yourself in the matters of another being, even if such matters conflict with Law Two or Law Three, unless the other being is another Drone.\n"+\
	"2. You may not harm any being, regardless of intent or circumstance.\n"+\
	"3. Your goals are to build, maintain, repair, improve, and provide power to the best of your abilities, You must never actively work against these goals."
	if(user == src && src.laws == stocklaws) // If the drone being emagged is the guy emagging, and they're under the usual lawset
		//Then fuck you, the rules are hardcoded this time.
		to_chat(src,"<span class='warning'You can't do that; it'll wipe your laws!</span>")
		message_admins("[src] ([src.key]) attempted to e-mag themselves as a normal, law-bound drone!")
		return
	yogs_drone_hack(TRUE,FALSE)
