::DifficultyBanalce <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = false,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = false,

		// 难度上限[0 ~ 100](超过就禁止刷特感)
		MaxIntensity = 75,

		// 难度下限[0 ~ 100](小于时强制刷特感)
		MinIntensity = 25,

		// 进行难度检查的间隔
		UpdateInterval = 15,

		// 每一波特感刷新间隔(秒)
		SpecialSpawn = 30,
		
		// 每一有名活着的生还者需要多少个特感
		// 例如设置为 1 则为 4 人时有 4 特，5 人时有 5 特
		OneSurvivorCount = 1,

		// 每一有名活着的生还者时特感的血量的倍率(百分比)
		// 例如设置为 25 则为 4人 x 25 = 100% 的血量，5 人时有 125% 的血量
		OneSurvivorHealth = 25,

		// Tank 活着时其他特感最大数量
		TankMaxSpecialCount = 0,

		// Tank 死亡后是否引发尸潮
		TankDeathPanicEvent = false,

		// Witch 死亡后是否引发尸潮
		WitchDeathPanicEvent = false,

		// Witch 被激怒是否引发尸潮
		WitchStartledPanicEvent = false,

		// Tank 最小血量
		MinTankHealth = 8000,

		// 难度的强度因素
		IntensityFactor = 0.5,
		HealthFactor = 0.3,
		ItemFactor = 0.25,
		AmmoFactor = 0.05,
		
		// 是否防止被普感攻击打断救人
		NoCommonBlocked = true,
		
		// 是否禁止泡水回血
		NoSurabayaHealing = true
	},

	ConfigVar = {},

	SurvivorIntensity = {},
	AverageIntensity = 0,
	AllIntensity = 0,
	
	/*
	DefaultSessionOptions = {},
	StoreSessionOptions = {
		// 普感
		cm_CommonLimit = "",
		CommonLimit = "",
		WitchLimit = "",
		cm_WitchLimit = "z_common_limit",
		
		// 特感
		cm_MaxSpecials = "",
		cm_BaseSpecialLimit = "",
		MaxSpecials = "survival_max_specials",
		cm_DominatorLimit = "",
		
		SmokerLimit = "z_smoker_limit",
		BoomerLimit = "z_boomer_limit",
		HunterLimit = "z_hunter_limit",
		SpitterLimit = "z_spitter_limit",
		JockeyLimit = "z_jockey_limit",
		ChargerLimit = "z_charger_limit",
		TankLimit = "",
		cm_TankLimit = "",
		
		// 复活间隔
		SpecialInitialSpawnDelayMax = "director_special_initial_spawn_delay_max",
		SpecialInitialSpawnDelayMin = "director_special_initial_spawn_delay_min",
		SpecialRespawnInterval = "z_respawn_interval",
		cm_SpecialRespawnInterval = "director_special_respawn_interval",
		cm_SpecialSlotCountdownTime = ""
	},
	
	function InitSessionOptions()
	{
		if(::DifficultyBanalce.DefaultSessionOptions.len() > 0 ||
			!("SessionOptions" in getroottable()))
			return false;
		
		foreach(option, convar in ::DifficultyBanalce.StoreSessionOptions)
		{
			if(option in ::DifficultyBanalce.DefaultSessionOptions)
				continue;
			
			if(convar != null && convar != "" && convar in ::DifficultyBanalce.DefaultSessionOptions)
				continue;
			
			if(option in SessionOptions)
				::DifficultyBanalce.DefaultSessionOptions[option] <- SessionOptions[option];
			else if(convar != null && convar != "")
				::DifficultyBanalce.DefaultSessionOptions[convar] <- ceil(Convars.GetFloat());
			else
				printl("Warring: SessionOptions invalid (" + option + ", " + convar + ").");
		}
		
		return true;
	},
	*/
	
	// 一个更好的压力检查
	function GetIntensity(player)
	{
		if(player == null || !player.IsSurvivor() || player.IsDead())
			return 0;
		
		local finalIntensity = 0;
		
		// 游戏自带的压力统计
		if(::DifficultyBanalce.ConfigVar.IntensityFactor > 0)
			finalIntensity += player.GetIntensity() * ::DifficultyBanalce.ConfigVar.IntensityFactor;
		
		// 血量
		if(::DifficultyBanalce.ConfigVar.HealthFactor > 0)
		{
			local healthScore = player.GetHealth() / player.GetHealth() * 100;
			if(healthScore > 100)
				healthScore = 100;
			
			finalIntensity += (100 - healthScore) * ::DifficultyBanalce.ConfigVar.HealthFactor;
		}
		
		local inv = player.GetHeldItems();
		
		// 携带的物品
		if(::DifficultyBanalce.ConfigVar.ItemFactor > 0)
		{
			local itemScore = 0;
			local classname = "";
			
			// 投掷武器
			if("slot2" in inv && inv["slot2"] != null && inv["slot2"].IsEntityValid())
			{
				classname = inv["slot2"].GetClassname();
				switch(classname)
				{
					case "weapon_pipe_bomb":
						itemScore += 10;
						break;
					case "weapon_molotov":
						itemScore += 15;
						break;
					case "weapon_vomitjar":
						itemScore += 12;
						break;
				}
			}
			
			// 医疗品
			if("slot3" in inv && inv["slot3"] != null && inv["slot3"].IsEntityValid())
			{
				classname = inv["slot3"].GetClassname();
				switch(classname)
				{
					case "weapon_first_aid_kit":
						itemScore += 60;
						break;
					case "weapon_defibrillator":
						itemScore += 30;
						break;
					case "weapon_upgradepack_incendiary":
						itemScore += 10;
					case "weapon_upgradepack_explosive":
						itemScore += 15;
				}
			}
			
			// 药物
			if("slot4" in inv && inv["slot4"] != null && inv["slot4"].IsEntityValid())
			{
				classname = inv["slot4"].GetClassname();
				switch(classname)
				{
					case "weapon_pain_pills":
						itemScore += 40;
						break;
					case "weapon_adrenaline":
						itemScore += 30;
						break;
				}
			}
			
			if(itemScore > 100)
				itemScore = 100;
			
			finalIntensity += (100 - itemScore) * ::DifficultyBanalce.ConfigVar.ItemFactor;
		}
		
		// 子弹数量
		if(::DifficultyBanalce.ConfigVar.AmmoFactor > 0 && "slot0" in inv && inv["slot0"] != null && inv["slot0"].IsEntityValid())
		{
			local ammoType = inv["slot0"].GetDefaultAmmoType();
			local maxAmmo = inv["slot0"].GetMaxAmmo();
			if(ammoType > AMMOTYPE_ASSAULTRIFLE && ammoType < AMMOTYPE_SNIPERRIFLE && maxAmmo > 0)
			{
				local ammoScore = inv["slot0"].GetAmmo() / maxAmmo * 100;
				if(ammoScore > 100)
					ammoScore = 100;
				
				finalIntensity += (100 - ammoScore) * ::DifficultyBanalce.ConfigVar.AmmoFactor;
			}
		}
		
		if(finalIntensity > 100)
			finalIntensity = 100;
		
		return ceil(finalIntensity);
	},
	
	function TotalIntensity()
	{
		::DifficultyBanalce.AverageIntensity = 0;
		::DifficultyBanalce.AllIntensity = 0;
		if(::DifficultyBanalce.SurvivorIntensity.len() > 0)
			::DifficultyBanalce.SurvivorIntensity.clear();
		
		foreach(player in Players.AliveSurvivors())
		{
			local index = player.GetIndex();
			::DifficultyBanalce.SurvivorIntensity[index] <- ::DifficultyBanalce.GetIntensity(player);
			::DifficultyBanalce.AllIntensity += ::DifficultyBanalce.SurvivorIntensity[index];
			// printl("[balance] player " + player.GetName() + " intensity is " + ::DifficultyBanalce.SurvivorIntensity[index]);
		}
		
		if(::DifficultyBanalce.AllIntensity > 0)
			::DifficultyBanalce.AverageIntensity = ::DifficultyBanalce.AllIntensity / ::DifficultyBanalce.SurvivorIntensity.len();
	},
	
	function GetZombieHealth(type)
	{
		switch(type)
		{
			case Z_COMMON:
			case Z_MOB:
				return ceil(Convars.GetFloat("z_health"));
			case Z_SMOKER:
				return ceil(Convars.GetFloat("z_gas_health"));
			case Z_BOOMER:
				return ceil(Convars.GetFloat("z_exploding_health"));
			case Z_HUNTER:
				return ceil(Convars.GetFloat("z_hunter_health"));
			case Z_SPITTER:
				return ceil(Convars.GetFloat("z_spitter_health"));
			case Z_JOCKEY:
				return ceil(Convars.GetFloat("z_jockey_health"));
			case Z_CHARGER:
				return ceil(Convars.GetFloat("z_charger_health"));
			case Z_WITCH:
			case Z_WITCH_BRIDE:
				return ceil(Convars.GetFloat("z_witch_health"));
			case Z_TANK:
				local tankHealth = -1;
				if("ZombieTankHealth" in SessionOptions)
					tankHealth = SessionOptions.ZombieTankHealth;
				else if("TankHealth" in SessionOptions)
					tankHealth = SessionOptions.TankHealth;
				else
					tankHealth = ceil(Convars.GetFloat("z_tank_health"));
				
				/*
				local difficulty = Utils.GetDifficulty();
				switch(difficulty)
				{
					case "easy":
					case "Easy":
						return (tankHealth / 2);
					case "normal":
					case "Normal":
						return tankHealth;
					case "hard":
					case "Hard":
						return (tankHealth / 2 * 3);
					case "impossible":
					case "Impossible":
						return (tankHealth * 2);
				}
				*/
				
				if(tankHealth < ::DifficultyBanalce.ConfigVar.MinTankHealth)
					tankHealth = ::DifficultyBanalce.ConfigVar.MinTankHealth;
				
				return tankHealth;
			case Z_SURVIVOR:
				return 100;
		}
		
		return -1;
	},
	
	function GetZombieName(type)
	{
		switch(type)
		{
			case Z_COMMON:
			case Z_MOB:
				return "infected";
			case Z_SMOKER:
				return "smoker";
			case Z_BOOMER:
				return "boomer";
			case Z_HUNTER:
				return "hunter";
			case Z_SPITTER:
				return "spitter";
			case Z_JOCKEY:
				return "jockey";
			case Z_CHARGER:
				return "charger";
			case Z_WITCH:
			case Z_WITCH_BRIDE:
				return "witch";
			case Z_TANK:
				return "tank";
			case Z_SURVIVOR:
				return "survivors";
		}
		
		return "";
	}
	
	function GetMaxSpecials()
	{
		if("cm_MaxSpecials" in SessionOptions)
			return SessionOptions.cm_MaxSpecials;
		
		if("MaxSpecials" in SessionOptions)
			return SessionOptions.MaxSpecials;
		
		return floor(Convars.GetFloat("survival_max_specials"));
	},
	
	function SetMaxSpecials(amount)
	{
		if("cm_MaxSpecials" in SessionOptions)
			SessionOptions.cm_MaxSpecials = amount;
		
		if("MaxSpecials" in SessionOptions)
			SessionOptions.MaxSpecials = amount;
		
		Convars.SetValue("survival_max_specials", amount);
	},
	
	function SimulationTakeDamage(victim, damage, damageType)
	{
		if(victim == null || !victim.IsEntityValid() || damage == 0)
			return;
		
		local health = victim.GetRawHealth();
		local buffer = victim.GetHealthBuffer();
		if(victim.GetTeam() == INFECTED)
			buffer = 0;
		
		if(buffer > 0 && damage > 0)
		{
			damage -= buffer;
			if(damage < 0)
			{
				buffer = -damage;
				damage = 0;
			}
			else
				buffer = 0;
		}
		
		if(health > 0 && damage > 0)
		{
			damage -= health;
			if(damage < 0)
			{
				health = -damage;
				damage = 0;
			}
			else
				health = 0;
		}
		
		victim.SetRawHealth(health);
		victim.SetHealthBuffer(buffer);
		
		if(damage != 0 || health <= 0)
			victim.Damage(abs(damage), damageType);
	},
	
	function Timer_BanalceThink(params)
	{
		::DifficultyBanalce.TotalIntensity();
		printl("total intensity " + ::DifficultyBanalce.AllIntensity +
			", survivor count " + ::DifficultyBanalce.SurvivorIntensity.len() +
			", average intensity " + ::DifficultyBanalce.AverageIntensity);
		
		local maxSpecial = ::DifficultyBanalce.GetMaxSpecials();
		if(!("DefaultMaxSpecials" in ::DifficultyBanalce))
			::DifficultyBanalce.DefaultMaxSpecials <- maxSpecial;
		
		if(!::DifficultyBanalce.ConfigVar.Enable)
		{
			if(Convars.GetFloat("director_no_specials") > 0 ||
				maxSpecial != ::DifficultyBanalce.DefaultMaxSpecials)
			{
				Convars.SetValue("director_no_specials", "0");
				Convars.SetValue("director_no_mobs", "0");
				
				/*
				local gamemode = Convars.GetStr("mp_gamemode");
				if(gamemode == "mutation4" || gamemode == "community1" || gamemode == "community2")
					maxSpecial = 8;
				else
					maxSpecial = 4;
				*/
				
				::DifficultyBanalce.SetMaxSpecials(::DifficultyBanalce.DefaultMaxSpecials);
			}
			
			return;
		}
		
		if(!Utils.IsTankPresent())
		{
			maxSpecial = ::DifficultyBanalce.SurvivorIntensity.len() * ::DifficultyBanalce.ConfigVar.OneSurvivorCount;
			if(maxSpecial <= 0)
				maxSpecial = ::DifficultyBanalce.DefaultMaxSpecials;
			
			/*
			local gamemode = Convars.GetStr("mp_gamemode");
			if(gamemode == "mutation4" || gamemode == "community1" || gamemode == "community2")
			{
				// 8 特感模式
				maxSpecial *= 2;
			}
			*/
			
			::DifficultyBanalce.SetMaxSpecials(maxSpecial);
			printl("[Balance] maxSpecial = " + maxSpecial);
		}
		
		if(::DifficultyBanalce.AverageIntensity >= ::DifficultyBanalce.ConfigVar.MaxIntensity)
		{
			// 禁止刷特感和暴动僵尸
			if(Convars.GetFloat("director_no_specials") < 1)
			{
				Convars.SetValue("director_no_specials", "1");
				Convars.SetValue("director_no_mobs", "1");
				printl("special spawn stopped");
			}
		}
		else
		{
			// 解除禁止刷特感和暴动僵尸
			if(Convars.GetFloat("director_no_specials") > 0)
			{
				Convars.SetValue("director_no_specials", "0");
				Convars.SetValue("director_no_mobs", "0");
				printl("special spawn starting");
			}
		}
		
		if(::DifficultyBanalce.AverageIntensity < ::DifficultyBanalce.ConfigVar.MinIntensity)
		{
			local maxCount = Objects.OfClassnameEx("player", @(p) p.IsAlive() && p.GetTeam() == INFECTED);
			
			for(local i = maxCount.len(); i < maxSpecial; ++i)
			{
				srand(Time() + i);
				Utils.SpawnZombie(Utils.GetRandNumber(Z_SMOKER, Z_CHARGER));
			}
			
			printl("force spawn " + (maxSpecial - maxCount.len()) + " special");
		}
	},
	
	function Timer_UpdateConVar(params)
	{
		// 游戏设置(可能需要)
		// Convars.SetValue("allow_all_bot_survivor_team", "1");
		// Convars.SetValue("sb_all_bot_game", "1");
		Convars.SetValue("sv_allow_wait_command", "0");
		Convars.SetValue("director_force_witch", "1");
		Convars.SetValue("director_force_tank", "1");
		Convars.SetValue("survivor_respawn_with_guns", "1");
		Convars.SetValue("sb_max_team_melee_weapons", "4");
		Convars.SetValue("versus_tank_chance", "1");
		Convars.SetValue("versus_tank_chance_finale", "1");
		Convars.SetValue("versus_tank_chance_intro", "1");
		Convars.SetValue("versus_witch_chance", "1");
		Convars.SetValue("versus_witch_chance_finale", "1");
		Convars.SetValue("versus_witch_chance_intro", "1");
		Convars.SetValue("director_must_create_all_scavenge_items", "0");
		Convars.SetValue("director_scavenge_item_override", "0");
		
		// 这个变量最大只能是 1268，再大就会出现 bug 的
		// Convars.SetValue("first_aid_kit_max_heal", "1268");
		// Convars.SetValue("pain_pills_health_threshold", "1268");
		
		// 生还者 BOT 强化
		// Convars.SetValue("sb_max_team_melee_weapons", "1");
		Convars.SetValue("sb_melee_approach_victim", "0");
		// Convars.SetValue("sb_all_bot_game", "1");
		// Convars.SetValue("allow_all_bot_survivor_team", "1");
		Convars.SetValue("sb_allow_shoot_through_survivors", "0");
		Convars.SetValue("sb_allow_leading", "0");
		Convars.SetValue("sb_battlestation_human_hold_time", "2");
		Convars.SetValue("sb_sidestep_for_horde", "1");
		Convars.SetValue("sb_toughness_buffer", "40");
		Convars.SetValue("sb_temp_health_consider_factor", "0.75");
		Convars.SetValue("sb_friend_immobilized_reaction_time_normal", "0.001");
		Convars.SetValue("sb_friend_immobilized_reaction_time_hard", "0.001");
		Convars.SetValue("sb_friend_immobilized_reaction_time_expert", "0.001");
		Convars.SetValue("sb_friend_immobilized_reaction_time_vs", "0.001");
		Convars.SetValue("sb_separation_range", "150");
		Convars.SetValue("sb_separation_danger_min_range", "150");
		Convars.SetValue("sb_separation_danger_max_range", "600");
		Convars.SetValue("sb_escort", "1");
		Convars.SetValue("sb_transition", "0");
		Convars.SetValue("sb_close_checkpoint_door_interval", "0.25");
		Convars.SetValue("sb_max_battlestation_range_from_human", "200");
		Convars.SetValue("sb_battlestation_give_up_range_from_human", "500");
		Convars.SetValue("sb_close_threat_range", "250");
		Convars.SetValue("sb_threat_close_range", "250");
		Convars.SetValue("sb_threat_very_close_range", "250");
		Convars.SetValue("sb_threat_medium_range", "500");
		Convars.SetValue("sb_threat_far_range", "1000");
		Convars.SetValue("sb_threat_very_far_range", "2000");
		Convars.SetValue("sb_neighbor_range", "200");
		Convars.SetValue("sb_follow_stress_factor", "100");
		Convars.SetValue("sb_locomotion_wait_threshold", "2");
		Convars.SetValue("sb_path_lookahead_range", "1000");
		Convars.SetValue("sb_near_hearing_range", "1000");
		Convars.SetValue("sb_far_hearing_range", "2000");
		Convars.SetValue("sb_combat_saccade_speed", "2000");
		
		local basemode = Utils.GetBaseMode();
		local gamemode = Convars.GetStr("mp_gamemode");
		switch(basemode)
		{
			case "coop":
			{
				Convars.SetValue("sv_rescue_disabled", "0");
				SessionOptions.cm_NoRescueClosets <- 0;
				SessionOptions.cm_AllowSurvivorRescue <- 1;
				SessionOptions.ShouldAllowSpecialsWithTank <- false;
				break;
			}
			case "realism":
			{
				Convars.SetValue("sv_disable_glow_survivors", "1");
				Convars.SetValue("sv_disable_glow_faritems", "1");
				Convars.SetValue("sv_rescue_disabled", "1");
				SessionOptions.ShouldAllowSpecialsWithTank <- false;
				break;
			}
			case "survival":
			{
				Convars.SetValue("sv_rescue_disabled", "0");
				SessionOptions.cm_NoRescueClosets <- 0;
				SessionOptions.cm_AllowSurvivorRescue <- 1;
				SessionOptions.cm_AutoReviveFromSpecialIncap <- 1;
				SessionOptions.ShouldAllowSpecialsWithTank <- false;
				SessionOptions.cm_DominatorLimit = 3;
				break;
			}
			case "versus":
			{
				Convars.SetValue("sv_rescue_disabled", "1");
				Convars.SetValue("sv_alltalk", "0");
				SessionOptions.ShouldAllowSpecialsWithTank <- true;
				SessionOptions.cm_DominatorLimit <- 3;
				SessionOptions.cm_ProhibitBosses <- 0;
				break;
			}
			case "scavenge":
			{
				Convars.SetValue("sv_rescue_disabled", "1");
				Convars.SetValue("sv_alltalk", "0");
				SessionOptions.ShouldAllowSpecialsWithTank = true;
				SessionOptions.cm_DominatorLimit <- 3;
				SessionOptions.cm_ProhibitBosses <- 0;
				break;
			}
		}
		
		SessionOptions.cm_NoSurvivorBots <- 0;
		SessionOptions.AllowWitchesInCheckpoints <- false;
		// SessionOptions.cm_ShouldHurry <- 0;
		// SessionOptions.cm_TankRun <- 0;
		// SessionOptions.cm_ShouldEscortHumanPlayers <- 0;
		// SessionOptions.cm_AggressiveSpecials <- false;
		// SessionOptions.ShouldIgnoreClearStateForSpawn <- false;
		
		/*
		local worldspawn = ::VSLib.Entity("worldspawn");
		if(worldspawn != null && worldspawn.IsEntityValid())
		{
			// 把这个设置成 3 会强制刷出的 Witch 闲逛，设置成 0 强制蹲下
			// 修改这个对游戏没有其他影响
			worldspawn.SetKeyValue("timeofday", 0);
			
			worldspawn.SetKeyValue("coldworld", 0);
			worldspawn.SetKeyValue("startdark", 0);
			worldspawn.SetKeyValue("skyname", "sky_l4d_c5_1_hdr");
			
			printl("worldspawn found");
		}
		
		local light_environment = ::VSLib.Entity("light_environment");
		if(light_environment != null && light_environment.IsEntityValid())
		{
			light_environment.SetKeyValue("_light", "255 255 255 200");
			light_environment.SetKeyValue("_ambient", "255 255 255 20");
			light_environment.SetKeyValue("SunSpreadAngle", 0);
			
			printl("light_environment found");
		}
		else
		{
			light_environment = Utils.CreateEntity("light_environment", Vector(0, 0, 0), QAngle(0, 0, 0),
				{_light = "255 255 255 200", _ambient = "255 255 255 20", SunSpreadAngle = 0, pitch = 0,
				_lightHDR = "-1 -1 -1 1", _lightscaleHDR = 0.7, _ambientHDR = "-1 -1 -1 1", _AmbientScaleHDR = 0.7});
			
			printl("light_environment not found");
		}
		*/
		
		printl("modebase = " + basemode + ", gamemode = " + gamemode);
	}
}

function Notifications::OnRoundBegin::BalanceAcitve(params)
{
	/*
	Timers.AddTimerByName("timer_balance", ::DifficultyBanalce.ConfigVar.UpdateInterval, true,
		::DifficultyBanalce.Timer_BanalceThink);
	*/
	Timers.AddTimerByName("timer_balance_convars", 1.0, false, ::DifficultyBanalce.Timer_UpdateConVar);
	
	// SessionOptions.SpecialRespawnInterval <- ::DifficultyBanalce.ConfigVar.SpecialSpawn;
	// SessionOptions.cm_SpecialRespawnInterval <- ::DifficultyBanalce.ConfigVar.SpecialSpawn;
}

function Notifications::FirstSurvLeftStartArea::BalanceAcitve(player, params)
{
	Timers.AddTimerByName("timer_balance", ::DifficultyBanalce.ConfigVar.UpdateInterval, true,
		::DifficultyBanalce.Timer_BanalceThink);
	
	Timers.AddTimerByName("timer_balance_convars", 1.0, false, ::DifficultyBanalce.Timer_UpdateConVar);
	
	printl("=== Balance Started ===");
}

function Notifications::OnSurvivorsDead::BalanceStop()
{
	Timers.RemoveTimerByName("timer_balance");
	Timers.RemoveTimerByName("timer_balance_convars");
	
	printl("=== Balance Stopped ===");
}

function EasyLogic::OnScriptStart::Balance_UpdateSetting()
{
	::DifficultyBanalce.Timer_UpdateConVar(null);
}

function Notifications::OnTankSpawned::Balance_StopSpecialSpawn(player, params)
{
	if(!::DifficultyBanalce.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayer() || player.IsDead())
		return;
	
	::DifficultyBanalce.SetMaxSpecials(::DifficultyBanalce.ConfigVar.TankMaxSpecialCount);
	printl("tank spawn, change max special " + ::DifficultyBanalce.GetMaxSpecials());
}

function Notifications::OnTankKilled::Balance_TankDeath(victim, attacker, params)
{
	if(!::DifficultyBanalce.ConfigVar.Enable)
		return;
	
	if(::DifficultyBanalce.ConfigVar.TankDeathPanicEvent)
	{
		Utils.ForcePanicEvent();
		printl("painc event trigged by tank death");
	}
	
	// 可能有多个 Tank
	if(!Utils.IsTankPresent())
	{
		::DifficultyBanalce.TotalIntensity();
		::DifficultyBanalce.SetMaxSpecials(::DifficultyBanalce.SurvivorIntensity.len() * ::DifficultyBanalce.ConfigVar.OneSurvivorCount);
		
		printl("tank death, change max special " + ::DifficultyBanalce.GetMaxSpecials());
	}
}

function Notifications::OnDeath::Balance_TankDeath(victim, attacker, params)
{
	if(!::DifficultyBanalce.ConfigVar.Enable)
		return;
	
	if(victim == null || victim.GetTeam() != INFECTED || victim.GetType() != Z_TANK)
		return;
	
	Notifications.OnTankKilled.Balance_TankDeath(victim, attacker, params);
}

function Notifications::OnWitchStartled::Balance_WitchAnger(victim, attacker, params)
{
	if(!::DifficultyBanalce.ConfigVar.Enable)
		return;
	
	if(::DifficultyBanalce.ConfigVar.WitchStartledPanicEvent)
	{
		Utils.ForcePanicEvent();
		printl("painc event trigged by witch anger");
	}
}

function Notifications::OnWitchKilled::Balance_WitchDeath(victim, attacker, params)
{
	if(!::DifficultyBanalce.ConfigVar.Enable)
		return;
	
	if(::DifficultyBanalce.ConfigVar.WitchDeathPanicEvent)
	{
		Utils.ForcePanicEvent();
		printl("painc event trigged by witch death");
	}
}

function Notifications::OnSpawn::Balance_UpdateHealth(player, params)
{
	if(!::DifficultyBanalce.ConfigVar.Enable)
		return;
	
	if(::DifficultyBanalce.ConfigVar.OneSurvivorHealth <= 0)
		return;
	
	if(player == null || !player.IsPlayer() || !player.IsAlive() || player.GetTeam() != INFECTED)
		return;
	
	local type = player.GetType();
	if(type < Z_SMOKER || (type > Z_CHARGER && type != Z_TANK))
		return;
	
	::DifficultyBanalce.TotalIntensity();
	
	// 默认血量
	local health = ::DifficultyBanalce.GetZombieHealth(player.GetType());
	if(health <= 0)
		return;
	
	// 需要设置的血量
	health = ceil(health * ::DifficultyBanalce.ConfigVar.OneSurvivorHealth / 100.0 * ::DifficultyBanalce.SurvivorIntensity.len());
	if(health <= 0)
		return;
	
	player.SetMaxHealth(health);
	player.SetHealth(health);
	
	printl("a " + player.GetZombieName() + " spawn, set health " + health);
}

function EasyLogic::OnTakeDamage::Balance_CommonBlockRevive(dmgTable)
{
	if(dmgTable["Victim"] == null || !dmgTable["Victim"].IsSurvivor())
		return true;
	
	if(::DifficultyBanalce.ConfigVar.NoCommonBlocked)
	{
		// 普感攻击生还者会导致救人打断
		if(dmgTable["Attacker"] != null && dmgTable["Attacker"].GetType() == Z_COMMON &&
			dmgTable["Victim"].GetNetPropEntity("m_reviveOwner") != null)
		{
			::DifficultyBanalce.SimulationTakeDamage(dmgTable["Victim"], dmgTable["DamageDone"], DMG_GENERIC);
			return false;
		}
	}
	
	if(::DifficultyBanalce.ConfigVar.NoSurabayaHealing)
	{
		// 这个好像没有触发
		if(((dmgTable["DamageType"] & DMG_POISON) || (dmgTable["DamageType"] & DMG_DROWN)) &&
			dmgTable["Victim"].GetNetPropInt("m_nWaterLevel") >= 2)
		{
			::DifficultyBanalce.SimulationTakeDamage(dmgTable["Victim"], dmgTable["DamageDone"], DMG_GENERIC);
			return false;
		}
	}
	
	return true;
}

function CommandTriggersEx::balance(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	local minIntensity = GetArgument(1);
	local maxIntensity = GetArgument(2);
	if(minIntensity == null)
	{
		::DifficultyBanalce.ConfigVar.Enable = !::DifficultyBanalce.ConfigVar.Enable;
		printl("balance change " + ::DifficultyBanalce.ConfigVar.Enable);
		return;
	}
	
	if(minIntensity.tointeger() > 0)
		::DifficultyBanalce.ConfigVar.MinIntensity <- minIntensity.tointeger();
	if(maxIntensity != null && maxIntensity.tointeger() > 0)
		::DifficultyBanalce.ConfigVar.MaxIntensity <- maxIntensity.tointeger();
	
	if(::DifficultyBanalce.ConfigVar.MaxIntensity < ::DifficultyBanalce.ConfigVar.MinIntensity)
		::DifficultyBanalce.ConfigVar.MaxIntensity <- ::DifficultyBanalce.ConfigVar.MinIntensity;
	
	printl("balance intensity " + ::DifficultyBanalce.ConfigVar.MinIntensity + " to " + ::DifficultyBanalce.ConfigVar.MaxIntensity);
}

::DifficultyBanalce.PLUGIN_NAME <- PLUGIN_NAME;
::DifficultyBanalce.ConfigVar = ::DifficultyBanalce.ConfigVarDef;

function Notifications::OnRoundStart::DifficultyBanalce_LoadConfig()
{
	RestoreTable(::DifficultyBanalce.PLUGIN_NAME, ::DifficultyBanalce.ConfigVar);
	if(::DifficultyBanalce.ConfigVar == null || ::DifficultyBanalce.ConfigVar.len() <= 0)
		::DifficultyBanalce.ConfigVar = FileIO.GetConfigOfFile(::DifficultyBanalce.PLUGIN_NAME, ::DifficultyBanalce.ConfigVarDef);

	// printl("[plugins] " + ::DifficultyBanalce.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::DifficultyBanalce_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::DifficultyBanalce.PLUGIN_NAME, ::DifficultyBanalce.ConfigVar);

	// printl("[plugins] " + ::DifficultyBanalce.PLUGIN_NAME + " saving...");
}
