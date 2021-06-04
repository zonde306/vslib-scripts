::MultipleGascanFill <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
	},
	
	ConfigVar = {},
	
	function Timer_HookOnUseStarted(params)
	{
		foreach(entity in Objects.OfClassname("point_prop_use_target"))
			entity.ConnectOutput("OnUseStarted", ::MultipleGascanFill.Hooked_OnUseStarted, "multiplefill");
	},
	
	function Hooked_OnUseStarted()
	{
		local entity = Utils.GetEntityOrPlayer(this.caller);
		if(entity == null || !entity.IsEntityValid())
			return;
		
		entity.SetNetPropEntity("m_useActionOwner", null);
	},
};

function Notifications::OnRoundBegin::MultipleGascanFill(params)
{
	if(!::MultipleGascanFill.ConfigVar.Enable)
		return;
	
	if(HasPlayerControlledZombies())
		return;
	
	Timers.AddTimerByName("timer_multiplegascan", 1.5, false, ::MultipleGascanFill.Timer_HookOnUseStarted);
}

::MultipleGascanFill.PLUGIN_NAME <- PLUGIN_NAME;
::MultipleGascanFill.ConfigVar = ::MultipleGascanFill.ConfigVarDef;

function Notifications::OnRoundStart::MultipleGascanFill_LoadConfig()
{
	RestoreTable(::MultipleGascanFill.PLUGIN_NAME, ::MultipleGascanFill.ConfigVar);
	if(::MultipleGascanFill.ConfigVar == null || ::MultipleGascanFill.ConfigVar.len() <= 0)
		::MultipleGascanFill.ConfigVar = FileIO.GetConfigOfFile(::MultipleGascanFill.PLUGIN_NAME, ::MultipleGascanFill.ConfigVarDef);

	// printl("[plugins] " + ::MultipleGascanFill.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::MultipleGascanFill_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::MultipleGascanFill.PLUGIN_NAME, ::MultipleGascanFill.ConfigVar);

	// printl("[plugins] " + ::MultipleGascanFill.PLUGIN_NAME + " saving...");
}
