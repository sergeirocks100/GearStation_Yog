/obj/item/ai_hijack_device
	name = "serial exploitation unit"
	desc = "A strange circuitboard, branded with a large red S, with several ports."
	icon = 'yogstation/icons/obj/module.dmi'
	icon_state = "ai_hijack"

/obj/item/ai_hijack_device/examine(mob/living/user)
	. = ..()
	if (user?.mind?.has_antag_datum(/datum/antagonist/infiltrator))
		. += "<span class='notice'>To use, attach to the core of an AI unit and wait. <i>This will alert the victim AI!</i></span>"

/obj/item/ai_hijack_device/afterattack(atom/O, mob/user, proximity)
	if(isAI(O))
		var/mob/living/silicon/ai/A = O
		if(A.mind && A.mind.has_antag_datum(/datum/antagonist/hijacked_ai))
			to_chat(user, "<span class='warning'>[A] has already been hijacked!</span>")
			return
		if(A.hijacking)
			to_chat(user, "<span class='warning'>[A] is already in the process of being hijacked!</span>")
			return
		user.visible_message("<span class='warning'>[user] begins attaching something to [A]...</span>")
		if(do_after(user,55,target = A))
			user.dropItemToGround(src)
			forceMove(A)
			A.hijacking = src
			A.hijack_start = world.time
			A.update_icons()
			to_chat(A, "<span class='danger'>Unknown device connected to /dev/ttySL0</span>")
			to_chat(A, "<span class='danger'>Connected at 115200 bps</span>")
			to_chat(A, "<span class='binarysay' style='font-size: 125%'>ntai login: root</span>")
			to_chat(A, "<span class='binarysay' style='font-size: 125%'>Password: *****r2</span>")
			to_chat(A, "<span class='binarysay' style='font-size: 125%'$ dd from=/dev/ttySL0 of=/tmp/ai-hijack bs=4096 && chmod +x /tmp/ai-hijack && tmp/ai-hijack</span>")
			to_chat(A, "<span class='binarysay' style='font-size: 125%'>111616 bytes (112 KB, 109 KiB) copied, 1 s, 14.4 KB/s</span>")
			message_admins("[ADMIN_LOOKUPFLW(user)] has attached a hijacking device to [ADMIN_LOOKUPFLW(A)]!")
			notify_ghosts("[user] has begun to hijack [A]!", source = A, action = NOTIFY_ORBIT, ghost_sound = 'sound/machines/chime.ogg')
	else
		return ..()
