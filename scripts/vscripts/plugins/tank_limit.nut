::SpecialSpawner <-
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
		RushSpawn = true,

		// 跑图达到多少距离时开始刷特感(百分比)
		SpawnFlowDistance = 25,

		// 跑图刷特感每次刷出多少个
		SpawnAmount = 2,

		// 是否开启 Tank 伤害转移
		// 在 Tank 攻击倒地的生还者时如果周围有非倒地的生还者，将伤害转移给他
		// 用于防止故意坑队友，例如有队友倒地了，就跑到倒地的队友旁引 Tank 攻击倒地的队友
		TankDamage = true,
		
		// 坦克最小血量
		TankMinHealth = 8000
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
			local player = ::SpecialSpawner.GetHeightFlowDistancePlayer();
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
				return ::SpecialSpawner.GetSpanwCount(value.ref(), flowDistance);
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
		if(!::SpecialSpawner.ConfigVar.Enable)
			return;
		
		local heightFlowDistancePlayer = ::SpecialSpawner.GetHeightFlowDistancePlayer();
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
			if(heightFlowDistance >= ::SpecialSpawner.ConfigVar.TankFlowDistance && ::SpecialSpawner.ForceTankCount > 0)
			{
				Utils.SpawnZombie(Z_TANK);
				::SpecialSpawner.ForceTankCount -= 1;
				printl("force spawn tank with flow distance " + heightFlowDistance);
			}
			if(heightFlowDistance >= ::SpecialSpawner.ConfigVar.WitchFlowDistance && ::SpecialSpawner.ForceWitchCount > 0)
			{
				Utils.SpawnZombie(Z_WITCH);
				::SpecialSpawner.ForceWitchCount -= 1;
				printl("force spawn witch with flow distance " + heightFlowDistance);
			}
		}
		
		/*
		local tankCount = ::SpecialSpawner.GetSpanwCount(::SpecialSpawner.ConfigVar.TankFlowDistance);
		local witchCount = ::SpecialSpawner.GetSpanwCount(::SpecialSpawner.ConfigVar.WitchFlowDistance);
		for(local i = max(tankCount, witchCount); i > 0; ++i)
		{
			if(--tankCount >= 0)
				Utils.SpawnZombie(Z_TANK);
			if(--witchCount >= 0)
				Utils.SpawnZombie(Z_WITCH_BRIDE);
		}
		*/
		
		if(::SpecialSpawner.ConfigVar.RushSpawn)
		{
			local avgFlowDistance = g_ModeScript.GetAverageSurvivorFlowDistance();
			if(avgFlowDistance <= 0)
				return;
			
			// 当前平均进度
			avgFlowDistance = avgFlowDistance / maxFlowDistance * 100;
			if(avgFlowDistance <= 0)
				return;
			
			if(heightFlowDistance - avgFlowDistance >= ::SpecialSpawner.ConfigVar.SpawnFlowDistance)
			{
				// 随机刷特感
				for(local i = 0; i < ::SpecialSpawner.ConfigVar.SpawnAmount; ++i)
				{
					Utils.SpawnZombieNearPlayer(heightFlowDistancePlayer, RandomInt(Z_SMOKER, Z_CHARGER),
						128.0, 32.0, true, false, heightFlowDistancePlayer);
				}
				
				heightFlowDistancePlayer.PlaySoundEx("ui/pickup_guitarriff10.wav");
				printl("force spawn special by player " + heightFlowDistancePlayer.GetName() +
					", flow distance is (" + heightFlowDistance + " / " + avgFlowDistance + ")");
			}
		}
	}
};

function Notifications::OnRoundBegin::SpecialSpawner_Active(params)
{
	::SpecialSpawner.ForceTankCount = ceil(Convars.GetFloat("director_force_tank"));
	::SpecialSpawner.ForceWitchCount = ceil(Convars.GetFloat("director_force_witch"));
	Timers.AddTimerByName("timer_tankspawner", 9.0, true, ::SpecialSpawner.TimerSpawner_OnPlayerThink);
}

function Notifications::FirstSurvLeftStartArea::SpecialSpawner_Active(player, params)
{
	::SpecialSpawner.ForceTankCount = ceil(Convars.GetFloat("director_force_tank"));
	::SpecialSpawner.ForceWitchCount = ceil(Convars.GetFloat("director_force_witch"));
	Timers.AddTimerByName("timer_tankspawner", 5.0, true, ::SpecialSpawner.TimerSpawner_OnPlayerThink);
}

function Notifications::OnTankSpawned::SpecialSpawner_SetTankHealth(player, params)
{
	::SpecialSpawner.ForceTankCount -= 1;
	if(::SpecialSpawner.ForceTankCount < 0)
		::SpecialSpawner.ForceTankCount = 0;
	Convars.SetValue("director_force_tank", ::SpecialSpawner.ForceTankCount);
	
	if(!::SpecialSpawner.ConfigVar.Enable)
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
	
	if(health < ::SpecialSpawner.ConfigVar.TankMinHealth)
		health = ::SpecialSpawner.ConfigVar.TankMinHealth;
	
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

function Notifications::OnWitchSpawned::SpecialSpawner_UpdateWitchForce(entity, params)
{
	::SpecialSpawner.ForceWitchCount -= 1;
	if(::SpecialSpawner.ForceWitchCount < 0)
		::SpecialSpawner.ForceWitchCount = 0;
	
	Convars.SetValue("director_force_witch", ::SpecialSpawner.ForceWitchCount);
	
	foreach(client in Players.Humans())
	{
		if(client.IsDead())
			continue;
		
		client.PlaySoundEx("buttons/blip2.wav");
	}
	
	printl("witch spawned.");
}

/*
function Notifications::OnVersusMarkerReached::SpecialSpawner_CheckTankSpawned(player, marker, params)
{
	if(!::SpecialSpawner.ConfigVar.Enable)
		return;
	
	if(marker >= ::SpecialSpawner.ConfigVar.TankFlowDistance && Convars.GetFloat("director_force_tank") > 0)
	{
		Utils.SpawnZombie(Z_TANK);
		// Convars.SetValue("director_force_tank", ceil(Convars.GetFloat("director_force_tank") - 1));
	}
	
	if(marker >= ::SpecialSpawner.ConfigVar.WitchFlowDistance && Convars.GetFloat("director_force_witch") > 0)
	{
		Utils.SpawnZombie(Z_WITCH_BRIDE);
		// Convars.SetValue("director_force_witch", ceil(Convars.GetFloat("director_force_witch") - 1));
	}
}
*/

function EasyLogic::OnTakeDamage::SpecialSpawner_TankDamage(dmgTable)
{
	if(!::SpecialSpawner.ConfigVar.TankDamage)
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
	
	if(dmgTable["Attacker"].IsBot())
		dmgTable["Attacker"].StaggerAwayFromEntity(dmgTable["Victim"]);
	
	return true;
}


::SpecialSpawner.PLUGIN_NAME <- PLUGIN_NAME;
::SpecialSpawner.ConfigVar = ::SpecialSpawner.ConfigVarDef;

function Notifications::OnRoundStart::SpecialSpawner_LoadConfig()
{
	RestoreTable(::SpecialSpawner.PLUGIN_NAME, ::SpecialSpawner.ConfigVar);
	if(::SpecialSpawner.ConfigVar == null || ::SpecialSpawner.ConfigVar.len() <= 0)
		::SpecialSpawner.ConfigVar = FileIO.GetConfigOfFile(::SpecialSpawner.PLUGIN_NAME, ::SpecialSpawner.ConfigVarDef);

	// printl("[plugins] " + ::SpecialSpawner.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::SpecialSpawner_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::SpecialSpawner.PLUGIN_NAME, ::SpecialSpawner.ConfigVar);

	// printl("[plugins] " + ::SpecialSpawner.PLUGIN_NAME + " saving...");
}
