/**
 * # Server
 *
 * Immobile (but not dense) shells that can interact with
 * world.
 */
/obj/structure/server
	name = "server"
	icon = 'icons/obj/wiremod.dmi'
	icon_state = "setup_stationary"

	density = TRUE

/obj/structure/server/Initialize()
	. = ..()
	AddComponent(/datum/component/shell, null, SHELL_CAPACITY_VERY_LARGE, SHELL_FLAG_REQUIRE_ANCHOR)

/obj/structure/server/wrench_act(mob/living/user, obj/item/tool)
	setAnchored(!anchored)
	tool.play_tool_sound(src)
	to_chat(user, "<span class='notice>You [anchored?"secure":"unsecure"] [src].</span>")
	return TRUE
