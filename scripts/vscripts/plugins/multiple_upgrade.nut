::MultipleUpgrade <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,

		// 是否开启发现激光升级提示
		LaserFound = true,

		// 是否开启激光升级转移
		LaserTransfer = true,

		// 激光转移需要多久(秒)
		LaserDuration = 3,

		// 转移激光需要的距离
		LaserRadius = 75,

		// 捡起燃烧升级包获得多少倍弹药(百分比)
		IncendiaryMultiple = 200,

		// 捡起爆炸升级包获得多少倍弹药(百分比)
		ExplosiveMultiple = 150,

		// 是否允许燃烧升级叠加
		IncendiarySuperimposed = true,

		// 是否允许爆炸升级叠加
		ExplosiveSuperimposed = true,
		
		// 放置弹药包时附赠子弹堆
		SpawnAmmoStack = true,
	},

	ConfigVar = {},

	UpgradeType = {},
	UpgradeAmmo = {},
	LaserGrabbed = {},
	LaserTime = {}
	
	// 玩家(生还者)是否需要帮助(是否倒地/挂边/被控)
	function IsNeedHelp(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead())
			return false;
		
		if(player.IsIncapacitated() || player.IsHangingFromLedge() || player.IsHangingFromTongue() ||
			player.IsBeingJockeyed() || player.IsPounceVictim() || player.IsTongueVictim() ||
			player.IsCarryVictim() || player.IsPummelVictim())
			return true;
		
		return false;
	},
	
	// 设置玩家的进度条(打包倒油那个)时间
	function SetProgressBarTime(player, time = 0.0)
	{
		if(player == null || !player.IsPlayerEntityValid())
			return;
		
		player.SetNetPropFloat("m_flProgressBarStartTime", Time());
		player.SetNetPropFloat("m_flProgressBarDuration", time);
	},
	
	// 检查该武器是否为主武器
	function IsPrimaryWeapon(weapon)
	{
		local classname = (typeof(weapon) == "string" ? weapon : weapon.GetClassname());
		classname = Utils.StringReplace(classname, "_spawn", "");
		
		if(classname.find("weapon_") != 0)
			return false;
		
		return (classname == "weapon_smg" || classname == "weapon_smg_mp5" || classname == "weapon_smg_silenced" ||
			classname == "weapon_pumpshotgun" || classname == "weapon_shotgun_chrome" ||
			classname == "weapon_autoshotgun" || classname == "weapon_shotgun_spas" || classname == "weapon_rifle" ||
			classname == "weapon_rifle_ak47" || classname == "weapon_rifle_desert" ||
			classname == "weapon_rifle_sg552" || classname == "weapon_rifle_m60" ||
			classname == "weapon_hunting_rifle" || classname == "weapon_sniper_military" ||
			classname == "weapon_sniper_scout" || classname == "weapon_sniper_awp" ||
			classname == "weapon_grenade_launcher");
	},
	
	function TimerLaser_OnPlayerThink(params)
	{
		if(!::MultipleUpgrade.ConfigVar.LaserTransfer)
		{
			foreach(index, idx in ::MultipleUpgrade.LaserGrabbed)
			{
				local player = ::VSLib.Player(index);
				if(player != null && player.IsPlayerEntityValid())
					::MultipleUpgrade.SetProgressBarTime(player);
			}
			
			::MultipleUpgrade.LaserGrabbed.clear();
			::MultipleUpgrade.LaserTime.clear();
			
			return;
		}
		
		local time = Time();
		foreach(player in Players.AliveSurvivors())
		{
			local index = player.GetIndex();
			
			if(!player.IsPressingDuck() || ::MultipleUpgrade.IsNeedHelp(player))
			{
				if(index in ::MultipleUpgrade.LaserGrabbed)
				{
					delete ::MultipleUpgrade.LaserTime[::MultipleUpgrade.LaserGrabbed[index]];
					delete ::MultipleUpgrade.LaserGrabbed[index];
					::MultipleUpgrade.SetProgressBarTime(player);
					
					printl("player grab laser from weapon stopped");
				}
				
				continue;
			}
			
			local inv = player.GetHeldItems();
			if(!("slot0" in inv) || inv["slot0"] == null || !inv["slot0"].IsEntityValid())
				continue;
			
			if(inv["slot0"].GetNetPropInt("m_upgradeBitVec") & 4)
				continue;
			
			local weapon = null;
			local pos = player.GetLocation();
			if(!(index in ::MultipleUpgrade.LaserGrabbed) ||
				!(::MultipleUpgrade.LaserGrabbed[index] in ::MultipleUpgrade.LaserTime) ||
				(weapon = ::VSLib.Entity(::MultipleUpgrade.LaserGrabbed[index])) == null ||
				!weapon.IsEntityValid() || weapon.GetOwnerEntity() != null)
			{
				foreach(entity in Objects.AroundRadius(pos, ::MultipleUpgrade.ConfigVar.LaserRadius))
				{
					local idx = entity.GetIndex();
					if(idx in ::MultipleUpgrade.LaserTime)
						continue;
					
					local classname = entity.GetClassname();
					if(!::MultipleUpgrade.IsPrimaryWeapon(classname) || entity.GetOwnerEntity() != null ||
						!(entity.GetNetPropInt("m_upgradeBitVec") & 4) || classname.find("_spawn") != null ||
						Utils.CalculateDistance(entity.GetLocation(), pos) > ::MultipleUpgrade.ConfigVar.LaserRadius)
						continue;
					
					weapon = entity;
					::MultipleUpgrade.LaserTime[idx] <- time + ::MultipleUpgrade.ConfigVar.LaserDuration;
					::MultipleUpgrade.LaserGrabbed[index] <- idx;
					::MultipleUpgrade.SetProgressBarTime(player, ::MultipleUpgrade.ConfigVar.LaserDuration);
					
					printl("player " + player.GetName() + " start grab laser from weapon " + classname);
				}
			}
			else if(::MultipleUpgrade.LaserTime[::MultipleUpgrade.LaserGrabbed[index]] <= time)
			{
				delete ::MultipleUpgrade.LaserTime[::MultipleUpgrade.LaserGrabbed[index]];
				delete ::MultipleUpgrade.LaserGrabbed[index];
				weapon.SetNetPropInt("m_upgradeBitVec", weapon.GetNetPropInt("m_upgradeBitVec") & ~4);
				inv["slot0"].SetNetPropInt("m_upgradeBitVec", inv["slot0"].GetNetPropInt("m_upgradeBitVec") | 4);
				::MultipleUpgrade.SetProgressBarTime(player);
				
				printl("player " + player.GetName() + " success grab laser from weapon " + weapon.GetClassname());
			}
			else if(Utils.CalculateDistance(weapon.GetLocation(), pos) > ::MultipleUpgrade.ConfigVar.LaserRadius)
			{
				delete ::MultipleUpgrade.LaserTime[::MultipleUpgrade.LaserGrabbed[index]];
				delete ::MultipleUpgrade.LaserGrabbed[index];
				::MultipleUpgrade.SetProgressBarTime(player);
				
				printl("player " + player.GetName() + " fail grab laser from weapon " + weapon.GetClassname());
			}
		}
	},
	
	function TimerButton_OnPlayerUse(params)
	{
		foreach(player in Players.AliveSurvivors())
		{
			if(!player.IsPressingUse() || ::MultipleUpgrade.IsNeedHelp(player))
				continue;
			
			local inv = player.GetHeldItems();
			if(!("slot0" in inv) || inv["slot0"] == null || !inv["slot0"].IsEntityValid())
				return;
			
			local index = inv["slot0"].GetIndex();
			local upgrade = inv["slot0"].GetUpgrades();
			
			if(upgrade & 1)
				::MultipleUpgrade.UpgradeType[index] <- 1;
			else if(upgrade & 2)
				::MultipleUpgrade.UpgradeType[index] <- 2;
			else
				::MultipleUpgrade.UpgradeType[index] <- 0;
			
			if(upgrade & 3)
				::MultipleUpgrade.UpgradeAmmo[index] <- inv["slot0"].GetNetPropInt("m_nUpgradedPrimaryAmmoLoaded");
			else
				::MultipleUpgrade.UpgradeAmmo[index] <- 0;
			
			// printl("player " + player.GetName() + " pickup upgrade pre ammo is " + ::MultipleUpgrade.UpgradeAmmo[index]);
		}
	}
}

function Notifications::OnRoundBegin::MultipleUpgrade(params)
{
	Timers.AddTimerByName("timer_lasertransfer", 0.1, true, ::MultipleUpgrade.TimerLaser_OnPlayerThink);
	Timers.AddTimerByName("timer_upgradepre", 0.1, true, ::MultipleUpgrade.TimerButton_OnPlayerUse);
}

function Notifications::FirstSurvLeftStartArea::MultipleUpgrade(player, params)
{
	Timers.AddTimerByName("timer_lasertransfer", 0.1, true, ::MultipleUpgrade.TimerLaser_OnPlayerThink);
	Timers.AddTimerByName("timer_upgradepre", 0.1, true, ::MultipleUpgrade.TimerButton_OnPlayerUse);
}

/*
function Notifications::CanPickupObject::MultipleUpgradePicupPre(entity, classname)
{
	if(!::MultipleUpgrade.ConfigVar.Enable)
		return true;
	
	if(classname != "upgrade_ammo_incendiary" && classname != "upgrade_ammo_explosive")
		return true;
	
	local client = null;
	foreach(player in Players.AliveSurvivors())
	{
		if(!player.IsPressingUse())
			continue;
		
		local aiming = player.GetLookingEntity();
		if(aiming != null && aiming.IsEntityValid() && aiming == entity)
		{
			client = player;
			break;
		}
	}
	
	if(client == null)
		return true;
	
	local inv = client.GetHeldItems();
	if(!("slot0" in inv) || inv["slot0"] == null || !inv["slot0"].IsEntityValid())
		return true;
	
	local index = inv["slot0"].GetIndex();
	local upgrade = inv["slot0"].GetUpgrades();
	
	if(upgrade & 1)
		::MultipleUpgrade.UpgradeType[index] <- 1;
	else if(upgrade & 2)
		::MultipleUpgrade.UpgradeType[index] <- 2;
	
	if(upgrade & 3)
		::MultipleUpgrade.UpgradeAmmo[index] <- inv["slot0"].GetNetPropInt("m_nUpgradedPrimaryAmmoLoaded");
	
	printl("player " + aiming.GetName() + " pickup upgrade pre ammo is " + ::MultipleUpgrade.UpgradeAmmo[index]);
	
	return true;
}
*/

/*
function Notifications::OnUse::MultipleUpgradePicupPre(player, entity, params)
{
	if(!::MultipleUpgrade.ConfigVar.Enable)
		return;
	
	if(entity == null || player == null || !player.IsPlayerEntityValid() || !entity.IsEntityValid() ||
		player.IsDead() || player.GetTeam() != SURVIVORS)
		return;
	
	local inv = player.GetHeldItems();
	if(!("slot0" in inv) || inv["slot0"] == null || !inv["slot0"].IsEntityValid())
		return;
	
	local index = inv["slot0"].GetIndex();
	local upgrade = inv["slot0"].GetUpgrades();
	
	if(upgrade & 1)
		::MultipleUpgrade.UpgradeType[index] <- 1;
	else if(upgrade & 2)
		::MultipleUpgrade.UpgradeType[index] <- 2;
	else
		::MultipleUpgrade.UpgradeType[index] <- 0;
	
	if(upgrade & 3)
		::MultipleUpgrade.UpgradeAmmo[index] <- inv["slot0"].GetNetPropInt("m_nUpgradedPrimaryAmmoLoaded");
	else
		::MultipleUpgrade.UpgradeAmmo[index] <- 0;
	
	printl("player " + player.GetName() + " pickup upgrade pre ammo is " + ::MultipleUpgrade.UpgradeAmmo[index]);
}
*/

function Notifications::OnUpgradePackAdded::MultipleUpgradePicupPost(player, entity, params)
{
	if(!::MultipleUpgrade.ConfigVar.Enable)
		return;
	
	if(entity == null || player == null || !player.IsPlayerEntityValid() || !entity.IsEntityValid() ||
		player.IsDead() || player.GetTeam() != SURVIVORS)
		return;
	
	local upgrade = 0;
	local classname = entity.GetClassname();
	if(classname == "upgrade_ammo_incendiary")
		upgrade = 1;
	else if(classname == "upgrade_ammo_explosive")
		upgrade = 2;
	else if(classname == "upgrade_laser_sight")
		upgrade = 4;
	else
		return;
	
	if(upgrade == 4)
	{
		if(::MultipleUpgrade.ConfigVar.LaserFound)
		{
			local pos = player.GetLocation();
			foreach(entity in Objects.OfClassnameWithin("upgrade_laser_sight", pos, 100))
			{
				Utils.SetEntityHint(entity, player.GetName() + " found laser sight", "icon_laser_sight",
					0, true, 9.0);
				
				entity.SetNetPropInt("m_iGlowType", 3);
				entity.SetNetPropInt("m_nGlowRange", 2048);
				entity.SetNetPropInt("m_glowColorOverride", 65534);
			}
		}
		
		return;
	}
	
	local inv = player.GetHeldItems();
	if(!("slot0" in inv) || inv["slot0"] == null || !inv["slot0"].IsEntityValid())
		return;
	
	local upgradeAmmo = inv["slot0"].GetNetPropInt("m_nUpgradedPrimaryAmmoLoaded");
	upgradeAmmo *= (upgrade == 1 ? ::MultipleUpgrade.ConfigVar.IncendiaryMultiple : ::MultipleUpgrade.ConfigVar.ExplosiveMultiple);
	upgradeAmmo /= 100;
	
	local index = inv["slot0"].GetIndex();
	if(index in ::MultipleUpgrade.UpgradeType)
	{
		if(::MultipleUpgrade.UpgradeType[index] == upgrade)
			upgradeAmmo += ::MultipleUpgrade.UpgradeAmmo[index];
		
		delete ::MultipleUpgrade.UpgradeType[index];
		delete ::MultipleUpgrade.UpgradeAmmo[index];
	}
	
	if(upgradeAmmo > 255)
		upgradeAmmo = 255;
	if(upgradeAmmo < 0)
		upgradeAmmo = 0;
	
	inv["slot0"].SetNetPropInt("m_nUpgradedPrimaryAmmoLoaded", upgradeAmmo);
	printl("player " + player.GetName() + " pickup upgrade post ammo is " + upgradeAmmo);
}

function Notifications::OnUpgradeDeployed::MultipleUpgradeDeployed(deployer, upgrade, params)
{
	if(!::MultipleUpgrade.ConfigVar.Enable)
		return;
	
	if(!::MultipleUpgrade.ConfigVar.SpawnAmmoStack)
		return;
	
	if(upgrade == null || !upgrade.IsValid())
		return;
	
	local origin = upgrade.GetLocation();
	
	origin.x -= 10.0;
	origin.y -= 10.0;
	upgrade.SetLocation(origin);
	
	origin.x += 20.0;
	origin.y += 20.0;
	Utils.SpawnAmmo("models/props/terror/ammo_stack.mdl", origin);
}

::MultipleUpgrade.PLUGIN_NAME <- PLUGIN_NAME;
::MultipleUpgrade.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::MultipleUpgrade.ConfigVarDef);

function Notifications::OnRoundStart::MultipleUpgrade_LoadConfig()
{
	RestoreTable(::MultipleUpgrade.PLUGIN_NAME, ::MultipleUpgrade.ConfigVar);
	if(::MultipleUpgrade.ConfigVar == null || ::MultipleUpgrade.ConfigVar.len() <= 0)
		::MultipleUpgrade.ConfigVar = FileIO.GetConfigOfFile(::MultipleUpgrade.PLUGIN_NAME, ::MultipleUpgrade.ConfigVarDef);

	// printl("[plugins] " + ::MultipleUpgrade.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::MultipleUpgrade_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::MultipleUpgrade.PLUGIN_NAME, ::MultipleUpgrade.ConfigVar);

	// printl("[plugins] " + ::MultipleUpgrade.PLUGIN_NAME + " saving...");
}
