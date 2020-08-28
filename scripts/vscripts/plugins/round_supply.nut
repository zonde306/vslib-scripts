::RoundSupply <-
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
		BlockColse = false,

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

	GiveWeapon =
	{
		// 投掷武器
		slot2 =
		[
			{ent = null, prob = 50, ammo = 1},
			
			{ent = "weapon_vomitjar", prob = 5, ammo = 1},
			{ent = "weapon_molotov", prob = 6, ammo = 1},
			{ent = "weapon_pipe_bomb", prob = 7, ammo = 1}
		],
		
		// 医疗品/升级包
		slot3 = 
		[
			{ent = null, prob = 100, ammo = 1},
			
			{ent = "weapon_first_aid_kit", prob = 5, ammo = 1},
			{ent = "weapon_defibrillator", prob = 10, ammo = 1},
			{ent = "weapon_upgradepack_explosive", prob = 20, ammo = 1},
			{ent = "weapon_upgradepack_incendiary", prob = 20, ammo = 1},
		],
		
		// 药物
		slot4 =
		[
			{ent = null, prob = 25, ammo = 1},
			
			{ent = "weapon_pain_pills", prob = 1, ammo = 1},
			{ent = "weapon_adrenaline", prob = 2, ammo = 1},
		]
	},
	
	ReplaceMedkit =
	[
		// {ent = "weapon_first_aid_kit_spawn", prob = 1, ammo = 1}
	],
	
	ByMissionFail = false,
	IsItemGived = false,
	HasFirstConnect = {},
	HasFirstRoundSpawn = {},
	IsRoundStarting = false,
	
	function GetRandomWeapon(randomList)
	{
		if(randomList == null || typeof(randomList) != "array" && typeof(randomList) != "table" ||
			randomList.len() <= 0)
			return null;
		
		local maxProbability = 0;
		foreach(each in randomList)
		{
			maxProbability += each["prob"];
		}
		
		if(maxProbability <= 0)
			return null;
		
		local number = RandomInt(1, maxProbability);
		foreach(each in randomList)
		{
			number -= each["prob"];
			if(number > 0)
				continue;
			
			if(each["ent"] == null)
				return null;
			
			return each;
		}
		
		return null;
	},
	
	function OnOutput_BlockCloseDoor()
	{
		if(caller == null || !caller.IsValid())
			return;
		
		local entity = ::VSLib.Entity(caller);
		if(::RoundSupply.ConfigVar.BlockColse)
		{
			// 阻止关门
			entity.Input("Lock");
			
			// 再按一次就直接把门破坏
			entity.Input("AddOutput", "OnLockedUse !self:Kill::1:1");
			
			// 取消挂钩
			entity.DisconnectOutput("OnFullyOpen", ::RoundSupply.OnOutput_BlockCloseDoor);
			
			printl("saferoom door locked");
		}
	},
	
	RoundEndSaferoom = null,
	RoundStartSaferoom = null,
	StartDoor = null,
	FinishDoor = null,
	
	function FindSurvivorStart()
	{
		// 安全门开始
		foreach(entity in Objects.OfClassname("prop_door_rotating_checkpoint"))
		{
			// 忽略非开始位置的安全门
			// 一般情况下终点的安全门是打开并且没有上锁的
			if(!entity.GetNetPropBool("m_bLocked") || entity.GetNetPropInt("m_eDoorState") != 0)
			{
				// 强制终点的安全门关闭，防止特感卡门
				entity.Input("Close");
				::RoundSupply.RoundEndSaferoom = entity.GetLocation();
				continue;
			}
			
			// 检查地图是否拥有导航流
			if(g_ModeScript.GetMaxFlowDistance() > 128.0)
			{
				// 使用导航流来检测安全门位置
				// 如果是救援关的话，可能无法获取到正确的导航流
				// 如果安全门不是终点，则附加一个开门后禁止关闭的功能
				// 因为 GetCurrentFlowDistanceForPosition 不存在所以才用 GetCurrentFlowDistanceForPlayer 的(但是非玩家也有效)
				if(g_MapScript.GetCurrentFlowDistanceForPlayer(entity) < 100.0)
					entity.Input("AddOutput", "OnFullyOpen !self:Lock::0:1");
				else
					entity.Input("Close");
			}
			else
			{
				// 某些非官方地图没有导航流或导航流不正确
				// 例如原版的 l4d_yama_3 就没有导航流
				entity.Input("AddOutput", "OnFullyOpen !self:Lock::0:1");
			}
			
			// entity.ConnectOutput("OnFullyOpen", ::RoundSupply.OnOutput_BlockCloseDoor);
			::RoundSupply.RoundStartSaferoom = entity.GetLocation();
			
			local flow = g_MapScript.GetCurrentFlowPercentForPlayer(entity);
			if(flow > 90)
			{
				::RoundSupply.FinishDoor = entity;
				entity.ConnectOutput("OnFullyOpen", ::RoundSupply.OnOutput_FinishDoorChanged);
				entity.ConnectOutput("OnBlockedClosing", ::RoundSupply.OnOutput_FinishDoorChanged);
				entity.ConnectOutput("OnUnblockedOpening", ::RoundSupply.OnOutput_FinishDoorChanged);
			}
			else if(flow < 10)
			{
				::RoundSupply.StartDoor = entity;
				entity.Input("AddOutput", "OnFullyOpen !self:Lock::0:1");
				entity.Input("AddOutput", "OnFullyClosed !self:Kill::5:1");
			}
		}
		
		if(::RoundSupply.RoundStartSaferoom == null)
		{
			// 无安全门开始
			/*
			foreach(entity in Objects.OfClassname("info_survivor_position"))
			{
				::RoundSupply.RoundStartSaferoom = entity.GetLocation();
				break;
			}*/
			
			foreach(player in Players.AliveSurvivors())
			{
				::RoundSupply.RoundStartSaferoom = player.GetLocation();
				break;
			}
		}
		
		return ::RoundSupply.RoundStartSaferoom;
	},
	
	function ReplaceFirstAidKit(position)
	{
		// 寻找安全门附近的医疗包
		local fak = Objects.OfClassnameNearest("weapon_first_aid_kit_spawn", position, ::RoundSupply.ConfigVar.ReplaceRadius);
		if(fak == null)
		{
			// 某些 地图/模式 开始时是药丸
			fak = Objects.OfClassnameNearest("weapon_pain_pills_spawn", position, ::RoundSupply.ConfigVar.ReplaceRadius);
		}
		if(fak == null)
		{
			printl("first_aid_kit or pain_pills not found");
			return -1;
		}
		
		local replaced = 0;
		
		// 一般情况下，安全室的包都是堆放在一起的
		position = fak.GetLocation();
		foreach(entity in Objects.OfClassnameWithin(fak.GetClassname(), position, 64))
		{
			if(Utils.CalculateDistance(position, entity.GetLocation()) > 64)
				continue;
			
			local object = ::RoundSupply.GetRandomWeapon(::RoundSupply.ReplaceMedkit);
			if(object != null)
			{
				/*
				entity = Utils.ConvertEntity(entity, object["ent"],
					{ammo = 999, count = object["ammo"], spawnflags = 2, solid = 6});
				*/
				
				local ent = Utils.SpawnWeapon(object["ent"], 1, 1, entity.GetLocation(), entity.GetAngles());
				if(ent != null && ent.IsValid())
				{
					entity.Kill();
					// ent.SetMoveType(MOVETYPE_NONE);
				}
				
				++replaced;
			}
		}
		
		return replaced;
	},
	
	function Timer_ReplaceSomething(params)
	{
		::RoundSupply.FindSurvivorStart();
		
		local replaced = 0;
		if(::RoundSupply.RoundStartSaferoom != null)
			replaced += ::RoundSupply.ReplaceFirstAidKit(::RoundSupply.RoundStartSaferoom);
		if(::RoundSupply.RoundEndSaferoom)
			replaced += ::RoundSupply.ReplaceFirstAidKit(::RoundSupply.RoundEndSaferoom);
		
		if(replaced > 0)
			printl("replace medkit count " + replaced);
		else
			printl("first_aid_kit or pain_pills not found");
	},
	
	function Timer_GiveRandomWeapon(player)
	{
		if(player == null || !player.IsEntityValid() || player.IsDead())
			return false;
		
		local inv = player.GetHeldItems();
		if("slot0" in inv && inv["slot0"] != null && inv["slot0"].IsEntityValid())
			return false;
		
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
		
		return true;
	},
	
	function Timer_UpdateMoreSupply(player)
	{
		if(!("MapChange" in getroottable()))
			return;
		
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
	},
	
	function Timer_AutoCloseDoor(entity)
	{
		if(entity != null && entity.IsEntityValid())
		{
			entity.Input("Close");
			printl("close the door");
		}
	},
	
	function Timer_GivePlayerSupply(params)
	{
		::RoundSupply.GivePlayerSupply(params["player"]);
	},
	
	function GivePlayerSupply(player)
	{
		if(!player.IsSurvivor())
			return;
		
		if(player.IsDead())
		{
			local other = Players.RandomAliveSurvivor();
			
			// 复活因为未知 bug 导致开局死亡的玩家
			player.Defib();
			
			// 将刚才复活的玩家移动到队友旁，因为刚复活的玩家位置是随机的
			if(other != null)
				player.SetLocation(other.GetLocation());
		}
		
		if(player.GetCurrentAttacker() != null)
			player.GetCurrentAttacker().Kill();
		
		if(player.IsIncapacitated() || player.IsHangingFromLedge())
			player.Revive();
		
		if(::RoundSupply.ConfigVar.StartMaxHealth > -1)
			player.SetMaxHealth(::RoundSupply.ConfigVar.StartMaxHealth);
		if(::RoundSupply.ConfigVar.StartHealth > -1)
			player.SetRawHealth(::RoundSupply.ConfigVar.StartHealth);
		if(::RoundSupply.ConfigVar.StartHealthBuffer > -1)
			player.SetHealthBuffer(::RoundSupply.ConfigVar.StartHealthBuffer);
		if(::RoundSupply.ConfigVar.StartReviveCount > -1)
			player.SetReviveCount(::RoundSupply.ConfigVar.StartReviveCount);
		
		// if(Convars.GetStr("mp_gamemode") == "community5")
		if(Utils.GetMaxIncapCount() <= 0)
		{
			player.SetNetPropInt("m_bIsOnThirdStrike", 0);
			// player.SetNetPropInt("m_isGoingToDie", 0);
			// player.StopSound("Player.HeartbeatLoop");
			// player.StopSound("Player.Heartbeat");
		}
		
		local gamemode = Convars.GetStr("mp_gamemode").tolower();
		if(gamemode == "stranded" || gamemode == "gunnuts" || gamemode == "gunnuts_ammo")
			return;
		
		local inv = player.GetHeldItems();
		foreach(key, value in ::RoundSupply.GiveWeapon)
		{
			if(key in inv && inv[key] != null && inv[key].IsEntityValid())
				continue;
			
			if(key != "command")
			{
				local item = ::RoundSupply.GetRandomWeapon(value);
				if(item == null)
					continue;
				
				player.Give(item["ent"]);
			}
			else
			{
				foreach(item in value)
				{
					if(typeof(item) == "table")
						player.Give(item["ent"]);
					else
						player.Give(item);
				}
			}
		}
		
		if(::RoundSupply.ConfigVar.GivePrimary)
			::RoundSupply.Timer_GiveRandomWeapon(player);
		if(::RoundSupply.ConfigVar.GiveAmmo)
			player.GiveAmmo(999);
		if(::RoundSupply.ConfigVar.GiveLaser)
			player.GiveUpgrade(UPGRADE_LASER_SIGHT);
		if(::RoundSupply.ConfigVar.GiveUpgrade > 0 && ::RoundSupply.ConfigVar.GiveUpgrade < 3)
			player.GiveUpgrade(::RoundSupply.ConfigVar.GiveUpgrade - 1);
		
		if(::RoundSupply.IsCoopMode() && "MapChange" in getroottable())
		{
			inv = player.GetHeldItems();
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
		
		printl("player " + player.GetName() + " supplyed");
	},
	
	function IsCoopMode()
	{
		return (Utils.GetBaseMode() == "coop");
	},
	
	FirstEnterPlayer = null,
	HasInSaferoom = {},
	InSaferoomCount = 0,
	AccessControlTimer = -1,
	
	function OnOutput_FinishDoorChanged()
	{
		if(caller == null || !caller.IsValid())
			return;
		
		Timers.AddTimerByName("timer_saferoom_door_colse", ::RoundSupply.ConfigVar.AutoCloseDoor, false,
			::RoundSupply.Timer_AutoCloseDoor, ::VSLib.Entity(caller));
	},
	
	function Timer_AccessControlTimer(params)
	{
		if(::RoundSupply.InSaferoomCount <= 0)
			return false;
		
		local aliveSurvivor = Players.AliveSurvivors();
		if(::RoundSupply.InSaferoomCount / aliveSurvivor.len() * 100 < ::RoundSupply.ConfigVar.AccessControlMin)
			return false;
		
		if(::RoundSupply.AccessControlTimer <= -1)
			::RoundSupply.AccessControlTimer = ::RoundSupply.ConfigVar.AccessControlDuration;
		
		if((::RoundSupply.AccessControlTimer -= 1) <= 0)
		{
			local inSaferoom = null;
			foreach(index, hasInSaferoom in ::RoundSupply.HasInSaferoom)
			{
				if(!hasInSaferoom)
					continue;
				
				inSaferoom = ::VSLib.Player(index);
				if(inSaferoom == null || !inSaferoom.IsSurvivor() || inSaferoom.IsDead())
				{
					inSaferoom = null;
					continue;
				}
				
				break;
			}
			
			if(inSaferoom == null)
				return false;
			
			inSaferoom = inSaferoom.GetLocation();
			foreach(player in Players.AliveSurvivors())
			{
				player.SetLocation(inSaferoom);
				player.ShowHint("Killed by Access Control");
				player.Kill();
			}
			
			if(::RoundSupply.FinishDoor != null && ::RoundSupply.FinishDoor.IsEntityValid())
				::RoundSupply.FinishDoor.Input("Close");
			
			Utils.PlaySoundToAllEx("ui/critical_event_1.wav");
			return false;
		}
		else if(::RoundSupply.AccessControlTimer <= 10)
		{
			local index = -1;
			foreach(player in aliveSurvivor)
			{
				if(player.IsBot())
					continue;
				
				index = player.GetIndex();
				if(index in ::RoundSupply.HasInSaferoom && ::RoundSupply.HasInSaferoom[index])
					continue;
				
				if(::RoundSupply.AccessControlTimer == 10)
					player.ShowHint("Please enter safeoom within 10 seconds", 9, "icon_skull");
				
				player.PlaySoundEx("ui/beep07.wav");
			}
		}
	}
};

function Notifications::OnRoundStart::RoundSupplyReplace()
{
	Timers.AddTimerByName("timer_medkitreplace", ::RoundSupply.ConfigVar.ReplaceDelay, false, ::RoundSupply.Timer_ReplaceSomething);
	Timers.AddTimerByName("timer_starthealth", 0.1, false, ::RoundSupply.Timer_UpdateMoreSupply);
	
	::RoundSupply.IsRoundStarting = true;
	printl("supply by round_start");
}

function Notifications::FirstSurvLeftStartArea::RoundSupply_StopHealPlayer(player, params)
{
	::RoundSupply.IsRoundStarting = false;
	::RoundSupply.HasFirstRoundSpawn.clear();
}

function Notifications::OnFirstSpawn::RoundSupply_FirstRoundSpawn(player, params)
{
	if(player == null || !player.IsPlayerEntityValid() || !player.IsSurvivor())
		return;
	
	Notifications.OnSpawn.RoundSupply_GiveSupply(player, params);
}

function Notifications::OnTeamChanged::RoundSupply_FirstRoundTeam(player, oldteam, newteam, params)
{
	if(oldteam > 1 || newteam != 2)
		return;
	
	Notifications.OnSpawn.RoundSupply_GiveSupply(player, params);
}

function Notifications::OnPlayerJoined::RoundSupply_FirstJoin(player, name, ip, steamId, params)
{
	if(!("retry" in params) || player == null || !player.IsPlayerEntityValid())
		return;
	
	::RoundSupply.HasFirstConnect[player.GetIndex()] <- true;
}

function Notifications::OnTeamChanged::RoundSupply_RespawnPlayer(player, oldteam, newteam, params)
{
	if(params["disconnect"] || params["isbot"] || player == null || !player.IsPlayerEntityValid())
		return;
	
	local index = player.GetIndex();
	if(!(index in ::RoundSupply.HasFirstConnect))
		return;
	
	if(newteam != 2 || oldteam == 3 || oldteam == 2)
		return;
	
	delete ::RoundSupply.HasFirstConnect[index];
	if(!::RoundSupply.ConfigVar.JoinRespawn)
		return;
	
	if(player.IsDead())
	{
		player.Defib();
		printl("player " + player.GetName() + " respawn");
	}
	
	if(::RoundSupply.ConfigVar.GivePrimary)
		Timers.AddTimerByName("timer_give_weapon_" + index, 0.1, false, ::RoundSupply.Timer_GiveRandomWeapon, player);
}

function Notifications::OnPlayerLeft::RoundSupply_CancelRespawnPlayer(player, name, steamId, params)
{
	if(player == null || !player.IsPlayerEntityValid() || player.IsBot())
		return;
	
	local index = player.GetIndex();
	if(index in ::RoundSupply.HasFirstConnect)
		delete ::RoundSupply.HasFirstConnect[index];
}

function Notifications::OnEnterSaferoom::RoundSupply_OnEnterCheckPoint(player, params)
{
	if(player == null || !("IsPlayerEntityValid" in player) ||
		!player.IsPlayerEntityValid() || player.GetFlowPercent() < 99)
		return;
	
	if(::RoundSupply.FirstEnterPlayer == null)
	{
		::RoundSupply.FirstEnterPlayer = player;
		Utils.PlaySoundToAllEx("level/scoreregular.wav");
		// player.Say("-> First reach saferoom");
	}
	
	if(::RoundSupply.FinishDoor != null)
	{
		Timers.AddTimerByName("timer_saferoom_door_colse", 9, false,
			::RoundSupply.Timer_AutoCloseDoor, ::RoundSupply.FinishDoor);
	}
	
	::RoundSupply.InSaferoomCount += 1;
	::RoundSupply.HasInSaferoom[player.GetIndex()] <- true;
	
	if(::RoundSupply.InSaferoomCount / Players.AliveSurvivors().len() * 100 >= ::RoundSupply.ConfigVar.AccessControlMin)
		Timers.AddTimerOne("timer_access_control", 1.0, true, ::RoundSupply.Timer_AccessControlTimer);
	
	printl("player " + player.GetName() + " enter saferoom (" + ::RoundSupply.InSaferoomCount + ")");
}

function Notifications::OnLeaveSaferoom::RoundSupply_OnLeaveCheckPoint(player, params)
{
	if(player == null || !("IsPlayerEntityValid" in player) ||
		!player.IsPlayerEntityValid() || player.GetFlowPercent() < 95)
		return;
	
	::RoundSupply.InSaferoomCount -= 1;
	::RoundSupply.HasInSaferoom[player.GetIndex()] <- false;
	printl("player " + player.GetName() + " leave saferoom (" + ::RoundSupply.InSaferoomCount + ")");
}

function Notifications::OnDoorUnlocked::RoundSupply_StopHealPlayer(player, checkpoint, params)
{
	if(checkpoint > 0)
		::RoundSupply.IsRoundStarting = false;
}

function Notifications::OnSpawn::RoundSupply_GiveSupply(player, params)
{
	if(!::RoundSupply.ConfigVar.Enable)
		return;
	
	if(!::RoundSupply.IsRoundStarting || player == null || !player.IsPlayerEntityValid() || !player.IsSurvivor())
		return;
	
	local index = player.GetIndex();
	if(index in ::RoundSupply.HasFirstRoundSpawn)
		return;
	
	::RoundSupply.HasFirstRoundSpawn[index] <- true;
	// ::RoundSupply.GivePlayerSupply(player);
	Timers.AddTimerByName("timer_supply_" + index, 0.1, false, ::RoundSupply.Timer_GivePlayerSupply, { "player" : player });
}

function CommandTriggersEx::supply(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	foreach(target in Players.AllSurvivors())
		::RoundSupply.GivePlayerSupply(target);
}

::RoundSupply.PLUGIN_NAME <- PLUGIN_NAME;
::RoundSupply.ConfigVar = ::RoundSupply.ConfigVarDef;

function Notifications::OnRoundStart::RoundSupply_LoadConfig()
{
	RestoreTable(::RoundSupply.PLUGIN_NAME, ::RoundSupply.ConfigVar);
	if(::RoundSupply.ConfigVar == null || ::RoundSupply.ConfigVar.len() <= 0)
		::RoundSupply.ConfigVar = FileIO.GetConfigOfFile(::RoundSupply.PLUGIN_NAME, ::RoundSupply.ConfigVarDef);

	// printl("[plugins] " + ::RoundSupply.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::RoundSupply_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::RoundSupply.PLUGIN_NAME, ::RoundSupply.ConfigVar);

	// printl("[plugins] " + ::RoundSupply.PLUGIN_NAME + " saving...");
}
