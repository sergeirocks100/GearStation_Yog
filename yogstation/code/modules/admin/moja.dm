/mob/living/proc/moja_divulge()
	INVOKE_ASYNC(_moja_divulge())

/mob/living/proc/_moja_divulge()
	visible_message("<span class='warning'>A vortex of violet energies surrounds [src]!</span>", "<span class='velvet'>Your barrier will keep you shielded to a point..</span>")
	visible_message("<span class='danger'>[src] slowly rises into the air, their belongings falling away, and begins to shimmer...</span>", \
						"<span class='velvet big'><b>You begin the removal of your human disguise. You will be completely vulnerable during this time.</b></span>")
	setDir(SOUTH)
	for(var/obj/item/I in src)
		dropItemToGround(I)
	for(var/turf/T in RANGE_TURFS(1, src))
		new/obj/structure/psionic_barrier(T)
	for(var/stage in 1 to 3)
		switch(stage)
			if(1)
				visible_message("<span class='userdanger'>Vibrations pass through the air. [src]'s eyes begin to glow a deep violet.</span>", \
									"<span class='velvet'>Psi floods into your consciousness. You feel your mind growing more powerful... <i>expanding.</i></span>")
				playsound(src, 'yogstation/sound/magic/divulge_01.ogg', 30, 0)
			if(2)
				visible_message("<span class='userdanger'>Gravity fluctuates. Psychic tendrils extend outward and feel blindly around the area.</span>", \
									"<span class='velvet'>Gravity around you fluctuates. You tentatively reach out, feel with your mind.</span>")
				Shake(0, 3, 750) //50 loops in a second times 15 seconds = 750 loops
				playsound(src, 'yogstation/sound/magic/divulge_02.ogg', 40, 0)
			if(3)
				visible_message("<span class='userdanger'>Sigils form along [src]'s body. \His skin blackens as \he glows a blinding purple.</span>", \
									"<span class='velvet'>Your body begins to warp. Sigils etch themselves upon your flesh.</span>")
				animate(src, color = list(rgb(0, 0, 0), rgb(0, 0, 0), rgb(0, 0, 0), rgb(0, 0, 0)), time = 150) //Produces a slow skin-blackening effect
				playsound(src, 'yogstation/sound/magic/divulge_03.ogg', 50, 0)
		if(!do_after(src, 150, target = src))
			visible_message("<span class='warning'>[src] falls to the ground!</span>", "<span class='userdanger'>Your transformation was interrupted!</span>")
			animate(src, color = initial(src.color), pixel_y = initial(src.pixel_y), time = 10)
			return
	playsound(src, 'yogstation/sound/magic/divulge_ending.ogg', 50, 0)
	visible_message("<span class='userdanger'>[src] rises into the air, crackling with power!</span>", "<span class='velvet bold'>Your mind...! can't--- THINK--</span>")
	animate(src, pixel_y = src.pixel_y + 8, time = 60)
	sleep(45)
	Shake(5, 5, 110)
	for(var/i in 1 to 20)
		to_chat(src, "<span class='velvet bold'>[pick("I- I- I-", "Mind-", "Sigils-", "Can't think-", "<i>POWER-</i>","<i>TAKE-</i>", "M-M-MOOORE-")]</span>")
		sleep(1.1) //Spooky flavor message spam
	visible_message("<span class='userdanger'>A tremendous shockwave emanates from [src]!</span>", "<span class='velvet big'><b>YOU ARE FREE!!</b></span>")
	playsound(src, 'yogstation/sound/magic/divulge_end.ogg', 50, 0)
	animate(src, color = initial(color), pixel_y = initial(pixel_y), time = 30)
	for(var/mob/living/L in view(7, src))
		if(L == src)
			continue
		L.flash_act(1, 1)
		L.Knockdown(50)
	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		H.make_moja()
	else
		var/mob/living/carbon/human/moja/moja = new /mob/living/carbon/human/moja(src.loc)
		moja.ckey = src.ckey
		qdel(src)

/mob/living/proc/moja_burst(new_key)
	var/mob/living/carbon/human/moja/moja = new /mob/living/carbon/human/moja(src.loc)
	moja.ckey = (new_key ? new_key : ckey)
	gib()

/mob/living/carbon/human/moja/Initialize()
	. = ..()
	make_moja()

/mob/living/carbon/human/proc/make_moja()
	if(!ishumanbasic(src))
		set_species(/datum/species/human)
	real_name = "Moja Manley"
	name = real_name
	gender = "male"
	age = 54
	eye_color = "630"
	var/obj/item/organ/eyes/organ_eyes = getorgan(/obj/item/organ/eyes)
	if(organ_eyes)
		organ_eyes.eye_color = eye_color
		organ_eyes.old_eye_color = eye_color
	hair_color = "888"
	facial_hair_color = "876"

	skin_tone = "asian2"
	hair_style = "Balding Hair"
	facial_hair_style = "Beard (Neckbeard)"
	underwear = "Nude"
	undershirt = "Nude"
	socks = "Nude"
	backbag = "Department Satchel"
	update_body()
	update_hair()
	update_body_parts()
