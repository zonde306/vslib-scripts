::BotDeployers <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
		
		// 思考间隔
		ThinkInterval = 1.0,
		
		// 低弹药数百分比
		LowAmmoBound = 0.25,
	},
	
	ConfigVar = {},
	
	function Timer_Think(params)
	{
		foreach(player in Players.AliveSurvivorBots())
		{
			if(player.IsIncapacitated() || player.IsHangingFromLedge() /*|| player.HasVisibleThreats()*/ || player.IsInCombat())
				continue;
			
			local upgrade = player.GetWeaponSlot(SLOT_MEDKIT);
			if(upgrade == null)
				continue;
			
			local classname = upgrade.GetClassname();
			if(classname.find("upgradepack") == null)
				continue;
			
			if(!::BotDeployers.HasLowAmmo(player))
				continue;
			
			if(player.GetActiveWeapon() != upgrade)
			{
				player.SwitchWeapon(classname);
				printl("bot " + player.GetName() + " switch to " + classname);
			}
			
			player.ForceButton(BUTTON_ATTACK);
			Timers.AddTimerByName("botdeployers_" + player.GetIndex(), 6.0, false, ::BotDeployers.Timer_StopFire, player, 0, { "action" : "reset" });
			printl("bot " + player.GetName() + " deploying " + classname);
		}
	},
	
	function Timer_StopFire(player)
	{
		if(player == null || !player.IsSurvivor())
			return;
		
		player.UnforceButton(BUTTON_ATTACK);
	},
	
	function HasLowAmmo(player)
	{
		if(player == null || !player.IsSurvivor() || player.IsDead() || player.IsIncapacitated() || player.IsHangingFromLedge())
			return false;
		
		local weapon = player.GetWeaponSlot(SLOT_PRIMARY);
		if(weapon == null || !weapon.IsValid())
			return false;
		
		local maxAmmo = 0;
		local classname = player.GetClassname();
		switch(classname)
		{
			case "weapon_smg":
			case "weapon_smg_silenced":
			case "weapon_smg_mp5":
			{
				maxAmmo = Convars.GetFloat("ammo_smg_max") + 50;
				break;
			}
			case "weapon_pumpshotgun":
			case "weapon_shotgun_chrome":
			{
				maxAmmo = Convars.GetFloat("ammo_shotgun_max") + 8;
				break;
			}
			case "weapon_rifle":
			case "weapon_rifle_ak47":
			case "weapon_rifle_desert":
			case "weapon_rifle_sg552":
			{
				maxAmmo = Convars.GetFloat("ammo_assaultrifle_max") + 40;
				break;
			}
			case "weapon_autoshotgun":
			case "weapon_shotgun_spas":
			{
				maxAmmo = Convars.GetFloat("ammo_autoshotgun_max") + 10;
				break;
			}
			case "weapon_hunting_rifle":
			{
				maxAmmo = Convars.GetFloat("ammo_huntingrifle_max") + 15;
				break;
			}
			case "weapon_sniper_military":
			case "weapon_sniper_scout":
			case "weapon_sniper_awp":
			{
				maxAmmo = Convars.GetFloat("ammo_sniperrifle_max") + 30;
				break;
			}
			case "weapon_rifle_m60":
			{
				maxAmmo = Convars.GetFloat("ammo_m60_max") + 150;
				break;
			}
			case "weapon_grenade_launcher":
			{
				maxAmmo = Convars.GetFloat("ammo_grenadelauncher_max") + 1;
				break;
			}
		}
		
		if(maxAmmo <= 0)
			return false;
		
		local ammo = player.GetPrimaryAmmo() + player.GetPrimaryClip();
		if(ammo.tofloat() / maxAmmo.tofloat() <= ::BotDeployers.ConfigVar.LowAmmoBound)
			return true;
		
		return false;
	},
};

function Notifications::FirstSurvLeftStartArea::BotDeployers_StartThink(player, params)
{
	if(!::BotDeployers.ConfigVar.Enable)
		return;
	
	Timers.AddTimerByName("bot_deployers", ::BotDeployers.ConfigVar.ThinkInterval, true, ::BotDeployers.Timer_Think);
}

function Notifications::OnSurvivorsLeftStartArea::BotDeployers_StartThink()
{
	if(!::BotDeployers.ConfigVar.Enable)
		return;
	
	Timers.AddTimerByName("bot_deployers", ::BotDeployers.ConfigVar.ThinkInterval, true, ::BotDeployers.Timer_Think);
}

function Notifications::OnHurt::BotDeployers_Stopped(victim, attacker, params)
{
	if(!::BotDefibrillator.ConfigVar.Enable)
		return;
	
	if(victim == null || !victim.IsSurvivor() || !victim.IsBot())
		return;
	
	// 被打时放弃部署
	if(Timers.RemoveTimerByName("botdeployers_" + victim.GetIndex()))
		victim.UnforceButton(BUTTON_ATTACK);
}

function Notifications::OnUpgradeDeployed::BotDeployers_StopFire(deployer, upgrade, params)
{
	if(!::BotDeployers.ConfigVar.Enable)
		return;
	
	if(deployer == null || !deployer.IsSurvivor())
		return;
	
	deployer.UnforceButton(BUTTON_ATTACK);
}

::BotDeployers.PLUGIN_NAME <- PLUGIN_NAME;
::BotDeployers.ConfigVar = ::BotDeployers.ConfigVarDef;

function Notifications::OnRoundStart::BotDeployers_LoadConfig()
{
	RestoreTable(::BotDeployers.PLUGIN_NAME, ::BotDeployers.ConfigVar);
	if(::BotDeployers.ConfigVar == null || ::BotDeployers.ConfigVar.len() <= 0)
		::BotDeployers.ConfigVar = FileIO.GetConfigOfFile(::BotDeployers.PLUGIN_NAME, ::BotDeployers.ConfigVarDef);

	// printl("[plugins] " + ::BotDeployers.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::BotDeployers_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::BotDeployers.PLUGIN_NAME, ::BotDeployers.ConfigVar);

	// printl("[plugins] " + ::BotDeployers.PLUGIN_NAME + " saving...");
}
