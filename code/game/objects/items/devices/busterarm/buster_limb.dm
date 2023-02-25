/* Formatting for these files, from top to bottom:
	* Spell/Action
	* Trigger()
	* IsAvailable()
	* Items
	In regards to spells or items with left and right subtypes, list the base, then left, then right.
*/
/// The Buster Arm (Left)
/// Same as the right one, but replaces your left arm!
/// Use it in-hand to swap its left or right mode
/// Attacking any human mob (typically yourself) will cause their arm to instantly be replaced with it
/obj/item/bodypart/l_arm/robot/buster
	name = "left buster arm"
	desc = "A robotic arm designed explicitly for combat and providing the user with extreme power. <b>It can be configured by hand to fit on the opposite arm.</b>"
	icon = 'icons/mob/augmentation/augments_buster.dmi'
	icon_state = "left_buster_arm"
	max_damage = 60
	aux_layer = 12
	var/obj/item/bodypart/r_arm/robot/buster/opphand
	var/datum/action/cooldown/buster/wire_snatch/l/wire_action =new/datum/action/cooldown/buster/wire_snatch/l()
	var/datum/action/cooldown/buster/grap/l/grapple_action = new/datum/action/cooldown/buster/grap/l()
	var/datum/action/cooldown/buster/mop/l/mop_action = new/datum/action/cooldown/buster/mop/l()
	var/datum/action/cooldown/buster/slam/l/slam_action = new/datum/action/cooldown/buster/slam/l()
	var/datum/action/cooldown/buster/megabuster/l/megabuster_action = new/datum/action/cooldown/buster/megabuster/l()

/// Set up our spells, disable gloves
/obj/item/bodypart/l_arm/robot/buster/attach_limb(mob/living/carbon/N, special)
	. = ..()
	var/datum/species/S = N.dna?.species
	S.add_no_equip_slot(N, SLOT_GLOVES)
	wire_action.Grant(N)
	grapple_action.Grant(N)
	mop_action.Grant(N)
	slam_action.Grant(N)
	megabuster_action.Grant(N)

/// Remove our spells, re-enable gloves
/obj/item/bodypart/l_arm/robot/buster/drop_limb(special)
	var/mob/living/carbon/N = owner
	var/datum/species/S = N.dna?.species
	S.remove_no_equip_slot(N, SLOT_GLOVES)
	wire_action.Remove(N)
	grapple_action.Remove(N)
	mop_action.Remove(N)
	slam_action.Remove(N)
	megabuster_action.Remove(N)
	..()

/// Attacking a human mob with the arm causes it to instantly replace their arm
/obj/item/bodypart/l_arm/robot/buster/attack(mob/living/L, proximity)
	if(!proximity)
		return
	if(!ishuman(L))
		return
	playsound(L,'sound/effects/phasein.ogg', 20, 1)
	to_chat(L, span_notice("You bump the prosthetic near your shoulder. In a flurry faster than your eyes can follow, it takes the place of your left arm!"))
	replace_limb(L)

/// Using the arm in-hand switches the arm it replaces
/obj/item/bodypart/l_arm/robot/buster/attack_self(mob/user)
	. = ..()
	opphand = new /obj/item/bodypart/r_arm/robot/buster(get_turf(src))
	opphand.brute_dam = src.brute_dam
	opphand.burn_dam = src.burn_dam 
	to_chat(user, span_notice("You modify [src] to be installed on the right arm."))
	qdel(src)

/// Same code as above, but set up for the right arm instead
/obj/item/bodypart/r_arm/robot/buster
	name = "right buster arm"
	desc = "A robotic arm designed explicitly for combat and providing the user with extreme power. <b>It can be configured by hand to fit on the opposite arm.</b>"
	icon = 'icons/mob/augmentation/augments_buster.dmi'
	icon_state = "right_buster_arm"
	max_damage = 60
	aux_layer = 12
	var/obj/item/bodypart/l_arm/robot/buster/opphand
	var/datum/action/cooldown/buster/wire_snatch/r/wire_action = new/datum/action/cooldown/buster/wire_snatch/r()
	var/datum/action/cooldown/buster/grap/r/grapple_action = new/datum/action/cooldown/buster/grap/r()
	var/datum/action/cooldown/buster/mop/r/mop_action = new/datum/action/cooldown/buster/mop/r()
	var/datum/action/cooldown/buster/slam/r/slam_action = new/datum/action/cooldown/buster/slam/r()
	var/datum/action/cooldown/buster/megabuster/r/megabuster_action = new/datum/action/cooldown/buster/megabuster/r()

/// Set up our spells, disable gloves
/obj/item/bodypart/r_arm/robot/buster/attach_limb(mob/living/carbon/N, special)
	. = ..()
	var/datum/species/S = N.dna?.species
	S.add_no_equip_slot(N, SLOT_GLOVES)
	wire_action.Grant(N)
	grapple_action.Grant(N)
	mop_action.Grant(N)
	slam_action.Grant(N)
	megabuster_action.Grant(N)

/// Remove our spells, re-enable gloves
/obj/item/bodypart/r_arm/robot/buster/drop_limb(special)
	var/mob/living/carbon/N = owner
	var/datum/species/S = N.dna?.species
	S.remove_no_equip_slot(N, SLOT_GLOVES)
	wire_action.Remove(N)
	grapple_action.Remove(N)
	mop_action.Remove(N)
	slam_action.Remove(N)
	megabuster_action.Remove(N)
	..()

/// Attacking a human mob with the arm causes it to instantly replace their arm
/obj/item/bodypart/r_arm/robot/buster/attack(mob/living/L, proximity)
	if(!proximity)
		return
	if(!ishuman(L))
		return
	playsound(L,'sound/effects/phasein.ogg', 20, 1)
	to_chat(L, span_notice("You bump the prosthetic near your shoulder. In a flurry faster than your eyes can follow, it takes the place of your right arm!"))
	replace_limb(L)

/// Using the arm in-hand switches the arm it replaces
/obj/item/bodypart/r_arm/robot/buster/attack_self(mob/user)
	. = ..()
	opphand = new /obj/item/bodypart/l_arm/robot/buster(get_turf(src))
	opphand.brute_dam = src.brute_dam
	opphand.burn_dam = src.burn_dam 
	to_chat(user, span_notice("You modify [src] to be installed on the left arm."))
	qdel(src)
