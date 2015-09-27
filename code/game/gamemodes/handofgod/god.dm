
/mob/camera/god
	name = "deity" //Auto changes to the player's deity name/random name
	real_name = "deity"
	icon = 'icons/mob/mob.dmi'
	icon_state = "marker"
	invisibility = 60
	see_in_dark = 0
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	languages = HUMAN | MONKEY | ALIEN | ROBOT | SLIME | DRONE | SWARMER

	var/faith = 0
	var/max_faith = 100
	var/side = "neutral" //Red or Blue for the gamemode
	var/obj/structure/divine/nexus/god_nexus = null //The source of the god's power in this realm, kill it and the god is kill
	var/nexus_required = FALSE //If the god dies from losing it's nexus, defaults to off so that gods don't instantly die at roundstart
	var/followers_required = 0 //Same as above
	var/alive_followers = 0
	var/mob/living/carbon/human/prophet = null //The prophet of this god
	var/list/structures = list()
	var/prophets_sacrificed_in_name = 0


/mob/camera/god/New(loc, newName, side = "neutral")
	..()
	real_name = newName
	name = real_name
	side = side
	update_icons()


/mob/camera/god/update_icons()
	icon_state = "[initial(icon_state)]-[side]"


/mob/camera/god/Stat()
	..()
	if(statpanel("Status"))
		if(god_nexus)
			stat("Nexus health: ", god_nexus.health)
		stat("Followers: ", alive_followers)
		stat("Faith: ", "[faith]/[max_faith]")


/mob/camera/god/Login()
	..()
	sync_mind()
	src << "<span class='notice'>You are a deity!</span>"
	src << "You are a deity and are worshipped by a cult!  You are rather weak right now, but that will change as you gain more followers."
	src << "You will need to place an anchor to this world, a <b>Nexus</b>, in two minutes.  If you don't, one will be placed for you randomly."
	src << "Your <b>Follower</b> count determines how many people believe in you and are a part of your cult.  If this drops to zero, you will die."
	src << "Your <b>Nexus Integrity</b> tells you the condition of your nexus.  If your nexus is destroyed, you die as well, but your powers are amplified when near it."
	src << "Your <b>Faith</b> is used to interact with the world.  This will regenerate on it's own, and it goes faster when you have more followers."
	src << "The first thing you should do after placing your nexus is to <b>appoint a prophet</b>.  Only prophets can hear you talk, unless you use an expensive power."
	update_health_hud()


/mob/camera/god/proc/update_health_hud()
	if(god_nexus && hud_used && hud_used.deity_health_display)
		hud_used.deity_health_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='lime'>[god_nexus.health]   </font></div>"


/mob/camera/god/proc/add_faith(faith_amt)
	if(faith_amt)
		faith = Clamp(faith+faith_amt, 0, max_faith)
		if(hud_used && hud_used.deity_power_display)
			hud_used.deity_power_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='cyan'>[faith]  </font></div>"


/mob/camera/god/proc/update_followers()
	alive_followers = 0
	var/list/all_followers

	if(side == "red")
		all_followers = ticker.mode.red_deity_followers|ticker.mode.red_deity_prophets
	if(side == "blue")
		all_followers = ticker.mode.blue_deity_followers|ticker.mode.blue_deity_prophets

	for(var/datum/mind/F in all_followers)
		if(F.current && F.current.stat != DEAD)
			alive_followers++

	if(hud_used && hud_used.deity_follower_display)
		hud_used.deity_follower_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='red'>[alive_followers]     </font></div>"


/mob/camera/god/say(msg)
	if(!msg)
		return
	if(client)
		if(client.prefs.muted & MUTE_IC)
			src << "You cannot send IC messages (muted)."
			return
		if(src.client.handle_spam_prevention(msg,MUTE_IC))
			return
	if(stat)
		return

	god_speak(msg)


/mob/camera/god/proc/god_speak(msg)
	log_say("Hand of God: [capitalize(side)] God/[key_name(src)] : [msg]")
	msg = trim(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))
	if(!msg)
		return

	msg = say_quote(msg, get_spans())
	var/rendered = "<font color='#045FB4'><i><span class='game say'>Divine Telepathy, <span class='name'>[name]</span> <span class='message'>[msg]</span></span></i></font>"

	for(var/mob/M in mob_list)
		if(is_handofgod_myprophet(M) || isobserver(M))
			M.show_message(rendered, 2)
	src << rendered


/mob/camera/god/emote(act,m_type = 1 ,msg = null)
	return


/mob/camera/god/Move(NewLoc, Dir = 0)
	loc = NewLoc
