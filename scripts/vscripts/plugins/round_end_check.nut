::DeathRoundEnd <-
{
	ConfigVarDef =
	{
		// 是否开启这个插件
		Enable = false,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		Mode = 7,

		// 死亡回合结束检查延迟
		Delay = 0.1
	},

	ConfigVar = {},

	function TimerCheck_OnPlayerDeath(params)
	{
		if(Players.AliveSurvivors().len() <= 0)
			Utils.TriggerStage(STAGE_RESULTS, 0);
	}
};

function Notifications::OnDeath::RoundEndCheck(victim, attacker, params)
{
	if(!::DeathRoundEnd.ConfigVar.Enable)
		return;
	
	if(victim == null || !victim.IsPlayer() || !victim.IsPlayerEntityValid() || victim.GetTeam() != SURVIVORS)
		return;
	
	// Convars.SetValue("director_no_death_check", "1");
	Timers.AddTimerByName("timer_deathcheck", ::DeathRoundEnd.ConfigVar.Delay, false,
		::DeathRoundEnd.TimerCheck_OnPlayerDeath);
}

/*
function Notifications::FirstSurvLeftStartArea::RoundEndConvar(player, params)
{
	if(::DeathRoundEnd.ConfigVar.Enable)
	{
		Convars.SetValue("director_no_death_check", "1");
		Convars.SetValue("allow_all_bot_survivor_team", "1");
		Convars.SetValue("sv_rescue_disabled", "0");
		Convars.SetValue("sv_allow_wait_command", "0");
		Convars.SetValue("director_force_witch", "1");
		Convars.SetValue("director_force_tank", "1");
		// Convars.SetValue("director_scavenge_item_override", "1");
		Convars.SetValue("director_must_create_all_scavenge_items", "0");
		Convars.SetValue("survivor_respawn_with_guns", "1");
		Convars.SetValue("defibrillator_return_to_life_time", "1");
		// Convars.SetValue("player_old_armor", "100");
		Convars.SetValue("sb_max_team_melee_weapons", "4");
	}
	else
	{
		Convars.SetValue("director_no_death_check", "0");
		Convars.SetValue("allow_all_bot_survivor_team", "1");
		Convars.SetValue("sv_rescue_disabled", "0");
		Convars.SetValue("sv_allow_wait_command", "0");
		Convars.SetValue("director_force_witch", "1");
		Convars.SetValue("director_force_tank", "1");
		Convars.SetValue("director_scavenge_item_override", "0");
		Convars.SetValue("director_must_create_all_scavenge_items", "0");
		// Convars.SetValue("survivor_respawn_with_guns", "1");
		Convars.SetValue("defibrillator_return_to_life_time", "3");
		Convars.SetValue("player_old_armor", "0");
		Convars.SetValue("sb_max_team_melee_weapons", "1");
	}
}

function Notifications::OnRoundBegin::RoundEndConvar(params)
{
	Notifications.FirstSurvLeftStartArea.RoundEndConvar(null, params);
}
*/

function Notifications::OnIncapacitated::RoundEnd_FixRoundEnd(victim, attacker, params)
{
	if(Utils.GetMaxIncapCount() <= 0)
		victim.Kill(DMG_GENERIC, attacker);
	
	if(::DeathRoundEnd.ConfigVar.Enable)
		Convars.SetValue("director_no_death_check", "1");
	else
		Convars.SetValue("director_no_death_check", "0");
}

::DeathRoundEnd.PLUGIN_NAME <- PLUGIN_NAME;
::DeathRoundEnd.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::DeathRoundEnd.ConfigVarDef);

function Notifications::OnRoundStart::DeathRoundEnd_LoadConfig()
{
	RestoreTable(::DeathRoundEnd.PLUGIN_NAME, ::DeathRoundEnd.ConfigVar);
	if(::DeathRoundEnd.ConfigVar == null || ::DeathRoundEnd.ConfigVar.len() <= 0)
		::DeathRoundEnd.ConfigVar = FileIO.GetConfigOfFile(::DeathRoundEnd.PLUGIN_NAME, ::DeathRoundEnd.ConfigVarDef);

	// printl("[plugins] " + ::DeathRoundEnd.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::DeathRoundEnd_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::DeathRoundEnd.PLUGIN_NAME, ::DeathRoundEnd.ConfigVar);

	// printl("[plugins] " + ::DeathRoundEnd.PLUGIN_NAME + " saving...");
}
