::AIDamageFix <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
	},
	ConfigVar = {},
	
	iHunterSkeetDamage = {},
};

function EasyLogic::OnTakeDamage::AIDamageFix(dmgTable)
{
	if(!::AIDamageFix.ConfigVar.Enable)
		return;
	
	if(dmgTable["Victim"] == null || dmgTable["Attacker"] == null || dmgTable["DamageDone"] <= 0.0)
		return;
	
	local type = dmgTable["Victim"].GetType();
	local uid = dmgTable["Victim"].GetUserID();
	if(type == Z_HUNTER)
	{
		if(uid in ::AIDamageFix.iHunterSkeetDamage)
			::AIDamageFix.iHunterSkeetDamage[uid] += dmgTable["DamageDone"];
		else
			::AIDamageFix.iHunterSkeetDamage[uid] <- dmgTable["DamageDone"];
		
		local maxDamage = Convars.GetFloat("z_pounce_damage_interrupt");
		if(dmgTable["Victim"].GetNetPropBool("m_isAttemptingToPounce") && ::AIDamageFix.iHunterSkeetDamage[uid] >= maxDamage)
		{
			delete ::AIDamageFix.iHunterSkeetDamage[uid];
			return dmgTable["Victim"].GetHealth();
		}
	}
	else if(type == Z_CHARGER)
	{
		local ability = dmgTable["Victim"].GetNetPropEntity("m_customAbility");
		if(ability != null && ability.IsValid() && ability.GetNetPropBool("m_isCharging"))
		{
			return ((dmgTable["DamageDone"] * 3) + 1);
		}
	}
}

::AIDamageFix.PLUGIN_NAME <- PLUGIN_NAME;
::AIDamageFix.ConfigVar = ::AIDamageFix.ConfigVarDef;

function Notifications::OnRoundStart::AIDamageFix_LoadConfig()
{
	RestoreTable(::AIDamageFix.PLUGIN_NAME, ::AIDamageFix.ConfigVar);
	if(::AIDamageFix.ConfigVar == null || ::AIDamageFix.ConfigVar.len() <= 0)
		::AIDamageFix.ConfigVar = FileIO.GetConfigOfFile(::AIDamageFix.PLUGIN_NAME, ::AIDamageFix.ConfigVarDef);

	// printl("[plugins] " + ::AIDamageFix.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::AIDamageFix_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::AIDamageFix.PLUGIN_NAME, ::AIDamageFix.ConfigVar);

	// printl("[plugins] " + ::AIDamageFix.PLUGIN_NAME + " saving...");
}
