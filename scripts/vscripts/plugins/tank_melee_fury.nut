::TankMeleeFury <-
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

function Notifications::OnHurt::TankMeleeFury(victim, attacker, params)
{
	if(!::TankMeleeFury.ConfigVar.Enable)
		return;
	
	if(!("weapon" in params) || (params["weapon"] != "melee" && params["weapon"] != "weapon_melee"))
		return;
	
	if(victim == null || attacker == null || !victim.IsValid() || !attacker.IsSurvivor() || victim.GetType() != Z_TANK)
		return;
	
	local claw = victim.GetActiveWeapon();
	if(claw == null || !claw.IsValid())
		return;
	
	local swingTime = Convars.GetFloat("tank_swing_interval") + Convars.GetFloat("tank_windup_time");
	claw.SetNetPropFloat("m_flNextPrimaryAttack", claw.GetNetPropFloat("m_flNextPrimaryAttack") - swingTime);
	claw.SetNetPropFloat("m_flNextSecondaryAttack", claw.GetNetPropFloat("m_flNextSecondaryAttack") - swingTime);
}

::TankMeleeFury.PLUGIN_NAME <- PLUGIN_NAME;
::TankMeleeFury.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::TankMeleeFury.ConfigVarDef);

function Notifications::OnRoundStart::TankMeleeFury_LoadConfig()
{
	RestoreTable(::TankMeleeFury.PLUGIN_NAME, ::TankMeleeFury.ConfigVar);
	if(::TankMeleeFury.ConfigVar == null || ::TankMeleeFury.ConfigVar.len() <= 0)
		::TankMeleeFury.ConfigVar = FileIO.GetConfigOfFile(::TankMeleeFury.PLUGIN_NAME, ::TankMeleeFury.ConfigVarDef);

	// printl("[plugins] " + ::TankMeleeFury.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::TankMeleeFury_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::TankMeleeFury.PLUGIN_NAME, ::TankMeleeFury.ConfigVar);

	// printl("[plugins] " + ::TankMeleeFury.PLUGIN_NAME + " saving...");
}
