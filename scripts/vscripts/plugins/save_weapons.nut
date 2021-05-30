::SaveWeapons <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 2,
		
		// 是否给新加入无武器的玩家提供基础武器
		NoobGive = true,
	},
	
	ConfigVar = {},
	
	PlayerNetProp = [
		"m_iMaxHealth",
		"m_iHealth",
		"m_healthBuffer",
		"m_healthBufferTime",
		"m_bIsOnThirdStrike",
		"m_currentReviveCount",
		"m_isGoingToDie",
		"m_survivorCharacter",
	],
	WeaponNetProp = [
		"m_iClip1",
		"m_upgradeBitVec",
		"m_nUpgradedPrimaryAmmoLoaded",
		"m_nSkin",
	],
	
	SavedWeapons = {},
	PreIncapSecondary = {},
	WeaponGived = {},
	GameStarted = false,
	
	function SaveWeapon(player)
	{
		if(!player.IsSurvivor() || player.IsDead())
			return;
		
		local uid = player.GetUserID();
		::SaveWeapons.SavedWeapons[uid] <- {};
		
		local saving = { "ammo" : player.GetPrimaryAmmo(), "model" : player.GetModel() };
		foreach(prop in ::SaveWeapons.PlayerNetProp)
		{
			saving[prop] <- player.GetNetProp(prop);
		}
		::SaveWeapons.SavedWeapons[uid]["player"] <- saving;
		
		foreach(slot, ent in player.GetHeldItems())
		{
			if(ent == null || !ent.IsValid())
				continue;
			
			saving = { "slot" : Utils.StringReplace(slot, "slot", "").tointeger() };
			if(ent.HasNetProp("m_strMapSetScriptName"))
			{
				// 近战武器只需要皮肤就够了
				if("m_nSkin" in ::SaveWeapons.WeaponNetProp)
					saving["m_nSkin"] <- ent.GetNetProp("m_nSkin");
				::SaveWeapons.SavedWeapons[uid][ent.GetMeleeName()] <- saving;
			}
			else if(saving["slot"] == 1 && (uid in ::SaveWeapons.PreIncapSecondary) && (player.IsIncapacitated() || player.IsHangingFromLedge()))
			{
				// 倒地武器无法保存 NetProp，因为没有实例
				::SaveWeapons.SavedWeapons[uid][::SaveWeapons.PreIncapSecondary[uid]] <- saving;
			}
			else
			{
				foreach(prop in ::SaveWeapons.WeaponNetProp)
				{
					local size = ent.GetNetPropArraySize(prop);
					saving[prop] <- ent.GetNetProp(prop, (size > 0 ? size : 0));
				}
				::SaveWeapons.SavedWeapons[uid][ent.GetClassname()] <- saving;
			}
		}
		
		printl("[SaveWeapons] " + player + " saved.");
	},
	
	function LoadWeapon(player)
	{
		if(!player.IsSurvivor() || player.IsDead())
			return;
		
		local uid = player.GetUserID();
		if(!(uid in ::SaveWeapons.SavedWeapons))
			return;
		
		if("player" in ::SaveWeapons.SavedWeapons[uid])
		{
			player.SetModel(::SaveWeapons.SavedWeapons[uid]["player"]["model"]);
			
			foreach(prop, value in ::SaveWeapons.SavedWeapons[uid]["player"])
			{
				if(prop.find("m_") == 0)
					player.SetNetProp(prop, value);
			}
		}
		
		player.RemoveAllWeapons();
		
		foreach(classname, table in ::SaveWeapons.SavedWeapons[uid])
		{
			if(classname == "player")
				continue;
			
			if(classname.find("weapon_") == 0)
				classname = Utils.StringReplace(classname, "weapon_", "");
			
			player.Give(classname, ("m_nSkin" in table ? table["m_nSkin"] : null));
			
			local weapon = player.GetWeaponSlot(table["slot"]);
			if(weapon == null || !weapon.IsValid())
			{
				Timers.AddTimerByName(
					"loadweapon_" + table["slot"], 0.1, false,
					::SaveWeapons.Timer_LoadWeaponLater,
					{ "player" : player, "table" : table, "ammo" : ::SaveWeapons.SavedWeapons[uid]["player"]["ammo"] },
					0, { "action" : "once" }
				);
				continue;
			}
			
			if(table["slot"] == 0)
				player.SetPrimaryAmmo(::SaveWeapons.SavedWeapons[uid]["player"]["ammo"]);
			
			foreach(prop, value in table)
			{
				if(prop.find("m_") == 0)
					weapon.SetNetProp(prop, value);
			}
		}
		
		printl("[SaveWeapons] " + player + " loaded.");
	},
	
	function Timer_LoadWeaponLater(params)
	{
		local player = params["player"];
		local table = params["table"];
		
		if(!player.IsSurvivor() || player.IsDead())
			return;
		
		local weapon = player.GetWeaponSlot(table["slot"]);
		if(weapon == null || !weapon.IsValid())
			return;
		
		if(table["slot"] == 0)
			player.SetPrimaryAmmo(params["ammo"]);
		
		foreach(prop, value in table)
		{
			if(prop == "slot")
				continue;
			
			weapon.SetNetProp(prop, value);
		}
	},
	
	function Timer_GiveWeapon(player)
	{
		if(!player.IsSurvivor() || player.IsDead())
			return;
		
		local uid = player.GetUserID();
		if(uid in ::SaveWeapons.WeaponGived)
			return;
		
		/*
		if(!(uid in ::SaveWeapons.SavedWeapons) && player.IsBot() && !::SaveWeapons.GameStarted)
		{
			foreach(oldUid, table in ::SaveWeapons.SavedWeapons)
			{
				local survivor = Utils.GetPlayerFromUserID(oldUid);
				if(survivor == null)
				{
					::SaveWeapons.CopyPlayer(oldUid, uid);
					break;
				}
			}
		}
		*/
		
		if(uid in ::SaveWeapons.SavedWeapons)
			::SaveWeapons.LoadWeapon(player);
		else if(::SaveWeapons.ConfigVar.NoobGive && !::SaveWeapons.GameStarted && player.GetWeaponSlot(SLOT_PRIMARY) == null)
			player.Give("smg");
	},
	
	function CopyPlayer(form, to, toDelete = true)
	{
		local fuid = (typeof(form) == "integer" ? form : form.GetUserID());
		local tuid = (typeof(to) == "integer" ? to : to.GetUserID());
		
		if(fuid in ::SaveWeapons.SavedWeapons)
		{
			::SaveWeapons.SavedWeapons[tuid] <- ::SaveWeapons.SavedWeapons[fuid];
			delete ::SaveWeapons.SavedWeapons[fuid];
		}
		if(fuid in ::SaveWeapons.PreIncapSecondary)
		{
			::SaveWeapons.PreIncapSecondary[tuid] <- ::SaveWeapons.PreIncapSecondary[fuid];
			delete ::SaveWeapons.PreIncapSecondary[fuid];
		}
		if(fuid in ::SaveWeapons.WeaponGived)
		{
			::SaveWeapons.WeaponGived[tuid] <- ::SaveWeapons.WeaponGived[fuid];
			delete ::SaveWeapons.WeaponGived[fuid];
		}
		
		printl("[SaveWeapons] " + form + " copy to " + to);
	},
};

function Notifications::OnSpawn::SaveWeapons_Give(player, params)
{
	if(!::SaveWeapons.ConfigVar.Enable)
		return;
	
	if(Utils.GetBaseMode() == "versus" || Utils.GetPreviousMap() == "")
		return;
	
	if(player == null || !player.IsValid())
		return;
	
	Timers.AddTimerByName("loadweapons_" + player.GetIndex(), 0.2, false, ::SaveWeapons.Timer_GiveWeapon, player);
}

function Notifications::FirstSurvLeftStartArea::SaveWeapons_GameStarting(player, params)
{
	::SaveWeapons.GameStarted = true;
}

function Notifications::OnSurvivorsLeftStartArea::SaveWeapons_GameStarting()
{
	::SaveWeapons.GameStarted = true;
}

function Notifications::OnBotReplacedPlayer::SaveWeapons_Copy(player, bot, params)
{
	if(player.IsBot())
		return;
	
	if(bot.GetTeam() == 2)
		::SaveWeapons.CopyPlayer(player, bot);
}

function Notifications::OnPlayerReplacedBot::SaveWeapons_Copy(player, bot, params)
{
	if(player.GetTeam() == 2)
		::SaveWeapons.CopyPlayer(bot, player);
}

function Notifications::OnMapEnd::SaveWeapons_Save()
{
	foreach(player in Players.AliveSurvivors())
	{
		::SaveWeapons.SaveWeapon(player);
		// player.RemoveAllWeapons();
	}
}

function Notifications::OnIncapacitatedStart::SaveWeapons_Save(player, attacker, params)
{
	if(player == null || !player.IsSurvivor() || player.IsDead())
		return;
	
	local weapon = player.GetWeaponSlot(SLOT_SECONDARY);
	if(weapon == null || !weapon.IsValid())
		return;
	
	if(weapon.HasNetProp("m_strMapSetScriptName"))
		weapon = weapon.GetMeleeName();
	else
		weapon = weapon.GetClassname();
	
	::SaveWeapons.PreIncapSecondary[player.GetUserID()] <- weapon;
}

function Notifications::OnReviveSuccess::SaveWeapons_Clear(player, reviver, params)
{
	if(player == null || !player.IsSurvivor() || player.IsDead())
		return;
	
	local uid = player.GetUserID();
	if(uid in ::SaveWeapons.PreIncapSecondary)
		delete ::SaveWeapons.PreIncapSecondary[uid];
}

function Notifications::OnDeath::SaveWeapons_Save(player, attacker, params)
{
	if(player == null || !player.IsSurvivor() || player.IsDead())
		return;
	
	local uid = player.GetUserID();
	if(uid in ::SaveWeapons.PreIncapSecondary)
		delete ::SaveWeapons.PreIncapSecondary[uid];
}

function Notifications::OnFinaleWin::SaveWeapons_Clear(mapname, difficulty, params)
{
	foreach(player in Players.AliveSurvivors())
		player.RemoveAllWeapons();
	
	::SaveWeapons.SavedWeapons = {};
	::SaveWeapons.PreIncapSecondary = {};
}

::SaveWeapons.PLUGIN_NAME <- PLUGIN_NAME;
::SaveWeapons.ConfigVar = ::SaveWeapons.ConfigVarDef;

function Notifications::OnRoundStart::SaveWeapons_LoadConfig()
{
	RestoreTable(::SaveWeapons.PLUGIN_NAME, ::SaveWeapons.ConfigVar);
	RestoreTable("saveweapons", ::SaveWeapons.SavedWeapons);
	if(::SaveWeapons.ConfigVar == null || ::SaveWeapons.ConfigVar.len() <= 0)
		::SaveWeapons.ConfigVar = FileIO.GetConfigOfFile(::SaveWeapons.PLUGIN_NAME, ::SaveWeapons.ConfigVarDef);
	if(::SaveWeapons.SavedWeapons == null)
		::SaveWeapons.SavedWeapons = {};
	
	// printl("[plugins] " + ::SaveWeapons.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::SaveWeapons_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
	{
		SaveTable(::SaveWeapons.PLUGIN_NAME, ::SaveWeapons.ConfigVar);
		SaveTable("saveweapons", ::SaveWeapons.SavedWeapons);
	}
	
	// printl("[plugins] " + ::SaveWeapons.PLUGIN_NAME + " saving...");
}
