::FastMeleeFix <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
		
		// 思考间隔
		ThinkInterval = 0.1
	},
	
	ConfigVar = {},
	
	NextSwingTime = {},
	
	function Timer_CheckFastMelee(params)
	{
		if(!::FastMeleeFix.ConfigVar.Enable)
			return;
		
		local time = Time();
		foreach(player in Players.AliveSurvivors())
		{
			local index = player.GetIndex();
			if(!(index in ::FastMeleeFix.NextSwingTime))
				continue;
			
			if(::FastMeleeFix.NextSwingTime[index] <= Time())
			{
				delete ::FastMeleeFix.NextSwingTime[index];
				continue;
			}
			
			local weapon = player.GetActiveWeapon()
			if(weapon == null || weapon.GetClassname() != "weapon_melee")
				continue;
			
			local byServer = Time() + 0.5;
			local shouldbe = ::FastMeleeFix.NextSwingTime[index];
			local nextAttack = (byServer < shouldbe ? byServer : shouldbe);
			if(weapon.GetNetPropFloat("m_flNextPrimaryAttack") < nextAttack)
			{
				weapon.SetNetPropFloat("m_flNextPrimaryAttack", nextAttack);
				// printl("survivor " + player.GetName() + " detect fastmelee.");
			}
		}
	}
};

function Notifications::OnRoundBegin::FastMeleeFix(params)
{
	Timers.AddTimerByName("timer_fastmeleefix", ::FastMeleeFix.ConfigVar.ThinkInterval, true,
		::FastMeleeFix.Timer_CheckFastMelee);
}

function Notifications::FirstSurvLeftStartArea::FastMeleeFix(player, params)
{
	Timers.AddTimerByName("timer_fastmeleefix", ::FastMeleeFix.ConfigVar.ThinkInterval, true,
		::FastMeleeFix.Timer_CheckFastMelee);
}

function Notifications::OnWeaponFire::FastMeleeFix(player, weapon, params)
{
	if(player == null || !player.IsSurvivor() || weapon != "weapon_melee")
		return;
	
	::FastMeleeFix.NextSwingTime[player.GetIndex()] <- Time() + 0.92;
}

::FastMeleeFix.PLUGIN_NAME <- PLUGIN_NAME;
::FastMeleeFix.ConfigVar = ::FastMeleeFix.ConfigVarDef;

function Notifications::OnRoundStart::FastMeleeFix_LoadConfig()
{
	RestoreTable(::FastMeleeFix.PLUGIN_NAME, ::FastMeleeFix.ConfigVar);
	if(::FastMeleeFix.ConfigVar == null || ::FastMeleeFix.ConfigVar.len() <= 0)
		::FastMeleeFix.ConfigVar = FileIO.GetConfigOfFile(::FastMeleeFix.PLUGIN_NAME, ::FastMeleeFix.ConfigVarDef);

	// printl("[plugins] " + ::FastMeleeFix.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::FastMeleeFix_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::FastMeleeFix.PLUGIN_NAME, ::FastMeleeFix.ConfigVar);

	// printl("[plugins] " + ::FastMeleeFix.PLUGIN_NAME + " saving...");
}
