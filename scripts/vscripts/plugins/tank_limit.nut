::TankLimit <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,

		// 路程达到多少时如果没有刷过 Tank 则强制刷出 (百分比)
		// 允许使用 string 来指定多个，使用 路程:数量 来指定，使用空格隔开
		// 例如 "25:2 50:1 75:3" 效果为 25％ 刷 2 个，50％ 刷 1 个，75％ 刷 3 个
		TankFlowDistance = 65,

		// 路程达到多少时如果没有刷过 Witch 则强制刷出 (百分比)
		// 允许使用 string 来指定多个，使用 路程:数量 来指定，使用空格隔开
		// 例如 "25:2 50:1 75:3" 效果为 25％ 刷 2 个，50％ 刷 1 个，75％ 刷 3 个
		WitchFlowDistance = 45,

		// 是否开启无视队友跑图刷特感
		RushSpawn = false,

		// 跑图达到多少距离时开始刷特感(百分比)
		SpawnFlowDistance = 25,

		// 跑图刷特感每次刷出多少个
		SpawnAmount = 2,

		// 是否开启 Tank 伤害转移
		// 在 Tank 攻击倒地的生还者时如果周围有非倒地的生还者，将伤害转移给他
		// 用于防止故意坑队友，例如有队友倒地了，就跑到倒地的队友旁引 Tank 攻击倒地的队友
		TankDamage = true,
		
		// 是否开启锤地板失衡
		TankStagger = false,
		
		// 坦克最小血量
		TankMinHealth = 8000,
		
		// 是否在 Tank 自杀时重新刷一个
		TankRespawn = true,
		
		// 是否强制允许 Tank 拍飞幸存者
		ForceFliing = true,
	},

	ConfigVar = {},

	GameRulesProxy = null,
	ForceTankCount = 0,
	ForceWitchCount = 0,
	
	TankSpawnFlowDistance = {},
	WitchSpawnFlowDistance = {},
	
	// 战役分数 m_iCampaignScore
	// 回合分数 m_iChapterScore
	// 生还者之间的距离 m_iVersusDistancePerSurvivor
	// 胜利的队伍 m_iWinningTeamNumber
	// 当前是否为第二局 m_bInSecondHalfOfRound
	// 是否正在换图 m_bIsTransitioningToNextMap
	// 是否处于投票再次开始 m_bIsVersusVoteRestarting
	// 生还者分数 m_iSurvivorScore
	// 对抗使用过多次个电击器(每个减25分) m_iVersusDefibsUsed
	function GetGameRules()
	{
		if(GameRulesProxy != null && GameRulesProxy.IsEntityValid())
			return GameRulesProxy;
		
		GameRulesProxy = null;
		foreach(entity in Objects.All())
		{
			if(entity.HasNetProp("m_iServerPlayerCount"))
			{
				GameRulesProxy = entity;
				break;
			}
		}
		
		return GameRulesProxy;
	},
	
	function GetHeightFlowDistancePlayer()
	{
		local heightFlowDistance = 0;
		local heightFlowDistancePlayer = null;
		foreach(player in Players.AliveSurvivors())
		{
			local currentFlowDistance = player.GetFlowDistance();
			if(currentFlowDistance > heightFlowDistance)
			{
				heightFlowDistance = currentFlowDistance;
				heightFlowDistancePlayer = player;
			}
		}
		
		return heightFlowDistancePlayer;
	},
	
	function GetSpanwCount(value, flowDistance = -1)
	{
		if(flowDistance < 0 || flowDistance > 100)
		{
			local player = ::TankLimit.GetHeightFlowDistancePlayer();
			if(player == null)
				return 0;
			
			// 转换为百分比
			flowDistance = player.GetFlowDistance() / g_ModeScript.GetMaxFlowDistance() * 100;
		}
		
		local type = typeof(value);
		switch(type)
		{
			case "integer":
			case "float":
				return (flowDistance >= value ? 1 : 0);
			case "table":
			case "array":
				local amount = 0;
				foreach(dist, count in value)
				{
					if(dist <= flowDistance)
						amount += count;
				}
				return amount;
			case "weakref":
				return ::TankLimit.GetSpanwCount(value.ref(), flowDistance);
			case "string":
				local amount = 0;
				foreach(idx, coll in regexp(@"([0-9\.]{1,3}:[0-9]{1,2})").capture(value))
				{
					local sub = value.slice(coll.begin, coll.end);
					if(sub == null)
						continue;
					
					local spec = sub.find(":");
					if(spec == null || sub.slice(0, spec).tointeger() > flowDistance)
						continue;
					
					amount += sub.slice(spec + 1).tointeger();
				}
				return amount;
			default:
				return -1;
		}
		
		return -1;
	},
	
	function TimerSpawner_OnPlayerThink(params)
	{
		if(!::TankLimit.ConfigVar.Enable)
			return;
		
		local heightFlowDistancePlayer = ::TankLimit.GetHeightFlowDistancePlayer();
		if(heightFlowDistancePlayer == null)
			return;
		
		local maxFlowDistance = g_ModeScript.GetMaxFlowDistance();
		local heightFlowDistance = heightFlowDistancePlayer.GetFlowDistance();
		
		if(heightFlowDistance <= 0 || heightFlowDistancePlayer == null || maxFlowDistance <= 0 ||
			maxFlowDistance < heightFlowDistance)
			return;
		
		// printl("GetMaxFlowDistance = " + maxFlowDistance + ", GetHeightFlowDistance = " + heightFlowDistance);
		
		// 跑得最快的玩家的进度
		heightFlowDistance = heightFlowDistance / maxFlowDistance * 100;
		if(heightFlowDistance < 0.0)
			return;
		
		// printl("GetHeightFlowDistance / GetMaxFlowDistance * 100 = " + heightFlowDistance + "%");
		
		if(Convars.GetStr("mp_gamemode").tolower() != "holdout")
		{
			if(heightFlowDistance >= ::TankLimit.ConfigVar.TankFlowDistance && ::TankLimit.ForceTankCount > 0)
			{
				Utils.SpawnZombie(Z_TANK);
				::TankLimit.ForceTankCount -= 1;
				printl("force spawn tank with flow distance " + heightFlowDistance);
			}
			if(heightFlowDistance >= ::TankLimit.ConfigVar.WitchFlowDistance && ::TankLimit.ForceWitchCount > 0)
			{
				Utils.SpawnZombie(Z_WITCH);
				::TankLimit.ForceWitchCount -= 1;
				printl("force spawn witch with flow distance " + heightFlowDistance);
			}
		}
		
		/*
		local tankCount = ::TankLimit.GetSpanwCount(::TankLimit.ConfigVar.TankFlowDistance);
		local witchCount = ::TankLimit.GetSpanwCount(::TankLimit.ConfigVar.WitchFlowDistance);
		for(local i = max(tankCount, witchCount); i > 0; ++i)
		{
			if(--tankCount >= 0)
				Utils.SpawnZombie(Z_TANK);
			if(--witchCount >= 0)
				Utils.SpawnZombie(Z_WITCH_BRIDE);
		}
		*/
		
		if(::TankLimit.ConfigVar.RushSpawn)
		{
			local avgFlowDistance = g_ModeScript.GetAverageSurvivorFlowDistance();
			if(avgFlowDistance <= 0)
				return;
			
			// 当前平均进度
			avgFlowDistance = avgFlowDistance / maxFlowDistance * 100;
			if(avgFlowDistance <= 0)
				return;
			
			if(heightFlowDistance - avgFlowDistance >= ::TankLimit.ConfigVar.SpawnFlowDistance)
			{
				// 随机刷特感
				for(local i = 0; i < ::TankLimit.ConfigVar.SpawnAmount; ++i)
				{
					Utils.SpawnZombieNearPlayer(heightFlowDistancePlayer, RandomInt(Z_SMOKER, Z_CHARGER),
						128.0, 32.0, true, false, heightFlowDistancePlayer);
				}
				
				heightFlowDistancePlayer.PlaySoundEx("ui/pickup_guitarriff10.wav");
				printl("force spawn special by player " + heightFlowDistancePlayer.GetName() +
					", flow distance is (" + heightFlowDistance + " / " + avgFlowDistance + ")");
			}
		}
	},
	
	function Timer_IncapPlayer(player)
	{
		player.SetNetPropInt("m_isIncapacitated", 1);
		player.SetRawHealth(Convars.GetFloat("survivor_incap_health"));
	},
};

function Notifications::OnRoundBegin::TankLimit_Active(params)
{
	::TankLimit.ForceTankCount = ceil(Convars.GetFloat("director_force_tank"));
	::TankLimit.ForceWitchCount = ceil(Convars.GetFloat("director_force_witch"));
	Timers.AddTimerByName("timer_tankspawner", 9.0, true, ::TankLimit.TimerSpawner_OnPlayerThink);
}

function Notifications::FirstSurvLeftStartArea::TankLimit_Active(player, params)
{
	::TankLimit.ForceTankCount = ceil(Convars.GetFloat("director_force_tank"));
	::TankLimit.ForceWitchCount = ceil(Convars.GetFloat("director_force_witch"));
	Timers.AddTimerByName("timer_tankspawner", 5.0, true, ::TankLimit.TimerSpawner_OnPlayerThink);
}

function Notifications::OnTankSpawned::TankLimit_SetTankHealth(player, params)
{
	::TankLimit.ForceTankCount -= 1;
	if(::TankLimit.ForceTankCount < 0)
		::TankLimit.ForceTankCount = 0;
	Convars.SetValue("director_force_tank", ::TankLimit.ForceTankCount);
	
	if(!::TankLimit.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayerEntityValid())
		return;
	
	local health = 0;
	if("ZombieTankHealth" in SessionOptions && SessionOptions["ZombieTankHealth"] > 0)
		health = SessionOptions["ZombieTankHealth"];
	else if("TankHealth" in SessionOptions && SessionOptions["TankHealth"] > 0)
		health = SessionOptions["TankHealth"];
	else
		health = ceil(Convars.GetFloat("z_tank_health"));
	
	if(health < ::TankLimit.ConfigVar.TankMinHealth)
		health = ::TankLimit.ConfigVar.TankMinHealth;
	
	player.SetMaxHealth(health);
	player.SetHealth(health);
	
	foreach(client in Players.Humans())
	{
		if(client.IsDead())
			continue;
		
		client.PlaySoundEx("ui/survival_medal.wav");
	}
	
	printl("tank spawned. health setting " + health);
}

function Notifications::OnWitchSpawned::TankLimit_UpdateWitchForce(entity, params)
{
	::TankLimit.ForceWitchCount -= 1;
	if(::TankLimit.ForceWitchCount < 0)
		::TankLimit.ForceWitchCount = 0;
	
	Convars.SetValue("director_force_witch", ::TankLimit.ForceWitchCount);
	
	foreach(client in Players.Humans())
	{
		if(client.IsDead())
			continue;
		
		client.PlaySoundEx("buttons/blip2.wav");
	}
	
	printl("witch spawned.");
}

/*
function Notifications::OnVersusMarkerReached::TankLimit_CheckTankSpawned(player, marker, params)
{
	if(!::TankLimit.ConfigVar.Enable)
		return;
	
	if(marker >= ::TankLimit.ConfigVar.TankFlowDistance && Convars.GetFloat("director_force_tank") > 0)
	{
		Utils.SpawnZombie(Z_TANK);
		// Convars.SetValue("director_force_tank", ceil(Convars.GetFloat("director_force_tank") - 1));
	}
	
	if(marker >= ::TankLimit.ConfigVar.WitchFlowDistance && Convars.GetFloat("director_force_witch") > 0)
	{
		Utils.SpawnZombie(Z_WITCH_BRIDE);
		// Convars.SetValue("director_force_witch", ceil(Convars.GetFloat("director_force_witch") - 1));
	}
}
*/

function Notifications::OnIncapacitated::TankLimit_HandleIncap(victim, attacker, params)
{
	if(!::TankLimit.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsValid() || !attacker.IsValid())
		return;
	
	if(::TankLimit.ConfigVar.TankRespawn && victim.GetType() == Z_TANK && victim.GetIndex() == attacker.GetIndex())
	{
		local netprops = {
			m_fFlags = null,
			m_nSequence = null,
			m_iHealth = null,
			m_iMaxHealth = null,
			m_vecOrigin = null,
			m_angRotation = null,
		};
		
		foreach(key, value in netprops)
			netprops[key] = victim.GetNetProp(key);
		
		printl("tank " + victim.GetName() + " is dead, but it will be resurrected");
		
		victim.Input("Kill");
		
		local tank = Utils.SpawnZombie(Z_TANK, netprops["m_vecOrigin"], netprops["m_angRotation"]);
		if(tank != null && tank.IsValid())
			foreach(key, value in netprops)
				tank.SetNetProp(key, value);
	}
	
	if(::TankLimit.ConfigVar.ForceFliing && victim.IsSurvivor() && params["weapon"] == "tank_claw")
	{
		victim.SetNetPropInt("m_isIncapacitated", 0);
		victim.SetRawHealth(0);
		Timers.AddTimerByName("tanklimit_incap_" + victim.GetUserID(), 0.1, false,
			::TankLimit.Timer_IncapPlayer, victim,
			0, { "action" : "once" }
		);
	}
}

function EasyLogic::OnTakeDamage::TankLimit_TankDamage(dmgTable)
{
	if(!::TankLimit.ConfigVar.TankDamage)
		return true;
	
	if(dmgTable["Victim"] == null || dmgTable["Attacker"] == null || dmgTable["DamageDone"] <= 0.0 ||
		!dmgTable["Victim"].IsPlayer() || !dmgTable["Attacker"].IsPlayer() ||
		dmgTable["Attacker"] == dmgTable["Victim"] || dmgTable["Attacker"].GetTeam() != INFECTED ||
		dmgTable["Victim"].GetTeam() != SURVIVORS || !dmgTable["Victim"].IsIncapacitated() ||
		dmgTable["Attacker"].GetType() != Z_TANK)
		return true;
	
	local pos = dmgTable["Attacker"].GetLocation();
	foreach(player in Objects.OfClassnameWithin("player", pos, Convars.GetFloat("tank_attack_range")))
	{
		if(player.GetTeam() != SURVIVORS || player.IsDead() || player.IsIncapacitated())
			continue;
		
		// 伤害转移
		player.Damage(dmgTable["DamageDone"], dmgTable["DamageType"], dmgTable["Attacker"]);
		player.PlaySoundEx("level/puck_fail.wav");
		return false;
	}
	
	if(::TankLimit.ConfigVar.TankStagger && dmgTable["Attacker"].IsBot())
		dmgTable["Attacker"].StaggerAwayFromEntity(dmgTable["Victim"]);
	
	return true;
}


::TankLimit.PLUGIN_NAME <- PLUGIN_NAME;
::TankLimit.ConfigVar = ::TankLimit.ConfigVarDef;

function Notifications::OnRoundStart::TankLimit_LoadConfig()
{
	RestoreTable(::TankLimit.PLUGIN_NAME, ::TankLimit.ConfigVar);
	if(::TankLimit.ConfigVar == null || ::TankLimit.ConfigVar.len() <= 0)
		::TankLimit.ConfigVar = FileIO.GetConfigOfFile(::TankLimit.PLUGIN_NAME, ::TankLimit.ConfigVarDef);

	// printl("[plugins] " + ::TankLimit.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::TankLimit_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::TankLimit.PLUGIN_NAME, ::TankLimit.ConfigVar);

	// printl("[plugins] " + ::TankLimit.PLUGIN_NAME + " saving...");
}
