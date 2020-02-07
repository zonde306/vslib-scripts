::PouncedFix <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,
		
		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
		
		// 呼叫间隔(秒)
		CallInterval = 0.5,
		
		// 寻找敌人范围
		ScanRadius = 800,
		
		// 被攻击时强制反击(或许可以修复站着不动挨打)
		ForceCounterattack = true,
	},

	ConfigVar = {},
	TimeNextOrder = {},
	
	function FindClosestDominator(origin)
	{
		local currentDominator = null;
		local currentDistance = ::PouncedFix.ConfigVar.ScanRadius;
		
		foreach(witch in Objects.OfClassnameWithin("witch", origin, currentDistance))
		{
			if(!witch.IsAlive() || witch.GetNetPropFloat("m_rage") < 1.0)
				continue;
			
			local distance = Utils.CalculateDistance(witch.GetLocation(), origin);
			if(distance > currentDistance)
				continue;
			
			currentDominator = witch;
			currentDistance = distance;
		}
		
		foreach(player in Players.AliveSurvivors())
		{
			local distance = 65535;
			local dominator = player.GetCurrentAttacker();
			if(dominator == null || (distance = Utils.CalculateDistance(dominator.GetLocation(), origin)) > currentDistance)
				continue;
			
			currentDominator = dominator;
			currentDistance = distance;
		}
		
		return currentDominator;
	},
	
	function CallBotHelper()
	{
		foreach(sb in Players.AliveSurvivorBots())
		{
			if(sb.GetNetPropEntity("m_reviveTarget") != null)
				continue;
			
			local index = sb.GetIndex();
			if(index in ::PouncedFix.TimeNextOrder && ::PouncedFix.TimeNextOrder[index] > Time())
				continue;
			
			local target = ::PouncedFix.FindClosestDominator(sb.GetLocation())
			if(target == null)
				continue;
			
			::PouncedFix.TimeNextOrder[index] <- Time() + ::PouncedFix.ConfigVar.CallInterval;
			sb.BotAttack(target, true, true);
			// printl("bot " + sb.GetName() + " try attack " + target.GetName());
		}
	},
};

function Notifications::OnHurt::PouncedFix(victim, attacker, params)
{
	if(!::PouncedFix.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsSurvivor() || attacker.GetTeam() != 3 || !attacker.IsAlive())
		return;
	
	if(victim.GetCurrentAttacker() == attacker || attacker.GetType() == Z_WITCH)
		::PouncedFix.CallBotHelper()
}

function Notifications::OnHurt::PouncedFix_ForceCounterattack(victim, attacker, params)
{
	if(!::PouncedFix.ConfigVar.Enable || !::PouncedFix.ConfigVar.ForceCounterattack)
		return;
	
	if(victim == null || attacker == null || !victim.IsSurvivor() || !victim.IsBot() ||
		attacker.GetTeam() == victim.GetTeam() || !attacker.IsAlive() || victim.IsInCombat() ||
		victim.GetNetPropEntity("m_reviveTarget") != null)
		return;
	
	victim.BotReset();
	victim.BotAttack(attacker, true, true);
}

function Notifications::OnSmokerChokeBegin::PouncedFix(attacker, victim, params)
{
	if(!::PouncedFix.ConfigVar.Enable)
		return;
	
	::PouncedFix.CallBotHelper()
}

function Notifications::OnHunterPouncedVictim::PouncedFix(attacker, victim, params)
{
	if(!::PouncedFix.ConfigVar.Enable)
		return;
	
	::PouncedFix.CallBotHelper()
}

function Notifications::OnJockeyRideStart::PouncedFix(attacker, victim, params)
{
	if(!::PouncedFix.ConfigVar.Enable)
		return;
	
	::PouncedFix.CallBotHelper()
}

function Notifications::OnChargerPummelBegin::PouncedFix(attacker, victim, params)
{
	if(!::PouncedFix.ConfigVar.Enable)
		return;
	
	::PouncedFix.CallBotHelper()
}

::PouncedFix.PLUGIN_NAME <- PLUGIN_NAME;
::PouncedFix.ConfigVar = ::PouncedFix.ConfigVarDef;

function Notifications::OnRoundStart::PouncedFix_LoadConfig()
{
	RestoreTable(::PouncedFix.PLUGIN_NAME, ::PouncedFix.ConfigVar);
	if(::PouncedFix.ConfigVar == null || ::PouncedFix.ConfigVar.len() <= 0)
		::PouncedFix.ConfigVar = FileIO.GetConfigOfFile(::PouncedFix.PLUGIN_NAME, ::PouncedFix.ConfigVarDef);

	// printl("[plugins] " + ::PouncedFix.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::PouncedFix_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::PouncedFix.PLUGIN_NAME, ::PouncedFix.ConfigVar);

	// printl("[plugins] " + ::PouncedFix.PLUGIN_NAME + " saving...");
}
