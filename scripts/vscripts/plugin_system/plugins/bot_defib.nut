::BotDefibrillator <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,

		// 机器人考虑使用电击器的最大距离(超过就不去使用电击器)
		MaxDistance = 2000,

		// 机器人考虑使用电击器的最大路程(防止机器人到安全室了还跑回去)
		MaxFlowPercent = 95,

		// 机器人可以使用电击器的距离(在多近的时候开始使用电击器)
		UseDistance = 100,

		// 机器人是否要在安全时才使用电击器(周围没有僵尸 没有队友倒地被控)
		SafeMode = true,

		// 机器人使用电击器时是否无法行动
		UsingFreeze = false
	},

	ConfigVar = {},

	// 玩家(生还者)是否需要帮助(是否倒地/挂边/被控)
	function IsNeedHelp(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead() || !player.IsSurvivor())
			return false;
		
		if(player.IsIncapacitated() || player.IsHangingFromLedge() || player.IsHangingFromTongue() ||
			player.IsBeingJockeyed() || player.IsPounceVictim() || player.IsTongueVictim() ||
			player.IsCarryVictim() || player.IsPummelVictim())
			return true;
		
		return false;
	},
	
	// 检查是否可以使用电击器
	function CanUseDefib(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead() ||
			::BotDefibrillator.IsNeedHelp(player) || !player.HasItem("weapon_defibrillator"))
			return false;
		
		return true;
	},
	
	// 寻找一个需要帮助的生还者
	function FindAnyNeedHelpSurvivor()
	{
		foreach(player in Players.AliveSurvivors())
		{
			if(::BotDefibrillator.IsNeedHelp(player))
				return player;
		}
		
		return null;
	},
	
	DefibUsing = {},
	DefibSubject = {},
	DefibTimer = {},
	
	function ResetDefib()
	{
		foreach(index, subject in ::BotDefibrillator.DefibUsing)
		{
			local player = ::VSLib.Player(index);
			if(player == null || !player.IsPlayerEntityValid())
				continue;
			
			player.BotReset();
			player.EnableButton(BUTTON_FORWARD|BUTTON_BACK|BUTTON_LEFT|BUTTON_RIGHT);
		}
		
		if(::BotDefibrillator.DefibUsing.len() > 0)
			::BotDefibrillator.DefibUsing.clear();
		if(::BotDefibrillator.DefibTimer.len() > 0)
			::BotDefibrillator.DefibTimer.clear();
		if(::BotDefibrillator.DefibSubject.len() > 0)
			::BotDefibrillator.DefibSubject.clear();
	},
	
	function ClearPlayerDefib(player, subject)
	{
		if(typeof(player) == "instance" && player.IsValid())
			player = player.GetIndex();
		if(typeof(subject) == "instance" && subject.IsValid())
			subject = subject.GetIndex();
		
		if(player != null)
		{
			if(player in ::BotDefibrillator.DefibUsing)
				delete ::BotDefibrillator.DefibUsing[player];
			if(player in ::BotDefibrillator.DefibTimer)
				delete ::BotDefibrillator.DefibTimer[player];
			
			if(player.IsAlive())
				player.BotReset();
		}
		
		if(subject != null)
		{
			if(subject in ::BotDefibrillator.DefibSubject)
				delete ::BotDefibrillator.DefibSubject[subject];
		}
	},
	
	function TimerBotDefib_OnBotsThink(params)
	{
		if(!::BotDefibrillator.ConfigVar.Enable || (::BotDefibrillator.ConfigVar.SafeMode && ::BotDefibrillator.FindAnyNeedHelpSurvivor() != null))
		{
			::BotDefibrillator.ResetDefib();
			return;
		}
		
		// 给机器人寻找电击器目标
		foreach(subject in Players.DeadSurvivors())
		{
			local idx = subject.GetIndex();
			if(idx in ::BotDefibrillator.DefibSubject &&
				::BotDefibrillator.CanUseDefib(::BotDefibrillator.DefibSubject[idx]))
				continue;
			
			if(idx in ::BotDefibrillator.DefibSubject)
				delete ::BotDefibrillator.DefibSubject[idx];
			
			local pos = subject.GetLastDeathLocation();
			foreach(bots in Players.AliveSurvivorBots())
			{
				local index = bots.GetIndex();
				if(!::BotDefibrillator.CanUseDefib(bots) || bots.HasVisibleThreats() || bots.IsInCombat() ||
					Utils.CalculateDistance(bots.GetLocation(), pos) > ::BotDefibrillator.ConfigVar.MaxDistance ||
					bots.GetFlowPercent() > ::BotDefibrillator.ConfigVar.MaxFlowPercent)
				{
					if(index in ::BotDefibrillator.DefibUsing)
						::BotDefibrillator.ClearPlayerDefib(bots, subject);
					
					continue;
				}
				
				::BotDefibrillator.DefibUsing[index] <- subject;
				::BotDefibrillator.DefibSubject[idx] <- bots;
				
				if(index in ::BotDefibrillator.DefibTimer)
					delete ::BotDefibrillator.DefibTimer[index];
				
				bots.BotMoveToLocation(pos);
				bots.EnableButton(BUTTON_FORWARD|BUTTON_BACK|BUTTON_LEFT|BUTTON_RIGHT);
				printl("bots " + bots.GetName() + " goto defib " + subject.GetName());
				break;
			}
			
			if(idx in ::BotDefibrillator.DefibSubject &&
				::BotDefibrillator.CanUseDefib(::BotDefibrillator.DefibSubject[idx]))
				break;
		}
		
		// 让机器人去使用电击器
		foreach(index, subject in ::BotDefibrillator.DefibUsing)
		{
			local player = ::VSLib.Player(index);
			if(player == null || subject == null || !player.IsPlayerEntityValid() || !subject.IsPlayerEntityValid())
			{
				// 重新寻找一个可以使用电击器的机器人
				::BotDefibrillator.ClearPlayerDefib(index, subject);
				break;
			}
			
			if(subject.IsAlive() || !::BotDefibrillator.CanUseDefib(player) || ::BotDefibrillator.IsNeedHelp(player) ||
				player.IsDead() || player.IsInCombat() || player.HasVisibleThreats())
			{
				::BotDefibrillator.ClearPlayerDefib(index, subject);
				printl("bots " + player.GetName() + " defib " + subject.GetName() + " stopped by respawn");
				break;
			}
			
			local pos = subject.GetLastDeathLocation();
			if(Utils.CalculateDistance(pos, player.GetLocation()) <= ::BotDefibrillator.ConfigVar.UseDistance)
			{
				if(!(index in ::BotDefibrillator.DefibTimer) || ::BotDefibrillator.DefibTimer[index] <= 0.0)
				{
					// 开始使用电击器
					if(::BotDefibrillator.ConfigVar.UsingFreeze)
						player.DisableButton(BUTTON_FORWARD|BUTTON_BACK|BUTTON_LEFT|BUTTON_RIGHT);
					
					::BotDefibrillator.DefibTimer[index] <- Time() + Convars.GetFloat("defibrillator_use_duration");
					printl("bots " + player.GetName() + " defib " + subject.GetName() + " starting.");
				}
				else if(::BotDefibrillator.DefibTimer[index] <= Time())
				{
					// 使用电击器完成
					player.EnableButton(BUTTON_FORWARD|BUTTON_BACK|BUTTON_LEFT|BUTTON_RIGHT);
					
					subject.Defib();
					player.Remove("weapon_defibrillator");
					delete ::BotDefibrillator.DefibUsing[index];
					delete ::BotDefibrillator.DefibTimer[index];
					delete ::BotDefibrillator.DefibSubject[subject.GetIndex()];
					
					if(!subject.IsBot())
						subject.PlaySoundEx("level/startwam.wav");
					
					printl("bots " + player.GetName() + " defib " + subject.GetName() + " success.");
					break;
				}
			}
			else
			{
				// 移动到指定位置
				player.EnableButton(BUTTON_FORWARD|BUTTON_BACK|BUTTON_LEFT|BUTTON_RIGHT);
				player.BotMoveToLocation(pos);
			}
		}
	}
};

function Notifications::OnRoundBegin::BotDefibActtive(params)
{
	Timers.AddTimerByName("timer_botdefib", 1.0, true, ::BotDefibrillator.TimerBotDefib_OnBotsThink);
}

function Notifications::FirstSurvLeftStartArea::BotDefibActtive(player, params)
{
	Timers.AddTimerByName("timer_botdefib", 1.0, true, ::BotDefibrillator.TimerBotDefib_OnBotsThink);
}

function Notifications::OnPlayerReplacedBot::BotDefib_Stopped(player, bots, params)
{
	if(player == null || !player.IsPlayerEntityValid() || !player.IsSurvivor())
		return;
	
	foreach(idx, subject in ::BotDefibrillator.DefibUsing)
	{
		if(subject == null || !subject.IsPlayerEntityValid())
			continue;
		
		if(subject.GetSurvivorCharacter() == player.GetSurvivorCharacter())
		{
			if(idx in ::BotDefibrillator.DefibTimer)
				delete ::BotDefibrillator.DefibTimer[idx];
			
			delete ::BotDefibrillator.DefibUsing[idx];
		}
	}
	
	local index = player.GetIndex();
	if(index in ::BotDefibrillator.DefibSubject)
	{
		delete ::BotDefibrillator.DefibSubject[index];
		printl("player " + player.GetName() + " spawned. defib stopped");
	}
}

function CommandTriggersEx::bd(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	::BotDefibrillator.ResetDefib();
	Timers.AddTimerByName("timer_botdefib", 1.0, true, ::BotDefibrillator.TimerBotDefib_OnBotsThink);
	player.ShowHint("bot defib reset");
}


::BotDefibrillator.PLUGIN_NAME <- PLUGIN_NAME;
::BotDefibrillator.ConfigVar = ::BotDefibrillator.ConfigVarDef;

function Notifications::OnRoundStart::BotDefibrillator_LoadConfig()
{
	RestoreTable(::BotDefibrillator.PLUGIN_NAME, ::BotDefibrillator.ConfigVar);
	if(::BotDefibrillator.ConfigVar == null || ::BotDefibrillator.ConfigVar.len() <= 0)
		::BotDefibrillator.ConfigVar = FileIO.GetConfigOfFile(::BotDefibrillator.PLUGIN_NAME, ::BotDefibrillator.ConfigVarDef);

	// printl("[plugins] " + ::BotDefibrillator.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::BotDefibrillator_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::BotDefibrillator.PLUGIN_NAME, ::BotDefibrillator.ConfigVar);

	// printl("[plugins] " + ::BotDefibrillator.PLUGIN_NAME + " saving...");
}
