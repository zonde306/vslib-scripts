::DamageLimit <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,

		// 单次受到普感伤害上限
		CommonInfected = 10,

		// 单次受到特感伤害上限
		SpecialInfected = 20,

		// 普感伤害最小间隔
		CommonInterval = 1.0,

		// 特感伤害间隔
		SpecialInterval = 0.15,

		// 被控是否忽略普感伤害
		CommonIgnore = false,
		
		// 被控否忽略其他特感伤害
		SpecialIgnore = false,

		// 只有在生还者血量不大于多少时启用强制特感释放
		IncapRelease = 75,

		// 使用临时血量代替长期血量受伤时，长期血量最少需要减少多少.-1=禁用
		RealHealthValue = -1,

		// 倒地后血量自然流失数量
		IncapLostAmount = 2,

		// 需要在倒地后血量少于多少时才更改流失速度
		IncapLostHealth = 125,

		// 被递药保护
		// 0=禁用.小于0为无敌.大于0为伤害转移
		GivePillsDuration = 2.0,
		
		// 救人防止被打断
		AntiReviveBlock = true
	},

	ConfigVar = {},

	NextAllowSpecial = {},
	NextAllowCommon = {},
	
	PillsGiveVictim = {},
	PillsGiveNextTime = {},
	
	// 是否倒地或挂边
	function IsIncapacitated(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead())
			return false;
		
		return (player.IsIncapacitated() || player.IsHangingFromLedge());
	},
	
	// 是否被控
	function IsGrabbedBySpecial(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead())
			return false;
		
		return (player.IsHangingFromTongue() || player.IsBeingJockeyed() || player.IsPounceVictim() ||
			player.IsTongueVictim() || player.IsCarryVictim() || player.IsPummelVictim());
	}
};

function Notifications::OnAwarded::DamageLimit(player, subject, award, params)
{
	if(!::DamageLimit.ConfigVar.Enable || ::DamageLimit.ConfigVar.GivePillsDuration == 0.0)
		return;
	
	if(subject == null || player == null || !subject.IsPlayerEntityValid() || !player.IsPlayerEntityValid() ||
		!player.IsSurvivor() || !subject.IsSurvivor() || subject.IsBot())
		return;
	
	if(award != 68 && award != 69)
		return;
	
	local index = subject.GetIndex();
	
	if(::DamageLimit.ConfigVar.GivePillsDuration > 0.0)
		::DamageLimit.PillsGiveVictim[index] <- player;
	else if(index in ::DamageLimit.PillsGiveVictim)
		delete ::DamageLimit.PillsGiveVictim[index];
	
	::DamageLimit.PillsGiveNextTime[index] <- Time() + fabs(::DamageLimit.ConfigVar.GivePillsDuration);
}

function EasyLogic::OnTakeDamage::DamageLimit(dmgTable)
{
	if(!::DamageLimit.ConfigVar.Enable)
		return true;
	
	if(dmgTable["Victim"] == null || dmgTable["Attacker"] == null || dmgTable["DamageDone"] <= 0.0 ||
		!dmgTable["Victim"].IsSurvivor() || dmgTable["Attacker"].GetTeam() == dmgTable["Victim"].GetTeam())
		return true;
	
	local time = Time();
	local index = dmgTable["Victim"].GetIndex();
	local type = dmgTable["Attacker"].GetType();
	local health = dmgTable["Victim"].GetHealth();
	
	switch(type)
	{
		case Z_COMMON:
		case Z_INFECTED:
		{
			if(index in ::DamageLimit.NextAllowCommon)
			{
				if(::DamageLimit.NextAllowCommon[index] > time)
					return false;
				
				delete ::DamageLimit.NextAllowCommon[index];
			}
			
			// 被控忽略普感伤害
			if(::DamageLimit.ConfigVar.CommonIgnore && ::DamageLimit.IsGrabbedBySpecial(dmgTable["Victim"]))
				return false;
			
			// 普感伤害上限
			if(dmgTable["DamageDone"] > ::DamageLimit.ConfigVar.CommonInfected)
				dmgTable["DamageDone"] = ::DamageLimit.ConfigVar.CommonInfected;
			
			// 被递药保护，防止普感伤害
			if(index in ::DamageLimit.PillsGiveNextTime)
			{
				if(::DamageLimit.PillsGiveNextTime[index] > time)
				{
					if(index in ::DamageLimit.PillsGiveVictim)
					{
						if(::DamageLimit.PillsGiveVictim[index] != null &&
							::DamageLimit.PillsGiveVictim[index].IsPlayerEntityValid() &&
							::DamageLimit.PillsGiveVictim[index].IsSurvivor() &&
							::DamageLimit.PillsGiveVictim[index].IsAlive())
						{
							// 伤害转移
							::DamageLimit.PillsGiveVictim[index].Damage(dmgTable["DamageDone"],
								dmgTable["DamageType"], dmgTable["Attacker"]);
						}
						else
							delete ::DamageLimit.PillsGiveVictim[index];
					}
					
					// 防止伤害
					return false;
				}
				
				if(index in ::DamageLimit.PillsGiveVictim)
					delete ::DamageLimit.PillsGiveVictim[index];
				
				delete ::DamageLimit.PillsGiveNextTime[index];
			}
			
			// 普感伤害间隔
			::DamageLimit.NextAllowCommon[index] <- time + ::DamageLimit.ConfigVar.CommonInterval;
			
			// 优化游戏体验
			if(health <= 25)
				::DamageLimit.NextAllowCommon[index] += ::DamageLimit.ConfigVar.CommonInterval;
			
			break;
		}
		case Z_SMOKER:
		case Z_HUNTER:
		case Z_JOCKEY:
		case Z_CHARGER:
		{
			// 释放控制的生还者
			if(::DamageLimit.ConfigVar.IncapRelease > 0 && health <= ::DamageLimit.ConfigVar.IncapRelease &&
				::DamageLimit.IsIncapacitated(dmgTable["Victim"]) &&
				::DamageLimit.IsGrabbedBySpecial(dmgTable["Victim"]))
			{
				dmgTable["Attacker"].StaggerAwayFromEntity(dmgTable["Victim"]);
				if(!dmgTable["Attacker"].IsBot())
					dmgTable["Attacker"].PlaySoundEx("level/puck_fail.wav");
			}
		}
		case Z_BOOMER:
		case Z_SPITTER:
		{
			if(index in ::DamageLimit.NextAllowSpecial)
			{
				if(::DamageLimit.NextAllowSpecial[index] > time)
					return false;
				
				delete ::DamageLimit.NextAllowSpecial[index];
			}
			
			// 被控忽其他特感伤害
			if(::DamageLimit.ConfigVar.SpecialIgnore && ::DamageLimit.IsGrabbedBySpecial(dmgTable["Victim"]) &&
				dmgTable["Victim"].GetCurrentAttacker().GetIndex() != dmgTable["Attacker"].GetIndex())
				return false;
			
			// 特感伤害上限
			if(dmgTable["DamageDone"] > ::DamageLimit.ConfigVar.SpecialInfected)
				dmgTable["DamageDone"] = ::DamageLimit.ConfigVar.SpecialInfected;
			
			// 被递药保护，防止特感伤害
			if(index in ::DamageLimit.PillsGiveNextTime)
			{
				if(::DamageLimit.PillsGiveNextTime[index] > time)
				{
					if(index in ::DamageLimit.PillsGiveVictim)
					{
						if(::DamageLimit.PillsGiveVictim[index] != null &&
							::DamageLimit.PillsGiveVictim[index].IsPlayerEntityValid() &&
							::DamageLimit.PillsGiveVictim[index].IsSurvivor() &&
							::DamageLimit.PillsGiveVictim[index].IsAlive())
						{
							// 伤害转移
							::DamageLimit.PillsGiveVictim[index].Damage(dmgTable["DamageDone"],
								dmgTable["DamageType"], dmgTable["Attacker"]);
						}
						else
							delete ::DamageLimit.PillsGiveVictim[index];
					}
					
					// 防止伤害
					return false;
				}
				
				if(index in ::DamageLimit.PillsGiveVictim)
					delete ::DamageLimit.PillsGiveVictim[index];
				
				delete ::DamageLimit.PillsGiveNextTime[index];
			}
			
			// 特感伤害间隔
			::DamageLimit.NextAllowSpecial[index] <- time + ::DamageLimit.ConfigVar.SpecialInterval;
			
			// 优化游戏体验
			if(dmgTable["Victim"].GetHealth() <= 25)
				::DamageLimit.NextAllowSpecial[index] += ::DamageLimit.ConfigVar.SpecialInterval;
			
			break;
		}
		case Z_WITCH:
		// case Z_TANK:
		{
			// 被递药保护，防止被秒
			if(index in ::DamageLimit.PillsGiveNextTime)
			{
				if(::DamageLimit.PillsGiveNextTime[index] > time)
				{
					if(index in ::DamageLimit.PillsGiveVictim)
					{
						if(::DamageLimit.PillsGiveVictim[index] != null &&
							::DamageLimit.PillsGiveVictim[index].IsPlayerEntityValid() &&
							::DamageLimit.PillsGiveVictim[index].IsSurvivor() &&
							::DamageLimit.PillsGiveVictim[index].IsAlive())
						{
							// 伤害转移
							::DamageLimit.PillsGiveVictim[index].Damage(dmgTable["DamageDone"],
								dmgTable["DamageType"], dmgTable["Attacker"]);
						}
						else
							delete ::DamageLimit.PillsGiveVictim[index];
					}
					
					// 防止伤害
					return false;
				}
				
				if(index in ::DamageLimit.PillsGiveVictim)
					delete ::DamageLimit.PillsGiveVictim[index];
				
				delete ::DamageLimit.PillsGiveNextTime[index];
			}
		}
	}
	
	// 机器人玩家伤害减少
	/*
	if(dmgTable["Victim"].IsBot() && type != null && type != Z_TANK && type != Z_WITCH)
	{
		if(Convars.GetStr("z_difficulty").tolower() == "impossible")
			dmgTable["DamageDone"] *= 0.5;
		else if(Convars.GetStr("z_difficulty").tolower() == "hard")
			dmgTable["DamageDone"] *= 0.75;
	}
	*/
	
	// 倒地血量流失修改
	if(::DamageLimit.ConfigVar.IncapLostHealth > 0 && ::DamageLimit.ConfigVar.IncapLostAmount > -1 &&
		health <= ::DamageLimit.ConfigVar.IncapLostHealth && type == null && !(dmgTable["DamageType"] & DMG_FALL) &&
		::DamageLimit.IsIncapacitated(dmgTable["Victim"]) && dmgTable["Attacker"].GetClassname() == "worldspawn")
	{
		// if(dmgTable["DamageDone"] < Convars.GetFloat("survivor_incap_hopeless_decay_rate") + 1)
		
		// 或许需要检查绝望状态血量流失
		if(fabs(dmgTable["DamageDone"] - Convars.GetFloat("survivor_incap_decay_rate")) < 1)
			dmgTable["DamageDone"] = ::DamageLimit.ConfigVar.IncapLostAmount;
	}
	
	// 受到伤害时优先使用临时血量代替伤害
	if(::DamageLimit.ConfigVar.RealHealthValue > -1)
	{
		local buffer = dmgTable["Victim"].GetHealthBuffer();
		if(buffer >= dmgTable["DamageDone"])
		{
			buffer -= dmgTable["DamageDone"] - ::DamageLimit.ConfigVar.RealHealthValue;
			dmgTable["DamageDone"] = ::DamageLimit.ConfigVar.RealHealthValue;
		}
		else
		{
			dmgTable["DamageDone"] -= buffer;
			buffer = 0.0;
		}
		
		dmgTable["Victim"].SetHealthBuffer(buffer);
	}
	
	if(::DamageLimit.ConfigVar.AntiReviveBlock)
	{
		dmgTable["DamageType"] = DMG_BULLET;
		return {"DamageDone" : dmgTable["DamageDone"], "DamageType" : DMG_BULLET};
	}
	
	return dmgTable["DamageDone"];
}

function CommandTriggersEx::dls(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	local interval = GetArgument(1);
	if(interval == null || interval == "")
	{
		if(::DamageLimit.ConfigVar.SpecialInfected >= 20)
			::DamageLimit.ConfigVar.SpecialInfected = FileIO.GetConfigByTable(PLUGIN_NAME, "SpecialInfected", 10);
		else
			::DamageLimit.ConfigVar.SpecialInfected = FileIO.GetConfigByTable(PLUGIN_NAME, "SpecialInfected", 20);
		
		printl("special damage limit setting " + ::DamageLimit.ConfigVar.SpecialInfected);
		return;
	}
	
	::DamageLimit.ConfigVar.SpecialInterval = interval.tofloat();
	printl("special damage interval setting " + ::DamageLimit.ConfigVar.SpecialInterval);
}

function CommandTriggersEx::dlc(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	local interval = GetArgument(1);
	if(interval == null || interval == "")
	{
		if(::DamageLimit.ConfigVar.CommonInfected >= 20)
			::DamageLimit.ConfigVar.CommonInfected = FileIO.GetConfigByTable(PLUGIN_NAME, "CommonInfected", 10);
		else
			::DamageLimit.ConfigVar.CommonInfected = FileIO.GetConfigByTable(PLUGIN_NAME, "CommonInfected", 20);
		
		printl("special damage limit setting " + ::DamageLimit.ConfigVar.CommonInfected);
		return;
	}
	
	::DamageLimit.ConfigVar.CommonInterval = interval.tofloat();
	printl("special damage interval setting " + ::DamageLimit.ConfigVar.CommonInterval);
}


::DamageLimit.PLUGIN_NAME <- PLUGIN_NAME;
::DamageLimit.ConfigVar = ::DamageLimit.ConfigVarDef;

function Notifications::OnRoundStart::DamageLimit_LoadConfig()
{
	RestoreTable(::DamageLimit.PLUGIN_NAME, ::DamageLimit.ConfigVar);
	if(::DamageLimit.ConfigVar == null || ::DamageLimit.ConfigVar.len() <= 0)
		::DamageLimit.ConfigVar = FileIO.GetConfigOfFile(::DamageLimit.PLUGIN_NAME, ::DamageLimit.ConfigVarDef);

	// printl("[plugins] " + ::DamageLimit.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::DamageLimit_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::DamageLimit.PLUGIN_NAME, ::DamageLimit.ConfigVar);

	// printl("[plugins] " + ::DamageLimit.PLUGIN_NAME + " saving...");
}
