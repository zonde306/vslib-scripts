::MeleeSpawner <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = false,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 7,

		// 最多刷出多少把禁止武器
		MaxCount = 8,

		// 最少刷出多少把近战武器
		MinCount = 4
	},

	ConfigVar = {},
	_MeleeList =
	[
		"baseball_bat",
		"cricket_bat",
		"crowbar",
		"electric_guitar",
		"fireaxe",
		"frying_pan",
		"golfclub",
		"katana",
		"hunting_knife",
		"machete",
		"riotshield",
		"tonfa"
	],

	function FindStartZone()
	{
		local player = Players.RandomAliveSurvivor();
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead())
			return null;
		
		return player.GetLocation();
	},
	
	function FindStartZonePlayer()
	{
		local target = null;
		foreach(player in Players.AliveSurvivors())
		{
			if(player.GetFlowDistance() > 100)
				continue;
			
			local inv = player.GetHeldItems();
			if("slot1" in inv && inv["slot1"] != null && inv["slot1"].IsEntityValid())
			{
				local classname = inv["slot1"].GetClassname();
				if(classname == "weapon_melee" || classname == "weapon_pistol_magnum")
					continue;
				
				if(classname == "weapon_pistol" && inv["slot1"].GetNetPropBool("m_hasDualWeapons"))
					continue;
			}
			
			target = player;
			break;
		}
		
		return player;
	},
	
	function Timer_SpawnMelee(params)
	{
		if(!::MeleeSpawner.ConfigVar.Enable)
			return false;
		
		local count = Players.Survivors().len();
		if(count < ::MeleeSpawner.ConfigVar.MinCount)
			count = ::MeleeSpawner.ConfigVar.MinCount;
		else if(count > ::MeleeSpawner.ConfigVar.MaxCount)
			count = ::MeleeSpawner.ConfigVar.MaxCount;
		
		local target = ::MeleeSpawner.FindStartZonePlayer();
		if(target != null)
		{
			local randNumber = 0;
			local maxNumber = ::MeleeSpawner._MeleeList.len() - 1;
			
			target.Remove("weapon_pistol");
			
			for(local i = 0; i < count; ++i)
			{
				srand(Time() + i);
				
				try
				{
					target.Give(::MeleeSpawner._MeleeList[Utils.GetRandNumber(0, maxNumber)]);
				}
				catch(err)
				{
					printl("invoke Player::Give() error: " + err);
				}
			}
			
			target.Give("weapon_pistol");
		}
		else
		{
			target = ::MeleeSpawner.FindStartZone();
			if(target == null)
				return true;
			
			target += ::MeleeSpawner.ConfigVar.Offset
			for(local i = 0; i < count; ++i)
			{
				g_ModeScript.SpawnMeleeWeapon("any", target, QAngle(0, 0, 0));
				// Utils.SpawnEntity("weapon_melee_spawn", "vslib_saferoom_melee", target, QAngle(0, 0, 0), {melee_weapon = "any"});
				// Utils.SpawnEntity("weapon_melee", "vslib_saferoom_melee", target, QAngle(0, 0, 0), {melee_script_name = ""});
			}
		}
		
		printl("spawn " + count + " melee");
		return false;
	}
};

function Notifications::OnRoundBegin::SafeRoomMelee_Spawner(params)
{
	if(!::MeleeSpawner.ConfigVar.Enable)
		return;
	
	Timers.AddTimerByName("timer_roundmeleespawn", 1.0, true, ::MeleeSpawner.Timer_SpawnMelee);
	printl("saferoom spawn melee");
}


::MeleeSpawner.PLUGIN_NAME <- PLUGIN_NAME;
::MeleeSpawner.ConfigVar = ::MeleeSpawner.ConfigVarDef;

function Notifications::OnRoundStart::MeleeSpawner_LoadConfig()
{
	RestoreTable(::MeleeSpawner.PLUGIN_NAME, ::MeleeSpawner.ConfigVar);
	if(::MeleeSpawner.ConfigVar == null || ::MeleeSpawner.ConfigVar.len() <= 0)
		::MeleeSpawner.ConfigVar = FileIO.GetConfigOfFile(::MeleeSpawner.PLUGIN_NAME, ::MeleeSpawner.ConfigVarDef);

	// printl("[plugins] " + ::MeleeSpawner.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::MeleeSpawner_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::MeleeSpawner.PLUGIN_NAME, ::MeleeSpawner.ConfigVar);

	// printl("[plugins] " + ::MeleeSpawner.PLUGIN_NAME + " saving...");
}
