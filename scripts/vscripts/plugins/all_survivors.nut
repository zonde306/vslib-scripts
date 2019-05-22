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
			{model = "models/survivors/survivor_namvet.mdl", present = false, character = 6},
			{model = "models/survivors/survivor_teenangst.mdl", present = false, character = 5},
			{model = "models/survivors/survivor_biker.mdl", present = false, character = 6},
			{model = "models/survivors/survivor_manager.mdl", present = false, character = 7},
			{model = "models/survivors/survivor_gambler.mdl", present = false, character = 0},
			{model = "models/survivors/survivor_producer.mdl", present = false, character = 1},
			{model = "models/survivors/survivor_coach.mdl", present = false, character = 2},
			{model = "models/survivors/survivor_mechanic.mdl", present = false, character = 3},
		],
		
		// 二代幸存者
		[
			{model = "models/survivors/survivor_gambler.mdl", present = false, character = 0},
			{model = "models/survivors/survivor_producer.mdl", present = false, character = 1},
			{model = "models/survivors/survivor_coach.mdl", present = false, character = 2},
			{model = "models/survivors/survivor_mechanic.mdl", present = false, character = 3},
			{model = "models/survivors/survivor_namvet.mdl", present = false, character = 6},
			{model = "models/survivors/survivor_teenangst.mdl", present = false, character = 5},
			{model = "models/survivors/survivor_biker.mdl", present = false, character = 6},
			{model = "models/survivors/survivor_manager.mdl", present = false, character = 7},
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
			if(::AllSurvivors._CharacterInfo[sets][i].model == models)
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
				// printl("[AllSurvivors] player " + player.GetName() + " is an original!");
			}
			else if(free != null)
			{
				player.SetModel(::AllSurvivors._CharacterInfo[sets][index]["model"]);
				player.SetSurvivorCharacter(::AllSurvivors._CharacterInfo[sets][index]["character"]);
				::AllSurvivors._CharacterInfo[sets][index]["present"] = true;
				
				printl("player " + player.GetName() + " setting " + free);
			}
		}
		
		printl("update survivor complete.");
	},
	
	function CheckFakeSurvivors()
	{
		foreach(index, item in ::AllSurvivors._CharacterInfo[Utils.GetSurvivorSet()])
		{
			if(item["present"])
				continue;
			
			foreach(entity in Objects.OfModel(item["model"]))
			{
				entity.Kill();
				SendToServerConsole("sb_add");
			}
		}
		
		printl("clean up fake survivor complete.");
	},
	
	function Timer_CheckSurvivors(params)
	{
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
	},
	
	function Timer_FixRoundEndCrash(params)
	{
		foreach(survivor in Players.L4D1Survivors())
			survivor.Kill();
		
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

function Notifications::OnFirstSpawn::AllSurvivors_StartCheck(player, params)
{
	if(!::AllSurvivors.ConfigVar.Enable)
		return;
	
	if(::AllSurvivors.HasCharacterChecked && ::AllSurvivors.HasSurvivorChecked)
		return;
	
	Timers.AddTimerByName("timer_checksurvivorcharacter", 6.0, false,
		::AllSurvivors.Timer_CheckSurvivors);
}

function Notifications::OnDoorUnlocked::AllSurvivors_StartCheck(player, checkpoint, params)
{
	if(!::AllSurvivors.ConfigVar.Enable || !checkpoint)
		return;
	
	if(::AllSurvivors.HasCharacterChecked && ::AllSurvivors.HasSurvivorChecked)
		return;
	
	Timers.AddTimerByName("timer_checksurvivorcharacter", 1.0, false,
		::AllSurvivors.Timer_CheckSurvivors);
}

function Notifications::FirstSurvLeftStartArea::AllSurvivors_StartCheck(player, params)
{
	if(!::AllSurvivors.ConfigVar.Enable)
		return;
	
	if(::AllSurvivors.HasCharacterChecked && ::AllSurvivors.HasSurvivorChecked)
		return;
	
	Timers.AddTimerByName("timer_checksurvivorcharacter", 0.1, false,
		::AllSurvivors.Timer_CheckSurvivors);
}

function Notifications::OnSurvivorsDead::AllSurvivors_CrashFixer()
{
	Timers.AddTimerByName("timer_checksurvivorcharacter", 1.0, false,
		::AllSurvivors.Timer_FixRoundEndCrash);
}

function Notifications::OnRoundEnd::AllSurvivors_CrashFixer(winner, reason, message, time, params)
{
	Timers.AddTimerByName("timer_checksurvivorcharacter", 1.0, false,
		::AllSurvivors.Timer_FixRoundEndCrash);
}

function Notifications::OnMapEnd::AllSurvivors_CrashFixer()
{
	Timers.AddTimerByName("timer_checksurvivorcharacter", 1.0, false,
		::AllSurvivors.Timer_FixRoundEndCrash);
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
