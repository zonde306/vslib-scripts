::MapChange <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,

		// 是否随机更换地图
		Random = false,

		// 更换地图的延迟
		Delay = 3.0,

		// 是否提示下一张地图
		ShowHint = false,

		// 战役最终关失败多少次强制换图.0=禁用
		FinaleFailChange = 3,

		// 生存失败多少次换图.0=禁用
		SurvivalChange = 3
	},

	ConfigVar = {},

	IsFinaleRound = false,
	CurrentNextMap = "none",
	
	RoundTable =
	{
		FinaleFailed = 0,
		RoundTime = 0,
		ServerTime = 0,
		MapTime = 0
	},
	
	// 普通类地图(战役/对抗)
	CampaignNextMap =
	{
		c1m4_atrium = {nextmap = "c6m1_riverbank", mapname = "#L4D360UI_CampaignName_C6"},
		c6m1_riverbank = {nextmap = "c2m1_highway", mapname = "#L4D360UI_CampaignName_C2"},
		c2m5_concert = {nextmap = "c3m1_plankcountry", mapname = "#L4D360UI_CampaignName_C3"},
		c3m4_plantation = {nextmap = "c4m1_milltown_a", mapname = "#L4D360UI_CampaignName_C4"},
		c4m5_milltown_escape = {nextmap = "c5m1_waterfront", mapname = "#L4D360UI_CampaignName_C5"},
		c5m5_bridge = {nextmap = "c13m1_alpinecreek", mapname = "#L4D360UI_CampaignName_C13"},
		c13m4_cutthroatcreek = {nextmap = "c8m1_apartment", mapname = "#L4D360UI_CampaignName_C8"},
		c8m5_rooftop = {nextmap = "c9m1_alleys", mapname = "#L4D360UI_CampaignName_C9"},
		c9m2_lots = {nextmap = "c10m1_caves", mapname = "#L4D360UI_CampaignName_C10"},
		c10m5_houseboat = {nextmap = "c11m1_greenhouse", mapname = "#L4D360UI_CampaignName_C11"},
		c11m5_runway = {nextmap = "c12m1_hilltop", mapname = "#L4D360UI_CampaignName_C12"},
		c12m5_cornfield = {nextmap = "c7m1_docks", mapname = "#L4D360UI_CampaignName_C7"},
		c7m3_port = {nextmap = "c1m1_hotel", mapname = "#L4D360UI_CampaignName_C1"}
	},
	
	// 生存地图
	SurvivalNextMap =
	{
		c1m4_atrium = {nextmap = "c6m1_riverbank", mapname = "#L4D360UI_LevelName_SURVIVAL_C6M1"},
		c6m1_riverbank = {nextmap = "c6m2_bedlam", mapname = "#L4D360UI_LevelName_SURVIVAL_C6M2"},
		c6m2_bedlam = {nextmap = "c6m3_port", mapname = "#L4D360UI_LevelName_SURVIVAL_C6M3"},
		c6m3_port = {nextmap = "c2m1_highway", mapname = "#L4D360UI_LevelName_SURVIVAL_C2M1"},
		c2m1_highway = {nextmap = "c2m4_barns", mapname = "#L4D360UI_LevelName_SURVIVAL_C2M4"},
		c2m4_barns = {nextmap = "c2m5_concert", mapname = "#L4D360UI_LevelName_SURVIVAL_C2M5"},
		c2m5_concert = {nextmap = "c3m1_plankcountry", mapname = "#L4D360UI_LevelName_SURVIVAL_C3M1"},
		c3m1_plankcountry = {nextmap = "c3m4_plantation", mapname = "#L4D360UI_LevelName_SURVIVAL_C3M4"},
		c3m4_plantation = {nextmap = "c4m1_milltown_a", mapname = "#L4D360UI_LevelName_SURVIVAL_C4M1"},
		c4m1_milltown_a = {nextmap = "c4m2_sugarmill_a", mapname = "#L4D360UI_LevelName_SURVIVAL_C4M2"},
		c4m2_sugarmill_a = {nextmap = "c5m2_park", mapname = "#L4D360UI_LevelName_SURVIVAL_C5M2"},
		c5m2_park = {nextmap = "c5m5_bridge", mapname = "#L4D360UI_LevelName_SURVIVAL_C5M5"},
		c5m5_bridge = {nextmap = "c8m2_subway", mapname = "#L4D360UI_LevelName_SURVIVAL_C8M2"},
		c8m2_subway = {nextmap = "c8m5_rooftop", mapname = "#L4D360UI_LevelName_SURVIVAL_C8M5"},
		c8m5_rooftop = {nextmap = "c1m4_atrium", mapname = "#L4D360UI_LevelName_SURVIVAL_C1M4"}
	},
	
	// 清道夫地图
	ScavengeNextMap =
	{
		c1m4_atrium = {nextmap = "c6m1_riverbank", mapname = "#L4D360UI_LevelName_SCAVENGE_C6M1"},
		c6m1_riverbank = {nextmap = "c6m2_bedlam", mapname = "#L4D360UI_LevelName_SCAVENGE_C6M2"},
		c6m2_bedlam = {nextmap = "c6m3_port", mapname = "#L4D360UI_LevelName_SCAVENGE_C6M3"},
		c6m3_port = {nextmap = "c2m1_highway", mapname = "#L4D360UI_LevelName_SCAVENGE_C2M1"},
		c2m1_highway = {nextmap = "c3m1_plankcountry", mapname = "#L4D360UI_LevelName_SCAVENGE_C3M1"},
		c3m1_plankcountry = {nextmap = "c4m1_milltown_a", mapname = "#L4D360UI_LevelName_SCAVENGE_C4M1"},
		c4m1_milltown_a = {nextmap = "c4m2_sugarmill_a", mapname = "#L4D360UI_LevelName_SCAVENGE_C4M2"},
		c4m2_sugarmill_a = {nextmap = "c5m2_park", mapname = "#L4D360UI_LevelName_SCAVENGE_C5M2"},
		c5m2_park = {nextmap = "c8m1_apartment", mapname = "#L4D360UI_LevelName_SCAVENGE_C8M1"},
		c8m1_apartment = {nextmap = "c8m5_rooftop", mapname = "#L4D360UI_LevelName_SCAVENGE_C8M5"},
		c8m5_rooftop = {nextmap = "C10M3_ranchhouse", mapname = "#L4D360UI_LevelName_SCAVENGE_C10M3"},
		C10M3_ranchhouse = {nextmap = "c11m4_terminal", mapname = "#L4D360UI_LevelName_SCAVENGE_C11M4"},
		c11m4_terminal = {nextmap = "C12M5_cornfield", mapname = "#L4D360UI_LevelName_SCAVENGE_C12M5"},
		C12M5_cornfield = {nextmap = "c1m4_atrium", mapname = "#L4D360UI_LevelName_SCAVENGE_C1M4"}
	},
	
	function TimerChangeMap_OnFinaleEnd(params)
	{
		SendToServerConsole("changelevel " + params);
	},
	
	function Timer_OnGameSecond(params)
	{
		::MapChange.RoundTable.RoundTime += 1;
		::MapChange.RoundTable.ServerTime += 1;
		::MapChange.RoundTable.MapTime += 1;
	},
};

function Notifications::OnRoundBegin::MapChange_ActiveTimer(params)
{
	Timers.AddTimerByName("timer_mapchange_second", 1.0, true, ::MapChange.Timer_OnGameSecond);
}

function Notifications::FirstSurvLeftStartArea::MapChange_ActiveTimer(player, params)
{
	Timers.AddTimerByName("timer_mapchange_second", 1.0, true, ::MapChange.Timer_OnGameSecond);
}

function Notifications::OnRoundStart::MapChange_RoundStart()
{
	RestoreTable("plugins_mapchange_table", ::MapChange.RoundTable);
	
	if(::MapChange.RoundTable == null || ::MapChange.RoundTable.len() <= 0)
	{
		::MapChange.RoundTable <-
		{
			FinaleFailed = 0,
			RoundTime = 0,
			ServerTime = 0,
			MapTime = 0
		};
		
		printl("initialization table success.");
	}
	else
	{
		printl("restore table success.");
	}
}

function Notifications::OnFinaleWin::MapChangeStart(mapName, difficulty, params)
{
	if(mapName in ::MapChange.CampaignNextMap)
	{
		local nextmap = ::MapChange.CampaignNextMap[mapName];
		if(::MapChange.ConfigVar.Random)
			nextmap = Utils.GetRandValueFromArray(::MapChange.CampaignNextMap);
		
		Timers.AddTimerByName("timer_changemap", ::MapChange.ConfigVar.Delay, false,
			::MapChange.TimerChangeMap_OnFinaleEnd, nextmap["nextmap"]);
		
		if(::MapChange.ConfigVar.ShowHint)
			Utils.PrintToChatAll("nextmap: %s (%s)", nextmap["mapname"], nextmap["nextmap"]);
	}
	
	::MapChange.RoundTable.MapTime = 0;
	::MapChange.RoundTable.RoundTime = 0;
	::MapChange.RoundTable.FinaleFailed = 0;
	Timers.RemoveTimerByName("timer_mapchange_second");
}

function Notifications::OnVersusMatchFinished::MapChangeStart(winner, params)
{
	if(mapName in ::MapChange.CampaignNextMap)
	{
		local nextmap = ::MapChange.CampaignNextMap[mapName];
		if(::MapChange.ConfigVar.Random)
			nextmap = Utils.GetRandValueFromArray(::MapChange.CampaignNextMap);
		
		Timers.AddTimerByName("timer_changemap", ::MapChange.ConfigVar.Delay, false,
			::MapChange.TimerChangeMap_OnFinaleEnd, nextmap["nextmap"]);
		
		if(::MapChange.ConfigVar.ShowHint)
			Utils.PrintToChatAll("nextmap: %s (%s)", nextmap["mapname"], nextmap["nextmap"]);
	}
	
	::MapChange.RoundTable.MapTime = 0;
	::MapChange.RoundTable.RoundTime = 0;
	::MapChange.RoundTable.FinaleFailed = 0;
	Timers.RemoveTimerByName("timer_mapchange_second");
}

function Notifications::OnScavengeMatchFinished::MapChangeStart(winner, params)
{
	if(mapName in ::MapChange.ScavengeNextMap)
	{
		local nextmap = ::MapChange.ScavengeNextMap[mapName];
		if(::MapChange.ConfigVar.Random)
			nextmap = Utils.GetRandValueFromArray(::MapChange.ScavengeNextMap);
		
		Timers.AddTimerByName("timer_changemap", ::MapChange.ConfigVar.Delay, false,
			::MapChange.TimerChangeMap_OnFinaleEnd, nextmap["nextmap"]);
		
		if(::MapChange.ConfigVar.ShowHint)
			Utils.PrintToChatAll("nextmap: %s (%s)", nextmap["mapname"], nextmap["nextmap"]);
	}
	
	::MapChange.RoundTable.MapTime = 0;
	::MapChange.RoundTable.RoundTime = 0;
	::MapChange.RoundTable.FinaleFailed = 0;
	Timers.RemoveTimerByName("timer_mapchange_second");
}

function Notifications::FirstSurvLeftStartArea::MapChangeCheckFinal(player, params)
{
	local mapname = Utils.StringReplace(Convars.GetStr("host_map"), ".bsp", "");
	local mode = Utils.GetBaseMode();
	
	if(mapname in ::MapChange.CampaignNextMap && (mode == "coop" || mode == "versus" || mode == "realism"))
	{
		::MapChange.CurrentNextMap = ::MapChange.CampaignNextMap[mapname]["mapname"];
		::MapChange.IsFinaleRound = true;
	}
	else
		::MapChange.CurrentNextMap = "none";
	
	if(::MapChange.RoundTable.RoundTime > ::MapChange.RoundTable.MapTime)
		::MapChange.RoundTable.RoundTime = ::MapChange.RoundTable.MapTime;
}

function Notifications::OnSurvivorsDead::MapChangeForceChange()
{
	::MapChange.RoundTable.FinaleFailed += 1;
	::MapChange.RoundTable.RoundTime = 0;
	
	local mapName = Utils.StringReplace(Convars.GetStr("host_map"), ".bsp", "");
	printl("mission lost x" + ::MapChange.RoundTable.FinaleFailed);
	
	if(::MapChange.ConfigVar.FinaleFailChange <= 0)
		return;
	
	if(::MapChange.IsFinaleRound)
	{
		if(::MapChange.RoundTable.FinaleFailed >= ::MapChange.ConfigVar.FinaleFailChange)
		{
			Notifications.OnFinaleWin.MapChangeStart(mapName, Utils.GetDifficulty(), {});
		}
		else if(::MapChange.ConfigVar.ShowHint)
		{
			Utils.PrintToChatAll("mission lost (" + ::MapChange.RoundTable.FinaleFailed + "/" + ::MapChange.ConfigVar.FinaleFailChange + ")");
		}
	}
	else if(Utils.GetBaseMode() == "survival")
	{
		if(mapName in ::MapChange.SurvivalNextMap)
		{
			local nextmap = ::MapChange.SurvivalNextMap[mapName];
			if(::MapChange.ConfigVar.Random)
				nextmap = Utils.GetRandValueFromArray(::MapChange.SurvivalNextMap);
			
			Timers.AddTimerByName("timer_changemap", ::MapChange.ConfigVar.Delay, false,
				::MapChange.TimerChangeMap_OnFinaleEnd, nextmap["nextmap"]);
			
			if(::MapChange.ConfigVar.ShowHint)
				Utils.PrintToChatAll("nextmap: %s (%s)", nextmap["mapname"], nextmap["nextmap"]);
		}
	}
	
	Timers.RemoveTimerByName("timer_mapchange_second");
}

function Notifications::OnMapEnd::MapChange_MapChange()
{
	::MapChange.RoundTable.MapTime = 0;
	::MapChange.RoundTable.RoundTime = 0;
	::MapChange.RoundTable.FinaleFailed = 0;
	Timers.RemoveTimerByName("timer_mapchange_second");
}

function EasyLogic::OnShutdown::MapChange_SaveData(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable("plugins_mapchange_table", ::MapChange.RoundTable);
}

/*
function EasyLogic::Update::MapChange_RoundTimer()
{
	::MapChange.RoundTable.RoundTime += 1;
	::MapChange.RoundTable.ServerTime += 1;
	::MapChange.RoundTable.MapTime += 1;
}
*/

function CommandTriggersEx::time(player, args, text)
{
	local t = Utils.GetTimeTable(::MapChange.RoundTable.RoundTime);
	Utils.PrintToChatAll("Round time: " + t.hours + " Hours, " + t.minutes + " Minutes, " + t.seconds + " Seconds");
	
	t = Utils.GetTimeTable(::MapChange.RoundTable.MapTime);
	Utils.PrintToChatAll("Map time: " + t.hours + " Hours, " + t.minutes + " Minutes, " + t.seconds + " Seconds");
	
	t = Utils.GetTimeTable(::MapChange.RoundTable.ServerTime);
	Utils.PrintToChatAll("Server uptime: " + t.hours + " Hours, " + t.minutes + " Minutes, " + t.seconds + " Seconds");
	
	Utils.PrintToChatAll("Restart times: " + ::MapChange.RoundTable.FinaleFailed);
}

function CommandTriggersEx::nextmap(player, args, text)
{
	local maps = GetArgument(1);
	if(maps == null || !::AdminSystem.IsPrivileged(player))
	{
		Utils.PrintToChatAll("nextmap: " + ::MapChange.CurrentNextMap);
		return;
	}
	
	if(maps && maps != "")
	{
		::MapChange.CurrentNextMap = maps;
		printl("nextmap changed " + maps);
	}
}


::MapChange.PLUGIN_NAME <- PLUGIN_NAME;
::MapChange.ConfigVar = ::MapChange.ConfigVarDef;

function Notifications::OnRoundStart::MapChange_LoadConfig()
{
	RestoreTable(::MapChange.PLUGIN_NAME, ::MapChange.ConfigVar);
	if(::MapChange.ConfigVar == null || ::MapChange.ConfigVar.len() <= 0)
		::MapChange.ConfigVar = FileIO.GetConfigOfFile(::MapChange.PLUGIN_NAME, ::MapChange.ConfigVarDef);

	// printl("[plugins] " + ::MapChange.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::MapChange_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::MapChange.PLUGIN_NAME, ::MapChange.ConfigVar);

	// printl("[plugins] " + ::MapChange.PLUGIN_NAME + " saving...");
}
