::RoundStartPause <- 
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
	},
	
	ConfigVar = {},
};

/*
function Notifications::OnRoundStart::RoundStartPause()
{
	if(!::RoundStartPause.ConfigVar.Enable)
		return;
	
	Convars.SetValue("sb_move", "0");
}
*/

function Notifications::OnTeamChanged::RoundStartPause(player, oldTeam, newTeam, params)
{
	if(!::RoundStartPause.ConfigVar.Enable)
		return;
	
	if(("isbot" in params && params["isbot"]) || ("disconnect" in params && params["disconnect"]) ||
		player == null || !player.IsPlayer() || player.IsBot())
		return;
	
	if(newTeam != SURVIVORS && newTeam != INFECTED)
		return;
	
	Convars.SetValue("sb_move", "1");
}

function Notifications::OnMapEnd::RoundStartPause()
{
	if(!::RoundStartPause.ConfigVar.Enable)
		return;
	
	Convars.SetValue("sb_move", "0");
}

::RoundStartPause.PLUGIN_NAME <- PLUGIN_NAME;
::RoundStartPause.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::RoundStartPause.ConfigVarDef);

function Notifications::OnRoundStart::RoundStartPause_LoadConfig()
{
	RestoreTable(::RoundStartPause.PLUGIN_NAME, ::RoundStartPause.ConfigVar);
	if(::RoundStartPause.ConfigVar == null || ::RoundStartPause.ConfigVar.len() <= 0)
		::RoundStartPause.ConfigVar = FileIO.GetConfigOfFile(::RoundStartPause.PLUGIN_NAME, ::RoundStartPause.ConfigVarDef);

	// printl("[plugins] " + ::RoundStartPause.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::RoundStartPause_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::RoundStartPause.PLUGIN_NAME, ::RoundStartPause.ConfigVar);

	// printl("[plugins] " + ::RoundStartPause.PLUGIN_NAME + " saving...");
}
