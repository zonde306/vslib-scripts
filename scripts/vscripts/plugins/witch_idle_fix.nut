::WitchIdleFix <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = false,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
		
		// 记录持续时间
		RecordDuration = 6,
	},
	
	ConfigVar = {},
	
	LastWitchAttacker = null,
	
	function Timer_ClearRecord(params)
	{
		::WitchIdleFix.LastWitchAttacker = null;
	},
};

function Notifications::OnBrokeProp::WitchIdleFix(attacker, prop, params)
{
	if(!::WitchIdleFix.ConfigVar.Enable)
		return;
	
	::WitchIdleFix.LastWitchAttacker = attacker;
	Timers.AddTimerByName("timer_witch_idle_fix", ::WitchIdleFix.ConfigVar.RecordDuration, false, ::WitchIdleFix.Timer_ClearRecord);
}

function Notifications::OnWeaponFire::WitchIdleFix(attacker, weapon, params)
{
	if(!::WitchIdleFix.ConfigVar.Enable)
		return;
	
	if(weapon != "weapon_molotov" && weapon != "weapon_pipe_bomb" && weapon != "weapon_vomitjar")
		return;
	
	::WitchIdleFix.LastWitchAttacker = attacker;
	Timers.AddTimerByName("timer_witch_idle_fix", ::WitchIdleFix.ConfigVar.RecordDuration, false, ::WitchIdleFix.Timer_ClearRecord);
}

function Notifications::OnInfectedHurt::WitchIdleFix(infected, attacker, params)
{
	if(!::WitchIdleFix.ConfigVar.Enable)
		return;
	
	if(infected == null || !infected.IsValid() || infected.GetType() != Z_WITCH)
		return;
	
	if(attacker != null && attacker.IsValid())
	{
		if(!attacker.IsBot() && attacker.GetTeam() == 1)
		{
			foreach(sb in Players.AliveSurvivorBots())
			{
				local spec = sb.GetHumanSpectator();
				if(spec != null && spec.IsValid() && spec.GetIndex() == attacker.GetIndex())
				{
					infected.SetTarget(sb);
					return;
				}
			}
		}
		/*	这样好像不太好
		else if(attacker.IsBot() && attacker.GetTeam() == 2 && attacker.IsHumanSpectating())
		{
			infected.SetTarget(attacker);
			return;
		}
		*/
	}
	
	if(::WitchIdleFix.LastWitchAttacker != null && ::WitchIdleFix.LastWitchAttacker.IsValid() && ::WitchIdleFix.LastWitchAttacker.GetTeam() == 1)
	{
		foreach(sb in Players.AliveSurvivorBots())
		{
			local spec = sb.GetHumanSpectator();
			if(spec != null && spec.IsValid() && spec.GetIndex() == ::WitchIdleFix.LastWitchAttacker.GetIndex())
			{
				::WitchIdleFix.LastWitchAttacker = null;
				infected.SetTarget(sb);
				return;
			}
		}
	}
}

function Notifications::OnWitchStartled::WitchIdleFix(witch, attacker, params)
{
	if(!::WitchIdleFix.ConfigVar.Enable)
		return;
	
	if(witch == null || !witch.IsValid())
		return;
	
	if(attacker != null && attacker.IsValid())
	{
		if(!attacker.IsBot() && attacker.GetTeam() == 1)
		{
			foreach(sb in Players.AliveSurvivorBots())
			{
				local spec = sb.GetHumanSpectator();
				if(spec != null && spec.IsValid() && spec.GetIndex() == attacker.GetIndex())
				{
					witch.SetTarget(sb);
					return;
				}
			}
		}
		else if(attacker.IsBot() && attacker.GetTeam() == 2 && attacker.IsHumanSpectating())
		{
			witch.SetTarget(attacker);
			return;
		}
	}
	
	if(::WitchIdleFix.LastWitchAttacker != null && ::WitchIdleFix.LastWitchAttacker.IsValid() && ::WitchIdleFix.LastWitchAttacker.GetTeam() == 1)
	{
		foreach(sb in Players.AliveSurvivorBots())
		{
			local spec = sb.GetHumanSpectator();
			if(spec != null && spec.IsValid() && spec.GetIndex() == ::WitchIdleFix.LastWitchAttacker.GetIndex())
			{
				::WitchIdleFix.LastWitchAttacker = null;
				witch.SetTarget(sb);
				return;
			}
		}
	}
}

::WitchIdleFix.PLUGIN_NAME <- PLUGIN_NAME;
::WitchIdleFix.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::WitchIdleFix.ConfigVarDef);

function Notifications::OnRoundStart::WitchIdleFix_LoadConfig()
{
	RestoreTable(::WitchIdleFix.PLUGIN_NAME, ::WitchIdleFix.ConfigVar);
	if(::WitchIdleFix.ConfigVar == null || ::WitchIdleFix.ConfigVar.len() <= 0)
		::WitchIdleFix.ConfigVar = FileIO.GetConfigOfFile(::WitchIdleFix.PLUGIN_NAME, ::WitchIdleFix.ConfigVarDef);

	// printl("[plugins] " + ::WitchIdleFix.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::WitchIdleFix_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::WitchIdleFix.PLUGIN_NAME, ::WitchIdleFix.ConfigVar);

	// printl("[plugins] " + ::WitchIdleFix.PLUGIN_NAME + " saving...");
}