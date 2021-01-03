::AllSurvivors <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
		
		// 是否开启修复模型重复
		CharacterFix = true,
		
		// 是否开启换图退出卡模型的问题
		ChangeLevelFix = true,
	},

	ConfigVar = {},
	
	_SurvivorSet =
	[
		// 填充用，默认列表
		[0, 1, 2, 3, 4, 5, 6, 7],
		
		// 一代幸存者
		[4, 5, 6, 7, 0, 1, 2, 3],
		
		// 二代幸存者
		[0, 1, 2, 3, 4, 5, 6, 7]
	],
	
	_CharacterInfo =
	[
		// 填充用
		[],
		
		// 一代幸存者
		[
			{model = "models/survivors/survivor_namvet.mdl", present = false, character = 6, name = "Bill"},
			{model = "models/survivors/survivor_teenangst.mdl", present = false, character = 5, name = "Zoey"},
			{model = "models/survivors/survivor_biker.mdl", present = false, character = 6, name = "Francis"},
			{model = "models/survivors/survivor_manager.mdl", present = false, character = 7, name = "Louis"},
			{model = "models/survivors/survivor_gambler.mdl", present = false, character = 0, name = "Nick"},
			{model = "models/survivors/survivor_producer.mdl", present = false, character = 1, name = "Rochelle"},
			{model = "models/survivors/survivor_coach.mdl", present = false, character = 2, name = "Coach"},
			{model = "models/survivors/survivor_mechanic.mdl", present = false, character = 3, name = "Ellis"},
		],
		
		// 二代幸存者
		[
			{model = "models/survivors/survivor_gambler.mdl", present = false, character = 0, name = "Nick"},
			{model = "models/survivors/survivor_producer.mdl", present = false, character = 1, name = "Rochelle"},
			{model = "models/survivors/survivor_coach.mdl", present = false, character = 2, name = "Coach"},
			{model = "models/survivors/survivor_mechanic.mdl", present = false, character = 3, name = "Ellis"},
			{model = "models/survivors/survivor_namvet.mdl", present = false, character = 6, name = "Bill"},
			{model = "models/survivors/survivor_teenangst.mdl", present = false, character = 5, name = "Zoey"},
			{model = "models/survivors/survivor_biker.mdl", present = false, character = 6, name = "Francis"},
			{model = "models/survivors/survivor_manager.mdl", present = false, character = 7, name = "Louis"},
		],
	],
	
	HasCharacterChecked = false,
	HasSurvivorChecked = false,
	
	function GetValue(index, keys)
	{
		return ::AllSurvivors._CharacterInfo[Utils.GetSurvivorSet()][index][keys];
	},
	
	function SetValue(index, keys, value)
	{
		::AllSurvivors._CharacterInfo[Utils.GetSurvivorSet()][index][keys] = value;
	},
	
	function FindCharacterInfoByModel(models)
	{
		local sets = Utils.GetSurvivorSet();
		
		for(local i = 0; i < 8; ++i)
		{
			if(::AllSurvivors._CharacterInfo[sets][i].model.tolower() == models.tolower())
				return i;
		}
		
		return null;
	},
	
	function FindFreeCharacter()
	{
		local sets = Utils.GetSurvivorSet();
		
		for(local i = 0; i < 8; ++i)
		{
			if(!::AllSurvivors._CharacterInfo[sets][i].present)
				return i;
		}
		
		return null;
	},
	
	function RestoreSurvivorInfo()
	{
		local sets = Utils.GetSurvivorSet();
		
		for(local i = 0; i < 8; ++i)
			::AllSurvivors._CharacterInfo[sets][i].present = false;
	},
	
	function UpdateSurvivorInfo()
	{
		local sets = Utils.GetSurvivorSet();
		
		foreach(player in Players.Survivors())
		{
			local models = player.GetModel();
			local index = ::AllSurvivors.FindCharacterInfoByModel(models);
			// printl("[AllSurvivors] Spots player " + player.GetName() + " wearing " + index + ", model " + models);
			
			if(index == null)
				continue;
			
			::AllSurvivors._CharacterInfo[sets][index].present = true;
		}
	},
	
	function CheckSurvivorCharacter()
	{
		local sets = Utils.GetSurvivorSet();
		local total = 0;
		
		foreach(player in Players.Survivors())
		{
			local models = player.GetModel();
			local index = ::AllSurvivors.FindCharacterInfoByModel(models);
			// printl("[AllSurvivors] Spots player " + player.GetName() + " wearing " + index + ", model " + models);
			
			if(index == null)
				continue;
			
			local free = ::AllSurvivors.FindFreeCharacter();
			
			if(!::AllSurvivors._CharacterInfo[sets][index]["present"])
			{
				::AllSurvivors._CharacterInfo[sets][index]["present"] = true;
				printl("[AllSurvivors] player " + player.GetName() + " is an original!");
				total += 1;
			}
			else if(free != null)
			{
				player.SetModel(::AllSurvivors._CharacterInfo[sets][index]["model"]);
				player.SetSurvivorCharacter(::AllSurvivors._CharacterInfo[sets][index]["character"]);
				::AllSurvivors._CharacterInfo[sets][index]["present"] = true;
				
				printl("player " + player.GetName() + " changed to " + free);
				total += 1;
			}
		}
		
		printl("update survivor " + total + " completed.");
	},
	
	function CheckFakeSurvivors()
	{
		local total = 0;
		foreach(index, item in ::AllSurvivors._CharacterInfo[Utils.GetSurvivorSet()])
		{
			if(item["present"])
				continue;
			
			local kicked = false;
			local kickable = true;
			foreach(entity in Objects.OfModel(item["model"]))
			{
				if(entity.IsSurvivor() && entity.IsPlayer() && entity.IsAlive())
				{
					if(entity.GetModel().tolower() == item["model"].tolower())
						kickable = false;
					
					continue;
				}
				
				local name = entity.GetName();
				entity.Input("Kill");
				SendToServerConsole("sb_add");
				
				total += 1;
				kicked = true;
				printl("faker " + name + " has be kicked");
			}
			
			if(kickable && !kicked)
			{
				local player = Utils.GetPlayerFromName(item["name"]);
				if(player == null)
				{
					SendToServerConsole("kick " + item["name"]);
					SendToServerConsole("kick " + item["name"] + "(1)");
					SendToServerConsole("kick " + item["name"] + "(2)");
					SendToServerConsole("kick " + item["name"] + "(3)");
					SendToServerConsole("sb_add");
					
					total += 1;
					printl("faker " + item["name"] + " has be kicked by name");
				}
			}
		}
		
		printl("clean up fake survivor " + total + " completed.");
	},
	
	function CheckInactivatedSurvivors()
	{
		local total = 0;
		foreach(player in Players.All())
		{
			local team = player.GetTeam();
			if(team <= 1 || (team == 2 && player.IsDead()))
			{
				local name = player.GetName();
				SendToServerConsole("kickid #" + player.GetUserID());
				SendToServerConsole("sb_add");
				
				total += 1;
				printl("fake bot " + name + " kicked");
			}
		}
		
		printl("kick faker " + total + " completed.");
	},
	
	function Timer_CheckSurvivors(params)
	{
		// ::AllSurvivors.UpdateSurvivorInfo();
		
		if(::AllSurvivors.ConfigVar.CharacterFix && !::AllSurvivors.HasCharacterChecked)
		{
			::AllSurvivors.CheckSurvivorCharacter();
			::AllSurvivors.HasCharacterChecked = true;
		}
		
		if(::AllSurvivors.ConfigVar.ChangeLevelFix && !::AllSurvivors.HasSurvivorChecked)
		{
			::AllSurvivors.CheckFakeSurvivors();
			::AllSurvivors.HasSurvivorChecked = true;
		}
		
		// ::AllSurvivors.CheckInactivatedSurvivors();
		// SendToServerConsole("sb_add");
		// SendToServerConsole("sb_add");
		// SendToServerConsole("sb_add");
	},
	
	function Timer_FixRoundEndCrash(params)
	{
		foreach(survivor in Players.L4D1Survivors())
			survivor.Input("Kill");
		
		/*
		foreach(survivor in Players.AllSurvivors())
		{
			if(!survivor.IsBot() || survivor.GetNetPropInt("m_humanSpectatorEntIndex") > 0 ||
				GetPlayerFromUserID(survivor.GetNetPropInt("m_humanSpectatorUserID")) != null)
				continue;
			
			
		}
		*/
	}
};

function Notifications::OnRoundStart::AllSurvivors_StartCheck()
{
	if(!::AllSurvivors.ConfigVar.Enable)
		return;
	
	Timers.AddTimerByName("timer_checksurvivorcharacter", 0.1, false,
		::AllSurvivors.Timer_CheckSurvivors);
}

function Notifications::OnFirstSpawn::AllSurvivors_StartCheck(player, params)
{
	if(!::AllSurvivors.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsSurvivor())
		return;
	
	Timers.AddTimerByName("timer_checksurvivorcharacter", 0.2, false,
		::AllSurvivors.Timer_CheckSurvivors);
}

function Notifications::OnSpawn::AllSurvivors_StartCheck(player, params)
{
	if(!::AllSurvivors.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsSurvivor())
		return;
	
	Timers.AddTimerByName("timer_checksurvivorcharacter", 0.2, false,
		::AllSurvivors.Timer_CheckSurvivors);
}

function Notifications::OnDoorUnlocked::AllSurvivors_StartCheck(player, checkpoint, params)
{
	if(!::AllSurvivors.ConfigVar.Enable || !checkpoint)
		return;
	
	Timers.AddTimerByName("timer_checksurvivorcharacter", 1.0, false,
		::AllSurvivors.Timer_CheckSurvivors);
}

function Notifications::FirstSurvLeftStartArea::AllSurvivors_StartCheck(player, params)
{
	if(!::AllSurvivors.ConfigVar.Enable)
		return;
	
	Timers.AddTimerByName("timer_checksurvivorcharacter", 0.1, false,
		::AllSurvivors.Timer_CheckSurvivors);
}

function Notifications::OnSurvivorsDead::AllSurvivors_CrashFixer()
{
	Timers.AddTimerByName("timer_checksurvivorcharacter", 1.0, false,
		::AllSurvivors.Timer_FixRoundEndCrash);
	
	::AllSurvivors.RestoreSurvivorInfo();
}

function Notifications::OnRoundEnd::AllSurvivors_CrashFixer(winner, reason, message, time, params)
{
	Timers.AddTimerByName("timer_checksurvivorcharacter", 1.0, false,
		::AllSurvivors.Timer_FixRoundEndCrash);
	
	::AllSurvivors.RestoreSurvivorInfo();
}

function Notifications::OnMapEnd::AllSurvivors_CrashFixer()
{
	Timers.AddTimerByName("timer_checksurvivorcharacter", 1.0, false,
		::AllSurvivors.Timer_FixRoundEndCrash);
	
	::AllSurvivors.RestoreSurvivorInfo();
}

::AllSurvivors.PLUGIN_NAME <- PLUGIN_NAME;
::AllSurvivors.ConfigVar = ::AllSurvivors.ConfigVarDef;

function Notifications::OnRoundStart::AllSurvivors_LoadConfig()
{
	RestoreTable(::AllSurvivors.PLUGIN_NAME, ::AllSurvivors.ConfigVar);
	if(::AllSurvivors.ConfigVar == null || ::AllSurvivors.ConfigVar.len() <= 0)
		::AllSurvivors.ConfigVar = FileIO.GetConfigOfFile(::AllSurvivors.PLUGIN_NAME, ::AllSurvivors.ConfigVarDef);

	// printl("[plugins] " + ::AllSurvivors.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::AllSurvivors_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::AllSurvivors.PLUGIN_NAME, ::AllSurvivors.ConfigVar);

	// printl("[plugins] " + ::AllSurvivors.PLUGIN_NAME + " saving...");
}
