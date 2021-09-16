/mob/living/silicon/ai
	var/obj/item/ai_hijack_device/hijacking
	var/mutable_appearance/hijack_overlay
	var/hijack_start = 0

/mob/camera/aiEye/pic_in_pic
	telegraph_cameras = FALSE

/mob/living/silicon/ai/proc/set_core_display_icon_yogs(input)
	var/datum/ai_skin/S = input
	icon = S.icon
	icon_state = S.icon_state

/mob/living/silicon/ai/attack_hand(mob/user)
	if(hijacking)
		user.visible_message("<span class='danger'>[user] attempts to disconnect the circuit board from [src].</span>", "<span class='notice'>There appears to be something connected to [src]'s ports! You attempt to disconnect it...</span>")
		if (do_after(user,100,target = src))
			hijacking.forceMove(loc)
			hijacking = null
			hijack_start = 0
			update_icons()
		else
			to_chat(user, "<span class='notice'>You fail to remove the device.</span>")
		return
	return ..()

/mob/living/silicon/ai/update_icons()
	..()
	cut_overlays()
	if(hijacking)
		if(!hijack_overlay)
			hijack_overlay = mutable_appearance('yogstation/icons/obj/module.dmi', "ai_hijack_overlay")
			hijack_overlay.layer = layer+0.1
			hijack_overlay.pixel_x = 8
		add_overlay(hijack_overlay)
		icon_state = "ai-static"
	else if(!hijacking && hijack_overlay)
		QDEL_NULL(hijack_overlay)
