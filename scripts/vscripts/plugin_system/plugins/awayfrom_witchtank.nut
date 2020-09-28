::AwayFromDanger <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,
		
		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
		
		// Witch 安全距离
		WitchDangerDistance = 500.0,
		
		// Tank 安全距离
		TankDangerDistance = 800.0,
		
		// 其他有危险的物体安全距离
		ObjectDangerDistance = 400.0,
	},

	ConfigVar = {},
	
	TimerHandle = null,
	
	function IsDangerPresent()
	{
		foreach(witch in Zombies.Witches())
		{
			if(!witch.IsAlive() || witch.GetNetPropFloat("m_rage") <= 0.0)
				continue;
			
			return true;
		}
		
		foreach(tank in Players.OfType(Z_TANK))
		{
			if(!tank.IsAlive() || tank.GetNetPropBool("m_isIncapacitated"))
				continue;
			
			return true;
		}
		
		return false;
	},
	
	function Timer_AwayFromDanger(params)
	{
		foreach(sb in Players.AliveSurvivorBots())
		{
			if(sb.IsIncapacitated())
				continue;
			
			local origin = sb.GetLocation();
			
			foreach(witch in Zombies.Witches())
			{
				if(!witch.IsAlive() || witch.GetNetPropFloat("m_rage") <= 0.0)
					continue;
				
				if(Utils.CalculateDistance(origin, witch.GetLocation()) <= ::AwayFromDanger.ConfigVar.WitchDangerDistance)
				{
					sb.BotRetreatFrom(witch);
					// printl("bot " + sb.GetName() + " try away from " + witch.GetName());
				}
			}
			
			foreach(tank in Players.OfType(Z_TANK))
			{
				if(!tank.IsAlive() || tank.GetNetPropBool("m_isIncapacitated"))
					continue;
				
				if(Utils.CalculateDistance(origin, tank.GetLocation()) <= ::AwayFromDanger.ConfigVar.TankDangerDistance)
				{
					sb.BotRetreatFrom(tank);
					// printl("bot " + sb.GetName() + " try away from " + tank.GetName());
				}
			}
			
			foreach(entity in Objects.AroundRadius(origin, ::AwayFromDanger.ConfigVar.ObjectDangerDistance))
			{
				switch(entity.GetClassname())
				{
					case "env_entity_igniter":			// 野火
					case "entityflame":					// 野火
					case "insect_swarm":				// 酸液
					case "grenade_launcher_projectile":	// 榴弹
					case "molotov_projectile":			// 火瓶
					case "pipe_bomb_projectile":		// 土雷
					case "spitter_projectile":			// 酸液球
					case "tank_rock":					// 投石
					{
						sb.BotRetreatFrom(entity);
						break;
					}
				}
			}
		}
		
		if(!::AwayFromDanger.IsDangerPresent())
		{
			::AwayFromDanger.TimerHandle = null;
			printl("danger released");
			return false;
		}
	}
};

function Notifications::OnWitchStartled::AwayFromDanger(witch, survivor, params)
{
	if(::AwayFromDanger.TimerHandle == null)
		::AwayFromDanger.TimerHandle = Timers.AddTimer(1.0, true, ::AwayFromDanger.Timer_AwayFromDanger);
	
	printl("danger found: witch rage");
}

function Notifications::OnTankSpawned::AwayFromDanger(tank, params)
{
	if(::AwayFromDanger.TimerHandle == null)
		::AwayFromDanger.TimerHandle = Timers.AddTimer(1.0, true, ::AwayFromDanger.Timer_AwayFromDanger);
	
	printl("danger found: tank");
}

::AwayFromDanger.PLUGIN_NAME <- PLUGIN_NAME;
::AwayFromDanger.ConfigVar = ::AwayFromDanger.ConfigVarDef;

function Notifications::OnRoundStart::AwayFromDanger_LoadConfig()
{
	RestoreTable(::AwayFromDanger.PLUGIN_NAME, ::AwayFromDanger.ConfigVar);
	if(::AwayFromDanger.ConfigVar == null || ::AwayFromDanger.ConfigVar.len() <= 0)
		::AwayFromDanger.ConfigVar = FileIO.GetConfigOfFile(::AwayFromDanger.PLUGIN_NAME, ::AwayFromDanger.ConfigVarDef);

	// printl("[plugins] " + ::AwayFromDanger.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::AwayFromDanger_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::AwayFromDanger.PLUGIN_NAME, ::AwayFromDanger.ConfigVar);

	// printl("[plugins] " + ::AwayFromDanger.PLUGIN_NAME + " saving...");
}
