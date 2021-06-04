::SniperDamage <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
		
		// 15发狙击伤害.0=不修改
		HuntingDamage = 0,
		
		// 30发狙击伤害.0=不修改
		MilitaryDamage = 0,
		
		// 鸟狙伤害
		ScoutDamage = 180,
		
		// 大鸟伤害
		AWPDamage = 345,
	},
	
	ConfigVar = {},
};

function EasyLogic::OnTakeDamage::SniperDamage(dmgTable)
{
	if(!::SniperDamage.ConfigVar.Enable)
		return;
	
	if(dmgTable["Victim"] == null || dmgTable["Attacker"] == null || dmgTable["Weapon"] == null || dmgTable["DamageDone"] <= 0.0 ||
		!dmgTable["Attacker"].IsSurvivor() || !dmgTable["Weapon"].IsValid() || dmgTable["Victim"].GetTeam() != INFECTED ||
		!(dmgTable["DamageType"] & (DMG_BULLET|DMG_BUCKSHOT)))
		return;
	
	if(dmgTable["Victim"].GetTeam() != INFECTED)
		return;
	
	switch(dmgTable["Weapon"].GetClassname())
	{
		case "weapon_hunting_rifle":
		{
			if(dmgTable["DamageDone"] < ::SniperDamage.ConfigVar.HuntingDamage)
				return ::SniperDamage.ConfigVar.HuntingDamage;
			break;
		}
		case "weapon_sniper_military":
		{
			if(dmgTable["DamageDone"] < ::SniperDamage.ConfigVar.MilitaryDamage)
				return ::SniperDamage.ConfigVar.MilitaryDamage;
			break;
		}
		case "weapon_sniper_scout":
		{
			if(dmgTable["DamageDone"] < ::SniperDamage.ConfigVar.ScoutDamage)
				return ::SniperDamage.ConfigVar.ScoutDamage;
			break;
		}
		case "weapon_sniper_awp":
		{
			if(dmgTable["DamageDone"] < ::SniperDamage.ConfigVar.AWPDamage)
				return ::SniperDamage.ConfigVar.AWPDamage;
			break;
		}
	}
}

::SniperDamage.PLUGIN_NAME <- PLUGIN_NAME;
::SniperDamage.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::SniperDamage.ConfigVarDef);

function Notifications::OnRoundStart::SniperDamage_LoadConfig()
{
	RestoreTable(::SniperDamage.PLUGIN_NAME, ::SniperDamage.ConfigVar);
	if(::SniperDamage.ConfigVar == null || ::SniperDamage.ConfigVar.len() <= 0)
		::SniperDamage.ConfigVar = FileIO.GetConfigOfFile(::SniperDamage.PLUGIN_NAME, ::SniperDamage.ConfigVarDef);

	// printl("[plugins] " + ::SniperDamage.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::SniperDamage_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::SniperDamage.PLUGIN_NAME, ::SniperDamage.ConfigVar);

	// printl("[plugins] " + ::SniperDamage.PLUGIN_NAME + " saving...");
}
