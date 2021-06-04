::Heartbeat <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 16,
		
		// 是否开启服务器的 heartbeat
		AllowServer = true,
		
		// 是否开启客户端的 heartbeat
		AllowClient = true,
		
		// 两次次 heartbeat 间隔
		Timeout = 20.0,
	},
	
	ConfigVar = {},
	
	HasRecentDisconnect = false,
	
	function OnClientDisconnect(player)
	{
		if(!::Heartbeat.ConfigVar.Enable || ::Heartbeat.HasRecentDisconnect)
			return;
		
		if(::Heartbeat.ConfigVar.AllowServer)
			SendToServerConsole("heartbeat");
		
		if(::Heartbeat.ConfigVar.AllowClient)
			Utils.BroadcastClientCommand("heartbeat");
		
		::Heartbeat.HasRecentDisconnect = true;
		printl("heartbeat sending.");
		
		Timers.AddTimerByName("timer_heartbeat", ::Heartbeat.ConfigVar.Timeout, false,
			::Heartbeat.Timer_ResetTimeout);
	},
	
	function Timer_ResetTimeout(params)
	{
		::Heartbeat.HasRecentDisconnect = false;
		printl("heartbeat reset.");
	}
};

function Notifications::OnPlayerLeft::Heartbeat_OnClientDisconnect(player, name, steamID, params)
{
	if(("bot" in params) && params["bot"])
		return;
	
	::Heartbeat.OnClientDisconnect(player);
}

function Notifications::OnTeamChanged::Heartbeat_OnClientTeam(player, oldteam, newteam, params)
{
	if(!params["disconnect"] || ("isbot" in params && params["isbot"]))
		return;
	
	::Heartbeat.OnClientDisconnect(player);
}

::Heartbeat.PLUGIN_NAME <- PLUGIN_NAME;
::Heartbeat.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::Heartbeat.ConfigVarDef);

function Notifications::OnRoundStart::Heartbeat_LoadConfig()
{
	RestoreTable(::Heartbeat.PLUGIN_NAME, ::Heartbeat.ConfigVar);
	if(::Heartbeat.ConfigVar == null || ::Heartbeat.ConfigVar.len() <= 0)
		::Heartbeat.ConfigVar = FileIO.GetConfigOfFile(::Heartbeat.PLUGIN_NAME, ::Heartbeat.ConfigVarDef);

	// printl("[plugins] " + ::Heartbeat.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::Heartbeat_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::Heartbeat.PLUGIN_NAME, ::Heartbeat.ConfigVar);

	// printl("[plugins] " + ::Heartbeat.PLUGIN_NAME + " saving...");
}
