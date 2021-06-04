::AutoPistol <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
	},
	ConfigVar = {},
	
	function Timer_SetHoldButton(weapon)
	{
		if(weapon != null && weapon.IsValid())
			weapon.SetNetPropInt("m_isHoldingFireButton", 0);
	},
}

function Notifications::OnWeaponFire::AutoPistol(player, weaponName, params)
{
	if(!::AutoPistol.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsValid())
		return;
	
	local weapon = player.GetActiveWeapon();
	if(weapon == null || !weapon.IsValid())
		return;
	
	weapon.SetNetPropInt("m_isHoldingFireButton", 0);
	Timers.AddTimerByName("autopistol_" + player.GetUserID(), 0.01, false,
		::AutoPistol.Timer_SetHoldButton, weapon,
		0, { "action" : "reset" }
	);
}

::AutoPistol.PLUGIN_NAME <- PLUGIN_NAME;
::AutoPistol.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::AutoPistol.ConfigVarDef);

function Notifications::OnRoundStart::AutoPistol_LoadConfig()
{
	RestoreTable(::AutoPistol.PLUGIN_NAME, ::AutoPistol.ConfigVar);
	if(::AutoPistol.ConfigVar == null || ::AutoPistol.ConfigVar.len() <= 0)
		::AutoPistol.ConfigVar = FileIO.GetConfigOfFile(::AutoPistol.PLUGIN_NAME, ::AutoPistol.ConfigVarDef);

	// printl("[plugins] " + ::AutoPistol.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::AutoPistol_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::AutoPistol.PLUGIN_NAME, ::AutoPistol.ConfigVar);

	// printl("[plugins] " + ::AutoPistol.PLUGIN_NAME + " saving...");
}
