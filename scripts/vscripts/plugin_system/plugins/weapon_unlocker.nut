::WeaponUnlocker <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,

		// MP5 刷出几率 [0~100]
		MP5 = 25,

		// SG552 刷出几率 [0~100]
		SG552 = 25,

		// Scout 刷出几率 [0~100]
		Scout = 35,

		// AWP 刷出几率 [0~100]
		AWP = 15,
		
		// 修复 SG552 换子弹
		PatchSG552 = true
	},

	ConfigVar = {},

	function Timer_GenerateWeapon(params)
	{
		local smgSpawned = 0;
		local rifleSpawned = 0;
		local scoutSpawned = 0;
		local awpSpawned = 0;
		local smgTotal = 0;
		local rifleTotal = 0;
		local sniperTotal = 0;
		
		foreach(entity in Objects.All())
		{
			local classname = entity.GetClassname();
			if(classname.find("weapon_") == null || entity.GetOwnerEntity() != null)
				return;
			
			local currentTime = Time();
			switch(classname)
			{
				case "weapon_smg_spawn":
				case "weapon_smg_silenced_spawn":
				{
					srand(currentTime + smgTotal + smgSpawned);
					if(Utils.GetRandNumber(1, 100) <= ::WeaponUnlocker.ConfigVar.MP5)
					{
						Utils.SpawnWeapon("weapon_smg_mp5_spawn", 4, 999, entity.GetLocation(), entity.GetAngles());
						entity.Kill();
						++smgSpawned;
					}
					
					++smgTotal;
					break;
				}
				case "weapon_rifle_spawn":
				case "weapon_rifle_ak47_spawn":
				case "weapon_rifle_desert_spawn":
				{
					srand(currentTime + rifleTotal + rifleSpawned);
					if(Utils.GetRandNumber(1, 100) <= ::WeaponUnlocker.ConfigVar.SG552)
					{
						Utils.SpawnWeapon("weapon_rifle_sg552_spawn", 4, 999, entity.GetLocation(), entity.GetAngles());
						entity.Kill();
						++rifleSpawned;
					}
					
					++rifleTotal;
					break;
				}
				case "weapon_sniper_military_spawn":
				case "weapon_hunting_rifle_spawn":
				{
					srand(currentTime + sniperTotal + scoutSpawned + awpSpawned);
					if(Utils.GetRandNumber(1, 100) <= ::WeaponUnlocker.ConfigVar.Scout)
					{
						Utils.SpawnWeapon("weapon_sniper_scout_spawn", 4, 999, entity.GetLocation(), entity.GetAngles());
						entity.Kill();
						++scoutSpawned;
					}
					else if(Utils.GetRandNumber(1, 100) <= ::WeaponUnlocker.ConfigVar.AWP)
					{
						Utils.SpawnWeapon("weapon_sniper_awp_spawn", 4, 999, entity.GetLocation(), entity.GetAngles());
						entity.Kill();
						++awpSpawned;
					}
					
					++sniperTotal;
					break;
				}
			}
		}
		
		printl("mp5 count " + smgSpawned + ", smg total " + smgTotal);
		printl("sg552 count " + rifleSpawned + ", rifle total " + rifleTotal);
		printl("scout count " + scoutSpawned + ", awp count " + awpSpawned + ", sniper total " + sniperTotal);
	}
};

function Notifications::OnRoundBegin::WeaponUnlocker_SpawnWeapon(params)
{
	if(!::WeaponUnlocker.ConfigVar.Enable)
		return;
	
	// Utils.PrecacheCSSWeapons();
	Timers.AddTimerByName("timer_weaponlocker", 1.0, false, ::WeaponUnlocker.Timer_GenerateWeapon);
	printl("css weapon spawnning...");
}

function Notifications::OnWeaponReload::HelmsSG552Fix(player, manual, params)
{
	if(!::WeaponUnlocker.ConfigVar.PatchSG552)
		return;
	
	if(player.GetActiveWeapon().GetClassname() != "weapon_rifle_sg552")
		return;
	
	local nextAttack = player.GetNetPropFloat("m_flNextAttack") - 0.6;
	player.SetNetPropFloat("m_flNextAttack", nextAttack);
	player.GetActiveWeapon().SetNetPropFloat("m_flNextPrimaryAttack", nextAttack);
}

::WeaponUnlocker.PLUGIN_NAME <- PLUGIN_NAME;
::WeaponUnlocker.ConfigVar = ::WeaponUnlocker.ConfigVarDef;

function Notifications::OnRoundStart::WeaponUnlocker_LoadConfig()
{
	RestoreTable(::WeaponUnlocker.PLUGIN_NAME, ::WeaponUnlocker.ConfigVar);
	if(::WeaponUnlocker.ConfigVar == null || ::WeaponUnlocker.ConfigVar.len() <= 0)
		::WeaponUnlocker.ConfigVar = FileIO.GetConfigOfFile(::WeaponUnlocker.PLUGIN_NAME, ::WeaponUnlocker.ConfigVarDef);

	// printl("[plugins] " + ::WeaponUnlocker.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::WeaponUnlocker_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::WeaponUnlocker.PLUGIN_NAME, ::WeaponUnlocker.ConfigVar);

	// printl("[plugins] " + ::WeaponUnlocker.PLUGIN_NAME + " saving...");
}
