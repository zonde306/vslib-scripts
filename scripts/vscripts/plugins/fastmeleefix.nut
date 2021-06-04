::FastMeleeFix <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
		
		// 思考间隔
		ThinkInterval = 0.1
	},
	
	ConfigVar = {},
	
	function Timer_CheckFastMelee(params)
	{
		if(!::FastMeleeFix.ConfigVar.Enable)
			return;
		
		local time = Time();
		local player = params["player"];
		local shouldbe = params["nextSwigTime"];
		
		if(shouldbe <= time || !player.IsSurvivor() || !player.IsAlive())
			return false;
		
		local weapon = player.GetActiveWeapon()
		if(weapon == null || weapon.GetClassname() != "weapon_melee")
			return;
		
		local byServer = time + 0.5;
		local nextAttack = (byServer < shouldbe ? byServer : shouldbe);
		if(weapon.GetNetPropFloat("m_flNextPrimaryAttack") < nextAttack)
		{
			weapon.SetNetPropFloat("m_flNextPrimaryAttack", nextAttack);
			// printl("survivor " + player.GetName() + " detect fastmelee.");
		}
		
		if(nextAttack <= time)
			return false;
	}
};

function Notifications::OnWeaponFire::FastMeleeFix(player, weapon, params)
{
	if(player == null || !player.IsSurvivor() || weapon != "weapon_melee")
		return;
	
	Timers.AddTimerByName("timer_fastmeleefix_" + player.GetIndex(), ::FastMeleeFix.ConfigVar.ThinkInterval, true,
		::FastMeleeFix.Timer_CheckFastMelee, { "player" : player, "nextSwigTime" : Time() + 0.92 });
}

::FastMeleeFix.PLUGIN_NAME <- PLUGIN_NAME;
::FastMeleeFix.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::FastMeleeFix.ConfigVarDef);

function Notifications::OnRoundStart::FastMeleeFix_LoadConfig()
{
	RestoreTable(::FastMeleeFix.PLUGIN_NAME, ::FastMeleeFix.ConfigVar);
	if(::FastMeleeFix.ConfigVar == null || ::FastMeleeFix.ConfigVar.len() <= 0)
		::FastMeleeFix.ConfigVar = FileIO.GetConfigOfFile(::FastMeleeFix.PLUGIN_NAME, ::FastMeleeFix.ConfigVarDef);

	// printl("[plugins] " + ::FastMeleeFix.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::FastMeleeFix_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::FastMeleeFix.PLUGIN_NAME, ::FastMeleeFix.ConfigVar);

	// printl("[plugins] " + ::FastMeleeFix.PLUGIN_NAME + " saving...");
}
