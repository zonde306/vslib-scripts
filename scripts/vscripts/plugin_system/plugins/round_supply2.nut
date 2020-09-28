::RoundSupply2 <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 16,

		// 替换物品的延迟
		ReplaceDelay = 0.1,

		// 给物品的延迟
		GiveDelay = 0.1,

		// 替换物品的最大距离
		ReplaceRadius = 400,

		// 开局时有少生命值
		StartHealth = 100,
		StartMaxHealth = 100,
		StartHealthBuffer = 0,
		StartReviveCount = 0,

		// 是否没主武器自动给主武器
		GivePrimary = true,

		// 出门是否补满子弹
		GiveAmmo = true,

		// 出门是否给激光瞄准
		GiveLaser = false,

		// 安全门打开后是否禁止关闭
		BlockColse = true,

		// 是否开启加入游戏死亡复活
		JoinRespawn = false,

		// 出门是否给升级.0=没有.1=燃烧.2=高爆
		GiveUpgrade = 0,
		
		// 当终点安全门被打开后多少秒自动关闭
		AutoCloseDoor = 40,
		
		// 当安全室生还者达到百分之多少时启动安全门限时
		AccessControlMin = 45,
		
		// 安全门限时持续时间，超时会把在安全室外的玩家传送到安全室
		// 并且他们会被处死
		AccessControlDuration = 40
	},

	ConfigVar = {},
	
	HasRoundStart = false,
	HasDataUpdated = false,
	IsFirstSpawn = {},
	
	function Timer_GiveRandomWeapon(player)
	{
		if(player == null || !player.IsSurvivor() || player.IsDead())
			return;
		
		local inv = player.GetHeldItems();
		if("slot0" in inv && inv["slot0"] != null && inv["slot0"].IsEntityValid())
			return;
		
		srand(player.GetIndex() + Time());
		local randomWeapon = Utils.GetRandNumber(1, 6);
		switch(randomWeapon)
		{
			case 1:
				player.Give("pumpshotgun");
				break;
			case 2:
				player.Give("shotgun_chrome");
				break;
			case 3:
				player.Give("smg");
				break;
			case 4:
				player.Give("smg_silenced");
				break;
			case 5:
				player.Give("smg_mp5");
				break;
			case 6:
				player.Give("sniper_scout");
				break;
		}
	},
	
	function Timer_GiveStartSupply(player)
	{
		if(!::RoundSupply2.HasRoundStart || player == null || !player.IsSurvivor() || player.IsDead())
			return;
		
		local index = player.GetUserID();
		if(index in ::RoundSupply2.IsFirstSpawn)
			return;
		
		::RoundSupply2.IsFirstSpawn[index] <- true;
		
		if(::RoundSupply2.ConfigVar.StartMaxHealth != null)
			player.SetMaxHealth(::RoundSupply2.ConfigVar.StartMaxHealth);
		if(::RoundSupply2.ConfigVar.StartHealth != null)
			player.SetRawHealth(::RoundSupply2.ConfigVar.StartHealth);
		if(::RoundSupply2.ConfigVar.StartHealthBuffer != null)
			player.SetHealthBuffer(::RoundSupply2.ConfigVar.StartHealthBuffer);
		if(::RoundSupply2.ConfigVar.StartReviveCount != null)
			player.SetReviveCount(::RoundSupply2.ConfigVar.StartReviveCount);
		
		// if(Convars.GetStr("mp_gamemode") == "community5")
		if(Utils.GetMaxIncapCount() <= 0)
		{
			player.SetNetPropInt("m_bIsOnThirdStrike", 0);
			// player.SetNetPropInt("m_isGoingToDie", 0);
			// player.StopSound("Player.HeartbeatLoop");
			// player.StopSound("Player.Heartbeat");
		}
		
		if(::RoundSupply2.ConfigVar.GivePrimary)
			::RoundSupply2.Timer_GiveRandomWeapon(player);
		if(::RoundSupply2.ConfigVar.GiveAmmo)
			player.GiveAmmo(999);
		if(::RoundSupply2.ConfigVar.GiveLaser)
			player.GiveUpgrade(UPGRADE_LASER_SIGHT);
		if(::RoundSupply2.ConfigVar.GiveUpgrade > 0 && ::RoundSupply2.ConfigVar.GiveUpgrade < 3)
			player.GiveUpgrade(::RoundSupply2.ConfigVar.GiveUpgrade - 1);
		
		printl("round set health " + player.GetName());
		
		local isCoopMode = Utils.GetBaseMode();
		if(isCoopMode == "coop" || isCoopMode == "realism" || isCoopMode == "survival")
			isCoopMode = true;
		else
			isCoopMode = false;
		
		if(isCoopMode)
		{
			local inv = player.GetHeldItems();
			if(::MapChange.RoundTable.FinaleFailed >= 1 && ("slot0" in inv))
				player.GiveUpgrade(UPGRADE_LASER_SIGHT);
			if(::MapChange.RoundTable.FinaleFailed >= 2 && !("slot4" in inv))
				player.Give("pain_pills");
			if(::MapChange.RoundTable.FinaleFailed >= 3 && !("slot3" in inv))
				player.Give("first_aid_kit");
			if(::MapChange.RoundTable.FinaleFailed >= 4 && !("slot2" in inv))
				player.Give("molotov");
			if(::MapChange.RoundTable.FinaleFailed >= 5)
				player.SetNetPropInt("m_ArmorValue", 127);
			if(::MapChange.RoundTable.FinaleFailed >= 6)
				player.SetMaxHealth(150);
			if(::MapChange.RoundTable.FinaleFailed >= 7)
				player.SetMaxHealth(200);
		}
		
		if(isCoopMode && !::RoundSupply2.HasDataUpdated)
		{
			::RoundSupply2.HasDataUpdated = true;
			
			if(::MapChange.RoundTable.FinaleFailed >= 3)
			{
				if(::WeaponInfo.RestoreData.len() <= 0)
					::WeaponInfo.RestoreData = ::WeaponInfo.WeaponData;
				
				foreach(index, classname in ::WeaponInfo.WeaponList._all)
				{
					if(!(classname in ::WeaponInfo.WeaponData))
						::WeaponInfo.WeaponData[classname] <- {};
					
					::WeaponInfo.WeaponData[classname]["ammo"] <- ::WeaponInfo.GetWeaponDefaultAmmo(classname) * 2;
				}
				
				printl("Double Ammo Activing...");
			}
			if(::MapChange.RoundTable.FinaleFailed >= 4)
			{
				if(::WeaponInfo.RestoreData.len() <= 0)
					::WeaponInfo.RestoreData = ::WeaponInfo.WeaponData;
				
				foreach(index, classname in ::WeaponInfo.WeaponList._all)
				{
					if(!(classname in ::WeaponInfo.WeaponData))
						::WeaponInfo.WeaponData[classname] <- {};
					
					::WeaponInfo.WeaponData[classname]["clip"] <- ::WeaponInfo.GetWeaponDefalutClip(classname) * 2;
				}
				
				printl("Double Clip Activing...");
			}
			if(::MapChange.RoundTable.FinaleFailed >= 5)
			{
				if(::WeaponInfo.RestoreData.len() <= 0)
					::WeaponInfo.RestoreData = ::WeaponInfo.WeaponData;
				
				foreach(index, classname in ::WeaponInfo.WeaponList._all)
				{
					if(!(classname in ::WeaponInfo.WeaponData))
						::WeaponInfo.WeaponData[classname] <- {};
					
					::WeaponInfo.WeaponData[classname]["reload"] <- 0.5;
				}
				
				printl("Fast Reload Activing...");
			}
			if(::MapChange.RoundTable.FinaleFailed >= 6)
			{
				if(::WeaponInfo.RestoreData.len() <= 0)
					::WeaponInfo.RestoreData = ::WeaponInfo.WeaponData;
				
				foreach(index, classname in ::WeaponInfo.WeaponList._all)
				{
					if(!(classname in ::WeaponInfo.WeaponData))
						::WeaponInfo.WeaponData[classname] <- {};
					
					::WeaponInfo.WeaponData[classname]["fire"] <- 0.5;
				}
				
				printl("Fast Shots Activing...");
			}
			if(::MapChange.RoundTable.FinaleFailed >= 7)
			{
				if(::WeaponInfo.RestoreData.len() <= 0)
					::WeaponInfo.RestoreData = ::WeaponInfo.WeaponData;
				
				foreach(index, classname in ::WeaponInfo.WeaponList._all)
				{
					if(!(classname in ::WeaponInfo.WeaponData))
						::WeaponInfo.WeaponData[classname] <- {};
					
					::WeaponInfo.WeaponData[classname]["damage"] <- ::WeaponInfo.GetWeaponDefalutDamage(classname) * 2;
				}
				
				printl("Increase Damage Activing...");
			}
		}
	}

	StartSafeRoom = null,
	FinalSafeRoom = null,
	
	function FindSafeRoomDoor()
	{
		
	},
};



::RoundSupply2.PLUGIN_NAME <- PLUGIN_NAME;
::RoundSupply2.ConfigVar = ::RoundSupply2.ConfigVarDef;

function Notifications::OnRoundStart::RoundSupply_LoadConfig()
{
	RestoreTable(::RoundSupply2.PLUGIN_NAME, ::RoundSupply2.ConfigVar);
	if(::RoundSupply2.ConfigVar == null || ::RoundSupply2.ConfigVar.len() <= 0)
		::RoundSupply2.ConfigVar = FileIO.GetConfigOfFile(::RoundSupply2.PLUGIN_NAME, ::RoundSupply2.ConfigVarDef);

	// printl("[plugins] " + ::RoundSupply2.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::RoundSupply_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::RoundSupply2.PLUGIN_NAME, ::RoundSupply2.ConfigVar);

	// printl("[plugins] " + ::RoundSupply2.PLUGIN_NAME + " saving...");
}
