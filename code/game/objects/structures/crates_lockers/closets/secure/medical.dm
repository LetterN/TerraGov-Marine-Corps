/obj/structure/closet/secure_closet/medical1
	name = "Medicine Closet"
	desc = "Filled with medical junk."
	icon_state = "secure_locked_medical_white"
	icon_closed = "secure_closed_medical_white"
	icon_locked = "secure_locked_medical_white"
	icon_opened = "secure_open_medical_white"
	icon_broken = "secure_locked_medical_white"
	icon_off = "secure_closed_medical_white"
	req_access = list(ACCESS_MARINE_MEDBAY)


	New()
		..()
		sleep(2)
		new /obj/item/weapon/storage/box/autoinjectors(src)
		new /obj/item/weapon/storage/box/syringes(src)
		new /obj/item/weapon/reagent_containers/dropper(src)
		new /obj/item/weapon/reagent_containers/dropper(src)
		new /obj/item/weapon/reagent_containers/glass/beaker(src)
		new /obj/item/weapon/reagent_containers/glass/beaker(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/inaprovaline(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/inaprovaline(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/antitoxin(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/antitoxin(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/spaceacillin(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/kelotane(src)
		new /obj/item/weapon/storage/box/pillbottles(src)
		return



/obj/structure/closet/secure_closet/medical2
	name = "Anesthetic"
	desc = "Used to knock people out."
	icon_state = "secure_locked_medical_white"
	icon_closed = "secure_closed_medical_white"
	icon_locked = "secure_locked_medical_white"
	icon_opened = "secure_open_medical_white"
	icon_broken = "secure_locked_medical_white"
	icon_off = "secure_closed_medical_white"
	req_access = list(ACCESS_MARINE_MEDBAY)


	New()
		..()
		sleep(2)
		new /obj/item/weapon/tank/anesthetic(src)
		new /obj/item/weapon/tank/anesthetic(src)
		new /obj/item/weapon/tank/anesthetic(src)
		new /obj/item/clothing/mask/breath/medical(src)
		new /obj/item/clothing/mask/breath/medical(src)
		new /obj/item/clothing/mask/breath/medical(src)
		return



/obj/structure/closet/secure_closet/medical3
	name = "Medical Doctor's Locker"
	req_access = list(ACCESS_MARINE_MEDBAY)
	icon_state = "secure_locked_medical_white"
	icon_closed = "secure_closed_medical_white"
	icon_locked = "secure_locked_medical_white"
	icon_opened = "secure_open_medical_white"
	icon_broken = "secure_locked_medical_white"
	icon_off = "secure_closed_medical_white"

	New()
		..()
		sleep(2)
		if(prob(50))
			new /obj/item/weapon/storage/backpack/medic(src)
		else
			new /obj/item/weapon/storage/backpack/satchel_med(src)
		new /obj/item/clothing/under/rank/nursesuit (src)
		new /obj/item/clothing/head/nursehat (src)
		switch(pick("blue", "green", "purple"))
			if ("blue")
				new /obj/item/clothing/under/rank/medical/blue(src)
				new /obj/item/clothing/head/surgery/blue(src)
			if ("green")
				new /obj/item/clothing/under/rank/medical/green(src)
				new /obj/item/clothing/head/surgery/green(src)
			if ("purple")
				new /obj/item/clothing/under/rank/medical/purple(src)
				new /obj/item/clothing/head/surgery/purple(src)
		switch(pick("blue", "green", "purple"))
			if ("blue")
				new /obj/item/clothing/under/rank/medical/blue(src)
				new /obj/item/clothing/head/surgery/blue(src)
			if ("green")
				new /obj/item/clothing/under/rank/medical/green(src)
				new /obj/item/clothing/head/surgery/green(src)
			if ("purple")
				new /obj/item/clothing/under/rank/medical/purple(src)
				new /obj/item/clothing/head/surgery/purple(src)
		new /obj/item/clothing/under/rank/medical(src)
		new /obj/item/clothing/under/rank/nurse(src)
		new /obj/item/clothing/under/rank/orderly(src)
		new /obj/item/clothing/suit/storage/labcoat(src)
		new /obj/item/clothing/suit/storage/fr_jacket(src)
		new /obj/item/clothing/shoes/white(src)
//		new /obj/item/weapon/cartridge/medical(src)
		if(z && (z == 3 || z == 4))
			new /obj/item/device/radio/headset/almayer/doc(src)
		return



/obj/structure/closet/secure_closet/CMO
	name = "Chief Medical Officer's Locker"
	req_access = list(ACCESS_MARINE_CMO)
	icon_state = "cmosecure1"
	icon_closed = "cmosecure"
	icon_locked = "cmosecure1"
	icon_opened = "cmosecureopen"
	icon_broken = "cmosecurebroken"
	icon_off = "cmosecureoff"

	New()
		..()
		sleep(2)
		if(prob(50))
			new /obj/item/weapon/storage/backpack/medic(src)
		else
			new /obj/item/weapon/storage/backpack/satchel_med(src)
		new /obj/item/clothing/suit/bio_suit/cmo(src)
		new /obj/item/clothing/head/bio_hood/cmo(src)
		new /obj/item/clothing/shoes/white(src)
		switch(pick("blue", "green", "purple"))
			if ("blue")
				new /obj/item/clothing/under/rank/medical/blue(src)
				new /obj/item/clothing/head/surgery/blue(src)
			if ("green")
				new /obj/item/clothing/under/rank/medical/green(src)
				new /obj/item/clothing/head/surgery/green(src)
			if ("purple")
				new /obj/item/clothing/under/rank/medical/purple(src)
				new /obj/item/clothing/head/surgery/purple(src)
		new /obj/item/clothing/under/rank/chief_medical_officer(src)
		new /obj/item/clothing/suit/storage/labcoat/cmo(src)
		new /obj/item/weapon/cartridge/cmo(src)
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/shoes/brown	(src)
		new /obj/item/device/radio/headset/almayer/cmo(src)
		new /obj/item/device/flash(src)
		new /obj/item/weapon/reagent_containers/hypospray/tricordrazine(src)
		return



/obj/structure/closet/secure_closet/animal
	name = "Animal Control"
	req_access = list(ACCESS_MARINE_MEDBAY)


	New()
		..()
		sleep(2)
		new /obj/item/device/assembly/signaler(src)
		new /obj/item/device/radio/electropack(src)
		new /obj/item/device/radio/electropack(src)
		new /obj/item/device/radio/electropack(src)
		return



/obj/structure/closet/secure_closet/chemical
	name = "Chemical Closet"
	desc = "Store dangerous chemicals in here."
	icon_state = "secure_locked_medical_white"
	icon_closed = "secure_closed_medical_white"
	icon_locked = "secure_locked_medical_white"
	icon_opened = "secure_open_medical_white"
	icon_broken = "secure_locked_medical_white"
	icon_off = "secure_closed_medical_white"
	req_access = list(ACCESS_MARINE_CHEMISTRY)


	New()
		..()
		sleep(2)
		new /obj/item/weapon/storage/box/pillbottles(src)
		new /obj/item/weapon/storage/box/pillbottles(src)
		return

/obj/structure/closet/secure_closet/medical_wall
	name = "First Aid Closet"
	desc = "It's a secure wall-mounted storage unit for first aid supplies."
	icon_state = "medical_wall_locked"
	icon_closed = "medical_wall_unlocked"
	icon_locked = "medical_wall_locked"
	icon_opened = "medical_wall_open"
	icon_broken = "medical_wall_spark"
	icon_off = "medical_wall_off"
	anchored = 1
	density = 0
	wall_mounted = 1
	req_access = list(ACCESS_MARINE_MEDBAY)

/obj/structure/closet/secure_closet/medical_wall/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened