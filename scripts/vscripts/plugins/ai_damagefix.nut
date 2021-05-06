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
	iChargerCarry = {},
	
	function Timer_StopChargerAttacking(uid)
	{
		if(uid in ::AIDamageFix.iChargerCarry)
			delete ::AIDamageFix.iChargerCarry[uid];
	},
};

function Notifications::OnSpawn::AIDamageFix(player, params)
{
	if(player == null || !player.IsValid())
		return;
	
	::AIDamageFix.iHunterSkeetDamage[player.GetUserID()] <- 0;
}

function Notifications::OnChargerCarryVictimEnd::AIDamageFix(attacker, victim, params)
{
	if(attacker == null || victim == null || !attacker.IsPlayer() || !victim.IsSurvivor() || attacker.IsDead() || victim.IsDead())
		return;
	
	local uid = victim.GetUserID();
	::AIDamageFix.iChargerCarry[uid] <- attacker;
	Timers.AddTimerByName("carryend_" + uid, 3.0, false, ::AIDamageFix.Timer_StopChargerAttacking, uid, 0, { "action" : "reset" });
}

function EasyLogic::OnTakeDamage::AIDamageFix(dmgTable)
{
	if(!::AIDamageFix.ConfigVar.Enable)
		return;
	
	if(dmgTable["Victim"] == null || dmgTable["Attacker"] == null || dmgTable["DamageDone"] <= 0.0 || !dmgTable["Victim"].IsPlayer())
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
	else if(type == Z_SURVIVOR)
	{
		if(dmgTable["Attacker"].IsSurvivor())
		{
			local charger = dmgTable["Victim"].GetNetPropEntity("m_carryAttacker");
			if(charger == null && uid in ::AIDamageFix.iChargerCarry)
				charger = ::AIDamageFix.iChargerCarry[uid];
			if(charger != null && charger && charger.IsValid() && charger.GetType() == Z_CHARGER)
			{
				charger.Damage(dmgTable["DamageDone"], dmgTable["DamageType"], dmgTable["Attacker"]);
				printl("attacking " + dmgTable["Victim"] + " forward to " + charger);
				return 0.0;
			}
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
