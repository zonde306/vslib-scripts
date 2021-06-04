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
	HasGameStarted = false,
	HasRoundEnded = false,
	
	function GetModelIndex(model)
	{
		if(model in EasyLogic.SetModelIndexes)
			return EasyLogic.SetModelIndexes[model];
		
		local dummyEnt = Utils.CreateEntity("prop_dynamic_override", Vector(0, 0, 0), QAngle(0, 0, 0), { model = mdl, renderfx = 15, solid = 1 });
		local index = dummyEnt.GetNetPropInt("m_nModelIndex");
		EasyLogic.SetModelIndexes[model] <- index;
		dummyEnt.Kill();
		
		return index;
	},
	
	function FindCharacterInfoByModel(model)
	{
		local sets = Utils.GetSurvivorSet();
		
		for(local i = 0; i < 8; ++i)
		{
			if(::AllSurvivors._CharacterInfo[sets][i].model == model)
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
		return total;
	},
	
	function CheckFakeSurvivors()
	{
		local total = 0;
		
		foreach(index, item in ::AllSurvivors._CharacterInfo[Utils.GetSurvivorSet()])
		{
			if(item["present"])
				continue;
			
			local kicked = false;
			foreach(entity in Objects.OfModel(item["model"]))
			{
				if(entity.IsSurvivor() && entity.IsPlayer() && entity.IsAlive())
					continue;
				
				local name = entity.GetName();
				local classname = entity.GetClassname();
				entity.Input("Kill");
				SendToServerConsole("sb_add");
				
				total += 1;
				kicked = true;
				printl("faker " + name + "(" + classname + ") has be killed by model");
			}
			
			/*
			if(!kicked)
			{
				foreach(entity in Objects.OfName(item["name"]))
				{
					if(entity.IsSurvivor() && entity.IsPlayer() && entity.IsAlive())
						continue;
					
					local name = entity.GetName();
					local classname = entity.GetClassname();
					entity.Input("Kill");
					SendToServerConsole("sb_add");
					
					total += 1;
					kicked = true;
					printl("faker " + name + "(" + classname + ") has be killed by targetname");
				}
			}
			
			if(!kicked)
			{
				foreach(entity in Objects.All())
				{
					if(entity.IsSurvivor() && entity.IsPlayer() && entity.IsAlive())
						continue;
					
					if(entity.HasNetProp("m_ModelName"))
					{
						if(entity.GetModel().tolower() != item["model"].tolower())
							continue;
					}
					else if(entity.HasNetProp("m_nModelIndex"))
					{
						if(entity.GetNetPropInt("m_nModelIndex") != ::AllSurvivors.GetModelIndex(item["model"]))
							continue;
					}
					else
					{
						continue;
					}
					
					local name = entity.GetName();
					local classname = entity.GetClassname();
					entity.Input("Kill");
					SendToServerConsole("sb_add");
					
					total += 1;
					kicked = true;
					printl("faker " + name + "(" + classname + ") has be killed by index");
				}
			}
			*/
			
			if(!kicked)
			{
				local player = Utils.GetPlayerFromName(item["name"]);
				if(player == null)
				{
					SendToServerConsole("kick " + item["name"]);
					SendToServerConsole("sb_add");
					
					total += 1;
					printl("faker " + item["name"] + " has be kicked by name");
				}
			}
		}
		
		printl("clean up fake survivor " + total + " completed.");
		return total;
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
		return total;
	},
	
	function Timer_CheckSurvivors(params)
	{
		local haveHuman = false;
		foreach(player in Players.AliveSurvivors())
		{
			if(player.IsBot())
				continue;
			
			haveHuman = true;
			break;
		}
		if(!haveHuman)
			return 0.1;
		
		foreach(entity in Objects.OfClassname("info_transitioning_player"))
		{
			entity.Kill();
			SendToServerConsole("sb_add");
		}
		
		// ::AllSurvivors.UpdateSurvivorInfo();
		if(params == true || (::AllSurvivors.ConfigVar.CharacterFix && !::AllSurvivors.HasCharacterChecked))
		{
			::AllSurvivors.CheckSurvivorCharacter();
			::AllSurvivors.HasCharacterChecked = true;
		}
		
		if(params == true || (::AllSurvivors.ConfigVar.ChangeLevelFix && !::AllSurvivors.HasSurvivorChecked))
		{
			::AllSurvivors.CheckFakeSurvivors();
			::AllSurvivors.HasSurvivorChecked = true;
		}
		
		// ::AllSurvivors.CheckInactivatedSurvivors();
		SendToServerConsole("sb_add");
		SendToServerConsole("sb_add");
		SendToServerConsole("sb_add");
		return false;
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

/*
function Notifications::OnMapFirstStart::AllSurvivors_StartCheck()
{
	if(!::AllSurvivors.ConfigVar.Enable)
		return;
	
	::AllSurvivors.HasGameStarted = false;
	
	Timers.AddTimerByName("timer_checksurvivorcharacter", 3.0, false,
		::AllSurvivors.Timer_CheckSurvivors);
}
*/

function Notifications::OnFirstSpawn::AllSurvivors_StartCheck(player, params)
{
	if(!::AllSurvivors.ConfigVar.Enable)
		return;
	
	if(::AllSurvivors.HasGameStarted || player == null || !player.IsSurvivor())
		return;
	
	Timers.AddTimerByName("timer_checksurvivorcharacter", 0.5, false,
		::AllSurvivors.Timer_CheckSurvivors);
}

function Notifications::OnSpawn::AllSurvivors_StartCheck(player, params)
{
	if(!::AllSurvivors.ConfigVar.Enable)
		return;
	
	if(::AllSurvivors.HasGameStarted || player == null || !player.IsSurvivor())
		return;
	
	Timers.AddTimerByName("timer_checksurvivorcharacter", 0.1, false,
		::AllSurvivors.Timer_CheckSurvivors);
}

function Notifications::OnDoorUnlocked::AllSurvivors_StartCheck(player, checkpoint, params)
{
	if(!::AllSurvivors.ConfigVar.Enable || !checkpoint)
		return;
	
	Timers.AddTimerByName("timer_checksurvivorcharacter", 0.1, false,
		::AllSurvivors.Timer_CheckSurvivors);
}

function Notifications::FirstSurvLeftStartArea::AllSurvivors_StartCheck(player, params)
{
	if(!::AllSurvivors.ConfigVar.Enable)
		return;
	
	::AllSurvivors.HasGameStarted = true;
	
	Timers.AddTimerByName("timer_checksurvivorcharacter", 0.1, false,
		::AllSurvivors.Timer_CheckSurvivors);
}

function Notifications::OnSurvivorsLeftStartArea::AllSurvivors_StartCheck()
{
	if(!::AllSurvivors.ConfigVar.Enable)
		return;
	
	::AllSurvivors.HasGameStarted = true;
	
	Timers.AddTimerByName("timer_checksurvivorcharacter", 0.2, false,
		::AllSurvivors.Timer_CheckSurvivors);
}

function Notifications::OnTeamChanged::AllSurvivors_StartCheck(player, oldTeam, newTeam, params)
{
	if(!::AllSurvivors.ConfigVar.Enable)
		return;
	
	if(::AllSurvivors.HasGameStarted)
		return;
	
	if(("isbot" in params && params["isbot"]) || ("disconnect" in params && params["disconnect"]) ||
		player == null || !player.IsPlayer() || player.IsBot())
		return;
	
	if(newTeam != SURVIVORS || oldTeam > UNKNOWN)
		return;
	
	Timers.AddTimerByName("timer_checksurvivorcharacter", 0.1, false,
		::AllSurvivors.Timer_CheckSurvivors);
}

function Notifications::OnSurvivorsDead::AllSurvivors_CrashFixer()
{
	Timers.AddTimerByName("timer_checksurvivorcharacter", 1.0, false,
		::AllSurvivors.Timer_FixRoundEndCrash);
	
	::AllSurvivors.RestoreSurvivorInfo();
	::AllSurvivors.HasGameStarted = false;
}

function Notifications::OnRoundEnd::AllSurvivors_CrashFixer(winner, reason, message, time, params)
{
	Timers.AddTimerByName("timer_checksurvivorcharacter", 1.0, false,
		::AllSurvivors.Timer_FixRoundEndCrash);
	
	::AllSurvivors.RestoreSurvivorInfo();
	::AllSurvivors.HasGameStarted = false;
}

function Notifications::OnMapEnd::AllSurvivors_CrashFixer()
{
	Timers.AddTimerByName("timer_checksurvivorcharacter", 1.0, false,
		::AllSurvivors.Timer_FixRoundEndCrash);
	
	::AllSurvivors.RestoreSurvivorInfo();
	::AllSurvivors.HasGameStarted = false;
	::AllSurvivors.HasRoundEnded = true;
}

function Notifications::OnPlayerLeft::AllSurvivors_BanPlayer(player, name, steamId, params)
{
	if(!::AllSurvivors.ConfigVar.Enable)
		return;
	
	if(!::AllSurvivors.HasRoundEnded)
		return;
	
	if(steamId == "" || steamId == null || steamId == "BOT" || (("bot" in params) && params["bot"]))
		return;
	
	if(::AdminSystem.IsPrivileged(player))
		return;
	
	SendToServerConsole("banid 60 \"" + steamId + "\"");
	printl("player " + name + " banned by MapEnd.");
}

function EasyLogic::OnCmdTriggersEx::checksurvivors(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	::AllSurvivors.Timer_CheckSurvivors(true);
}

::AllSurvivors.PLUGIN_NAME <- PLUGIN_NAME;
::AllSurvivors.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::AllSurvivors.ConfigVarDef);

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
