#define LINKIFY_READY(string, value) "<a href='byond://?src=[REF(src)];ready=[value]'>[string]</a>"

/mob/new_player
	var/ready = PLAYER_NOT_READY
	var/spawning = FALSE
	universal_speak = TRUE

	invisibility = INVISIBILITY_MAXIMUM

	stat = DEAD

	density = FALSE
	canmove = FALSE
	anchored = TRUE

	var/mob/living/new_character	//for instant transfer once the round is set up


/mob/new_player/Initialize()
	if(client && SSticker.state == GAME_STATE_STARTUP)
		var/obj/screen/splash/S = new(client, TRUE, TRUE)
		S.Fade(TRUE)

	GLOB.total_players++
	return ..()


/mob/new_player/Destroy()
	GLOB.total_players--
	return ..()


/mob/new_player/proc/version_check()
	if(client.byond_version < world.byond_version)
		to_chat(client, "<span class='warning'>Your version of Byond differs from the server (v[world.byond_version].[world.byond_build]). You may experience graphical glitches, crashes, or other errors. You will be disconnected until your version matches or exceeds the server version.<br> \
		Direct Download (Windows Installer): http://www.byond.com/download/build/[world.byond_version]/[world.byond_version].[world.byond_build]_byond.exe <br> \
		Other versions (search for [world.byond_build] or higher): http://www.byond.com/download/build/[world.byond_version]</span>")

		qdel(client)


/mob/new_player/proc/new_player_panel()
	var/output = "<center><p><a href='byond://?src=[REF(src)];show_preferences=1'>Setup Character</A></p>"

	if(!SSticker?.mode || SSticker.current_state <= GAME_STATE_PREGAME)
		switch(ready)
			if(PLAYER_NOT_READY)
				output += "<p>\[ [LINKIFY_READY("Ready", PLAYER_READY_TO_PLAY)] | <b>Not Ready</b> | [LINKIFY_READY("Observe", PLAYER_READY_TO_OBSERVE)] \]</p>"
			if(PLAYER_READY_TO_PLAY)
				output += "<p>\[ <b>Ready</b> | [LINKIFY_READY("Not Ready", PLAYER_NOT_READY)] | [LINKIFY_READY("Observe", PLAYER_READY_TO_OBSERVE)] \]</p>"
			if(PLAYER_READY_TO_OBSERVE)
				output += "<p>\[ [LINKIFY_READY("Ready", PLAYER_READY_TO_PLAY)] | [LINKIFY_READY("Not Ready", PLAYER_NOT_READY)] | <b> Observe </b> \]</p>"
	else
		output += "<p><a href='byond://?src=[REF(src)];manifest=1'>View the Crew Manifest</A></p>"
		output += "<p><a href='byond://?src=[REF(src)];late_join=1'>Join the TGMC!</A></p>"
		output += "<p><a href='byond://?src=[REF(src)];late_join_xeno=1'>Join the Hive!</A></p>"
		output += "<p>[LINKIFY_READY("Observe", PLAYER_READY_TO_OBSERVE)]</p>"

	if(!IsGuestKey(key))
		if(SSdbcore.Connect())
			var/isadmin = FALSE
			if(check_rights(R_ADMIN, FALSE))
				isadmin = TRUE
			var/datum/DBQuery/query_get_new_polls = SSdbcore.NewQuery("SELECT id FROM [format_table_name("poll_question")] WHERE [(isadmin ? "" : "adminonly = false AND")] Now() BETWEEN starttime AND endtime AND id NOT IN (SELECT pollid FROM [format_table_name("poll_vote")] WHERE ckey = \"[sanitizeSQL(ckey)]\") AND id NOT IN (SELECT pollid FROM [format_table_name("poll_textreply")] WHERE ckey = \"[sanitizeSQL(ckey)]\")")
			if(query_get_new_polls.Execute())
				var/newpoll = FALSE
				if(query_get_new_polls.NextRow())
					newpoll = TRUE

				if(newpoll)
					output += "<p><b><a href='byond://?src=[REF(src)];showpoll=1'>Show Player Polls</A> (NEW!)</b></p>"
				else
					output += "<p><a href='byond://?src=[REF(src)];showpoll=1'>Show Player Polls</A></p>"
			qdel(query_get_new_polls)
			if(QDELETED(src))
				return

	output += "</center>"

	var/datum/browser/popup = new(src, "playersetup", "<div align='center'>New Player Options</div>", 250, 265)
	popup.set_window_options("can_close=0")
	popup.set_content(output)
	popup.open(FALSE)


/mob/new_player/Stat()
	. = ..()

	if(!SSticker)
		return

	if(statpanel("Stats"))
		if(SSticker.hide_mode)
			stat("Game Mode:", "TerraGov Marine Corps")
		else
			stat("Game Mode:", "[GLOB.master_mode]")

		if(SSticker.current_state == GAME_STATE_PREGAME)
			stat("Time To Start:", "[going ? SSticker.GetTimeLeft() : "(DELAYED)"]")
			stat("Players: [GLOB.total_players]", "Players Ready: [GLOB.ready_players]")
			for(var/mob/new_player/player in GLOB.player_list)
				stat("[player.key]", player.ready ? "Playing" : "")

/mob/new_player/Topic(href, href_list[])
	if(src != usr)
		return FALSE

	if(!client)
		return FALSE

	if(href_list["show_preferences"])
		client.prefs.ShowChoices(src)
		return TRUE

	if(href_list["ready"])
		var/tready = text2num(href_list["ready"])
		//Avoid updating ready if we're after PREGAME (they should use latejoin instead)
		//This is likely not an actual issue but I don't have time to prove that this
		//no longer is required
		if(SSticker.current_state <= GAME_STATE_PREGAME)
			ready = tready
			if(ready)
				GLOB.ready_players++
			else
				GLOB.ready_players--
		//if it's post initialisation and they're trying to observe we do the needful
		if(!SSticker.current_state < GAME_STATE_PREGAME && tready == PLAYER_READY_TO_OBSERVE)
			ready = tready
			make_me_an_observer()
			return

	if(href_list["refresh"])
		src << browse(null, "window=playersetup") //closes the player setup window
		new_player_panel()

	if(href_list["late_join"])
		if(!SSticker || !SSticker.IsRoundInProgress())
			to_chat(usr, "<span class='danger'>The round is either not ready, or has already finished...</span>")
			return

		if(href_list["late_join"] == "override")
			LateChoices()
			return

		//if(SSticker.queued_players.len || (relevant_cap && living_player_count() >= relevant_cap && !(ckey(key) in GLOB.admin_datums)))
		//	to_chat(usr, "<span class='danger'>[CONFIG_GET(string/hard_popcap_message)]</span>")

		//	var/queue_position = SSticker.queued_players.Find(usr)
		//	if(queue_position == 1)
		//		to_chat(usr, "<span class='notice'>You are next in line to join the game. You will be notified when a slot opens up.</span>")
		//	else if(queue_position)
		//		to_chat(usr, "<span class='notice'>There are [queue_position-1] players in front of you in the queue to join the game.</span>")
		//	else
		//		SSticker.queued_players += usr
		//		to_chat(usr, "<span class='notice'>You have been added to the queue to join the game. Your position in queue is [SSticker.queued_players.len].</span>")
		//	return   //soon(TM)
		LateChoices()


	if(href_list["late_join_xeno"])
		if(!SSticker || !SSticker.IsRoundInProgress())
			to_chat(src, "<span class='warning'>The round is either not ready, or has already finished.</span>")
			return

		switch(alert("Would you like to try joining as a burrowed larva or as a living xenomorph?", "Select", "Burrowed Larva", "Living Xenomorph", "Cancel"))
			if("Burrowed Larva")
				if(SSticker.mode.check_xeno_late_join(src))
					var/mob/living/carbon/Xenomorph/Queen/mother
					mother = SSticker.mode.attempt_to_join_as_larva(src)
					if(mother)
						close_spawn_windows()
						SSticker.mode.spawn_larva(src, mother)

			if("Living Xenomorph")
				if(SSticker.mode.check_xeno_late_join(src))
					var/mob/new_xeno = SSticker.mode.attempt_to_join_as_xeno(src, 0)
					if(new_xeno)
						close_spawn_windows(new_xeno)
						SSticker.mode.transfer_xeno(src, new_xeno)


	if(href_list["manifest"])
		ViewManifest()

	if(href_list["SelectedJob"])

		if(!GLOB.enter_allowed)
			to_chat(usr, "<span class='notice'>There is an administrative lock on entering the game!</span>")
			return
		/*
		if(SSticker.queued_players.len && !(ckey(key) in GLOB.admin_datums))
			if((living_player_count() >= relevant_cap) || (src != SSticker.queued_players[1]))
				to_chat(usr, "<span class='warning'>Server is full.</span>")
				return
		*/

		AttemptLateSpawn(href_list["SelectedJob"])
		return

	if(!ready && href_list["preference"])
		client.prefs.process_link(src, href_list)
	else if(!href_list["late_join"])
		new_player_panel()


	if(href_list["showpoll"])
		handle_player_polling()
		return

	if(href_list["pollid"])
		var/pollid = href_list["pollid"]
		if(istext(pollid))
			pollid = text2num(pollid)
		if(isnum(pollid) && ISINTEGER(pollid))
			poll_player(pollid)
		return

	if(href_list["votepollid"] && href_list["votetype"])
		var/pollid = text2num(href_list["votepollid"])
		var/votetype = href_list["votetype"]
		//lets take data from the user to decide what kind of poll this is, without validating it
		//what could go wrong
		switch(votetype)
			if(POLLTYPE_OPTION)
				var/optionid = text2num(href_list["voteoptionid"])
				if(vote_on_poll(pollid, optionid))
					to_chat(usr, "<span class='notice'>Vote successful.</span>")
				else
					to_chat(usr, "<span class='danger'>Vote failed, please try again or contact an administrator.</span>")
			if(POLLTYPE_TEXT)
				var/replytext = href_list["replytext"]
				if(log_text_poll_reply(pollid, replytext))
					to_chat(usr, "<span class='notice'>Feedback logging successful.</span>")
				else
					to_chat(usr, "<span class='danger'>Feedback logging failed, please try again or contact an administrator.</span>")
			if(POLLTYPE_RATING)
				var/id_min = text2num(href_list["minid"])
				var/id_max = text2num(href_list["maxid"])

				if((id_max - id_min) > 100)	//Basic exploit prevention
					to_chat(usr, "The option ID difference is too big. Please contact administration or the database admin.")
					return

				for(var/optionid = id_min; optionid <= id_max; optionid++)
					if(!isnull(href_list["o[optionid]"]))	//Test if this optionid was replied to
						var/rating
						if(href_list["o[optionid]"] == "abstain")
							rating = null
						else
							rating = text2num(href_list["o[optionid]"])
							if(!isnum(rating) || !ISINTEGER(rating))
								return

						if(!vote_on_numval_poll(pollid, optionid, rating))
							to_chat(usr, "<span class='danger'>Vote failed, please try again or contact an administrator.</span>")
							return
				to_chat(usr, "<span class='notice'>Vote successful.</span>")
			if(POLLTYPE_MULTI)
				var/id_min = text2num(href_list["minoptionid"])
				var/id_max = text2num(href_list["maxoptionid"])

				if((id_max - id_min) > 100)	//Basic exploit prevention
					to_chat(usr, "The option ID difference is too big. Please contact administration or the database admin.")
					return

				for(var/optionid = id_min; optionid <= id_max; optionid++)
					if(!isnull(href_list["option_[optionid]"]))	//Test if this optionid was selected
						var/i = vote_on_multi_poll(pollid, optionid)
						switch(i)
							if(0)
								continue
							if(1)
								to_chat(usr, "<span class='danger'>Vote failed, please try again or contact an administrator.</span>")
								return
							if(2)
								to_chat(usr, "<span class='danger'>Maximum replies reached.</span>")
								break
				to_chat(usr, "<span class='notice'>Vote successful.</span>")
			if(POLLTYPE_IRV)
				if(!href_list["IRVdata"])
					to_chat(src, "<span class='danger'>No ordering data found. Please try again or contact an administrator.</span>")
					return
				var/list/votelist = splittext(href_list["IRVdata"], ",")
				if(!vote_on_irv_poll(pollid, votelist))
					to_chat(src, "<span class='danger'>Vote failed, please try again or contact an administrator.</span>")
					return
				to_chat(src, "<span class='notice'>Vote successful.</span>")


/mob/new_player/proc/make_me_an_observer()
	if(!SSticker || SSticker.current_state == GAME_STATE_STARTUP)
		to_chat(src, "<span class='warning'>The game is still setting up, please try again later.</span>")
		return FALSE

	if(QDELETED(src) || !client)
		ready = PLAYER_NOT_READY
		return FALSE

	if(QDELETED(src) || !client || alert(src,"Are you sure you wish to observe?\nYou will have to wait at least 5 minutes before being able to respawn!","Player Setup","Yes","No") != "Yes")
		ready = PLAYER_NOT_READY
		src << browse(null, "window=playersetup") //closes the player setup window
		new_player_panel()
		return FALSE

	var/mob/dead/observer/observer = new()
	spawning = TRUE

	observer.started_as_observer = TRUE
	close_spawn_windows()
	var/obj/effect/landmark/observer_start/O = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
	to_chat(src, "<span class='notice'>Now teleporting.</span>")
	if (O)
		observer.forceMove(O.loc)
	else
		to_chat(src, "<span class='notice'>Teleporting failed. Ahelp an admin please</span>")
		stack_trace("There's no freaking observer landmark available on this map or you're making observers before the map is initialised")
	observer.key = key
	observer.client = client
	//observer.set_ghost_appearance()
	if(observer.client && observer.client.prefs)
		if(!observer.client.prefs.real_name)
			var/datum/species/species = GLOB.all_species[client.prefs.species] || GLOB.all_species[DEFAULT_SPECIES]
			//what is the probability of this happening anyways
			observer.real_name = species.random_name()
			to_chat(src, "Something went horribly wrong, your name wasn't fetched for some reason so you got a random name")
		else
			observer.real_name = observer.client.prefs.real_name
		observer.name = observer.real_name
	observer.update_icon()
	observer.alpha = 127
	stop_lobby() //lettern, fix this
	QDEL_NULL(mind)
	qdel(src)
	return TRUE

/mob/new_player/proc/AttemptLateSpawn(rank)
	if(src != usr)
		return FALSE

	if(!IsJobAvailable(rank))
		to_chat(usr, "<span class='warning'>Selected job is not available.<span>")
		return FALSE

	if(!SSticker || !SSticker.IsRoundInProgress())
		to_chat(usr, "<span class='warning'>The round is either not ready, or has already finished!<span>")
		return FALSE

	if(!GLOB.enter_allowed)
		to_chat(usr, "<span class='warning'>An administrator has disabled late join spawning.<span>")
		return FALSE

	if(!SSjob.AssignRole(src, rank, TRUE))
		to_chat(usr, "<span class='warning'>Failed to assign selected role.<span>")
		return FALSE

	close_spawn_windows()
	spawning = TRUE

	var/mob/living/character = create_character(TRUE)	//creates the human and transfers vars and mind
	var/equip = SSjob.EquipRank(character, rank, TRUE)
	if(isliving(equip))	//Borgs get borged in the equip, so we need to make sure we handle the new mob.
		character = equip


	var/datum/job/job = SSjob.GetJob(rank)

	if(job && !job.override_latejoin_spawn(character))
		SSjob.SendToLateJoin(character)
		var/obj/screen/splash/Spl = new(character.client, TRUE)
		Spl.Fade(TRUE)

	GLOB.datacore.manifest_inject(character)
	SSticker.minds += character.mind
	SSticker.mode.latejoin_tally += 1

	for(var/datum/squad/sq in SSjob.squads)
		sq.max_engineers = engi_slot_formula(length(GLOB.clients))
		sq.max_medics = medic_slot_formula(length(GLOB.clients))

	if(SSticker.mode.latejoin_larva_drop && SSticker.mode.latejoin_tally >= SSticker.mode.latejoin_larva_drop)
		SSticker.mode.latejoin_tally -= SSticker.mode.latejoin_larva_drop
		SSticker.mode.stored_larva++

	qdel(src)


/mob/new_player/proc/LateChoices()
	var/dat = "<div class='notice'>Round Duration: [DisplayTimeText(world.time - SSticker.round_start_time)]</div><br>"

	if(SSevacuation)
		switch(SSevacuation.evac_status)
			if(EVACUATION_STATUS_INITIATING)
				dat += "<font color='red'><b>The [CONFIG_GET(string/ship_name)] is being evacuated.</b></font><br>"
			if(EVACUATION_STATUS_COMPLETE)
				dat += "<font color='red'>The [CONFIG_GET(string/ship_name)] has undergone evacuation.</font><br>"

	dat += "<div class='clearBoth'>Choose from the following open positions:</div><br>"
	dat += "<div class='jobs'><div class='jobsColumn'>"
	var/datum/job/J
	for(var/i in sortList(SSjob.occupations, /proc/cmp_job_display_asc))
		J = i
		if(!(J.title in JOBS_REGULAR_ALL))
			continue
		if((J.current_positions >= J.spawn_positions) && J.spawn_positions != -1)
			continue
		var/active = 0
		//Only players with the job assigned and AFK for less than 10 minutes count as active
		for(var/mob/M in GLOB.player_list)
			if(M.mind && M.client && M.mind.assigned_role == J.title && M.client.inactivity <= 10 MINUTES)
				active++
		dat += "<a href='byond://?src=[REF(src)];SelectedJob=[J.title]'>[J.title] ([J.current_positions]) (Active: [active])</a><br>"

	dat += "</div></div>"
	var/datum/browser/popup = new(src, "latechoices", "<div align='center'>Join the TGMC</div>", 430, 450)
	popup.add_stylesheet("playeroptions", 'html/browser/playeroptions.css')
	popup.set_content(dat)
	popup.open(FALSE)


/mob/new_player/proc/ViewManifest()
	var/dat = GLOB.datacore.get_manifest(ooc = TRUE)

	var/datum/browser/popup = new(src, "manifest", "<div align='center'>Crew Manifest</div>", 400, 420)
	popup.set_content(dat)
	popup.open(FALSE)


/mob/new_player/Move()
	return FALSE


/mob/new_player/proc/close_spawn_windows()
	src << browse(null, "window=latechoices") //closes late choices window
	src << browse(null, "window=playersetup") //closes the player setup window
	src << browse(null, "window=preferences") //closes job selection
	src << browse(null, "window=mob_occupation")
	stop_lobby()


/mob/new_player/proc/stop_lobby() //lazyfix i know, will pr sound magic after this
	src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // Stops lobby music.


/mob/new_player/get_species()
	var/datum/species/chosen_species
	if(client.prefs.species)
		chosen_species = GLOB.all_species[client.prefs.species]
	if(!chosen_species)
		return "Human"
	return chosen_species


/mob/new_player/get_gender()
	if(!client?.prefs)
		. = ..()
	return client.prefs.gender

/mob/new_player/hear_say(message, verb = "says", datum/language/language = null, alt_name = "", italics = FALSE, mob/speaker = null)
	return


/mob/new_player/hear_radio(message, verb = "says", datum/language/language = null, part_a, part_b, mob/speaker = null, hard_to_hear = FALSE)
	return


/mob/new_player/proc/create_character(transfer_after)
	spawning = TRUE
	close_spawn_windows()

	var/mob/living/carbon/human/H = new(loc)

	if(!is_banned_from(ckey, "Appearance"))
		client.prefs.copy_to(H)

	if(mind)
		if(transfer_after)
			mind.late_joiner = TRUE
		mind.active = FALSE					//we wish to transfer the key manually
		mind.transfer_to(H)					//won't transfer key since the mind is not active

	. = H
	new_character = .
	if(transfer_after)
		transfer_character()


/mob/new_player/proc/transfer_character()
	. = new_character
	if(.)
		new_character.key = key		//Manually transfer the key to log them in
		new_character = null
		qdel(src)


/mob/new_player/proc/IsJobAvailable(rank, latejoin = FALSE)
	var/datum/job/job = SSjob.GetJob(rank)
	if(!job)
		return FALSE
	if((job.current_positions >= job.total_positions) && job.total_positions != -1)
		for(var/datum/job/J in SSjob.occupations)
			if(J && J.current_positions < J.total_positions && J.title != job.title)
				return FALSE

	if(jobban_isbanned(src, rank))
		return FALSE

	if(is_banned_from(ckey, rank))
		return FALSE

	if(QDELETED(src))
		return FALSE

	if(!job.player_old_enough(client))
		return FALSE

	if(job.required_playtime_remaining(client))
		return FALSE

	if(latejoin && !job.special_check_latejoin(client))
		return FALSE

	return TRUE
