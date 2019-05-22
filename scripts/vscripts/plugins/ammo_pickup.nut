::AmmoPickup <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 7,

		// 是否开启机枪捡子弹
		M60 = true,

		// 是否开启榴弹捡子弹
		Grenade = true,

		// 是否开启捡子弹时弹夹补满
		FullClip = false,

		// 是否开启换弹夹时保留剩余弹药
		ReloadClip = false,
		
		// 是否防止 M60 没有子弹时被丢弃
		BlockM60Drop = true,
		
		// 是否防止 链锯 没有燃料时被丢弃
		BlockChainsawDrop = true,
		
		// 是否防止其他主武器在只剩下最后一颗子弹时开枪
		BlockPrimaryFiring = false
	},

	ConfigVar = {},

	LastClip = {},
	
	function GetWeaponMaxClip(weapon)
	{
		local classname = (typeof(weapon) == "string" ? weapon : weapon.GetClassname());
		classname = Utils.StringReplace(classname, "_spawn", "");
		
		switch(classname)
		{
			case "weapon_smg":
			case "weapon_smg_mp5":
			case "weapon_smg_silenced":
			case "weapon_rifle":
			case "weapon_rifle_sg552":
				return 50;
			case "weapon_shotgun_chrome":
			case "weapon_pumpshotgun":
				return 8;
			case "weapon_autoshotgun":
			case "weapon_shotgun_spas":
				return 10;
			case "weapon_rifle_ak47":
				return 40;
			case "weapon_rifle_desert":
				return 60;
			case "weapon_pistol_magnum":
				return 8;
			case "weapon_sniper_military":
				return 30;
			case "weapon_hunting_rifle":
			case "weapon_sniper_scout":
				return 15;
			case "weapon_sniper_awp":
				return 20;
			case "weapon_rifle_m60":
				return 150;
			case "weapon_grenade_launcher":
				return 1;
			case "weapon_pistol":
				if(typeof(weapon) != "string")
					return (weapon.GetNetPropBool("m_hasDualWeapons") ? 30 : 15);
				return 15;
		}
		
		return 0;
	},
	
	function TimerReload_OnPlayerReload(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.GetTeam() != SURVIVORS)
			return;
		
		local index = player.GetIndex();
		if(!(index in ::AmmoPickup.LastClip) || ::AmmoPickup.LastClip[index] <= 0)
			return;
		
		local weapon = player.GetActiveWeapon();
		if(weapon == null || !weapon.IsEntityValid() || !weapon.GetNetPropBool("m_bInReload") ||
			weapon.GetClip() > 0)
			return;
		
		local ammoType = weapon.GetNetPropInt("m_iPrimaryAmmoType");
		if(ammoType < AMMOTYPE_ASSAULTRIFLE || ammoType > AMMOTYPE_SNIPERRIFLE)
			return;
		
		weapon.SetClip(::AmmoPickup.LastClip[index]);
		player.SetNetPropInt("m_iAmmo", player.GetNetPropInt("m_iAmmo", ammoType) - ::AmmoPickup.LastClip[index],
			ammoType);
		
		delete ::AmmoPickup.LastClip[index];
	},
	
	function TimerButton_OnPlayerReloadPre(params)
	{
		if(!::AmmoPickup.ConfigVar.Enable)
			return;
		
		foreach(player in Players.AliveSurvivors())
		{
			if(!player.IsPressingReload())
				continue;
			
			local weapon = player.GetActiveWeapon();
			if(weapon == null || !weapon.IsEntityValid())
				continue;
			
			local clip = weapon.GetClip();
			if(clip <= 0)
				continue;
			
			local maxClip = ::AmmoPickup.GetWeaponMaxClip(weapon);
			if(maxClip <= 0 || clip >= maxClip)
				continue;
			
			::AmmoPickup.LastClip[player.GetIndex()] <- clip;
		}
	},
	
	HasForceReload = {},
	HasInReloadM60 = {},
	
	function Timer_CheckWeaponAmmo(player)
	{
		if(!::AmmoPickup.ConfigVar.Enable)
			return;
		
		local function CheckWeaponClip(player)
		{
			local weapon = player.GetActiveWeapon();
			if(weapon == null || !weapon.IsEntityValid())
				return;
			
			local classname = weapon.GetClassname();
			local clip = weapon.GetClip();
			
			if(classname == "weapon_rifle_m60")
			{
				if(::AmmoPickup.ConfigVar.BlockM60Drop && clip <= 1)
				{
					local index = player.GetIndex();
					
					if(weapon.GetAmmo() > 0)
					{
						::AmmoPickup.HasForceReload[index] <- true;
						player.ForceButton(BUTTON_RELOAD);
					}
					else
					{
						if(index in ::AmmoPickup.HasForceReload)
							delete ::AmmoPickup.HasForceReload[index];
						
						weapon.SetClip(1);
						weapon.SetNetPropFloat("m_flNextPrimaryAttack", Time() + 1.0);
						player.SetNetPropFloat("m_flNextAttack", Time() + 1.0);
					}
				}
			}
			else if(classname == "weapon_chainsaw")
			{
				if(::AmmoPickup.ConfigVar.BlockChainsawDrop && clip <= 1)
				{
					weapon.SetClip(1);
					weapon.SetNetPropFloat("m_flNextPrimaryAttack", Time() + 1.0);
					player.SetNetPropFloat("m_flNextAttack", Time() + 1.0);
				}
			}
			else if(classname.find("smg") != null || classname.find("shotgun") != null ||
				classname.find("rifle") != null || classname.find("sniper") != null ||
				classname.find("launcher") != null)
			{
				if(::AmmoPickup.ConfigVar.BlockPrimaryFiring && clip <= 1)
				{
					weapon.SetClip(1);
					weapon.SetNetPropFloat("m_flNextPrimaryAttack", Time() + 1.0);
					player.SetNetPropFloat("m_flNextAttack", Time() + 1.0);
				}
			}
		};
		
		if(player != null && "IsPlayerEntityValid" in player)
		{
			if(player.IsSurvivor() && player.IsAlive())
				CheckWeaponClip(player);
		}
		else
		{
			foreach(player in Players.AliveSurvivors())
				CheckWeaponClip(player);
		}
	},
	
	function EquipFakeWeapon(player, weapon)
	{
		if(player == null || !player.IsPlayerEntityValid() || !player.IsAlive() || !player.IsSurvivor() ||
			weapon == null || !weapon.IsEntityValid() || weapon.GetClassname().find("weapon_") != 0)
			return null;
		
		local entity = Utils.CreateEntity(classname, player.GetLocation(), player.GetEyeAngles());
		if(entity == null)
			return null;
		
		entity.SetClip(0);
		entity.SetNetPropInt("m_upgradeBitVec", weapon.GetNetPropInt("m_upgradeBitVec"));
		entity.SetNetPropInt("m_nUpgradedPrimaryAmmoLoaded", weapon.GetNetPropInt("m_nUpgradedPrimaryAmmoLoaded"));
		entity.SetAmmo(weapon.GetAmmo());
		
		weapon.Kill();
		entity.Input("Use", "", 0, player);
		return true;
	}
}

function Notifications::OnRoundBegin::AmmoPickupActtive(params)
{
	Timers.AddTimerByName("timer_reloadstart", 0.1, true, ::AmmoPickup.TimerButton_OnPlayerReloadPre);
	Timers.AddTimerByName("timer_weaponammocheck", 0.1, true, ::AmmoPickup.Timer_CheckWeaponAmmo);
}

function Notifications::FirstSurvLeftStartArea::AmmoPickupActtive(player, params)
{
	Timers.AddTimerByName("timer_reloadstart", 0.1, true, ::AmmoPickup.TimerButton_OnPlayerReloadPre);
	Timers.AddTimerByName("timer_weaponammocheck", 0.1, true, ::AmmoPickup.Timer_CheckWeaponAmmo);
}

function Notifications::OnAmmoCantUse::AmmoPickupGrenade(player, params)
{
	if(!::AmmoPickup.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayerEntityValid() || player.GetTeam() != SURVIVORS)
		return;
	
	local inv = player.GetHeldItems();
	if(!("slot0" in inv) || inv["slot0"] == null || !inv["slot0"].IsEntityValid())
		return;
	
	local classname = inv["slot0"].GetClassname();
	if(classname == "weapon_rifle_m60" && ::AmmoPickup.ConfigVar.M60 ||
		classname == "weapon_grenade_launcher" && ::AmmoPickup.ConfigVar.Grenade)
	{
		// player.GiveAmmo(999);
		
		local ammoType = inv["slot0"].GetNetPropInt("m_iPrimaryAmmoType");
		/*
		player.SetNetPropInt("m_iAmmo", player.GetNetPropInt("m_iAmmo", ammoType) +
			::AmmoPickup.GetWeaponMaxClip(inv["slot0"]) - inv["slot0"].GetClip(), ammoType);
		*/
		
		player.SetNetPropInt("m_iAmmo", ::AmmoPickup.GetWeaponMaxClip(inv["slot0"]) +
			inv["slot0"].GetMaxAmmo() - inv["slot0"].GetClip(), ammoType);
		
		if(inv["slot0"].GetNetPropBool("m_bInReload"))
		{
			inv["slot0"].SetNetPropInt("m_bInReload", 0);
			inv["slot0"].SetNetPropInt("m_reloadState", 0);
			inv["slot0"].SetNetPropInt("m_reloadAnimState", 0);
			player.ClientCommand("lastinv");
		}
		
		printl("player " + player.GetName() + " pickup ammo with " + classname);
	}
}

function Notifications::OnAmmoPickup::AmmoPickupFullClip(player, params)
{
	if(!::AmmoPickup.ConfigVar.Enable || !::AmmoPickup.ConfigVar.FullClip)
		return;
	
	if(player == null || !player.IsPlayerEntityValid() || player.GetTeam() != SURVIVORS)
		return;
	
	local inv = player.GetHeldItems();
	if("slot0" in inv && inv["slot0"] != null && inv["slot0"].IsEntityValid())
	{
		local maxClip = ::AmmoPickup.GetWeaponMaxClip(inv["slot0"]);
		local classname = inv["slot0"].GetClassname();
		local clip = inv["slot0"].GetClip();
		
		if((maxClip = maxClip - clip) > 0 &&
			(classname != "weapon_rifle_m60" || !::AmmoPickup.ConfigVar.M60) &&
			(classname != "weapon_grenade_launcher" || !::AmmoPickup.ConfigVar.Grenade))
		{
			local ammoType = inv["slot0"].GetNetPropInt("m_iPrimaryAmmoType");
			if(ammoType >= AMMOTYPE_ASSAULTRIFLE && ammoType <= AMMOTYPE_SNIPERRIFLE)
			{
				local ammo = player.GetNetPropInt("m_iAmmo", ammoType);
				player.SetNetPropInt("m_iAmmo", ammo - maxClip, ammoType);
				inv["slot0"].SetClip(maxClip + clip);
				
				if(inv["slot0"].GetNetPropBool("m_bInReload"))
				{
					inv["slot0"].SetNetPropInt("m_bInReload", 0);
					inv["slot0"].SetNetPropInt("m_reloadState", 0);
					inv["slot0"].SetNetPropInt("m_reloadAnimState", 0);
					player.ClientCommand("lastinv");
				}
				
				printl("player " + player.GetName() + " pickup ammo by " + classname);
			}
		}
	}
	
	if("slot1" in inv && inv["slot1"] != null && inv["slot1"].IsEntityValid())
	{
		local maxClip = ::AmmoPickup.GetWeaponMaxClip(inv["slot1"]);
		local clip = inv["slot1"].GetClip();
		
		if(clip < maxClip)
		{
			inv["slot1"].SetClip(maxClip);
			
			if(inv["slot1"].GetNetPropBool("m_bInReload"))
			{
				inv["slot1"].SetNetPropInt("m_bInReload", 0);
				inv["slot1"].SetNetPropInt("m_reloadState", 0);
				inv["slot1"].SetNetPropInt("m_reloadAnimState", 0);
				player.ClientCommand("lastinv");
			}
			
			printl("player " + player.GetName() + " pickup ammo by " + inv["slot1"].GetClassname());
		}
	}
}

function Notifications::OnWeaponReload::AmmoPickupReloadClip(player, manually, params)
{
	if(!::AmmoPickup.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayerEntityValid() || player.GetTeam() != SURVIVORS)
		return;
	
	player.UnforceButton(BUTTON_RELOAD);
	
	if(!::AmmoPickup.ConfigVar.ReloadClip || !manually)
		return;
	
	local index = player.GetIndex();
	if(index in ::AmmoPickup.HasForceReload)
	{
		delete ::AmmoPickup.HasForceReload[index];
		player.SetNetPropInt("m_releasedFireButton", 1);
		player.SetNetPropFloat("m_flNextAttack", Time() + 2.0);
	}
	
	// ::AmmoPickup.LastClip[index] <- player.GetActiveWeapon().GetClip();
	
	/*
	Timers.AddTimerByName("timer_reloading_" + index, 0.1, false,
		::AmmoPickup.TimerReload_OnPlayerReload, player);
	*/
	
	if(index in ::AmmoPickup.LastClip)
		printl("player " + player.GetName() + " reloading start " + ::AmmoPickup.LastClip[index]);
	
	::AmmoPickup.TimerReload_OnPlayerReload(player);
}

function Notifications::OnWeaponFire::AmmoPickup_BlockDrop(player, classname, params)
{
	if(!::AmmoPickup.ConfigVar.Enable || !::AmmoPickup.ConfigVar.BlockM60Drop)
		return;
	
	if(classname != "weapon_rifle_m60")
		return;
	
	if(player == null || !player.IsPlayerEntityValid() || player.GetTeam() != SURVIVORS || player.IsDead())
		return;
	
	local weapon = player.GetActiveWeapon();
	if(weapon == null || !weapon.IsEntityValid() || weapon.GetClassname() != classname)
		return;
	
	local index = player.GetIndex();
	local clip = weapon.GetClip();
	
	if(clip == 1)
		::AmmoPickup.HasInReloadM60[index] <- true;
	
	if(weapon.GetNetPropBool("m_bInReload"))
		return;
	
	if(clip <= 1 && index in ::AmmoPickup.HasInReloadM60)
	{
		local newWeapon = Utils.CreateEntity("weapon_rifle_m60");
		local upgrade = weapon.GetNetPropInt("m_upgradeBitVec");
		local upgradeAmmo = weapon.GetNetPropInt("m_nUpgradedPrimaryAmmoLoaded");
		
		weapon.Kill();
		delete ::AmmoPickup.HasInReloadM60[index];
		
		newWeapon.Use(player);
		newWeapon.SetClip(0);
		newWeapon.SetAmmo(weapon.GetAmmo());
		newWeapon.SetNetPropInt("m_upgradeBitVec", upgrade);
		newWeapon.SetNetPropInt("m_nUpgradedPrimaryAmmoLoaded", upgradeAmmo);
	}
}


::AmmoPickup.PLUGIN_NAME <- PLUGIN_NAME;
::AmmoPickup.ConfigVar = ::AmmoPickup.ConfigVarDef;

function Notifications::OnRoundStart::AmmoPickup_LoadConfig()
{
	RestoreTable(::AmmoPickup.PLUGIN_NAME, ::AmmoPickup.ConfigVar);
	if(::AmmoPickup.ConfigVar == null || ::AmmoPickup.ConfigVar.len() <= 0)
		::AmmoPickup.ConfigVar = FileIO.GetConfigOfFile(::AmmoPickup.PLUGIN_NAME, ::AmmoPickup.ConfigVarDef);

	// printl("[plugins] " + ::AmmoPickup.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::AmmoPickup_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::AmmoPickup.PLUGIN_NAME, ::AmmoPickup.ConfigVar);

	// printl("[plugins] " + ::AmmoPickup.PLUGIN_NAME + " saving...");
}
