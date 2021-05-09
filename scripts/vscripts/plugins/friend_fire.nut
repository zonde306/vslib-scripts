::FriendlyFire <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = false,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,

		// 是否忽略火焰伤害.0=禁用.1=倒地时.2=黑白时.4=其他.数字相加
		IgnoreFire = 4,

		// 是否忽略爆炸伤害.0=禁用.1=倒地时.2=黑白时.4=其他.数字相加
		IgnoreExplode = 1 + 4,

		// 是否在被控时忽略反伤.0=禁用.1=倒地时.2=黑白时.4=其他.数字相加
		IgnoreGrabbed = 1,
		
		// 是否对机器人忽略反伤.0=禁用.1=倒地时.2=黑白时.4=其他.数字相加
		IgnoreBOTs = 1 + 2,
		
		// 是否忽略安全室内反伤.0=禁用.1=倒地时.2=黑白时.4=其他.数字相加
		IgnoreSafeRoom = 1 + 2,
		
		// 在玩家被从特感手里救出时忽略多少秒的反伤.0=禁用
		// 用于防止刚被救出没反应过来导致无意黑枪
		IgnoreRescue = 3,
		
		// 是否在 其他(以上均不适用) 情况下忽略反伤.0=禁用.1=倒地时.2=黑白时.4=其他.数字相加
		IgnoreOther = 0,

		// 攻击者受到多少伤害(百分比 负数可以加血)
		AttackerDmage = 99,

		// 受害者受到多少伤害(百分比 负数可以加血)
		VictimDamage = 1,
		
		// 是否显示反伤提示.0=禁用.1=显示给攻击者.2=显示给受害者
		ShowMsg = 1,
	},

	ConfigVar = {},

	IsChargerCarry = {},
	IgnoreDamageTime = {},
	
	function IsReverseFF(flags, incap, dying)
	{
		if(incap)
			return (flags & 1);
		else if(dying)
			return (flags & 2);
		return (flags & 4)
	},
	
	function IsInSafeRoom(player)
	{
		if(player.IsInEndingSafeRoom())
			return true;
		
		local saferoom = Utils.GetSaferoomLocation();
		if(saferoom != null && Utils.CalculateDistance(saferoom, player.GetLocation()) < 800)
			return true;
		
		return false;
	},
	
	function CheckIgnoreRescue(player)
	{
		local index = player.GetIndex();
		if(index in ::FriendlyFire.IgnoreDamageTime)
		{
			if(::FriendlyFire.IgnoreDamageTime[index] <= Time())
				delete ::FriendlyFire.IgnoreDamageTime[index];
			else
				return true;
		}
		
		return false;
	},
};

function EasyLogic::OnTakeDamage::FriendlyFireUpdate(dmgTable)
{
	if(!::FriendlyFire.ConfigVar.Enable)
		return true;
	
	if(dmgTable["Victim"] == null || dmgTable["Attacker"] == null || dmgTable["DamageDone"] <= 0.0 ||
		typeof(dmgTable["Victim"]) != "VSLIB_PLAYER" || typeof(dmgTable["Attacker"]) != "VSLIB_PLAYER" ||
		!dmgTable["Victim"].IsPlayer() || !dmgTable["Attacker"].IsPlayer() ||
		dmgTable["Attacker"].GetTeam() != dmgTable["Victim"].GetTeam() ||
		dmgTable["Victim"].GetIndex() == dmgTable["Attacker"].GetIndex() ||
		dmgTable["Victim"].GetUserID() == dmgTable["Attacker"].GetUserID())
		return true;
	
	/*
	if(dmgTable["Victim"].IsSurvivor() && dmgTable["Attacker"].IsSurvivor() &&
		dmgTable["Attacker"].GetSurvivorCharacter() == dmgTable["Victim"].GetSurvivorCharacter())
		return true;
	*/
	
	local incap = (dmgTable["Victim"].IsIncapacitated() || dmgTable["Victim"].IsHangingFromLedge());
	local dying = (dmgTable["Victim"].GetNetPropBool("m_bIsOnThirdStrike") || dmgTable["Victim"].IsLastStrike());
	if(::FriendlyFire.IsReverseFF(::FriendlyFire.ConfigVar.IgnoreExplode, incap, dying) && (dmgTable["DamageType"] & DMG_BLAST))
		return true;
	else if(::FriendlyFire.IsReverseFF(::FriendlyFire.ConfigVar.IgnoreFire, incap, dying) && (dmgTable["DamageType"] & DMG_BURN))
		return true;
	else if(::FriendlyFire.IsReverseFF(::FriendlyFire.ConfigVar.IgnoreBOTs, incap, dying) && dmgTable["Victim"].IsBot())
		return true;
	else if(::FriendlyFire.IsReverseFF(::FriendlyFire.ConfigVar.IgnoreGrabbed, incap, dying) && dmgTable["Victim"].GetCurrentAttacker() != null)
		return true;
	else if(::FriendlyFire.IsReverseFF(::FriendlyFire.ConfigVar.IgnoreSafeRoom, incap, dying) && ::FriendlyFire.IsInSafeRoom(dmgTable["Victim"]))
		return true;
	else if(::FriendlyFire.ConfigVar.IgnoreRescue > 0 && ::FriendlyFire.CheckIgnoreRescue(dmgTable["Victim"]))
		return true;
	else if(::FriendlyFire.IsReverseFF(::FriendlyFire.ConfigVar.IgnoreOther, incap, dying))
		return true;
	
	local attackerDamage = dmgTable["DamageDone"] * ::FriendlyFire.ConfigVar.AttackerDmage / 100;
	local victimDamage = dmgTable["DamageDone"] * ::FriendlyFire.ConfigVar.VictimDamage / 100;
	
	/*
	printl("player " + dmgTable["Attacker"].GetName() + " attacker " + dmgTable["Victim"].GetName() + " weapon " + dmgTable["Weapon"] +
		"| damage = " + dmgTable["DamageDone"] + ", victim = " + victimDamage + ", attacker = " + attackerDamage);
	*/
	
	if(attackerDamage > 0)
		dmgTable["Attacker"].Damage(attackerDamage, dmgTable["DamageType"]);
	else if(attackerDamage < 0)
		dmgTable["Attacker"].IncreaseHealth(-attackerDamage);
	
	if(victimDamage >= 0)
		dmgTable["DamageDone"] = victimDamage;
	else if(victimDamage < 0)
	{
		dmgTable["DamageDone"] = 0;
		dmgTable["Victim"].IncreaseHealth(-victimDamage);
	}
	
	if((::FriendlyFire.ConfigVar.ShowMsg & 1) && attackerDamage > 0)
		dmgTable["Attacker"].PrintToCenter("friendly-fire damage reversed " + attackerDamage);
	else if((::FriendlyFire.ConfigVar.ShowMsg & 2) && attackerDamage > 0)
		dmgTable["Victim"].PrintToCenter("friendly-fire damage reversed " + attackerDamage + " from " + dmgTable["Attacker"]);
	
	return dmgTable["DamageDone"];
}

function Notifications::OnChargerCarryVictim::FriendlyFire_UpdateCharger(attacker, victim, params)
{
	if(!::FriendlyFire.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsPlayerEntityValid() || !attacker.IsPlayerEntityValid())
		return;
	
	::FriendlyFire.IsChargerCarry[victim.GetIndex()] <- attacker;
}

function Notifications::OnChargerCarryVictimEnd::FriendlyFire_UpdateCharger(attacker, victim, params)
{
	if(!::FriendlyFire.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsPlayerEntityValid() || !attacker.IsPlayerEntityValid())
		return;
	
	if(victim.GetIndex() in ::FriendlyFire.IsChargerCarry)
		delete ::FriendlyFire.IsChargerCarry[victim.GetIndex()];
	
	if(::FriendlyFire.ConfigVar.IgnoreRescue > 0)
		::FriendlyFire.IgnoreDamageTime[victim.GetIndex()] <- Time() + ::FriendlyFire.ConfigVar.IgnoreRescue;
}

function Notifications::OnChargerPummelEnd::FriendlyFire_UpdateCharger(attacker, victim, params)
{
	if(!::FriendlyFire.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsPlayerEntityValid() || !attacker.IsPlayerEntityValid())
		return;
	
	if(::FriendlyFire.ConfigVar.IgnoreRescue > 0)
		::FriendlyFire.IgnoreDamageTime[victim.GetIndex()] <- Time() + ::FriendlyFire.ConfigVar.IgnoreRescue;
}

function Notifications::OnSmokerTongueReleased::FriendlyFire_UpdateSmoker(attacker, victim, params)
{
	if(!::FriendlyFire.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsPlayerEntityValid() || !attacker.IsPlayerEntityValid())
		return;
	
	if(::FriendlyFire.ConfigVar.IgnoreRescue > 0)
		::FriendlyFire.IgnoreDamageTime[victim.GetIndex()] <- Time() + ::FriendlyFire.ConfigVar.IgnoreRescue;
}

function Notifications::OnJockeyRideEnd::FriendlyFire_UpdateJockey(attacker, victim, params)
{
	if(!::FriendlyFire.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsPlayerEntityValid() || !attacker.IsPlayerEntityValid())
		return;
	
	if(::FriendlyFire.ConfigVar.IgnoreRescue > 0)
		::FriendlyFire.IgnoreDamageTime[victim.GetIndex()] <- Time() + ::FriendlyFire.ConfigVar.IgnoreRescue;
}

function Notifications::OnHunterPounceStopped::FriendlyFire_UpdateHunter(attacker, victim, params)
{
	if(!::FriendlyFire.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsPlayerEntityValid() || !attacker.IsPlayerEntityValid())
		return;
	
	if(::FriendlyFire.ConfigVar.IgnoreRescue > 0)
		::FriendlyFire.IgnoreDamageTime[victim.GetIndex()] <- Time() + ::FriendlyFire.ConfigVar.IgnoreRescue;
}

function Notifications::OnHunterReleasedVictim::FriendlyFire_UpdateHunter(attacker, victim, params)
{
	if(!::FriendlyFire.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsPlayerEntityValid() || !attacker.IsPlayerEntityValid())
		return;
	
	if(::FriendlyFire.ConfigVar.IgnoreRescue > 0)
		::FriendlyFire.IgnoreDamageTime[victim.GetIndex()] <- Time() + ::FriendlyFire.ConfigVar.IgnoreRescue;
}

function CommandTriggersEx::ff(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	local arg1 = GetArgument(1);
	if(!arg1)
	{
		::FriendlyFire.ConfigVar.Enable = !::FriendlyFire.ConfigVar.Enable;
		printl("reverse ff " + ::FriendlyFire.ConfigVar.Enable);
		return;
	}
	
	local arg2 = GetArgument(2);
	if(!arg2)
	{
		local val = arg1.tofloat();
		if(val < 1.0)
			val *= 100;
		
		::FriendlyFire.ConfigVar.AttackerDmage = 100 - val;
		::FriendlyFire.ConfigVar.VictimDamage = 100 - ::FriendlyFire.ConfigVar.AttackerDmage;
		printl("reverse ff: attacker " + ::FriendlyFire.ConfigVar.AttackerDmage + "%, victim " +
			::FriendlyFire.ConfigVar.VictimDamage + "%");
		
		// ::FriendlyFire.ConfigVar.Enable <- FileIO.GetConfigByTable(PLUGIN_NAME, "Enable", true);
		::FriendlyFire.ConfigVar.Enable = true;
		return;
	}
	
	local v1 = arg1.tofloat();
	local v2 = arg2.tofloat();
	
	if(v1 < 1.0)
		v1 *= 100;
	if(v2 < 1.0)
		v2 *= 100;
	
	::FriendlyFire.ConfigVar.AttackerDmage = v1;
	::FriendlyFire.ConfigVar.VictimDamage = v2;
	
	printl("reverse ff: attacker " + ::FriendlyFire.ConfigVar.AttackerDmage + "%, victim " +
		::FriendlyFire.ConfigVar.VictimDamage + "%");
	
	// ::FriendlyFire.ConfigVar.Enable <- FileIO.GetConfigByTable(PLUGIN_NAME, "Enable", true);
	::FriendlyFire.ConfigVar.Enable = true;
}


::FriendlyFire.PLUGIN_NAME <- PLUGIN_NAME;
::FriendlyFire.ConfigVar = ::FriendlyFire.ConfigVarDef;

function Notifications::OnRoundStart::FriendlyFire_LoadConfig()
{
	RestoreTable(::FriendlyFire.PLUGIN_NAME, ::FriendlyFire.ConfigVar);
	if(::FriendlyFire.ConfigVar == null || ::FriendlyFire.ConfigVar.len() <= 0)
		::FriendlyFire.ConfigVar = FileIO.GetConfigOfFile(::FriendlyFire.PLUGIN_NAME, ::FriendlyFire.ConfigVarDef);

	// printl("[plugins] " + ::FriendlyFire.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::FriendlyFire_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::FriendlyFire.PLUGIN_NAME, ::FriendlyFire.ConfigVar);

	// printl("[plugins] " + ::FriendlyFire.PLUGIN_NAME + " saving...");
}
