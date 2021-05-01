::SkillDetect <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
		
		// 隐藏溢出伤害
		HideFakeDamage = true,
		
		// 被拉自救最小伤害
		MinSelfCleanDamage = 200,
		
		// 连跳第一下最低速度
		MinBHopFirstSpeed = 150,
		
		// 连跳最小速度
		MinBHopKeepSpeed = 300,
		
		// 连跳最小次数
		MinBHopStreak = 3,
		
		// 秒救最大时间
		MaxInsteaClear = 0.75,
		
		// 高扑最小高度
		MinHighPounceHeight = 400,
		
		// 空投最小高度
		MinHighRideHeight = 300,
		
		// 是否提示秒飞扑 Hunter/Jockey
		ReportSkeet = true,
		
		// 是否提示打死飞扑 Hunter/Jockey
		ReportHurtSkeet = true,
		
		// 是否提示近战秒牛
		ReportLevel = true,
		
		// 是否提示近战砍死牛
		ReportHurtLevel = true,
		
		// 是否提示秒妹
		ReportCrown = true,
		
		// 是否提示引秒
		ReportDrawCrown = true,
		
		// 是否提示砍舌
		ReportTongueCut = true,
		
		// 是否提示被拉自救
		ReportSelfClear = true,
		
		// 是否提示近战爆石头
		ReportRockSkeet = true,
		
		// 是否提示推停飞扑 Hunter/Jockey
		ReportDeadstop = false,
		
		// 是否提示安全打接近胖子
		ReportBoomerPop = false,
		
		// 是否提示推特感
		ReportShove = false,
		
		// 是否提示 Hunter 高扑
		ReportHunterDP = true,
		
		// 是否提示 Jockey 空投
		ReportJockeyDP = true,
		
		// 是否提示 Charger 冲锋秒杀
		ReportDeathCharge = true,
		
		// 是否提示助攻者
		ReportAssist = true,
		
		// 是否提示秒救
		ReportInsteClear = true,
		
		// 是否提示连跳
		ReportBHopStreak = true,
		
		// 是否提示推停呕吐 Boomer
		ReportPopStop = true,
	},
	
	ConfigVar = {},
	
	// 常量
	SHOTGUN_BLAST_TIME = 0.1,
	HOP_CHECK_TIME = 0.1,
	HOPEND_CHECK_TIME = 0.1,
	SHOVE_TIME = 0.05,
	MAX_CHARGE_TIME = 12.0,
	CHARGE_CHECK_TIME = 0.25,
	CHARGE_END_CHECK = 2.5,
	CHARGE_END_RECHECK = 3.0,
	VOMIT_DURATION_TIME = 2.25,
	ROCK_CHECK_TIME = 0.34,
	HITGROUP_HEAD = 1,
	MIN_DC_TRIGGER_DMG = 300,
	MIN_DC_FALL_DMG = 175,
	WEIRD_FLOW_THRESH = 900.0,
	MIN_FLOWDROPHEIGHT = 350.0,
	MIN_DC_RECHECK_DMG = 100,
	HOP_ACCEL_THRESH = 0.01,
	VICFLG_CARRIED = (1 << 0),
	VICFLG_FALL = (1 << 1),
	VICFLG_DROWN = (1 << 2),
	VICFLG_HURTLOTS = (1 << 3),
	VICFLG_TRIGGER = (1 << 4),
	VICFLG_AIRDEATH = (1 << 5),
	VICFLG_KILLEDBYOTHER = (1 << 6),
	VICFLG_WEIRDFLOW = (1 << 7),
	VICFLG_WEIRDFLOWDONE = (1 << 8),
	CUT_SHOVED = 1,
	CUT_SHOVEDSURV = 2,
	CUT_KILL = 3,
	CUT_SLASH = 4,
	
	// Hunter/Jockey
	iHunterLastHealth = {},
	iHunterOverkill = {},
	iHunterShotDmg = {},
	fHunterShotStart = {},
	fHunterTracePouncing = {},
	bHunterKilledPouncing = {},
	iHunterShotDmgTeam = {},
	iHunterShotCount = {},
	iHunterShotDamage = {},
	fPouncePosition = {},
	fVictimLastShove = {},
	iPounceDamage = {},
	
	// Charger
	iChargerHealth = {},
	iVictimMapDmg = {},
	iChargeVictim = {},
	fChargeTime = {},
	bDeathChargeIgnore = {},
	fChargeVictimPos = {},
	iVictimCharger = {},
	
	// Smoker
	iSmokerVictimDamage = {},
	bSmokerClearCheck = {},
	iSmokerVictim = {},
	bSmokerShoved = {},
	
	// Boomer
	bBoomerHitSomebody = {},
	bBoomerNearSomebody = {},
	bBoomerLanded = {},
	iBoomerGotShoved = {},
	fBoomerNearTime = {},
	fSpawnTime = {},
	iBoomerVomitHits = {},
	fBoomerVomitStart = {},
	
	// Tank
	bRockHitSomebody = {},
	
	// Witch
	iWitchAttacker = {},
	fWitchDamage = {},
	iWitchState = {},	// 1=bMelee.2=bShot.4=bOther.8=bAngry
	
	// 其他/通用
	iSpecialVictim = {},
	fPinTime = {},
	bHopCheck = {},
	fHopTopVelocity = {},
	bIsHopping = {},
	iHops = {},
	fLastHop = {},
	iVictimFlags = {},
	
	/*
	********************************
	*			杂项
	********************************
	*/
	
	function IsJockeyLeaping(jockey)
	{
		if(jockey == null || !jockey.IsValid() || jockey.GetType() != Z_JOCKEY ||
			jockey.GetNetPropEntity("m_hGroundEntity") != null ||
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
	
	function ResetHunter(player, death = false)
	{
		local puid = player.GetUserID();
		
		::SkillDetect.iHunterShotDmgTeam[puid] <- 0;
		::SkillDetect.iHunterShotDmg[puid] <- {};
		::SkillDetect.fHunterShotStart[puid] <- {};
		
		if(death)
		{
			::SkillDetect.iHunterShotCount[puid] <- {};
			::SkillDetect.iHunterShotDamage[puid] <- {};
		}
		
		::SkillDetect.iHunterOverkill[puid] <- 0;
	},
	
	function Timer_CheckHop(player)
	{
		if(player == null || !player.IsValid() || player.IsDead())
			return false;
		
		if(player.GetFlags() & FL_ONGROUND)
		{
			local velocity = player.GetVelocity();
			velocity.z = 0.0;
			
			local puid = player.GetUserID();
			
			::SkillDetect.bHopCheck[puid] <- true;
			
			Timers.AddTimerByName("skilldetect_streak_" + puid,
				::SkillDetect.HOPEND_CHECK_TIME, false,
				::SkillDetect.Timer_CheckHopStreak, player,
				0, { "action" : "reset" }
			);
		}
	},
	
	function Timer_CheckHopStreak(player)
	{
		if(player == null || !player.IsValid() || player.IsDead())
			return false;
		
		local puid = player.GetUserID();
		if(::SkillDetect.bHopCheck[puid] && ::SkillDetect.iHops[puid] > 0)
		{
			::SkillDetect.HandleBHopStreak(player, ::SkillDetect.iHops[puid], ::SkillDetect.fHopTopVelocity[puid]);
			::SkillDetect.bIsHopping[puid] = false;
			::SkillDetect.iHops[puid] = 0;
			::SkillDetect.fHopTopVelocity[puid] = 0.0;
		}
	},
	
	function Timer_BoomVomitCheck(player)
	{
		if(player == null || !player.IsValid() || player.IsDead())
			return false;
		
		local puid = player.GetUserID();
		::SkillDetect.iBoomerVomitHits[puid] = 0;
		::SkillDetect.bBoomerLanded[puid] = false;
		::SkillDetect.fBoomerVomitStart[puid] = 0.0;
	},
	
	function Timer_ChargeCheck(player)
	{
		if(player == null || !player.IsValid())
			return false;
		
		local puid = player.GetUserID();
		if(!::SkillDetect.iVictimCharger[puid] || ::SkillDetect.fChargeTime[puid] <= 0.0 ||
			Time() - ::SkillDetect.fChargeTime[puid] > ::SkillDetect.MAX_CHARGE_TIME)
			return false;
		
		if(player.IsDead())
		{
			::SkillDetect.iVictimFlags[puid] = ::SkillDetect.iVictimFlags[puid] | ::SkillDetect.VICFLG_AIRDEATH;
			::SkillDetect.Timer_DeathChargeCheck(player);
			return false;
		}
		else if((player.GetFlags() & FL_ONGROUND) && ::SkillDetect.iChargeVictim[::SkillDetect.iVictimCharger[puid]] != puid)
		{
			Timers.AddTimerByName("skilldetect_chargeend_" + puid,
				::SkillDetect.CHARGE_END_CHECK, false,
				::SkillDetect.Timer_DeathChargeCheck, player,
				0, { "action" : "once" }
			);
			return false;
		}
	},
	
	function Timer_DeathChargeCheck(player)
	{
		if(player == null || !player.IsValid())
			return false;
		
		local puid = player.GetUserID();
		local flags = ::SkillDetect.iVictimFlags[puid];
		
		if(player.IsDead())
		{
			local pos = player.GetLocation();
			local height = ::SkillDetect.fChargeVictimPos[puid].z - pos.z;
			
			if(((flags & (::SkillDetect.VICFLG_DROWN|::SkillDetect.VICFLG_FALL)) &&
				(flags & (::SkillDetect.VICFLG_HURTLOTS|::SkillDetect.VICFLG_AIRDEATH)) ||
				((flags & ::SkillDetect.VICFLG_WEIRDFLOW) && height >= ::SkillDetect.MIN_FLOWDROPHEIGHT) ||
				::SkillDetect.iVictimMapDmg[puid] >= ::SkillDetect.MIN_DC_TRIGGER_DMG) &&
				!(flags & ::SkillDetect.VICFLG_KILLEDBYOTHER))
			{
				::SkillDetect.HandleDeathCharge(Utils.GetPlayerFromUserID(::SkillDetect.iVictimCharger[puid]), player, height,
					Utils.CalculateDistance(::SkillDetect.fChargeVictimPos[puid], pos),
					!!(flags & ::SkillDetect.VICFLG_CARRIED)
				);
			}
		}
		else if(((flags & ::SkillDetect.VICFLG_WEIRDFLOW) || ::SkillDetect.iVictimMapDmg[puid] >= ::SkillDetect.MIN_DC_RECHECK_DMG) &&
			!(flags & ::SkillDetect.VICFLG_WEIRDFLOWDONE))
		{
			::SkillDetect.iVictimFlags[puid] = ::SkillDetect.iVictimFlags[puid] | ::SkillDetect.VICFLG_WEIRDFLOWDONE;
			
			/*
			Timers.AddTimerByName("skilldetect_chargeend_" + puid,
				::SkillDetect.CHARGE_END_RECHECK, false,
				::SkillDetect.Timer_DeathChargeCheck, player,
				0, { "action" : "reset" }
			);
			*/
			
			return ::SkillDetect.CHARGE_END_RECHECK;
		}
		
	},
	
	function Timer_ChargeCarryEnd(player)
	{
		if(player == null || !player.IsValid())
			return false;
		
		::SkillDetect.iChargeVictim[player.GetUserID()] = 0;
	},
	
	function Timer_CheckRockSkeet(params)
	{
		local player = params["attacker"];
		local tank = params["tank"];
		
		if(player == null || tank == null || !player.IsValid() || !tank.IsValid())
			return;
		
		local vuid = tank.GetUserID();
		
		if(!::SkillDetect.bRockHitSomebody[vuid])
		{
			::SkillDetect.HandleRockSkeeted(player, tank);
		}
	},
	
	function Timer_WitchDeath(params)
	{
		local witchid = params["witchid"];
		local auid = params["attacker"].GetUserID();
		
		if(::SkillDetect.iWitchAttacker[witchid] == auid)
		{
			local type = ::SkillDetect.iWitchState[witchid];
			local angry = ::SkillDetect.fWitchDamage[witchid][1].len();
			local calm = ::SkillDetect.fWitchDamage[witchid][0].len();
			if((type == 1 || type == 9) && calm == 1 && angry >= 1)	// 至少两刀砍死(bMelee|bAngry)
			{
				::SkillDetect.HandleCrown(params["attacker"], witchid, 9);
			}
			else if((type == 2 && (angry ^ calm) == 1) || params["oneshot"])	// 一枪带走(bShot)
			{
				::SkillDetect.HandleCrown(params["attacker"], witchid, 2);
			}
			else if(type == 10 && calm >= 1 && angry >= 1)	// 引秒(bShot|bAngry)
			{
				angry = ::SkillDetect.fWitchDamage[witchid][1].reduce(@(p, n) p + n);
				calm = ::SkillDetect.fWitchDamage[witchid][0].reduce(@(p, n) p + n);
				
				::SkillDetect.HandleDrawCrown(params["attacker"], witchid, 10, calm, angry);
			}
			
			printl("witch " + witchid + " dead, killer " + params["attacker"] + ", type " + type + ", at " + (angry + calm) + " shots");
		}
		
		delete ::SkillDetect.iWitchAttacker[witchid];
		delete ::SkillDetect.iWitchState[witchid];
		delete ::SkillDetect.fWitchDamage[witchid];
	},
	
	/*
	********************************
	*			效果
	********************************
	*/
	
	// mode: 1=bMelee.2=bSniper/bMagnum.3=bGL
	function HandleSkeet(attacker, victim, mode = 0, shots = 1, assist = null, isHunter = true)
	{
		if(!::SkillDetect.ConfigVar.ReportSkeet)
			return;
		
		switch(mode)
		{
			case 1:
			{
				Utils.PrintToChatAll("\x03★★ \x04%s\x01 melee-skeeted \x04%s\x01。", attacker.GetName(), victim.GetName());
				break;
			}
			case 2:
			{
				Utils.PrintToChatAll("\x03★ \x04%s\x01 headshot-skeeted \x04%s\x01。", attacker.GetName(), victim.GetName());
				break;
			}
			case 3:
			{
				Utils.PrintToChatAll("\x03★ \x04%s\x01 grenade-skeeted \x04%s\x01。", attacker.GetName(), victim.GetName());
				break;
			}
			default:
			{
				if(shots > 1)
				{
					Utils.PrintToChatAll("\x03★ \x04%s\x01 skeeted \x04%s\x01(\x05%d\x01 shots)。", attacker.GetName(), victim.GetName(), shots);
				}
				else
				{
					Utils.PrintToChatAll("\x03★ \x04%s\x01 skeeted \x04%s\x01。", attacker.GetName(), victim.GetName());
				}
				break;
			}
		}
		
		::SkillDetect.HandleSkeetAssist(attacker, victim);
	},
	
	function HandleSkeetAssist(attacker, victim)
	{
		if(!::SkillDetect.ConfigVar.ReportAssist)
			return;
		
		local vuid = victim.GetUserID();
		local auid = attacker.GetUserID();
		if(::SkillDetect.iHunterShotDmgTeam[vuid] <= 0)
			return;
		
		local flip = true;
		local anything = false;
		local message = "\x03助攻：\x01";
		foreach(asuid, shots in ::SkillDetect.iHunterShotCount[vuid])
		{
			local damage = ::SkillDetect.iHunterShotDamage[vuid][asuid];
			if(asuid == auid || damage <= 0)
				continue;
			
			local assister = Utils.GetPlayerFromUserID(asuid);
			if(assister == null || !assister.IsValid())
				continue;
			
			message += format("\x04%s\x01 (\x05%d\x01shots,\x05%d\x01 damage)\n", assister.GetName(), shots, damage);
			flip = !flip;
			anything = true;
			
			if(flip)
			{
				Utils.PrintToChatAll(message);
				message = "";
			}
		}
		
		if(anything && message != "")
			Utils.PrintToChatAll(message);
	},
	
	// mode: 1=bMelee.2=bSniper/bMagnum
	function HandleNonSkeet(attacker, victim, damage, bOverKill = false, mode = 0, shots = 1, isHunter = true)
	{
		if(!::SkillDetect.ConfigVar.ReportHurtSkeet)
			return;
		
		switch(mode)
		{
			case 1:
			{
				Utils.PrintToChatAll("\x03★%s \x04%s\x01 was not melee-skeeted \x04%s\x01(\x05%d\x01 damage)。", (bOverKill ? "★":"☆"), attacker.GetName(), victim.GetName(), damage);
				break;
			}
			case 2:
			{
				Utils.PrintToChatAll("\x03%s \x04%s\x01 was not headshot-skeeted \x04%s\x01(\x05%d\x01 damage)。", (bOverKill ? "★":"☆"), attacker.GetName(), victim.GetName(), damage);
				break;
			}
			default:
			{
				if(shots > 1)
				{
					Utils.PrintToChatAll("\x03%s \x04%s\x01 was not skeeted \x04%s\x01(\x05%d\x01shots,\x05%d\x01 damage)。", (bOverKill ? "★":"☆"), attacker.GetName(), victim.GetName(), shots, damage);
				}
				else
				{
					Utils.PrintToChatAll("\x03%s \x04%s\x01 was not skeeted \x04%s\x01(\x05%d\x01 damage)。", (bOverKill ? "★":"☆"), attacker.GetName(), victim.GetName(), damage);
				}
				break;
			}
		}
		
		::SkillDetect.HandleSkeetAssist(attacker, victim);
	},
	
	function HandleLevel(attacker, victim)
	{
		if(!::SkillDetect.ConfigVar.ReportLevel)
			return;
		
		Utils.PrintToChatAll("\x03★★★ \x04%s\x01 fully leveled \x04%s\x01。", attacker.GetName(), victim.GetName());
	},
	
	function HandleLevelHurt(attacker, victim, damage)
	{
		if(!::SkillDetect.ConfigVar.ReportHurtLevel)
			return;
		
		Utils.PrintToChatAll("\x03★★ \x04%s\x01 chip-leveled \x04%s\x01(\x05%d\x01 damage)。", attacker.GetName(), victim.GetName(), damage);
	},
	
	function HandleClear(attacker, victim, pinVictim, zombieClass, clearTimeA, clearTimeB, bWithShove = false)
	{
		if(!::SkillDetect.ConfigVar.ReportInsteClear)
			return;
		
		if(clearTimeA != -1.0 && clearTimeA <= ::SkillDetect.ConfigVar.MaxInsteaClear && attacker.IsPlayer() && attacker != pinVictim && attacker != victim)
		{
			Utils.PrintToChatAll("\x03☆ \x04%s\x01 insta-cleared \x04%s\x01 from \x04%s\x01(\x05%.2f\x01 seconds)。", attacker.GetName(), pinVictim.GetName(), victim.GetName(), clearTimeA);
		}
	},
	
	function HandleSmokerSelfClear(attacker, victim, withShove = false)
	{
		if(!::SkillDetect.ConfigVar.ReportSelfClear)
			return;
		
		Utils.PrintToChatAll("\x03☆☆ \x04%s\x01 self-cleared from \x04%s\x01 tongue%s。", attacker.GetName(), victim.GetName(), (withShove?" by shoving":""));
	},
	
	function HandlePopStop(attacker, victim, hits, timeVomit)
	{
		if(!::SkillDetect.ConfigVar.ReportPopStop)
			return;
		
		Utils.PrintToChatAll("\x03★ \x04%s\x01 popstopped \x04%s\x01 (\x05%.1f\x01 seconds)。", attacker.GetName(), victim.GetName(), timeVomit);
	},
	
	function HandleDeadstop(attacker, victim, bHunter)
	{
		if(!::SkillDetect.ConfigVar.ReportDeadstop)
			return;
		
		Utils.PrintToChatAll("\x03☆ \x04%s\x01 deadstopped \x04%s\x01。", attacker.GetName(), victim.GetName());
	},
	
	function HandleShove(attacker, victim, zClass)
	{
		if(!::SkillDetect.ConfigVar.ReportShove)
			return;
		
		Utils.PrintToChatAll("\x03☆ \x04%s\x01 shoved \x04%s\x01。", attacker.GetName(), victim.GetName());
	},
	
	function HandleHunterDP(attacker, victim, actualDamage, calculatedDamage, height)
	{
		if(!::SkillDetect.ConfigVar.ReportHunterDP)
			return;
		
		if(height < ::SkillDetect.ConfigVar.MinHighPounceHeight)
			return;
		
		Utils.PrintToChatAll("\x03★☆ \x04%s\x01 high-pounced \x04%s\x01(height:\x05%.1f\x01,\x05%d\x01 damage)。", attacker.GetName(), victim.GetName(), height, actualDamage);
	},
	
	function HandleJockeyDP(attacker, victim, height)
	{
		if(!::SkillDetect.ConfigVar.ReportJockeyDP)
			return;
		
		if(height < ::SkillDetect.ConfigVar.MinHighRideHeight)
			return;
		
		Utils.PrintToChatAll("\x03★☆ \x04%s\x01 high-pounced \x04%s\x01(height:\x05%.1f\x01)。", attacker.GetName(), victim.GetName(), height);
	},
	
	function HandleBHopStreak(player, streak, topSpeed)
	{
		if(!::SkillDetect.ConfigVar.ReportBHopStreak)
			return;
		
		if(streak < ::SkillDetect.ConfigVar.MinBHopStreak)
			return;
		
		Utils.PrintToChatAll("\x03☆ \x04%s\x01 got \x05%d\x01 bunnyhop%s in a row(top speed:\x05%.1f\x01)。", player.GetName(), streak, (streak>1?"s":""), topSpeed);
	},
	
	function HandleDeathCharge(attacker, victim, height, distance, bCarried = false)
	{
		if(!::SkillDetect.ConfigVar.ReportDeathCharge)
			return;
		
		local vuid = victim.GetUserID();
		local auid = attacker.GetUserID();
		if((auid in ::SkillDetect.bDeathChargeIgnore) && (vuid in ::SkillDetect.bDeathChargeIgnore[auid]))
			return;
		if(auid in ::SkillDetect.bDeathChargeIgnore)
			::SkillDetect.bDeathChargeIgnore[auid][vuid] <- true;
		else
		{
			::SkillDetect.bDeathChargeIgnore[auid] <- {};
			::SkillDetect.bDeathChargeIgnore[auid][vuid] <- true;
		}
		Utils.PrintToChatAll("\x03★★★ \x04%s\x01 death-charged \x04%s\x01%s (height:\x05%.1f\x01)。", attacker.GetName(), victim.GetName(), (bCarried?" by bowling":""), height);
	},
	
	function HandleRockSkeeted(attacker, victim)
	{
		if(!::SkillDetect.ConfigVar.ReportRockSkeet)
			return;
		
		Utils.PrintToChatAll("\x03★★★ \x04%s\x01 melee-skeeted \x04%s\x01 rock。", attacker.GetName(), victim.GetName());
	},
	
	function HandlePop(attacker, victim, numShoved, timeAlive, timeNear)
	{
		if(!::SkillDetect.ConfigVar.ReportBoomerPop)
			return;
		
		if(timeNear <= 3.0)
			Utils.PrintToChatAll("\x03☆ \x04%s\x01 popped \x04%s\x01(\x05.1f\x01seconds)", attacker.GetName(), victim.GetName(), timeNear);
	},
	
	function HandleCrown(attacker, witchid, type)
	{
		if(!::SkillDetect.ConfigVar.ReportCrown)
			return;
		
		if(type == 9)
		{
			Utils.PrintToChatAll("\x03★ \x04%s\x01 melee-crowned a \x04Witch\x01。", attacker.GetName());
		}
		else if(type == 2)
		{
			Utils.PrintToChatAll("\x03★ \x04%s\x01 crowned a \x04Witch\x01。", attacker.GetName());
		}
	},
	
	function HandleDrawCrown(attacker, witchid, type, chipdamage, damage)
	{
		if(!::SkillDetect.ConfigVar.ReportDrawCrown)
			return;
		
		if(type == 10)
		{
			Utils.PrintToChatAll("\x03★☆ \x04%s\x01 draw-crowned a \x04Witch\x01(\x05%.0f\x01 chip,\x05%.0f\x01 damage)。", attacker.GetName(), chipdamage, damage);
		}
	},
	
	function HandleTongueCut(attacker, victim)
	{
		if(!::SkillDetect.ConfigVar.ReportTongueCut)
			return;
		
		Utils.PrintToChatAll("\x03★★ \x04%s\x01 cut \x04%s\x01 tongue。", attacker.GetName(), victim.GetName());
	},
}

function Notifications::OnRoundBegin::SkillDetect(params)
{
	::SkillDetect.fVictimLastShove <- {};
}

function Notifications::OnScavengeStart::SkillDetect(round, firsthalf, params)
{
	::SkillDetect.fVictimLastShove <- {};
}

function Notifications::OnSpawn::SkillDetect(player, params)
{
	if(player == null || !player.IsValid())
		return;
	
	local puid = player.GetUserID();
	local zClass = player.GetType();
	
	switch(zClass)
	{
		case Z_SMOKER:
		{
			::SkillDetect.bSmokerClearCheck[puid] <- false;
			::SkillDetect.bSmokerShoved[puid] <- false;
			::SkillDetect.iSmokerVictim[puid] <- 0;
			::SkillDetect.iSmokerVictimDamage[puid] <- 0;
			break;
		}
		case Z_BOOMER:
		{
			::SkillDetect.bBoomerHitSomebody[puid] <- false;
			::SkillDetect.bBoomerNearSomebody[puid] <- false;
			::SkillDetect.bBoomerLanded[puid] <- false;
			::SkillDetect.iBoomerGotShoved[puid] <- 0;
			::SkillDetect.fBoomerNearTime[puid] <- 0;
			::SkillDetect.fBoomerVomitStart[puid] <- 0;
			::SkillDetect.iBoomerVomitHits[puid] <- 0;
			break;
		}
		case Z_HUNTER:
		case Z_JOCKEY:
		{
			::SkillDetect.fPouncePosition[puid] <- null;
			::SkillDetect.fHunterTracePouncing[puid] <- 0.0;
			::SkillDetect.iPounceDamage[puid] <- 0.0;
			::SkillDetect.ResetHunter(player, true);
			break;
		}
		case Z_CHARGER:
		{
			::SkillDetect.iChargerHealth[puid] <- player.GetNetPropInt("m_iMaxHealth");
			break;
		}
	}
	
	::SkillDetect.fPinTime[puid] <- [ 0.0, 0.0 ];
	::SkillDetect.fSpawnTime[puid] <- Time();
}

function Notifications::OnHurt::SkillDetect(victim, attacker, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(!("dmg_health" in params) || params["dmg_health"] == null || params["dmg_health"] == "" || params["dmg_health"] <= 0)
		return;
	
	local damage = params["dmg_health"];
	local damagetype = params["type"];
	local vuid = (victim != null && victim.IsValid() && victim.IsPlayer() ? victim.GetUserID() : null);
	local auid = (attacker != null && attacker.IsValid() && attacker.IsPlayer() ? attacker.GetUserID() : null);
	local time = Time();
	
	if(vuid != null)	// 打特感
	{
		local zClass = victim.GetType();
		local health = params["health"];
		local hitgroup = params["hitgroup"];
		
		switch(zClass)
		{
			case Z_HUNTER:
			case Z_JOCKEY:
			{
				if(auid == null)
				{
					::SkillDetect.iHunterLastHealth[vuid] <- health;
					break;
				}
				
				if(vuid in ::SkillDetect.iHunterLastHealth && ::SkillDetect.iHunterLastHealth[vuid] > 0 && damage > ::SkillDetect.iHunterLastHealth[vuid])
				{
					damage = ::SkillDetect.iHunterLastHealth[vuid];
					::SkillDetect.iHunterOverkill[vuid] <- ::SkillDetect.iHunterLastHealth[vuid] - damage;
					::SkillDetect.iHunterLastHealth[vuid] <- 0;
				}
				
				if((vuid in ::SkillDetect.iHunterShotDmg) && (auid in ::SkillDetect.iHunterShotDmg[vuid]) &&
					::SkillDetect.iHunterShotDmg[vuid][auid] > 0 &&
					(vuid in ::SkillDetect.fHunterShotStart) && (auid in ::SkillDetect.fHunterShotStart[vuid]) &&
					time - ::SkillDetect.fHunterShotStart[vuid][auid] > ::SkillDetect.SHOTGUN_BLAST_TIME)
				{
					::SkillDetect.fHunterShotStart[vuid][auid] = 0.0;
				}
				
				local isPouncing = (victim.GetNetPropBool("m_isAttemptingToPounce") ||
					(vuid in ::SkillDetect.fHunterTracePouncing && ::SkillDetect.fHunterTracePouncing[vuid] != 0.0 && time - ::SkillDetect.fHunterTracePouncing[vuid] < 0.001));
				local maxDamage = Convars.GetFloat("z_pounce_damage_interrupt");
				
				if(isPouncing || ::SkillDetect.IsJockeyLeaping(victim))
				{
					if(damagetype & DMG_BUCKSHOT)	// 霰弹枪
					{
						if((vuid in ::SkillDetect.fHunterShotStart) && (auid in ::SkillDetect.fHunterShotStart[vuid]) &&
							::SkillDetect.fHunterShotStart[vuid][auid] <= 0.0)
						{
							::SkillDetect.fHunterShotStart[vuid][auid] = time;
							if((vuid in ::SkillDetect.iHunterShotCount) && (auid in ::SkillDetect.iHunterShotCount[vuid]))
								::SkillDetect.iHunterShotCount[vuid][auid] += 1;
							else if(vuid in ::SkillDetect.iHunterShotCount)
								::SkillDetect.iHunterShotCount[vuid][auid] <- 1;
							else
							{
								::SkillDetect.iHunterShotCount[vuid] <- {};
								::SkillDetect.iHunterShotCount[vuid][auid] <- 1;
							}
						}
						
						if((vuid in ::SkillDetect.iHunterShotDmg) && (auid in ::SkillDetect.iHunterShotDmg[vuid]))
							::SkillDetect.iHunterShotDmg[vuid][auid] += damage;
						else if(vuid in ::SkillDetect.iHunterShotDmg)
							::SkillDetect.iHunterShotDmg[vuid][auid] <- damage;
						else
						{
							::SkillDetect.iHunterShotDmg[vuid] <- {};
							::SkillDetect.iHunterShotDmg[vuid][auid] <- damage;
						}
						if(vuid in ::SkillDetect.iHunterShotDmgTeam)
							::SkillDetect.iHunterShotDmgTeam[vuid] += damage;
						else
							::SkillDetect.iHunterShotDmgTeam[vuid] <- damage;
						if((vuid in ::SkillDetect.iHunterShotDamage) && (auid in ::SkillDetect.iHunterShotDamage[vuid]))
							::SkillDetect.iHunterShotDamage[vuid][auid] += damage;
						else if(vuid in ::SkillDetect.iHunterShotDamage)
							::SkillDetect.iHunterShotDamage[vuid][auid] <- damage;
						else
						{
							::SkillDetect.iHunterShotDamage[vuid] <- {};
							::SkillDetect.iHunterShotDamage[vuid][auid] <- damage;
						}
						
						if(health <= 0)
							::SkillDetect.bHunterKilledPouncing[vuid] <- true;
					}
					else if((damagetype & (DMG_BLAST|DMG_PLASMA)) == (DMG_BLAST|DMG_PLASMA) && health <= 0)	// 榴弹直接击中(非爆炸)
					{
						if(params["weapon"] == "grenade_launcher_projectile")
							::SkillDetect.HandleSkeet(attacker, victim, 3, 1, null, (zClass == Z_HUNTER));
					}
					else if(damagetype & DMG_BULLET)	// 爆头
					{
						if(params["weapon"] == "hunting_rifle" || params["weapon"] == "sniper_military" ||
							params["weapon"] == "sniper_awp" || params["weapon"] == "sniper_scout" ||
							params["weapon"] == "pistol_magnum")
						{
							if((vuid in ::SkillDetect.iHunterShotCount) && (auid in ::SkillDetect.iHunterShotCount[vuid]))
								::SkillDetect.iHunterShotCount[vuid][auid] += 1;
							else if(vuid in ::SkillDetect.iHunterShotCount)
								::SkillDetect.iHunterShotCount[vuid][auid] <- 1;
							else
							{
								::SkillDetect.iHunterShotCount[vuid] <- {};
								::SkillDetect.iHunterShotCount[vuid][auid] <- 1;
							}
							
							if(health <= 0 && hitgroup == ::SkillDetect.HITGROUP_HEAD)
							{
								if(damage >= maxDamage)		// 满血一枪
								{
									::SkillDetect.iHunterShotDmgTeam[vuid] = 0;
									::SkillDetect.HandleSkeet(attacker, victim, 2,
										::SkillDetect.iHunterShotCount[vuid][auid],
										null, (zClass == Z_HUNTER)
									);
								}
								else	// 残血
								{
									::SkillDetect.HandleNonSkeet(attacker, victim, damage,
										::SkillDetect.iHunterOverkill[vuid] + ::SkillDetect.iHunterShotDmgTeam[vuid] > maxDamage,
										2, ::SkillDetect.iHunterShotCount[vuid][auid], (zClass == Z_HUNTER)
									);
								}
								
								::SkillDetect.ResetHunter(victim);
							}
							else
							{
								if(vuid in ::SkillDetect.iHunterShotDmgTeam)
									::SkillDetect.iHunterShotDmgTeam[vuid] += damage;
								else
									::SkillDetect.iHunterShotDmgTeam[vuid] <- damage;
								// ::SkillDetect.iHunterShotDmg[vuid][auid] += damage;
								if((vuid in ::SkillDetect.iHunterShotDamage) && (auid in ::SkillDetect.iHunterShotDamage[vuid]))
									::SkillDetect.iHunterShotDamage[vuid][auid] += damage;
								else if(vuid in ::SkillDetect.iHunterShotDamage)
									::SkillDetect.iHunterShotDamage[vuid][auid] <- damage;
								else
								{
									::SkillDetect.iHunterShotDamage[vuid] <- {};
									::SkillDetect.iHunterShotDamage[vuid][auid] <- damage;
								}
							}
						}
					}
					else if(damagetype & (DMG_SLASH|DMG_CLUB))	// 切/敲/拍
					{
						if(damage >= maxDamage)		// 满血一刀
						{
							::SkillDetect.iHunterShotDmgTeam[vuid] <- 0;
							::SkillDetect.HandleSkeet(attacker, victim, 1, 1, null, (zClass == Z_HUNTER));
							::SkillDetect.ResetHunter(victim);
						}
						else if(health <= 0)		// 残血
						{
							::SkillDetect.HandleNonSkeet(attacker, victim, damage, true, 1, 1, (zClass == Z_HUNTER));
							::SkillDetect.ResetHunter(victim);
						}
					}
				}
				else if(health <= 0)
				{
					::SkillDetect.bHunterKilledPouncing[vuid] <- false;
				}
				
				::SkillDetect.iHunterLastHealth[vuid] <- health;
				break;
			}
			case Z_CHARGER:
			{
				if(auid != null)
				{
					if(health <= 0 && (damagetype & (DMG_CLUB|DMG_SLASH)))
					{
						local maxHealth = victim.GetNetPropInt("m_iMaxHealth");
						local ability = victim.GetNetPropEntity("m_customAbility");
						if(ability != null && ability.IsValid() && ability.GetNetPropBool("m_isCharging"))
						{
							if(::SkillDetect.ConfigVar.HideFakeDamage)
							{
								damage = maxHealth - ::SkillDetect.iChargerHealth[vuid];
							}
							
							if(damage > maxHealth * 0.65)
							{
								::SkillDetect.HandleLevel(attacker, victim);
							}
							else
							{
								::SkillDetect.HandleLevelHurt(attacker, victim, damage);
							}
						}
					}
				}
				
				if(health > 0)
				{
					::SkillDetect.iChargerHealth[vuid] <- health;
				}
				
				break;
			}
			case Z_SMOKER:
			{
				if(auid == null)
					return;
				
				::SkillDetect.iSmokerVictimDamage[vuid] += damage;
				break;
			}
		}
	}
	else if(auid != null)	// 打生还
	{
		local zClass = attacker.GetType();
		
		switch(zClass)
		{
			case Z_HUNTER:
			{
				if(damagetype & DMG_CRUSH)
				{
					// 空投伤害
					::SkillDetect.iPounceDamage[auid] <- damage;
				}
				break;
			}
			case Z_TANK:
			{
				if(params["weapon"] == "tank_rock")
					::SkillDetect.bRockHitSomebody[auid] <- true;
			}
		}
	}
	
	// 检测冲锋秒人
	if(vuid != null)
	{
		if(damagetype & (DMG_DROWN|DMG_FALL))
		{
			if(vuid in ::SkillDetect.iVictimMapDmg)
				::SkillDetect.iVictimMapDmg[vuid] += damage;
			else
				::SkillDetect.iVictimMapDmg[vuid] <- damage;
		}
		if((damagetype & DMG_DROWN) && damage >= ::SkillDetect.MIN_DC_TRIGGER_DMG)
		{
			if(vuid in ::SkillDetect.iVictimFlags)
				::SkillDetect.iVictimFlags[vuid] = ::SkillDetect.iVictimFlags[vuid] | ::SkillDetect.VICFLG_HURTLOTS;
			else
				::SkillDetect.iVictimFlags[vuid] <- ::SkillDetect.VICFLG_HURTLOTS;
		}
		else if((damagetype & DMG_FALL) && damage >= ::SkillDetect.MIN_DC_FALL_DMG)
		{
			if(vuid in ::SkillDetect.iVictimFlags)
				::SkillDetect.iVictimFlags[vuid] = ::SkillDetect.iVictimFlags[vuid] | ::SkillDetect.VICFLG_HURTLOTS;
			else
				::SkillDetect.iVictimFlags[vuid] <- ::SkillDetect.VICFLG_HURTLOTS;
		}
	}
}

function Notifications::OnIncapacitatedStart::SkillDetect(victim, attacker, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(victim == null || !victim.IsValid())
		return;
	
	local dmgtype = params["type"];
	local puid = victim.GetUserID();
	
	if(attacker != null && attacker.IsValid() && !attacker.IsPlayer())
	{
		local classname = attacker.GetClassname();
		if(classname == "tank_rock" || classname == "witch" || classname == "trigger_hurt" ||
			classname == "prop_car_alarm" || classname == "prop_car_glass")
		{
			if(puid in ::SkillDetect.iVictimFlags)
				::SkillDetect.iVictimFlags[puid] = ::SkillDetect.iVictimFlags[puid] | ::SkillDetect.VICFLG_TRIGGER;
			else
				::SkillDetect.iVictimFlags[puid] <- ::SkillDetect.VICFLG_TRIGGER;
		}
	}
	
	local flow = victim.GetFlowDistance();
	
	if(dmgtype & DMG_DROWN)
	{
		if(puid in ::SkillDetect.iVictimFlags)
			::SkillDetect.iVictimFlags[puid] = ::SkillDetect.iVictimFlags[puid] | ::SkillDetect.VICFLG_DROWN;
		else
			::SkillDetect.iVictimFlags[puid] <- ::SkillDetect.VICFLG_DROWN;
	}
	if(flow < ::SkillDetect.WEIRD_FLOW_THRESH)
	{
		if(puid in ::SkillDetect.iVictimFlags)
			::SkillDetect.iVictimFlags[puid] = ::SkillDetect.iVictimFlags[puid] | ::SkillDetect.VICFLG_WEIRDFLOW;
		else
			::SkillDetect.iVictimFlags[puid] <- ::SkillDetect.VICFLG_WEIRDFLOW;
	}
}

function Notifications::OnDeath::SkillDetect(victim, attacker, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	local damagetype = params["type"];
	local vuid = (victim != null && victim.IsValid() && victim.IsPlayer() ? victim.GetUserID() : null);
	local auid = (attacker != null && attacker.IsValid() && attacker.IsPlayer() ? attacker.GetUserID() : null);
	local time = Time();
	local team = victim.GetTeam();
	
	if(vuid != null && team == INFECTED)
	{
		local zClass = victim.GetNetPropInt("m_zombieClass");
		switch(zClass)
		{
			case Z_HUNTER:
			case Z_JOCKEY:
			{
				if(auid == null)
					return;
				
				local maxDamage = Convars.GetFloat("z_pounce_damage_interrupt");
				
				if(::SkillDetect.iHunterShotDmgTeam[vuid] > 0 && vuid in ::SkillDetect.bHunterKilledPouncing && ::SkillDetect.bHunterKilledPouncing[vuid])
				{
					if(::SkillDetect.iHunterShotDmgTeam[vuid] > ::SkillDetect.iHunterShotDmg[vuid][auid] &&
						::SkillDetect.iHunterShotDmgTeam[vuid] >= maxDamage)
					{
						// 多人合力击杀
						// ::SkillDetect.HandleSkeetAssist(attacker, victim);
					}
					else if(::SkillDetect.iHunterShotDmg[vuid][auid] >= maxDamage)
					{
						// 单杀
						local shots = 0;
						if((vuid in ::SkillDetect.iHunterShotCount) && (auid in ::SkillDetect.iHunterShotCount[vuid]))
							shots = ::SkillDetect.iHunterShotCount[vuid][auid];
						::SkillDetect.HandleSkeet(attacker, victim, 0, shots,
							null, (zClass == Z_HUNTER)
						);
					}
					else if(::SkillDetect.iHunterOverkill[vuid] > 0)
					{
						// 一枪+助攻
						::SkillDetect.HandleNonSkeet(attacker, victim, ::SkillDetect.iHunterShotDmgTeam[vuid],
							(::SkillDetect.iHunterOverkill[vuid] + ::SkillDetect.iHunterShotDmgTeam[vuid] >= maxDamage),
							0, 1, (zClass == Z_HUNTER)
						);
					}
					else
					{
						// 一枪
						::SkillDetect.HandleNonSkeet(attacker, victim, ::SkillDetect.iHunterShotDmg[vuid][auid],
							false, 0, 1, (zClass == Z_HUNTER)
						);
					}
				}
				else
				{
					if(auid != null && vuid in ::SkillDetect.iSpecialVictim && ::SkillDetect.iSpecialVictim[vuid] > 0)
					{
						::SkillDetect.HandleClear(attacker, victim, Utils.GetPlayerFromUserID(::SkillDetect.iSpecialVictim[vuid]),
							zClass, time - ::SkillDetect.fPinTime[vuid][0], -1.0
						);
					}
				}
				
				break;
			}
			case Z_SMOKER:
			{
				if(auid == null)
					return;
				
				if(::SkillDetect.bSmokerClearCheck[vuid] &&
					::SkillDetect.iSmokerVictim[vuid] == auid &&
					::SkillDetect.iSmokerVictimDamage[vuid] >= ::SkillDetect.ConfigVar.MinSelfCleanDamage)
				{
					::SkillDetect.HandleSmokerSelfClear(attacker, victim, false);
				}
				else
				{
					::SkillDetect.bSmokerClearCheck[vuid] <- false;
					::SkillDetect.iSmokerVictim[vuid] <- 0;
				}
				
				break;
			}
			case Z_CHARGER:
			{
				local chargeVictim = (vuid in ::SkillDetect.iChargeVictim ? ::SkillDetect.iChargeVictim[vuid] : 0);
				if(chargeVictim > 0)
					chargeVictim = Utils.GetPlayerFromUserID(chargeVictim);
				if(chargeVictim != 0 && chargeVictim != null && chargeVictim.IsValid())
					::SkillDetect.fChargeTime[::SkillDetect.iChargeVictim[vuid]] <- time;
				
				if(auid != null && vuid in ::SkillDetect.iSpecialVictim && ::SkillDetect.iSpecialVictim[vuid] > 0)
				{
					::SkillDetect.HandleClear(attacker, victim,
						Utils.GetPlayerFromUserID(::SkillDetect.iSpecialVictim[vuid]),
						Z_CHARGER,
						(::SkillDetect.fPinTime[vuid][1] > 0.0 ? time - ::SkillDetect.fPinTime[vuid][1] : -1.0),
						time - ::SkillDetect.fPinTime[vuid][0]
					);
				}
			}
		}
	}
	else if(vuid != null && team == SURVIVOR)
	{
		if(damagetype & DMG_FALL)
		{
			if(vuid in ::SkillDetect.iVictimFlags)
				::SkillDetect.iVictimFlags[vuid] = ::SkillDetect.iVictimFlags[vuid] | ::SkillDetect.VICFLG_FALL;
			else
				::SkillDetect.iVictimFlags[vuid] <- ::SkillDetect.VICFLG_FALL;
		}
		else if(auid != null && attacker.GetTeam() == INFECTED && (!(vuid in ::SkillDetect.iVictimCharger) || auid != ::SkillDetect.iVictimCharger[vuid]))
		{
			if(vuid in ::SkillDetect.iVictimFlags)
				::SkillDetect.iVictimFlags[vuid] = ::SkillDetect.iVictimFlags[vuid] | ::SkillDetect.VICFLG_KILLEDBYOTHER;
			else
				::SkillDetect.iVictimFlags[vuid] <- ::SkillDetect.VICFLG_KILLEDBYOTHER;
		}
	}
}

function Notifications::OnPlayerShoved::SkillDetect(victim, attacker, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsValid() || !attacker.IsValid() ||
		victim.GetTeam() != 3 || attacker.GetTeam() != 2)
		return;
	
	local zClass = victim.GetNetPropInt("m_zombieClass");
	local vuid = victim.GetUserID();
	local auid = attacker.GetUserID();
	local time = Time();
	
	switch(zClass)
	{
		case Z_BOOMER:
		{
			::SkillDetect.iBoomerGotShoved[vuid] += 1;
			if(::SkillDetect.bBoomerLanded[vuid])
			{
				::SkillDetect.HandlePopStop(attacker, victim, ::SkillDetect.iBoomerVomitHits[vuid],
					time - ::SkillDetect.fBoomerVomitStart[vuid]
				);
				
				::SkillDetect.Timer_BoomVomitCheck(victim);
			}
			break;
		}
		case Z_HUNTER:
		{
			local pinned = victim.GetNetPropEntity("m_pounceVictim");
			if(pinned != null && pinned.IsValid())
			{
				::SkillDetect.HandleClear(attacker, victim, pinned,
					Z_HUNTER, time - ::SkillDetect.fPinTime[vuid][0],
					-1.0, true
				);
			}
			
			break;
		}
		case Z_JOCKEY:
		{
			local pinned = victim.GetNetPropEntity("m_jockeyVictim");
			if(pinned != null && pinned.IsValid())
			{
				::SkillDetect.HandleClear(attacker, victim, pinned,
					Z_JOCKEY, time - ::SkillDetect.fPinTime[vuid][0],
					-1.0, true
				);
			}
			
			break;
		}
	}
	
	if(!(vuid in ::SkillDetect.fVictimLastShove) || !(auid in ::SkillDetect.fVictimLastShove[vuid]) ||
		::SkillDetect.fVictimLastShove[vuid][auid] <= 0.0 || time - ::SkillDetect.fVictimLastShove[vuid][auid] >= ::SkillDetect.SHOVE_TIME)
	{
		if(victim.GetNetPropBool("m_isAttemptingToPounce"))
		{
			::SkillDetect.HandleDeadstop(attacker, victim, true);
		}
		else if(::SkillDetect.IsJockeyLeaping(victim))
		{
			::SkillDetect.HandleDeadstop(attacker, victim, false);
		}
		
		::SkillDetect.HandleShove(attacker, victim, zClass);
		
		if(vuid in ::SkillDetect.fVictimLastShove)
			::SkillDetect.fVictimLastShove[vuid][auid] <- time;
		else
		{
			::SkillDetect.fVictimLastShove[vuid] <- {};
			::SkillDetect.fVictimLastShove[vuid][auid] <- time;
		}
	}
	
	if(((vuid in ::SkillDetect.iSmokerVictim) && ::SkillDetect.iSmokerVictim[vuid] == auid) ||
		attacker.GetNetPropEntity("m_tongueVictim") == victim ||
		victim.GetNetPropEntity("m_tongueOwner") == attacker)
	{
		::SkillDetect.bSmokerShoved[vuid] <- true;
	}
}

function Notifications::OnHunterPouncedVictim::SkillDetect(attacker, victim, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsValid() || !attacker.IsValid())
		return;
	
	local vuid = victim.GetUserID();
	local auid = attacker.GetUserID();
	
	::SkillDetect.fPinTime[auid][0] = Time();
	
	::SkillDetect.ResetHunter(attacker);
	
	if(::SkillDetect.fPouncePosition[auid] == null)
		return;
	
	local endPos = attacker.GetLocation();
	local height = ::SkillDetect.fPouncePosition[auid].z - endPos.z;
	local minRange = Convars.GetFloat("z_pounce_damage_range_min");
	local maxRange = Convars.GetFloat("z_pounce_damage_range_max");
	local maxDamage = Convars.GetFloat("z_hunter_max_pounce_bonus_damage");
	if(minRange == null)
		minRange = 300.0;
	if(maxRange == null)
		maxRange = 1000.0;
	
	local distance = Utils.CalculateDistance(::SkillDetect.fPouncePosition[auid], endPos);
	local damage = (((distance - minRange) / (maxRange - minRange)) * maxDamage) + 1.0;
	
	if(damage < 0.0)
		damage = 0.0;
	else if(damage > maxDamage + 1.0)
		damage = maxDamage + 1.0;
	
	local rawDamage = (auid in ::SkillDetect.iPounceDamage ? ::SkillDetect.iPounceDamage[auid] : 0);
	::SkillDetect.HandleHunterDP(attacker, victim, rawDamage, damage, height);
}

function Notifications::OnJump::SkillDetect(player, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsValid())
		return;
	
	local puid = player.GetUserID();
	
	if(player.GetType() == Z_JOCKEY)
	{
		::SkillDetect.fPouncePosition[puid] <- player.GetLocation();
	}
	
	local velocity = player.GetVelocity();
	velocity.z = 0.0;
	
	local lengthNew = velocity.Length();
	
	::SkillDetect.bHopCheck[puid] <- true;
	
	if(!(puid in ::SkillDetect.bIsHopping) || !::SkillDetect.bIsHopping[puid])
	{
		if(lengthNew >= ::SkillDetect.ConfigVar.MinBHopFirstSpeed)
		{
			::SkillDetect.fHopTopVelocity[puid] <- lengthNew;
			::SkillDetect.bIsHopping[puid] <- true;
			::SkillDetect.iHops[puid] <- 0;
		}
	}
	else
	{
		local lengthOld = ::SkillDetect.fLastHop[puid].Length();
		if(lengthNew - lengthOld > ::SkillDetect.HOP_ACCEL_THRESH || lengthNew >= ::SkillDetect.ConfigVar.MinBHopKeepSpeed)
		{
			::SkillDetect.iHops[puid] += 1;
			
			if(lengthNew > ::SkillDetect.fHopTopVelocity[puid])
			{
				::SkillDetect.fHopTopVelocity[puid] <- lengthNew;
			}
		}
		else
		{
			::SkillDetect.bIsHopping[puid] <- false;
			
			if(::SkillDetect.iHops[puid] > 0)
			{
				::SkillDetect.HandleBHopStreak(player, ::SkillDetect.iHops[puid], ::SkillDetect.fHopTopVelocity[puid]);
				::SkillDetect.iHops[puid] <- 0;
			}
		}
	}
	
	::SkillDetect.fLastHop[puid] <- velocity;
	
	if(puid in ::SkillDetect.iHops && ::SkillDetect.iHops[puid] > 0)
	{
		Timers.AddTimerByName("skilldetect_bhop_" + puid,
			::SkillDetect.HOP_CHECK_TIME, true,
			::SkillDetect.Timer_CheckHop, player,
			0, { "action" : "once" }
		);
	}
}

function Notifications::OnJumpApex::SkillDetect(player, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsValid())
		return;
	
	local puid = player.GetUserID();
	
	if(puid in ::SkillDetect.bIsHopping && ::SkillDetect.bIsHopping[puid])
	{
		local velocity = player.GetVelocity();
		velocity.z = 0.0;
		
		local length = velocity.Length();
		if(length > ::SkillDetect.fHopTopVelocity[puid])
			::SkillDetect.fHopTopVelocity[puid] <- length;
	}
}

function Notifications::OnJockeyRideStart::SkillDetect(attacker, victim, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsValid() || !attacker.IsValid())
		return;
	
	local auid = attacker.GetUserID();
	
	::SkillDetect.fPinTime[auid][0] = Time();
	
	if(::SkillDetect.fPouncePosition[auid] == null)
		return;
	
	local endPos = attacker.GetLocation();
	local height = ::SkillDetect.fPouncePosition[auid].z - endPos.z;
	
	::SkillDetect.HandleJockeyDP(attacker, victim, height);
}

function Notifications::OnAbilityUsed::SkillDetect(player, ability, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsValid())
		return;
	
	local puid = player.GetUserID();
	
	::SkillDetect.bDeathChargeIgnore[puid] <- {};
	
	switch(ability)
	{
		case "ability_lunge":
		{
			::SkillDetect.ResetHunter(player, false);
			::SkillDetect.fPouncePosition[puid] <- player.GetLocation();
			break;
		}
		case "ability_vomit":
		{
			::SkillDetect.bBoomerLanded[puid] <- true;
			::SkillDetect.iBoomerVomitHits[puid] <- 0;
			::SkillDetect.fBoomerVomitStart[puid] <- Time();
			
			Timers.AddTimerByName("skilldetect_pop_" + puid,
				::SkillDetect.VOMIT_DURATION_TIME, false,
				::SkillDetect.Timer_BoomVomitCheck, player,
				0, { "action" : "reset" }
			);
			break;
		}
		case "ability_throw":
		{
			::SkillDetect.bRockHitSomebody[puid] <- false;
			break;
		}
	}
}

function Notifications::OnChargerCarryVictim::SkillDetect(attacker, victim, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsValid() || !attacker.IsValid())
		return;
	
	local auid = attacker.GetUserID();
	local vuid = victim.GetUserID();
	local time = Time();
	
	::SkillDetect.fChargeTime[auid] <- time;
	::SkillDetect.fPinTime[auid] <- [ time, 0.0 ];
	
	::SkillDetect.iChargeVictim[auid] <- vuid;
	::SkillDetect.iVictimCharger[vuid] <- auid;
	::SkillDetect.iVictimFlags[vuid] <- ::SkillDetect.VICFLG_CARRIED;
	::SkillDetect.fChargeTime[vuid] <- time;
	::SkillDetect.iVictimMapDmg[vuid] <- 0;
	::SkillDetect.fChargeVictimPos[vuid] <- victim.GetLocation();
	
	Timers.AddTimerByName("skilldetect_charge_" + auid,
		::SkillDetect.CHARGE_CHECK_TIME, true,
		::SkillDetect.Timer_ChargeCheck, victim,
		0, { "action" : "once" }
	);
}

function Notifications::OnChargerImpact::SkillDetect(attacker, victim, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsValid() || !attacker.IsValid())
		return;
	
	local vuid = victim.GetUserID();
	
	::SkillDetect.fChargeVictimPos[vuid] <- victim.GetLocation();
	::SkillDetect.iVictimCharger[vuid] <- attacker.GetUserID();
	::SkillDetect.iVictimFlags[vuid] <- 0;
	::SkillDetect.fChargeTime[vuid] <- Time();
	::SkillDetect.iVictimMapDmg[vuid] <- 0;
	
	Timers.AddTimerByName("skilldetect_charge_" + vuid,
		::SkillDetect.CHARGE_CHECK_TIME, true,
		::SkillDetect.Timer_ChargeCheck, victim,
		0, { "action" : "once" }
	);
}

function Notifications::OnChargerPummelBegin::SkillDetect(attacker, victim, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsValid() || !attacker.IsValid())
		return;
	
	local auid = attacker.GetUserID();
	::SkillDetect.fPinTime[auid][1] = Time();
}

function Notifications::OnChargerCarryVictimEnd::SkillDetect(attacker, victim, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsValid() || !attacker.IsValid())
		return;
	
	local auid = attacker.GetUserID();
	::SkillDetect.fPinTime[auid][1] = Time();
	
	Timers.AddTimerByName("skilldetect_carryend_" + auid, 0.1, false,
		::SkillDetect.Timer_ChargeCarryEnd, attacker,
		0, { "action" : "once" }
	);
}

function Notifications::OnPlayerVomited::SkillDetect(victim, attacker, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(!params["by_boomer"] || victim == null || attacker == null || !victim.IsValid() || !attacker.IsValid())
		return;
	
	local auid = attacker.GetUserID();
	
	::SkillDetect.bBoomerHitSomebody[auid] <- true;
	
	if(auid in ::SkillDetect.iBoomerVomitHits)
		::SkillDetect.iBoomerVomitHits[auid] += 1;
	else
		::SkillDetect.iBoomerVomitHits[auid] <- 1;
}

function Notifications::OnBoomerExploded::SkillDetect(victim, attacker, splashedbile, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsValid() || !attacker.IsValid())
		return;
	
	local auid = attacker.GetUserID();
	local vuid = victim.GetUserID();
	
	if(!splashedbile && !::SkillDetect.bBoomerHitSomebody[vuid] && ::SkillDetect.bBoomerNearSomebody[vuid])
	{
		local time = Time();
		::SkillDetect.HandlePop(attacker, victim,
			::SkillDetect.iBoomerGotShoved[vuid],
			time - ::SkillDetect.fSpawnTime[vuid],
			time - ::SkillDetect.fBoomerNearTime[vuid]
		);
	}
}

function Notifications::OnBoomerNear::SkillDetect(attacker, victim, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsValid() || !attacker.IsValid())
		return;
	
	local auid = attacker.GetUserID();
	
	::SkillDetect.bBoomerNearSomebody[auid] <- true;
	::SkillDetect.fBoomerNearTime[auid] <- Time();
}

function Notifications::OnWitchSpawned::SkillDetect(witch, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	local witchid = params["witchid"];
	if(witchid <= 0)
		return;
	
	::SkillDetect.iWitchAttacker[witchid] <- 0;
	::SkillDetect.iWitchState[witchid] <- 0;
	::SkillDetect.fWitchDamage[witchid] <- [[], []];
}

function Notifications::OnWitchStartled::SkillDetect(witch, attacker, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(attacker == null || !attacker.IsValid())
		return;
	
	local witchid = params["witchid"];
	if(witchid <= 0)
		return;
	
	local lastAttacker = ::SkillDetect.iWitchAttacker[witchid];
	local auid = attacker.GetUserID();
	
	if(lastAttacker <= 0)
	{
		// 无主妹子
		::SkillDetect.iWitchAttacker[witchid] = auid;
		::SkillDetect.iWitchState[witchid] = ::SkillDetect.iWitchState[witchid] | 8;
	}
	else if(lastAttacker != auid)
	{
		// 别人抢走了妹子
		::SkillDetect.iWitchState[witchid] = ::SkillDetect.iWitchState[witchid] | 12;
	}
	else
	{
		// 自己扰的妹子
		::SkillDetect.iWitchState[witchid] = ::SkillDetect.iWitchState[witchid] | 8;
	}
}

function Notifications::OnWitchKilled::SkillDetect(witch, attacker, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(params["witchid"] <= 0 || attacker == null || !attacker.IsValid())
		return;
	
	Timers.AddTimerByName("skilldetect_witchdeath_" + params["witchid"], 0.15, false,
		::SkillDetect.Timer_WitchDeath, { "witchid" : params["witchid"], "attacker" : attacker, "oneshot" : params["oneshot"] },
		0, { "action" : "once" }
	);
}

function Notifications::OnSmokerPullStopped::SkillDetect(attacker, victim, smoker, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || smoker == null || !victim.IsValid() || !attacker.IsValid() || !smoker.IsValid())
		return;
	
	local reason = params["release_type"];
	local auid = attacker.GetUserID();
	local suid = smoker.GetUserID();
	local time = Time();
	
	::SkillDetect.HandleClear(attacker, smoker, victim, Z_SMOKER,
		(::SkillDetect.fPinTime[suid][1] > 0.0 ? time - ::SkillDetect.fPinTime[suid][1] : -1.0),
		time - ::SkillDetect.fPinTime[suid][0],
		(reason != ::SkillDetect.CUT_SLASH && reason != ::SkillDetect.CUT_KILL)
	);
	
	if(auid != victim.GetUserID())
		return;
	
	if(reason == ::SkillDetect.CUT_KILL)
	{
		::SkillDetect.bSmokerClearCheck[suid] <- true;
	}
	else if(suid in ::SkillDetect.bSmokerShoved && ::SkillDetect.bSmokerShoved[suid])
	{
		::SkillDetect.HandleSmokerSelfClear(attacker, smoker, true);
	}
	else if(reason == ::SkillDetect.CUT_SLASH)
	{
		local weapon = attacker.GetActiveWeapon();
		if(weapon != null && weapon.IsValid() && weapon.GetClassname() == "weapon_melee")
		{
			::SkillDetect.HandleTongueCut(attacker, smoker);
		}
	}
}

function Notifications::OnSmokerTongueGrab::SkillDetect(attacker, victim, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsValid() || !attacker.IsValid())
		return;
	
	local auid = attacker.GetUserID();
	
	::SkillDetect.bSmokerClearCheck[auid] <- false;
	::SkillDetect.bSmokerShoved[auid] <- false;
	::SkillDetect.iSmokerVictim[auid] <- victim.GetUserID();
	::SkillDetect.iSmokerVictimDamage[auid] <- 0;
	::SkillDetect.fPinTime[auid] <- [ Time(), 0.0 ];
}

function Notifications::OnSmokerChokeBegin::SkillDetect(attacker, victim, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsValid() || !attacker.IsValid())
		return;
	
	local time = Time();
	local auid = attacker.GetUserID();
	
	if(::SkillDetect.fPinTime[auid][0] <= 0.0)
		::SkillDetect.fPinTime[auid][0] = time;
	::SkillDetect.fPinTime[auid][1] = time;
}

function Notifications::OnSmokerChokeStopped::SkillDetect(smoker, victim, attacker, params)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || smoker == null || !victim.IsValid() || !attacker.IsValid() || !smoker.IsValid())
		return;
	
	local reason = params["release_type"];
	local suid = smoker.GetUserID();
	local time = Time();
	
	::SkillDetect.HandleClear(attacker, smoker, victim, Z_SMOKER,
		(::SkillDetect.fPinTime[suid][1] > 0.0 ? time - ::SkillDetect.fPinTime[suid][1] : -1.0),
		time - ::SkillDetect.fPinTime[suid][0],
		( reason != ::SkillDetect.CUT_SLASH && reason != ::SkillDetect.CUT_KILL )
	);
}

function EasyLogic::OnTakeDamage::SkillDetect(dmgTable)
{
	if(!::SkillDetect.ConfigVar.Enable)
		return;
	
	if(dmgTable["Victim"] == null || dmgTable["DamageDone"] <= 0.0)
		return;
	
	local vuid = (dmgTable["Victim"].IsPlayer() ? dmgTable["Victim"].GetUserID() : null);
	
	if(vuid != null)
	{
		::SkillDetect.fPinTime[vuid] <- [0, 0];
	}
	
	switch(dmgTable["Victim"].GetType())
	{
		case Z_HUNTER:
		{
			if(dmgTable["Attacker"] != null)
			{
				local victim = dmgTable["Victim"].GetNetPropEntity("m_pounceVictim");
				if(victim != null && victim.IsValid())
					::SkillDetect.iSpecialVictim[vuid] <- victim.GetUserID();
				else
					::SkillDetect.iSpecialVictim[vuid] <- 0;
				
				if(dmgTable["Victim"].GetNetPropEntity("m_isAttemptingToPounce"))
				{
					::SkillDetect.fHunterTracePouncing[vuid] <- Time();
				}
				else
				{
					::SkillDetect.fHunterTracePouncing[vuid] <- 0.0;
				}
			}
			break;
		}
		case Z_CHARGER:
		{
			local victim = dmgTable["Victim"].GetNetPropEntity("m_carryVictim");
			if(victim != null && victim.IsValid())
			{
				::SkillDetect.iSpecialVictim[vuid] <- victim.GetUserID();
			}
			else
			{
				local victim = dmgTable["Victim"].GetNetPropEntity("m_pummelVictim");
				if(victim != null && victim.IsValid())
					::SkillDetect.iSpecialVictim[vuid] <- victim.GetUserID();
				else
					::SkillDetect.iSpecialVictim[vuid] <- 0;
			}
			
			break;
		}
		case Z_JOCKEY:
		{
			if(dmgTable["Attacker"] != null)
			{
				local victim = dmgTable["Victim"].GetNetPropEntity("m_jockeyVictim");
				if(victim != null && victim.IsValid())
					::SkillDetect.iSpecialVictim[vuid] <- victim.GetUserID();
				else
					::SkillDetect.iSpecialVictim[vuid] <- 0;
				
				if(::SkillDetect.IsJockeyLeaping(dmgTable["Victim"]))
				{
					::SkillDetect.fHunterTracePouncing[vuid] <- Time();
				}
				else
				{
					::SkillDetect.fHunterTracePouncing[vuid] <- 0.0;
				}
			}
			
			break;
		}
		case Z_WITCH:
		case Z_WITCH_BRIDE:
		{
			local witchid = dmgTable["Victim"].GetIndex();
			if(dmgTable["Attacker"] != null && dmgTable["Attacker"].IsSurvivor() && witchid in ::SkillDetect.iWitchAttacker)
			{
				local auid = dmgTable["Attacker"].GetUserID();
				local angry = (dmgTable["Victim"].GetNetPropFloat("m_rage") >= 1.0 ? 1 : 0);
				
				if(::SkillDetect.iWitchAttacker[witchid] <= 0)
				{
					// 认领妹子
					::SkillDetect.iWitchAttacker[witchid] = auid;
				}
				else if(::SkillDetect.iWitchAttacker[witchid] != auid)
				{
					// 抢妹子
					::SkillDetect.iWitchState[witchid] = ::SkillDetect.iWitchState[witchid] | 4;
				}
				
				if(dmgTable["DamageType"] & (DMG_CLUB|DMG_SLASH))
				{
					// 近战
					::SkillDetect.iWitchState[witchid] = ::SkillDetect.iWitchState[witchid] | 1;
					::SkillDetect.fWitchDamage[witchid][angry].append(dmgTable["DamageDone"]);
				}
				else if(dmgTable["DamageType"] & DMG_BUCKSHOT)
				{
					// 射击
					::SkillDetect.iWitchState[witchid] = ::SkillDetect.iWitchState[witchid] | 2;
					::SkillDetect.fWitchDamage[witchid][angry].append(dmgTable["DamageDone"]);
				}
				else
				{
					// 已经不算是秒妹了
					::SkillDetect.iWitchState[witchid] = ::SkillDetect.iWitchState[witchid] | 4;
				}
				
				if(angry)
				{
					// 已经被惊扰了
					::SkillDetect.iWitchState[witchid] = ::SkillDetect.iWitchState[witchid] | 8;
				}
			}
			break;
		}
		default:
		{
			local classname = dmgTable["Victim"].GetClassname();
			if(classname == "tank_rock" && dmgTable["Attacker"] != null && (dmgTable["DamageType"] & DMG_CLUB))
			{
				Timers.AddTimerByName("skilldetect_rock_" + dmgTable["Victim"].GetIndex(),
					::SkillDetect.ROCK_CHECK_TIME, false,
					::SkillDetect.Timer_CheckRockSkeet, { "attacker" : dmgTable["Attacker"], "tank" : dmgTable["Victim"].GetNetPropEntity("m_hThrower") },
					0, { "action" : "reset" }
				);
			}
			break;
		}
	}
}

/*
*********************************************
*				其他
*********************************************
*/

::SkillDetect.PLUGIN_NAME <- PLUGIN_NAME;
::SkillDetect.ConfigVar = ::SkillDetect.ConfigVarDef;

function Notifications::OnRoundStart::SkillDetect_LoadConfig()
{
	RestoreTable(::SkillDetect.PLUGIN_NAME, ::SkillDetect.ConfigVar);
	if(::SkillDetect.ConfigVar == null || ::SkillDetect.ConfigVar.len() <= 0)
		::SkillDetect.ConfigVar = FileIO.GetConfigOfFile(::SkillDetect.PLUGIN_NAME, ::SkillDetect.ConfigVarDef);

	// printl("[plugins] " + ::SkillDetect.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::SkillDetect_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::SkillDetect.PLUGIN_NAME, ::SkillDetect.ConfigVar);

	// printl("[plugins] " + ::SkillDetect.PLUGIN_NAME + " saving...");
}
