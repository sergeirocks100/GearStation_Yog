/datum/job/atmos
	title = "Atmospheric Technician"
	flag = ATMOSTECH
	department_head = list("Chief Engineer")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	alt_titles = list("Life-support Technician", "Fire Suppression Specialist", "Atmospherics Trainee", "Environmental Maintainer")

	outfit = /datum/outfit/job/atmos

	access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_MECH_ENGINE,
									ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_ATMOSPHERICS, ACCESS_MAINT_TUNNELS, ACCESS_CONSTRUCTION, ACCESS_MECH_ENGINE, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_ENG
	display_order = JOB_DISPLAY_ORDER_ATMOSPHERIC_TECHNICIAN

	changed_maps = list("OmegaStation", "EclipseStation")

/datum/job/atmos/proc/OmegaStationChanges()
	total_positions = 3
	supervisors = "the captain and the head of personnel"

/datum/job/atmos/proc/EclipseStationChanges()
	total_positions = 3
	spawn_positions = 3

/datum/outfit/job/atmos
	name = "Atmospheric Technician"
	jobtype = /datum/job/atmos

	pda_type = /obj/item/pda/atmos

	belt = /obj/item/storage/belt/utility/atmostech
	ears = /obj/item/radio/headset/headset_eng
	uniform = /obj/item/clothing/under/rank/atmospheric_technician
	uniform_skirt = /obj/item/clothing/under/rank/atmospheric_technician/skirt
	r_pocket = /obj/item/analyzer

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/engineer
	backpack_contents = list(/obj/item/modular_computer/tablet/pda/preset/basic/atmos=1)

	pda_slot = SLOT_L_STORE

/datum/outfit/job/atmos/rig
	name = "Atmospheric Technician (Hardsuit)"

	mask = /obj/item/clothing/mask/gas
	suit = /obj/item/clothing/suit/space/hardsuit/engine/atmos
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = SLOT_S_STORE
