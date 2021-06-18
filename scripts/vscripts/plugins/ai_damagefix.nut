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
	
	iSkeetDamage = {},
	iChargerCarry = {},
	fStaggerTime = {},
	
	function Timer_StopChargerAttacking(uid)
	{
		if(uid in ::AIDamageFix.iChargerCarry)
			delete ::AIDamageFix.iChargerCarry[uid];
	},
	
	function IsJockeyLeaping(jockey)
	{
		if(jockey == null || !jockey.IsValid() || jockey.GetType() != Z_JOCKEY ||
			jockey.IsOnGround() ||
			jockey.GetMoveType() != MOVETYPE_WALK ||
			jockey.GetNetPropInt("m_nWaterLevel") >= 3 ||	// 0=不在水中.1=水浸到腿部.2=水浸到板身.3=水浸过身体
			jockey.GetNetPropEntity("m_jockeyVictim") != null)
			return false;
		
		local ability = jockey.GetNetPropEntity("m_customAbility");
		if(ability != null && ability.IsValid() && ability.GetNetPropBool("m_isLeaping"))
			return true;
		
		local velocity = jockey.GetVelocity();
		velocity.z = 0.0;	// 不计算下落速度
		
		return (velocity.Length() >= 15.0);
	},
	
	function Timer_ResetSkeet(uid)
	{
		::AIDamageFix.iSkeetDamage[uid] <- 0;
	},
};

function Notifications::OnSpawn::AIDamageFix(player, params)
{
	if(player == null || !player.IsValid())
		return;
	
	::AIDamageFix.iSkeetDamage[player.GetUserID()] <- 0;
}

function Notifications::OnChargerCarryVictimEnd::AIDamageFix(attacker, victim, params)
{
	if(attacker == null || victim == null || !attacker.IsPlayer() || !victim.IsSurvivor() || attacker.IsDead() || victim.IsDead())
		return;
	
	local uid = victim.GetUserID();
	::AIDamageFix.iChargerCarry[uid] <- attacker;
	Timers.AddTimerByName("carryend_" + uid, 3.0, false, ::AIDamageFix.Timer_StopChargerAttacking, uid, 0, { "action" : "reset" });
}

/*
function Notifications::OnPlayerShoved::AIDamageFix(victim, attacker, params)
{
	if(attacker == null || victim == null || !attacker.IsSurvivor() || !victim.IsPlayer() || attacker.IsDead() || victim.IsDead() || victim.GetTeam() != INFECTED)
		return;
	
	local uid = victim.GetUserID();
	::AIDamageFix.fStaggerTime[uid] <- Time() + Convars.GetFloat("z_max_stagger_duration");
}
*/

function EasyLogic::OnTakeDamage::AIDamageFix(dmgTable)
{
	if(!::AIDamageFix.ConfigVar.Enable)
		return;
	
	if(dmgTable["Victim"] == null || dmgTable["Attacker"] == null || dmgTable["DamageDone"] <= 0.0 || !dmgTable["Victim"].IsPlayer())
		return;
	
	local type = dmgTable["Victim"].GetType();
	local uid = dmgTable["Victim"].GetUserID();
	switch(type)
	{
		case Z_HUNTER:
		{
			if(dmgTable["Victim"].GetNetPropBool("m_isAttemptingToPounce"))
			{
				if(uid in ::AIDamageFix.iSkeetDamage)
					::AIDamageFix.iSkeetDamage[uid] += dmgTable["DamageDone"];
				else
					::AIDamageFix.iSkeetDamage[uid] <- dmgTable["DamageDone"];
				
				local maxDamage = Convars.GetFloat("z_pounce_damage_interrupt");
				if(::AIDamageFix.iSkeetDamage[uid] >= maxDamage)
				{
					delete ::AIDamageFix.iSkeetDamage[uid];
					return dmgTable["Victim"].GetHealth();
				}
				else
				{
					Timers.AddTimerByName("dmgfix_reset_" + uid, 0.1, false,
						::AIDamageFix.Timer_ResetSkeet, uid,
						0, { "action" : "reset" }
					);
				}
			}
			break;
		}
		case Z_JOCKEY:
		{
			if(::AIDamageFix.IsJockeyLeaping(dmgTable["Victim"]))
			{
				if(uid in ::AIDamageFix.iSkeetDamage)
					::AIDamageFix.iSkeetDamage[uid] += dmgTable["DamageDone"];
				else
					::AIDamageFix.iSkeetDamage[uid] <- dmgTable["DamageDone"];
				
				local maxDamage = Convars.GetFloat("z_pounce_damage_interrupt") * 1.3;	// 325 / 250 = 1.3
				if(::AIDamageFix.iSkeetDamage[uid] >= maxDamage)
				{
					delete ::AIDamageFix.iSkeetDamage[uid];
					return dmgTable["Victim"].GetHealth();
				}
				else
				{
					Timers.AddTimerByName("dmgfix_reset_" + uid, 0.1, false,
						::AIDamageFix.Timer_ResetSkeet, uid,
						0, { "action" : "reset" }
					);
				}
			}
			break;
		}
		case Z_CHARGER:
		{
			local ability = dmgTable["Victim"].GetNetPropEntity("m_customAbility");
			if(ability != null && ability.IsValid() && ability.GetNetPropBool("m_isCharging"))
			{
				return ((dmgTable["DamageDone"] * 3) + 1);
			}
			break;
		}
		case Z_SURVIVOR:
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
			else if(dmgTable["Attacker"].IsPlayer() && dmgTable["Attacker"].GetTeam() == 3)
			{
				local atype = dmgTable["Attacker"].GetType();
				if((atype == Z_CHARGER || atype == Z_HUNTER || atype == Z_JOCKEY) && dmgTable["Attacker"].IsStaggering())
				{
					printl(dmgTable["Attacker"].GetName() + " has starggering.");
					return 0.0;
				}
			}
			break;
		}
	}
}

function Notifications::OnAbilityUsed::AIDamageFix(player, ability, params)
{
	if(player == null || !player.IsValid())
		return;
	
	::AIDamageFix.iSkeetDamage[player.GetUserID()] <- 0;
}

::AIDamageFix.PLUGIN_NAME <- PLUGIN_NAME;
::AIDamageFix.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::AIDamageFix.ConfigVarDef);

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
