::BotPickup <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,

		// 机器人自动捡起的东西.0=禁用.1=包.2=药.4=针.8=电击.16=爆炸子弹.32=燃烧子弹.64=土雷.128=火瓶.256=胆汁.512=机关枪
		// 1024=榴弹.2048=电锯.4096=油桶(黄色).8192=油桶(红色).16384=煤气罐.32768=氧气瓶.65536=烟花盒.131072=侏儒.262144=可乐
		// 524288=Tier1武器.1048576=Tier2武器.2097152=狙击枪.4194304=近战和手枪.8388608=弹药堆
		PickupGroups = 8388607,

		// 机器人会自动给玩家的东西.0=禁用.1=包.2=药.4=针.8=电击.16=爆炸子弹.32=燃烧子弹.64=土雷.128=火瓶.256=胆汁
		// 更多的内容参考 PickupGroups 的解释
		GiveGroups = 496,

		// 允许从机器人交换获得的物品.0=禁用.1=包.2=药.4=针.8=电击.16=爆炸子弹.32=燃烧子弹.64=土雷.128=火瓶.256=胆汁
		// 更多的内容参考 PickupGroups 的解释
		SwapGroups = 520703,

		// 机器人无视障碍捡起物品的距离
		CatchDistance = 125,

		// 机器人可见捡起物品的距离(这个值必须大于 ::BotPickup.ConfigVar.CatchDistance)
		VisibleDistance = 300,

		// 机器人给予物品的距离
		GiveDistance = 100,

		// 机器人是否可以在倒地的情况下捡东西
		PickupByIncapacitated = false,

		// 机器人是否可以在倒地的情况下给东西
		GiveByIncapacitated = false,
		
		// 是否开启机器人自动倒油
		AllowPourGascan = true,
		
		// 自动倒油距离
		AllowPourDistance = 300,
		
		// 拾取检查间隔
		ThinkInterval = 1.0,
	},

	ConfigVar = {},

	// 正在被其他玩家/机器人交互的物品
	// 在此列表内的物品(以物品id为key,获得者为value)不能被无关的玩家捡起
	IgnoreGroup = {},
	
	function GetClassnameByGroupsId(type)
	{
		local classnameTable = [];
		
		if(type & 1)
			classnameTable.append("weapon_first_aid_kit");
		if(type & 2)
			classnameTable.append("weapon_pain_pills");
		if(type & 4)
			classnameTable.append("weapon_adrenaline");
		if(type & 8)
			classnameTable.append("weapon_defibrillator");
		if(type & 16)
			classnameTable.append("weapon_upgradepack_explosive");
		if(type & 32)
			classnameTable.append("weapon_upgradepack_incendiary");
		if(type & 64)
			classnameTable.append("weapon_pipe_bomb");
		if(type & 128)
			classnameTable.append("weapon_molotov");
		if(type & 256)
			classnameTable.append("weapon_vomitjar");
		if(type & 512)
			classnameTable.append("weapon_rifle_m60");
		if(type & 1024)
			classnameTable.append("weapon_grenade_launcher");
		if(type & 2048)
			classnameTable.append("weapon_gascan");
		if(type & 4096)
			classnameTable.append("weapon_chainsaw");
		if(type & 8192)
			classnameTable.append("weapon_gascan");
		if(type & 16384)
			classnameTable.append("weapon_propanetank");
		if(type & 32768)
			classnameTable.append("weapon_oxygentank");
		if(type & 65536)
			classnameTable.append("weapon_fireworkcrate");
		if(type & 131072)
			classnameTable.append("weapon_gnome");
		if(type & 262144)
			classnameTable.append("weapon_cola_bottles");
		
		if(type & 524288)
		{
			classnameTable.append("weapon_smg");
			classnameTable.append("weapon_smg_silenced");
			classnameTable.append("weapon_smg_mp5");
			classnameTable.append("weapon_pumpshotgun");
			classnameTable.append("weapon_shotgun_chrome");
		}
		if(type & 1048576)
		{
			classnameTable.append("weapon_rifle");
			classnameTable.append("weapon_rifle_desert");
			classnameTable.append("weapon_rifle_ak47");
			classnameTable.append("weapon_rifle_sg552");
			classnameTable.append("weapon_autoshotgun");
			classnameTable.append("weapon_shotgun_spas");
		}
		if(type & 2097152)
		{
			classnameTable.append("weapon_hunting_rifle");
			classnameTable.append("weapon_sniper_military");
			classnameTable.append("weapon_sniper_scout");
			classnameTable.append("weapon_sniper_awp");
		}
		if(type & 4194304)
		{
			classnameTable.append("weapon_melee");
			classnameTable.append("weapon_pistol_magnum");
			classnameTable.append("weapon_pistol");
		}
		if(type & 8388608)
		{
			classnameTable.append("weapon_ammo_spawn");
			classnameTable.append("weapon_ammo_pack");
		}
		
		local count = classnameTable.len();
		if(count == 0)
			return "";
		if(count == 1)
			return classnameTable[0];
		
		return classnameTable;
	},
	
	function GetGroupsIdByClassname(classname)
	{
		local groups = 0;
		
		local type = typeof(classname);
		if(type == "string")
		{
			if(classname == "")
				return 0;
			
			if(classname.find("_spawn") != null)
				classname = Utils.StringReplace(classname, "_spawn", "");
			
			switch(classname)
			{
				case "weapon_first_aid_kit":
				{
					groups = groups | 1;
					break;
				}
				case "weapon_pain_pills":
				{
					groups = groups | 2;
					break;
				}
				case "weapon_adrenaline":
				{
					groups = groups | 4;
					break;
				}
				case "weapon_defibrillator":
				{
					groups = groups | 8;
					break;
				}
				case "weapon_upgradepack_explosive":
				{
					groups = groups | 16;
					break;
				}
				case "weapon_upgradepack_incendiary":
				{
					groups = groups | 32;
					break;
				}
				case "weapon_pipe_bomb":
				{
					groups = groups | 64;
					break;
				}
				case "weapon_molotov":
				{
					groups = groups | 128;
					break;
				}
				case "weapon_vomitjar":
				{
					groups = groups | 256;
					break;
				}
				case "weapon_rifle_m60":
				{
					groups = groups | 512;
					break;
				}
				case "weapon_grenade_launcher":
				{
					groups = groups | 1024;
					break;
				}
				case "weapon_chainsaw":
				{
					groups = groups | 2048;
					break;
				}
				case "weapon_gascan":
				{
					groups = groups | 8192 | 4096;
					break;
				}
				case "weapon_propanetank":
				{
					groups = groups | 16384;
					break;
				}
				case "weapon_oxygentank":
				{
					groups = groups | 32768;
					break;
				}
				case "weapon_fireworkcrate":
				{
					groups = groups | 65536;
					break;
				}
				case "weapon_gnome":
				{
					groups = groups | 131072;
					break;
				}
				case "weapon_cola_bottles":
				{
					groups = groups | 262144;
					break;
				}
				case "weapon_smg":
				case "weapon_smg_silenced":
				case "weapon_smg_mp5":
				case "weapon_pumpshotgun":
				case "weapon_shotgun_chrome":
				{
					groups = groups | 524288;
					break;
				}
				case "weapon_rifle":
				case "weapon_rifle_ak47":
				case "weapon_rifle_desert":
				case "weapon_autoshotgun":
				case "weapon_shotgun_spas":
				{
					groups = groups | 1048576;
					break;
				}
				case "weapon_hunting_rifle":
				case "weapon_sniper_military":
				case "weapon_sniper_scout":
				case "weapon_sniper_awp":
				{
					groups = groups | 2097152;
					break;
				}
				case "weapon_melee":
				case "weapon_pistol_magnum":
				case "weapon_pistol":
				{
					groups = groups | 4194304;
					break;
				}
				case "weapon_ammo_spawn":
				case "weapon_ammo_pack":
				{
					groups = groups | 8388608;
					break;
				}
			}
		}
		else if(type == "array" || type == "table")
		{
			foreach(name in classname)
			{
				if(name == "")
					continue;
				
				if(name.find("_spawn") != null)
					name = Utils.StringReplace(name, "_spawn", "");
				
				switch(name)
				{
					case "weapon_first_aid_kit":
					{
						groups = groups | 1;
						break;
					}
					case "weapon_pain_pills":
					{
						groups = groups | 2;
						break;
					}
					case "weapon_adrenaline":
					{
						groups = groups | 4;
						break;
					}
					case "weapon_defibrillator":
					{
						groups = groups | 8;
						break;
					}
					case "weapon_upgradepack_explosive":
					{
						groups = groups | 16;
						break;
					}
					case "weapon_upgradepack_incendiary":
					{
						groups = groups | 32;
						break;
					}
					case "weapon_pipe_bomb":
					{
						groups = groups | 64;
						break;
					}
					case "weapon_molotov":
					{
						groups = groups | 128;
						break;
					}
					case "weapon_vomitjar":
					{
						groups = groups | 256;
						break;
					}
					case "weapon_rifle_m60":
					{
						groups = groups | 512;
						break;
					}
					case "weapon_grenade_launcher":
					{
						groups = groups | 1024;
						break;
					}
					case "weapon_chainsaw":
					{
						groups = groups | 2048;
						break;
					}
					case "weapon_gascan":
					{
						groups = groups | 8192 | 4096;
						break;
					}
					case "weapon_propanetank":
					{
						groups = groups | 16384;
						break;
					}
					case "weapon_oxygentank":
					{
						groups = groups | 32768;
						break;
					}
					case "weapon_fireworkcrate":
					{
						groups = groups | 65536;
						break;
					}
					case "weapon_gnome":
					{
						groups = groups | 131072;
						break;
					}
					case "weapon_cola_bottles":
					{
						groups = groups | 262144;
						break;
					}
					case "weapon_smg":
					case "weapon_smg_silenced":
					case "weapon_smg_mp5":
					case "weapon_pumpshotgun":
					case "weapon_shotgun_chrome":
					{
						groups = groups | 524288;
						break;
					}
					case "weapon_rifle":
					case "weapon_rifle_ak47":
					case "weapon_rifle_desert":
					case "weapon_autoshotgun":
					case "weapon_shotgun_spas":
					{
						groups = groups | 1048576;
						break;
					}
					case "weapon_hunting_rifle":
					case "weapon_sniper_military":
					case "weapon_sniper_scout":
					case "weapon_sniper_awp":
					{
						groups = groups | 2097152;
						break;
					}
					case "weapon_melee":
					case "weapon_pistol_magnum":
					case "weapon_pistol":
					{
						groups = groups | 4194304;
						break;
					}
					case "weapon_ammo_spawn":
					case "weapon_ammo_pack":
					{
						groups = groups | 8388608;
						break;
					}
				}
			}
		}
		
		return groups;
	},
	
	// 检查该物品是否可以被捡起
	function CanPickupItem(player, item)
	{
		if(player == null || item == null || !player.IsPlayerEntityValid() || !item.IsEntityValid() || player.IsDead())
			return false;
		
		if(item.GetOwnerEntity() != null)
			return false;
		
		local classname = item.GetClassname();
		local distance = Utils.CalculateDistance(player.GetLocation(), item.GetLocation());
		
		// 检查是否数量足够
		if(classname.find("_spawn") && !item.HasSpawnFlags(1 << 3) && item.GetNetPropInt("m_itemCount") <= 0)
			return false;
		
		// 检查实体类型和最大距离
		if(classname.find("weapon_") != 0 || item.GetIndex() in ::BotPickup.IgnoreGroup ||
			distance > ::BotPickup.ConfigVar.VisibleDistance)
			return false;
		
		// 检查可见
		if(distance > ::BotPickup.ConfigVar.CatchDistance && !player.CanSeeOtherEntity(item))
			return false;
		
		classname = Utils.StringReplace(classname, "_spawn", "");
		return ((::BotPickup.ConfigVar.PickupGroups & GetGroupsIdByClassname(classname)) != 0);
	},
	
	// 寻找机器人可捡起的物品
	function FindCanPickup(player, groups)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead())
			return null;
		
		local type = typeof(groups);
		if(type == "string")
		{
			if(groups == "")
				return null;
			
			foreach(weapon in Objects.OfClassnameWithin(groups, player.GetLocation(), ::BotPickup.ConfigVar.VisibleDistance))
			{
				if(!::BotPickup.CanPickupItem(player, weapon))
					continue;
				
				return weapon;
			}
		}
		else if(type == "integer")
		{
			if(groups == 0)
				return null;
			
			foreach(weapon in Objects.AroundRadius(player.GetLocation(), ::BotPickup.ConfigVar.VisibleDistance))
			{
				local classname = weapon.GetClassname();
				if(classname.find("weapon_") != 0)
					continue;
				
				classname = Utils.StringReplace(classname, "_spawn", "");
				if(!(groups & ::BotPickup.GetGroupsIdByClassname(classname)) || !::BotPickup.CanPickupItem(player, weapon))
					continue;
				
				return weapon;
			}
		}
		else if(type == "array" || type == "table")
		{
			foreach(classname in groups)
			{
				if(classname == "")
					continue;
				
				foreach(weapon in Objects.OfClassnameWithin(classname, player.GetLocation(), ::BotPickup.ConfigVar.VisibleDistance))
				{
					if(!::BotPickup.CanPickupItem(player, weapon))
						continue;
					
					return weapon;
				}
			}
		}
		
		return null;
	},
	
	// 捡起东西
	function PickupItem(player, item)
	{
		if(player == null || item == null || !player.IsPlayerEntityValid() || !item.IsEntityValid() || player.IsDead())
			return "";
		
		/*
		local index = item.GetIndex();
		if(index in ::BotPickup.IgnoreGroup && ::BotPickup.IgnoreGroup[index] != null)
			return "";
		*/
		
		::BotPickup.IgnoreGroup[item.GetIndex()] <- player;
		item.Input("Use", "", 0, player);
		// player.NativePickupObject(item);
		
		Timers.AddTimerByName("bot_pickup_" + item.GetIndex(), 0.1, false,
			::BotPickup.TimerBotPickup_CancelIgnoreGroup, item);
		
		printl("player " + player.GetName() + " pickup " + item.GetClassname());
		return item.GetClassname();
	},
	
	function TimerBotPickup_CancelIgnoreGroup(entity)
	{
		if(entity == null || !entity.IsEntityValid())
			return;
		
		local index = entity.GetIndex();
		if(index in ::BotPickup.IgnoreGroup)
			delete ::BotPickup.IgnoreGroup[index];
	},
	
	function TimerBotPickup_PickupWeapon(params)
	{
		if(params["player1"] != null && params["weapon1"] != null && params["player1"].IsPlayerEntityValid() &&
			params["weapon1"].IsEntityValid())
			::BotPickup.PickupItem(params["player1"], params["weapon1"]);
		
		if(params["player2"] != null && params["weapon2"] != null && params["player2"].IsPlayerEntityValid() &&
			params["weapon2"].IsEntityValid())
				::BotPickup.PickupItem(params["player2"], params["weapon2"]);
	},
	
	function FindSlotByClassname(player, weapon)
	{
		local inv = (typeof(player) == "instance" ? player.GetHeldItems() : player);
		
		foreach(slot, entity in inv)
		{
			if(entity == null || !entity.IsEntityValid())
				continue;
			
			if(entity.GetClassname() == weapon)
				return slot;
		}
		
		return null;
	},
	
	function TimerFlags_OnWeaponSwap(entlist)
	{
		foreach(spawner in entlist)
		{
			if(spawner == null || !spawner.IsEntityValid())
				continue;
			
			spawner.SetKeyValue("spawnflags", 4);
		}
	},
	
	// 交换两个玩家的物品
	function SwapItem(player, target, item)
	{
		if(player == null || target == null || !player.IsPlayerEntityValid() || !target.IsPlayerEntityValid() ||
			!player.IsSurvivor() || !target.IsSurvivor() || player.IsDead() || target.IsDead())
			return false;
		
		local swapType = typeof(item);
		
		local slot = null;
		local weaponFrom = null;
		local weaponTo = null;
		
		local invFrom = player.GetHeldItems();
		local invTo = target.GetHeldItems();
		
		switch(swapType)
		{
			case "integer":
			{
				slot = "slot" + item;
				if(slot in invFrom && invFrom[slot] != null && invFrom[slot].IsEntityValid())
					weaponFrom = invFrom[slot];
				if(slot in invTo && invTo[slot] != null && invTo[slot].IsEntityValid())
					weaponTo = invTo[slot];
				
				break;
			}
			case "string":
			{
				if((slot = ::BotPickup.FindSlotByClassname(invFrom, item)) != null)
				{
					if(slot in invFrom && invFrom[slot] != null && invFrom[slot].IsEntityValid())
						weaponFrom = invFrom[slot];
					if(slot in invTo && invTo[slot] != null && invTo[slot].IsEntityValid())
						weaponTo = invTo[slot];
				}
				else if((slot = ::BotPickup.FindSlotByClassname(invTo, item)) != null)
				{
					if(slot in invFrom && invFrom[slot] != null && invFrom[slot].IsEntityValid())
						weaponFrom = invFrom[slot];
					if(slot in invTo && invTo[slot] != null && invTo[slot].IsEntityValid())
						weaponTo = invTo[slot];
				}
				
				break;
			}
			default:
			{
				if(!("IsEntityValid" in item) || !item.IsEntityValid())
					return false;
				
				local classname = item.GetClassname();
				if((slot = ::BotPickup.FindSlotByClassname(invFrom, classname)) != null)
				{
					if(slot in invFrom && invFrom[slot] != null && invFrom[slot].IsEntityValid())
						weaponFrom = invFrom[slot];
					if(slot in invTo && invTo[slot] != null && invTo[slot].IsEntityValid())
						weaponTo = invTo[slot];
				}
				else if((slot = ::BotPickup.FindSlotByClassname(invTo, classname)) != null)
				{
					if(slot in invFrom && invFrom[slot] != null && invFrom[slot].IsEntityValid())
						weaponFrom = invFrom[slot];
					if(slot in invTo && invTo[slot] != null && invTo[slot].IsEntityValid())
						weaponTo = invTo[slot];
				}
				
				break;
			}
		}
		
		if(weaponFrom == null && weaponTo == null)
			return false;
		
		// 如果使用直接移除实体会导致实体被 _spawn 吸收，会出现无限刷物品的 bug
		// 所以这里使用掉落捡起的方式交换物品
		
		if(weaponFrom != null)
		{
			local classname = weaponFrom.GetClassname();
			local spawner = Objects.OfClassnameNearest(classname + "_spawn", weaponFrom.GetLocation(), 250);
			
			if(spawner != null && spawner.IsEntityValid())
			{
				// 默认情况下带 _spawn 的同 classname 的实体会吸收掉落的物品
				// 在这里将需要捡起的东西转移到带 _spawn 的实体上
				// 以免因为物品被吸收了导致丢失
				::BotPickup.IgnoreGroup[spawner.GetIndex()] <- player;
				weaponFrom.Kill();
				weaponFrom = spawner;
			}
			else
			{
				// 周围没有可以吸收的实体，按照默认的方式进行交换
				::BotPickup.IgnoreGroup[weaponFrom.GetIndex()] <- player;
				player.Drop(classname);
			}
		}
		
		if(weaponTo != null)
		{
			local classname = weaponTo.GetClassname();
			local spawner = Objects.OfClassnameNearest(classname + "_spawn", weaponTo.GetLocation(), 250);
			
			if(spawner != null && spawner.IsEntityValid())
			{
				// 默认情况下带 _spawn 的同 classname 的实体会吸收掉落的物品
				// 在这里将需要捡起的东西转移到带 _spawn 的实体上
				// 以免因为物品被吸收了导致丢失
				::BotPickup.IgnoreGroup[spawner.GetIndex()] <- target;
				weaponTo.Kill();
				weaponTo = spawner;
			}
			else
			{
				// 周围没有可以吸收的实体，按照默认的方式进行交换
				::BotPickup.IgnoreGroup[weaponTo.GetIndex()] <- target;
				target.Drop(classname);
			}
		}
		
		Timers.AddTimerByName("timer_switch_weapon_" + player.GetIndex() + "x" + target.GetIndex(), 0.1, false,
			::BotPickup.TimerBotPickup_PickupWeapon, {player1 = player, weapon1 = weaponTo, player2 = target,
			weapon2 = weaponFrom});
		
		return true;
	}
	
	function TimerSetupUpgrade_OnBotPickup(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead() || player.GetTeam() != SURVIVORS)
			return false;
		
		local inv = player.GetHeldItems();
		if(!("slot3" in inv) || inv["slot3"] == null || !inv["slot3"].IsEntityValid())
			return false;
		
		local classname = inv["slot3"].GetClassname();
		if(classname.find("upgradepack") == null)
			return false;
		
		/*
		local entity = null;
		if(classname == "weapon_upgradepack_incendiary")
			entity = Utils.SpawnUpgrade(UPGRADE_INCENDIARY_AMMO, 4, player.GetLocation());
		else if(classname == "weapon_upgradepack_explosive")
			entity = Utils.SpawnUpgrade(UPGRADE_EXPLOSIVE_AMMO, 4, player.GetLocation());
		else
			return false;
		
		inv["slot3"].Kill();
		*/
		
		/*
		if(entity != null && entity.IsEntityValid())
			FireGameEvent("upgrade_pack_used", {upgradeid = entity.GetIndex(), userid = player.GetUserID()});
		*/
		
		player.SwitchWeapon(classname);
		player.ForceButton(BUTTON_ATTACK);
		Timers.AddTimerByName("bot_upgrade_" + player.GetIndex(), 9.0, false, ::BotPickup.Timer_StopFire, player, 0, { "action" : "reset" });
		
		return true;
	},
	
	function Timer_StopFire(player)
	{
		if(player == null || !player.IsSurvivor())
			return;
		
		player.UnforceButton(BUTTON_ATTACK);
	},
	
	// 机器人思考(拣东西/给东西)
	function TimerBotPickup_OnBotsThink(params)
	{
		if(!::BotPickup.ConfigVar.Enable)
		{
			::BotPickup.IgnoreGroup.clear();
			return;
		}
		
		foreach(player in Players.AliveSurvivorBots())
		{
			local item = player.GetHeldItems();
			local incap = player.IsIncapacitated();
			
			// 捡起或者更换主武器
			if((!("slot0" in item) || item["slot0"] == null || player.GetPrimaryAmmo() <= 0) && (!incap || ::BotPickup.ConfigVar.PickupByIncapacitated))
			{
				// 机枪和榴弹
				local groupMask = (512|1024|524288|1048576|2097152);
				
				::BotPickup.PickupItem(player, ::BotPickup.FindCanPickup(player,
					(::BotPickup.ConfigVar.PickupGroups & groupMask)));
				
				// printl("bots " + player.GetName() + " pickup pri weapon");
			}
			
			// 补充弹药
			if("slot0" in item && item["slot0"] != null && (!incap || ::BotPickup.ConfigVar.PickupByIncapacitated))
			{
				// 弹药堆
				local groupMask = (8388608);
				
				::BotPickup.PickupItem(player, ::BotPickup.FindCanPickup(player,
					(::BotPickup.ConfigVar.PickupGroups & groupMask)));
				
				// printl("bots " + player.GetName() + " pickup ammo");
			}
			
			// 捡起电锯
			if((!("slot1" in item) || item["slot1"] == null) && (!incap || ::BotPickup.ConfigVar.PickupByIncapacitated))
			{
				// 电锯
				local groupMask = (2048|4194304);
				
				::BotPickup.PickupItem(player, ::BotPickup.FindCanPickup(player,
					(::BotPickup.ConfigVar.PickupGroups & groupMask)));
				
				// printl("bots " + player.GetName() + " pickup chainsaw");
			}
			
			// 捡起投掷武器
			if((!("slot2" in item) || item["slot2"] == null) && (!incap || ::BotPickup.ConfigVar.PickupByIncapacitated))
			{
				// 土雷/火瓶/胆汁
				local groupMask = (64|128|256);
				
				::BotPickup.PickupItem(player, ::BotPickup.FindCanPickup(player,
					(::BotPickup.ConfigVar.PickupGroups & groupMask)));
				
				// printl("bots " + player.GetName() + " pickup grenade");
			}
			
			// 捡起恢复/强化物品
			if((!("slot3" in item) || item["slot3"] == null) && (!incap || ::BotPickup.ConfigVar.PickupByIncapacitated))
			{
				// 医疗包/电击器/高爆弹药/燃烧弹药
				local groupMask = (1|8|16|32);
				
				::BotPickup.PickupItem(player, ::BotPickup.FindCanPickup(player,
					(::BotPickup.ConfigVar.PickupGroups & groupMask)));
				
				/*
				if(::BotPickup.PickupItem(player, ::BotPickup.FindCanPickup(player,
					(::BotPickup.ConfigVar.PickupGroups & groupMask))).find("upgradepack") != null)
				{
					Timers.AddTimerByName("timer_setup_upgrade_" + player.GetIndex(), 8.0, false,
						::BotPickup.TimerSetupUpgrade_OnBotPickup, player);
					
					// FireGameEvent("upgrade_pack_begin", {userid = player.GetUserID()});
				}
				*/
				
				// printl("bots " + player.GetName() + " pickup medkit");
			}
			
			// 捡起药物
			if((!("slot4" in item) || item["slot4"] == null) && (!incap || ::BotPickup.ConfigVar.PickupByIncapacitated))
			{
				// 止痛药/肾上腺素
				local groupMask = (2|4);
				
				::BotPickup.PickupItem(player, ::BotPickup.FindCanPickup(player,
					(::BotPickup.ConfigVar.PickupGroups & groupMask)));
				
				// printl("bots " + player.GetName() + " pickup pills");
			}
			
			// 捡起携带物品
			if((!("slot5" in item) || item["slot5"] == null) && !player.HasVisibleThreats() &&
				(!incap || ::BotPickup.ConfigVar.PickupByIncapacitated))
			{
				// 油桶/煤气罐/氧气瓶/烟花盒/可乐/侏儒
				local groupMask = (4096|8192|16384|32768|65536|131072|262144);
				
				::BotPickup.PickupItem(player, ::BotPickup.FindCanPickup(player,
					(::BotPickup.ConfigVar.PickupGroups & groupMask)));
				
				// printl("bots " + player.GetName() + " pickup carry");
			}
			else if(::BotPickup.ConfigVar.AllowPourGascan && "slot5" in item && item["slot5"] != null &&
				item["slot5"].GetClassname() == "weapon_gascan")
			{
				local target = ::VSLib.Entity("point_prop_use_target");
				local director = ::VSLib.Entity("info_director");
				local progress = ::VSLib.Entity("game_scavenge_progress_display");
				if(target != null && director != null && progress != null && progress.GetNetPropBool("m_bActive") &&
					item["slot5"].GetName() == target.GetNetPropString("m_sGasNozzleName") &&
					player.GetDistanceToOther(target) <= ::BotPickup.ConfigVar.AllowPourDistance)
				{
					item["slot5"].KillDelayed(0.1);
					director.Input("IncrementTeamScore", "2", 0, player);
					target.Input("OnUseFinished", "", 0, player);
					delete item["slot5"];
					
					// TODO: 检查数量并触发救援
					if("GasCanPoured" in g_MapScript)
						g_MapScript.GasCanPoured();
					if("GasCanPoured" in g_ModeScript)
						g_ModeScript.GasCanPoured();
					foreach(rule in Objects.OfClassname("terror_gamerules"))
						rule.SetNetPropInt("terror_gamerules_data.m_iScavengeTeamScore", rule.GetNetPropInt("terror_gamerules_data.m_iScavengeTeamScore") + 1);
					foreach(counter in Objects.OfClassname("math_counter"))
						counter.Input("Add", "1", 0, player);
				}
			}
			
			// 自动给投掷武器
			if("slot2" in item && item["slot2"] != null && (!incap || ::BotPickup.ConfigVar.GiveByIncapacitated) &&
				::BotPickup.ConfigVar.GiveGroups & ::BotPickup.GetGroupsIdByClassname(item["slot2"].GetClassname()))
			{
				foreach(client in Players.AliveSurvivors())
				{
					if(client.IsBot() || client.IsIncapacitated() || client.IsHangingFromLedge() ||
						client.IsHangingFromTongue() || client.IsBeingJockeyed() || client.IsPounceVictim() ||
						client.IsTongueVictim() || client.IsCarryVictim() || client.IsPummelVictim())
						continue;
					
					local inv = client.GetHeldItems();
					if("slot2" in inv && inv["slot2"] != null)
						continue;
					
					::BotPickup.SwapItem(player, client, item["slot2"]);
					
					client.PlaySoundEx("ui/gift_pickup.wav");
					printl("bots " + player.GetName() + " give " + client.GetName() + " grenade");
					break;
				}
			}
			
			// 自动给医疗或强化装备
			if("slot3" in item && item["slot3"] != null && (!incap || ::BotPickup.ConfigVar.GiveByIncapacitated) &&
				::BotPickup.ConfigVar.GiveGroups & ::BotPickup.GetGroupsIdByClassname(item["slot3"].GetClassname()))
			{
				foreach(client in Players.AliveSurvivors())
				{
					if(client.IsBot() || client.IsIncapacitated() || client.IsHangingFromLedge() ||
						client.IsHangingFromTongue() || client.IsBeingJockeyed() || client.IsPounceVictim() ||
						client.IsTongueVictim() || client.IsCarryVictim() || client.IsPummelVictim())
						continue;
					
					local inv = client.GetHeldItems();
					if("slot3" in inv && inv["slot3"] != null)
						continue;
					
					::BotPickup.SwapItem(player, client, item["slot3"]);
					
					client.PlaySoundEx("ui/gift_pickup.wav");
					printl("bots " + player.GetName() + " give " + client.GetName() + " medkit");
					break;
				}
			}
			
			// 自动给药物
			if("slot4" in item && item["slot4"] != null && (!incap || ::BotPickup.ConfigVar.GiveByIncapacitated) &&
				::BotPickup.ConfigVar.GiveGroups & ::BotPickup.GetGroupsIdByClassname(item["slot4"].GetClassname()))
			{
				foreach(client in Players.AliveSurvivors())
				{
					if(client.IsBot() || client.IsIncapacitated() || client.IsHangingFromLedge() ||
						client.IsHangingFromTongue() || client.IsBeingJockeyed() || client.IsPounceVictim() ||
						client.IsTongueVictim() || client.IsCarryVictim() || client.IsPummelVictim())
						continue;
					
					local inv = client.GetHeldItems();
					if("slot4" in inv && inv["slot4"] != null)
						continue;
					
					::BotPickup.SwapItem(player, client, item["slot4"]);
					
					client.PlaySoundEx("ui/gift_pickup.wav");
					printl("bots " + player.GetName() + " give " + client.GetName() + " pills");
					break;
				}
			}
			
			// 自动给携带物品
			if("slot5" in item && item["slot5"] != null && (!incap || ::BotPickup.ConfigVar.GiveByIncapacitated) &&
				::BotPickup.ConfigVar.GiveGroups & ::BotPickup.GetGroupsIdByClassname(item["slot5"].GetClassname()))
			{
				foreach(client in Players.AliveSurvivors())
				{
					if(client.IsBot() || client.IsIncapacitated() || client.IsHangingFromLedge() ||
						client.IsHangingFromTongue() || client.IsBeingJockeyed() || client.IsPounceVictim() ||
						client.IsTongueVictim() || client.IsCarryVictim() || client.IsPummelVictim())
						continue;
					
					local inv = client.GetHeldItems();
					if("slot5" in inv && inv["slot5"] != null)
						continue;
					
					::BotPickup.SwapItem(player, client, item["slot5"]);
					
					client.PlaySoundEx("ui/gift_pickup.wav");
					printl("bots " + player.GetName() + " give " + client.GetName() + " carry");
					break;
				}
			}
		}
	},
}

function Notifications::OnRoundBegin::BotPickupActtive(params)
{
	Timers.AddTimerByName("timer_botpickup", ::BotPickup.ConfigVar.ThinkInterval true, ::BotPickup.TimerBotPickup_OnBotsThink);
}

function Notifications::FirstSurvLeftStartArea::BotPickupActtive(player, params)
{
	Timers.AddTimerByName("timer_botpickup", ::BotPickup.ConfigVar.ThinkInterval, true, ::BotPickup.TimerBotPickup_OnBotsThink);
}

function Notifications::OnPlayerShoved::BotPickup_SwapItem(victim, attacker, params)
{
	if(!::BotPickup.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsPlayerEntityValid() || !attacker.IsPlayerEntityValid())
		return;
	
	if(victim.GetTeam() != SURVIVORS || attacker.IsBot() || !victim.IsBot())
		return;
	
	local weapon = attacker.GetActiveWeapon();
	if(weapon != null && weapon.IsEntityValid())
	{
		local classname = weapon.GetClassname();
		
		if((::BotPickup.ConfigVar.SwapGroups & ::BotPickup.GetGroupsIdByClassname(classname)) &&
			::BotPickup.FindSlotByClassname(victim.GetHeldItems(), classname) == null)
		{
			::BotPickup.SwapItem(attacker, victim, weapon);
			attacker.PlaySoundEx("level/popup.wav");
			printl("player " + attacker.GetName() + " swap " + classname + " to " + victim.GetName());
			
			// 给目标玩家递东西时防止意外进行交换
			return;
		}
	}
	
	// 被要求物品方（机器人）
	local invFrom = victim.GetHeldItems();
	
	// 要求物品方（玩家）
	local invTo = attacker.GetHeldItems();
	
	if(("slot2" in invFrom) && !("slot2" in invTo) && invFrom["slot2"].IsEntityValid())
	{
		// 要求机器人给投掷武器
		local classname = invFrom["slot2"].GetClassname();
		if(::BotPickup.ConfigVar.SwapGroups & ::BotPickup.GetGroupsIdByClassname(classname))
		{
			::BotPickup.SwapItem(victim, attacker, invFrom["slot2"]);
			attacker.PlaySoundEx("ui/alert_clink.wav");
			printl("player " + attacker.GetName() + " grabbed " + classname + " from " + victim.GetName());
			return;
		}
	}
	
	if(("slot3" in invFrom) && !("slot3" in invTo) && invFrom["slot3"].IsEntityValid())
	{
		// 要求机器人给医疗品
		local classname = invFrom["slot3"].GetClassname();
		if(::BotPickup.ConfigVar.SwapGroups & ::BotPickup.GetGroupsIdByClassname(classname))
		{
			::BotPickup.SwapItem(victim, attacker, invFrom["slot3"]);
			attacker.PlaySoundEx("ui/alert_clink.wav");
			printl("player " + attacker.GetName() + " grabbed " + classname + " from " + victim.GetName());
			return;
		}
	}
	
	if(("slot4" in invFrom) && !("slot4" in invTo) && invFrom["slot4"].IsEntityValid())
	{
		// 要求机器人给药物
		local classname = invFrom["slot4"].GetClassname();
		if(::BotPickup.ConfigVar.SwapGroups & ::BotPickup.GetGroupsIdByClassname(classname))
		{
			::BotPickup.SwapItem(victim, attacker, invFrom["slot4"]);
			attacker.PlaySoundEx("ui/alert_clink.wav");
			printl("player " + attacker.GetName() + " grabbed " + classname + " from " + victim.GetName());
			return;
		}
	}
	
	if(("slot5" in invFrom) && !("slot5" in invTo) && invFrom["slot5"].IsEntityValid())
	{
		// 要求机器人给携带物品
		local classname = invFrom["slot5"].GetClassname();
		if(::BotPickup.ConfigVar.SwapGroups & ::BotPickup.GetGroupsIdByClassname(classname))
		{
			::BotPickup.SwapItem(victim, attacker, invFrom["slot5"]);
			attacker.PlaySoundEx("ui/alert_clink.wav");
			printl("player " + attacker.GetName() + " grabbed " + classname + " from " + victim.GetName());
			return;
		}
	}
}

/*
function Notifications::OnUpgradeDeployed::BotPickup_StopFire(deployer, upgrade, params)
{
	if(!::BotPickup.ConfigVar.Enable)
		return;
	
	if(deployer == null || !deployer.IsSurvivor())
		return;
	
	deployer.UnforceButton(BUTTON_ATTACK);
}
*/

::BotPickup.PLUGIN_NAME <- PLUGIN_NAME;
::BotPickup.ConfigVar = ::BotPickup.ConfigVarDef;

function Notifications::OnRoundStart::BotPickup_LoadConfig()
{
	RestoreTable(::BotPickup.PLUGIN_NAME, ::BotPickup.ConfigVar);
	if(::BotPickup.ConfigVar == null || ::BotPickup.ConfigVar.len() <= 0)
		::BotPickup.ConfigVar = FileIO.GetConfigOfFile(::BotPickup.PLUGIN_NAME, ::BotPickup.ConfigVarDef);

	// printl("[plugins] " + ::BotPickup.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::BotPickup_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::BotPickup.PLUGIN_NAME, ::BotPickup.ConfigVar);

	// printl("[plugins] " + ::BotPickup.PLUGIN_NAME + " saving...");
}
