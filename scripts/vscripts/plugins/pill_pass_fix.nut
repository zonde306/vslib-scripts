::PillPassFix <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,
		
		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
	},
	
	ConfigVar = {},
	
	function Timer_SetWeapon(params)
	{
		if(params["player"].GetActiveWeapon() != params["weapon"])
		{
			params["player"].SetNetPropEntity("m_hActiveWeapon", params["weapon"]);
			params["player"].SetNetPropEntity("m_hViewModel", params["viewmodel"]);
			printl("player " + params["player"] + " set weapon " + params["weapon"]);
			return false;
		}
	},
	
	function Timer_StopSetWeapon(params)
	{
		Timers.RemoveTimer(params["timer"]);
	},
};

function Notifications::OnWeaponGiven::PillPassFix(receiver, giver, weapon, params)
{
	if(!::PillPassFix.ConfigVar.Enable)
		return;
	
	if(params["weapon"] == 15 || params["weapon"] == 23)
	{
		local timer = Timers.AddTimer(0.01, true, ::PillPassFix.Timer_SetWeapon, {
			"player" : receiver,
			"weapon" : receiver.GetActiveWeapon(),
			"viewmodel" : receiver.GetNetPropEntity("m_hViewModel"),
		});
		/*
		Timers.AddTimer(3.0, false, ::PillPassFix.Timer_StopSetWeapon, {
			"timer" : timer,
		});
		*/
	}
}

::PillPassFix.PLUGIN_NAME <- PLUGIN_NAME;
::PillPassFix.ConfigVar = ::PillPassFix.ConfigVarDef;

function Notifications::OnRoundStart::PillPassFix_LoadConfig()
{
	RestoreTable(::PillPassFix.PLUGIN_NAME, ::PillPassFix.ConfigVar);
	if(::PillPassFix.ConfigVar == null || ::PillPassFix.ConfigVar.len() <= 0)
		::PillPassFix.ConfigVar = FileIO.GetConfigOfFile(::PillPassFix.PLUGIN_NAME, ::PillPassFix.ConfigVarDef);

	// printl("[plugins] " + ::PillPassFix.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::PillPassFix_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::PillPassFix.PLUGIN_NAME, ::PillPassFix.ConfigVar);

	// printl("[plugins] " + ::PillPassFix.PLUGIN_NAME + " saving...");
}
