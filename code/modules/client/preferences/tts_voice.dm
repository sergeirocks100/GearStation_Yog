/datum/preference/choiced/tts_voice
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "tts_voice"

/datum/preference/choiced/tts_voice/init_possible_values()
	return GLOB.tts_voices

/datum/preference/choiced/tts_voice/compile_constant_data()
	var/list/data = ..()

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = GLOB.tts_voices_names

	return data

/datum/preference/choiced/tts_voice/apply_to_human(mob/living/carbon/human/target, value)
	target.tts_voice = value
