/datum/controller/subsystem/ticker
	var/selected_lobby_music

/datum/controller/subsystem/ticker/proc/choose_lobby_music()
	var/list/songs = world.file2list("config/title_music/yogs_lobby_music.txt")
	if(!songs.len)
		log_world("There are no songs in config/title_music/yogs_lobby_music.txt, add some!")
		return
	selected_lobby_music = pick(songs)

	if(SSevents.holidays) // What's this? Events are initialized before tickers? Let's do something with that!
		for(var/holidayname in SSevents.holidays)
			var/datum/holiday/holiday = SSevents.holidays[holidayname]
			if(LAZYLEN(holiday.lobby_music))
				selected_lobby_music = pick(holiday.lobby_music)
				break

	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		to_chat(world, "<span class='boldwarning'>Youtube-dl was not configured.</span>")
		log_world("Could not play lobby song because youtube-dl is not configured properly, check the config.")
		return

	var/list/output = world.shelleo("[ytdl] --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height<=360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" -g --no-playlist -- \"[selected_lobby_music]\"")
	var/errorlevel = output[SHELLEO_ERRORLEVEL]
	var/stdout = output[SHELLEO_STDOUT]
	var/stderr = output[SHELLEO_STDERR]

	if(errorlevel)
		to_chat(world, "<span class='boldwarning'>Youtube-dl failed.</span>")
		log_world("Could not play lobby song [selected_lobby_music]: [stderr]")
		return

	return stdout
