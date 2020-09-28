::SelfHelp <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = false,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 7,

		// 允许用作自救的物品.1=包.2=药.4=针
		AllowItem = 7,

		// 可以自救的开始延迟
		StartDelay = 1,

		// 自救需要的时间
		Duration = 3,

		// 自救是否杀死控制者
		KillAttacker = true,

		// 倒地后可以拣的东西.1=包.2=药.4=针.8=手枪.16=马格南.32=土雷.64=火瓶.128=胆汁
		IncapPickup = 255,

		// 是否可以给倒地的队友递药/针
		GivePills = true,

		// 被队友救时是否中断自救
		OtherStopped = false,

		// 是否允许机器人自救
		BotSupport = true,

		// 是否允许救别人
		HelpOther = true,

		// 救别人的最大距离
		HelpOtherDistance = 75,

		// 在什么情况下允许自救.1=倒地.2=挂边.4=被猴骑.8=被猎人扑.16=被舌头拉.32=被牛锤地
		AllowStatus = 63,

		// 倒地拣东西的范围
		PickupRadius = 100,

		// 自救完成后推开周围特感的范围
		SpecialStagger = 175,

		// 自救完成后点燃附近的普感的范围
		CommonIgnite = 225,

		// 自救完成的无敌时间
		GodTime = 3.0
	},

	ConfigVar = {},

	HasFirstStart = {},
	CurrentStatus = {},
	CurrentTime = {},
	CurrentOther = {},
	GodModeTime = {},
	
	// 玩家(生还者)是否需要帮助(是否倒地/挂边/被控)
	function IsNeedHelp(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead())
			return false;
		
		if(player.IsIncapacitated() || player.IsHangingFromLedge() || player.IsHangingFromTongue() ||
			player.IsBeingJockeyed() || player.IsPounceVictim() || player.IsTongueVictim() ||
			player.IsCarryVictim() || player.IsPummelVictim())
			return true;
		
		return false;
	},
	
	// 获取可以用作自救的物品，无法自救返回 0
	function GetCanSelfhelpItem(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.GetTeam() != SURVIVORS || player.IsDead())
			return 0;
		
		// 检查被控和挂边
		if(player.IsHangingFromLedge() && !(::SelfHelp.ConfigVar.AllowStatus & 2) ||
			player.IsBeingJockeyed() && !(::SelfHelp.ConfigVar.AllowStatus & 4) ||
			player.IsPounceVictim() && !(::SelfHelp.ConfigVar.AllowStatus & 8) ||
			player.IsTongueVictim() && !(::SelfHelp.ConfigVar.AllowStatus & 16) ||
			player.IsPummelVictim() && !(::SelfHelp.ConfigVar.AllowStatus & 32))
			return 0;
		
		// 检查倒地
		if(player.IsIncapacitated() && !(::SelfHelp.ConfigVar.AllowStatus & 1))
			return 0;
		
		local inv = player.GetHeldItems();
		
		// 优先选择 药/针
		if("slot4" in inv && inv["slot4"] != null && inv["slot4"].IsEntityValid())
		{
			if((::SelfHelp.ConfigVar.AllowItem & 2) && inv["slot4"].GetClassname() == "weapon_pain_pills")
				return 2;
			if((::SelfHelp.ConfigVar.AllowItem & 4) && inv["slot4"].GetClassname() == "weapon_adrenaline")
				return 4;
		}
		
		// 没有就选择包
		if("slot3" in inv && inv["slot3"] != null && inv["slot3"].IsEntityValid())
		{
			if((::SelfHelp.ConfigVar.AllowItem & 1) && inv["slot3"].GetClassname() == "weapon_first_aid_kit")
				return 1;
		}
		
		return 0;
	},
	
	// 尝试开始自救计时，失败(玩家无效/已经开始过了)返回 false
	function StartSelfhelpTimer(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.GetTeam() != SURVIVORS || player.IsDead())
			return false;
		
		if(player.IsBot() && ::SelfHelp.ConfigVar.BotSupport)
			player.ForceButton(BUTTON_DUCK);
		
		local index = player.GetIndex();
		if(index in ::SelfHelp.CurrentStatus && ::SelfHelp.CurrentStatus[index] >= 1)
			return false;
		
		::SelfHelp.CurrentStatus[index] <- 1;
		::SelfHelp.HasFirstStart[index] <- true;
		::SelfHelp.CurrentTime[index] <- Time() + ::SelfHelp.ConfigVar.StartDelay;
		::SelfHelp.CurrentOther[index] <- null;
		::SelfHelp.SetProgressBarTime(player);
		
		return true;
	},
	
	// 尝试停止自救计时，失败(玩家无效/已经结束了)返回 false
	function StopSelfhelpTimer(player)
	{
		if(player == null || !player.IsPlayerEntityValid())
			return false;
		
		if(player.IsBot() && ::SelfHelp.ConfigVar.BotSupport)
			player.UnforceButton(BUTTON_DUCK);
		
		local index = player.GetIndex();
		if(!(index in ::SelfHelp.CurrentStatus) || ::SelfHelp.CurrentStatus[index] < 1)
			return false;
		
		::SelfHelp.CurrentStatus[index] <- 0;
		::SelfHelp.HasFirstStart[index] <- false;
		::SelfHelp.CurrentTime[index] <- Time();
		::SelfHelp.CurrentOther[index] <- null;
		::SelfHelp.SetProgressBarTime(player);
		
		return true;
	},
	
	// 设置进度条
	function SetProgressBarTime(player, time = 0.0)
	{
		if(player == null || !player.IsPlayerEntityValid())
			return;
		
		player.SetNetPropFloat("m_flProgressBarStartTime", Time());
		player.SetNetPropFloat("m_flProgressBarDuration", time);
	},
	
	// 救起生还者
	function RevivePlayerOfSelfhelp(player, from = null, reviveMode = 0)
	{
		if(!::SelfHelp.IsNeedHelp(player))
			return false;
		
		local attacker = player.GetCurrentAttacker();
		if(attacker != null)
		{
			if(::SelfHelp.ConfigVar.KillAttacker)
				attacker.Kill(DMG_GENERIC, player);
			else
				attacker.StaggerAwayFromEntity(player);
		}
		
		local ledge = player.IsHangingFromLedge();
		if(player.IsIncapacitated() || ledge)
			player.Revive();
		
		switch(reviveMode)
		{
			case 1:
				player.Remove("weapon_first_aid_kit");
				player.SetRawHealth(1);
				// player.SetHealthBuffer(Convars.GetFloat("first_aid_heal_percent") * 100);
				player.SetHealthBuffer(80);
				break;
			case 2:
				player.Remove("weapon_pain_pills");
				player.SetRawHealth(1);
				// player.SetHealthBuffer(Convars.GetFloat("pain_pills_health_value"));
				player.SetHealthBuffer(50);
				break;
			case 4:
				player.Remove("weapon_adrenaline");
				player.SetRawHealth(1);
				// player.SetHealthBuffer(Convars.GetFloat("adrenaline_health_buffer"));
				player.SetHealthBuffer(30);
				break;
		}
		
		/*
		if(from != null && from.IsPlayerEntityValid())
		{
			FireGameEvent("revive_success",
				{userid = from.GetUserID(), subject = player.GetUserID(), ledge_hang = ledge});
		}
		*/
		
		local position = player.GetLocation();
		if(::SelfHelp.ConfigVar.SpecialStagger > 0)
		{
			foreach(victim in Objects.OfClassnameWithin("player", position, ::SelfHelp.ConfigVar.SpecialStagger))
			{
				if(victim.IsPlayer() && victim.GetTeam() == INFECTED && victim.IsAlive())
					victim.StaggerAwayFromLocation(position);
			}
		}
		
		if(::SelfHelp.ConfigVar.CommonIgnite > 0)
		{
			foreach(victim in Objects.OfClassnameWithin("infected", position, ::SelfHelp.ConfigVar.SpecialStagger))
			{
				if(victim.IsAlive() && !victim.IsOnFire())
					victim.Damage(1, DMG_BURN, player);
			}
		}
		
		if(::SelfHelp.ConfigVar.GodTime > 0)
			::SelfHelp.GodModeTime[player.GetIndex()] <- Time() + ::SelfHelp.ConfigVar.GodTime;
	},
	
	function TimerSelfhelp_OnPlayerThink(params)
	{
		if(!::SelfHelp.ConfigVar.Enable)
		{
			// 清理自救进度条
			foreach(index, status in ::SelfHelp.CurrentStatus)
			{
				local player = ::VSLib.Player(index);
				if(player == null || !player.IsPlayerEntityValid())
					continue;
				
				::SelfHelp.SetProgressBarTime(player);
			}
			
			// 清理被救进度条
			foreach(index, player in ::SelfHelp.CurrentOther)
			{
				if(player == null || !player.IsPlayerEntityValid())
					continue;
				
				::SelfHelp.SetProgressBarTime(player);
			}
			
			// 清理保存的东西
			::SelfHelp.CurrentStatus.clear();
			::SelfHelp.HasFirstStart.clear();
			::SelfHelp.CurrentTime.clear();
			::SelfHelp.CurrentOther.clear();
			
			return;
		}
		
		local time = Time();
		foreach(player in Players.AliveSurvivors())
		{
			if(!::SelfHelp.IsNeedHelp(player))
			{
				::SelfHelp.StopSelfhelpTimer(player);
				continue;
			}
			
			if(::SelfHelp.StartSelfhelpTimer(player))
			{
				// 开始允许自救计时
				printl("start player " + player.GetName() + " allow selfhelp timer");
				continue;
			}
			
			local index = player.GetIndex();
			if(::SelfHelp.CurrentStatus[index] == 1)
			{
				// 正在进行开始计时
				if(::SelfHelp.CurrentTime[index] > time)
					continue;
			}
			
			local reviveMode = ::SelfHelp.GetCanSelfhelpItem(player);
			
			if(!player.IsPressingDuck())
			{
				// 取消自救/救队友
				if(::SelfHelp.CurrentStatus[index] > 1)
				{
					// 正在进行自救/救队友
					::SelfHelp.CurrentStatus[index] <- 1;
					::SelfHelp.CurrentTime[index] <- 0;
					::SelfHelp.SetProgressBarTime(player);
					
					if(::SelfHelp.CurrentOther[index] != null && ::SelfHelp.CurrentOther[index].IsPlayerEntityValid())
						::SelfHelp.SetProgressBarTime(::SelfHelp.CurrentOther[index]);
					
					::SelfHelp.CurrentOther[index] <- null;
					
					if(!player.IsBot())
						printl("player " + player.GetName() + " selfhelp stopped");
				}
				else if(::SelfHelp.CurrentStatus[index] == 1 && ::SelfHelp.HasFirstStart[index])
				{
					::SelfHelp.HasFirstStart[index] = false;
					
					if(reviveMode > 0)
						player.ShowHint("Hold down CTRL self-help", 9, "use_binding", "duck");
				}
				
				continue;
			}
			
			if(reviveMode > 0)
			{
				// 允许自救，则进行自救
				if(::SelfHelp.CurrentStatus[index] == 1)
				{
					// 现在开始自救计时
					::SelfHelp.CurrentStatus[index] <- 2;
					::SelfHelp.CurrentTime[index] <- time + ::SelfHelp.ConfigVar.Duration;
					::SelfHelp.SetProgressBarTime(player, ::SelfHelp.ConfigVar.Duration);
					
					// FireGameEvent("revive_begin", {userid = player.GetUserID(), subject = player.GetUserID()});
					
					if(!player.IsBot())
						printl("player " + player.GetName() + " selfhelp starting");
				}
				else if(::SelfHelp.CurrentStatus[index] == 2 && ::SelfHelp.CurrentTime[index] <= time)
				{
					// 玩家自救计时完成
					::SelfHelp.RevivePlayerOfSelfhelp(player, null, reviveMode);
					::SelfHelp.StopSelfhelpTimer(player);
					
					/*
					FireGameEvent("revive_success", {userid = player.GetUserID(), subject = player.GetUserID(),
						lastlife = false, ledge_hang = false});
					*/
					
					player.PlaySoundEx("level/gnomeftw.wav");
					printl("player " + player.GetName() + " selfhelp success");
				}
				
				continue;
			}
			
			// 无法自救，尝试捡东西用于自救
			if(::SelfHelp.ConfigVar.IncapPickup != 0)
			{
				// 玩家拣东西
				local pos = player.GetLocation();
				local pickuped = false;
				
				local canPickup = 0;
				local inv = player.GetHeldItems();
				if("slot1" in inv && inv["slot1"] != null && inv["slot1"].IsEntityValid())
				{
					local classname = inv["slot1"].GetClassname();
					if(classname == "weapon_pistol")
					{
						// 小手枪时可以升级成马格南
						canPickup = canPickup | 16;
						
						// 单手枪时可以升级成双手枪
						if(!inv["slot1"].GetNetPropBool("m_hasDualWeapons"))
							canPickup = canPickup | 8;
					}
				}
				
				// 没有投掷武器时可以捡一个投掷武器，各类投掷武器都可以在倒地时有帮助
				// 当然，需要开启倒地丢手雷的功能
				if(!("slot2" in inv) || inv["slot2"] == null || !inv["slot2"].IsEntityValid())
					canPickup = canPickup | 32 | 64 | 128;
				
				// 尝试捡一个包
				if("slot3" in inv && inv["slot3"] != null && inv["slot3"].IsEntityValid())
				{
					local classname = inv["slot1"].GetClassname();
					
					// 医疗包可以用于自救，非医疗包是不能自救的
					if(classname != "weapon_first_aid_kit")
						canPickup = canPickup | 1;
				}
				else
					canPickup = canPickup | 1;
				
				// 寻找一瓶药或一根针
				if(!("slot4" in inv) || inv["slot4"] == null || !inv["slot4"].IsEntityValid())
					canPickup = canPickup | 2 | 4;
				
				// 将禁止拾取的东西去除
				canPickup = canPickup & ::SelfHelp.ConfigVar.IncapPickup;
				
				foreach(entity in Objects.AroundRadius(pos, ::SelfHelp.ConfigVar.PickupRadius))
				{
					local classname = entity.GetClassname();
					if(classname.find("weapon_") != 0 || entity.GetOwnerEntity() != null)
						continue;
					
					classname = Utils.StringReplace(classname, "_spawn", "");
					
					if(classname == "weapon_pistol_magnum" && (canPickup & 16) ||
						classname == "weapon_pistol" && (canPickup & 8) ||
						classname == "weapon_first_aid_kit" && (canPickup & 1) ||
						classname == "weapon_pain_pills" && (canPickup & 2) ||
						classname == "weapon_adrenaline" && (canPickup & 4))
					{
						entity.Input("Use", "", 0, player);
						pickuped = true;
						
						player.PlaySoundEx("ui/alert_clink.wav");
						printl("player " + player.GetName() + " incap pickup " + classname);
						break;
					}
				}
				
				// 捡到东西了，不能再去救队友
				if(pickuped)
					continue;
			}
			
			// 捡不到任何东西，尝试救队友
			if(::SelfHelp.ConfigVar.HelpOther)
			{
				// 玩家救其他队友
				local pos = player.GetLocation();
				if(::SelfHelp.CurrentStatus[index] == 1)
				{
					// 寻找一个可以救助的队友
					foreach(other in Objects.OfClassnameWithin("player", pos, ::SelfHelp.ConfigVar.HelpOtherDistance))
					{
						if(other.GetTeam() != SURVIVORS || other == player || !::SelfHelp.IsNeedHelp(other) ||
							other.GetSurvivorCharacter() == player.GetSurvivorCharacter() ||
							Utils.CalculateDistance(pos, other.GetLocation()) > ::SelfHelp.ConfigVar.HelpOtherDistance)
							continue;
						
						local checked = false;
						foreach(idx, othee in ::SelfHelp.CurrentOther)
						{
							if(othee != null && othee == other)
							{
								checked = true;
								break;
							}
						}
						
						if(checked)
							continue;
						
						::SelfHelp.CurrentStatus[index] <- 3;
						::SelfHelp.CurrentTime[index] <- time + ::SelfHelp.ConfigVar.Duration;
						::SelfHelp.CurrentOther[index] <- other;
						
						// 给双方都显示救助进度条
						::SelfHelp.SetProgressBarTime(player, ::SelfHelp.ConfigVar.Duration);
						::SelfHelp.SetProgressBarTime(other, ::SelfHelp.ConfigVar.Duration);
						
						// FireGameEvent("revive_begin", {userid = player.GetUserID(), subject = other.GetUserID()});
						
						printl("player " + player.GetName() + " incap help " + other.GetName() + " starting");
						break;
					}
				}
				else if(::SelfHelp.CurrentStatus[index] == 3)
				{
					// 现在是正在救助队友
					if(!::SelfHelp.IsNeedHelp(::SelfHelp.CurrentOther[index]) ||
						Utils.CalculateDistance(::SelfHelp.CurrentOther[index].GetLocation(), pos) > ::SelfHelp.ConfigVar.HelpOtherDistance)
					{
						// 离队友太远了，无法进行救助
						::SelfHelp.CurrentStatus[index] <- 1;
						::SelfHelp.CurrentTime[index] <- time;
						
						if(::SelfHelp.CurrentOther[index] != null &&
							::SelfHelp.CurrentOther[index].IsPlayerEntityValid())
						{
							// 停止进度条
							::SelfHelp.SetProgressBarTime(::SelfHelp.CurrentOther[index]);
							
							/*
							FireGameEvent("revive_end", {userid = player.GetUserID(),
								subject = ::SelfHelp.CurrentOther[index].GetUserID(), ledge_hang = false});
							*/
							
							printl("player " + player.GetName() + " incap help " +
								::SelfHelp.CurrentOther[index].GetName() + " stopped");
						}
						
						::SelfHelp.SetProgressBarTime(player);
						// delete ::SelfHelp.CurrentOther[index];
						::SelfHelp.CurrentOther[index] <- null;
					}
					else if(::SelfHelp.CurrentTime[index] <= time)
					{
						// 救队友完成
						::SelfHelp.CurrentStatus[index] <- 1;
						::SelfHelp.CurrentTime[index] <- time;
						
						::SelfHelp.SetProgressBarTime(player);
						::SelfHelp.RevivePlayerOfSelfhelp(::SelfHelp.CurrentOther[index], player);
						::SelfHelp.SetProgressBarTime(::SelfHelp.CurrentOther[index]);
						
						/*
						FireGameEvent("revive_success", {userid = player.GetUserID(),
							subject = ::SelfHelp.CurrentOther[index].GetUserID(),
							lastlife = false, ledge_hang = false});
						*/
						
						player.PlaySoundEx("level/gnomeftw.wav");
						::SelfHelp.CurrentOther[index].PlaySoundEx("level/gnomeftw.wav");
						printl("player " + player.GetName() + " incap help " +
								::SelfHelp.CurrentOther[index].GetName() + " success");
						
						// delete ::SelfHelp.CurrentOther[index];
						::SelfHelp.CurrentOther[index] <- null;
					}
				}
			}
		}
	},
	
	function TimerGivePills_OnPlayerThink(params)
	{
		if(!::SelfHelp.ConfigVar.GivePills)
			return;
		
		foreach(player in Players.AliveSurvivors())
		{
			if(!player.IsPressingShove() || ::SelfHelp.IsNeedHelp(player))
				continue;
			
			local weapon = player.GetActiveWeapon();
			if(weapon == null || !weapon.IsEntityValid())
				continue;
			
			local classname = weapon.GetClassname();
			if(classname != "weapon_pain_pills" && classname != "weapon_adrenaline")
				continue;
			
			local aiming = player.GetLookingEntity(TRACE_MASK_SHOT);
			if(aiming == null || !aiming.IsPlayer() || !aiming.IsPlayerEntityValid() || player.GetTeam() != SURVIVORS)
				continue;
			
			local inv = aiming.GetHeldItems();
			if("slot4" in inv && inv["slot4"] != null && inv["slot4"].IsEntityValid())
				continue;
			
			// 给队友递药
			player.Remove(classname);
			aiming.Give(classname);
			
			printl("player " + player.GetName() + " give " + aiming.GetName() + " a " + classname);
			
			// 游戏事件
			/*
			FireGameEvent("award_earned", {userid = player.GetUserID(), entityid = player.GetIndex(),
				subjectentid = aiming.GetIndex(), award = (classname == "weapon_pain_pills" ? 68 : 69)});
			*/
		}
	}
};

function Notifications::OnRoundBegin::Selfhelp(params)
{
	Timers.AddTimerByName("timer_selfhelp", 0.1, true, ::SelfHelp.TimerSelfhelp_OnPlayerThink);
	Timers.AddTimerByName("timer_givepills", 0.1, true, ::SelfHelp.TimerGivePills_OnPlayerThink);
}

function Notifications::FirstSurvLeftStartArea::Selfhelp(player, params)
{
	Timers.AddTimerByName("timer_selfhelp", 0.1, true, ::SelfHelp.TimerSelfhelp_OnPlayerThink);
	Timers.AddTimerByName("timer_givepills", 0.1, true, ::SelfHelp.TimerGivePills_OnPlayerThink);
}

function Notifications::OnDeath::SelfhelpStopped(victim, attacker, params)
{
	if(victim == null || !victim.IsPlayer() || !victim.IsPlayerEntityValid() || victim.GetTeam() != SURVIVORS)
		return;
	
	::SelfHelp.StopSelfhelpTimer(victim);
}

function Notifications::OnReviveBegin::SelfhelpStopped(subject, player, params)
{
	if(!::SelfHelp.ConfigVar.Enable)
		return;
	
	if(subject == null || !subject.IsPlayerEntityValid())
		return;
	
	if(subject.IsBot())
		subject.UnforceButton(BUTTON_DUCK);
	else if(::SelfHelp.ConfigVar.OtherStopped)
		subject.DisableButton(BUTTON_DUCK);
}

function Notifications::OnReviveEnd::SelfhelpStart(subject, player, params)
{
	if(!::SelfHelp.ConfigVar.Enable)
		return;
	
	if(subject == null || !subject.IsPlayerEntityValid())
		return;
	
	subject.EnableButton(BUTTON_DUCK);
	
	if(subject.IsBot() && ::SelfHelp.ConfigVar.BotSupport)
		subject.ForceButton(BUTTON_DUCK);
}

function Notifications::OnReviveSuccess::SelfhelpStopped(subject, player, params)
{
	if(!::SelfHelp.ConfigVar.Enable)
		return;
	
	// 倒地/挂边被救起来了
	::SelfHelp.StopSelfhelpTimer(subject);
	
	if(subject != null && player != null)
		printl("player " + subject.GetName() + " revived by " + player.GetName());
}

function Notifications::OnIncapacitated::SelfhelpActive(victim, attacker, params)
{
	if(!::SelfHelp.ConfigVar.Enable || !(::SelfHelp.ConfigVar.AllowStatus & 1))
		return;
	
	// 倒地（可能是被特感控倒）
	::SelfHelp.StartSelfhelpTimer(victim);
	
	if(victim != null && attacker != null)
		printl("player " + victim.GetName() + " incap by " + attacker.GetName());
}

function Notifications::OnGrabbedLedge::SelfhelpActive(attacker, victim, params)
{
	if(!::SelfHelp.ConfigVar.Enable || !(::SelfHelp.ConfigVar.AllowStatus & 2))
		return;
	
	// 挂边（可能是被舌头拉挂边/猴子骑挂边）
	::SelfHelp.StartSelfhelpTimer(victim);
	
	if(victim != null && attacker != null)
		printl("player " + victim.GetName() + " ledge by " + attacker.GetName());
}

function Notifications::OnJockeyRideStart::SelfhelpActive(attacker, victim, params)
{
	if(!::SelfHelp.ConfigVar.Enable || !(::SelfHelp.ConfigVar.AllowStatus & 4))
		return;
	
	// 被猴骑
	::SelfHelp.StartSelfhelpTimer(victim);
	
	if(victim != null && attacker != null)
		printl("player " + victim.GetName() + " ride by " + attacker.GetName());
}

function Notifications::OnHunterPouncedVictim::SelfhelpActive(attacker, victim, params)
{
	if(!::SelfHelp.ConfigVar.Enable || !(::SelfHelp.ConfigVar.AllowStatus & 8))
		return;
	
	// 被猎人扑（猎人可以扑倒地的生还者）
	::SelfHelp.StartSelfhelpTimer(victim);
	
	if(victim != null && attacker != null)
		printl("player " + victim.GetName() + " pounce by " + attacker.GetName());
}

function Notifications::OnSmokerTongueGrab::SelfhelpActive(attacker, victim, params)
{
	if(!::SelfHelp.ConfigVar.Enable || !(::SelfHelp.ConfigVar.AllowStatus & 16))
		return;
	
	// 被舌头拉
	::SelfHelp.StartSelfhelpTimer(victim);
	
	if(victim != null && attacker != null)
		printl("player " + victim.GetName() + " tongue by " + attacker.GetName());
}

function Notifications::OnChargerCarryVictim::SelfhelpActive(attacker, victim, params)
{
	if(!::SelfHelp.ConfigVar.Enable || !(::SelfHelp.ConfigVar.AllowStatus & 32))
		return;
	
	// 被牛抓住（还没开始锤地）
	// 牛在冲锋时受到攻击是由被抓住的生还者承受伤害的
	::SelfHelp.StartSelfhelpTimer(victim);
	
	if(victim != null && attacker != null)
		printl("player " + victim.GetName() + " carry by " + attacker.GetName());
}

function Notifications::OnChargerPummelBegin::SelfhelpActive(attacker, victim, params)
{
	if(!::SelfHelp.ConfigVar.Enable || !(::SelfHelp.ConfigVar.AllowStatus & 32))
		return;
	
	// 被牛锤地
	::SelfHelp.StartSelfhelpTimer(victim);
	
	if(victim != null && attacker != null)
		printl("player " + victim.GetName() + " pummel by " + attacker.GetName());
}

function Notifications::OnChargerPummelEnd::SelfhelpStopped(attacker, victim, params)
{
	if(!::SelfHelp.ConfigVar.Enable)
		return;
	
	if(victim == null || !victim.IsPlayerEntityValid())
		return;
	
	if(victim.IsIncapacitated() || victim.IsHangingFromLedge())
		return;
	
	// 牛锤地放开
	::SelfHelp.StopSelfhelpTimer(victim);
	
	if(victim != null && attacker != null)
		printl("player " + victim.GetName() + " pummel release by " + attacker.GetName());
}

function Notifications::OnSmokerTongueReleased::SelfhelpStopped(attacker, victim, params)
{
	if(!::SelfHelp.ConfigVar.Enable)
		return;
	
	if(victim == null || !victim.IsPlayerEntityValid())
		return;
	
	if(victim.IsIncapacitated() || victim.IsHangingFromLedge())
		return;
	
	// 舌头放开
	::SelfHelp.StopSelfhelpTimer(victim);
	
	if(victim != null && attacker != null)
		printl("player " + victim.GetName() + " tongue release by " + attacker.GetName());
}

function Notifications::OnJockeyRideEnd::SelfhelpStopped(attacker, victim, params)
{
	if(!::SelfHelp.ConfigVar.Enable)
		return;
	
	if(victim == null || !victim.IsPlayerEntityValid())
		return;
	
	if(victim.IsIncapacitated() || victim.IsHangingFromLedge())
		return;
	
	// 猴子骑脸放开
	::SelfHelp.StopSelfhelpTimer(victim);
	
	if(victim != null && attacker != null)
		printl("player " + victim.GetName() + " ride release by " + attacker.GetName());
}

function Notifications::OnHunterPounceStopped::SelfhelpStopped(attacker, victim, params)
{
	if(!::SelfHelp.ConfigVar.Enable)
		return;
	
	if(victim == null || !victim.IsPlayerEntityValid())
		return;
	
	if(victim.IsIncapacitated() || victim.IsHangingFromLedge())
		return;
	
	// 猎人扑倒放开
	::SelfHelp.StopSelfhelpTimer(victim);
	
	if(victim != null && attacker != null)
		printl("player " + victim.GetName() + " pounce stopped by " + attacker.GetName());
}

function Notifications::OnHunterReleasedVictim::SelfhelpStopped(attacker, victim, params)
{
	if(!::SelfHelp.ConfigVar.Enable)
		return;
	
	if(victim == null || !victim.IsPlayerEntityValid())
		return;
	
	if(victim.IsIncapacitated() || victim.IsHangingFromLedge())
		return;
	
	// 猎人扑倒放开
	::SelfHelp.StopSelfhelpTimer(victim);
	
	if(victim != null && attacker != null)
		printl("player " + victim.GetName() + " pounce release by " + attacker.GetName());
}

function EasyLogic::OnTakeDamage::SelfHelp_GodTimeThink(dmgTable)
{
	if(::SelfHelp.ConfigVar.GodTime <= 0)
		return true;
	
	if(dmgTable["Victim"] == null || dmgTable["Attacker"] == null || dmgTable["DamageDone"] <= 0.0 ||
		!dmgTable["Victim"].IsSurvivor() || dmgTable["Attacker"].GetTeam() != INFECTED)
		return true;
	
	local index = dmgTable["Victim"].GetIndex();
	if(index in ::SelfHelp.GodModeTime)
	{
		if(::SelfHelp.GodModeTime[index] < Time())
			delete ::SelfHelp.GodModeTime[index];
		else
			return false;
	}
	
	return true;
}

function CommandTriggersEx::sh(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	::SelfHelp.ConfigVar.Enable = !::SelfHelp.ConfigVar.Enable;
	::DeathRoundEnd.ConfigVar.Enable = ::SelfHelp.ConfigVar.Enable;
	
	printl("selfhelp setting " + ::SelfHelp.ConfigVar.Enable);
}

function CommandTriggersEx::shb(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	::SelfHelp.ConfigVar.BotSupport <- !::SelfHelp.ConfigVar.BotSupport;
	printl("selfhelp bots setting " + ::SelfHelp.ConfigVar.BotSupport);
}


::SelfHelp.PLUGIN_NAME <- PLUGIN_NAME;
::SelfHelp.ConfigVar = ::SelfHelp.ConfigVarDef;

function Notifications::OnRoundStart::SelfHelp_LoadConfig()
{
	RestoreTable(::SelfHelp.PLUGIN_NAME, ::SelfHelp.ConfigVar);
	if(::SelfHelp.ConfigVar == null || ::SelfHelp.ConfigVar.len() <= 0)
		::SelfHelp.ConfigVar = FileIO.GetConfigOfFile(::SelfHelp.PLUGIN_NAME, ::SelfHelp.ConfigVarDef);

	// printl("[plugins] " + ::SelfHelp.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::SelfHelp_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::SelfHelp.PLUGIN_NAME, ::SelfHelp.ConfigVar);

	// printl("[plugins] " + ::SelfHelp.PLUGIN_NAME + " saving...");
}
