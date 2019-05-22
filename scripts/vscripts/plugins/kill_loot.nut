::KillLoot <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = false,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 4,

		// 是否禁止地图自带的刷枪械
		DisableDirectorSpawner = false,

		// 僵尸死亡后掉落的物品多少秒后消失
		LootRemoveDelay = 30,

		// 武器被丢弃多少秒后消失
		DropRemoveDelay = 16
	},

	ConfigVar = {},

	CommonLoot =
	[
		{ent = "weapon_pistol", prob = 100, ammo = null, melee_type = null},
		{ent = "weapon_smg", prob = 60, ammo = 0, melee_type = null},
		{ent = "weapon_smg_silenced", prob = 55, ammo = 0, melee_type = null},
		{ent = "weapon_smg_mp5", prob = 50, ammo = 0, melee_type = null},
		{ent = "weapon_pumpshotgun", prob = 55, ammo = 0, melee_type = null},
		{ent = "weapon_shotgun_chrome", prob = 50, ammo = 0, melee_type = null},
		{ent = "weapon_sniper_scout", prob = 25, ammo = 0, melee_type = null},
		
		{ent = "weapon_vomitjar", prob = 30, ammo = null, melee_type = null},
		{ent = "weapon_molotov", prob = 40, ammo = null, melee_type = null},
		{ent = "weapon_pipe_bomb", prob = 50, ammo = null, melee_type = null},
		{ent = "weapon_adrenaline", prob = 5, ammo = null, melee_type = null},
		{ent = "weapon_pain_pills", prob = 1, ammo = null, melee_type = null},
		
		// 不掉落物品
		{ent = null, prob = 3000, ammo = null, melee_type = null},
		{ent = "ammo_single", prob = 1000, ammo = null, melee_type = null}
	],
	
	SpecialLoot =
	[
		{ent = "weapon_pistol_magnum", prob = 1, ammo = null, melee_type = null},
		{ent = "weapon_melee_spawn", prob = 3, ammo = null, melee_type = "any"},
		{ent = "weapon_rifle", prob = 50, ammo = 50, melee_type = null},
		{ent = "weapon_rifle_ak47", prob = 40, ammo = 40, melee_type = null},
		{ent = "weapon_rifle_desert", prob = 45, ammo = 60, melee_type = null},
		{ent = "weapon_rifle_sg552", prob = 45, ammo = 50, melee_type = null},
		{ent = "weapon_autoshotgun", prob = 50, ammo = 10, melee_type = null},
		{ent = "weapon_shotgun_spas", prob = 45, ammo = 10, melee_type = null},
		{ent = "weapon_hunting_rifle", prob = 50, ammo = 15, melee_type = null},
		{ent = "weapon_sniper_military", prob = 40, ammo = 30, melee_type = null},
		{ent = "weapon_sniper_awp", prob = 20, ammo = 20, melee_type = null},
		
		{ent = "weapon_upgradepack_explosive", prob = 25, ammo = null, melee_type = null},
		{ent = "weapon_upgradepack_incendiary", prob = 30, ammo = null, melee_type = null},
		{ent = "upgrade_spawn", prob = 10, ammo = null, melee_type = null},
		{ent = "weapon_vomitjar", prob = 45, ammo = null, melee_type = null},
		{ent = "weapon_molotov", prob = 50, ammo = null, melee_type = null},
		{ent = "weapon_pipe_bomb", prob = 55, ammo = null, melee_type = null},
		{ent = "weapon_adrenaline", prob = 35, ammo = null, melee_type = null},
		{ent = "weapon_pain_pills", prob = 20, ammo = null, melee_type = null},
		{ent = "weapon_defibrillator", prob = 15, ammo = null, melee_type = null},
		{ent = "weapon_first_aid_kit", prob = 10, ammo = null, melee_type = null},
		
		// 不掉落物品
		// {ent = null, prob = 1000, ammo = null, melee_type = null},
		{ent = "weapon_ammo_pack", prob = 500, ammo = null, melee_type = null}
	],
	
	OldAllowDirectorSpawner = null,
	AllowDirectorSpawner =
	{
		weapon_first_aid_kit = true,
		weapon_pain_pills = true,
		weapon_gascan = true,
		weapon_propanetank = true,
		weapon_oxygentank = true,
		weapon_fireworkcrate = true,
		upgrade_laser_sight = true,
		upgrade_ammo_incendiary = true,
		upgrade_ammo_explosive = true
	},
	
	OldConvertDirectorSpawner = null,
	ConvertDirectorSpawner =
	{
		
	},
	
	OldDefaultDirectorWeapon = null,
	DefaultDirectorWeapon =
	[
		"weapon_pistol"
	],
	
	HasFirstRound = true,
	AmmoPickupAmount =
	{
		weapon_smg = 50,
		weapon_smg_silenced = 50,
		weapon_smg_mp5 = 50,
		weapon_pumpshotgun = 8,
		weapon_shotgun_chrome = 8.
		weapon_autoshotgun = 10,
		weapon_shotgun_spas = 10,
		weapon_rifle = 50,
		weapon_rifle_ak47 = 40,
		weapon_rifle_desert = 60,
		weapon_rifle_sg552 = 50,
		weapon_hunting_rifle = 15,
		weapon_sniper_military = 30,
		weapon_sniper_scout = 15,
		weapon_sniper_awp = 20,
		weapon_rifle_m60 = 50
	},
	
	function OnOutput_RemoveEntity()
	{
		if(caller == null || !caller.IsValid())
			return;
		
		local entity = ::VSLib.Entity(caller);
		if(entity.GetOwnerEntity() != null)
			return;
		
		entity.Kill();
		return;
	},
	
	function OnOutput_TouchAmmoPack()
	{
		if(caller == null || !caller.IsValid() || activator == null || !activator.IsValid() || !activator.IsSurvivor())
			return;
		
		local entity = ::VSLib.Entity(caller);
		local player = ::VSLib.Player(activator);
		
		if(player.IsBot())
			entity.Input("FireUser4", "", 0, player);
	},
	
	function OnOutput_PickupAmmoSingle()
	{
		if(caller == null || !caller.IsValid() || activator == null || !activator.IsValid() || !activator.IsSurvivor())
			return;
		
		local entity = ::VSLib.Entity(caller);
		local player = ::VSLib.Player(activator);
		
		local inv = player.GetHeldItems();
		if(!("slot0" in inv) || inv["slot0"] == null || !inv["slot0"].IsEntityValid())
			return;
		
		local classname = inv["slot0"].GetClassname();
		if(classname in ::KillLoot.AmmoPickupAmount && ::KillLoot.AmmoPickupAmount[classname] > 0)
		{
			player.GiveAmmo(::KillLoot.AmmoPickupAmount[classname]);
			
			local count = entity.GetNetPropInt("m_iHealth") - 1;
			
			if(count <= 0)
				entity.Kill();
			else
				entity.SetNetPropInt("m_iHealth", count);
			
			printl("player " + player.GetName() + " pickup a ammo");
		}
	},
	
	function SpawnLootItem(entTable, position)
	{
		if(entTable == null || !("ent" in entTable))
			return null;
		
		local entity = null;
		if(entTable["ent"] == "weapon_melee" || entTable["ent"] == "weapon_melee_spawn")
		{
			entity = Utils.CreateEntity("weapon_melee", position,
				QAngle(0.0, RandomFloat(-180.0, 180.0), RandomInt(0,1) * 180 - 90),
				{solid = 6, melee_weapon = entTable["melee_type"], spawnflags = 3, targetname = "zombie_loot"});
		}
		else if(entTable["ent"] == "upgrade_spawn" || entTable["ent"] == "weapon_upgradepack_explosive" ||
			entTable["ent"] == "weapon_upgradepack_incendiary")
		{
			if(entTable["ent"] == "weapon_upgradepack_incendiary")
			{
				entity = Utils.SpawnUpgrade("upgrade_ammo_incendiary", 1, position,
					QAngle(0.0, RandomFloat(-180.0, 180.0), 0.0), {solid = 6, targetname = "zombie_loot"});
			}
			else if(entTable["ent"] == "weapon_upgradepack_explosive")
			{
				entity = Utils.SpawnUpgrade("upgrade_ammo_explosive", 1, position,
					QAngle(0.0, RandomFloat(-180.0, 180.0), 0.0), {solid = 6, targetname = "zombie_loot"});
			}
			else
			{
				entity = Utils.SpawnUpgrade("upgrade_laser_sight", 1, position,
					QAngle(0.0, RandomFloat(-180.0, 180.0), 0.0), {solid = 6, targetname = "zombie_loot"});
			}
		}
		else if(entTable["ent"] == "ammo_single")
		{
			entity = Utils.CreateEntity("scripted_item_drop", position,
				QAngle(0.0, RandomFloat(-180.0, 180.0), RandomInt(0, 1) * 180.0 - 90.0),
				{model = "models/w_models/weapons/w_HE_grenade.mdl", solid = 6, targetname = "zombie_loot"});
			
			entity.SetNetPropInt("m_iHealth", 1);
			entity.ConnectOutput("OnUser4", ::KillLoot.OnOutput_PickupAmmoSingle);
			entity.ConnectOutput("OnPlayerTouch", ::KillLoot.OnOutput_PickupAmmoSingle);
			entity.ConnectOutput("OnPlayerPickup", ::KillLoot.OnOutput_PickupAmmoSingle);
		}
		else if(entTable["ent"] == "weapon_ammo_spawn" || entTable["ent"] == "weapon_ammo_pack")
		{
			entity = Utils.CreateEntity("scripted_item_drop", position,
				QAngle(0.0, RandomFloat(-180.0, 180.0), 0.0),
				{model = "models/props/terror/ammo_stack.mdl", solid = 6, targetname = "zombie_loot"});
			
			entity.SetNetPropInt("m_iHealth", 4);
			entity.ConnectOutput("OnUser4", ::KillLoot.OnOutput_PickupAmmoSingle);
			entity.ConnectOutput("OnPlayerPickup", ::KillLoot.OnOutput_PickupAmmoSingle);
			entity.ConnectOutput("OnPlayerTouch", ::KillLoot.OnOutput_TouchAmmoPack);
		}
		else
		{
			/*
			entity = Utils.SpawnWeapon(entTable["ent"], 1, entTable["ammo"], position,
				QAngle(0.0, RandomFloat(-180.0, 180.0), RandomInt(0, 1) * 180.0 - 90.0),
				{solid = 6, targetname = "zombie_loot"});
			*/
			
			entity = Utils.CreateEntity(entTable["ent"], position,
				QAngle(0.0, RandomFloat(-180.0, 180.0), RandomInt(0, 1) * 180.0 - 90.0),
				{solid = 6, ammo = entTable["ammo"], targetname = "zombie_loot"});
		}
		
		if(entity == null || !entity.IsEntityValid())
			return null;
		
		entity.SetNetPropString("m_iName", "zombie_loot");
		// entity.SetMoveType(MOVETYPE_VPHYSICS);
		entity.ConnectOutput("OnUser1", ::KillLoot.OnOutput_RemoveEntity);
		entity.Input("FireUser1", "", ::KillLoot.ConfigVar.LootRemoveDelay);
		return entity;
	},
	
	function CreateLootWeapon(randomList, pos)
	{
		if(randomList == null || randomList.len() <= 0)
			return null;
		
		local total = 0;
		foreach(props in randomList)
			total += props["prob"];
		
		if(total <= 0)
			return null;
		
		local probability = RandomInt(1, total);
		foreach(props in randomList)
		{
			if((probability -= props["prob"]) > 0)
				continue;
			
			if(props["ent"] == null)
				return null;
			
			return ::KillLoot.SpawnLootItem(props, pos);
		}
		
		return null;
	},
	
	function Timer_RemoveAllEntity(params)
	{
		local convert = 0;
		local remove = 0;
		
		foreach(entity in Objects.AllEx(@(entity) (entity.GetClassname().find("weapon_") == 0 &&
			entity.GetOwnerEntity() == null)))
		{
			local classname = Utils.StringReplace(entity.GetClassname(), "_spawn", "");
			if(classname in ::KillLoot.ConvertDirectorSpawner)
			{
				entity = Utils.ConvertEntity(entity, ::KillLoot.ConvertDirectorSpawner[classname],
					{targetname = "loot_convert"});
				
				++convert;
				continue;
			}
			
			if(classname in ::KillLoot.AllowDirectorSpawner && ::KillLoot.AllowDirectorSpawner[classname])
				continue;
			
			++remove;
			entity.Kill();
			entity = null;
		}
		
		printl("entity convert " + convert + ", remove " + remove + ".");
	}
};

function Notifications::OnDeath::KillLoot_DropWeapon(victim, attacker, params)
{
	if(!::KillLoot.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !attacker.IsSurvivor() || !attacker.IsPlayerEntityValid() ||
		victim.GetTeam() != INFECTED || attacker.GetTeam() != SURVIVORS)
		return;
	
	if(victim.IsPlayer())
	{
		// 特感死亡
		::KillLoot.CreateLootWeapon(::KillLoot.SpecialLoot, victim.GetLocation());
	}
	else
	{
		// 普感死亡
		::KillLoot.CreateLootWeapon(::KillLoot.CommonLoot,
			Vector(params["victim_x"], params["victim_y"], params["victim_z"]));
	}
}

function Notifications::OnWeaponDropped::KillLoot_RemoveDropWeapon(player, weapon, params)
{
	if(!::KillLoot.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsSurvivor() || !player.IsPlayerEntityValid() ||
		weapon == null || !weapon.IsEntityValid())
		return;
	
	if(Utils.IsValidFireWeapon(params["item"]) && weapon.GetNetPropString("m_iName") == "zombie_loot")
	{
		local ammotype = weapon.GetNetPropInt("m_iPrimaryAmmoType");
		local ammo = player.GetNetPropInt("m_iAmmo", ammotype);
		
		weapon.ConnectOutput("OnUser1", ::KillLoot.OnOutput_RemoveEntity);
		if(weapon.GetNetPropInt("m_iClip1") == 0 && ammo == 0)
			weapon.Input("FireUser1", "", 1);
		else
			weapon.Input("FireUser1", "", ::KillLoot.ConfigVar.DropRemoveDelay);
		
		printl("remove weapon " + params["item"] + " by player " + player.GetName() + " dropped");
	}
}

function Notifications::OnRoundBegin::KillLoot_CheckDirectorSpawner(params)
{
	if(!::KillLoot.ConfigVar.Enable)
		return;
	
	if(::KillLoot.ConfigVar.DisableDirectorSpawner)
	{
		if("AllowWeaponSpawn" in SessionOptions && ::KillLoot.OldAllowDirectorSpawner == null)
		{
			::KillLoot.OldAllowDirectorSpawner = SessionOptions.AllowWeaponSpawn;
			printl("store SessionOptions.AllowWeaponSpawn");
		}
		if("ConvertWeaponSpawn" in SessionOptions && ::KillLoot.OldConvertDirectorSpawner == null)
		{
			::KillLoot.OldConvertDirectorSpawner = SessionOptions.ConvertWeaponSpawn;
			printl("store SessionOptions.ConvertWeaponSpawn");
		}
		if("GetDefaultItem" in SessionOptions && ::KillLoot.OldDefaultDirectorWeapon == null)
		{
			::KillLoot.OldDefaultDirectorWeapon = SessionOptions.GetDefaultItem;
			printl("store SessionOptions.GetDefaultItem");
		}
		
		/*
		SessionOptions.AllowWeaponSpawn <- function(classname)
		{
			if(classname in ::KillLoot.AllowDirectorSpawner)
				return ::KillLoot.AllowDirectorSpawner[classname];
			
			return false;
		};
		
		SessionOptions.ConvertWeaponSpawn <- function(classname)
		{
			if(classname in ::KillLoot.ConvertDirectorSpawner)
				return ::KillLoot.ConvertDirectorSpawner[classname];
			
			return classname;
		};
		
		SessionOptions.GetDefaultItem <- function(index)
		{
			if(index < ::KillLoot.DefaultDirectorWeapon.len())
				return ::KillLoot.DefaultDirectorWeapon[index];
			
			return 0;
		};
		*/
		
		if(::KillLoot.HasFirstRound)
			Timers.AddTimerByName("timer_loot_remove", 1.0, false, ::KillLoot.Timer_RemoveAllEntity);
		else
			Timers.AddTimerByName("timer_loot_remove", 0.1, false, ::KillLoot.Timer_RemoveAllEntity);
	}
	else
	{
		/*
		if(::KillLoot.OldAllowDirectorSpawner != null)
		{
			SessionOptions.AllowWeaponSpawn <- ::KillLoot.OldAllowDirectorSpawner;
			printl("restore SessionOptions.AllowWeaponSpawn");
		}
		if(::KillLoot.OldConvertDirectorSpawner != null)
		{
			SessionOptions.ConvertWeaponSpawn <- ::KillLoot.OldConvertDirectorSpawner;
			printl("restore SessionOptions.ConvertWeaponSpawn");
		}
		if(::KillLoot.OldDefaultDirectorWeapon != null)
		{
			SessionOptions.GetDefaultItem <- ::KillLoot.OldDefaultDirectorWeapon;
			printl("restore SessionOptions.GetDefaultItem");
		}
		*/
		
		::KillLoot.OldAllowDirectorSpawner = null;
		::KillLoot.OldConvertDirectorSpawner = null;
		::KillLoot.OldDefaultDirectorWeapon = null;
	}
}

function Notifications::OnUpgradeDeployed::KillLoot_GiveUpgrade(player, entity, params)
{
	if(!::KillLoot.ConfigVar.DisableDirectorSpawner)
		return;
	
	if(player == null || !player.IsPlayerEntityValid() || !player.IsSurvivor() || player.IsDead() ||
		entity == null || !entity.IsEntityValid())
		return;
	
	/*
	local classname = entity.GetClassname();
	if(classname == "upgrade_ammo_incendiary")
		player.AddPrimaryUpgrade(UPGRADE_INCENDIARY_AMMO);
	else if(classname == "upgrade_ammo_explosive")
		player.AddPrimaryUpgrade(UPGRADE_EXPLOSIVE_AMMO);
	*/
	
	entity.Input("Use", "", 0, player);
	entity.Input("Kill", "", 1);
	// FireGameEvent("upgrade_pack_added", {userid = player.GetUserID(), upgradeid = entity.GetIndex()});
}

function Notifications::OnUse::KillLoot_PickupAmmoPack(player, entity, params)
{
	if(!::KillLoot.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayerEntityValid() || !player.IsSurvivor() || player.IsDead() ||
		entity == null || !entity.IsEntityValid() || entity.GetClassname() != "scripted_item_drop" ||
		entity.GetNetPropString("m_iName") != "zombie_loot")
		return;
	
	entity.Input("FireUser4", "", 0, player);
}

function CommandTriggersEx::loot(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	::KillLoot.ConfigVar.Enable = !::KillLoot.ConfigVar.Enable;
	printl("::KillLoot.ConfigVar.Enable = " + ::KillLoot.ConfigVar.Enable);
}

function CommandTriggersEx::nuts(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	::KillLoot.ConfigVar.DisableDirectorSpawner = !::KillLoot.ConfigVar.DisableDirectorSpawner;
	Notifications.OnRoundStartPreEntity.KillLoot_CheckDirectorSpawner();
	printl("::KillLoot.ConfigVar.DisableDirectorSpawner = " + ::KillLoot.ConfigVar.DisableDirectorSpawner);
}


::KillLoot.PLUGIN_NAME <- PLUGIN_NAME;
::KillLoot.ConfigVar = ::KillLoot.ConfigVarDef;

function Notifications::OnRoundStart::KillLoot_LoadConfig()
{
	RestoreTable(::KillLoot.PLUGIN_NAME, ::KillLoot.ConfigVar);
	if(::KillLoot.ConfigVar == null || ::KillLoot.ConfigVar.len() <= 0)
		::KillLoot.ConfigVar = FileIO.GetConfigOfFile(::KillLoot.PLUGIN_NAME, ::KillLoot.ConfigVarDef);

	// printl("[plugins] " + ::KillLoot.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::KillLoot_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::KillLoot.PLUGIN_NAME, ::KillLoot.ConfigVar);

	// printl("[plugins] " + ::KillLoot.PLUGIN_NAME + " saving...");
}
