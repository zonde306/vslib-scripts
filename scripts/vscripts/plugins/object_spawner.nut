::ObjectSpawner2 <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,

		// 加载的延迟(秒)
		LoadDelay = 1.0,

		// 是否开启自动加载
		AutoLoad = true,
		
		// 是否开启自动保存
		AutoSave = true,
		
		// 抓住的物体的移动速度
		GrabSpeed = 10.0,
		
		// 抓住的物体的旋转速度
		GrabRototing = 15.0,
		
		// 需要站在板块上距离多少之内才触发效果
		GroundDistance = 50.0,
		
		// 寻找实体的范围
		FindEntityRange = 5.0,
	},
	
	ConfigVar = {},
	
	// 普通的实体
	NamedObject =
	[
		// 手枪
		{cmd = "pis", ent = "weapon_pistol_spawn", ammo = 999, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "pistol", ent = "weapon_pistol_spawn", ammo = 999, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "mag", ent = "weapon_pistol_magnum_spawn", ammo = 999, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "magnum", ent = "weapon_pistol_magnum_spawn", ammo = 999, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		
		// 冲锋枪
		{cmd = "smg", ent = "weapon_smg_spawn", ammo = 650, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "smgs", ent = "weapon_smg_silenced_spawn", ammo = 650, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "silent", ent = "weapon_smg_silenced_spawn", ammo = 650, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "silenced", ent = "weapon_smg_silenced_spawn", ammo = 650, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "mp5", ent = "weapon_smg_mp5_spawn", ammo = 650, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		
		// 霰弹枪
		{cmd = "pump", ent = "weapon_pumpshotgun_spawn", ammo = 56, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "chrome", ent = "weapon_shotgun_chrome_spawn", ammo = 56, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "chr", ent = "weapon_shotgun_chrome_spawn", ammo = 56, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "auto", ent = "weapon_autoshotgun_spawn", ammo = 90, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "xm1014", ent = "weapon_autoshotgun_spawn", ammo = 90, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "spas", ent = "weapon_shotgun_spas_spawn", ammo = 90, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		
		// 步枪
		{cmd = "m16", ent = "weapon_rifle_spawn", ammo = 360, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "m4", ent = "weapon_rifle_spawn", ammo = 360, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "ak47", ent = "weapon_rifle_ak47_spawn", ammo = 360, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "ak", ent = "weapon_rifle_ak47_spawn", ammo = 360, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "des", ent = "weapon_rifle_desert_spawn", ammo = 360, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "dst", ent = "weapon_rifle_desert_spawn", ammo = 360, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "dsr", ent = "weapon_rifle_desert_spawn", ammo = 360, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "sg552", ent = "weapon_rifle_sg552_spawn", ammo = 360, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "552", ent = "weapon_rifle_sg552_spawn", ammo = 360, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "m60", ent = "weapon_rifle_m60_spawn", ammo = 0, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "m249", ent = "weapon_rifle_m60_spawn", ammo = 0, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "gl", ent = "weapon_grenade_launcher_spawn", ammo = 30, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "grenade", ent = "weapon_grenade_launcher_spawn", ammo = 30, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "launcher", ent = "weapon_grenade_launcher_spawn", ammo = 30, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		
		// 狙击枪
		{cmd = "hunt", ent = "weapon_hunting_rifle_spawn", ammo = 120, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "hunting", ent = "weapon_hunting_rifle_spawn", ammo = 120, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "mil", ent = "weapon_sniper_military_spawn", ammo = 180, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "g3sg1", ent = "weapon_sniper_military_spawn", ammo = 180, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "sg550", ent = "weapon_sniper_military_spawn", ammo = 180, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "scout", ent = "weapon_sniper_scout_spawn", ammo = 180, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "sco", ent = "weapon_sniper_scout_spawn", ammo = 180, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "awp", ent = "weapon_sniper_awp_spawn", ammo = 180, count = 1, model = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		
		// 投掷武器
		{cmd = "pipe", ent = "weapon_pipe_bomb_spawn", ammo = 1, count = 1, model = null, pos = Vector(0, 0, 5), ang = null},
		{cmd = "bomb", ent = "weapon_pipe_bomb_spawn", ammo = 1, count = 1, model = null, pos = Vector(0, 0, 5), ang = null},
		{cmd = "pipebomb", ent = "weapon_pipe_bomb_spawn", ammo = 1, count = 1, model = null, pos = Vector(0, 0, 5), ang = null},
		{cmd = "molo", ent = "weapon_molotov_spawn", ammo = 1, count = 1, model = null, pos = Vector(0, 0, 4), ang = null},
		{cmd = "molotov", ent = "weapon_molotov_spawn", ammo = 1, count = 1, model = null, pos = Vector(0, 0, 4), ang = null},
		{cmd = "bile", ent = "weapon_vomitjar_spawn", ammo = 1, count = 1, model = null, pos = Vector(0, 0, 11), ang = null},
		{cmd = "vomit", ent = "weapon_vomitjar_spawn", ammo = 1, count = 1, model = null, pos = Vector(0, 0, 11), ang = null},
		{cmd = "vomitjar", ent = "weapon_vomitjar_spawn", ammo = 1, count = 1, model = null, pos = Vector(0, 0, 11), ang = null},
		
		// 医疗品
		{cmd = "fak", ent = "weapon_first_aid_kit_spawn", ammo = 1, count = 1, model = null, pos = Vector(0, 0, 2), ang = null},
		{cmd = "defib", ent = "weapon_defibrillator_spawn", ammo = 1, count = 1, model = null, pos = null, ang = null},
		{cmd = "pill", ent = "weapon_pain_pills_spawn", ammo = 1, count = 1, model = null, pos = null, ang = null},
		{cmd = "pain", ent = "weapon_pain_pills_spawn", ammo = 1, count = 1, model = null, pos = null, ang = null},
		{cmd = "pills", ent = "weapon_pain_pills_spawn", ammo = 1, count = 1, model = null, pos = null, ang = null},
		{cmd = "adren", ent = "weapon_adrenaline_spawn", ammo = 1, count = 1, model = null, pos = Vector(0, 0, 2), ang = null},
		
		// 升级包
		{cmd = "fire", ent = "weapon_upgradepack_incendiary_spawn", ammo = 1, count = 1, model = null, pos = null, ang = null},
		{cmd = "exp", ent = "weapon_upgradepack_explosive_spawn", ammo = 1, count = 1, model = null, pos = null, ang = null},
		{cmd = "ufire", ent = "upgrade_ammo_incendiary", ammo = 1, count = 4, model = null, pos = null, ang = null},
		{cmd = "uexp", ent = "upgrade_ammo_explosive", ammo = 1, count = 4, model = null, pos = null, ang = null},
		{cmd = "laser", ent = "upgrade_laser_sight", ammo = 1, count = 4, model = null, pos = null, ang = null},
		
		// 近战武器
		{cmd = "cha", ent = "weapon_chainsaw_spawn", ammo = 999, count = 1, model = null, pos = Vector(0, 0, 3), ang = null},
		{cmd = "saw", ent = "weapon_chainsaw_spawn", ammo = 999, count = 1, model = null, pos = Vector(0, 0, 3), ang = null},
		{cmd = "ball", ent = "weapon_melee_spawn", ammo = null, count = 1, model = "baseball_bat", pos = null, ang = QAngle(0, 0, 90)},
		{cmd = "cri", ent = "weapon_melee_spawn", ammo = null, count = 1, model = "cricket_bat", pos = null, ang = QAngle(0, 0, 90)},
		{cmd = "gui", ent = "weapon_melee_spawn", ammo = null, count = 1, model = "guitar", pos = null, ang = QAngle(0, 0, 90)},
		{cmd = "axe", ent = "weapon_melee_spawn", ammo = null, count = 1, model = "fireaxe", pos = null, ang = QAngle(0, 0, 90)},
		{cmd = "pan", ent = "weapon_melee_spawn", ammo = null, count = 1, model = "frying_pan", pos = null, ang = QAngle(0, 0, 90)},
		{cmd = "kat", ent = "weapon_melee_spawn", ammo = null, count = 1, model = "katana", pos = null, ang = QAngle(0, 0, 90)},
		{cmd = "knife", ent = "weapon_melee_spawn", ammo = null, count = 1, model = "knife", pos = null, ang = QAngle(0, 0, 90)},
		{cmd = "kni", ent = "weapon_melee_spawn", ammo = null, count = 1, model = "knife", pos = null, ang = QAngle(0, 0, 90)},
		{cmd = "mac", ent = "weapon_melee_spawn", ammo = null, count = 1, model = "machete", pos = null, ang = QAngle(0, 0, 90)},
		{cmd = "ton", ent = "weapon_melee_spawn", ammo = null, count = 1, model = "tonfa", pos = null, ang = QAngle(0, 0, 90)},
		{cmd = "golf", ent = "weapon_melee_spawn", ammo = null, count = 1, model = "golfclub", pos = null, ang = QAngle(0, 0, 90)},
		
		// 携带物品
		{cmd = "gas", ent = "weapon_gascan", ammo = null, count = 1, model = null, pos = Vector(0, 0, 16), ang = null},
		{cmd = "prop", ent = "weapon_propanetank", ammo = null, count = 1, model = null, pos = Vector(0, 0, 16), ang = null},
		{cmd = "oxy", ent = "weapon_oxygentank", ammo = null, count = 1, model = null, pos = null, ang = null},
		{cmd = "fw", ent = "weapon_fireworkcrate", ammo = null, count = 1, model = null, pos = Vector(0, 0, 4), ang = null},
		// {cmd = "cola", ent = "weapon_cola_bottles", ammo = null, count = 1, model = null, pos = null, ang = null},
		// {cmd = "gnome", ent = "weapon_gnome", ammo = null, count = 1, model = null, pos = Vector(0, 0, 11), ang = null},
		{cmd = "cola", ent = "prop_physics", ammo = null, count = 1, model = "models/w_models/weapons/w_cola.mdl", pos = null, ang = null},
		{cmd = "gnome", ent = "prop_physics", ammo = null, count = 1, model = "models/props_junk/gnome.mdl", pos = Vector(0, 0, 11), ang = null},
		
		// 杂项
		{cmd = "bar", ent = "prop_fuel_barrel", ammo = null, count = null, model = null, pos = null, ang = null},
		{cmd = "mg3", ent = "prop_mounted_machine_gun", ammo = null, count = null, model = null, pos = null, ang = null},
		{cmd = "mg2", ent = "prop_minigun", ammo = null, count = null, model = null, pos = null, ang = null},
		{cmd = "mg", ent = "prop_minigun_l4d1", ammo = null, count = null, model = null, pos = null, ang = null},
		{cmd = "ammo", ent = "weapon_ammo_spawn", ammo = null, count = 1, model = "models/props/terror/ammo_stack.mdl", pos = null, ang = null},
		{cmd = "ammo1", ent = "weapon_ammo_spawn", ammo = null, count = 1, model = "models/props_unique/spawn_apartment/coffeeammo.mdl", pos = null, ang = null},
		{cmd = "ammo2", ent = "weapon_ammo_spawn", ammo = null, count = 1, model = "models/props/terror/Ammo_Can.mdl", pos = null, ang = null},
		{cmd = "ammo3", ent = "weapon_ammo_spawn", ammo = null, count = 1, model = "models/props/de_prodigy/ammo_can_02.mdl", pos = null, ang = null},
		{cmd = "rescue", ent = "info_survivor_rescue", ammo = null, count = null, model = "models/editor/playerstart.mdl", pos = null, ang = null},
		{cmd = "res", ent = "info_survivor_rescue", ammo = null, count = null, model = "models/editor/playerstart.mdl", pos = null, ang = null},
		// {cmd = "zombie", ent = "info_zombie_spawn", ammo = 1, count = null, model = null, pos = null, ang = null},
		// {cmd = "infected", ent = "commentary_zombie_spawner", ammo = 1, count = null, model = null, pos = null, ang = null},
		// {cmd = "rock", ent = "env_rock_launcher", ammo = 1, count = null, model = null, pos = null, ang = null},
		{cmd = "can", ent = "weapon_scavenge_item_spawn", ammo = null, count = null, model = null, pos = null, ang = null},
		
		// 生还者
		{cmd = "nick", ent = "info_l4d1_survivor_spawn", ammo = 0, count = null, model = null, pos = null, ang = null},
		{cmd = "rochelle", ent = "info_l4d1_survivor_spawn", ammo = 1, count = null, model = null, pos = null, ang = null},
		{cmd = "coach", ent = "info_l4d1_survivor_spawn", ammo = 2, count = null, model = null, pos = null, ang = null},
		{cmd = "ellis", ent = "info_l4d1_survivor_spawn", ammo = 3, count = null, model = null, pos = null, ang = null},
		{cmd = "bill", ent = "info_l4d1_survivor_spawn", ammo = 4, count = null, model = null, pos = null, ang = null},
		{cmd = "zoey", ent = "info_l4d1_survivor_spawn", ammo = 5, count = null, model = null, pos = null, ang = null},
		{cmd = "francis", ent = "info_l4d1_survivor_spawn", ammo = 6, count = null, model = null, pos = null, ang = null},
		{cmd = "louis", ent = "info_l4d1_survivor_spawn", ammo = 7, count = null, model = null, pos = null, ang = null},
		
		// 模型
		{cmd = "yzz", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_interiors/dining_table_round.mdl", pos = null, ang = null},
		{cmd = "ymz", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_interiors/coffee_table_oval.mdl", pos = null, ang = null},
		{cmd = "mxz", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props/de_nuke/crate_extralarge.mdl", pos = null, ang = null},
		{cmd = "jc", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_vehicles/police_car_rural.mdl", pos = null, ang = null},
		{cmd = "bed", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_interiors/couch.mdl", pos = null, ang = null},
		{cmd = "bebch", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props/cs_militia/wood_bench.mdl", pos = null, ang = null},
		{cmd = "ljx", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_junk/dumpster.mdl", pos = null, ang = null},
		{cmd = "xp", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_unique/escalatortall.mdl", pos = null, ang = null},
		{cmd = "ytd", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_unique/wooden_barricade_gascans.mdl", pos = null, ang = null},
		{cmd = "atm", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_unique/atm01.mdl", pos = null, ang = null},
		{cmd = "ylx", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_interiors/medicalcabinet02.mdl", pos = null, ang = null},
		{cmd = "dz", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props/de_prodigy/concretebags2.mdl", pos = null, ang = null},
		{cmd = "mx", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props/de_nuke/crate_extralarge.mdl", pos = null, ang = null},
		{cmd = "wxd", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props/terror/hamradio.mdl", pos = null, ang = null},
		{cmd = "dtmb", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_interiors/elevator_panel.mdl", pos = null, ang = null},
		{cmd = "yx", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_fairgrounds/amp_plexi.mdl", pos = null, ang = null},
		{cmd = "dyx", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_fairgrounds/amp_stack.mdl", pos = null, ang = null},
		{cmd = "zl", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_urban/fence002_256.mdl", pos = null, ang = null},
		{cmd = "zl2", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_wasteland/exterior_fence002c.mdl", pos = null, ang = null},
		{cmd = "zlx", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_wasteland/exterior_fence002b.mdl", pos = null, ang = null},
		{cmd = "zlz", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_wasteland/exterior_fence002d.mdl", pos = null, ang = null},
		{cmd = "zld", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_wasteland/exterior_fence002e.mdl", pos = null, ang = null},
		{cmd = "slt", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_c17/metalladder001.mdl", pos = null, ang = null},
		{cmd = "slt2", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_c17/metalladder005.mdl", pos = null, ang = null},
		{cmd = "tlt", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_equipment/tablegreenhouse01.mdl", pos = null, ang = null},
		{cmd = "tb", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_urban/fence_cover001_128.mdl", pos = null, ang = null},
		{cmd = "ey", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_fairgrounds/alligator.mdl", pos = null, ang = null},
		{cmd = "dx", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_fairgrounds/elephant.mdl", pos = null, ang = null},
		{cmd = "ft", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props_mall/mall_escalator.mdl", pos = null, ang = null},
		{cmd = "shj", ent = "prop_dynamic_override", ammo = null, count = null, model = "models/props/cs_office/vending_machine.mdl", pos = null, ang = null},
		
		// 带脚本的实体
		{cmd = "mine", ent = "info_item_position", ammo = "Landmine", count = null, model = "entitygroups/landmine_group.nut", pos = null, ang = null},
	],
	
	function FindNamedObjectInfo(name)
	{
		if(name == null || name == "")
			return null;
		
		foreach(object in ::ObjectSpawner2.NamedObject)
		{
			if(object["cmd"] == name)
				return object;
		}
		
		return null;
	},
	
	function FindHeightHammerID()
	{
		::ObjectSpawner2.HeightHammerId = 0;
		
		local hammerId = 0;
		foreach(entity in Objects.All())
		{
			hammerId = entity.GetNetPropInt("m_iHammerID");
			if(hammerId > ::ObjectSpawner2.HeightHammerId)
				::ObjectSpawner2.HeightHammerId = hammerId;
		}
	},
	
	SpawnedEntity = {},
	LastEntity = {},
	HeightHammerId = 0,
	HasDataChanged = false,
	CurrentMapName = "",
	
	function SpawnNamedEntity(name, origin, angles, params = {})
	{
		local objectInfo = ::ObjectSpawner2.FindNamedObjectInfo(name);
		if(objectInfo == null)
			return null;
		
		local entity = null;
		local classname = objectInfo["ent"];
		
		// 偏移，因为大部分的实体的原点都是在实体的中间
		local tempOrigin = origin;
		local tempAngles = angles;
		
		if(objectInfo["pos"] != null)
			tempOrigin += objectInfo["pos"];
		if(objectInfo["ang"] != null)
			tempAngles += objectInfo["ang"];
		
		if(classname == "weapon_ammo_spawn" || classname == "weapon_ammo_pack")
		{
			// 子弹堆
			entity = Utils.SpawnAmmo(objectInfo["model"], tempOrigin, tempAngles);
		}
		else if(classname == "weapon_melee" || classname == "weapon_melee_spawn")
		{
			// 近战武器
			entity = g_ModeScript.SpawnMeleeWeapon(objectInfo["model"], tempOrigin, tempAngles);
			if(entity != null)
				entity = ::VSLib.Entity(entity);
		}
		else if(classname == "weapon_scavenge_item_spawn")
		{
			// 黄色油桶，如果被破坏（点燃），会重复刷出
			entity = Utils.CreateEntity(classname, tempOrigin, tempAngles, {glowstate = 0});
			
			if(entity != null)
				entity.Input("SpawnItem");
		}
		else if(classname == "prop_dynamic" || classname == "prop_dynamic_override")
		{
			// 普通的实体，无法移动（当然可以直接修改位置来移动），没有物理效果
			entity = Utils.SpawnDynamicProp(objectInfo["model"], tempOrigin, tempAngles, params);
		}
		else if(classname == "prop_physics" || classname == "prop_physics_override")
		{
			// 物理实体，可以移动，拥有重力和浮力
			entity = Utils.SpawnPhysicsProp(objectInfo["model"], tempOrigin, tempAngles, params);
		}
		else if(classname == "upgrade_ammo_explosive" || classname == "upgrade_ammo_incendiary" ||
			classname == "upgrade_laser_sight")
		{
			// 武器/弹药升级包
			entity = Utils.SpawnUpgrade(objectInfo["ent"], objectInfo["count"], tempOrigin, tempAngles);
		}
		else if(classname == "prop_fuel_barrel")
		{
			// 白色的油桶（不可以捡起，可以打爆，就是 c7m1 的那种）
			entity = Utils.SpawnFuelBarrel(tempOrigin, tempAngles);
		}
		else if(classname == "prop_minigun")
		{
			// 二代固定机枪（开枪不用预热的那种）
			entity = Utils.SpawnMinigun(tempOrigin, tempAngles);
		}
		else if(classname == "prop_minigun_l4d1")
		{
			// 一代固定机枪（开枪需要预热）
			entity = Utils.SpawnL4D1Minigun(tempOrigin, tempAngles);
		}
		else if(classname == "prop_mounted_machine_gun")
		{
			// 二代固定机枪（c6m3 一代生还者 Louis 用的那个）
			entity = Utils.SpawnMountedGun(tempOrigin, tempAngles);
		}
		else if(classname == "info_survivor_rescue")
		{
			// 生还者复活点（开门复活那种）
			entity = Utils.CreateEntity(classname, tempOrigin, tempAngles, {rescueEyePos = angles,
				solid = 0, maxs = Vector(-5.0, -5.0, 50.0), mins = Vector(-5.0, -5.0, -5.0),
				model = "models/editor/playerstart.mdl"});
		}
		else if(classname == "info_l4d1_survivor_spawn")
		{
			// 刷出一代生还者（只能在开局是二代生还者的地图上刷）
			entity = Utils.SpawnL4D1Survivor(objectInfo["ammo"], tempOrigin, tempAngles);
		}
		else if(classname == "info_item_position")
		{
			if(objectInfo["model"] != null)
				IncludeScript(objectInfo["model"], g_MapScript);
			
			local entityGroup = g_MapScript.GetEntityGroup(objectInfo["ammo"]);
			if(entityGroup != null)
				entity = g_MapScript.SpawnSingleAt(entityGroup, tempOrigin, tempAngles);
			if(entity != null)
				entity = ::VSLib.Entity(entity);
		}
		else if(classname.find("weapon_") == 0)
		{
			local hasSolidSpawn = (classname.find("_spawn") != null);
			
			// 刷出一般的武器
			entity = Utils.SpawnWeapon(classname, objectInfo["count"], objectInfo["ammo"], tempOrigin, tempAngles,
				{solid = 0, spawnflags = 2});
			
			if(entity == null && hasSolidSpawn)
			{
				classname = Utils.StringReplace(classname, "_spawn", "");
				
				// 刷出带 _spawn 的武器失败了，尝试移除 _spawn 再来
				entity = Utils.SpawnWeapon(classname, objectInfo["count"], objectInfo["ammo"], tempOrigin, tempAngles,
					{solid = 0, spawnflags = 2});
			}
			
			/*
			// 如果武器没有带 _spawn 会导致武器可以被移动
			if(!hasSolidSpawn && entity != null)
				entity.SetMoveType(MOVETYPE_NONE);
			*/
		}
		
		if(entity == null)
		{
			printl("[ObjectSpawner] Warring: can't create " + classname + " from " + name);
			return null;
		}
		
		local index = entity.GetIndex();
		// entity.SetMoveType(MOVETYPE_NONE);
		entity.SetNetPropInt("m_iHammerID", (::ObjectSpawner2.HeightHammerId += 1));
		
		if("entity_type" in params && !(index in ::EntityType.Instance))
			::EntityType.OnCreate(entity, params);
		
		// 记录已经刷出的东西
		::ObjectSpawner2.SpawnedEntity[entity.GetIndex()] <-
		{
			"entity" : entity,
			"classname" : classname,
			"name" : name,
			"origin" : origin,
			"angles" : angles,
			"params" : params,
			"string" : ::ObjectSpawner2.BuildSpawnString(name, origin, angles, params),
		};
		
		// 修复实体卡在地上的问题
		entity.SetLocation(origin - Vector(0, 0, entity.GetNetPropVector("m_Collision.m_vecMins").z));
		return entity;
	},
	
	function UpdateEntityData(index, origin = null, angles = null, params = null)
	{
		if(!(index in ::ObjectSpawner2.SpawnedEntity) || ::ObjectSpawner2.SpawnedEntity[index] == null)
			return false;
		
		local hasSuccess = true;
		
		if(origin != null)
		{
			if("origin" in ::ObjectSpawner2.SpawnedEntity[index])
				::ObjectSpawner2.SpawnedEntity[index]["origin"] = origin;
			else
				hasSuccess = false;
		}
		
		if(angles != null)
		{
			if("angles" in ::ObjectSpawner2.SpawnedEntity[index])
				::ObjectSpawner2.SpawnedEntity[index]["angles"] = angles;
			else
				hasSuccess = false;
		}
		
		if(params != null)
		{
			if("params" in ::ObjectSpawner2.SpawnedEntity[index])
				::ObjectSpawner2.SpawnedEntity[index]["params"] = params;
			else
				hasSuccess = false;
		}
		
		if(!("string" in ::ObjectSpawner2.SpawnedEntity[index]))
			return false;
		
		::ObjectSpawner2.SpawnedEntity[index]["string"] = ::ObjectSpawner2.BuildSpawnString(
			::ObjectSpawner2.SpawnedEntity[index]["name"],
			::ObjectSpawner2.SpawnedEntity[index]["origin"],
			::ObjectSpawner2.SpawnedEntity[index]["angles"],
			::ObjectSpawner2.SpawnedEntity[index]["params"]);
		
		::ObjectSpawner2.HasDataChanged = true;
		return hasSuccess;
	},
	
	function UpdateEntityPosition(index, origin = null, angles = null, params = null)
	{
		if(!(index in ::ObjectSpawner2.SpawnedEntity) || ::ObjectSpawner2.SpawnedEntity[index] == null ||
			!("name" in ::ObjectSpawner2.SpawnedEntity[index]))
			return false;
		
		local objectInfo = ::ObjectSpawner2.FindNamedObjectInfo(::ObjectSpawner2.SpawnedEntity[index]["name"]);
		if(objectInfo == null)
			return false;
		
		local hasSuccess = true;
		
		if(origin != null)
		{
			if("origin" in ::ObjectSpawner2.SpawnedEntity[index])
				origin -= objectInfo["pos"];
			else
				hasSuccess = false;
		}
		
		if(angles != null)
		{
			if("angles" in ::ObjectSpawner2.SpawnedEntity[index])
				angles -= objectInfo["ang"];
			else
				hasSuccess = false;
		}
		
		if(!hasSuccess)
			return false;
		
		return ::ObjectSpawner2.UpdateEntityData(index, origin, angles, params);
	},
	
	function VectorToString(vec, prefix = "Vector")
	{
		return prefix + "(" + vec.x + ", " + vec.y + ", " + vec.z + ")";
	},
	
	function VectorToStringNaked(vec)
	{
		return "" + vec.x + " " + vec.y + " " + vec.z + "";
	},
	
	function TableToString(tables)
	{
		local result = "{";
		
		foreach(key, value in tables)
		{
			switch(typeof(value))
			{
				case "integer":
				case "float":
				case "bool":
				case "boolean":
					result += "\"" + key + "\" : " + value + ", ";
					break;
				case "string":
					result += "\"" + key + "\" : \"" + value + "\", ";
					break;
				case "table":
				case "array":
					result += "\"" + key + "\" : " + ::ObjectSpawner2.TableToString(value) + ", ";
					break;
				case "vector":
					result += "\"" + key + "\" : " + ::ObjectSpawner2.VectorToString(value, "Vector") + ", ";
					break;
				case "angle":
				case "qangle":
				case "angles":
					result += "\"" + key + "\" : " + ::ObjectSpawner2.VectorToString(value, "QAngle") + ", ";
					break;
			}
		}
		
		result += "}";
		return result;
	},
	
	function BuildSpawnString(name, origin, angles, params)
	{
		local stringTable = ::ObjectSpawner2.TableToString(params);
		local result = @"::ObjectSpawner2.SpawnNamedEntity(""" + name + @""", " +
			ObjectSpawner2.VectorToString(origin, "Vector") + ", " +
			ObjectSpawner2.VectorToString(angles, "QAngle");
		
		if(stringTable != null && stringTable != "" && stringTable != "{}")
			result += ", " + stringTable;
		
		result += ");";
		return result;
	},
	
	function SaveToFile()
	{
		local fileString = "";
		local numEntitySaved = 0;
		foreach(entity in ::ObjectSpawner2.SpawnedEntity)
		{
			if(!("string" in entity) || entity["string"] == null || entity["string"] == "")
			{
				if("name" in entity && "classname" in entity)
					printl("[ObjectSpawner] Warring: unknown entity " + entity["name"] + " (" + entity["classname"] + ")");
				
				continue;
			}
			
			fileString += entity["string"] + "\n";
			numEntitySaved += 1;
		}
		
		foreach(entity in ::ObjectSpawner2.MovingEntity)
		{
			if(!("string" in entity) || entity["string"] == null || entity["string"] == "")
			{
				if("classname" in entity)
					printl("[ObjectSpawner] Warring: entity " + entity["classname"] + " not found");
				
				continue;
			}
			
			fileString += entity["string"] + "\n";
			numEntitySaved += 1;
		}
		
		if(fileString == "")
			return 0;
		
		StringToFile("spawner/" + ::ObjectSpawner2.CurrentMapName + ".nut", fileString);
		::ObjectSpawner2.HasDataChanged = false;
		
		return numEntitySaved;
	},
	
	function LoadFromFile()
	{
		try
		{
			// 从 scripts/vscripts 里加载文件
			IncludeScript("spawner/" + ::ObjectSpawner2.CurrentMapName + ".nut");
		}
		catch(err)
		{
			
		}
		
		local fileString = FileToString("spawner/" + ::ObjectSpawner2.CurrentMapName + ".nut");
		if(fileString == null || fileString == "")
		{
			printl("file ems/spawner/" + ::ObjectSpawner2.CurrentMapName + ".nut not found.");
		}
		else
		{
			try
			{
				// 从 ems/spawner 加载
				compilestring(fileString)();
				
				printl("file ems/spawner/" + ::ObjectSpawner2.CurrentMapName + ".nut loading...");
			}
			catch(err)
			{
				printl("file ems/spawner/" + ::ObjectSpawner2.CurrentMapName + ".nut error: " + err);
				return false;
			}
		}
		
		return true;
	},
	
	ConvertWeaponSpawn = null,
	AllowWeaponSpawn = null,
	
	function PauseSpawnBlocker()
	{
		if("ConvertWeaponSpawn" in SessionOptions)
		{
			if(::ObjectSpawner2.ConvertWeaponSpawn == null)
				::ObjectSpawner2.ConvertWeaponSpawn = SessionOptions.ConvertWeaponSpawn;
			
			SessionOptions.ConvertWeaponSpawn = @(classname) 0;
		}
		
		if("AllowWeaponSpawn" in SessionOptions)
		{
			if(::ObjectSpawner2.AllowWeaponSpawn == null)
				::ObjectSpawner2.AllowWeaponSpawn = SessionOptions.AllowWeaponSpawn;
			
			SessionOptions.AllowWeaponSpawn = @(classname) true;
		}
	},
	
	function UnpauseSpawnBlocker()
	{
		if(::ObjectSpawner2.ConvertWeaponSpawn != null && "ConvertWeaponSpawn" in SessionOptions)
			SessionOptions.ConvertWeaponSpawn = ::ObjectSpawner2.ConvertWeaponSpawn;
		if(::ObjectSpawner2.AllowWeaponSpawn != null && "AllowWeaponSpawn" in SessionOptions)
			SessionOptions.AllowWeaponSpawn = ::ObjectSpawner2.AllowWeaponSpawn;
	},
	
	function Timer_LoadMapScript(params)
	{
		if(::ObjectSpawner2.CurrentMapName == "")
		{
			if("MapName" in SessionState && SessionState.MapName != "")
				::ObjectSpawner2.CurrentMapName = SessionState.MapName;
			else
				::ObjectSpawner2.CurrentMapName = Utils.StringReplace(Convars.GetStr("host_map"), ".bsp", "");
		}
		
		::ObjectSpawner2.FindHeightHammerID();
		::ObjectSpawner2.PauseSpawnBlocker();
		::ObjectSpawner2.LoadFromFile();
		return false;
	},
	
	CurrentGrabbed = {},
	MovingEntity = {},
	
	function GrabEntity(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsBot())
			return false;
		
		local index = player.GetIndex();
		if(index in ::ObjectSpawner2.CurrentGrabbed)
			return ::ObjectSpawner2.ReleaseEntity(player);
		
		local entity = null;
		local classname = GetArgument(1);
		if(classname != null && classname != "")
			entity = Objects.OfClassnameNearest(classname, player.GetLocation(), 65535);
		else
		{
			entity = player.GetLookingEntity(TRACE_MASK_PLAYER_SOLID);
			if(entity == null)
				entity = player.GetLookingEntity(TRACE_MASK_SHOT);
		}
		
		if(entity == null || !entity.IsEntityValid())
		{
			player.ShowHint("not target");
			return false;
		}
		
		local classname = entity.GetClassname();
		if(entity.IsPlayer() || entity.IsSurvivor() || classname == "infected" || classname == "witch")
		{
			player.ShowHint("invalid target");
			return false;
		}
		
		local origin = entity.GetLocation();
		
		::ObjectSpawner2.CurrentGrabbed[index] <-
		{
			"entity" : entity,
			"origin" : origin,
			"angles" : entity.GetAngles(),
			"classname" : classname,
			"distance" : Utils.CalculateDistance(player.GetEyePosition(), origin),
			"offset" : origin - player.GetLookingLocation(TRACE_MASK_PLAYER_SOLID),
			
			// 实体数据
			"movetype" : entity.GetMoveType(),
			"rendermode" : entity.GetNetPropInt("m_nRenderMode"),
			"renderfx" : entity.GetNetPropInt("m_nRenderFX"),
			"rendercolor" : entity.GetNetPropInt("m_clrRender"),
			"glowtype" : entity.GetNetPropInt("m_Glow.m_iGlowType"),
			"glowrange" : entity.GetNetPropInt("m_Glow.m_nGlowRange"),
			"glowcolor" : entity.GetNetPropInt("m_Glow.m_glowColorOverride"),
			"solidtype" : entity.GetNetPropInt("m_Collision.m_nSolidType"),
			"solidflags" : entity.GetNetPropInt("m_Collision.m_usSolidFlags"),
			"collision" : entity.GetNetPropInt("m_CollisionGroup"),
		};
		
		if(classname == "prop_physics" || classname == "prop_physics_override" ||
			classname == "prop_physics_multiplayer")
		{
			// 有物理效果的实体
			entity.Input("Wake");
			entity.Input("EnableMotion");
			entity.Input("EnableDamageForces");
			entity.SetKeyValue("physdamagescale", 0.0);
			entity.SetNetPropEntity("m_hPhysicsAttacker", player);
			entity.SetNetPropFloat("m_flLastPhysicsInfluenceTime", Time());
		}
		
		if(entity.GetMoveType() == MOVETYPE_NONE)
		{
			if(classname == "player")
				entity.SetMoveType(MOVETYPE_VPHYSICS);
			else
				entity.SetMoveType(MOVETYPE_WALK);
		}
		
		// 实体半透明，方便检查是否卡住了
		entity.SetRenderMode(RENDER_TRANSCOLOR);
		entity.SetRenderEffects(RENDERFX_PULSE_SLOW);
		entity.SetColor(255, 255, 255, 128);
		
		// 禁止实体和任何物体（包括 worldspawn）发生碰撞
		entity.Input("DisableCollision");
		// entity.SetNetPropInt("m_Collision.m_nSolidType", 0);
		// entity.SetNetPropInt("m_Collision.m_usSolidFlags", 4);
		
		// 实体光圈，免得半透明的实体看不清楚
		entity.SetNetPropInt("m_Glow.m_iGlowType", 2);
		entity.SetNetPropInt("m_Glow.m_nGlowRange", 1024);
		entity.SetNetPropInt("m_Glow.m_glowColorOverride", Utils.SetColor32(255, 255, 255, 255));
		
		player.ShowHint("grabbed " + classname + "\n models " + entity.GetModel(), 9);
		player.PlaySound("buttons/combine_button5.wav");
		return true;
	},
	
	function ReleaseEntity(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsBot())
			return false;
		
		local index = player.GetIndex();
		if(!(index in ::ObjectSpawner2.CurrentGrabbed) || ::ObjectSpawner2.CurrentGrabbed[index] == null)
		{
			player.ShowHint("invalid target");
			delete ::ObjectSpawner2.CurrentGrabbed[index];
			return false;
		}
		
		local entity = ::ObjectSpawner2.CurrentGrabbed[index]["entity"];
		if(entity == null || !entity.IsEntityValid() || entity.IsPlayer())
		{
			player.ShowHint("invalid entity");
			delete ::ObjectSpawner2.CurrentGrabbed[index];
			return false;
		}
		
		local classname = entity.GetClassname();
		if(classname == "prop_physics" || classname == "prop_physics_override" ||
			classname == "prop_physics_multiplayer")
		{
			entity.SetNetPropEntity("m_hPhysicsAttacker", null);
			entity.SetNetPropFloat("m_flLastPhysicsInfluenceTime", 0.0);
		}
		
		entity.Input("EnableCollision");
		
		// 恢复数据
		entity.SetMoveType(::ObjectSpawner2.CurrentGrabbed[index].movetype);
		entity.SetRenderMode(::ObjectSpawner2.CurrentGrabbed[index].rendermode);
		entity.SetRenderEffects(::ObjectSpawner2.CurrentGrabbed[index].renderfx);
		entity.SetNetPropInt("m_clrRender", ::ObjectSpawner2.CurrentGrabbed[index].rendercolor);
		// entity.SetNetPropInt("m_Collision.m_nSolidType", ::ObjectSpawner2.CurrentGrabbed[index].solidtype);
		// entity.SetNetPropInt("m_Collision.m_usSolidFlags", ::ObjectSpawner2.CurrentGrabbed[index].solidflags);
		entity.SetNetPropInt("m_Glow.m_iGlowType", ::ObjectSpawner2.CurrentGrabbed[index].glowtype);
		entity.SetNetPropInt("m_Glow.m_nGlowRange", ::ObjectSpawner2.CurrentGrabbed[index].glowrange);
		entity.SetNetPropInt("m_Glow.m_glowColorOverride", ::ObjectSpawner2.CurrentGrabbed[index].glowcolor);
		
		local origin = entity.GetLocation();
		local angles = entity.GetAngles();
		
		local entIndex = entity.GetIndex();
		if(entIndex in ::ObjectSpawner2.SpawnedEntity)
		{
			// 修改由当前脚本刷出的实体的位置
			::ObjectSpawner2.UpdateEntityPosition(entIndex, origin, angles);
		}
		else if(entIndex in ::ObjectSpawner2.MovingEntity)
		{
			// 修改已经修改过的实体的位置
			::ObjectSpawner2.SetEntityOrigin(entity, origin, angles, null, null);
		}
		else
		{
			// 修改地图自带的实体的位置
			::ObjectSpawner2.SetEntityOrigin(entity, origin, angles,
				::ObjectSpawner2.CurrentGrabbed[index]["origin"],
				::ObjectSpawner2.CurrentGrabbed[index]["angles"]);
		}
		
		delete ::ObjectSpawner2.CurrentGrabbed[index];
		return true;
	},
	
	function BuildMovingString(origin, angles, oldOrigin, classname)
	{
		return "::ObjectSpawner2.SetEntityOriginFirst(" +
			::ObjectSpawner2.VectorToString(oldOrigin, "Vector") +
			", " + ::ObjectSpawner2.VectorToString(origin, "Vector") +
			", " + ::ObjectSpawner2.VectorToString(angles, "QAngle") +
			", \"" + classname + "\");"
	},
	
	function FindEntityByHint(hintTable)
	{
		local entity = null;
		
		if("entity" in hintTable && (entity = hintTable["entity"]) != null)
			return entity;
		
		if("hammerId" in hintTable && (entity = Objects.OfHammerID(hintTable["hammerId"]) != null))
			return entity;
		
		if("origin" in hintTable)
		{
			if("classname" in hintTable && (entity = Objects.OfClassnameNearest(
				hintTable["classname"], hintTable["origin"],
				::ObjectSpawner2.ConfigVar.FindEntityRange)) != null)
				return entity;
			
			if("targetname" in hintTable && (entity = Objects.OfNameNearest(
				hintTable["targetname"], hintTable["origin"],
				::ObjectSpawner2.ConfigVar.FindEntityRange)) != null)
				return entity;
			
			if("model" in hintTable && (entity = Objects.OfModelNearest(
				hintTable["model"], hintTable["origin"],
				::ObjectSpawner2.ConfigVar.FindEntityRange)) != null)
				return entity;
			
			entity = null;
			local minDist = 65535.0;
			local curDist = 65535.0;
			foreach(eachEntity in Objects.AroundRadius(origin, ::ObjectSpawner2.ConfigVar.FindEntityRange))
			{
				curDist = Utils.CalculateDistance(origin, eachEntity.GetLocation());
				if(curDist <= ::ObjectSpawner2.ConfigVar.FindEntityRange && curDist < minDist)
				{
					minDist = curDist;
					entity = eachEntity;
				}
			}
			
			if(entity != null)
				return entity;
		}
		
		return null;
	},
	
	function SetEntityOriginFirst(oldOrigin, origin, angles, classname)
	{
		local entity = Objects.OfClassnameNearest(classname, origin, 5);
		if(entity == null)
		{
			printl("[ObjectSpawner] Warring: entity " + classname + " not found.");
			return false;
		}
		
		return ::ObjectSpawner2.SetEntityOrigin(entity, origin, angles, oldOrigin, entity.GetAngles());
	},
	
	// 修改一个地图上已经存在，并且不是这个脚本刷出的实体
	function SetEntityOrigin(entity, origin, angles, oldOrigin = null, oldAngles = null)
	{
		if(entity == null || !entity.IsEntityValid())
			return false;
		
		local index = entity.GetIndex();
		if(oldOrigin == null && !(index in ::ObjectSpawner2.MovingEntity))
			return false;
		
		if(!(index in ::ObjectSpawner2.MovingEntity))
		{
			::ObjectSpawner2.MovingEntity[index] <-
			{
				"origin" : oldOrigin,
				"angles" : oldAngles,
				"entity" : entity,
				"classname" : entity.GetClassname(),
				"newOrigin" : origin,
				"newAngles" : angles,
				"string" : "",
			};
		}
		
		entity.SetLocation(origin);
		entity.SetAngles(angles);
		
		::ObjectSpawner2.MovingEntity[index]["newOrigin"] = origin;
		::ObjectSpawner2.MovingEntity[index]["newAngles"] = angles;
		::ObjectSpawner2.MovingEntity[index]["string"] = ::ObjectSpawner2.BuildMovingString(origin, angles,
			::ObjectSpawner2.MovingEntity[index]["origin"],
			::ObjectSpawner2.MovingEntity[index]["classname"]);
		
		return true;
	},
	
	function Timer_PlayerThink(params)
	{
		if(!::ObjectSpawner2.ConfigVar.Enable)
			return;
		
		foreach(index, entityInfo in ::ObjectSpawner2.CurrentGrabbed)
		{
			local player = ::VSLib.Player(index);
			if(player == null || !player.IsPlayerEntityValid())
			{
				delete ::ObjectSpawner2.CurrentGrabbed[index];
				break;
			}
			
			local entity = entityInfo["entity"];
			if(entity == null || !entity.IsEntityValid())
			{
				delete ::ObjectSpawner2.CurrentGrabbed[index];
				break;
			}
			
			if(player.IsPressingAttack())
			{
				entityInfo["distance"] += ::ObjectSpawner2.ConfigVar.GrabSpeed;
				::ObjectSpawner2.CurrentGrabbed[index]["distance"] = entityInfo["distance"];
			}
			else if(player.IsPressingShove())
			{
				entityInfo["distance"] -= ::ObjectSpawner2.ConfigVar.GrabSpeed;
				::ObjectSpawner2.CurrentGrabbed[index]["distance"] = entityInfo["distance"];
			}
			
			if(player.IsPressingUse())
			{
				entity.SetAngles(entity.GetAngles() + QAngle(0, ::ObjectSpawner2.ConfigVar.GrabRototing, 0));
			}
			else if(player.IsPressingReload())
			{
				entity.SetAngles(entity.GetAngles() + QAngle(0, -::ObjectSpawner2.ConfigVar.GrabRototing, 0));
			}
			
			if(player.IsPressingWalk())
			{
				entity.SetAngles(entity.GetAngles() + QAngle(-::ObjectSpawner2.ConfigVar.GrabRototing, 0, 0));
			}
			else if(player.IsPressingDuck())
			{
				entity.SetAngles(entity.GetAngles() + QAngle(::ObjectSpawner2.ConfigVar.GrabRototing, 0, 0));
			}
			
			if(player.IsPressingButton(BUTTON_SCORE))
			{
				entity.SetAngles(entity.GetAngles() + QAngle(0, 0, -::ObjectSpawner2.ConfigVar.GrabRototing));
			}
			else if(player.IsPressingJump())
			{
				entity.SetAngles(entity.GetAngles() + QAngle(0, 0, ::ObjectSpawner2.ConfigVar.GrabRototing));
			}
			
			// 让实体跟随玩家瞄准的位置
			entity.SetLocation(player.GetEyePosition() +
				player.GetEyeAngles().Forward().Scale(entityInfo["distance"]) + entityInfo["offset"]);
		}
		
		foreach(player in Players.All())
		{
			if(player.IsDead() || player.IsGhost() || player.GetTeam() == SPECTATORS)
				continue;
			
			/*
			if(player.IsSurvivor())
			{
				if(player.IsIncapacitated() || player.IsHangingFromLedge() || player.GetCurrentAttacker() != null)
					continue;
			}
			else if(player.GetCurrentVictim() != null)
				continue;
			*/
			
			local index = player.GetIndex();
			local lastInEntity = (index in ::EntityType.CurrentEntity);
			local entity = ::ObjectSpawner2.GetPlayerGroundEntity(player, ::ObjectSpawner2.ConfigVar.GroundDistance);
			
			if(::EntityType.IsValid(entity))
			{
				// 检查是否为从一个实体到了另一个实体
				if(!lastInEntity || ::EntityType.CurrentEntity[index] != entity)
				{
					if(lastInEntity)
					{
						if(index in ::EntityType.HasInEntity && ::EntityType.HasInEntity[index])
						{
							// 直接走过去的，没有跳起来
							// delete ::EntityType.HasInEntity[index];
							::EntityType.OnPlayerLeft(::EntityType.CurrentEntity[index]);
						}
						
						// 离开之前的实体
						::EntityType.OnPlayerReset(player, ::EntityType.CurrentEntity[index]);
						
						/*
						if(index in ::EntityType.LastEntity)
							delete ::EntityType.LastEntity[index];
						*/
					}
					
					// 进入了一个新的实体
					::EntityType.OnPlayerGround(player, entity);
				}
				else if(!(index in ::EntityType.HasInEntity) || !::EntityType.HasInEntity[index])
				{
					// 在实体上跳起来，然后落回去
					::EntityType.OnPlayerGround(player, entity);
				}
				
				::EntityType.HasInEntity[index] <- true;
			}
			else
			{
				if(lastInEntity)
				{
					if(index in ::EntityType.HasInEntity && ::EntityType.HasInEntity[index])
					{
						// 刚刚离开实体
						delete ::EntityType.HasInEntity[index];
						::EntityType.OnPlayerLeft(::EntityType.CurrentEntity[index]);
					}
					
					if(player.GetFlags() & FL_ONGROUND)
					{
						// 离开实体并且到达地面
						::EntityType.OnPlayerReset(player, ::EntityType.CurrentEntity[index]);
						delete ::EntityType.CurrentEntity[index];
					}
				}
				
				/*
				if(index in ::EntityType.LastEntity)
				{
					if(index in ::EntityType.HasInEntity && ::EntityType.HasInEntity[index])
					{
						delete ::EntityType.HasInEntity[index];
						::EntityType.OnPlayerLeft(::EntityType.LastEntity[index]);
					}
					
					if(player.GetFlags() & FL_ONGROUND)
					{
						::EntityType.OnPlayerReset(player, ::EntityType.LastEntity[index]);
						delete ::EntityType.LastEntity[index];
					}
				}
				*/
			}
			
			if(entity != null)
				::EntityType.CurrentEntity[index] <- entity;
		}
	},
	
	function GetPlayerGroundEntity(player, maxDistance)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.GetNetPropInt("m_lifeState") != 0)
			return null;
		
		local entity = player.GetNetPropEntity("m_hGroundEntity");
		if(entity != null && entity.IsEntityValid())
			return entity;
		
		local origin = player.GetLocation();
		local mins = player.GetNetPropVector("m_Collision.m_vecMins");
		local maxs = player.GetNetPropVector("m_Collision.m_vecMaxs");
		
		local traceTable = {};
		local traceList = [];
		
		for(local i = 0; i < 5; ++i)
		{
			switch(i)
			{
				case 0:
				{
					traceTable =
					{
						start = origin,
						end = origin + Vector(0, 0, -9999999),
						ignore = player.GetBaseEntity(),
						mask = TRACE_MASK_PLAYER_SOLID
					};
					
					break;
				}
				case 1:
				{
					traceTable =
					{
						start = origin + Vector(maxs.x, maxs.y, 0),
						end = origin + Vector(maxs.x, maxs.y, 0) + Vector(0, 0, -9999999),
						ignore = player.GetBaseEntity(),
						mask = TRACE_MASK_PLAYER_SOLID
					};
					
					break;
				}
				case 2:
				{
					traceTable =
					{
						start = origin + Vector(mins.x, mins.y, 0),
						end = origin + Vector(mins.x, mins.y, 0) + Vector(0, 0, -9999999),
						ignore = player.GetBaseEntity(),
						mask = TRACE_MASK_PLAYER_SOLID
					};
					
					break;
				}
				case 3:
				{
					traceTable =
					{
						start = origin + Vector(maxs.x, mins.y, 0),
						end = origin + Vector(maxs.x, mins.y, 0) + Vector(0, 0, -9999999),
						ignore = player.GetBaseEntity(),
						mask = TRACE_MASK_PLAYER_SOLID
					};
					
					break;
				}
				case 4:
				{
					traceTable =
					{
						start = origin + Vector(mins.x, maxs.y, 0),
						end = origin + Vector(mins.x, maxs.y, 0) + Vector(0, 0, -9999999),
						ignore = player.GetBaseEntity(),
						mask = TRACE_MASK_PLAYER_SOLID
					};
					
					break;
				}
			}
			
			if(TraceLine(traceTable))
			{
				if(traceTable.hit && traceTable.enthit != player.GetBaseEntity())
					traceList.append({object = ::VSLib.Entity(traceTable.enthit), position = traceTable.pos});
			}
		}
		
		entity = null;
		local distance = 65535.0;
		foreach(each in traceList)
		{
			local dist = Utils.CalculateDistance(each.position, origin);
			if(dist < distance)
			{
				entity = each.object;
				distance = dist;
			}
		}
		
		if(distance > maxDistance)
			return null;
		
		return entity;
	},
	
	SpawnedCabinet = {},
	CabinetItem_None = "",
	CabinetItem_Random = "?",
	CabinetItem_FirstAidKit = "weapon_first_aid_kit_spawn",
	CabinetItem_PainPills = "weapon_pain_pills_spawn",
	CabinetItem_Defibrillator = "weapon_defibrillator_spawn",
	CabinetItem_Adrenaline = "weapon_adrenaline_spawn",
	
	function CreateCabinet(origin, angles, items = ["", "", "", ""])
	{
		local entity = Utils.CreateEntity("prop_health_cabinet", origin, angles,
			{model = "models/props_interiors/medicalcabinet02.mdl"});
		
		entity.SetMoveType(MOVETYPE_NONE);
		entity.ConnectOutput("OnAnimationDone", ::ObjectSpawner2.OnOutput_OnCabinetOpening,
			"_vslib_objectspawner_cabinet");
		
		::ObjectSpawner2.SpawnedCabinet[entity.GetIndex()] <-
		{
			"entity" : entity,
			"items" : items,
			"object" : [null, null, null, null]
		};
	},
	
	function OnOutput_OnCabinetOpening()
	{
		if(caller == null || !caller.IsValid())
			return;
		
		local entity = ::VSLib.Entity(caller);
		local index = entity.GetIndex();
		
		entity.DisconnectOutput("OnAnimationDone", "_vslib_objectspawner_cabinet");
		if(!(index in ::ObjectSpawner2.SpawnedCabinet))
			return;
		
		local origin = entity.GetLocation();
		local angles = entity.GetAngles();
		local items = ::ObjectSpawner2.SpawnedCabinet[index].items;
		
		origin += angles.Forward().Scale(3);
		local total = 0;
		
		local function MoveSideway(pos, ang, dst)
		{
			local tv = ang.Left().Scale(-1);
			return (pos + Vector(tv.x * dst, tv.y * dst, 0));
		}
		
		for(local i = 0; i < 4; ++i)
		{
			if(!(i in items) || items[i] == "" || items[i] == null)
				continue;
			
			local entity = null;
			local classname = items[i];
			if(classname == "?")
			{
				classname = Utils.GetRandValueFromArray(["weapon_first_aid_kit_spawn", "weapon_pain_pills_spawn",
					"weapon_defibrillator_spawn", "weapon_adrenaline_spawn"]);
			}
			
			switch(i)
			{
				case 0:
				{
					entity = Utils.SpawnWeapon(classname, 1, 999, MoveSideway(origin, angles, -9) +
						Vector(0, 0, 37), angles + QAngle(0, 180, 0), {solid = 0, disableshadows = 1, spawnflags = 2});
					break;
				}
				case 1:
				{
					entity = Utils.SpawnWeapon(classname, 1, 999, MoveSideway(origin, angles, 9) +
						Vector(0, 0, 37), angles + QAngle(0, 180, 0), {solid = 0, disableshadows = 1, spawnflags = 2});
					break;
				}
				case 2:
				{
					entity = Utils.SpawnWeapon(classname, 1, 999, MoveSideway(origin, angles, 9) +
						Vector(0, 0, 51), angles + QAngle(0, 180, 0), {solid = 0, disableshadows = 1, spawnflags = 2});
					break;
				}
				case 3:
				{
					entity = Utils.SpawnWeapon(classname, 1, 999, MoveSideway(origin, angles, -9) +
						Vector(0, 0, 51), angles + QAngle(0, 180, 0), {solid = 0, disableshadows = 1, spawnflags = 2});
					break;
				}
			}
			
			if(entity == null)
				continue;
			
			total += 1;
			::ObjectSpawner2.SpawnedCabinet[index].object[i] = entity;
		}
		
		printl("prop_health_cabinet opening, total " + total + " items spawnning");
	},
	
	SpawnedCloset = {},
	
	function CreateCloset(origin, angles)
	{
		local toilet = Utils.CreateEntity("prop_dynamic_override", origin, angles,
			{solid = 6, model = "models/props_urban/outhouse002.mdl"});
		
		local door = Utils.CreateEntity("prop_door_rotating", origin, angles,
			{solid = 6, disableshadows = 1, distance = 100, spawnpos = 0, opendir = 1, spawnflags = 532480,
			model = "models/props_urban/outhouse_door001.mdl"});
		
		toilet.AttachOther(door);
		door.SetLocation(Vector(27.5, -17.0, 3.49));
		toilet.RemoveAttached(door);
		
		local rescue = Utils.CreateEntity("info_survivor_rescue", origin, angles,
			{solid = 0, model = "models/editor/playerstart.mdl",
			mins = Vector(-5.0, -5.0, -5.0), maxs = Vector(-5.0, -5.0, 50.0)});
		rescue.Input("TurnOn");
		
		toilet.AttachOther(rescue);
		rescue.SetLocation(Vector(1.0, 0.0, 5.5));
		toilet.RemoveAttached(rescue);
		
		::ObjectSpawner2.SpawnedCloset[index] <-
		{
			"toilet" : toilet,
			"door" : door,
			"rescue" : rescue
		};
	}
};

::ObjectSpawner <-
{
	function SpawnEntity(name, origin, angles, params = {})
	{
		return ::ObjectSpawner2.SpawnNamedEntity(name, origin, angles, params);
	}
};

::EntityType <-
{
	CurrentEntity = {},
	// LastEntity = {},
	HasInEntity = {},
	Instance = {},
	Creator = {},
	
	function IsValid(entity)
	{
		if(entity == null || !entity.IsEntityValid())
			return false;
		
		local index = entity.GetIndex();
		return (index in ::EntityType.Instance && ::EntityType.Instance[index] != null);
	},
	
	// 触碰到实体
	function OnPlayerTouch(player, entity)
	{
		if(player == null || entity == null)
			return false;
		
		local index = entity.GetIndex();
		if(index in ::EntityType.Instance)
			return ::EntityType.Instance[index].OnTouch(player);
		
		return false;
	},
	
	// 站在实体上
	function OnPlayerGround(player, entity)
	{
		if(player == null || entity == null)
			return false;
		
		local index = entity.GetIndex();
		if(index in ::EntityType.Instance)
			return ::EntityType.Instance[index].OnGround(player);
		
		return false;
	},
	
	// 当玩家对实体按 E
	function OnPlayerUse(player, entity)
	{
		if(player == null || entity == null)
			return false;
		
		local index = entity.GetIndex();
		if(index in ::EntityType.Instance)
			return ::EntityType.Instance[index].OnUse(player);
		
		return false;
	},
	
	// 当玩家离开了实体
	function OnPlayerLeft(player, entity)
	{
		if(player == null || entity == null)
			return false;
		
		local index = entity.GetIndex();
		if(index in ::EntityType.Instance)
			return ::EntityType.Instance[index].OnLeft(player);
		
		return false;
	},
	
	// 当玩家离开了实体并到地地面
	function OnPlayerReset(player, entity)
	{
		if(player == null || entity == null)
			return false;
		
		local index = entity.GetIndex();
		if(index in ::EntityType.Instance)
			return ::EntityType.Instance[index].OnReset(player);
		
		return false;
	},
	
	// 创建特殊实体
	function OnCreate(entity, params)
	{
		if(entity == null)
			return false;
		
		entity.ConnectOutput("OnPlayerPickup", ::EntityType.OnOutput_OnPickup, "_vslib_objectspawner_pickup");
		entity.ConnectOutput("OnPlayerTouch", ::EntityType.OnOutput_OnTouch, "_vslib_objectspawner_touch");
		
		local index = entity.GetIndex();
		if(!(index in ::EntityType.Instance))
			::EntityType.Instance[index] <- ::EntityType.Creator[params["entity_type"]](entity);
		
		return ::EntityType.Instance[index].OnCreate(params);
	},
	
	// 撤销特殊实体
	function OnRelease(entity)
	{
		if(entity == null)
			return false;
		
		local index = entity.GetIndex();
		if(index in ::EntityType.Instance)
		{
			local result = ::EntityType.Instance[index].OnRelease();
			delete ::EntityType.Instance[index];
		}
		
		entity.DisconnectOutput("OnPlayerPickup", "_vslib_objectspawner_pickup");
		entity.DisconnectOutput("OnPlayerTouch", "_vslib_objectspawner_touch");
		
		return false;
	},
	
	function OnOutput_OnTouch()
	{
		if(caller == null || activator == null || !caller.IsValid() || !activator.IsValid())
			return;
		
		::EntityType.OnPlayerTouch(::VSLib.Player(activator), ::VSLib.Entity(activator));
	},
	
	function OnOutput_OnPickup()
	{
		if(caller == null || activator == null || !caller.IsValid() || !activator.IsValid())
			return;
		
		::EntityType.OnPlayerUse(::VSLib.Player(activator), ::VSLib.Entity(activator));
	}
};

class ::ObjectSpawner2.BaseEntityType
{
	constructor(entity)
	{
		// base.constructor(entity);
		_ent = entity;
	}
	
	function _typeof()
	{
		return "OBJECT_SPAWNER_BASE";
	}
	
	function OnCreate(params)
	{
	}
	
	function OnRelease()
	{
	}
	
	function OnTouch(player)
	{
	}
	
	function OnGround(player)
	{
	}
	
	function OnUse(player)
	{
	}
	
	function OnLeft(player)
	{
	}
	
	function OnReset(player)
	{
	}
	
	_ent = null;
}

function Notifications::OnRoundBegin::ObjectSpawner_LoadMapScript(params)
{
	if(!::ObjectSpawner2.ConfigVar.Enable || !::ObjectSpawner2.ConfigVar.AutoLoad)
		return;
	
	Timers.AddTimerByName("timer_objectspawner_loadmap", ::ObjectSpawner2.ConfigVar.LoadDelay, false,
		::ObjectSpawner2.Timer_LoadMapScript);
}

function Notifications::OnSurvivorsDead::ObjectSpawner_SaveMapScript()
{
	if(!::ObjectSpawner2.ConfigVar.Enable || !::ObjectSpawner2.ConfigVar.AutoSave ||
		!::ObjectSpawner2.HasDataChanged)
		return;
	
	::ObjectSpawner2.SaveToFile();
}

function Notifications::OnMapEnd::ObjectSpawner_SaveMapScript()
{
	Notifications.OnSurvivorsDead.ObjectSpawner_SaveMapScript();
}

function Notifications::OnFirstSpawn::ObjectSpawner_GetMapName(player, params)
{
	if(!("map_name" in params) || ::ObjectSpawner2.CurrentMapName != "")
		return;
	
	::ObjectSpawner2.CurrentMapName = params["map_name"];
	printl("[ObjectSpawner] current map: " + params["map_name"]);
}

function CommandTriggersEx::so(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	local numSaved = ::ObjectSpawner2.SaveToFile();
	// player.ShowHint("saved " + numSaved);
	player.PrintToChat("saved " + numSaved);
}

// 刷出物体
function CommandTriggersEx::si(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	local name = GetArgument(1);
	if(name == null || name == "")
	{
		// player.ShowHint("invalid parameter", 9);
		player.PrintToChat("invalid parameter");
		return;
	}
	
	local objectInfo = ::ObjectSpawner2.FindNamedObjectInfo(name);
	if(objectInfo == null)
	{
		// player.ShowHint(name + " not found", 9);
		player.PrintToChat(name + " not found");
		return;
	}
	
	local origin = player.GetLookingLocation();
	local angles = player.GetEyeAngles();
	angles.x = angles.z = 0;
	
	if(objectInfo["ent"] == "info_survivor_rescue" ||
		objectInfo["ent"] == "prop_dynamic" || objectInfo["ent"] == "prop_dynamic_override" ||
		objectInfo["ent"] == "prop_physics" || objectInfo["ent"] == "prop_physics_override")
		origin = player.GetLocation();
	
	local params = {};
	
	local args = GetArgument(2);
	if(args != null && args != "")
	{
		if(objectInfo["ent"].find("weapon_") != null)
			params["count"] <- args.tointeger();
	}
	
	args = GetArgument(3);
	if(args != null && args != "")
	{
		if(objectInfo["ent"].find("weapon_") != null)
			params["ammo"] <- args.tointeger();
	}
	
	local entity = ::ObjectSpawner2.SpawnNamedEntity(name, origin, angles, params);
	if(entity == null)
	{
		// player.ShowHint("Failed to create " + objectInfo["ent"], 9);
		player.PrintToChat("Failed to create " + objectInfo["ent"]);
		return;
	}
	
	::ObjectSpawner2.HasDataChanged = true;
	// player.ShowHint("a " + entity.GetClassname() + " created.", 9);
	player.PrintToChat("a " + entity.GetClassname() + " created.");
	
	local index = player.GetIndex();
	if(!(index in ::ObjectSpawner2.LastEntity))
		::ObjectSpawner2.LastEntity[index] <- [];
	
	::ObjectSpawner2.LastEntity[index].append(entity);
}

function CommandTriggersEx::di(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	local entity = player.GetLookingEntity(TRACE_MASK_SHOT);
	if(entity == null)
	{
		local index = player.GetIndex();
		if(!(index in ::ObjectSpawner2.LastEntity) || ::ObjectSpawner2.LastEntity[index] == null ||
			::ObjectSpawner2.LastEntity[index].len() <= 0)
		{
			// player.ShowHint("not target", 9);
			player.PrintToChat("not target");
			return;
		}
		
		entity = ::ObjectSpawner2.LastEntity[index].pop();
	}
	
	if(entity == null || !entity.IsEntityValid())
	{
		// player.ShowHint("not vaild target", 9);
		player.PrintToChat("not vaild target");
		return;
	}
	
	local index = entity.GetIndex();
	if(index in ::ObjectSpawner2.SpawnedEntity)
		delete ::ObjectSpawner2.SpawnedEntity[index];
	
	::EntityType.OnRelease(entity);
	entity.Kill();
	
	::ObjectSpawner2.HasDataChanged = true;
}

function CommandTriggersEx::grab(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	local index = player.GetIndex();
	if(index in ::ObjectSpawner2.CurrentGrabbed)
		::ObjectSpawner2.GrabEntity(player);
	else
		::ObjectSpawner2.ReleaseEntity(player);
}

function CommandTriggersEx::release(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	local index = player.GetIndex();
	if(!(index in ::ObjectSpawner2.CurrentGrabbed))
	{
		player.ShowHint("not target", 9);
		return;
	}
	
	local entity = ::ObjectSpawner2.CurrentGrabbed[index]["entity"];
	if(entity == null || !entity.IsEntityValid())
	{
		delete ::ObjectSpawner2.CurrentGrabbed[index];
		printl("invalid target", 9);
		return;
	}
	
	entity.SetLocation(::ObjectSpawner2.CurrentGrabbed[index]["origin"]);
	entity.SetAngles(::ObjectSpawner2.CurrentGrabbed[index]["angles"]);
	::ObjectSpawner2.ReleaseEntity(player);
}

::ObjectSpawner2.PLUGIN_NAME <- PLUGIN_NAME;
::ObjectSpawner2.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::ObjectSpawner2.ConfigVarDef);

function Notifications::OnRoundStart::ObjectSpawner_LoadConfig()
{
	RestoreTable(::ObjectSpawner2.PLUGIN_NAME, ::ObjectSpawner2.ConfigVar);
	if(::ObjectSpawner2.ConfigVar == null || ::ObjectSpawner2.ConfigVar.len() <= 0)
		::ObjectSpawner2.ConfigVar = FileIO.GetConfigOfFile(::ObjectSpawner2.PLUGIN_NAME, ::ObjectSpawner2.ConfigVarDef);

	// printl("[plugins] " + ::ObjectSpawner2.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::ObjectSpawner_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::ObjectSpawner2.PLUGIN_NAME, ::ObjectSpawner2.ConfigVar);

	// printl("[plugins] " + ::ObjectSpawner2.PLUGIN_NAME + " saving...");
}


