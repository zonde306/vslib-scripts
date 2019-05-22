::FriendlyFire <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = false,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,

		// 是否忽略火焰伤害
		IgnoreFire = true,

		// 是否忽略爆炸伤害
		IgnoreExplode = true,

		// 是否在 倒地/挂边 时忽略反伤
		IgnoreIncap = true,

		// 是否在被控时忽略反伤
		IgnoreGrabbed = true,

		// 在玩家被从特感手里救出时忽略多少秒的反伤.0=禁用
		// 用于防止刚被救出没反应过来导致无意黑枪
		IgnoreRescue = 3,

		// 攻击者受到多少倍的伤害(百分比 负数可以加血)
		AttackerDmage = 100,

		// 受害者受到多少倍的伤害(百分比 负数可以加血)
		VictimDamage = 0
	},

	ConfigVar = {},

	IsChargerCarry = {},
	IgnoreDamageTime = {},
	
	// 修复伤害表不正确
	function FixDamageTable(dmgTable)
	{
		local damageTable =
		{
			Attacker = null,
			Victim = null,
			DamageDone = 0,
			Damage = 0,
			DamageType = 0,
			Location = Vector(0, 0, 0),
			Weapon = ""
		};
		
		if("Attacker" in dmgTable && dmgTable["Attacker"] != null)
			damageTable["Attacker"] <- Utils.GetEntityOrPlayer(dmgTable["Attacker"]);
		if("Victim" in dmgTable && dmgTable["Victim"] != null)
			damageTable["Victim"] <- Utils.GetEntityOrPlayer(dmgTable["Victim"]);
		if("DamageDone" in dmgTable && (typeof(dmgTable["DamageDone"]) == "integer" ||
			typeof(dmgTable["DamageDone"]) == "float"))
		{
			damageTable["DamageDone"] <- dmgTable["DamageDone"].tointeger();
			damageTable["Damage"] <- dmgTable["DamageDone"].tointeger();
		}
		if("DamageType" in dmgTable && typeof(dmgTable["DamageType"]) == "integer")
			damageTable["DamageType"] <- dmgTable["DamageType"];
		if("Location" in dmgTable)
			damageTable["Location"] <- dmgTable["Location"];
		if("Weapon" in dmgTable && typeof(dmgTable["Weapon"]) == "string")
		{
			local re = regexp("weapon_[a-zA-Z0-9_]+");
			local result = re.search(dmgTable["Weapon"]);
			if(result != null)
				damageTable["Weapon"] <- dmgTable["Weapon"].slice(result.begin, result.end);
		}
		
		return damageTable;
	}
};

function EasyLogic::OnTakeDamage::FriendlyFireUpdate(dmgTable)
{
	if(!::FriendlyFire.ConfigVar.Enable)
		return true;
	
	if(dmgTable["Victim"] == null || dmgTable["Attacker"] == null || dmgTable["DamageDone"] <= 0.0 ||
		typeof(dmgTable["Victim"]) != "VSLIB_PLAYER" || typeof(dmgTable["Attacker"]) != "VSLIB_PLAYER" ||
		!dmgTable["Victim"].IsPlayer() || !dmgTable["Attacker"].IsPlayer() ||
		dmgTable["Attacker"].GetTeam() != dmgTable["Victim"].GetTeam() ||
		dmgTable["Victim"].GetIndex() == dmgTable["Attacker"].GetIndex())
		return true;
	
	if(dmgTable["Victim"].IsSurvivor() && dmgTable["Attacker"].IsSurvivor() &&
		dmgTable["Attacker"].GetSurvivorCharacter() == dmgTable["Victim"].GetSurvivorCharacter())
		return true;
	
	local index = dmgTable["Victim"].GetIndex();
	if(typeof(dmgTable["Weapon"]) == "VSLIB_ENTITY")
	{
		if((::FriendlyFire.ConfigVar.IgnoreExplode && (dmgTable["DamageType"] & DMG_BLAST)) ||
			(::FriendlyFire.ConfigVar.IgnoreFire && (dmgTable["DamageType"] & DMG_BURN) &&
			dmgTable["Weapon"].GetClassname().find("launcher") == null))
			return true;
		
		if(index in ::FriendlyFire.IsChargerCarry)
		{
			if(::FriendlyFire.IsChargerCarry[index] != null &&
				(dmgTable["DamageType"] & DMG_BULLET) &&
				::FriendlyFire.IsChargerCarry[index].IsPlayerEntityValid() &&
				::FriendlyFire.IsChargerCarry[index].GetType() == Z_CHARGER)
			{
				// 生还者被 charger 抓住冲锋时攻击 charger 伤害是计算到队友身上的
				// 在这里将伤害转移给 charger
				::FriendlyFire.IsChargerCarry[index].Damage(dmgTable["DamageDone"], dmgTable["DamageType"], dmgTable["Attacker"]);
				return false;
			}
			else
				delete ::FriendlyFire.IsChargerCarry[index];
		}
	}
	
	if(::FriendlyFire.ConfigVar.IgnoreIncap && (dmgTable["Victim"].IsIncapacitated() || dmgTable["Victim"].IsHangingFromLedge()))
		return true;
	
	if(::FriendlyFire.ConfigVar.IgnoreGrabbed && (dmgTable["Victim"].IsHangingFromTongue() ||
		dmgTable["Victim"].IsBeingJockeyed() || dmgTable["Victim"].IsPounceVictim() ||
		dmgTable["Victim"].IsTongueVictim() || dmgTable["Victim"].IsPummelVictim()))
		return true;
	
	if(::FriendlyFire.ConfigVar.IgnoreRescue > 0 && index in ::FriendlyFire.IgnoreDamageTime)
	{
		if(::FriendlyFire.IgnoreDamageTime[index] <= Time())
			delete ::FriendlyFire.IgnoreDamageTime[index];
		
		return true;
	}
	
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
		printl("firendlyfire back " + ::FriendlyFire.ConfigVar.Enable);
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
		printl("firendlyfire back: attacker " + ::FriendlyFire.ConfigVar.AttackerDmage + "%, victim " +
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
	
	printl("firendlyfire back: attacker " + ::FriendlyFire.ConfigVar.AttackerDmage + "%, victim " +
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
