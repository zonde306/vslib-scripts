::DamageExtra <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 7,
		
		// 基础暴击率
		BaseChance = 5,
		
		// 最后一颗子弹暴击率
		LastBulletChance = 95,
		
		// 第一枪暴击率
		FirstBulletChance = 75,
		
		// 第一枪触发闲置时间
		FirstBulletDelay = 10.0,
		
		// 手枪暴击率加成
		PistolChance = 5,
		
		// 冲锋枪暴击率加成
		SmgChance = 5,
		
		// 单喷暴击率加成
		SingleChance = 5,
		
		// 连喷暴击率加成
		AutoChance = 5,
		
		// 步枪暴击率加成
		RifleChance = 5,
		
		// 狙击枪暴击率加成
		SniperChance = 5,
		
		// 机关枪暴击率加成
		MachineChance = 5,
		
		// 榴弹发射器暴击率加成
		GrenadeChance = 5,
		
		// T1 武器暴击率加成
		T1Chance = 5,
		
		// T2 武器暴击率加成
		T2Chance = 5,
		
		// T3 武器暴击率加成
		T3Chance = 5,
		
		// 允许被暴击的目标
		// 1=特感.2=普感.4=Witch.8=队友
		ExtraAllow = 7,
		
		// 造成暴击可以震退的目标
		// 1=舌头.2=胖子.4=猎人.8=口水.16=猴子.32=牛.128=克
		FendAllow = 63,
		
		// 造成暴击触发震退的几率
		FendChance = 25,
		
		// 暴击额外造成的最大伤害
		MaxDamage = 250,
		
		// 暴击额外造成的最小伤害
		MinDamage = 50
	},
	
	ConfigVar = {},
	HasLastFired = {},
	HasFirstFired = {},
	HasWeaponFired = {},
	WeaponIdleTime = {},
	LastWeaponIndex = {},
	
	function ClearTable(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead())
			return false;
		
		local cleared = false;
		local index = player.GetIndex();
		if(index in ::DamageExtra.HasLastFired)
		{
			delete ::DamageExtra.HasLastFired[index];
			cleared = true;
		}
		
		if(index in ::DamageExtra.HasWeaponFired)
		{
			delete ::DamageExtra.HasWeaponFired[index];
			cleared = true;
		}
		
		if(index in ::DamageExtra.HasFirstFired)
		{
			delete ::DamageExtra.HasFirstFired[index];
			cleared = true;
		}
		
		if(index in ::DamageExtra.WeaponIdleTime)
		{
			delete ::DamageExtra.WeaponIdleTime[index];
			cleared = true;
		}
		
		if(index in ::DamageExtra.LastWeaponIndex)
		{
			delete ::DamageExtra.LastWeaponIndex[index];
			cleared = true;
		}
		
		return cleared;
	},
	
	function GetChance(player, weapon)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead())
			return 0;
		
		local index = player.GetIndex();
		local chance = ::DamageExtra.ConfigVar.BaseChance;
		if(index in ::DamageExtra.HasLastFired)
			chance += ::DamageExtra.ConfigVar.LastBulletChance;
		if(index in ::DamageExtra.HasFirstFired)
			chance += ::DamageExtra.ConfigVar.FirstBulletChance;
		
		switch(weapon)
		{
			case "weapon_pistol":
				chance += ::DamageExtra.ConfigVar.T1Chance;
			case "weapon_pistol_magnum":
				chance += ::DamageExtra.ConfigVar.PistolChance;
				break;
			
			case "weapon_smg":
			case "weapon_smg_mp5":
			case "weapon_smg_silenced":
				chance += ::DamageExtra.ConfigVar.SmgChance;
				chance += ::DamageExtra.ConfigVar.T1Chance;
				break;
			
			case "weapon_pumpshotgun":
			case "weapon_shotgun_chrome":
				chance += ::DamageExtra.ConfigVar.SingleChance;
				chance += ::DamageExtra.ConfigVar.T1Chance;
				break;
			
			case "weapon_autoshotgun":
			case "weapon_shotgun_spas":
				chance += ::DamageExtra.ConfigVar.SingleChance;
				chance += ::DamageExtra.ConfigVar.T2Chance;
				break;
			
			case "weapon_rifle":
			case "weapon_rifle_ak47":
			case "weapon_rifle_sg552":
			case "weapon_rifle_desert":
				chance += ::DamageExtra.ConfigVar.RifleChance;
				chance += ::DamageExtra.ConfigVar.T2Chance;
				break;
			
			case "weapon_sniper_awp":
			case "weapon_sniper_scout":
			case "weapon_sniper_military":
			case "weapon_hunting_rifle":
				chance += ::DamageExtra.ConfigVar.SniperChance;
				chance += ::DamageExtra.ConfigVar.T2Chance;
				break;
			
			case "weapon_rifle_m60":
				chance += ::DamageExtra.ConfigVar.MachineChance;
				chance += ::DamageExtra.ConfigVar.T3Chance;
				break;
			
			case "weapon_grenade_launcher":
				chance += ::DamageExtra.ConfigVar.MachineChance;
				chance += ::DamageExtra.ConfigVar.T3Chance;
				break;
		}
		
		return chance;
	},
	
	function Timer_WepaonIdleThink(params)
	{
		if(!::DamageExtra.ConfigVar.Enable)
		{
			if(::DamageExtra.HasLastFired.len() > 0)
			{
				::DamageExtra.HasLastFired = {};
				::DamageExtra.HasFirstFired = {};
				::DamageExtra.HasWeaponFired = {};
				::DamageExtra.WeaponIdleTime = {};
				::DamageExtra.LastWeaponIndex = {};
			}
			
			return;
		}
		
		foreach(player in Players.AliveSurvivors())
		{
			local index = player.GetIndex();
			local weapon = player.GetActiveWeapon();
			if(weapon == null || !weapon.IsEntityValid())
			{
				if(index in ::DamageExtra.HasLastFired)
					::DamageExtra.ClearTable(player);
				
				continue;
			}
			
			local time = Time();
			if(weapon.GetNetPropBool("m_bInReload") ||
				weapon.GetNetPropFloat("m_flNextPrimaryAttack") > time ||
				// weapon.GetNetPropFloat("m_flNextSecondaryAttack") > time ||
				player.GetNetPropFloat("m_flNextAttack") > time)
				continue;
			
			local weaponIndex = weapon.GetIndex();
			if(!(index in ::DamageExtra.LastWeaponIndex) || ::DamageExtra.LastWeaponIndex[index] != weaponIndex)
			{
				::DamageExtra.LastWeaponIndex[index] <- weaponIndex;
				::DamageExtra.WeaponIdleTime[index] <- time;
			}
		}
	}
};

function Notifications::OnRoundBegin::DamageExtra_WeaponThink(params)
{
	Timers.AddTimerByName("timer_weaponidlecheck", 0.1, true, ::DamageExtra.Timer_WepaonIdleThink);
}

function Notifications::FirstSurvLeftStartArea::DamageExtra_WeaponThink(player, params)
{
	Timers.AddTimerByName("timer_weaponidlecheck", 0.1, true, ::DamageExtra.Timer_WepaonIdleThink);
}

function EasyLogic::OnTakeDamage::DamageExtra_OnTakeDamage(dmgTable)
{
	if(!::DamageExtra.ConfigVar.Enable)
		return true;
	
	if(dmgTable["Victim"] == null || dmgTable["Attacker"] == null || dmgTable["DamageDone"] <= 0.0 ||
		!dmgTable["Attacker"].IsSurvivor() || dmgTable["Weapon"] == null || !dmgTable["Weapon"].IsEntityValid())
		return true;
	
	local index = dmgTable["Attacker"].GetIndex();
	if(!(index in ::DamageExtra.HasWeaponFired) ||
		dmgTable["Weapon"].GetClassname() != ::DamageExtra.HasWeaponFired[index])
		return true;
	
	local type = dmgTable["Victim"].GetType();
	if(type == null)
		return true;
	
	if(!(::DamageExtra.ConfigVar.ExtraAllow & 8) && type == Z_SURVIVOR)
		return true;
	
	if(!(::DamageExtra.ConfigVar.ExtraAllow & 1) && type >= Z_SMOKER && type <= Z_CHARGER)
		return;
	
	if(!(::DamageExtra.ConfigVar.ExtraAllow & 2) && type == Z_COMMON)
		return;
	
	if(!(::DamageExtra.ConfigVar.ExtraAllow & 4) && type == Z_WITCH)
		return;
	
	local chance = ::DamageExtra.GetChance(dmgTable["Attacker"], dmgTable["Weapon"].GetClassname());
	::DamageExtra.ClearTable(dmgTable["Attacker"]);
	
	srand(Time() + dmgTable["DamageDone"]);
	if(chance >= 100 || Utils.GetRandNumber(1, 100) <= chance)
	{
		dmgTable["Attacker"].PlaySoundEx("ui/littlereward.wav");
		dmgTable["DamageDone"] += Utils.GetRandNumber(::DamageExtra.ConfigVar.MinDamage,
			::DamageExtra.ConfigVar.MaxDamage);
		
		if(dmgTable["Victim"].IsPlayer() &&
			(::DamageExtra.ConfigVar.FendAllow & (1 << (type - 1))) &&
			Utils.GetRandNumber(1, 100) <= ::DamageExtra.ConfigVar.FendChance)
			dmgTable["Victim"].StaggerAwayFromEntity(dmgTable["Attacker"]);
		
		printl("player " + dmgTable["Attacker"] + " extra damage to " + dmgTable["Victim"].GetName());
		return dmgTable["DamageDone"];
	}
	
	return true;
}

function Notifications::OnWeaponFire::DamageExtra_OnWeaponFire(player, weaponName, params)
{
	if(!::DamageExtra.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsSurvivor() || Utils.IsValidFireWeapon(weaponName))
		return;
	
	local weapon = player.GetActiveWeapon();
	if(weapon == null || !weapon.IsEntityValid())
		return;
	
	local time = Time();
	local index = player.GetIndex();
	local weaponIndex = weapon.GetIndex();
	
	if(weapon.GetClassname() != weaponName)
	{
		::DamageExtra.LastWeaponIndex[index] <- weaponIndex;
		::DamageExtra.WeaponIdleTime[index] <- time;
		return;
	}
	
	::DamageExtra.HasWeaponFired[index] <- weaponName;
	
	if(weapon.GetClip() == 1 && weaponName != "weapon_grenade_launcher")
	{
		::DamageExtra.HasLastFired[index] <- weaponName;
		printl("player " + player.GetName() + " has last fired");
	}
	
	if(index in ::DamageExtra.WeaponIdleTime && index in ::DamageExtra.LastWeaponIndex &&
		::DamageExtra.LastWeaponIndex[index] == weaponIndex)
	{
		// if(time - weapon.GetNetPropFloat("m_flTimeWeaponIdle") >= ::DamageExtra.ConfigVar.FirstBulletDelay)
		if(time - ::DamageExtra.WeaponIdleTime[index] >= ::DamageExtra.ConfigVar.FirstBulletDelay)
		{
			::DamageExtra.HasFirstFired[index] <- weaponName;
			printl("player " + player.GetName() + " has first fired");
		}
	}
	
	::DamageExtra.LastWeaponIndex[index] <- weaponIndex;
	::DamageExtra.WeaponIdleTime[index] <- time;
}

::DamageExtra.PLUGIN_NAME <- PLUGIN_NAME;
::DamageExtra.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::DamageExtra.ConfigVarDef);

function Notifications::OnRoundStart::DamageExtra_LoadConfig()
{
	RestoreTable(::DamageExtra.PLUGIN_NAME, ::DamageExtra.ConfigVar);
	if(::DamageExtra.ConfigVar == null || ::DamageExtra.ConfigVar.len() <= 0)
		::DamageExtra.ConfigVar = FileIO.GetConfigOfFile(::DamageExtra.PLUGIN_NAME, ::DamageExtra.ConfigVarDef);

	// printl("[plugins] " + ::DamageExtra.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::DamageExtra_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::DamageExtra.PLUGIN_NAME, ::DamageExtra.ConfigVar);

	// printl("[plugins] " + ::DamageExtra.PLUGIN_NAME + " saving...");
}
