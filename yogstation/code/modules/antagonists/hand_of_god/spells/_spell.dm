/datum/action/innate/hog_cult
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	background_icon_state = "bg_demon"
	buttontooltipstyle = "cult"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	var/datum/antagonist/hog/antag_datum
	var/charges = 1
	var/obj/item/melee/hog_magic/godhand
	var/hand_type = FALSE

/datum/action/innate/hog_cult/IsAvailable()
	if(!IS_HOG_CULTIST(owner) || IS_HOG_CULTIST(owner) != antag_datum || owner.incapacitated())
		return FALSE
	return ..()

/datum/action/innate/hog_cult/Grant(mob/living/owner, datum/antagonist/hog/ownr)
	antag_datum = ownr
	..()
	button.locked = TRUE
	button.ordered = FALSE

/datum/action/innate/hog_cult/Remove()
	if(antag_datum)
		antag_datum.magic -= src
	..()

/datum/action/innate/hog_cult/Activate()
	if(hand_type) //If this spell flows from the hand
		if(!godhand)
			godhand = new hand_type(owner, src)
			if(!owner.put_in_hands(godhand))
				qdel(godhand)
				godhand = null
				to_chat(owner, span_warning("You have no empty hand for invoking magic!"))
				return
			return
		if(godhand)
			qdel(godhand)
			godhand = null
			to_chat(owner, span_warning("You snuff out the spell, saving it for later."))

/datum/hog_spell_preparation
	var/name = "Prepare Nothing"
	var/description = "Kinda useless thingie it doesn't prepare anything don't do this please it will be just a waste of time and your energy."
	var/cost = 40
	var/p_time = 3 SECONDS 
	var/datum/action/innate/hog_cult/poggy = /datum/action/innate/hog_cult

/datum/hog_spell_preparation/proc/confirm(mob/user, datum/antagonist/hog/antag_datum)
	var/confirm = alert(user, "[description] It will cost [cost] energy.", "[name]", "Yes", "No")
	if(confirm == "No")
		return FALSE
	if(cost > antag_datum.energy)
		to_chat(user,span_warning("You don't have enough energy to prepare this spell!"))
		return FALSE
	return TRUE

/datum/hog_spell_preparation/proc/on_prepared(mob/user, datum/antagonist/hog/antag_datum, obj/item/hog_item/book/tome)
	if(cost > antag_datum.energy)
		return
	antag_datum.get_energy(-cost)
	give_spell(user, antag_datum)

/datum/hog_spell_preparation/proc/give_spell(mob/user, datum/antagonist/hog/antag_datum)
	var/datum/action/innate/hog_cult/new_spell = new poggy(user)
	new_spell.Grant(user, antag_datum)
	antag_datum.magic += new_spell

/obj/item/melee/hog_magic
	name = "\improper hand of god" ///Ahahaha joke
	desc = "A cool, magic hand. If you ask, i want to have one for myself."
	icon = 'icons/obj/wizard.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "disintegrate"
	item_state = "disintegrate"
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	var/uses = 1
	var/datum/antagonist/hog/antag
	var/datum/action/innate/hog_cult/parent

/obj/item/melee/hog_magic/New(loc, spell)
	parent = spell
	antag = parent.antag_datum
	uses = parent.charges
	..()

/obj/item/melee/hog_magic/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/melee/hog_magic/Destroy()
	if(!QDELETED(parent))
		if(uses <= 0)
			parent.godhand = null
			qdel(parent)
			parent = null
		else
			parent.hand_magic = null
			parent.charges = uses
	..()