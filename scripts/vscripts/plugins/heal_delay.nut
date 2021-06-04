::HealDelay <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = false,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 24,

		// 吃药进行回复多少次生命值
		PillsAmount = 10,

		// 吃药每次回复的间隔
		PillsInterval = 0.25,

		// 吃药回复多少次生命值
		PillsCount = 5,

		// 打针进行回复多少次生命值
		AdrenAmount = 5,

		// 打针每次回复的间隔
		AdrenInterval = 0.25,

		// 打针回复多少次生命值
		AdrenCount = 5
	},

	ConfigVar = {},

	PillsHealCount = {},
	AdrenHealCount = {},
	PillsHealNext = {},
	AdrenHealNext = {},
	HealAmountChanged = false,
	
	function GiveHealthBuffer(player, amount)
	{
		if(player == null || !player.IsSurvivor() || player.IsDead() || player.IsIncapacitated())
			return false;
		
		local health = player.GetRawHealth();
		local buffer = player.GetHealthBuffer();
		local maxHealth = player.GetMaxHealth();
		
		buffer += amount;
		if(health + buffer > maxHealth)
			buffer = maxHealth - health;
		
		player.SetHealthBuffer(buffer);
		return true;
	},
	
	function RemoveHealthBuffer(player, amount)
	{
		if(player == null || !player.IsSurvivor() || player.IsDead() || player.IsIncapacitated())
			return false;
		
		local buffer = player.GetHealthBuffer();
		
		buffer -= amount;
		if(buffer < 0)
			buffer = 0;
		
		player.SetHealthBuffer(buffer);
		return true;
	}
	
	function Timer_PillsHeal(params)
	{
		if(!::HealDelay.ConfigVar.Enable)
		{
			if(::HealDelay.HealAmountChanged)
			{
				Convars.SetValue("pain_pills_health_value", "50");
				Convars.SetValue("adrenaline_health_buffer", "30");
				::HealDelay.HealAmountChanged = false;
			}
			return;
		}
		
		if(!::HealDelay.HealAmountChanged)
		{
			Convars.SetValue("pain_pills_health_value", "0");
			Convars.SetValue("adrenaline_health_buffer", "0");
			::HealDelay.HealAmountChanged = true;
		}
		
		local currentTime = Time();
		foreach(index, amount in ::HealDelay.PillsHealCount)
		{
			local player = ::VSLib.Player(index);
			if(player == null || !player.IsSurvivor() || player.IsIncapacitated() || player.IsDead() || amount < 1)
			{
				delete ::HealDelay.PillsHealCount[index];
				
				if(index in ::HealDelay.PillsHealNext)
					delete ::HealDelay.PillsHealNext[index];
				
				if(player != null && player.IsPlayerEntityValid())
					printl("player " + player.GetName() + " pain_pills stopped");
				
				break;
			}
			
			if(index in ::HealDelay.PillsHealNext && ::HealDelay.PillsHealNext[index] > currentTime)
				continue;
			
			::HealDelay.GiveHealthBuffer(player, ::HealDelay.ConfigVar.PillsAmount);
			if(amount > 1)
			{
				::HealDelay.PillsHealNext[index] <- currentTime + ::HealDelay.ConfigVar.PillsInterval;
				::HealDelay.PillsHealCount[index] <- amount - 1;
			}
			else
			{
				if(index in ::HealDelay.PillsHealNext)
					delete ::HealDelay.PillsHealNext[index];
				
				delete ::HealDelay.PillsHealCount[index];
				printl("player " + player.GetName() + " pain_pills complete");
				
				break;
			}
		}
		
		foreach(index, amount in ::HealDelay.AdrenHealCount)
		{
			local player = ::VSLib.Player(index);
			if(player == null || !player.IsSurvivor() || player.IsIncapacitated() || player.IsDead() || amount < 1)
			{
				delete ::HealDelay.AdrenHealCount[index];
				
				if(index in ::HealDelay.AdrenHealNext)
					delete ::HealDelay.AdrenHealNext[index];
				
				if(player != null && player.IsPlayerEntityValid())
					printl("player " + player.GetName() + " adrenaline stopped");
				
				break;
			}
			
			if(index in ::HealDelay.AdrenHealNext && ::HealDelay.AdrenHealNext[index] > currentTime)
				continue;
			
			::HealDelay.GiveHealthBuffer(player, ::HealDelay.ConfigVar.AdrenAmount);
			if(amount > 1)
			{
				::HealDelay.AdrenHealNext[index] <- currentTime + ::HealDelay.ConfigVar.AdrenInterval;
				::HealDelay.AdrenHealCount[index] <- amount - 1;
			}
			else
			{
				if(index in ::HealDelay.AdrenHealNext)
					delete ::HealDelay.AdrenHealNext[index];
				
				delete ::HealDelay.AdrenHealCount[index];
				printl("player " + player.GetName() + " adrenaline complete");
				
				break;
			}
		}
	}
};

function Notifications::OnPillsUsed::HealDelay_StartTimer(player, params)
{
	if(!::HealDelay.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayerEntityValid() || player.IsIncapacitated())
		return;
	
	::HealDelay.RemoveHealthBuffer(player, Convars.GetFloat("pain_pills_health_value"));
	::HealDelay.PillsHealCount[player.GetIndex()] <- ::HealDelay.ConfigVar.PillsCount;
	// printl("player " + player.GetName() + " use pain_pills");
}

function Notifications::OnAdrenalineUsed::HealDelay_StartTimer(player, params)
{
	if(!::HealDelay.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayerEntityValid() || player.IsIncapacitated())
		return;
	
	::HealDelay.RemoveHealthBuffer(player, Convars.GetFloat("adrenaline_health_buffer"));
	::HealDelay.AdrenHealCount[player.GetIndex()] <- ::HealDelay.ConfigVar.AdrenCount;
	// printl("player " + player.GetName() + " use adrenaline");
}

function Notifications::OnRoundBegin::HealDelay_Active(params)
{
	Timers.AddTimerByName("timer_pillsdelay", 0.1, true, ::HealDelay.Timer_PillsHeal);
	
	Convars.SetValue("pain_pills_health_value", "0");
	Convars.SetValue("adrenaline_health_buffer", "0");
	::HealDelay.HealAmountChanged = true;
}

function Notifications::FirstSurvLeftStartArea::HealDelay_Active(player, params)
{
	Timers.AddTimerByName("timer_pillsdelay", 0.1, true, ::HealDelay.Timer_PillsHeal);
}


::HealDelay.PLUGIN_NAME <- PLUGIN_NAME;
::HealDelay.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::HealDelay.ConfigVarDef);

function Notifications::OnRoundStart::HealDelay_LoadConfig()
{
	RestoreTable(::HealDelay.PLUGIN_NAME, ::HealDelay.ConfigVar);
	if(::HealDelay.ConfigVar == null || ::HealDelay.ConfigVar.len() <= 0)
		::HealDelay.ConfigVar = FileIO.GetConfigOfFile(::HealDelay.PLUGIN_NAME, ::HealDelay.ConfigVarDef);

	// printl("[plugins] " + ::HealDelay.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::HealDelay_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::HealDelay.PLUGIN_NAME, ::HealDelay.ConfigVar);

	// printl("[plugins] " + ::HealDelay.PLUGIN_NAME + " saving...");
}
