::TougherSurvivorBots <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,
		
		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
		
		// 是否开启开枪引怪
		Chase = true,
		
		// 是否开启自动打头
		Headshot = true,
	},
	
	ConfigVar = {},
	
	DamageSpecialMult = 1.0,
	DamageCommonMult = 1.0,
	DamageTakeMult = 1.0,
	
	function UpdateDamageMult()
	{
		switch(Utils.GetDifficulty())
		{
			case "easy":
			{
				::TougherSurvivorBots.DamageTakeMult = 1.0;
				::TougherSurvivorBots.DamageSpecialMult = 1.0;
				::TougherSurvivorBots.DamageCommonMult = 1.25;
				printl("[TougherSurvivorBots] damage multipliers changed to easy mode.");
				break;
			}
			case "normal":
			{
				::TougherSurvivorBots.DamageTakeMult = 0.75;
				::TougherSurvivorBots.DamageSpecialMult = 1.1;
				::TougherSurvivorBots.DamageCommonMult = 1.5;
				printl("[TougherSurvivorBots] damage multipliers changed to normal mode.");
				break;
			}
			case "hard":
			{
				::TougherSurvivorBots.DamageTakeMult = 0.5;
				::TougherSurvivorBots.DamageSpecialMult = 1.2;
				::TougherSurvivorBots.DamageCommonMult = 1.75;
				printl("[TougherSurvivorBots] damage multipliers changed to hard mode.");
				break;
			}
			case "impossible":
			{
				::TougherSurvivorBots.DamageTakeMult = 0.25;
				::TougherSurvivorBots.DamageSpecialMult = 1.3;
				::TougherSurvivorBots.DamageCommonMult = 2.0;
				printl("[TougherSurvivorBots] damage multipliers changed to impossible mode.");
				break;
			}
			default:
			{
				::TougherSurvivorBots.DamageTakeMult = 0.75;
				::TougherSurvivorBots.DamageSpecialMult = 1.1;
				::TougherSurvivorBots.DamageCommonMult = 1.5;
				printl("[TougherSurvivorBots] damage multipliers changed to undefined mode.");
			}
		}
	},
	
	INFECTED_TYPE = [
		Z_INFECTED,
		Z_SMOKER,
		Z_BOOMER,
		Z_HUNTER,
		Z_SPITTER,
		Z_JOCKEY,
		Z_CHARGER,
		Z_MOB
	],
};

function Notifications::OnWeaponFire::TougherSurvivorBots(player, classname, params)
{
	if(!::TougherSurvivorBots.ConfigVar.Enable || !::TougherSurvivorBots.ConfigVar.Chase)
		return;
	
	if(!Utils.IsValidFireWeapon(classname))
		return;
	
	if(player == null || !player.IsSurvivor())
		return;
	
	if(::AdminSystem.IsPrivileged(player))
		return;
	
	player.Chase(800);
}

function EasyLogic::OnTakeDamage::TougherSurvivorBots(dmgTable)
{
	if(!::TougherSurvivorBots.ConfigVar.Enable)
		return;
	
	if(dmgTable["Victim"] == null || dmgTable["Attacker"] == null || dmgTable["DamageDone"] <= 0.0)
		return true;
	
	// 攻击加成
	if(dmgTable["Attacker"].IsSurvivor() && dmgTable["Attacker"].IsBot() && !dmgTable["Attacker"].IsHumanSpectating())
	{
		local type = dmgTable["Victim"].GetType();
		switch(type)
		{
			case Z_COMMON:
			case Z_INFECTED:
			{
				// return dmgTable["DamageDone"] *= ::TougherSurvivorBots.DamageCommonMult;
				return { "DamageDone" : dmgTable["DamageDone"] * ::TougherSurvivorBots.DamageCommonMult, "DamageType" : dmgTable["DamageType"] | DMG_STUMBLE };
			}
			case Z_WITCH:
			case Z_WITCH_BRIDE:
			{
				// return dmgTable["DamageDone"] *= ::TougherSurvivorBots.DamageCommonMult;
				return { "DamageDone" : dmgTable["DamageDone"] * ::TougherSurvivorBots.DamageCommonMult, "DamageType" : dmgTable["DamageType"] | DMG_STUMBLE | DMG_HEADSHOT };
			}
			case Z_BOOMER:
			case Z_SPITTER:
			{
				return dmgTable["DamageDone"] *= ::TougherSurvivorBots.DamageSpecialMult;
			}
			case Z_CHARGER:
			{
				local ability = dmgTable["Victim"].GetNetPropEntity("m_customAbility");
				if(::TougherSurvivorBots.ConfigVar.Headshot && ability != null && ability.IsValid() && ability.GetNetPropBool("m_isCharging"))
					return { "DamageDone" : dmgTable["DamageDone"] * ::TougherSurvivorBots.DamageSpecialMult, "DamageType" : dmgTable["DamageType"] | DMG_HEADSHOT };
				return dmgTable["DamageDone"] *= ::TougherSurvivorBots.DamageSpecialMult;
			}
			case Z_JOCKEY:
			case Z_HUNTER:
			{
				if(::TougherSurvivorBots.ConfigVar.Headshot && !dmgTable["Victim"].IsOnGround())
					return { "DamageDone" : dmgTable["DamageDone"] * ::TougherSurvivorBots.DamageSpecialMult, "DamageType" : dmgTable["DamageType"] | DMG_HEADSHOT };
				return dmgTable["DamageDone"] *= ::TougherSurvivorBots.DamageSpecialMult;
			}
			case Z_SMOKER:
			{
				if(::TougherSurvivorBots.ConfigVar.Headshot && dmgTable["Victim"].GetNetPropEntity("m_tongueVictim") != null)
					return { "DamageDone" : dmgTable["DamageDone"] * ::TougherSurvivorBots.DamageSpecialMult, "DamageType" : dmgTable["DamageType"] | DMG_HEADSHOT };
				return dmgTable["DamageDone"] *= ::TougherSurvivorBots.DamageSpecialMult;
			}
		}
	}
	
	// 伤害降低
	if(dmgTable["Victim"].IsSurvivor() && dmgTable["Victim"].IsBot() && !dmgTable["Victim"].IsHumanSpectating() && !dmgTable["Victim"].IsIncapacitated() &&
		dmgTable["Attacker"].IsValid() && ::TougherSurvivorBots.INFECTED_TYPE.find(dmgTable["Attacker"].GetType()) != null)
	{
		if(dmgTable["DamageType"] & DMG_BURN)
			dmgTable["DamageDone"] /= 1.5;
		
		return dmgTable["DamageDone"] *= ::TougherSurvivorBots.DamageTakeMult;
	}
}

function Notifications::OnDifficulty::TougherSurvivorBots(difficulty, params)
{
	::TougherSurvivorBots.UpdateDamageMult();
}

::TougherSurvivorBots.PLUGIN_NAME <- PLUGIN_NAME;
::TougherSurvivorBots.ConfigVar = ::TougherSurvivorBots.ConfigVarDef;

function Notifications::OnRoundStart::TougherSurvivorBots_LoadConfig()
{
	RestoreTable(::TougherSurvivorBots.PLUGIN_NAME, ::TougherSurvivorBots.ConfigVar);
	if(::TougherSurvivorBots.ConfigVar == null || ::TougherSurvivorBots.ConfigVar.len() <= 0)
		::TougherSurvivorBots.ConfigVar = FileIO.GetConfigOfFile(::TougherSurvivorBots.PLUGIN_NAME, ::TougherSurvivorBots.ConfigVarDef);

	// printl("[plugins] " + ::TougherSurvivorBots.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::TougherSurvivorBots_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::TougherSurvivorBots.PLUGIN_NAME, ::TougherSurvivorBots.ConfigVar);

	// printl("[plugins] " + ::TougherSurvivorBots.PLUGIN_NAME + " saving...");
}
