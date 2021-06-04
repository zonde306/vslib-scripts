::SpecialSpawnner <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = false,
		
		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = false,
		
		// 倒地宽限时间上限
		GracePeriodOfIncapped = 7,
		
		// 被控宽限时间上限
		GracePeriodOfGrabbed = 5,
		
		SessionOption = {},
	},
	
	ConfigVar = {},
	
	MaxSpecialCount = 0,
	CurrentSpecialCount = 0,
	SessionOptionOriginal = {},
	SpecialUsed = {},
	
	function GetSessionOption(key, cvar = null)
	{
		if(key in SessionOptions && SessionOptions[key] != null)
			return SessionOptions[key];
		
		local DirectorOptions = DirectorScript.GetDirectorOptions();
		if(key in DirectorOptions && DirectorOptions[key] != null)
			return DirectorOptions[key];
		
		if(cvar != null)
			return Convars.GetStr(cvar);
		
		return null;
	}
	
	function StoreSessionOption()
	{
		::SpecialSpawnner.SessionOptionOriginal.cm_MaxSpecials <- ::SpecialSpawnner.GetSessionOption("cm_MaxSpecials", "z_max_player_zombies").tointeger();
		::SpecialSpawnner.SessionOptionOriginal.MaxSpecials <- ::SpecialSpawnner.GetSessionOption("MaxSpecials", "z_max_player_zombies").tointeger();
		::SpecialSpawnner.SessionOptionOriginal.cm_CommonLimit <- ::SpecialSpawnner.GetSessionOption("cm_CommonLimit", "z_common_limit").tointeger();
		::SpecialSpawnner.SessionOptionOriginal.CommonLimit <- ::SpecialSpawnner.GetSessionOption("CommonLimit", "z_common_limit").tointeger();
		::SpecialSpawnner.SessionOptionOriginal.SmokerLimit <- ::SpecialSpawnner.GetSessionOption("SmokerLimit", "z_smoker_limit").tointeger();
		::SpecialSpawnner.SessionOptionOriginal.BoomerLimit <- ::SpecialSpawnner.GetSessionOption("BoomerLimit", "z_boomer_limit").tointeger();
		::SpecialSpawnner.SessionOptionOriginal.HunterLimit <- ::SpecialSpawnner.GetSessionOption("HunterLimit", "z_hunter_limit").tointeger();
		::SpecialSpawnner.SessionOptionOriginal.SpitterLimit <- ::SpecialSpawnner.GetSessionOption("SpitterLimit", "z_spitter_limit").tointeger();
		::SpecialSpawnner.SessionOptionOriginal.JockeyLimit <- ::SpecialSpawnner.GetSessionOption("JockeyLimit", "z_jockey_limit").tointeger();
		::SpecialSpawnner.SessionOptionOriginal.ChargerLimit <- ::SpecialSpawnner.GetSessionOption("ChargerLimit", "z_charger_limit").tointeger();
		::SpecialSpawnner.SessionOptionOriginal.DominatorLimit <- ::SpecialSpawnner.GetSessionOption("DominatorLimit");
		::SpecialSpawnner.SessionOptionOriginal.cm_SpecialRespawnInterval <- ::SpecialSpawnner.GetSessionOption("cm_SpecialRespawnInterval", "director_special_respawn_interval").tofloat();
		::SpecialSpawnner.SessionOptionOriginal.SpecialRespawnInterval <- ::SpecialSpawnner.GetSessionOption("SpecialRespawnInterval", "director_special_respawn_interval").tofloat();
	},
	
	function RestoreSessionOption()
	{
		if("cm_MaxSpecials" in ::SpecialSpawnner.SessionOptionOriginal && ::SpecialSpawnner.SessionOptionOriginal.cm_MaxSpecials != null)
			SessionOptions.cm_MaxSpecials <- ::SpecialSpawnner.SessionOptionOriginal.cm_MaxSpecials;
		if("MaxSpecials" in ::SpecialSpawnner.SessionOptionOriginal && ::SpecialSpawnner.SessionOptionOriginal.MaxSpecials != null)
			SessionOptions.MaxSpecials <- ::SpecialSpawnner.SessionOptionOriginal.MaxSpecials;
		if("cm_CommonLimit" in ::SpecialSpawnner.SessionOptionOriginal && ::SpecialSpawnner.SessionOptionOriginal.cm_CommonLimit != null)
			SessionOptions.cm_CommonLimit <- ::SpecialSpawnner.SessionOptionOriginal.cm_CommonLimit;
		if("CommonLimit" in ::SpecialSpawnner.SessionOptionOriginal && ::SpecialSpawnner.SessionOptionOriginal.CommonLimit != null)
			SessionOptions.CommonLimit <- ::SpecialSpawnner.SessionOptionOriginal.CommonLimit;
		if("SmokerLimit" in ::SpecialSpawnner.SessionOptionOriginal && ::SpecialSpawnner.SessionOptionOriginal.SmokerLimit != null)
			SessionOptions.SmokerLimit <- ::SpecialSpawnner.SessionOptionOriginal.SmokerLimit;
		if("HunterLimit" in ::SpecialSpawnner.SessionOptionOriginal && ::SpecialSpawnner.SessionOptionOriginal.HunterLimit != null)
			SessionOptions.HunterLimit <- ::SpecialSpawnner.SessionOptionOriginal.HunterLimit;
		if("BoomerLimit" in ::SpecialSpawnner.SessionOptionOriginal && ::SpecialSpawnner.SessionOptionOriginal.BoomerLimit != null)
			SessionOptions.BoomerLimit <- ::SpecialSpawnner.SessionOptionOriginal.BoomerLimit;
		if("SpitterLimit" in ::SpecialSpawnner.SessionOptionOriginal && ::SpecialSpawnner.SessionOptionOriginal.SpitterLimit != null)
			SessionOptions.SpitterLimit <- ::SpecialSpawnner.SessionOptionOriginal.SpitterLimit;
		if("JockeyLimit" in ::SpecialSpawnner.SessionOptionOriginal && ::SpecialSpawnner.SessionOptionOriginal.JockeyLimit != null)
			SessionOptions.JockeyLimit <- ::SpecialSpawnner.SessionOptionOriginal.JockeyLimit;
		if("ChargerLimit" in ::SpecialSpawnner.SessionOptionOriginal && ::SpecialSpawnner.SessionOptionOriginal.ChargerLimit != null)
			SessionOptions.ChargerLimit <- ::SpecialSpawnner.SessionOptionOriginal.ChargerLimit;
		if("DominatorLimit" in ::SpecialSpawnner.SessionOptionOriginal && ::SpecialSpawnner.SessionOptionOriginal.DominatorLimit != null)
			SessionOptions.DominatorLimit <- ::SpecialSpawnner.SessionOptionOriginal.DominatorLimit;
		if("cm_SpecialRespawnInterval" in ::SpecialSpawnner.SessionOptionOriginal && ::SpecialSpawnner.SessionOptionOriginal.cm_SpecialRespawnInterval != null)
			SessionOptions.cm_SpecialRespawnInterval <- ::SpecialSpawnner.SessionOptionOriginal.cm_SpecialRespawnInterval;
		if("SpecialRespawnInterval" in ::SpecialSpawnner.SessionOptionOriginal && ::SpecialSpawnner.SessionOptionOriginal.SpecialRespawnInterval != null)
			SessionOptions.SpecialRespawnInterval <- ::SpecialSpawnner.SessionOptionOriginal.SpecialRespawnInterval;
		
		printl("RestoreSessionOption");
	},
	
	function ApplySessionOption()
	{
		if(::SpecialSpawnner.SessionOptionOriginal.len() <= 0)
			::SpecialSpawnner.StoreSessionOption();
		
		if("cm_MaxSpecials" in ::SpecialSpawnner.ConfigVar.SessionOption && ::SpecialSpawnner.ConfigVar.SessionOption.cm_MaxSpecials != null)
			SessionOptions.cm_MaxSpecials <- ::SpecialSpawnner.ConfigVar.SessionOption.cm_MaxSpecials;
		if("MaxSpecials" in ::SpecialSpawnner.ConfigVar.SessionOption && ::SpecialSpawnner.ConfigVar.SessionOption.MaxSpecials != null)
			SessionOptions.MaxSpecials <- ::SpecialSpawnner.ConfigVar.SessionOption.MaxSpecials;
		if("cm_CommonLimit" in ::SpecialSpawnner.ConfigVar.SessionOption && ::SpecialSpawnner.ConfigVar.SessionOption.cm_CommonLimit != null)
			SessionOptions.cm_CommonLimit <- ::SpecialSpawnner.ConfigVar.SessionOption.cm_CommonLimit;
		if("CommonLimit" in ::SpecialSpawnner.ConfigVar.SessionOption && ::SpecialSpawnner.ConfigVar.SessionOption.CommonLimit != null)
			SessionOptions.CommonLimit <- ::SpecialSpawnner.ConfigVar.SessionOption.CommonLimit;
		if("SmokerLimit" in ::SpecialSpawnner.ConfigVar.SessionOption && ::SpecialSpawnner.ConfigVar.SessionOption.SmokerLimit != null)
			SessionOptions.SmokerLimit <- ::SpecialSpawnner.ConfigVar.SessionOption.SmokerLimit;
		if("HunterLimit" in ::SpecialSpawnner.ConfigVar.SessionOption && ::SpecialSpawnner.ConfigVar.SessionOption.HunterLimit != null)
			SessionOptions.HunterLimit <- ::SpecialSpawnner.ConfigVar.SessionOption.HunterLimit;
		if("BoomerLimit" in ::SpecialSpawnner.ConfigVar.SessionOption && ::SpecialSpawnner.ConfigVar.SessionOption.BoomerLimit != null)
			SessionOptions.BoomerLimit <- ::SpecialSpawnner.ConfigVar.SessionOption.BoomerLimit;
		if("SpitterLimit" in ::SpecialSpawnner.ConfigVar.SessionOption && ::SpecialSpawnner.ConfigVar.SessionOption.SpitterLimit != null)
			SessionOptions.SpitterLimit <- ::SpecialSpawnner.ConfigVar.SessionOption.SpitterLimit;
		if("JockeyLimit" in ::SpecialSpawnner.ConfigVar.SessionOption && ::SpecialSpawnner.ConfigVar.SessionOption.JockeyLimit != null)
			SessionOptions.JockeyLimit <- ::SpecialSpawnner.ConfigVar.SessionOption.JockeyLimit;
		if("ChargerLimit" in ::SpecialSpawnner.ConfigVar.SessionOption && ::SpecialSpawnner.ConfigVar.SessionOption.ChargerLimit != null)
			SessionOptions.ChargerLimit <- ::SpecialSpawnner.ConfigVar.SessionOption.ChargerLimit;
		if("DominatorLimit" in ::SpecialSpawnner.ConfigVar.SessionOption && ::SpecialSpawnner.ConfigVar.SessionOption.DominatorLimit != null)
			SessionOptions.DominatorLimit <- ::SpecialSpawnner.ConfigVar.SessionOption.DominatorLimit;
		if("cm_SpecialRespawnInterval" in ::SpecialSpawnner.ConfigVar.SessionOption && ::SpecialSpawnner.ConfigVar.SessionOption.cm_SpecialRespawnInterval != null)
			SessionOptions.cm_SpecialRespawnInterval <- ::SpecialSpawnner.ConfigVar.SessionOption.cm_SpecialRespawnInterval;
		if("SpecialRespawnInterval" in ::SpecialSpawnner.ConfigVar.SessionOption && ::SpecialSpawnner.ConfigVar.SessionOption.SpecialRespawnInterval != null)
			SessionOptions.SpecialRespawnInterval <- ::SpecialSpawnner.ConfigVar.SessionOption.SpecialRespawnInterval;
		
		printl("ApplySessionOption");
	},
	
	function GetMaxSpecialCount()
	{
		if("cm_MaxSpecials" in SessionOptions)
			::SpecialSpawnner.MaxSpecialCount = SessionOptions.cm_MaxSpecials;
		else if("MaxSpecials" in SessionOptions)
			::SpecialSpawnner.MaxSpecialCount = SessionOptions.MaxSpecials;
		else
			::SpecialSpawnner.MaxSpecialCount = floor(Convars.GetFloat("z_max_player_zombies"));
		
		return ::SpecialSpawnner.MaxSpecialCount;
	},
	
	function GetCurrentSpecialCount()
	{
		::SpecialSpawnner.CurrentSpecialCount = 0;
		::SpecialSpawnner.SpecialUsed[Z_SMOKER] <- 0;
		::SpecialSpawnner.SpecialUsed[Z_BOOMER] <- 0;
		::SpecialSpawnner.SpecialUsed[Z_HUNTER] <- 0;
		::SpecialSpawnner.SpecialUsed[Z_SPITTER] <- 0;
		::SpecialSpawnner.SpecialUsed[Z_JOCKEY] <- 0;
		::SpecialSpawnner.SpecialUsed[Z_CHARGER] <- 0;
		
		foreach(player in Players.Infected())
		{
			local type = player.GetType();
			if(player.IsDead() || player.IsGhost() || !(type in ::SpecialSpawnner.SpecialUsed))
				continue;
			
			::SpecialSpawnner.CurrentSpecialCount += 1;
			::SpecialSpawnner.SpecialUsed[player.GetType()] += 1;
		}
		
		return ::SpecialSpawnner.CurrentSpecialCount;
	},
	
	function GetSpecialLimit(classId)
	{
		switch(classId)
		{
			case Z_SMOKER:
				return ::SpecialSpawnner.GetSessionOption("SmokerLimit", "z_smoker_limit").tointeger();
			case Z_BOOMER:
				return ::SpecialSpawnner.GetSessionOption("BoomerLimit", "z_boomer_limit").tointeger();
			case Z_HUNTER:
				return ::SpecialSpawnner.GetSessionOption("HunterLimit", "z_hunter_limit").tointeger();
			case Z_SPITTER:
				return ::SpecialSpawnner.GetSessionOption("SpitterLimit", "z_spitter_limit").tointeger();
			case Z_JOCKEY:
				return ::SpecialSpawnner.GetSessionOption("JockeyLimit", "z_jockey_limit").tointeger();
			case Z_CHARGER:
				return ::SpecialSpawnner.GetSessionOption("ChargerLimit", "z_charger_limit").tointeger();
		}
		
		return null;
	}
	
	function GetAvailableSpecial()
	{
		local queue = [];
		foreach(classId, used in ::SpecialSpawnner.SpecialUsed)
		{
			local limit = ::SpecialSpawnner.GetSpecialLimit(classId);
			if(limit == null)
				continue;
			
			for(local i = 0; i < limit - used; ++i)
				queue.append(classId);
		}
		
		return queue;
	}
	
	function Timer_SpawnSpecialInfected(params)
	{
		/*
		foreach(player in Players.Infected())
		{
			if(!player.IsBot() || player.IsDead() || player.HasVisibleThreats() || player.GetTarget() == null)
				continue;
			
			SendToServerConsole("kick " + player.GetName());
			printl("kick " + player + " with idle");
		}
		*/
		
		local specials = ::SpecialSpawnner.GetCurrentSpecialCount();
		local queue = ::SpecialSpawnner.GetAvailableSpecial();
		local maxSpecials = ::SpecialSpawnner.GetMaxSpecialCount();
		for(local i = specials; i < maxSpecials; ++i)
		{
			local classId = Utils.GetRandValueFromArray(queue, true);
			if(classId == null)
				break;
			
			Utils.SpawnZombie(classId);
		}
	},
	
	function Timer_BeginSpawnSpecial(params)
	{
		if(!::SpecialSpawnner.ConfigVar.Enable)
			return;
		
		local numIncap = 0;
		local numVictim = 0;
		local numTotal = 0;
		
		foreach(player in Players.AliveSurvivors())
		{
			if(player.IsIncapacitated() || player.IsHangingFromLedge())
				numIncap += 1;
			if(player.GetCurrentAttacker() != null)
				numVictim += 1;
			
			numTotal += 1;
		}
		
		local delay = 0.1;
		if((numIncap > 0 || numVictim > 0) && numTotal > 1)
			delay = (numIncap * ::SpecialSpawnner.ConfigVar.GracePeriodOfIncapped / (numTotal - 1) + numVictim * ::SpecialSpawnner.ConfigVar.GracePeriodOfGrabbed / (numTotal - 1));
		
		Timers.AddTimerByName("timer_ss_spawn", delay, false, ::SpecialSpawnner.Timer_SpawnSpecialInfected);
		
		if(delay > 0.1)
			printl("total " + numTotal + ", incap " + numIncap + ", victim " + numVictim + ", delay " + delay);
		
		return ::SpecialSpawnner.GetSessionOption("SpecialRespawnInterval", "director_special_respawn_interval").tofloat() + delay;
	},
};

function Notifications::FirstSurvLeftStartArea::SpecialSpawnner_StartSpawnner(player, params)
{
	Timers.AddTimerByName("timer_ss_start", ::SpecialSpawnner.GetSessionOption("SpecialRespawnInterval", "director_special_respawn_interval").tofloat(),
		true, ::SpecialSpawnner.Timer_BeginSpawnSpecial);
}

function Notifications::OnDoorUnlocked::SpecialSpawnner_StartSpawnner(player, checkpoint, params)
{
	if(!checkpoint)
		return;
	
	Timers.AddTimerByName("timer_ss_start", ::SpecialSpawnner.GetSessionOption("SpecialRespawnInterval", "director_special_respawn_interval").tofloat(),
		true, ::SpecialSpawnner.Timer_BeginSpawnSpecial);
}

function Notifications::OnSurvivorsLeftStartArea::SpecialSpawnner_StartSpawnner()
{
	Timers.AddTimerByName("timer_ss_start", ::SpecialSpawnner.GetSessionOption("SpecialRespawnInterval", "director_special_respawn_interval").tofloat(),
		true, ::SpecialSpawnner.Timer_BeginSpawnSpecial);
}

function EasyLogic::OnInterceptChat::SpecialSpawnner_SetSpawnCount(text, player)
{
	local admin = ::AdminSystem.IsPrivileged(player);
	if(!::SpecialSpawnner.ConfigVar.Enable && !admin)
		return;
	
	if(player != null && (!player.IsSurvivor() || player.IsDead()) && !admin)
		return;
	
	if(text.tolower() == "ssrst")
	{
		::SpecialSpawnner.RestoreSessionOption();
		return;
	}
	if(text.tolower() == "sson")
	{
		::SpecialSpawnner.ConfigVar.Enable = true;
		::SpecialSpawnner.ApplySessionOption();
		return;
	}
	if(text.tolower() == "ssoff")
	{
		::SpecialSpawnner.ConfigVar.Enable = false;
		::SpecialSpawnner.RestoreSessionOption();
		::SpecialSpawnner.ConfigVar.SessionOption = {};
		return;
	}
	
	local cp = regexp(@"^(\d{1,3})(si|ci|ht|jk|ps|SI|CI|HT|JK|PS|Si|Ci|Ht|Jk|Ps|sI|cI|hT|jK|pS)$").capture(text);
	if(cp == null)
		return;
	
	local value = text.slice(cp[1].begin, cp[1].end).tointeger();
	switch(text.slice(cp[2].begin, cp[2].end).tolower())
	{
		case "si":
		{
			if(value < 1 || value > 32)
				return;
			
			::SpecialSpawnner.ConfigVar.SessionOption.cm_MaxSpecials <- value;
			::SpecialSpawnner.ConfigVar.SessionOption.MaxSpecialCount <- value;
			
			local numBoss = (value / 3).tointeger();
			::SpecialSpawnner.ConfigVar.SessionOption.SmokerLimit <- numBoss;
			::SpecialSpawnner.ConfigVar.SessionOption.BoomerLimit <- numBoss;
			::SpecialSpawnner.ConfigVar.SessionOption.HunterLimit <- numBoss;
			::SpecialSpawnner.ConfigVar.SessionOption.SpitterLimit <- numBoss;
			::SpecialSpawnner.ConfigVar.SessionOption.JockeyLimit <- numBoss;
			::SpecialSpawnner.ConfigVar.SessionOption.ChargerLimit <- numBoss;
			::SpecialSpawnner.ConfigVar.SessionOption.DominatorLimit <- value - numBoss;
			
			Utils.SayToAll("Special Infected: " + value.tostring() + ", Dominator: " + (value - numBoss).tostring(), ", PerBoss: " + numBoss.tostring());
			break;
		}
		case "ci":
		{
			if(value < 0 || value > 200)
				return;
			
			::SpecialSpawnner.ConfigVar.SessionOption.cm_CommonLimit <- value;
			::SpecialSpawnner.ConfigVar.SessionOption.CommonLimit <- value;
			
			Utils.SayToAll("Common Infected: " + value.tostring());
			break;
		}
		case "ht":
		{
			::SpecialSpawnner.ConfigVar.SessionOption.cm_MaxSpecials <- value;
			::SpecialSpawnner.ConfigVar.SessionOption.MaxSpecialCount <- value;
			::SpecialSpawnner.ConfigVar.SessionOption.DominatorLimit <- value;
			
			local numBoss = (value / 3).tointeger();
			::SpecialSpawnner.ConfigVar.SessionOption.SmokerLimit <- 0;
			::SpecialSpawnner.ConfigVar.SessionOption.BoomerLimit <- 0;
			::SpecialSpawnner.ConfigVar.SessionOption.HunterLimit <- value;
			::SpecialSpawnner.ConfigVar.SessionOption.SpitterLimit <- numBoss;
			::SpecialSpawnner.ConfigVar.SessionOption.JockeyLimit <- 0;
			::SpecialSpawnner.ConfigVar.SessionOption.ChargerLimit <- 0;
			
			::SpecialSpawnner.ConfigVar.SessionOption.DominatorLimit <- value - numBoss;
			
			Utils.SayToAll("Hunter: " + value.tostring());
			break;
		}
		case "jk":
		{
			::SpecialSpawnner.ConfigVar.SessionOption.cm_MaxSpecials <- value;
			::SpecialSpawnner.ConfigVar.SessionOption.MaxSpecialCount <- value;
			::SpecialSpawnner.ConfigVar.SessionOption.DominatorLimit <- value;
			
			local numBoss = (value / 3).tointeger();
			::SpecialSpawnner.ConfigVar.SessionOption.SmokerLimit <- 0;
			::SpecialSpawnner.ConfigVar.SessionOption.BoomerLimit <- 0;
			::SpecialSpawnner.ConfigVar.SessionOption.HunterLimit <- 0;
			::SpecialSpawnner.ConfigVar.SessionOption.SpitterLimit <- numBoss;
			::SpecialSpawnner.ConfigVar.SessionOption.JockeyLimit <- value;
			::SpecialSpawnner.ConfigVar.SessionOption.ChargerLimit <- 0;
			
			::SpecialSpawnner.ConfigVar.SessionOption.DominatorLimit <- value - numBoss;
			
			Utils.SayToAll("Jockey: " + value.tostring());
			break;
		}
		case "ps":
		{
			::SpecialSpawnner.ConfigVar.SessionOption.cm_SpecialRespawnInterval <- value;
			::SpecialSpawnner.ConfigVar.SessionOption.SpecialRespawnInterval <- value;
			Utils.SayToAll("Every " + value.tostring() + " second a wave");
		}
	}
	
	::SpecialSpawnner.ConfigVar.Enable = true;
	::SpecialSpawnner.ApplySessionOption();
}

::SpecialSpawnner.PLUGIN_NAME <- PLUGIN_NAME;
::SpecialSpawnner.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::SpecialSpawnner.ConfigVarDef);

function Notifications::OnRoundStart::SpecialSpawnner_LoadConfig()
{
	RestoreTable(::SpecialSpawnner.PLUGIN_NAME, ::SpecialSpawnner.ConfigVar);
	if(::SpecialSpawnner.ConfigVar == null || ::SpecialSpawnner.ConfigVar.len() <= 0)
		::SpecialSpawnner.ConfigVar = FileIO.GetConfigOfFile(::SpecialSpawnner.PLUGIN_NAME, ::SpecialSpawnner.ConfigVarDef);
	
	::SpecialSpawnner.ApplySessionOption();
	// printl("[plugins] " + ::SpecialSpawnner.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::SpecialSpawnner_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::SpecialSpawnner.PLUGIN_NAME, ::SpecialSpawnner.ConfigVar);

	// printl("[plugins] " + ::SpecialSpawnner.PLUGIN_NAME + " saving...");
}
