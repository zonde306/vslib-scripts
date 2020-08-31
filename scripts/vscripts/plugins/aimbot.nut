::Aimbot <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,
		
		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
		
		// 搜索目标间隔
		UpdateInterval = 0.3,
		
		// 攻击范围
		GunAttackRadius = 3000,
		
		// 攻击角度
		AttackFieldOfView = null,
		
		// 强制攻击间隔
		ForceAttackInterval = 0.1,
		
		// 距离过远时强制切换武器(如果当前为近战武器)
		FarSwitchWeapon = true,
		
		// 强制换主武器额外距离
		FarSwitchDistance = 75,
		
		// 是否将闲置的普感(未表现出攻击性)视为敌人
		IdleCommonAsEnemy = false,
		
		// 被攻击时强制反击(或许可以修复站着不动挨打)
		ForceCounterattack = true,
		
		// 对于单喷和慢速狙击使用打推
		AutoShotShove = true,
		
		// 防止救人时攻击
		PreventReviveStop = true,
	},

	ConfigVar = {},
	
	function CanAttack(player, weapon)
	{
		local time = Time();
		local clip = weapon.GetClip();	// -1 为无需弹药（如近战）
		local attack = player.GetNetPropFloat("m_flNextAttack");
		local primary = weapon.GetNetPropFloat("m_flNextPrimaryAttack");
		// local cycle = weapon.GetNetPropFloat("m_flCycle");
		// printl("bot " + player.GetName() + " wpn " + weapon.GetName() + " clip=" + clip + " na=" + attack + " npa=" + primary);
		return (primary <= time && attack <= time && clip != 0/* && cycle <= 0.0*/);
	},
	
	function UpdateRotation(angle, targetAngle, maxin = 360)
	{
		local value = targetAngle - angle % 360;

		if (value >= 180)
		{
			value -= 360;
		}

		if (value < -180)
		{
			value += 360;
		}
		
		if (value > maxin)
		{
			value = maxin;
		}

		if (value < -maxin)
		{
			value = -maxin;
		}
		
		value = angle + value;
		
		return value;
	},
	
	// 非玩家用
	function CalcAimForward(ent_self, ent_b)
	{
		if(ent_self != null && ent_self.IsValid() && ent_b != null)
		{
			local d0 = ent_b.GetOrigin().x - ent_self.GetOrigin().x;
			local d2 = ent_b.GetOrigin().y - ent_self.GetOrigin().y;
			local d1 = 0;
			
			if("GetEyePosition" in ent_self)
				d1 = ent_b.GetOrigin().z - ent_self.GetEyePosition().z + 50;
			else
				d1 = ent_b.GetOrigin().z - ent_self.GetOrigin().z;
			
			local d3 = sqrt(d0 * d0 + d2 * d2);
			local f = atan2(d2, d0) * (180 / PI) - 90;
			local f1 = -atan2(d1, d3) * (180 / PI);
			local rotationPitch = ::Aimbot.UpdateRotation(0, f1, 90);
			local rotationYaw = ::Aimbot.UpdateRotation(0, f);
			
			local qAn = QAngle(rotationPitch, rotationYaw, 0);
			return ::VSLib.Utils.VectorFromQAngle(qAn);
		}
		else if(ent_self != null && ent_self.IsValid() && "GetEyeAngles" in ent_self)
			return ::VSLib.Utils.VectorFromQAngle(ent_self.GetEyeAngles());
		
		return null;
	},
	
	// 玩家用
	function CalcAimForwardCorrect(ent_self, ent_b, height = 62)
	{
		if(ent_self != null && ent_self.IsAlive() && ent_b != null)
		{
			local d0 = ent_b.GetOrigin().x - ent_self.GetOrigin().x;
			local d2 = ent_b.GetOrigin().y - ent_self.GetOrigin().y;
			local d1 = 0;
			
			if(ent_b.IsDucking())
				height /= 2;
			
			if("GetEyePosition" in ent_b && "GetEyePosition" in ent_self )
				d1 = ent_b.GetEyePosition().z - ent_self.GetEyePosition().z;
			else if("GetEyePosition" in ent_self )
				d1 = ent_b.GetOrigin().z + height - ent_self.GetEyePosition().z;
			else if("GetEyePosition" in ent_b )
				d1 = ent_b.GetEyePosition().z - ent_self.GetOrigin().z + height ;
			else
				d1 = ent_b.GetOrigin().z + height - ent_self.GetEyePosition().z;
			
			local d3 = sqrt(d0 * d0 + d2 * d2);
			local f = atan2(d2, d0) * (180 / PI);
			local f1 = -atan2(d1, d3) * (180 / PI);
			local rotationPitch = ::Aimbot.UpdateRotation(0, f1, 90);
			local rotationYaw = ::Aimbot.UpdateRotation(0, f);
			
			local qAn = QAngle(rotationPitch, rotationYaw, 0);
			return ::VSLib.Utils.VectorFromQAngle(qAn);
		}
		else if(ent_self != null && ent_self.IsValid() && "GetEyeAngles" in ent_self)
			return ::VSLib.Utils.VectorFromQAngle(ent_self.GetEyeAngles());
		
		return null;
	},
	
	function GetEntityAbsOrigin(entity)
	{
		local origin = entity.GetOrigin();
		local mins = entity.GetNetPropVector("m_vecMins");
		local maxs = entity.GetNetPropVector("m_vecMaxs");
		
		origin.x += (mins.x + maxs.x) * 0.5;
		origin.y += (mins.y + maxs.y) * 0.5;
		origin.z += (mins.z + maxs.z) * 0.5;
		return origin;
	},
	
	function CanSeeTarget(attacker, victim)
	{
		local trace = {
			start = attacker.GetEyePosition(),
			end = victim.GetOrigin(),
			ignore = attacker.GetBaseEntity(),
			mask = TRACE_MASK_SHOT
		};
		
		if(::Aimbot.ConfigVar.AttackFieldOfView && !attacker.CanSeeLocation(trace.end, ::Aimbot.ConfigVar.AttackFieldOfView))
			return false;
		
		TraceLine(trace);
		
		if(!trace.hit || trace.enthit == attacker.GetBaseEntity())
			return false;
		
		return (trace.enthit == victim.GetBaseEntity() || trace.fraction > 0.97);
	},
	
	function FindEnemy(player, radius)
	{
		local target = null;
		local location = player.GetLocation();
		local minDistance = radius + 1;
		foreach(victim in Objects.OfClassnameWithin("player", location, radius))
		{
			// tank 短时间内打不死，可以先暂时忽略
			if(victim.IsSurvivor() || victim.GetType() == Z_TANK || victim.GetRawHealth() <= 0 || !::Aimbot.CanSeeTarget(player, victim))
				continue;
			
			local distance = Utils.CalculateDistance(location, victim.GetLocation());
			if(distance < minDistance)
			{
				minDistance = distance;
				target = victim;
			}
		}
		
		if(target)
			return target;
		
		foreach(victim in Objects.OfClassnameWithin("witch", location, radius))
		{
			if(victim.GetNetPropFloat("m_rage") < 1.0 || victim.GetRawHealth() <= 0 || !::Aimbot.CanSeeTarget(player, victim))
				continue;
			
			local distance = Utils.CalculateDistance(location, victim.GetLocation());
			if(distance < minDistance)
			{
				minDistance = distance;
				target = victim;
			}
		}
		
		if(target)
			return target;
		
		foreach(victim in Objects.OfClassnameWithin("infected", location, radius))
		{
			if(victim.GetNetPropBool("m_bIsBurning") || !victim.GetNetPropBool("m_mobRush") || victim.GetRawHealth() <= 0 || !::Aimbot.CanSeeTarget(player, victim))
				continue;
			
			local distance = Utils.CalculateDistance(location, victim.GetLocation());
			if(distance < minDistance)
			{
				minDistance = distance;
				target = victim;
			}
		}
		
		if(target)
			return target;
		
		return null;
	},
	
	function IsValidEnemy(entity)
	{
		if(entity == null || !entity.IsValid())
			return false;
		
		switch(entity.GetType())
		{
			case Z_SMOKER:
			case Z_BOOMER:
			case Z_HUNTER:
			case Z_SPITTER:
			case Z_JOCKEY:
			case Z_CHARGER:
			{
				return (entity.IsAlive() && !entity.IsGhost());
			}
			case Z_TANK:
			{
				return (entity.IsAlive() && !entity.IsGhost() && !entity.GetNetPropBool("m_isIncapacitated"));
			}
			case Z_INFECTED:
			case Z_COMMON:
			case Z_MOB:
			{
				if(::Aimbot.ConfigVar.IdleCommonAsEnemy)
					return (entity.IsAlive() && !entity.GetNetPropBool("m_bIsBurning"));
				
				return (entity.IsAlive() && !entity.GetNetPropBool("m_bIsBurning") && entity.GetNetPropBool("m_mobRush"));
			}
			case Z_WITCH:
			case Z_WITCH_BRIDE:
			{
				return (entity.IsAlive() && entity.GetNetPropFloat("m_rage") >= 1.0);
			}
		}
		
		return false;
	},
	
	function SwitchToGun(player)
	{
		local inv = player.GetHeldItems();
		if(inv && "slot0" in inv && inv["slot0"] != null && inv["slot0"].IsValid() &&
			(player.GetPrimaryAmmo() > 0 || player.GetPrimaryClip() > 0))
		{
			player.SetNetPropEntity("m_hActiveWeapon", inv["slot0"]);
			player.GetViewModel().SetNetPropInt("m_nSequence", 0);
			
			if(inv["slot0"].GetClip() != 0)
			{
				player.SetNetPropFloat("m_flNextAttack", Time());
				inv["slot0"].SetNetPropFloat("m_flNextPrimaryAttack", Time());
				inv["slot0"].SetNetPropFloat("m_flNextSecondaryAttack", Time());
				inv["slot0"].SetNetPropInt("m_nSequence", 0);
				inv["slot0"].SetNetPropFloat("m_flCycle", 0.0);
			}
		}
	},
	
	function Timer_ScanEnemy(params)
	{
		foreach(player in Players.AliveSurvivorBots())
		{
			local weapon = player.GetActiveWeapon();
			if(weapon == null || !weapon.IsValid() || player.GetCurrentAttacker() != null ||
				player.IsHangingFromLedge() || player.GetNetPropEntity("m_reviveTarget") ||
				player.GetNetPropBool("m_usingMountedGun") || player.GetNetPropBool("m_usingMountedWeapon"))
			{
				player.UnforceButton(BUTTON_ATTACK);
				player.UnforceButton(BUTTON_SHOVE);
				// Timers.RemoveTimerByName("timer_rapid_fire_" + player.GetIndex());
				continue;
			}
			
			if(!::Aimbot.CanAttack(player, weapon))
			{
				player.UnforceButton(BUTTON_ATTACK);
				// Timers.RemoveTimerByName("timer_rapid_fire_" + player.GetIndex());
				::Aimbot.HandleShove(player, ::Aimbot.ConfigVar.UpdateInterval);
				// printl("bot " + player.GetName() + " can't attack");
			}
			else if(Utils.IsValidFireWeapon(weapon.GetClassname()))
			{
				player.UnforceButton(BUTTON_SHOVE);
				::Aimbot.HandleGunShot(player, ::Aimbot.ConfigVar.UpdateInterval);
				// printl("bot " + player.GetName() + " can shot");
			}
			else if(Utils.IsValidMeleeWeapon(weapon.GetClassname()))
			{
				player.UnforceButton(BUTTON_SHOVE);
				if(!::Aimbot.HandleMeleeAttack(player, ::Aimbot.ConfigVar.UpdateInterval))
					::Aimbot.SwitchToGun(player);
				// printl("bot " + player.GetName() + " can hack");
			}
			else
			{
				player.UnforceButton(BUTTON_ATTACK);
				player.UnforceButton(BUTTON_SHOVE);
				// Timers.RemoveTimerByName("timer_rapid_fire_" + player.GetIndex());
				// printl("bot " + player.GetName() + " idle");
			}
		}
	},
	
	function Timer_Trigger(params)
	{
		local forceAttack = false;
		local meleeRange = Convars.GetFloat("melee_range") + ::Aimbot.ConfigVar.FarSwitchDistance;
		
		foreach(player in Players.AliveSurvivorBots())
		{
			local weapon = player.GetActiveWeapon();
			if(player.GetCurrentAttacker() != null || player.IsHangingFromLedge() || player.GetNetPropEntity("m_reviveTarget") != null ||
				player.GetNetPropBool("m_usingMountedGun") || player.GetNetPropBool("m_usingMountedWeapon"))
				continue;
			
			if(!::Aimbot.CanAttack(player, weapon))
				continue;
			
			local target = player.GetLookingEntity(TRACE_MASK_SHOT);
			if(!::Aimbot.IsValidEnemy(target))
				continue;
			
			if(::Aimbot.ConfigVar.FarSwitchWeapon)
			{
				local weapon = player.GetActiveWeapon();
				if((weapon == null || weapon.GetClassname() == "weapon_melee") &&
					(player.GetPrimaryAmmo() > 0 || player.GetPrimaryClip() > 0) &&
					Utils.GetDistBetweenEntities(player, target) > meleeRange)
				{
					local inv = player.GetHeldItems();
					if(inv && "slot0" in inv && inv["slot0"] != null && inv["slot0"].IsValid())
					{
						// 快速切换武器
						player.SetNetPropEntity("m_hActiveWeapon", inv["slot0"]);
						player.GetViewModel().SetNetPropInt("m_nSequence", 0);
						
						// 没效果...
						// player.Input("Use", inv["slot0"].GetClassname(), 0, player);
						// player.ClientCommand("use " + inv["slot0"].GetClassname());
						// printl("bot " + player.GetName() + " use " + inv["slot0"].GetClassname());
					}
				}
			}
			
			/*
			if(target.GetType() == Z_WITCH || target.GetType() == Z_WITCH_BRIDE)
			{
				// 不要随意攻击 witch
				forceAttack = false;
				break;
			}
			*/
			
			forceAttack = true;
		}
		
		if(forceAttack)
			Convars.SetValue("sb_open_fire", "1");
		else
			Convars.SetValue("sb_open_fire", "0");
	},
	
	function Timer_ShoveReset(player)
	{
		if(player.IsSurvivor())
			player.UnforceButton(BUTTON_SHOVE);
	},
	
	function Timer_ShotReset(player)
	{
		if(player.IsSurvivor())
			player.UnforceButton(BUTTON_ATTACK);
	},
	
	function ForceShove(player, duration = 0.3)
	{
		/*
		if(player.IsIncapacitated() || player.GetCurrentAttacker() != null || player.GetActiveWeapon() == null)
			return false;
		*/
		
		player.ForceButton(BUTTON_SHOVE);
		Timers.AddTimerByName("timer_shove_stop_" + player.GetIndex(), duration, false, ::Aimbot.Timer_ShoveReset, player, 0, { "action" : "reset" });
	},
	
	function ForceShot(player, duration = 0.3)
	{
		player.ForceButton(BUTTON_ATTACK);
		Timers.AddTimerByName("timer_shot_stop_" + player.GetIndex(), duration, false, ::Aimbot.Timer_ShotReset, player, 0, { "action" : "reset" });
	},
	
	function Timer_RapidFire(player)
	{
		if(!player.IsSurvivor())
			return false;
		
		local weapon = player.GetActiveWeapon();
		if(weapon == null || !weapon.IsValid())
			return;
		
		if(weapon.HasNetProp("m_iShotsFired"))
			weapon.SetNetPropInt("m_iShotsFired", 0);
		if(weapon.HasNetProp("m_isHoldingFireButton"))
			weapon.SetNetPropInt("m_isHoldingFireButton", 0);
		player.SetNetPropVector("m_vecPunchAngle", Vector(0, 0, 0));
		player.SetNetPropVector("m_vecPunchAngleVel", Vector(0, 0, 0));
	},
	
	function HandleGunShot(player, duration = null)
	{
		local target = ::Aimbot.FindEnemy(player, ::Aimbot.ConfigVar.GunAttackRadius);
		if(target)
		{
			local aim = ::Aimbot.CalcAimForwardCorrect(player, target);
			if(aim != null)
			{
				player.SetForwardVector(aim);
				player.ForceButton(BUTTON_ATTACK);
				// Timers.AddTimerByName("timer_rapid_fire_" + player.GetIndex(), 0.1, true, ::Aimbot.Timer_RapidFire, player, 0, { "action" : "once" });
				
				// 应该不会和躲避危险冲突吧（大概
				if(!player.GetTarget())
					player.BotAttack(target, true, true);
				
				printl("bot " + player.GetName() + " attack " + target.GetName());
				return true;
			}
			
			// printl("bot " + player.GetName() + " enemy is " + target.GetName() + ", but can't aiming");
		}
		
		/*
		if(duration)
			Timers.AddTimerByName("timer_stop_fire_" + player.GetIndex(), duration, false, ::Aimbot.Timer_ShotReset, player, 0, { "action" : "once" });
		*/
		
		player.UnforceButton(BUTTON_ATTACK);
		// printl("bot " + player.GetName() + " notarget");
		return false;
	},
	
	function HandleMeleeAttack(player, duration = null)
	{
		local target = ::Aimbot.FindEnemy(player, Convars.GetFloat("melee_range"));
		if(target)
		{
			local aim = ::Aimbot.CalcAimForwardCorrect(player, target);
			if(aim != null)
			{
				player.SetForwardVector(aim);
				player.ForceButton(BUTTON_ATTACK);
				
				// 应该不会和躲避危险冲突吧（大概
				if(!player.GetTarget())
					player.BotAttack(target, true, true);
				
				// printl("bot " + player.GetName() + " hack " + target.GetName());
				return true;
			}
			
			// printl("bot " + player.GetName() + " enemy is " + target.GetName() + ", but can't aiming");
		}
		
		/*
		if(duration)
			Timers.AddTimerByName("timer_stop_fire_" + player.GetIndex(), duration, false, ::Aimbot.Timer_ShotReset, player, 0, { "action" : "once" });
		*/
		
		player.UnforceButton(BUTTON_ATTACK);
		// printl("bot " + player.GetName() + " notarget");
		return false;
	},
	
	function HandleShove(player, duration = 0.3)
	{
		local weapon = player.GetActiveWeapon();
		if(weapon == null || weapon.GetNetPropFloat("m_flNextSecondaryAttack") > Time())
			return;
		
		local target = ::Aimbot.FindEnemy(player, Convars.GetFloat("z_gun_range"));
		if(target)
		{
			local aim = ::Aimbot.CalcAimForwardCorrect(player, target);
			if(aim != null)
			{
				player.SetForwardVector(aim);
				::Aimbot.ForceShove(player, duration);
				
				// 应该不会和躲避危险冲突吧（大概
				if(!player.GetTarget())
					player.BotAttack(target, true, true);
				
				// printl("bot " + player.GetName() + " shove " + target.GetName());
				return true;
			}
			
			// printl("bot " + player.GetName() + " enemy is " + target.GetName() + ", but can't aiming");
		}
		
		// printl("bot " + player.GetName() + " notarget");
		return false;
	},
};

function Notifications::OnWeaponFire::Aimbot_RapidFire(player, classname, params)
{
	if(!::Aimbot.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsSurvivor() || !player.IsBot())
		return;
	
	Timers.AddTimerByName("timer_rapid_fire_" + player.GetIndex(), 0.1, false, ::Aimbot.Timer_RapidFire, player, 0, { "action" : "once" });
	
	if(::Aimbot.ConfigVar.AutoShotShove)
	{
		classname = classname.tolower();
		if(classname == "weapon_pumpshotgun" || classname == "weapon_shotgun_chrome" ||
			classname == "weapon_sniper_scout" || classname == "weapon_sniper_awp")
			::Aimbot.ForceShove(player, 0.1);
	}
}

function Notifications::OnWeaponReload::Aimbot_StopFire(player, manual, params)
{
	if(!::Aimbot.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsSurvivor() || !player.IsBot())
		return;
	
	player.UnforceButton(BUTTON_ATTACK);
	player.UnforceButton(BUTTON_SHOVE);
}

function Notifications::OnHurt::Aimbot_ForceCounterattack(victim, attacker, params)
{
	if(!::Aimbot.ConfigVar.Enable || !::Aimbot.ConfigVar.ForceCounterattack)
		return;
	
	if(victim == null || attacker == null || !victim.IsSurvivor() || !victim.IsBot() ||
		attacker.GetTeam() == victim.GetTeam() || !attacker.IsAlive() || victim.IsInCombat() ||
		victim.GetNetPropEntity("m_reviveTarget") != null)
		return;
	
	victim.BotReset();
	victim.BotAttack(attacker, true, true);
}

function Notifications::OnReviveBegin::Aimbot_PreventForceAttack(revivee, revivor, params)
{
	if(!::Aimbot.ConfigVar.Enable || !::Aimbot.ConfigVar.PreventReviveStop)
		return;
	
	if(revivee == null || revivor == null || !revivee.IsSurvivor() || !revivor.IsSurvivor() || revivee.IsDead() || revivor.IsDead())
		return;
	
	if(revivee.GetIndex() == revivor.GetIndex() || !revivor.IsBot())
		return;
	
	revivor.UnforceButton(BUTTON_ATTACK);
	// revivor.UnforceButton(BUTTON_SHOVE);
	revivor.DisableButton(BUTTON_ATTACK);
	// revivor.DisableButton(BUTTON_SHOVE);
}

function Notifications::OnReviveEnd::Aimbot_PreventForceAttack(revivee, revivor, params)
{
	if(!::Aimbot.ConfigVar.Enable)
		return;
	
	if(revivor == null || !revivor.IsSurvivor())
		return;
	
	revivor.EnableButton(BUTTON_ATTACK);
	revivor.EnableButton(BUTTON_SHOVE);
}

function Notifications::OnReviveSuccess::Aimbot_PreventForceAttack(revivee, revivor, params)
{
	if(!::Aimbot.ConfigVar.Enable)
		return;
	
	if(revivor == null || !revivor.IsSurvivor())
		return;
	
	revivor.EnableButton(BUTTON_ATTACK);
	revivor.EnableButton(BUTTON_SHOVE);
}

function Notifications::OnRoundBegin::Aimbot(params)
{
	// Timers.AddTimerByName("timer_aimbot", ::Aimbot.ConfigVar.UpdateInterval, true, ::Aimbot.Timer_ScanEnemy);
	Timers.AddTimerByName("timer_triggerbot", ::Aimbot.ConfigVar.ForceAttackInterval, true, ::Aimbot.Timer_Trigger);
}

function Notifications::FirstSurvLeftStartArea::Aimbot(player, params)
{
	// Timers.AddTimerByName("timer_aimbot", ::Aimbot.ConfigVar.UpdateInterval, true, ::Aimbot.Timer_ScanEnemy);
	Timers.AddTimerByName("timer_triggerbot", ::Aimbot.ConfigVar.ForceAttackInterval, true, ::Aimbot.Timer_Trigger);
}

::Aimbot.PLUGIN_NAME <- PLUGIN_NAME;
::Aimbot.ConfigVar = ::Aimbot.ConfigVarDef;

function Notifications::OnRoundStart::Aimbot_LoadConfig()
{
	RestoreTable(::Aimbot.PLUGIN_NAME, ::Aimbot.ConfigVar);
	if(::Aimbot.ConfigVar == null || ::Aimbot.ConfigVar.len() <= 0)
		::Aimbot.ConfigVar = FileIO.GetConfigOfFile(::Aimbot.PLUGIN_NAME, ::Aimbot.ConfigVarDef);

	// printl("[plugins] " + ::Aimbot.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::Aimbot_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::Aimbot.PLUGIN_NAME, ::Aimbot.ConfigVar);

	// printl("[plugins] " + ::Aimbot.PLUGIN_NAME + " saving...");
}
