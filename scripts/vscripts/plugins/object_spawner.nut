::ObjectSpawner <-
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

		// 需要站在板块上距离多少之内才触发效果
		GroundDistance = 50.0,

		// 连跳板消失延迟
		BhopDelay = 0.25,

		// 连跳板消失后恢复时间
		BhopDuration = 3.0,

		// 蹦床板触发延迟
		TrampolineDelay = 0.1,

		// 蹦床板跳跃高度
		TrampolinePower = 500,

		// 弹射板触发延迟
		CatapultDelay = 0.1,

		// 弹射板发射力度
		CatapultPower = 900,

		// 弹射板弹射高度
		CatapultHeight = 300,

		// 重力板修改的重力大小
		Gravity = 0.6,

		// 滑冰板的摩檫力
		Friction = 0.4,

		// 移动板设置移动速度
		Movement = 1.5,

		// 伤害板伤害延迟
		DamageDelay = 1.0,

		// 伤害板伤害数量
		DamageAmount = 5,

		// 黑屏板触发延迟
		BlindDelay = 1.0
	},

	ConfigVar = {},

	ObjectNamed =
	[
		// {cmd = "", ent = "", ammo = null, count = 1, models = null, pos = null, ang = null},
		
		// 手枪
		{cmd = "pis", ent = "weapon_pistol_spawn", ammo = 999, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "mag", ent = "weapon_pistol_magnum_spawn", ammo = 999, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		
		// 冲锋枪
		{cmd = "smg", ent = "weapon_smg_spawn", ammo = 650, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "smgs", ent = "weapon_smg_silenced_spawn", ammo = 650, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "mp5", ent = "weapon_smg_mp5_spawn", ammo = 650, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		
		// 霰弹枪
		{cmd = "pump", ent = "weapon_pumpshotgun_spawn", ammo = 56, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "chrome", ent = "weapon_shotgun_chrome_spawn", ammo = 56, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "auto", ent = "weapon_autoshotgun_spawn", ammo = 90, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "spas", ent = "weapon_shotgun_spas_spawn", ammo = 90, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		
		// 步枪
		{cmd = "m16", ent = "weapon_rifle_spawn", ammo = 360, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "m4", ent = "weapon_rifle_spawn", ammo = 360, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "ak47", ent = "weapon_rifle_ak47_spawn", ammo = 360, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "ak", ent = "weapon_rifle_ak47_spawn", ammo = 360, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "des", ent = "weapon_rifle_desert_spawn", ammo = 360, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "dst", ent = "weapon_rifle_desert_spawn", ammo = 360, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "dsr", ent = "weapon_rifle_desert_spawn", ammo = 360, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "sg552", ent = "weapon_rifle_sg552_spawn", ammo = 360, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "m60", ent = "weapon_rifle_m60_spawn", ammo = 0, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "gl", ent = "weapon_grenade_launcher_spawn", ammo = 30, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		
		// 狙击枪
		{cmd = "hunt", ent = "weapon_hunting_rifle_spawn", ammo = 120, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "mil", ent = "weapon_sniper_military_spawn", ammo = 180, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "scout", ent = "weapon_sniper_scout_spawn", ammo = 180, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "sco", ent = "weapon_sniper_scout_spawn", ammo = 180, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		{cmd = "awp", ent = "weapon_sniper_awp_spawn", ammo = 180, count = 1, models = null, pos = Vector(0, 0, 2), ang = QAngle(0, 0, 90)},
		
		// 投掷武器
		{cmd = "pipe", ent = "weapon_pipe_bomb_spawn", ammo = 1, count = 1, models = null, pos = Vector(0, 0, 8), ang = null},
		{cmd = "molo", ent = "weapon_molotov_spawn", ammo = 1, count = 1, models = null, pos = Vector(0, 0, 8), ang = null},
		{cmd = "bile", ent = "weapon_vomitjar_spawn", ammo = 1, count = 1, models = null, pos = Vector(0, 0, 8), ang = null},
		
		// 医疗品
		{cmd = "fak", ent = "weapon_first_aid_kit_spawn", ammo = 1, count = 1, models = null, pos = Vector(0, 0, 2), ang = null},
		{cmd = "defib", ent = "weapon_defibrillator_spawn", ammo = 1, count = 1, models = null, pos = null, ang = null},
		{cmd = "pill", ent = "weapon_pain_pills_spawn", ammo = 1, count = 1, models = null, pos = null, ang = null},
		{cmd = "adren", ent = "weapon_adrenaline_spawn", ammo = 1, count = 1, models = null, pos = Vector(0, 0, 2), ang = null},
		
		// 升级包
		{cmd = "fire", ent = "weapon_upgradepack_incendiary_spawn", ammo = 1, count = 1, models = null, pos = null, ang = null},
		{cmd = "exp", ent = "weapon_upgradepack_explosive_spawn", ammo = 1, count = 1, models = null, pos = null, ang = null},
		{cmd = "ufire", ent = "upgrade_ammo_incendiary", ammo = 1, count = 4, models = null, pos = null, ang = null},
		{cmd = "uexp", ent = "upgrade_ammo_explosive", ammo = 1, count = 4, models = null, pos = null, ang = null},
		{cmd = "laser", ent = "upgrade_laser_sight", ammo = 1, count = 4, models = null, pos = null, ang = null},
		
		// 近战武器
		{cmd = "cha", ent = "weapon_chainsaw_spawn", ammo = 999, count = 1, models = null, pos = Vector(0, 0, 3), ang = null},
		{cmd = "ball", ent = "weapon_melee_spawn", ammo = null, count = 1, models = "baseball_bat", pos = null, ang = QAngle(0, 0, 90)},
		{cmd = "cri", ent = "weapon_melee_spawn", ammo = null, count = 1, models = "cricket_bat", pos = null, ang = QAngle(0, 0, 90)},
		{cmd = "gui", ent = "weapon_melee_spawn", ammo = null, count = 1, models = "guitar", pos = null, ang = QAngle(0, 0, 90)},
		{cmd = "axe", ent = "weapon_melee_spawn", ammo = null, count = 1, models = "fireaxe", pos = null, ang = QAngle(0, 0, 90)},
		{cmd = "pan", ent = "weapon_melee_spawn", ammo = null, count = 1, models = "frying_pan", pos = null, ang = QAngle(0, 0, 90)},
		{cmd = "kat", ent = "weapon_melee_spawn", ammo = null, count = 1, models = "katana", pos = null, ang = QAngle(0, 0, 90)},
		{cmd = "knife", ent = "weapon_melee_spawn", ammo = null, count = 1, models = "knife", pos = null, ang = QAngle(0, 0, 90)},
		{cmd = "mac", ent = "weapon_melee_spawn", ammo = null, count = 1, models = "machete", pos = null, ang = QAngle(0, 0, 90)},
		{cmd = "ton", ent = "weapon_melee_spawn", ammo = null, count = 1, models = "tonfa", pos = null, ang = QAngle(0, 0, 90)},
		{cmd = "golf", ent = "weapon_melee_spawn", ammo = null, count = 1, models = "golfclub", pos = null, ang = QAngle(0, 0, 90)},
		
		// 携带物品
		{cmd = "gas", ent = "weapon_gascan", ammo = null, count = 1, models = null, pos = Vector(0, 0, 16), ang = null},
		{cmd = "prop", ent = "weapon_propanetank", ammo = null, count = 1, models = null, pos = Vector(0, 0, 16), ang = null},
		{cmd = "oxy", ent = "weapon_oxygentank", ammo = null, count = 1, models = null, pos = null, ang = null},
		{cmd = "fw", ent = "weapon_fireworkcrate", ammo = null, count = 1, models = null, pos = Vector(0, 0, 4), ang = null},
		{cmd = "cola", ent = "weapon_cola_bottles", ammo = null, count = 1, models = null, pos = null, ang = null},
		{cmd = "gnome", ent = "weapon_gnome", ammo = null, count = 1, models = null, pos = Vector(0, 0, 16), ang = null},
		
		// 杂项
		{cmd = "bar", ent = "prop_fuel_barrel", ammo = null, count = null, models = null, pos = null, ang = null},
		{cmd = "mg3", ent = "prop_mounted_machine_gun", ammo = null, count = null, models = null, pos = null, ang = null},
		{cmd = "mg2", ent = "prop_minigun", ammo = null, count = null, models = null, pos = null, ang = null},
		{cmd = "mg", ent = "prop_minigun_l4d1", ammo = null, count = null, models = null, pos = null, ang = null},
		{cmd = "ammo", ent = "weapon_ammo_spawn", ammo = null, count = 1, models = "models/props/terror/ammo_stack.mdl", pos = null, ang = null},
		{cmd = "ammo1", ent = "weapon_ammo_spawn", ammo = null, count = 1, models = "models/props_unique/spawn_apartment/coffeeammo.mdl", pos = null, ang = null},
		{cmd = "ammo2", ent = "weapon_ammo_spawn", ammo = null, count = 1, models = "models/props/terror/Ammo_Can.mdl", pos = null, ang = null},
		{cmd = "ammo3", ent = "weapon_ammo_spawn", ammo = null, count = 1, models = "models/props/de_prodigy/ammo_can_02.mdl", pos = null, ang = null},
		{cmd = "rescue", ent = "info_survivor_rescue", ammo = null, count = null, models = "models/editor/playerstart.mdl", pos = null, ang = null},
		{cmd = "zombie", ent = "info_zombie_spawn", ammo = 1, count = null, models = null, pos = null, ang = null},
		{cmd = "infected", ent = "commentary_zombie_spawner", ammo = 1, count = null, models = null, pos = null, ang = null},
		{cmd = "rock", ent = "env_rock_launcher", ammo = 1, count = null, models = null, pos = null, ang = null},
		{cmd = "can", ent = "weapon_scavenge_item_spawn", ammo = null, count = null, models = null, pos = null, ang = null},
		{cmd = "pos", ent = "make_entity_position", ammo = null, count = null, models = null, pos = null, ang = null},
		
		// 生还者
		{cmd = "nick", ent = "info_l4d1_survivor_spawn", ammo = 0, count = null, models = null, pos = null, ang = null},
		{cmd = "rochelle", ent = "info_l4d1_survivor_spawn", ammo = 1, count = null, models = null, pos = null, ang = null},
		{cmd = "coach", ent = "info_l4d1_survivor_spawn", ammo = 2, count = null, models = null, pos = null, ang = null},
		{cmd = "ellis", ent = "info_l4d1_survivor_spawn", ammo = 3, count = null, models = null, pos = null, ang = null},
		{cmd = "bill", ent = "info_l4d1_survivor_spawn", ammo = 4, count = null, models = null, pos = null, ang = null},
		{cmd = "zoey", ent = "info_l4d1_survivor_spawn", ammo = 5, count = null, models = null, pos = null, ang = null},
		{cmd = "francis", ent = "info_l4d1_survivor_spawn", ammo = 6, count = null, models = null, pos = null, ang = null},
		{cmd = "louis", ent = "info_l4d1_survivor_spawn", ammo = 7, count = null, models = null, pos = null, ang = null}
		
		// 模型
		{cmd = "yzz", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_interiors/dining_table_round.mdl", pos = null, ang = null},
		{cmd = "ymz", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_interiors/coffee_table_oval.mdl", pos = null, ang = null},
		{cmd = "mxz", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props/de_nuke/crate_extralarge.mdl", pos = null, ang = null},
		{cmd = "jc", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_vehicles/police_car_rural.mdl", pos = null, ang = null},
		{cmd = "bed", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_interiors/couch.mdl", pos = null, ang = null},
		{cmd = "bebch", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props/cs_militia/wood_bench.mdl", pos = null, ang = null},
		{cmd = "ljx", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_junk/dumpster.mdl", pos = null, ang = null},
		{cmd = "xp", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_unique/escalatortall.mdl", pos = null, ang = null},
		{cmd = "ytd", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_unique/wooden_barricade_gascans.mdl", pos = null, ang = null},
		{cmd = "atm", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_unique/atm01.mdl", pos = null, ang = null},
		{cmd = "ylx", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_interiors/medicalcabinet02.mdl", pos = null, ang = null},
		{cmd = "dz", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props/de_prodigy/concretebags2.mdl", pos = null, ang = null},
		{cmd = "mx", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props/de_nuke/crate_extralarge.mdl", pos = null, ang = null},
		{cmd = "wxd", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props/terror/hamradio.mdl", pos = null, ang = null},
		{cmd = "dtmb", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_interiors/elevator_panel.mdl", pos = null, ang = null},
		{cmd = "yx", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_fairgrounds/amp_plexi.mdl", pos = null, ang = null},
		{cmd = "dyx", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_fairgrounds/amp_stack.mdl", pos = null, ang = null},
		{cmd = "zl", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_urban/fence002_256.mdl", pos = null, ang = null},
		{cmd = "zl2", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_wasteland/exterior_fence002c.mdl", pos = null, ang = null},
		{cmd = "zlx", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_wasteland/exterior_fence002b.mdl", pos = null, ang = null},
		{cmd = "zlz", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_wasteland/exterior_fence002d.mdl", pos = null, ang = null},
		{cmd = "zld", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_wasteland/exterior_fence002e.mdl", pos = null, ang = null},
		{cmd = "slt", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_c17/metalladder001.mdl", pos = null, ang = null},
		{cmd = "slt2", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_c17/metalladder005.mdl", pos = null, ang = null},
		{cmd = "tlt", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_equipment/tablegreenhouse01.mdl", pos = null, ang = null},
		{cmd = "tb", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_urban/fence_cover001_128.mdl", pos = null, ang = null},
		{cmd = "ey", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_fairgrounds/alligator.mdl", pos = null, ang = null},
		{cmd = "dx", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_fairgrounds/elephant.mdl", pos = null, ang = null},
		{cmd = "ft", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props_mall/mall_escalator.mdl", pos = null, ang = null},
		{cmd = "shj", ent = "prop_dynamic_override", ammo = null, count = null, models = "models/props/cs_office/vending_machine.mdl", pos = null, ang = null},
		
		// 板块
		{cmd = "bhop", ent = "entity_type", ammo = null, count = null, models = null, pos = null, ang = null},
		{cmd = "trampoline", ent = "entity_type", ammo = null, count = null, models = null, pos = null, ang = null},
		{cmd = "catapult", ent = "entity_type", ammo = null, count = null, models = null, pos = null, ang = null},
		{cmd = "gravity", ent = "entity_type", ammo = null, count = null, models = null, pos = null, ang = null},
		{cmd = "skate", ent = "entity_type", ammo = null, count = null, models = null, pos = null, ang = null},
		{cmd = "shake", ent = "entity_type", ammo = null, count = null, models = null, pos = null, ang = null},
		{cmd = "movement", ent = "entity_type", ammo = null, count = null, models = null, pos = null, ang = null},
		{cmd = "fall", ent = "entity_type", ammo = null, count = null, models = null, pos = null, ang = null},
		{cmd = "teleport", ent = "entity_type", ammo = null, count = null, models = null, pos = null, ang = null},
		{cmd = "damage", ent = "entity_type", ammo = null, count = null, models = null, pos = null, ang = null},
		{cmd = "death", ent = "entity_type", ammo = null, count = null, models = null, pos = null, ang = null},
	],
	
	ObjectIndex = 3000,
	ObjectSpawned = {},
	ZombieSpawnParams = {},
	RockLauncherParams = {},
	CurrentGrabbed = {},
	CurrentGrabbedString = {},
	StartGrabbedAngles = {},
	MovedEntity = {},
	CurrentMapName = "",
	ScipteToFileString = null,
	ScriptChanged = false,
	
	function OnEntityThink_ZombieSpawn()
	{
		if(this.ent == null || !this.ent.IsEntityValid())
			return;
		
		local index = this.ent.GetIndex();
		if(!(index in ::ObjectSpawner.ZombieSpawnParams) || ::ObjectSpawner.ZombieSpawnParams[index] == null)
		{
			this.ent.AddThinkFunction(null);
			return;
		}
		
		if(::ObjectSpawner.ZombieSpawnParams[index]["nexttime"] > Time())
		{
			this.ent.SetNextThinkTime(::ObjectSpawner.ZombieSpawnParams[index]["nexttime"]);
			return;
		}
		
		this.ent.Input("SpawnZombie");
		::ObjectSpawner.ZombieSpawnParams[index]["nexttime"] = Time() + ::ObjectSpawner.ZombieSpawnParams[index]["interval"];
		this.ent.SetNextThinkTime(::ObjectSpawner.ZombieSpawnParams[index]["nexttime"]);
	},
	
	function OnEntityThink_InfectedSpawn()
	{
		if(this.ent == null || !this.ent.IsEntityValid())
			return;
		
		local index = this.ent.GetIndex();
		if(!(index in ::ObjectSpawner.ZombieSpawnParams) || ::ObjectSpawner.ZombieSpawnParams[index] == null)
		{
			this.ent.AddThinkFunction(null);
			return;
		}
		
		if(::ObjectSpawner.ZombieSpawnParams[index]["nexttime"] > Time())
		{
			this.ent.SetNextThinkTime(::ObjectSpawner.ZombieSpawnParams[index]["nexttime"]);
			return;
		}
		
		this.ent.Input("SpawnZombie", ::ObjectSpawner.ZombieSpawnParams[index]["zombie"]);
		::ObjectSpawner.ZombieSpawnParams[index]["nexttime"] = Time() + ::ObjectSpawner.ZombieSpawnParams[index]["interval"];
		this.ent.SetNextThinkTime(::ObjectSpawner.ZombieSpawnParams[index]["nexttime"]);
	},
	
	function OnEntityThink_RockLauncher()
	{
		if(this.ent == null || !this.ent.IsEntityValid())
			return;
		
		local index = this.ent.GetIndex();
		if(!(index in ::ObjectSpawner.ZombieSpawnParams) || ::ObjectSpawner.ZombieSpawnParams[index] == null)
		{
			this.ent.AddThinkFunction(null);
			return;
		}
		
		if(::ObjectSpawner.ZombieSpawnParams[index]["nexttime"] > Time())
		{
			this.ent.SetNextThinkTime(::ObjectSpawner.ZombieSpawnParams[index]["nexttime"]);
			return;
		}
		
		this.ent.Input("LaunchRock");
		::ObjectSpawner.ZombieSpawnParams[index]["nexttime"] = Time() + ::ObjectSpawner.ZombieSpawnParams[index]["interval"];
		this.ent.SetNextThinkTime(::ObjectSpawner.ZombieSpawnParams[index]["nexttime"]);
	},
	
	PlayerStatus = {},
	PlayerGround = {},
	PlayerTeleport = {},
	
	function ResetPlayerData(player)
	{
		if(player == null || !player.IsPlayerEntityValid())
			return false;
		
		local index = player.GetIndex();
		if(index in ::ObjectSpawner.PlayerStatus)
		{
			switch(::ObjectSpawner.PlayerStatus[index])
			{
				case 1:
					player.SetGravity(1.0);
					break;
				case 2:
					player.SetFriction(1.0);
					break;
				case 3:
					player.SetNetPropFloat("m_flLaggedMovementValue", 1.0);
					break;
			}
			
			delete ::ObjectSpawner.PlayerStatus[index];
		}
		
		return false;
	},
	
	function Timer_ResetBhopEntity(entity)
	{
		if(entity == null || !entity.IsEntityValid())
			return;
		
		entity.Input("EnableCollision");
		entity.Input("TurnOn");
		entity.SetKeyValue("solid", 6);
		entity.SetNetPropInt("m_bFlashing", 0);
		entity.SetNetPropInt("m_noGhostCollision", 0);
		
		entity.SetColor(255, 255, 255, 255);
		entity.SetRenderMode(RENDER_NORMAL);
		entity.SetRenderEffects(RENDERFX_NONE);
	},
	
	function MakeEntityType(entity, targetName, params = {})
	{
		if(entity == null || !entity.IsEntityValid())
			return;
		
		entity.SetNetPropString("m_iName", targetName);
		entity.SetNetPropInt("m_bFlashing", 0);
		entity.SetNetPropInt("m_iTeamNum", 0);
		entity.SetNetPropInt("m_noGhostCollision", 0);
		
		switch(targetName)
		{
			case "teleport":
				entity.SetRenderMode(RENDER_TRANSCOLOR);
				entity.SetColor(0, 0, 255, 255);
				break;
			case "trampoline":
				entity.SetRenderMode(RENDER_TRANSCOLOR);
				entity.SetColor(255, 255, 0, 255);
				break;
			case "catapult":
				entity.SetRenderMode(RENDER_TRANSCOLOR);
				entity.SetColor(0, 255, 0, 255);
				break;
			case "damage":
				entity.SetRenderMode(RENDER_TRANSCOLOR);
				entity.SetColor(255, 0, 0, 255);
				break;
			case "fall":
				entity.SetRenderMode(RENDER_TRANSCOLOR);
				entity.SetColor(128, 128, 64, 255);
				break;
			case "death":
				entity.SetRenderMode(RENDER_TRANSCOLOR);
				entity.SetColor(0, 0, 0, 255);
				break;
		}
		
		printl("entity type: " + entity.GetNetPropString("m_iName") + " created");
	},
	
	function Timer_EntityTypeTrigger(params)
	{
		if(!("client" in params) || !("object" in params) || params["client"] == null || params["object"] == null ||
			!params["client"].IsPlayerEntityValid() || !params["object"].IsEntityValid() || params["client"].IsDead())
			return;
		
		// 检查玩家是否离开了这个板块
		local index = params["client"].GetIndex();
		if(!(index in ::ObjectSpawner.PlayerGround) || ::ObjectSpawner.PlayerGround[index] == null ||
			!::ObjectSpawner.PlayerGround[index].IsEntityValid() ||
			::ObjectSpawner.PlayerGround[index].GetBaseEntity() != params["object"].GetBaseEntity())
			return;
		
		// 限制实体可以触发的队伍
		/*
		local entityTeam = params["object"].GetNetPropInt("m_iTeamNum");
		if(entityTeam > 0 && params["client"].GetTeam() != entityTeam)
			return;
		*/
		
		local targetName = params["object"].GetNetPropString("m_iName");
		switch(targetName)
		{
			case "bhop":
				if(params["object"].GetNetPropBool("m_bFlashing"))
					break;
				
				params["object"].SetNetPropInt("m_bFlashing", 1);
				params["object"].Input("DisableCollision");
				params["object"].Input("TurnOff");
				params["object"].SetKeyValue("solid", 0);
				
				params["object"].SetRenderMode(RENDER_TRANSCOLOR);
				params["object"].SetRenderEffects(RENDERFX_PULSE_SLOW);
				params["object"].SetColor(255, 255, 255, 128);
				
				Timers.AddTimerOne("timer_bhop_reset_" + params["object"].GetIndex(), ::ObjectSpawner.ConfigVar.BhopDuration,
					::ObjectSpawner.Timer_ResetBhopEntity, params["object"]);
				
				params["client"].ClientCommand("play ui/littlereward.wav");
				printl("bhop break by " + params["client"].GetName());
				break;
			case "trampoline":
				// params["client"].PlaySound("buttons/blip1.wav");
				params["client"].ClientCommand("play buttons/blip1.wav");
				params["client"].SetVelocity(params["client"].GetVelocity() + Vector(0, 0, ::ObjectSpawner.ConfigVar.TrampolinePower));
				break;
			case "catapult":
				local velocity = params["client"].GetEyeAngles().Forward().Scale(::ObjectSpawner.ConfigVar.CatapultPower);
				velocity.z = ::ObjectSpawner.ConfigVar.CatapultHeight;
				// params["client"].PlaySound("buttons/blip1.wav");
				params["client"].ClientCommand("play buttons/blip1.wav");
				params["client"].SetVelocity(velocity);
				break;
			case "gravity":
				if(!(index in ::ObjectSpawner.PlayerStatus) || ::ObjectSpawner.PlayerStatus[index] != 1)
				{
					::ObjectSpawner.ResetPlayerData(params["client"]);
					::ObjectSpawner.PlayerStatus[index] <- 1;
					params["client"].SetGravity(::ObjectSpawner.ConfigVar.Gravity);
				}
				break;
			case "skate":
				if(!(index in ::ObjectSpawner.PlayerStatus) || ::ObjectSpawner.PlayerStatus[index] != 2)
				{
					::ObjectSpawner.ResetPlayerData(params["client"]);
					::ObjectSpawner.PlayerStatus[index] <- 2;
					params["client"].SetFriction(::ObjectSpawner.ConfigVar.Friction);
				}
				break;
			case "shake":
				::ObjectSpawner.ResetPlayerData(params["client"]);
				params["client"].Shake(0.1);
				break;
			case "movement":
				if(!(index in ::ObjectSpawner.PlayerStatus) || ::ObjectSpawner.PlayerStatus[index] != 3)
				{
					::ObjectSpawner.ResetPlayerData(params["client"]);
					::ObjectSpawner.PlayerStatus[index] <- 3;
					params["client"].SetNetPropFloat("m_flLaggedMovementValue", ::ObjectSpawner.ConfigVar.Movement);
				}
				break;
			case "fall":
				::ObjectSpawner.ResetPlayerData(params["client"]);
				break;
			case "teleport":
				::ObjectSpawner.ResetPlayerData(params["client"]);
				// params["client"].PlaySound("level/startwam.wav");
				params["client"].ClientCommand("play level/startwam.wav");
				
				local idx = params["object"].GetIndex();
				if(idx in ::ObjectSpawner.ObjectSpawned && "teleport" in ::ObjectSpawner.ObjectSpawned[idx].parameter)
				{
					params["client"].SetLocation(::ObjectSpawner.ObjectSpawned[idx].parameter["teleport"]);
					
					if("eyeangles" in ::ObjectSpawner.ObjectSpawned[idx].parameter)
						params["client"].SetEyeAngles(::ObjectSpawner.ObjectSpawned[idx].parameter["eyeangles"]);
				}
				
				break;
			case "damage":
				::ObjectSpawner.ResetPlayerData(params["client"]);
				params["client"].Damage(::ObjectSpawner.ConfigVar.DamageAmount, DMG_BURN, params["object"]);
				break;
			case "death":
				::ObjectSpawner.ResetPlayerData(params["client"]);
				params["client"].ClientCommand("play ui/critical_event_1.wav");
				params["client"].Kill();
				break;
			case "fade":
				::ObjectSpawner.ResetPlayerData(params["client"]);
				params["client"].Fade(0, 0, 0, 255, 0.1);
				break;
		}
	},
	
	function ActiveEntityEffect(player, entity)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead() ||
			entity == null || !entity.IsEntityValid())
			return false;
		
		// 实体正在等待恢复，防止多次触发
		if(entity.GetNetPropBool("m_bFlashing"))
			return false;
		
		local index = player.GetIndex();
		local name = entity.GetNetPropString("m_iName");
		
		switch(name)
		{
			case "bhop":
				::ObjectSpawner.ResetPlayerData(player);
				Timers.AddTimerOne("timer_entitytype_" + player.GetIndex(), ::ObjectSpawner.ConfigVar.BhopDelay,
					::ObjectSpawner.Timer_EntityTypeTrigger, {client = player, object = entity});
				break;
			case "trampoline":
				::ObjectSpawner.ResetPlayerData(player);
				Timers.AddTimerOne("timer_entitytype_" + player.GetIndex(), ::ObjectSpawner.ConfigVar.TrampolineDelay,
					::ObjectSpawner.Timer_EntityTypeTrigger, {client = player, object = entity});
				break;
			case "catapult":
				::ObjectSpawner.ResetPlayerData(player);
				Timers.AddTimerOne("timer_entitytype_" + player.GetIndex(), ::ObjectSpawner.ConfigVar.CatapultDelay,
					::ObjectSpawner.Timer_EntityTypeTrigger, {client = player, object = entity});
				break;
			case "damage":
				::ObjectSpawner.ResetPlayerData(player);
				Timers.AddTimerOne("timer_entitytype_" + player.GetIndex(), ::ObjectSpawner.ConfigVar.DamageDelay,
					::ObjectSpawner.Timer_EntityTypeTrigger, {client = player, object = entity});
				break;
			case "gravity":
			case "skate":
			case "shake":
			case "movement":
			case "fall":
			case "teleport":
				Timers.RemoveTimerByName("timer_entitytype_" + player.GetIndex());
				::ObjectSpawner.Timer_EntityTypeTrigger({client = player, object = entity});
				break;
			default:
				return false;
		}
		
		return true;
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
	
	function Timer_PlayerGroundCheck(params)
	{
		foreach(player in Players.All())
		{
			if(player.IsDead() || player.IsGhost() || player.GetTeam() == SPECTATORS)
				continue;
			
			if(player.IsSurvivor())
			{
				if(player.IsIncapacitated() || player.IsHangingFromLedge() || player.GetCurrentAttacker() != null)
					continue;
			}
			else if(player.GetCurrentVictim() != null)
				continue;
			
			local index = player.GetIndex();
			local entity = ::ObjectSpawner.GetPlayerGroundEntity(player, ::ObjectSpawner.ConfigVar.GroundDistance);
			if(entity != null && entity.IsEntityValid())
			{
				::ObjectSpawner.PlayerGround[index] <- entity;
				if(::ObjectSpawner.ActiveEntityEffect(player, entity))
					continue;
			}
			
			if(player.GetFlags() & FL_ONGROUND)
				::ObjectSpawner.ResetPlayerData(player);
		}
	}
	
	function FindEntity(params)
	{
		if("object" in params)
			return params["object"];
		
		if("classname" in params && "origin" in params)
			return Objects.OfClassnameNearest(params["classname"], params["origin"], 5);
		
		return null;
	},
	
	// TODO: 实现保存功能
	RescueClosetSpawned = {},
	
	// 创建一个厕所复活门(就是开门复活队友那种)
	// 代码是抄 http://forums.alliedmods.net/showthread.php?t=223138 的
	function SpawnRescueCloset(origin, angles)
	{
		// 厕所
		local closet = Utils.CreateEntity("prop_dynamic_override", origin, angles,
			{solid = 6, model = "models/props_urban/outhouse002.mdl"});
		
		if(closet == null)
			return null;
		
		// 厕所门
		local door = Utils.CreateEntity("prop_door_rotating", origin, angles,
			{solid = 6, disableshadows = 1, distance = 100, spawnpos = 0, opendir = 1, spawnflags = 532480,
			model = "models/props_urban/outhouse_door001.mdl"});
		
		if(door == null)
		{
			closet.Kill();
			return null;
		}
		
		// 把厕所门附加到厕所上
		door.Input("SetParent", "!activator", 0, closet);
		door.SetLocation(Vector(27.5, -17.0, 3.49));
		door.Input("ClearParent", "", 0, closet);
		
		local rescue = Utils.CreateEntity("info_survivor_rescue", origin, angles,
			{solid = 0, rescueEyePos = angles, mins = Vector(-5.0, -5.0, -5.0), maxs = Vector(-5.0, -5.0, 50.0),
			model = "models/editor/playerstart.mdl"});
		
		if(rescue == null)
		{
			closet.Kill();
			door.Kill();
			return null;
		}
		
		rescue.Input("TurnOn");
		rescue.Input("SetParent", "!activator", 0, closet);
		rescue.SetLocation(Vector(1.0, 0.0, 5.5));
		
		::ObjectSpawner.RescueClosetSpawned[closet.GetIndex()] <-
		{
			"closet" : closet,
			"door" : door,
			"rescue" : rescue
		};
		
		return closet;
	},
	
	// TODO: 实现保存功能
	HealthCabinetSpawned = {},
	
	// 创建一个医疗箱(就是墙壁上红色带门的那个)
	// 代码是抄 http://forums.alliedmods.net/showthread.php?t=175154 的
	function SpawnHealthCabinet(origin, angles, spawnTable = {})
	{
		local cabinet = Utils.CreateEntity("prop_health_cabinet", origin, angles,
			{movetype = MOVETYPE_NONE, model = "models/props_interiors/medicalcabinet02.mdl"});
		
		if(cabinet == null)
			return null;
		
		cabinet.SetNetPropInt("m_iGlowType", 3);
		cabinet.SetNetPropInt("m_glowColorOverride", 0xFFFF0000);
		cabinet.SetNetPropInt("m_nGlowRange", 150);
		cabinet.SetNetPropInt("m_nGlowRangeMin", 1);
		cabinet.SetMoveType(MOVETYPE_NONE);
		cabinet.ConnectOutput("OnAnimationDone", ::ObjectSpawner.OnOutput_HealthCabinetOpening, "_object_spawner");
		
		::ObjectSpawner.HealthCabinetSpawned[cabinet.GetIndex()] <-
		{
			"cabinet" : cabinet,
			"spawnTable" : spawnTable,
			"spawnedEntity" : {}
		};
		
		return cabinet;
	},
	
	function OnOutput_HealthCabinetOpening()
	{
		if(caller == null || activator == null || !caller.IsValid() || !activator.IsValid())
			return;
		
		local player = ::VSLib.Player(activator);
		if(!player.IsSurvivor())
			return;
		
		local entity = ::VSLib.Entity(caller);
		
		if(::ObjectSpawner.SpawnHealthCabinetItem(entity))
			entity.DisconnectOutput("OnAnimationDone", "_object_spawner");
	},
	
	function SpawnHealthCabinetItem(entity)
	{
		if(entity == null || !entity.IsEntityValid() || entity.GetClassname() != "prop_health_cabinet")
			return -1;
		
		local index = entity.GetIndex();
		if(!(index in ::ObjectSpawner.HealthCabinetSpawned) || ::ObjectSpawner.HealthCabinetSpawned[index] == null)
			return -1;
		
		if(::ObjectSpawner.HealthCabinetSpawned[index]["spawnTable"].len() <= 0)
			return 0;
		
		local function CheckSpawnType(type)
		{
			/*
			if(type >= 1 && type <= 4)
				return type;
			
			return Utils.GetRandNumber(1, 4);
			*/
			
			if(type == 0)
				return Utils.GetRandNumber(1, 4);
			
			if(type >= 1 && type <= 4)
				return type;
			
			return -1;
		};
		
		local function GetSpawnClassname(type)
		{
			switch(type)
			{
				case 1:
					return "weapon_pain_pills_spawn";
				case 2:
					return "weapon_adrenaline_spawn";
				case 3:
					return "weapon_first_aid_kit_spawn";
				case 4:
					return "weapon_defibrillator_spawn";
			}
			
			return "";
		};
		
		local function MoveForward(origin, angles, distance)
		{
			local dir = angles.Forward();
			return Vector(origin.x + (dir.x * distance), origin.y + (dir.y * distance), origin.z + (dir.z * distance));
		};
		
		local function MoveSideway(origin, angles, distance)
		{
			local dir = angles.Left();
			distance *= -1.0;
			dir = QAngle(-(dir.x), -(dir.y), -(dir.z));
			return Vector(origin.x + (dir.x * distance), origin.y + (dir.y * distance), origin.z);
		};
		
		local spawnEntity = null;
		local lastOrigin = entity.GetLocation();
		local lastAngles = entity.GetAngles();
		local tempOrigin = null;
		local tempAngles = null;
		local entitySpawned = 0;
		
		foreach(placed, spawnType in ::ObjectSpawner.HealthCabinetSpawned[index]["spawnTable"])
		{
			placed = placed.tointeger();
			if(placed < 1 || placed > 4)
				continue;
			
			if(placed in ::ObjectSpawner.HealthCabinetSpawned[index]["spawnedEntity"] &&
				::ObjectSpawner.HealthCabinetSpawned[index]["spawnedEntity"][placed] != null &&
				::ObjectSpawner.HealthCabinetSpawned[index]["spawnedEntity"][placed].IsEntityValid())
				continue;
			
			spawnType = CheckSpawnType(spawnType);
			if(spawnType == -1)
				continue;
			
			tempOrigin = lastOrigin;
			tempAngles = lastAngles;
			tempOrigin = MoveForward(tempOrigin, tempAngles, 3.0);
			
			switch(placed)
			{
				case 1:
				{
					tempOrigin = MoveSideway(tempOrigin, tempAngles, -9.0);
					tempOrigin.z += 37.0;
					break;
				}
				case 2:
				{
					tempOrigin = MoveSideway(tempOrigin, tempAngles, 9.0);
					tempOrigin.z += 37.0;
					break;
				}
				case 3:
				{
					tempOrigin = MoveSideway(tempOrigin, tempAngles, 9.0);
					tempOrigin.z += 51.0;
					break;
				}
				case 4:
				{
					tempOrigin = MoveSideway(tempOrigin, tempAngles, -9.0);
					tempOrigin.z += 51.0;
					break;
				}
			}
			
			tempAngles.y += 180.0;
			
			spawnEntity = Utils.SpawnWeapon(GetSpawnClassname(spawnType), 1, 1, tempAngles,
				{solid = 0, disableshadows = 1, movetype = MOVETYPE_PUSH});
			
			if(spawnEntity != null)
			{
				spawnEntity.SetMoveType(MOVETYPE_PUSH);
				entitySpawned += 1;
			}
			
			::ObjectSpawner.HealthCabinetSpawned[index]["spawnedEntity"][placed] <- spawnEntity;
		}
		
		return entitySpawned;
	},
	
	// TODO: 实现保存功能
	FootLockerSpawned = {},
	
	// 创建一个绿色箱子，里面有无限物品（或者有限）
	// 代码是抄 https://forums.alliedmods.net/showthread.php?t=157183 的
	// 参考 https://developer.valvesoftware.com/wiki/L4D2_Level_Design/Foot_Lockers
	function SpawnFootLocker(origin, angles, spawnTable = {})
	{
		// 绿色箱子的模型，这个模型没有实现碰撞盒子，需要手动创建一个
		local greenbox = Utils.CreateEntity("prop_dynamic", origin, angles,
			{solid = 0, fademaxdist = 1920, fademindist = 1501, model = "models/props_waterfront/footlocker01.mdl"});
		
		if(greenbox == null)
			return null;
		
		// 创建箱子的光圈
		greenbox.SetNetPropInt("m_iGlowType", 3);
		greenbox.SetNetPropInt("m_glowColorOverride", 0xFF00FF00);
		greenbox.SetNetPropInt("m_nGlowRange", 150);
		
		// 设置一个名字，用于打开箱子
		local index = greenbox.GetIndex();
		local targetName = "_object_spawner_footlocker_" + greenbox.GetIndex();
		greenbox.SetKeyValue("targetname", targetName);
		
		local cover = Utils.CreateEntity("prop_dynamic_override", origin + Vector(0, 0, 10), angles,
			{solid = 6, fademaxdist = 1920, fademindist = 1501, disableshadows = 1,
			model = "models/props_crates/supply_crate02_gib2.mdl"});
		
		if(cover == null)
		{
			greenbox.Kill();
			return null;
		}
		
		local event = Utils.CreateEntity("logic_game_event", origin, angles,
			{targetname = "_object_spawner_footlocker_event_" + index,
			spawnflags = 1, eventName = "foot_locker_opened"});
		
		if(event == null)
		{
			greenbox.Kill();
			cover.Kill();
			return null;
		}
		
		local button = Utils.CreateEntity("func_button", origin, angles,
			{glow = targetName, rendermode = 3, spawnflags = 1025,
			mins = Vector(-14.0, -25.0, -12.0), maxs = Vector(13.0, 25.0, 12.0),
			targetname = "_object_spawner_footlocker_button_" + index});
		
		if(button == null)
		{
			greenbox.Kill();
			cover.Kill();
			event.Kill();
			return null;
		}
		
		button.Input("Enable");
		button.Input("AddOutput", "OnPressed !self:Kill::0.1:1");
		button.Input("AddOutput", "OnPressed _object_spawner_footlocker_" + index + ":SetAnimation:opening:0:1");
		button.Input("AddOutput", "OnPressed _object_spawner_footlocker_event_" + index + ":FireEvent::0:1");
		greenbox.ConnectOutput("OnAnimationBegun", ::ObjectSpawner.OnOutput_FootLockerOpening, "_object_spawner");
		
		local remarkable = Utils.CreateEntity("info_remarkable", origin + Vector(0, 0, 10), angles,
			{contextsubject = "WorldFootLocker"});
		
		::ObjectSpawner.FootLockerSpawned[index] <-
		{
			"footlocker" : greenbox,
			"cover" : cover,
			"button" : button,
			"remarkable" : remarkable,
			"spawnTable" : spawnTable
		};
		
		return greenbox;
	},
	
	function OnOutput_FootLockerOpening()
	{
		if(caller == null || activator == null || !caller.IsValid() || !activator.IsValid())
			return;
		
		local player = ::VSLib.Player(activator);
		if(!player.IsSurvivor())
			return;
		
		local entity = ::VSLib.Entity(caller);
		if(::ObjectSpawner.SpawnFootLockerItem(entity))
			entity.DisconnectOutput("OnAnimationBegun", "_object_spawner");
	},
	
	function SpawnFootLockerItem(entity)
	{
		if(entity == null || !entity.IsEntityValid() || entity.GetClassname() != "prop_dynamic")
			return false;
		
		local index = entity.GetIndex();
		if(!(index in ::ObjectSpawner.FootLockerSpawned) || ::ObjectSpawner.FootLockerSpawned[index] == null)
			return false;
		
		// TODO: 生还者说找到了一个补给箱
		entity.Input("StopGlowing");
		entity.EmitSound("Trunk.Open");
		
		local function GetSpawnClassname(spawnTable)
		{
			if(typeof(spawnTable) == "string")
				return spawnTable;
			
			if(typeof(spawnTable) != "array" && typeof(spawnTable) != "table")
				return "";
			
			local number = Utils.GetRandNumber(1, spawnTable.len());
			foreach(items in spawnTable)
			{
				if((number -= 1) <= 0)
					return items;
			}
			
			return "";
		};
		
		// 刷物品
		local classname = GetSpawnClassname(::ObjectSpawner.FootLockerSpawned[index]["spawnTable"]);
		if(classname == null)
			return false;
		
		local function MoveSideway(origin, angles, distance)
		{
			local dir = angles.Left();
			distance *= -1.0;
			dir = QAngle(-(dir.x), -(dir.y), -(dir.z));
			return Vector(origin.x + (dir.x * distance), origin.y + (dir.y * distance), origin.z);
		};
		
		local origin = entity.GetLocation();
		local angles = entity.GetAngles();
		
		local tempOrigin = origin;
		local tempAngles = angles;
		
		local weapon = null;
		if(classname == "weapon_fireworkcrate" || classname == "weapon_gascan" ||
			classname == "weapon_fireworkcrate_spawn" || classname == "weapon_gascan_spawn")
		{
			tempAngles = QAngle(angles.x, angles.y, angles.z + 90.0);
			
			for(local i = 0; i < 8; ++i)
			{
				tempOrigin = MoveSideway(origin, angles, (i - 3.5) * 6.0);
				weapon = Utils.CreateEntity(classname, tempOrigin, tempAngles,
					{disableshadows = 1, model = "models/props_junk/explosive_box001.mdl"});
				if(weapon != null)
					weapon.SetMoveType(MOVETYPE_PUSH);
			}
		}
		else
		{
			tempOrigin += Vector(0, 0, 5);
			if(classname != "weapon_adrenaline" && classname != "weapon_adrenaline_spawn")
				tempAngles = QAngle(angles.x, angles.y, angles.z + 90.0);
			
			weapon = Utils.CreateEntity(classname, tempOrigin, tempAngles, {disableshadows = 1});
			if(weapon != null)
				weapon.SetMoveType(MOVETYPE_PUSH);
		}
	},
	
	function FindNamedObject(name)
	{
		local object = null;
		name = name.tolower();
		
		foreach(each in ::ObjectSpawner.ObjectNamed)
		{
			if(each["cmd"].tolower() == name)
			{
				object = each;
				break;
			}
		}
		
		return object;
	},
	
	function SpawnEntity(commands, pos, ang, params = {})
	{
		local object = ::ObjectSpawner.FindNamedObject(commands);
		local lastOrigin = pos;
		local lastAngles = ang;
		
		local entity = ::ObjectSpawner.FindEntity(params);
		if(entity == null || !entity.IsEntityValid())
		{
			if(object == null)
			{
				// 使用模型刷出实体
				
				if(!("solid" in params))
					params.solid <- 6;
				
				entity = Utils.SpawnDynamicProp(commands, pos, ang, params);
			}
			else
			{
				// 刷出偏移
				if(object["pos"] != null)
					pos += object["pos"];
				if(object["ang"] != null)
					ang += object["ang"];
				
				if(object["ent"] == "weapon_ammo_spawn" || object["ent"] == "weapon_ammo" || object["ent"] == "weapon_ammo_pack")
				{
					// 弹药堆
					entity = Utils.SpawnAmmo(object["models"], pos, ang);
				}
				else if(object["ent"] == "weapon_scavenge_item_spawn")
				{
					// 黄色油桶，被打爆可以在刷
					entity = Utils.CreateEntity(object["ent"], pos, ang, {glowstate = 0});
				}
				else if(object["ent"].find("weapon_") == 0)
				{
					// 武器刷出
					if(object["ent"] == "weapon_melee" || object["ent"] == "weapon_melee_spawn")
					{
						// 近战武器专用
						entity = g_ModeScript.SpawnMeleeWeapon(object["models"], pos, ang);
						if(entity == null || !("IsValid" in entity) || !entity.IsValid())
							return false;
						
						entity = ::VSLib.Entity(entity);
					}
					else
					{
						// 刷出一般武器
						entity = Utils.SpawnWeapon(object["ent"], object["count"], object["ammo"], pos, ang,
							{solid = 0, spawnflags = 2});
						
						if(object["ent"].find("_spawn") != null &&
							(entity == null || !("IsValid" in entity) || !entity.IsValid()))
						{
							object["ent"] = Utils.StringReplace(object["ent"], "_spawn", "");
							printl("Warring: weapon " + object["ent"] + " not support '_spawn' suffix");
							
							entity = Utils.SpawnWeapon(object["ent"], object["count"], object["ammo"], pos, ang,
								{solid = 0, spawnflags = 2});
						}
					}
				}
				else if(object["ent"].find("upgrade_") == 0)
				{
					// 已经放置好的升级包
					entity = Utils.SpawnUpgrade(object["ent"], object["count"], pos, ang);
				}
				else if(object["ent"] == "prop_fuel_barrel")
				{
					// 白色固定油桶
					entity = Utils.SpawnFuelBarrel(pos, ang);
				}
				else if(object["ent"] == "prop_minigun")
				{
					// 二代固定机枪
					entity = Utils.SpawnMinigun(pos, ang);
				}
				else if(object["ent"] == "prop_minigun_l4d1")
				{
					// 一代固定机枪
					entity = Utils.SpawnL4D1Minigun(pos, ang);
				}
				else if(object["ent"] == "prop_mounted_machine_gun")
				{
					// 二代固定机枪，并且 L4D1 生还者 BOT 会使用
					entity = Utils.SpawnMountedGun(pos, ang);
				}
				else if(object["ent"] == "info_survivor_rescue")
				{
					// 复活点，一般放在带门的小房间里
					entity = Utils.CreateEntity(object["ent"], pos, ang, {rescueEyePos = ang, solid = 0, maxs = Vector(-5.0, -5.0, 50.0), mins = Vector(-5.0, -5.0, -5.0), model = "models/editor/playerstart.mdl"});
				}
				else if(object["ent"] == "info_zombie_spawn")
				{
					// 刷僵尸用的
					entity = Utils.CreateEntity(object["ent"], pos, ang, {population = params["zombie"], offer_tank = 1});
				}
				else if(object["ent"] == "commentary_zombie_spawner")
				{
					// 刷僵尸用的，这个可以刷罕见的普感
					entity = Utils.CreateEntity(object["ent"], pos, ang);
				}
				else if(object["ent"] == "env_rock_launcher")
				{
					// 石头发射器
					entity = Utils.CreateEntity(object["ent"], pos, ang, {RockDamageOverride = 0, RockTargetName = ""});
				}
				else if(object["ent"] == "info_l4d1_survivor_spawn")
				{
					// 一代生还者
					// Utils.SpawnSurvivor(object["ammo"], pos, ang);
					Utils.SpawnL4D1Survivor(object["ammo"], pos, ang);
					return true;
				}
				else if(object["ent"] == "make_entity_position")
				{
					// 修改实体位置
					entity = ::ObjectSpawner.FindEntity(params);
					if(entity == null || !entity.IsEntityValid())
					{
						Utils.SayToAll("Can not find entity " + params["classname"] + " with (" +
							params["origin"].x + ", " + params["origin"].y + ", " + params["origin"].z + ")");
						return false;
					}
					
					entity.SetLocation(pos);
					entity.SetAngles(ang);
				}
				else if(object["ent"].find("prop_dynamic") == 0)
				{
					// 不可移动的实体
					entity = Utils.SpawnDynamicProp(object["models"], pos, ang, params);
				}
				else if(object["ent"].find("prop_physics") == 0)
				{
					// 物理实体，拥有物理效果
					entity = Utils.SpawnPhysicsProp(object["models"], pos, ang, params);
				}
				else if(object["ent"] == "entity_type")
				{
					// 实体效果
					entity = ::ObjectSpawner.FindEntity(params);
					
					if(!("entity_type" in params))
					{
						params["teleport"] <- pos;
						params["eyeangles"] <- ang;
						params["entity_type"] <- object["cmd"];
					}
				}
			}
			
			if(object != null)
			{
				if(object["ent"] == "info_zombie_spawn")
				{
					params["nexttime"] <- Time() + params["interval"];
					::ObjectSpawner.ZombieSpawnParams[entity.GetIndex()] <- params;
					entity.AddThinkFunction(::ObjectSpawner.OnEntityThink_ZombieSpawn);
					entity.SetNextThinkTime(Time() + 1.0);
					
					entity.Input("SpawnZombie");
				}
				else if(object["ent"] == "commentary_zombie_spawner")
				{
					params["nexttime"] <- Time() + params["interval"];
					::ObjectSpawner.ZombieSpawnParams[entity.GetIndex()] <- params;
					entity.AddThinkFunction(::ObjectSpawner.OnEntityThink_InfectedSpawn);
					entity.SetNextThinkTime(Time() + 1.0);
					
					entity.Input("SpawnZombie", "common");
				}
				else if(object["ent"] == "env_rock_launcher")
				{
					params["nexttime"] <- Time() + params["interval"];
					::ObjectSpawner.RockLauncherParams[entity.GetIndex()] <- params;
					entity.AddThinkFunction(::ObjectSpawner.OnEntityThink_RockLauncher);
					entity.SetNextThinkTime(Time() + 1.0);
					
					entity.Input("LaunchRock");
				}
				else if(object["ent"] == "info_l4d1_survivor_spawn")
				{
					foreach(survivor in Players.L4D1Survivors())
						survivor.SetNetPropInt("m_bSurvivorGlowEnabled", 0);
				}
				else if(object["ent"] == "weapon_scavenge_item_spawn")
				{
					entity.Input("SpawnItem");
				}
			}
		}
		
		if(entity == null || !entity.IsEntityValid())
			return false;
		
		if("entity_type" in params)
			::ObjectSpawner.MakeEntityType(entity, params["entity_type"], params);
		
		entity.SetMoveType(MOVETYPE_NONE);
		
		::ObjectSpawner.ObjectIndex += 1;
		entity.SetNetPropInt("m_iHammerID", ::ObjectSpawner.ObjectIndex);
		
		local function MergeTable(t1, t2, filter = @(k, v1, v2) true)
		{
			local t = t1;
			
			foreach(k, v in t2)
			{
				if(k in t1)
				{
					if(filter(k, t1[k], t2[k]))
						t[k] <- t2[k];
				}
				else if(filter(k, null, t2[k]))
					t[k] <- t2[k];
			}
			
			return t;
		};
		
		local index = entity.GetIndex();
		if(!(index in ::ObjectSpawner.ObjectSpawned) || ::ObjectSpawner.ObjectSpawned[index] == null)
			::ObjectSpawner.ObjectSpawned[index] <- {};
		
		// 当前位置和角度
		::ObjectSpawner.ObjectSpawned[index].origin <- pos;
		::ObjectSpawner.ObjectSpawned[index].angles <- ang;
		
		// 输入的位置和角度
		::ObjectSpawner.ObjectSpawned[index]._origin <- lastOrigin;
		::ObjectSpawner.ObjectSpawned[index]._angles <- lastAngles;
		
		// 实体参数
		::ObjectSpawner.ObjectSpawned[index].cmd <- commands;
		::ObjectSpawner.ObjectSpawned[index].entity <- entity;
		::ObjectSpawner.ObjectSpawned[index].parameter <- params;
		
		// 创建保存数据
		::ObjectSpawner.ObjectSpawned[index].filestring <- ::ObjectSpawner.BuildString(
			entity, commands, lastOrigin, lastAngles, params);
		
		/*
		if(index in ::ObjectSpawner.ObjectSpawned && ::ObjectSpawner.ObjectSpawned[index] != null)
		{
			::ObjectSpawner.ObjectSpawned[index].position = pos;
			::ObjectSpawner.ObjectSpawned[index].angles = ang;
			::ObjectSpawner.ObjectSpawned[index].parameter =
				MergeTable(::ObjectSpawner.ObjectSpawned[index].parameter, params,
				@(k, v1, v2) (k == "classname" || k == "origin" || k == "entity_type" || k == "nexttime" ||
				k == "interval" || k == "zombie" || k == "teleport" || k == "eyeangles"));
		}
		else
		{
			::ObjectSpawner.ObjectSpawned[index] <-
			{
				object = entity,
				position = pos,
				angles = ang,
				cmd = commands,
				filestring = "",
				parameter = MergeTable({}, params, @(k, v1, v2) (k == "classname" || k == "origin" ||
					k == "entity_type" || k == "nexttime" || k == "interval" || k == "zombie" || k == "teleport" ||
					k == "eyeangles"))
			};
			
			// ::ObjectSpawner.ObjectSpawned[index].filestring = ::ObjectSpawner.BuildString(entity);
		}
		
		::ObjectSpawner.ObjectSpawned[index].filestring = ::ObjectSpawner.BuildString(
			entity, commands, lastOrigin, lastAngles, params);
		*/
		
		printl(::ObjectSpawner.ObjectSpawned[index].filestring);
		
		return true;
	},
	
	function GetFindEntity(entity)
	{
		if(entity == null || !entity.IsEntityValid())
			return null;
		
		local index = entity.GetIndex();
		if(index in ::ObjectSpawner.ObjectSpawned && ::ObjectSpawner.ObjectSpawned[index] != null)
			return {};
		
		return {classname = entity.GetClassname(), origin = entity.GetLocation()};
	},
	
	function SetupEntityType(entity, entityType, params = {})
	{
		if(entity == null || !entity.IsEntityValid())
			return false;
		
		local index = entity.GetIndex();
		if(index in ::ObjectSpawner.ObjectSpawned && ::ObjectSpawner.ObjectSpawned[index] != null)
		{
			/*
			::ObjectSpawner.ObjectSpawned[index].origin = entity.GetLocation();
			::ObjectSpawner.ObjectSpawned[index].angles = entity.GetAngles();
			
			local object = ::ObjectSpawner.FindNamedObject(::ObjectSpawner.ObjectSpawned[index].cmd);
			if(object != null)
			{
				::ObjectSpawner.ObjectSpawned[index]._origin = ::ObjectSpawner.ObjectSpawned[index].origin - object.pos;
				::ObjectSpawner.ObjectSpawned[index]._angles = ::ObjectSpawner.ObjectSpawned[index].angles - object.ang;
			}
			else
			{
				::ObjectSpawner.ObjectSpawned[index]._origin = ::ObjectSpawner.ObjectSpawned[index].origin;
				::ObjectSpawner.ObjectSpawned[index]._angles = ::ObjectSpawner.ObjectSpawned[index].angles;
			}
			*/
			
			foreach(key, value in params)
				::ObjectSpawner.ObjectSpawned[index].parameter[key] <- value;
			
			params["entity_type"] <- entityType;
			
			// 更新保存数据
			::ObjectSpawner.ObjectSpawned[index].filestring = ::ObjectSpawner.BuildString(
				entity, null, null, null, ::ObjectSpawner.ObjectSpawned[index].parameter);
		}
		else
		{
			::ObjectSpawner.ObjectSpawned[index] <- {};
			
			// 寻找实体用
			params["classname"] <- entity.GetClassname();
			params["origin"] <- entity.GetLocation();
			params["entity_type"] <- entityType;
			
			// 当前位置和角度
			::ObjectSpawner.ObjectSpawned[index].origin <- params["origin"];
			::ObjectSpawner.ObjectSpawned[index].angles <- entity.GetAngles();
			
			// 输入的位置和角度
			::ObjectSpawner.ObjectSpawned[index]._origin <- ::ObjectSpawner.ObjectSpawned[index].origin;
			::ObjectSpawner.ObjectSpawned[index]._angles <- ::ObjectSpawner.ObjectSpawned[index].angles;
			
			// 实体参数
			::ObjectSpawner.ObjectSpawned[index].cmd <- null;
			::ObjectSpawner.ObjectSpawned[index].entity <- entity;
			::ObjectSpawner.ObjectSpawned[index].parameter <- params;
			
			// 创建保存数据
			::ObjectSpawner.ObjectSpawned[index].filestring <- ::ObjectSpawner.BuildString(
				entity, null, ::ObjectSpawner.ObjectSpawned[index].origin,
				::ObjectSpawner.ObjectSpawned[index].angles, params);
		}
		
		if("entity_type" in params)
			::ObjectSpawner.MakeEntityType(entity, params["entity_type"], params);
		
		return true;
	},
	
	function SetupEntityOrigin(entity, newOirign, newAngles, oldOrigin = null, oldAngles = null)
	{
		if(entity == null || !entity.IsEntityValid())
			return false;
		
		local index = entity.GetIndex();
		if(index in ::ObjectSpawner.ObjectSpawned && ::ObjectSpawner.ObjectSpawned[index] != null)
		{
			::ObjectSpawner.ObjectSpawned[index].origin = newOirign;
			::ObjectSpawner.ObjectSpawned[index].angles = newAngles;
			
			foreach(key, value in params)
				::ObjectSpawner.ObjectSpawned[index].parameter[key] <- value;
			
			// 更新保存数据
			::ObjectSpawner.ObjectSpawned[index].filestring = ::ObjectSpawner.BuildString(
				entity, null, null, null, ::ObjectSpawner.ObjectSpawned[index].parameter);
		}
		else
		{
			::ObjectSpawner.ObjectSpawned[index] <- {};
			
			if(oldOrigin == null)
			{
				printl("Warring: not oldOrigin");
				oldOrigin = newOirign;
			}
			
			// 寻找实体用
			params["classname"] <- entity.GetClassname();
			params["origin"] <- entity.GetLocation();
			
			// 当前位置和角度
			::ObjectSpawner.ObjectSpawned[index].origin <- params["origin"];
			::ObjectSpawner.ObjectSpawned[index].angles <- entity.GetAngles();
			
			// 输入的位置和角度
			::ObjectSpawner.ObjectSpawned[index]._origin <- ::ObjectSpawner.ObjectSpawned[index].origin;
			::ObjectSpawner.ObjectSpawned[index]._angles <- ::ObjectSpawner.ObjectSpawned[index].angles;
			
			// 实体参数
			::ObjectSpawner.ObjectSpawned[index].cmd <- null;
			::ObjectSpawner.ObjectSpawned[index].entity <- entity;
			::ObjectSpawner.ObjectSpawned[index].parameter <- params;
			
			// 创建保存数据
			::ObjectSpawner.ObjectSpawned[index].filestring <- ::ObjectSpawner.BuildString(
				entity, null, ::ObjectSpawner.ObjectSpawned[index].origin,
				::ObjectSpawner.ObjectSpawned[index].angles, params);
		}
		
		entity.SetLocation(newOirign);
		entity.SetAngles(newAngles);
		
		return true;
	},
	
	function VectorToString(vec, prefix = "")
	{
		/*
		if(typeof(vec) == "Vector")
			return "Vector(" + vec.x + ", " + vec.y + ", " + vec.z + ")";
		else if(typeof(vec) == "QAngle")
			return "QAngle(" + vec.x + ", " + vec.y + ", " + vec.z + ")";
		*/
		return prefix + "(" + vec.x + ", " + vec.y + ", " + vec.z + ")";
	},
	
	function BuildString(entity, cmds = null, position = null, angles = null, params = null)
	{
		if(entity == null || !entity.IsEntityValid())
			return null;
		
		local function TableToString(table)
		{
			if(typeof(table) != "table" || table.len() <= 0)
				return "{}";
			
			local str = "";
			foreach(k, v in table)
			{
				switch(k)
				{
					case "classname":
					case "entity_type":
					case "nexttime":
					case "interval":
					case "zombie":
						if(str.len() > 0)
							str += ", ";
						
						str += k + @" = """ + v + @"""";
						break;
					case "origin":
					case "teleport":
						if(str.len() > 0)
							str += ", ";
						
						str += k + " = " + ::ObjectSpawner.VectorToString(v, "Vector");
						break;
					case "eyeangles":
					case "angles":
						if(str.len() > 0)
							str += ", ";
						
						str += k + " = " + ::ObjectSpawner.VectorToString(v, "QAngle");
						break;
				}
			}
			
			return "{" + str + "}";
		};
		
		local index = entity.GetIndex();
		if(position == null || angles == null || cmds == null)
		{
			if(!(index in ::ObjectSpawner.ObjectSpawned) || ::ObjectSpawner.ObjectSpawned[index] == null)
				return null;
			
			if(position == null)
				position = ::ObjectSpawner.ObjectSpawned[index]._origin;
			if(angles == null)
				angles = ::ObjectSpawner.ObjectSpawned[index]._angles;
			if(params == null)
				params = ::ObjectSpawner.ObjectSpawned[index].parameter;
			if(cmds == null)
				cmds = ::ObjectSpawner.ObjectSpawned[index].cmd;
		}
		
		if(params == null)
			params = {};
		
		return @"::ObjectSpawner.SpawnEntity(""" + cmds + @""", " +
			::ObjectSpawner.VectorToString(position, "Vector") + ", " +
			::ObjectSpawner.VectorToString(angles, "QAngle") + ", " +
			TableToString(params) + ");";
	},
	
	function SaveToFile()
	{
		::ObjectSpawner.ScipteToFileString = "";
		foreach(index, params in ::ObjectSpawner.ObjectSpawned)
			::ObjectSpawner.ScipteToFileString += params.filestring + "\n";
		
		if(::ObjectSpawner.ScipteToFileString.len() > 0)
		{
			::ObjectSpawner.ScipteToFileString = strip(::ObjectSpawner.ScipteToFileString);
			StringToFile("spawner/" + ::ObjectSpawner.CurrentMapName + ".nut", ::ObjectSpawner.ScipteToFileString);
		}
		
		// printl(::ObjectSpawner.ScipteToFileString);
	},
	
	ConvertWeaponSpawn = null,
	AllowWeaponSpawn = null,
	function PauseSpawnBlocker()
	{
		if("ConvertWeaponSpawn" in SessionOptions)
		{
			if(::ObjectSpawner.ConvertWeaponSpawn == null)
				::ObjectSpawner.ConvertWeaponSpawn = SessionOptions.ConvertWeaponSpawn;
			
			SessionOptions.ConvertWeaponSpawn = @(classname) 0;
		}
		
		if("AllowWeaponSpawn" in SessionOptions)
		{
			if(::ObjectSpawner.AllowWeaponSpawn == null)
				::ObjectSpawner.AllowWeaponSpawn = SessionOptions.AllowWeaponSpawn;
			
			SessionOptions.AllowWeaponSpawn = @(classname) true;
		}
	},
	
	function UnpauseSpawnBlocker()
	{
		if(::ObjectSpawner.ConvertWeaponSpawn != null && "ConvertWeaponSpawn" in SessionOptions)
			SessionOptions.ConvertWeaponSpawn = ::ObjectSpawner.ConvertWeaponSpawn;
		if(::ObjectSpawner.AllowWeaponSpawn != null && "AllowWeaponSpawn" in SessionOptions)
			SessionOptions.AllowWeaponSpawn = ::ObjectSpawner.AllowWeaponSpawn;
	},
	
	function TimerLoad_OnRoundStart(params)
	{
		if(::ObjectSpawner.CurrentMapName == "")
		{
			if("MapName" in SessionState && SessionState.MapName != "")
				::ObjectSpawner.CurrentMapName = SessionState.MapName;
			else
				::ObjectSpawner.CurrentMapName = Utils.StringReplace(Convars.GetStr("host_map"), ".bsp", "");
		}
		
		// 搜索最高的 HammerID
		::ObjectSpawner.ObjectIndex = 0;
		foreach(entity in Objects.All())
		{
			local hammerId = entity.GetNetPropInt("m_iHammerID");
			if(hammerId > ::ObjectSpawner.ObjectIndex)
				::ObjectSpawner.ObjectIndex = hammerId;
		}
		
		::ObjectSpawner.PauseSpawnBlocker();
		
		// 从 ems 里加载文件
		::ObjectSpawner.ScipteToFileString = FileToString("spawner/" + ::ObjectSpawner.CurrentMapName + ".nut");
		if(::ObjectSpawner.ScipteToFileString == null)
		{
			::ObjectSpawner.ScipteToFileString = "";
			printl("file " + ::ObjectSpawner.CurrentMapName + ".nut not found");
		}
		else
		{
			try
			{
				compilestring(::ObjectSpawner.ScipteToFileString)();
				printl("file ems/spawner/" + ::ObjectSpawner.CurrentMapName + ".nut load done");
			}
			catch(err)
			{
				printl("file " + ::ObjectSpawner.CurrentMapName + ".nut error: " + err);
			}
		}
		
		try
		{
			// 从 scripts/vscripts 里加载文件
			IncludeScript("spawner/" + ::ObjectSpawner.CurrentMapName + ".nut");
			printl("file scripts/vscripts/spawner/" + ::ObjectSpawner.CurrentMapName + ".nut load done");
		}
		catch(err)
		{
			printl("file " + ::ObjectSpawner.CurrentMapName + ".nut error: " + err);
		}
		
		local stripper = FileToString("stripper/" + ::ObjectSpawner.CurrentMapName + ".cfg");
		if(stripper != null)
		{
			::ObjectSpawner.ParseStripper(stripper);
			printl("stripper loading...");
		}
	},
	
	function Timer_GrabbedEntity(params)
	{
		foreach(index, each in ::ObjectSpawner.CurrentGrabbed)
		{
			if(each.grabber == null || !each.grabber.IsPlayerEntityValid() ||
				each.object == null || !each.object.IsEntityValid())
				continue;
			
			if(each.grabber.IsPressingAttack())
			{
				each.distance += 10;
				::ObjectSpawner.CurrentGrabbed[index].distance = each.distance;
			}
			else if(each.grabber.IsPressingShove())
			{
				each.distance -= 10;
				::ObjectSpawner.CurrentGrabbed[index].distance = each.distance;
			}
			
			if(each.grabber.IsPressingUse())
			{
				// 左转
				each.object.SetAngles(each.object.GetAngles() + QAngle(0, 15, 0));
			}
			else if(each.grabber.IsPressingReload())
			{
				// 右转
				each.object.SetAngles(each.object.GetAngles() + QAngle(0, -15, 0));
			}
			
			if(each.grabber.IsPressingWalk())
			{
				// 上转
				each.object.SetAngles(each.object.GetAngles() + QAngle(-15, 0, 0));
			}
			else if(each.grabber.IsPressingDuck())
			{
				// 下转
				each.object.SetAngles(each.object.GetAngles() + QAngle(15, 0, 0));
			}
			
			if(each.grabber.IsPressingButton(BUTTON_SCORE))
			{
				// 左斜
				each.object.SetAngles(each.object.GetAngles() + QAngle(0, 0, -15));
			}
			else if(each.grabber.IsPressingJump())
			{
				// 右斜
				each.object.SetAngles(each.object.GetAngles() + QAngle(0, 0, 15));
			}
			
			// 让实体跟随玩家眼睛移动
			/*
			each.object.SetVelocity(((each.grabber.GetEyePosition() + each.grabber.GetEyeAngles().Forward() *
				each.distance) - each.object.GetLocation()).Scale(10));
			*/
			
			/*
			local start = each.grabber.GetEyePosition();
			local end = each.grabber.GetLookingLocation();
			local dist = Utils.CalculateDistance(start, end);
			local dir = end - start;
			if(dist == 0.0)
				dist = 1.0;
			
			local pos = Vector(0, 0, 0);
			pos.x = (start.x - dir.x * each.distance / dist) + each.offset.x;
			pos.y = (start.y - dir.y * each.distance / dist) + each.offset.y;
			pos.z = (start.z - dir.z * each.distance / dist) + each.offset.z;
			pos.z = floor(pos.z) * 1.0;
			each.object.SetLocation(pos);
			*/
			
			// 让实体跟随玩家瞄准的位置
			each.object.SetLocation(each.grabber.GetEyePosition() +
				each.grabber.GetEyeAngles().Forward().Scale(each.distance) +
				each.offset);
		}
	}
};

function Notifications::OnRoundBegin::ObjectSpawner_StartSpawn(params)
{
	if(!::ObjectSpawner.ConfigVar.Enable || !::ObjectSpawner.ConfigVar.AutoLoad)
		return;
	
	Timers.AddTimerByName("timer_objectspawner", 1.0, false, ::ObjectSpawner.TimerLoad_OnRoundStart);
	printl("load object spawnning...");
	
	Timers.AddTimerByName("timer_grabbedfllow", 0.1, true, ::ObjectSpawner.Timer_GrabbedEntity);
	Timers.AddTimerByName("timer_playerground", 0.1, true, ::ObjectSpawner.Timer_PlayerGroundCheck);
}

function Notifications::FirstSurvLeftStartArea::ObjectSpawner_StartGrabbed(player, params)
{
	Timers.AddTimerByName("timer_grabbedfllow", 0.1, true, ::ObjectSpawner.Timer_GrabbedEntity);
	Timers.AddTimerByName("timer_playerground", 0.1, true, ::ObjectSpawner.Timer_PlayerGroundCheck);
}

function Notifications::OnSurvivorsDead::ObjectSpawner_AutoSave()
{
	if(::ObjectSpawner.ScriptChanged)
	{
		::ObjectSpawner.SaveToFile();
		printl("save spawner by mission lost");
	}
	
	::ObjectSpawner.ScriptChanged = false;
}

function Notifications::OnMapEnd::ObjectSpawner_AutoSave()
{
	if(::ObjectSpawner.ScriptChanged)
	{
		::ObjectSpawner.SaveToFile();
		printl("save spawner by change level");
	}
	
	::ObjectSpawner.ScriptChanged = false;
}

function Notifications::OnFirstSpawn::ObjectSpawner_LogMaps(player, params)
{
	if("map_name" in params && ::ObjectSpawner.CurrentMapName == "")
	{
		printl("map start. old = " + ::ObjectSpawner.CurrentMapName + ", new = " + params["map_name"]);
		::ObjectSpawner.CurrentMapName = params["map_name"];
	}
}

function EasyLogic::OnTakeDamage::ObjectSpawner_FallDamage(dmgTable)
{
	if(dmgTable["Victim"] == null || dmgTable["DamageDone"] <= 0.0 || !dmgTable["Victim"].IsSurvivor())
		return true;
	
	if(dmgTable["DamageType"] & DMG_FALL)
	{
		local entity = ::ObjectSpawner.GetPlayerGroundEntity(dmgTable["Victim"], ::ObjectSpawner.ConfigVar.GroundDistance);
		if(entity != null && entity.IsEntityValid() && entity.GetNetPropString("m_iName") == "fall")
		{
			// dmgTable["Victim"].ShowHint("Safe landing");
			dmgTable["Victim"].ClientCommand("play ui/pickup_secret01.wav");
			return false;
		}
	}
	
	return true;
}

function CommandTriggersEx::si(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	local name = GetArgument(1);
	if(name == null || name == "")
	{
		player.ShowHint("Must provide at least one parameter", 9);
		return;
	}
	
	local object = ::ObjectSpawner.FindNamedObject(name);
	
	if(object == null)
	{
		player.ShowHint("This option does not exist", 9);
		return;
	}
	
	local pos = player.GetLookingLocation();
	local ang = player.GetEyeAngles();
	ang.x = 0;
	ang.z = 0;
	
	if(object["ent"] == "env_rock_launcher" || object["ent"] == "info_zombie_spawn" ||
		object["ent"] == "info_survivor_rescue" || object["ent"] == "commentary_zombie_spawner")
		pos = player.GetLocation();
	
	local parameter = {};
	if(object["ent"] == "env_rock_launcher")
	{
		// 发射间隔
		parameter["interval"] <- GetArgument(2).tofloat();
	}
	else if(object["ent"] == "info_zombie_spawn" || object["ent"] == "commentary_zombie_spawner")
	{
		// 刷出什么僵尸
		parameter["zombie"] <- GetArgument(2);
		
		// 刷出间隔
		parameter["interval"] <- GetArgument(3).tofloat();
	}
	else if(object["ent"].find("prop_dynamic") == 0 || object["ent"].find("prop_physics") == 0)
	{
		// 在玩家脚下刷出实体
		pos = player.GetLocation();
	}
	
	if(!::ObjectSpawner.SpawnEntity(name, pos, ang, parameter))
	{
		player.ShowHint("Failed to create " + object["ent"], 9);
		return;
	}
	
	::ObjectSpawner.ScriptChanged = true;
}

function CommandTriggersEx::grab(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	local entity = null;
	local classname = GetArgument(1);
	if(classname != null && classname != "")
		entity = Objects.OfClassnameNearest(classname, player.GetLocation(), 65535);
	else
		entity = player.GetLookingEntity(TRACE_MASK_PLAYER_SOLID);
	
	local index = player.GetIndex();
	if(!(index in ::ObjectSpawner.CurrentGrabbed))
	{
		if(entity == null || !entity.IsEntityValid() || entity.IsPlayer())
		{
			player.ShowHint("Can not find any entity or invalid target");
			return;
		}
		
		::ObjectSpawner.CurrentGrabbed[index] <-
		{
			grabber = player,																	// 抓住实体的玩家
			object = entity,																	// 被抓住的实体
			distance = Utils.CalculateDistance(player.GetEyePosition(), entity.GetLocation()),	// 距离
			offset = entity.GetLocation() - player.GetLookingLocation(TRACE_MASK_PLAYER_SOLID),	// 位置偏移
			classname = entity.GetClassname(),													// 类名
			hammer = entity.GetNetPropInt("m_iHammerID"),										// 地图编辑器ID
			models = entity.GetModel(),															// 模型
			origin = entity.GetLocation(),														// 原来的位置
			angles = entity.GetAngles(),														// 原来的角度
			movetype = entity.GetMoveType(),													// 移动类型
			glowtype = entity.GetNetPropInt("m_Glow.m_iGlowType"),								// 光圈类型
			glowrange = entity.GetNetPropInt("m_Glow.m_nGlowRange"),							// 光圈范围
			glowcolor = entity.GetNetPropInt("m_Glow.m_glowColorOverride"),						// 光圈颜色
			rendermode = entity.GetNetPropInt("m_nRenderMode"),									// 渲染模式
			renderfx = entity.GetNetPropInt("m_nRenderFX"),										// 渲染效果
			rendercolor = entity.GetNetPropInt("m_clrRender"),									// 渲染颜色
			solidtype = entity.GetNetPropInt("m_Collision.m_nSolidType"),						// 固体类型
			solidflags = entity.GetNetPropInt("m_Collision.m_usSolidFlags"),					// 固体标记
			collision = entity.GetNetPropInt("m_CollisionGroup")								// 材质类型
		};
		
		local classname = entity.GetClassname();
		if(classname == "prop_physics" || classname == "prop_physics_multiplayer")
		{
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
		
		entity.SetRenderMode(RENDER_TRANSCOLOR);
		entity.SetRenderEffects(RENDERFX_PULSE_SLOW);
		entity.SetColor(255, 255, 255, 128);
		
		entity.Input("DisableCollision");
		// entity.SetNetPropInt("m_Collision.m_nSolidType", 0);
		// entity.SetNetPropInt("m_Collision.m_usSolidFlags", 4);
		entity.SetNetPropInt("m_Glow.m_iGlowType", 2);
		entity.SetNetPropInt("m_Glow.m_nGlowRange", 1024);
		entity.SetNetPropInt("m_Glow.m_glowColorOverride", Utils.SetColor32(255, 255, 255, 255));
		
		player.ShowHint("grabbed " + entity.GetClassname() + " hammerId " + entity.GetNetPropInt("m_iHammerID"), 9);
		player.PlaySound("buttons/combine_button5.wav");
		
		/*
		local pos = ::ObjectSpawner.CurrentGrabbed[index].origin;
		local ang = ::ObjectSpawner.CurrentGrabbed[index].angles;
		local newScrpitString = "";
		local reVector = regexp(@"Vector\(-?(?:\d+(?:\.\d+)?), ?-?(?:\d+(?:\.\d+)?), ?-?(?:\d+(?:\.\d+)?)\)");
		local reFirst = regexp(@"^::ObjectSpawner\.SpawnEntity\(""(\w+)"", ?(Vector\(-?(?:\d+(?:\.\d+)?), ?-?(?:\d+(?:\.\d+)?), ?-?(?:\d+(?:\.\d+)?)\))");
		local reSecond = regexp(@"^::ObjectSpawner\.SpawnEntity\(""(\w+)"", ?Vector\(-?(?:\d+(?:\.\d+)?), ?-?(?:\d+(?:\.\d+)?), ?-?(?:\d+(?:\.\d+)?)\), QAngle\(-?(?:\d+(?:\.\d+)?), ?-?(?:\d+(?:\.\d+)?), ?-?(?:\d+(?:\.\d+)?)\), ?\{classname ?= ?""(\w+)"", ?origin ?= ?(Vector\(-?(?:\d+(?:\.\d+)?), ?-?(?:\d+(?:\.\d+)?), ?-?(?:\d+(?:\.\d+)?)\))");
		local reGetParam = regexp(@"^::ObjectSpawner\.SpawnEntity\(""(\w+)"", ?Vector\(-?(?:\d+(?:\.\d+)?), ?-?(?:\d+(?:\.\d+)?), ?-?(?:\d+(?:\.\d+)?)\), QAngle\(-?(?:\d+(?:\.\d+)?), ?-?(?:\d+(?:\.\d+)?), ?-?(?:\d+(?:\.\d+)?)\), ?(\{.*\})\);?$");
		
		foreach(line in split(::ObjectSpawner.ScipteToFileString, "\r\n"))
		{
			line = strip(line);
			local matGrabbed = null;
			if(reVector.match(line))
			{
				if((matGrabbed = reSecond.capture(line)) != null)
				{
					// 移动位置检查
					local origin = compilestring(line.slice(matGrabbed[3].begin, matGrabbed[3].end))();
					if(Utils.CalculateDistance(origin, pos) <= 5)
					{
						printl("remove line " + line);
						continue;
					}
				}
				else if((matGrabbed = reFirst.capture(line)) != null)
				{
					// 创建检查
					local origin = compilestring(line.slice(matGrabbed[2].begin, matGrabbed[2].end))();
					if(Utils.CalculateDistance(origin, pos) <= 5)
					{
						if(!reGetParam.match(line))
						{
							printl("get params fail " + line);
							continue;
						}
						
						::ObjectSpawner.CurrentGrabbedString[index] <-
						{
							cmd = line.slice(matGrabbed[1].begin, matGrabbed[1].end),
							params = strip(line.slice(matGrabbed[2].begin + 1, matGrabbed[2].end))
						}
						
						printl("delete line " + line);
						continue;
					}
				}
			}
			
			newScrpitString += line + "\n";
		}
		
		::ObjectSpawner.ScipteToFileString = newScrpitString;
		*/
	}
	else
	{
		entity = ::ObjectSpawner.CurrentGrabbed[index].object;
		if(entity == null || !entity.IsEntityValid())
		{
			player.ShowHint("Invalid entity", 9);
			delete ::ObjectSpawner.CurrentGrabbed[index];
			return;
		}
		
		entity.Input("EnableCollision");
		entity.SetNetPropEntity("m_hPhysicsAttacker", null);
		entity.SetNetPropFloat("m_flLastPhysicsInfluenceTime", 0.0);
		entity.SetMoveType(::ObjectSpawner.CurrentGrabbed[index].movetype);
		entity.SetRenderMode(::ObjectSpawner.CurrentGrabbed[index].rendermode);
		entity.SetRenderEffects(::ObjectSpawner.CurrentGrabbed[index].renderfx);
		entity.SetNetPropInt("m_clrRender", ::ObjectSpawner.CurrentGrabbed[index].rendercolor);
		// entity.SetNetPropInt("m_Collision.m_nSolidType", ::ObjectSpawner.CurrentGrabbed[index].solidtype);
		// entity.SetNetPropInt("m_Collision.m_usSolidFlags", ::ObjectSpawner.CurrentGrabbed[index].solidflags);
		entity.SetNetPropInt("m_Glow.m_iGlowType", ::ObjectSpawner.CurrentGrabbed[index].glowtype);
		entity.SetNetPropInt("m_Glow.m_nGlowRange", ::ObjectSpawner.CurrentGrabbed[index].glowrange);
		entity.SetNetPropInt("m_Glow.m_glowColorOverride", ::ObjectSpawner.CurrentGrabbed[index].glowcolor);
		
		local pos = entity.GetLocation();
		local ang = entity.GetAngles();
		// entity.SetLocation(::ObjectSpawner.CurrentGrabbed[index].origin);
		// entity.SetAngles(::ObjectSpawner.CurrentGrabbed[index].angles);
		
		/*
		if(index in ::ObjectSpawner.CurrentGrabbedString)
		{
			if(::ObjectSpawner.SpawnEntity(::ObjectSpawner.CurrentGrabbedString[index].cmd, pos, ang,
				compilestring(::ObjectSpawner.CurrentGrabbedString[index].params)()))
			{
				::ObjectSpawner.ScipteToFileString += "::ObjectSpawner.SpawnEntity(\"" +
					::ObjectSpawner.CurrentGrabbedString[index].cmd + "\", Vector(" +
					pos.x + ", " + pos.y + ", " + pos.z + "), QAngle(" + ang.x + ", " + ang.y + ", " + ang.z + "), ";
				
				::ObjectSpawner.ScipteToFileString += ::ObjectSpawner.CurrentGrabbed[index].params;
				::ObjectSpawner.ScipteToFileString += ");\n";
				
				entity.Kill();
				StringToFile("spawner/" + ::ObjectSpawner.CurrentMapName + ".nut", ::ObjectSpawner.ScipteToFileString);
			}
			
			delete ::ObjectSpawner.CurrentGrabbedString[index];
		}
		else
		{
			if(::ObjectSpawner.SpawnEntity("pos", pos, ang, ::ObjectSpawner.CurrentGrabbed[index]))
			{
				::ObjectSpawner.ScipteToFileString += "::ObjectSpawner.SpawnEntity(\"pos\", Vector(" +
					pos.x + ", " + pos.y + ", " + pos.z + "), QAngle(" + ang.x + ", " + ang.y + ", " + ang.z + "), {";
				
				::ObjectSpawner.ScipteToFileString += "classname = \"" + ::ObjectSpawner.CurrentGrabbed[index].classname + "\", ";
				::ObjectSpawner.ScipteToFileString += "origin = Vector(" +
					::ObjectSpawner.CurrentGrabbed[index].origin.x + ", " +
					::ObjectSpawner.CurrentGrabbed[index].origin.y + ", " +
					::ObjectSpawner.CurrentGrabbed[index].origin.z + "), ";
				::ObjectSpawner.ScipteToFileString += "hammer = " + ::ObjectSpawner.CurrentGrabbed[index].hammer;
				
				::ObjectSpawner.ScipteToFileString += "});\n";
				StringToFile("spawner/" + ::ObjectSpawner.CurrentMapName + ".nut", ::ObjectSpawner.ScipteToFileString);
			}
		}
		*/
		
		local entIndex = entity.GetIndex();
		if(entIndex in ::ObjectSpawner.ObjectSpawned && ::ObjectSpawner.ObjectSpawned[entIndex] != null)
		{
			// 修改已经刷出的实体的位置
			::ObjectSpawner.ObjectSpawned[entIndex].origin = pos;
			::ObjectSpawner.ObjectSpawned[entIndex].angles = ang;
			
			local lastOrigin = pos;
			local lastAngles = ang;
			
			local commands = ::ObjectSpawner.ObjectSpawned[entIndex].cmd;
			if(commands != null && commands in ::ObjectSpawner.ObjectNamed)
			{
				local entCmd = ::ObjectSpawner.ObjectNamed[commands];
				lastOrigin -= entCmd.pos;
				lastAngles -= entCmd.ang;
				
				// 起始位置偏移
				::ObjectSpawner.ObjectSpawned[entIndex]._origin = lastOrigin;
				::ObjectSpawner.ObjectSpawned[entIndex]._angles = lastAngles;
			}
			
			// 保存到文件的数据
			::ObjectSpawner.ObjectSpawned[entIndex].filestring = ::ObjectSpawner.BuildString(
				entity, commands, lastOrigin, lastAngles,
				::ObjectSpawner.ObjectSpawned[entIndex].parameter);
		}
		else
		{
			// 将地图上已有的实体移动位置
			::ObjectSpawner.SpawnEntity("pos", pos, ang, ::ObjectSpawner.CurrentGrabbed[index]);
		}
		
		// ::ObjectSpawner.SpawnEntity("pos", pos, ang, ::ObjectSpawner.CurrentGrabbed[index]);
		player.ShowHint("release " + ::ObjectSpawner.CurrentGrabbed[index].classname, 9);
		delete ::ObjectSpawner.CurrentGrabbed[index];
	}
	
	::ObjectSpawner.ScriptChanged = true;
}

function CommandTriggersEx::et(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	local index = player.GetIndex();
	if(index in ::ObjectSpawner.PlayerTeleport)
	{
		if(::ObjectSpawner.PlayerTeleport[index] != null && ::ObjectSpawner.PlayerTeleport[index].IsEntityValid())
		{
			local plypos = player.GetLocation();
			local eyeang = player.GetEyeAngles();
			
			local pos = ::ObjectSpawner.PlayerTeleport[index].GetLocation();
			local name = ::ObjectSpawner.PlayerTeleport[index].GetClassname();
			local hammerId = ::ObjectSpawner.PlayerTeleport[index].GetNetPropInt("m_iHammerID");
			
			::ObjectSpawner.SpawnEntity("teleport", pos, ::ObjectSpawner.PlayerTeleport[index].GetAngles(),
				{object = ::ObjectSpawner.PlayerTeleport[index], classname = name, origin = pos, hammer = hammerId,
				teleport = plypos, entity_type = "teleport", eyeangles = eyeang})
		}
		
		delete ::ObjectSpawner.PlayerTeleport[index];
		return;
	}
	
	local entity = null;
	local classname = GetArgument(1);
	if(classname != null && classname != "")
		entity = Objects.OfClassnameNearest(classname, player.GetLocation(), 65535);
	if(entity == null || !entity.IsEntityValid())
		entity = player.GetLookingEntity();
	if(entity == null || !entity.IsEntityValid())
	{
		player.ShowHint("Invalid Entity.", 9);
		return;
	}
	
	local targetName = GetArgument(2);
	if(targetName == null || targetName == "")
		targetName = classname;
	if(targetName == null || targetName == "")
	{
		player.ShowHint("Invalid Entity Type.", 9);
		return;
	}
	
	local object = ::ObjectSpawner.FindNamedObject(targetName);
	
	if(object == null)
	{
		player.ShowHint("This option does not exist", 9);
		return;
	}
	
	if(targetName == "teleport")
	{
		::ObjectSpawner.PlayerTeleport[index] <- entity;
		player.ShowHint("Please select the destination of the teleport");
		return;
	}
	
	local pos = entity.GetLocation();
	local ang = entity.GetAngles();
	
	if(!::ObjectSpawner.SetupEntityType(entity, targetName, object["cmd"]))
	{
		player.ShowHint("Failed to make type " + object["ent"], 9);
		return;
	}
	
	::ObjectSpawner.ScriptChanged = true;
}

function CommandTriggersEx::so(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	::ObjectSpawner.SaveToFile();
	player.ShowHint("save success");
	::ObjectSpawner.ScriptChanged = false;
}


::ObjectSpawner.PLUGIN_NAME <- PLUGIN_NAME;
::ObjectSpawner.ConfigVar = ::ObjectSpawner.ConfigVarDef;

function Notifications::OnRoundStart::ObjectSpawner_LoadConfig()
{
	RestoreTable(::ObjectSpawner.PLUGIN_NAME, ::ObjectSpawner.ConfigVar);
	if(::ObjectSpawner.ConfigVar == null || ::ObjectSpawner.ConfigVar.len() <= 0)
		::ObjectSpawner.ConfigVar = FileIO.GetConfigOfFile(::ObjectSpawner.PLUGIN_NAME, ::ObjectSpawner.ConfigVarDef);

	// printl("[plugins] " + ::ObjectSpawner.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::ObjectSpawner_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::ObjectSpawner.PLUGIN_NAME, ::ObjectSpawner.ConfigVar);

	// printl("[plugins] " + ::ObjectSpawner.PLUGIN_NAME + " saving...");
}
