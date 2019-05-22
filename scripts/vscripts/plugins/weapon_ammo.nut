::WeaponInfo <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,

		// 是否开启防止换子弹
		AntiReload = true
	},

	ConfigVar = {},
	RestoreData = {},

	WeaponData =
	{
		weapon_sniper_scout =
		{
			damage = 180,
			// clip = 10,
			// ammo = 140
		},
		weapon_sniper_awp =
		{
			damage = 350,
			// clip = 10,
			// ammo = 100
		},
		weapon_rifle_sg552 =
		{
			damage = 35
		},
		weapon_smg_mp5 =
		{
			damage = 25
		},
		weapon_hunting_rifle =
		{
			damage = 90
		}
	},
	
	WeaponDataClient = {},
	
	function GetWeaponData(player)
	{
		if(player == null || !player.IsSurvivor())
			return ::WeaponInfo.WeaponData;
		
		local index = player.GetIndex();
		if(index in ::WeaponInfo.WeaponDataClient && ::WeaponInfo.WeaponDataClient[index].len() > 0)
			return ::WeaponInfo.WeaponDataClient[index];
		
		return ::WeaponInfo.WeaponData;
	},
	
	function SetWeaponData(player, classname, property, value)
	{
		if(player == null || !player.IsSurvivor())
		{
			if(classname == null)
			{
				if(::WeaponInfo.WeaponData.len() > 0)
					::WeaponInfo.WeaponData.clear();
				
				return true;
			}
			else if(property == null)
			{
				if(classname in ::WeaponInfo.WeaponData)
					delete ::WeaponInfo.WeaponData[classname];
				
				return true;
			}
			else if(value == null)
			{
				if(classname in ::WeaponInfo.WeaponData && property in ::WeaponInfo.WeaponData[classname])
					delete ::WeaponInfo.WeaponData[classname][property];
				
				return true;
			}
			
			if(!(classname in ::WeaponInfo.WeaponData))
				::WeaponInfo.WeaponData[classname] <- {};
			
			::WeaponInfo.WeaponData[classname][property] <- value;
			return true;
		}
		
		local index = player.GetIndex();
		if(classname == null)
		{
			if(index in ::WeaponInfo.WeaponDataClient)
				delete ::WeaponInfo.WeaponDataClient[index];
			
			return true;
		}
		else if(property == null)
		{
			if(index in ::WeaponInfo.WeaponDataClient && classname in ::WeaponInfo.WeaponDataClient[index])
				delete ::WeaponInfo.WeaponDataClient[index][classname];
			
			return true;
		}
		else if(value == null)
		{
			if(index in ::WeaponInfo.WeaponDataClient && classname in ::WeaponInfo.WeaponDataClient[index] &&
				property in ::WeaponInfo.WeaponDataClient[index][classname])
				delete ::WeaponInfo.WeaponDataClient[index][classname][property];
			
			return true;
		}
		
		if(!(index in ::WeaponInfo.WeaponDataClient))
			::WeaponInfo.WeaponDataClient[index] <- {};
		
		if(!(classname in ::WeaponInfo.WeaponDataClient[index]))
			::WeaponInfo.WeaponDataClient[index][classname] <- {};
		
		::WeaponInfo.WeaponDataClient[index][classname][property] <- value;
		return true;
	},
	
	WeaponList =
	{
		// 全部武器
		_all = ["weapon_pistol", "weapon_pistol_magnum", "weapon_smg", "weapon_smg_mp5", "weapon_smg_silenced",
			"weapon_shotgun_chrome", "weapon_pumpshotgun", "weapon_autoshotgun", "weapon_shotgun_spas",
			"weapon_rifle", "weapon_rifle_sg552", "weapon_rifle_ak47", "weapon_rifle_desert",
			"weapon_hunting_rifle", "weapon_sniper_military", "weapon_sniper_scout", "weapon_sniper_awp"],
		
		// T1 武器(冲锋枪/单喷)
		_t1 = ["weapon_smg", "weapon_smg_mp5", "weapon_smg_silenced",
			"weapon_pumpshotgun", "weapon_shotgun_chrome"],
		
		// T2 武器(步枪/连喷/狙击)
		_t2 = ["weapon_rifle", "weapon_rifle_sg552", "weapon_rifle_ak47", "weapon_rifle_desert",
			"weapon_autoshotgun", "weapon_shotgun_spas",
			"weapon_hunting_rifle", "weapon_sniper_military", "weapon_sniper_scout", "weapon_sniper_awp"],
		
		// 冲锋枪
		_smg = ["weapon_smg", "weapon_smg_mp5", "weapon_smg_silenced"],
		
		// 霰弹枪
		_shotgun = ["weapon_shotgun_chrome", "weapon_pumpshotgun", "weapon_autoshotgun", "weapon_shotgun_spas"],
		
		// 步枪
		_rifle = ["weapon_rifle", "weapon_rifle_sg552", "weapon_rifle_ak47", "weapon_rifle_desert"],
		
		// 狙击枪
		_sniper = ["weapon_hunting_rifle", "weapon_sniper_military", "weapon_sniper_scout", "weapon_sniper_awp"],
		
		// 手枪
		_pistol = ["weapon_pistol", "weapon_pistol_magnum"],
		
		// 其他，未分类
		pistol = ["weapon_pistol"],
		magnum = ["weapon_pistol_magnum"],
		eagle = ["weapon_pistol_magnum"],
		de = ["weapon_pistol_magnum"],
		grenade = ["weapon_grenade_launcher"],
		launcher = ["weapon_grenade_launcher"],
		gl = ["weapon_grenade_launcher"],
		m60 = ["weapon_rifle_m60"],
		m249 = ["weapon_rifle_m60"],
		uzi = ["weapon_smg"],
		smg = ["weapon_smg"],
		silent = ["weapon_smg_silenced"],
		smgs = ["weapon_smg_silenced"],
		tmp = ["weapon_smg_silenced"],
		mp5 = ["weapon_smg_mp5"],
		chrome = ["weapon_shotgun_chrome"],
		iron = ["weapon_shotgun_chrome"],
		pump = ["weapon_pumpshotgun"],
		wood = ["weapon_pumpshotgun"],
		auto = ["weapon_autoshotgun"],
		xm1014 = ["weapon_autoshotgun"],
		spas = ["weapon_shotgun_spas"],
		rifle = ["weapon_rifle"],
		m16 = ["weapon_rifle"],
		m4 = ["weapon_rifle"],
		m4a1 = ["weapon_rifle"],
		sg552 = ["weapon_rifle_sg552"],
		aug = ["weapon_rifle_sg552"],
		ak = ["weapon_rifle_ak47"],
		ak47 = ["weapon_rifle_ak47"],
		ak74 = ["weapon_rifle_ak47"],
		dest = ["weapon_rifle_desert"],
		dst = ["weapon_rifle_desert"],
		desert = ["weapon_rifle_desert"],
		hunting = ["weapon_hunting_rifle"],
		hunt = ["weapon_hunting_rifle"],
		mil = ["weapon_sniper_military"],
		military = ["weapon_sniper_military"],
		g3sg1 = ["weapon_sniper_military"],
		sg550 = ["weapon_sniper_military"],
		sco = ["weapon_sniper_scout"],
		scout = ["weapon_sniper_scout"],
		awp = ["weapon_sniper_awp"],
		awm = ["weapon_sniper_awp"],
	},
	
	function GetWeaponDefalutClip(weapon)
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
	
	function GetWeaponClip(weapon)
	{
		local classname = (typeof(weapon) == "string" ? weapon : weapon.GetClassname());
		classname = Utils.StringReplace(classname, "_spawn", "");
		
		if(typeof(weapon) == "string")
		{
			if(classname in ::WeaponInfo.WeaponData && "clip" in ::WeaponInfo.WeaponData[classname] &&
				::WeaponInfo.WeaponData[classname]["clip"] > 0)
				return ::WeaponInfo.WeaponData[classname]["clip"];
		}
		else
		{
			local info = ::WeaponInfo.GetWeaponData(weapon.GetOwnerEntity());
			if(classname in info && "clip" in info[classname] && info[classname]["clip"] > 0)
				return info[classname]["clip"];
			else if(classname in ::WeaponInfo.WeaponData && "clip" in ::WeaponInfo.WeaponData[classname] &&
				::WeaponInfo.WeaponData[classname]["clip"] > 0)
				return ::WeaponInfo.WeaponData[classname]["clip"];
		}
		
		return ::WeaponInfo.GetWeaponDefalutClip(weapon);
	},
	
	function GetWeaponDefaultAmmo(weapon)
	{
		local classname = (typeof(weapon) == "string" ? weapon : weapon.GetClassname());
		classname = Utils.StringReplace(classname, "_spawn", "");
		
		switch(classname)
		{
			case "weapon_smg":
			case "weapon_smg_silenced":
			case "weapon_smg_mp5":
				return 650;
			case "weapon_pumpshotgun":
			case "weapon_shotgun_chrome":
				return 56;
			case "weapon_rifle":
			case "weapon_rifle_ak47":
			case "weapon_rifle_desert":
			case "weapon_rifle_sg552":
				return 360;
			case "weapon_autoshotgun":
			case "weapon_shotgun_spas":
				return 90;
			case "weapon_hunting_rifle":
				return 120;
			case "weapon_sniper_military":
			case "weapon_sniper_scout":
			case "weapon_sniper_awp":
				return 180;
			case "weapon_rifle_m60":
				return 0;
			case "weapon_grenade_launcher":
				return 30;
			case "weapon_pistol":
			case "weapon_pistol_magnum":
				return 999;
		}
		
		return -1;
	},
	
	function GetWeaponDefalutDamage(weapon)
	{
		local classname = (typeof(weapon) == "string" ? weapon : weapon.GetClassname());
		classname = Utils.StringReplace(classname, "_spawn", "");
		
		switch(classname)
		{
			case "weapon_pistol":
				return 36;
			case "weapon_pistol_magnum":
				return 80;
			case "weapon_smg":
				return 20;
			case "weapon_smg_silenced":
				return 25;
			case "weapon_smg_mp5":
				return 24;
			case "weapon_pumpshotgun":
				return 25;	// 10 颗子弹
			case "weapon_shotgun_chrome":
				return 31;	// 8 颗子弹
			case "weapon_rifle":
			case "weapon_rifle_sg552":
				return 33;
			case "weapon_rifle_ak47":
				return 58;
			case "weapon_rifle_desert":
				return 44;
			case "weapon_autoshotgun":
				return 23;	// 11 颗子弹
			case "weapon_shotgun_spas":
				return 28;	// 9 颗子弹
			case "weapon_sniper_scout":
			case "weapon_hunting_rifle":
			case "weapon_sniper_military":
				return 90;
			case "weapon_sniper_awp":
				return 115;
			case "weapon_rifle_m60":
				return 50;
			case "weapon_grenade_launcher":
				return 33;
		}
		
		return 0;
	},
	
	function GetDamageMultiplier(victimType = null, weapon = null)
	{
		local multiplier = 1.0;
		
		if(victimType == Z_COMMON || victimType == Z_WITCH)
		{
			local difficulty = Convars.GetStr("z_difficulty").tolower();
			if(Convars.GetFloat("z_use_next_difficulty_damage_factor"))
			{
				switch(difficulty)
				{
					case "easy":
						difficulty = "normal";
						break;
					case "normal":
						difficulty = "hard";
						break;
					case "hard":
						difficulty = "impossible";
						break;
				}
			}
			
			switch(difficulty)
			{
				case "easy":
					multiplier = Convars.GetFloat("z_non_head_damage_factor_easy");
					break;
				case "normal":
					multiplier = Convars.GetFloat("z_non_head_damage_factor_normal");
					break;
				case "hard":
					multiplier = Convars.GetFloat("z_non_head_damage_factor_hard");
					break;
				case "impossible":
					multiplier = Convars.GetFloat("z_non_head_damage_factor_expert");
					break;
			}
			
			if(Utils.GetBaseMode().find("realism") != null)
				multiplier *= Convars.GetFloat("z_non_head_damage_factor_multiplier");
		}
		else if(victimType == Z_TANK)
		{
			if(weapon == "weapon_autoshotgun" || weapon == "weapon_shotgun_spas")
				multiplier *= Convars.GetFloat("z_tank_autoshotgun_dmg_scale");
			else if(weapon == "weapon_grenade_launcher")
				multiplier *= Convars.GetFloat("z_tank_grenade_launcher_dmg_scale");
		}
		
		return multiplier;
	},
	
	WeaponOwner = {},
	LastClip = {},
	FinalClip = {},
	StartAmmo = {},
	HasRelading = {},
	HasReloadBlocked = {},
	HasWeaponFired = {},
	RequirementAmmo = {},
	BulletFired = {},
	
	function ClearTable(index)
	{
		if(index in ::WeaponInfo.LastClip)
			delete ::WeaponInfo.LastClip[index];
		if(index in ::WeaponInfo.FinalClip)
			delete ::WeaponInfo.FinalClip[index];
		if(index in ::WeaponInfo.StartAmmo)
			delete ::WeaponInfo.StartAmmo[index];
		if(index in ::WeaponInfo.HasRelading)
			delete ::WeaponInfo.HasRelading[index];
		if(index in ::WeaponInfo.HasReloadBlocked)
			delete ::WeaponInfo.HasReloadBlocked[index];
		if(index in ::WeaponInfo.RequirementAmmo)
			delete ::WeaponInfo.RequirementAmmo[index];
	},
	
	function OnWeaponThink_Reloading()
	{
		if(this.ent == null || !this.ent.IsEntityValid())
		{
			printl("entity OnWeaponThink_Reloading invalid.");
			return;
		}
		
		local index = this.ent.GetIndex();
		local player = this.ent.GetOwnerEntity();
		if(player == null || !player.IsPlayerEntityValid() || !player.IsSurvivor() || player.IsDead())
		{
			this.ent.AddThinkFunction(null);
			::WeaponInfo.ClearTable(index);
			// printl("weapon " + index + " reload stopped by non owner");
			return;
		}
		
		/*
		if(!(index in ::WeaponInfo.WeaponOwner) || ::WeaponInfo.WeaponOwner[index] == null ||
			!::WeaponInfo.WeaponOwner[index].IsPlayerEntityValid() || !::WeaponInfo.WeaponOwner[index].IsSurvivor() ||
			::WeaponInfo.WeaponOwner[index].GetSurvivorCharacter() != player.GetSurvivorCharacter() ||
			::WeaponInfo.WeaponOwner[index].GetUserID() != player.GetUserID())
		{
			// 玩家和武器不匹配，可能是玩家已经无效了
			this.ent.AddThinkFunction(null);
			::WeaponInfo.ClearTable(index);
			return;
		}
		*/
		
		local weapon = player.GetActiveWeapon();
		if(weapon == null || weapon.GetClassname() != this.ent.GetClassname())
		{
			// 手持武器和当前武器不匹配，可能是因为换武器了
			this.ent.AddThinkFunction(null);
			::WeaponInfo.ClearTable(index);
			// printl("player " + player.GetName() + " reload stopped by non active");
			return;
		}
		
		local index = this.ent.GetIndex();
		local ammoType = weapon.GetNetPropInt("m_iPrimaryAmmoType");
		local ammo = player.GetNetPropInt("m_iAmmo", ammoType);
		
		if(!(index in ::WeaponInfo.FinalClip) || ::WeaponInfo.FinalClip[index] <= 0)
		{
			::WeaponInfo.FinalClip[index] <- ::WeaponInfo.GetWeaponClip(this.ent);
			/*
			if(this.ent.GetClassname() == "weapon_pistol" && this.ent.GetNetPropBool("m_isDualWielding"))
				::WeaponInfo.FinalClip[index] *= 2;
			*/
			
			// 验证备用弹药数量是否足够
			if(::WeaponInfo.FinalClip[index] > ammo)
				::WeaponInfo.FinalClip[index] = ammo;
			
			// printl("player " + player.GetName() + " reloading. maxclip = " + ::WeaponInfo.FinalClip[index]);
		}
		
		if(::WeaponInfo.FinalClip[index] <= 0)
		{
			// 当前弹药够多了，不需要换子弹
			this.ent.AddThinkFunction(null);
			::WeaponInfo.ClearTable(index);
			// this.ent.SetNetPropInt("m_bInReload", 0);
			// this.ent.SetNetPropInt("m_reloadState", 0);
			printl("player " + player.GetName() + " reload stopped by fullammo");
			return;
		}
		
		if(this.ent.GetNetPropBool("m_bInReload"))
		{
			if(this.ent.GetClassname().find("shotgun") != null)
			{
				// 霰弹枪换弹
				if(index in ::WeaponInfo.LastClip && ::WeaponInfo.LastClip[index] > 0)
				{
					// 还原开始填装时的弹药数量
					this.ent.SetNetPropInt("m_iClip1", ::WeaponInfo.LastClip[index]);
					
					local requirement = ::WeaponInfo.FinalClip[index] - ::WeaponInfo.LastClip[index];
					if(requirement > ammo)
						requirement = ammo;
					
					// ::WeaponInfo.FinalClip[index] = requirement;
					::WeaponInfo.LastClip[index] <- 0;
					::WeaponInfo.RequirementAmmo[index] <- requirement;
				}
				
				if(index in ::WeaponInfo.RequirementAmmo && ::WeaponInfo.RequirementAmmo[index] > 0)
				{
					// 设置需要填装多少颗子弹
					// 弹夹上限 = 开始填装的弹药数 + 需要填装多少颗子弹
					this.ent.SetNetPropInt("m_reloadNumShells", ::WeaponInfo.RequirementAmmo[index]);
				}
				
				if(this.ent.GetNetPropInt("m_iClip1") >= ::WeaponInfo.FinalClip[index])
				{
					this.ent.SetNetPropInt("m_bInReload", 0);
					this.ent.SetNetPropInt("m_reloadState", 0);
					this.ent.SetNetPropInt("m_reloadAnimState", 0);
					this.ent.SetNetPropInt("m_reloadFromEmpty", 0);
					this.ent.SetNetPropInt("m_reloadNumShells", 0);
					this.ent.SetNetPropInt("m_shellsInserted", 0);
				}
			}
			
			this.ent.SetNetPropInt("m_iExtraPrimaryAmmo", ammo);
			::WeaponInfo.HasRelading[index] <- true;
		}
		else
		{
			local function doReloadComplete(weapon, player, index)
			{
				weapon.AddThinkFunction(null);
				::WeaponInfo.ClearTable(index);
				// printl("player " + player.GetName() + " reload success");
			}
			
			local classname = this.ent.GetClassname();
			if(classname.find("shotgun") == null)
			{
				local clip = this.ent.GetNetPropInt("m_iClip1");
				
				/*
				if(player.IsPressingAttack())
				{
					clip -= 1;
					if(clip < 0)
						clip = 0;
				}
				*/
				
				if(clip >= ::WeaponInfo.GetWeaponDefalutClip(classname) || ammo <= 0)
				{
					// 非霰弹枪换弹完成
					this.ent.SetNetPropInt("m_iClip1", ::WeaponInfo.FinalClip[index]);
					player.SetNetPropInt("m_iAmmo", ammo + clip - ::WeaponInfo.FinalClip[index], ammoType);
					this.ent.SetNetPropInt("m_iExtraPrimaryAmmo", player.GetNetPropInt("m_iAmmo", ammoType));
					
					doReloadComplete(this.ent, player, index);
					return;
				}
				else if(index in ::WeaponInfo.HasReloadBlocked || player.GetMoveType() == MOVETYPE_LADDER ||
					player.GetCurrentAttacker() != null)
				{
					// 因为各种意外情况取消换弹
					doReloadComplete(this.ent, player, index);
					return;
				}
				
				// 换子弹完成了，但是子弹还没有就位
			}
			else
			{
				// 霰弹枪换弹完成或取消换弹
				doReloadComplete(this.ent, player, index);
				return;
			}
		}
		
		this.ent.SetNextThinkTime(Time() + 0.1);
	},
	
	function Timer_HookTimedButton(params)
	{
		local buttonHooked = 0;
		foreach(entity in Objects.OfClassname("func_button_timed"))
		{
			// 按按钮
			entity.ConnectOutput("OnPressed", ::WeaponInfo.ButtonPress_OnTimedButtonPressing);
			++buttonHooked;
		}
		
		printl("func_button_timed found " + buttonHooked);
	},
	
	function ButtonPress_OnTimedButtonPressing()
	{
		if(caller == null || !caller.IsValid() || activator == null || !activator.IsValid() ||
			!activator.IsPlayer() || !activator.IsSurvivor())
			return;
		
		local entity = ::VSLib.Entity(caller);
		if(entity.GetClassname() != "func_button_timed")
		{
			// 普通按钮不会中断换子弹的
			entity.DisconnectOutput("OnPressed", ::WeaponInfo.ButtonPress_OnTimedButtonPressing);
			return;
		}
		
		local player = ::VSLib.Player(activator);
		local weapon = player.GetActiveWeapon();
		if(weapon == null || !weapon.IsEntityValid())
			return;
		
		local index = weapon.GetIndex();
		if(index in ::WeaponInfo.HasRelading && ::WeaponInfo.HasRelading[index])
		{
			::WeaponInfo.HasReloadBlocked[index] <- true;
			printl("player " + player.GetName() + " reload stopped by button pressing");
		}
	},
	
	function TimerButton_OnPlayerThink(params)
	{
		if(!::WeaponInfo.ConfigVar.Enable)
			return;
		
		foreach(player in Players.AliveSurvivors())
		{
			local weapon = player.GetActiveWeapon();
			if(weapon == null || !weapon.IsEntityValid())
				continue;
			
			local index = weapon.GetIndex();
			if(index in ::WeaponInfo.HasRelading && ::WeaponInfo.HasRelading[index])
				continue;
			
			local classname = weapon.GetClassname();
			local clip = weapon.GetNetPropInt("m_iClip1");
			local maxClip = ::WeaponInfo.GetWeaponClip(weapon);
			local ammoType = weapon.GetNetPropInt("m_iPrimaryAmmoType");
			local ammo = player.GetNetPropInt("m_iAmmo", ammoType);
			
			// 检查武器是否可以换弹夹
			// 如果当前弹夹小于 0 则会自动换子弹，如果弹夹上限小于 0 则该武器不支持换弹夹
			if(!Utils.IsValidFireWeapon(classname) || clip <= 0 || maxClip <= 0)
				continue;
			
			local info = ::WeaponInfo.GetWeaponData(player);
			if(player.IsPressingUse() && classname in info && "ammo" in info[classname] && info[classname]["ammo"] > 0)
			{
				local entity = player.GetLookingEntity(TRACE_MASK_SHOT);
				local maxAmmo = info[classname]["ammo"] + maxClip - clip;
				if(entity != null && ammo < maxAmmo && entity.IsEntityValid() &&
					entity.GetClassname().find("weapon_ammo") == 0 &&
					Utils.CalculateDistance(player.GetLocation(), entity.GetLocation()) <=
					Convars.GetFloat("player_use_radius"))
				{
					weapon.SetNetPropInt("m_iExtraPrimaryAmmo", maxAmmo);
					player.SetNetPropInt("m_iAmmo", maxAmmo, weapon.GetNetPropInt("m_iPrimaryAmmoType"));
				}
			}
			
			if(clip >= maxClip)
			{
				// 禁止弹药太多的武器换弹夹
				if(::WeaponInfo.ConfigVar.AntiReload && !player.HasDisabledButton(BUTTON_RELOAD))
					player.DisableButton(BUTTON_RELOAD);
				
				continue;
			}
			
			// 现在可以换弹夹
			if(player.HasDisabledButton(BUTTON_RELOAD))
				player.EnableButton(BUTTON_RELOAD);
			
			// 没有备用弹药的武器不能换弹夹
			if(ammo <= 0 || !player.IsPressingReload() || maxClip <= ::WeaponInfo.GetWeaponDefalutClip(weapon))
				continue;
			
			local index = weapon.GetIndex();
			if(classname.find("shotgun") != null)
			{
				// 当前没有进行填装，设置允许进行填装
				// local defclip = ::WeaponInfo.GetWeaponDefalutClip(weapon);
				// weapon.SetNetPropInt("m_iClip1", (clip >= defclip ? defclip - 1 : clip));
				weapon.SetNetPropInt("m_iClip1", 0);
				::WeaponInfo.LastClip[index] <- clip;
				::WeaponInfo.RequirementAmmo[index] <- maxClip - clip;
				// player.ShowHint("lastClip = " + clip + ", maxclip = " + maxClip);
			}
			else
			{
				// 非霰弹枪的强制开始更换弹夹
				if(classname in info && "holdclip" in info[classname] && info[classname]["holdclip"])
				{
					weapon.SetNetPropInt("m_iClip1", 0);
					::WeaponInfo.LastClip[index] <- clip;
				}
				else
				{
					player.SetNetPropInt("m_iAmmo", ammo + clip, ammoType);
					weapon.SetNetPropInt("m_iExtraPrimaryAmmo", ammo + clip);
					weapon.SetNetPropInt("m_iClip1", 0);
				}
			}
		}
	},
	
	function Timer_ResetWeaponPlayback(entity)
	{
		if(entity == null || !entity.IsEntityValid())
			return;
		
		entity.SetNetPropFloat("m_flPlaybackRate", 1.0);
	},
	
	function Timer_ResetPlayerStartTime(params)
	{
		if(!("client" in params) || !("startTime" in params) || params["client"] == null ||
			!params["client"].IsPlayerEntityValid() || !params["client"].IsSurvivor())
			return;
		
		local viewModel = params["client"].GetNetPropEntity("m_hViewModel");
		if(viewModel == null || !viewModel.IsEntityValid())
			return;
		
		viewModel.SetNetPropFloat("m_flLayerStartTime", params["startTime"]);
	},
	
	function Timer_ResetShotgunTime(params)
	{
		if(!("player" in params) || !("weapon" in params) ||
			params["player"] == null || !params["player"].IsPlayerEntityValid() || !params["player"].IsSurvivor() ||
			params["weapon"] == null || !params["weapon"].IsEntityValid())
			return;
		
		if(params["weapon"].GetNetPropInt("m_reloadState") == 0)
		{
			local time = Time() + 0.2;
			params["weapon"].SetNetPropFloat("m_flPlaybackRate", 1.0);
			params["player"].SetNetPropFloat("m_flNextAttack", time);
			params["weapon"].SetNetPropFloat("m_flTimeWeaponIdle", time);
			params["weapon"].SetNetPropFloat("m_flNextPrimaryAttack", time);
			return false;
		}
	},
	
	function Timer_StartShotgunReload(params)
	{
		if(!("client" in params) || !("speed" in params) || !("entity" in params) || !("clname" in params) ||
			params["client"] == null || !params["client"].IsPlayerEntityValid() || !params["client"].IsSurvivor() ||
			params["entity"] == null || !params["entity"].IsEntityValid())
			return;
		
		switch(params["clname"])
		{
			case "weapon_autoshotgun":
				params["entity"].SetNetPropFloat("m_reloadStartDuration", 0.666666 * params["speed"]);
				params["entity"].SetNetPropFloat("m_reloadInsertDuration", 0.4 * params["speed"]);
				params["entity"].SetNetPropFloat("m_reloadEndDuration", 0.675 * params["speed"]);
				params["entity"].SetNetPropFloat("m_flPlaybackRate", 1.0 / params["speed"]);
				Timers.AddTimerByName("timer_shotgunreload_" + params["entity"].GetIndex(), 0.3, true,
					::WeaponInfo.Timer_ResetShotgunTime,
					{player = params["client"], weapon = params["entity"]});
				break;
			case "weapon_shotgun_spas":
				params["entity"].SetNetPropFloat("m_reloadStartDuration", 0.5 * params["speed"]);
				params["entity"].SetNetPropFloat("m_reloadInsertDuration", 0.375 * params["speed"]);
				params["entity"].SetNetPropFloat("m_reloadEndDuration", 0.699999 * params["speed"]);
				params["entity"].SetNetPropFloat("m_flPlaybackRate", 1.0 / params["speed"]);
				Timers.AddTimerByName("timer_shotgunreload_" + params["entity"].GetIndex(), 0.3, true,
					::WeaponInfo.Timer_ResetShotgunTime,
					{player = params["client"], weapon = params["entity"]});
				break;
			case "weapon_pumpshotgun":
			case "weapon_shotgun_chrome":
				params["entity"].SetNetPropFloat("m_reloadStartDuration", 0.5 * params["speed"]);
				params["entity"].SetNetPropFloat("m_reloadInsertDuration", 0.5 * params["speed"]);
				params["entity"].SetNetPropFloat("m_reloadEndDuration", 0.6 * params["speed"]);
				params["entity"].SetNetPropFloat("m_flPlaybackRate", 1.0 / params["speed"]);
				Timers.AddTimerByName("timer_shotgunreload_" + params["entity"].GetIndex(), 0.3, true,
					::WeaponInfo.Timer_ResetShotgunTime,
					{player = params["client"], weapon = params["entity"]});
				break;
		}
	},
	
	function StartWeaponReload(player, rate)
	{
		if(player == null || !player.IsPlayerEntityValid() || !player.IsSurvivor() || player.IsDead())
			return;
		
		local weapon = player.GetActiveWeapon();
		if(weapon == null || !weapon.IsEntityValid())
			return;
		
		local classname = weapon.GetClassname();
		if(classname.find("shotgun") == null)
		{
			local time = Time();
			local nextAttack = weapon.GetNetPropFloat("m_flNextPrimaryAttack");
			local calc = (nextAttack - time) * rate;
			
			weapon.SetNetPropFloat("m_flPlaybackRate", 1.0 / rate);
			Timers.AddTimerByName("timer_weaponreload1_" + weapon.GetIndex(), calc, false,
				::WeaponInfo.Timer_ResetWeaponPlayback, weapon);
			
			if(calc - 0.4 > 0.0)
			{
				Timers.AddTimerByName("timer_weaponreload2_" + weapon.GetIndex(), calc - 0.4, false,
					::WeaponInfo.Timer_ResetPlayerStartTime,
					{client = player, startTime = (time - nextAttack) * (1.0 - rate)});
			}
			
			calc += time;
			weapon.SetNetPropFloat("m_flTimeWeaponIdle", calc);
			weapon.SetNetPropFloat("m_flNextPrimaryAttack", calc);
			player.SetNetPropFloat("m_flNextAttack", calc);
		}
		else
		{
			Timers.AddTimerByName("timer_startshotgunreload_" + weapon.GetIndex(), 0.1, false,
				::WeaponInfo.Timer_StartShotgunReload,
				{client = player, speed = rate, entity = weapon, clname = classname});
		}
	},
	
	function StartWeaponFire(player, rate)
	{
		if(player == null || !player.IsPlayerEntityValid() || !player.IsSurvivor() || player.IsDead())
			return false;
		
		local weapon = player.GetActiveWeapon();
		if(weapon == null || !weapon.IsEntityValid())
			return false;
		
		if(weapon.GetClassname().find("weapon_") != 0)
			return false;
		
		local time = Time();
		local nextAttack = weapon.GetNetPropFloat("m_flNextPrimaryAttack");
		if(nextAttack <= time)
			return false;
		
		// 或许需要修改的是玩家 View 模型？
		weapon.SetNetPropFloat("m_flPlaybackRate", 1.0 / rate);
		
		// 主要攻击(射击)
		local primary = (nextAttack - time) * rate;
		weapon.SetNetPropFloat("m_flNextPrimaryAttack", time + primary);
		
		// 次要攻击(推)
		local secondary = (weapon.GetNetPropFloat("m_flNextSecondaryAttack") - time) * rate;
		weapon.SetNetPropFloat("m_flNextSecondaryAttack", time + secondary);
		
		// 掏出武器时的等待时间(可能需要)
		local drawing = (player.GetNetPropFloat("m_flNextAttack") - time) * rate;
		player.SetNetPropFloat("m_flNextAttack", time + drawing);
		
		Timers.AddTimerByName("timer_weaponfire_" + weapon.GetIndex(), primary, false,
			::WeaponInfo.Timer_ResetWeaponPlayback, weapon);
		
		return true;
	},
	
	function Command_UpdateWeaponInfo(player, cmdstr, defunc, arg1, arg2)
	{
		local total = 0;
		
		if(arg2 != null && arg2 != "")
		{
			if(arg1 == null || arg1 == "")
				return;
			
			local number = arg2.tofloat();
			if(number <= 0.0)
			{
				player.ShowHint("invalid params2: " + arg2 + ", must > 0.0", 9);
				return;
			}
			
			if(arg1 in ::WeaponInfo.WeaponList)
			{
				foreach(item in ::WeaponInfo.WeaponList[arg1])
				{
					if(!(item in ::WeaponInfo.WeaponData) || typeof(::WeaponInfo.WeaponData[item]) != "table")
						::WeaponInfo.WeaponData[item] <- {};
					
					total += 1;
					::WeaponInfo.WeaponData[item][cmdstr] <- defunc(item) * number;
					printl("weapon " + item + " " + cmdstr + " change to " + ::WeaponInfo.WeaponData[item][cmdstr]);
				}
			}
			else
			{
				player.ShowHint("weapon " + arg1 + " not found.", 9);
			}
		}
		else if(arg1 != null && arg1 != "")
		{
			if(arg1 in ::WeaponInfo.WeaponList)
			{
				foreach(item in ::WeaponInfo.WeaponList[arg1])
				{
					if(item in ::WeaponInfo.WeaponData && cmdstr in ::WeaponInfo.WeaponData[item])
					{
						total += 1;
						// ::WeaponInfo.WeaponData[item][cmdstr] <- -1;
						delete ::WeaponInfo.WeaponData[item][cmdstr];
					}
					
					printl("weapon " + item + " " + cmdstr + " changing to default");
				}
			}
			else
			{
				local number = arg1.tofloat();
				if(number > 0.0)
				{
					foreach(item in ::WeaponInfo.WeaponList["_all"])
					{
						if(!(item in ::WeaponInfo.WeaponData) || typeof(::WeaponInfo.WeaponData[item]) != "table")
							::WeaponInfo.WeaponData[item] <- {};
						
						total += 1;
						::WeaponInfo.WeaponData[item][cmdstr] <- arg2 = defunc(item) * number;
						printl("weapon " + item + " " + cmdstr + " changing to " + ::WeaponInfo.WeaponData[item][cmdstr]);
					}
				}
				else
				{
					player.ShowHint("invalid params1: " + arg1 + ", must > 0.0", 9);
				}
			}
		}
		else
		{
			foreach(item in ::WeaponInfo.WeaponList["_all"])
			{
				if(item in ::WeaponInfo.WeaponData && cmdstr in ::WeaponInfo.WeaponData[item])
				{
					total += 1;
					// ::WeaponInfo.WeaponData[item][cmdstr] <- -1;
					delete ::WeaponInfo.WeaponData[item][cmdstr];
				}
			}
			
			printl("all weapon " + cmdstr + " changing to default");
		}
		
		printl("total " + total + " weapon changed");
	}
}

function Notifications::OnRoundBegin::WeaponAmmo_StartThink(params)
{
	Timers.AddTimerByName("timer_weaponreloadammo", 0.1, true, ::WeaponInfo.TimerButton_OnPlayerThink);
	Timers.AddTimerByName("timer_hooktimedbutton", 1.0, false, ::WeaponInfo.Timer_HookTimedButton);
}

function Notifications::FirstSurvLeftStartArea::WeaponAmmo_StartThink(player, params)
{
	Timers.AddTimerByName("timer_weaponreloadammo", 0.1, true, ::WeaponInfo.TimerButton_OnPlayerThink);
	Timers.AddTimerByName("timer_hooktimedbutton", 0.1, false, ::WeaponInfo.Timer_HookTimedButton);
}

function Notifications::OnWeaponReload::WeaponAmmo_Reloading(player, fromEmpty, params)
{
	if(!::WeaponInfo.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayerEntityValid() || !player.IsSurvivor())
		return;
	
	local weapon = player.GetActiveWeapon();
	if(weapon == null || !weapon.IsEntityValid() || !Utils.IsValidFireWeapon(weapon.GetClassname()))
		return;
	
	// 修复无法换弹夹的问题
	if(player.HasDisabledButton(BUTTON_RELOAD))
		player.EnableButton(BUTTON_RELOAD);
	
	local index = player.GetIndex();
	if(index in ::WeaponInfo.HasWeaponFired)
	{
		delete ::WeaponInfo.HasWeaponFired[index];
		printl("warring: player " + player.GetName() + " firehook spread to weapon_reload");
	}
	
	index = weapon.GetIndex();
	local classname = weapon.GetClassname();
	if(index in ::WeaponInfo.HasRelading && ::WeaponInfo.HasRelading[index])
	{
		printl("warring: weapon " + classname + " already in reloading");
	}
	
	local info = ::WeaponInfo.GetWeaponData(player);
	if(classname in info && "reload" in info[classname])
		::WeaponInfo.StartWeaponReload(player, info[classname]["reload"]);
	
	/*
	if(!(index in ::WeaponInfo.LastClip) || ::WeaponInfo.LastClip[index] <= 0)
		::WeaponInfo.LastClip[index] <- weapon.GetNetPropInt("m_iClip1");
	*/
	
	if(index in ::WeaponInfo.LastClip && ::WeaponInfo.LastClip[index] > 0)
	{
		weapon.SetNetPropInt("m_iClip1", ::WeaponInfo.LastClip[index]);
		weapon.SetNetPropInt("m_reloadFromEmpty", 0);
		
		// printl("set weapon clip by weapon_reload (" + ::WeaponInfo.LastClip[index] + ")");
	}
	
	if(classname.find("shotgun") != null)
	{
		if(!(index in ::WeaponInfo.RequirementAmmo) || ::WeaponInfo.RequirementAmmo[index] <= 0)
			::WeaponInfo.RequirementAmmo[index] <- ::WeaponInfo.GetWeaponClip(weapon) - weapon.GetNetPropInt("m_iClip1");
		
		weapon.SetNetPropInt("m_reloadNumShells", ::WeaponInfo.RequirementAmmo[index]);
	}
	
	if(classname in info && "clip" in info[classname] && info[classname]["clip"] > 0)
	{
		::WeaponInfo.WeaponOwner[index] <- player;
		::WeaponInfo.HasRelading[index] <- true;
		weapon.AddThinkFunction(::WeaponInfo.OnWeaponThink_Reloading);
		weapon.SetNextThinkTime(Time() + 0.1);
		
		// printl("enter OnWeaponThink_Reloading hook");
	}
}

// 在玩家尝试开枪时触发
// 但此时子弹还没有射出去
function Notifications::OnWeaponFire::WeaponAmmo_Shoot(player, classname, params)
{
	if(!::WeaponInfo.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayerEntityValid() || !player.IsSurvivor())
		return;
	
	local weapon = player.GetActiveWeapon();
	if(weapon == null || !weapon.IsEntityValid() || !Utils.IsValidFireWeapon(classname))
		return;
	
	local index = player.GetIndex();
	if(index in ::WeaponInfo.HasWeaponFired)
	{
		delete ::WeaponInfo.HasWeaponFired[index];
		printl("warring: player " + player.GetName() + " last firehook spread to new weapon_fire");
	}
	
	if(index in ::WeaponInfo.BulletFired)
		delete ::WeaponInfo.BulletFired[index];
	
	if(index in ::WeaponInfo.HasRelading)
	{
		::WeaponInfo.ClearTable(index);
		printl("warring: player " + player.GetName() + " reloadhook spread to weapon_fire");
	}
	
	local info = ::WeaponInfo.GetWeaponData(player);
	if(classname in info && "fire" in info[classname])
		::WeaponInfo.HasWeaponFired[index] <- classname;
}

// 当子弹射出去时触发
// 但如果是霰弹枪会多次触发
function Notifications::OnBulletImpact::WeaponAmmo_Shoot(player, origin, params)
{
	if(!::WeaponInfo.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayerEntityValid() || !player.IsSurvivor())
		return;
	
	local weapon = player.GetActiveWeapon();
	local classname = weapon.GetClassname();
	if(weapon == null || !weapon.IsEntityValid() || !Utils.IsValidFireWeapon(classname))
		return;
	
	local index = player.GetIndex();
	if(!(index in ::WeaponInfo.BulletFired))
		::WeaponInfo.BulletFired[index] <- 1;
	else
		::WeaponInfo.BulletFired[index] += 1;
	
	if(!(index in ::WeaponInfo.HasWeaponFired))
		return;
	
	if(::WeaponInfo.HasWeaponFired[index] != classname)
	{
		printl("player " + player.GetName() + " bullet_impact weapon is " + classname +
			", but weapon_fire weapon is " + ::WeaponInfo.HasWeaponFired[index] + ". wtf");
		
		delete ::WeaponInfo.HasWeaponFired[index];
		return;
	}
	
	local info = ::WeaponInfo.GetWeaponData(player);
	if(classname in info && "fire" in info[classname])
	{
		if(::WeaponInfo.StartWeaponFire(player, info[classname]["fire"]));
			delete ::WeaponInfo.HasWeaponFired[index];
	}
	
	if(classname in info && "rapidfire" in info[classname] && info[classname]["rapidfire"])
		weapon.SetNetPropInt("m_iShotsFired", 0);
}

function Notifications::OnUpgradePackAdded::WeaponAmmo_PickupUpgrade(player, entity, params)
{
	if(!::WeaponInfo.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayerEntityValid() || !player.IsSurvivor())
		return;
	
	if(entity != null && entity.IsEntityValid())
	{
		if(entity.GetClassname() == "upgrade_laser_sight")
			return;
	}
	
	local inv = player.GetHeldItems();
	if(!("slot0" in inv) || inv["slot0"] == null || !inv["slot0"].IsEntityValid())
		return;
	
	local clip = ::WeaponInfo.GetWeaponClip(inv["slot0"]);
	if(clip > 0)
		inv["slot0"].SetNetPropInt("m_nUpgradedPrimaryAmmoLoaded", clip);
}

function EasyLogic::OnTakeDamage::WeaponAmmo_AttackDamage(dmgTable)
{
	if(!::WeaponInfo.ConfigVar.Enable)
		return true;
	
	if(dmgTable["Victim"] == null || dmgTable["Attacker"] == null || dmgTable["DamageDone"] <= 0.0 ||
		!dmgTable["Attacker"].IsPlayer() || !dmgTable["Victim"].IsEntityValid() || dmgTable["Victim"].IsSurvivor() ||
		dmgTable["Attacker"].GetTeam() == dmgTable["Victim"].GetTeam() ||
		dmgTable["Weapon"] == null || !dmgTable["Weapon"].IsEntityValid())
		return true;
	
	local classname = dmgTable["Weapon"].GetClassname();
	if(Utils.IsValidFireWeapon(classname) && !dmgTable["Attacker"].IsBot())
	{
		// 子弹击中部位检查
		if(dmgTable["Location"] == null)
			return true;
		
		// 检查是否为子弹
		if(!(dmgTable["DamageType"] & DMG_BULLET) && !(dmgTable["DamageType"] & DMG_BUCKSHOT))
			return true;
		
		local index = dmgTable["Attacker"].GetIndex();
		
		// 检查子弹数量，防止一颗子弹打死一堆僵尸
		if(!(index in ::WeaponInfo.BulletFired) || ::WeaponInfo.BulletFired[index] <= 0)
			return true;
		
		/*
		local m_trace = {start = dmgTable["Attacker"].GetEyePosition(), end = dmgTable["Location"],
			ignore = dmgTable["Attacker"].GetBaseEntity(), mask = TRACE_MASK_SHOT};
		TraceLine(m_trace);

		if (!m_trace.hit || m_trace.enthit == null || m_trace.enthit == dmgTable["Attacker"].GetBaseEntity() ||
			!m_trace.enthit.IsValid() || m_trace.enthit.GetClassname() == "worldspawn" ||
			m_trace.enthit != dmgTable["Victim"].GetBaseEntity())
			return true;
		*/
		
		::WeaponInfo.BulletFired[index] -= 1;
	}
	
	local info = ::WeaponInfo.GetWeaponData(dmgTable["Attacker"]);
	if(classname in info && "damage" in info[classname] && info[classname]["damage"] > 0)
		return info[classname]["damage"];
	
	return true;
}

function Notifications::OnAmmoPickup::WeaponAmmo_PickupAmmo(player, params)
{
	if(!::WeaponInfo.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayerEntityValid() || !player.IsSurvivor())
		return;
	
	local inv = player.GetHeldItems();
	if(!("slot0" in inv) || inv["slot0"] == null || !inv["slot0"].IsEntityValid())
		return;
	
	local weaponClassname = inv["slot0"].GetClassname();
	local info = ::WeaponInfo.GetWeaponData(player);
	
	if(weaponClassname in info)
	{
		local clip = inv["slot0"].GetNetPropInt("m_iClip1");
		local maxClip = ::WeaponInfo.GetWeaponClip(inv["slot0"]);
		local maxAmmo = inv["slot0"].GetMaxAmmo();
		
		if("ammo" in info[weaponClassname] && info[weaponClassname]["ammo"] > -1)
			maxAmmo = info[weaponClassname]["ammo"];
		
		inv["slot0"].SetNetPropInt("m_iExtraPrimaryAmmo", maxAmmo + maxClip - clip);
		player.SetNetPropInt("m_iAmmo", maxAmmo + maxClip - clip, inv["slot0"].GetNetPropInt("m_iPrimaryAmmoType"));
	}
}

function Notifications::OnItemPickup::WeaponAmmo_PickupAmmo(player, classname, params)
{
	if(!::WeaponInfo.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayerEntityValid() || !player.IsSurvivor())
		return;
	
	local inv = player.GetHeldItems();
	if(!("slot0" in inv) || inv["slot0"] == null || !inv["slot0"].IsEntityValid())
		return;
	
	local weaponClassname = inv["slot0"].GetClassname();
	local info = ::WeaponInfo.GetWeaponData(player);
	
	if(weaponClassname in info)
	{
		local clip = inv["slot0"].GetNetPropInt("m_iClip1");
		local maxClip = ::WeaponInfo.GetWeaponClip(inv["slot0"]);
		local ammoType = inv["slot0"].GetNetPropInt("m_iPrimaryAmmoType");
		
		local maxAmmo = inv["slot0"].GetMaxAmmo();
		if("ammo" in info[weaponClassname] && info[weaponClassname]["ammo"] > -1)
			maxAmmo = info[weaponClassname]["ammo"];
		
		if(clip > maxClip)
		{
			inv["slot0"].SetNetPropInt("m_iClip1", maxClip);
			clip = maxClip;
		}
		
		if(classname.find("weapon_ammo") == 0 || player.GetNetPropInt("m_iAmmo", ammoType) > maxAmmo)
		{
			inv["slot0"].SetNetPropInt("m_iExtraPrimaryAmmo", maxAmmo + maxClip - clip);
			player.SetNetPropInt("m_iAmmo", maxAmmo + maxClip - clip, ammoType);
		}
	}
}

function Notifications::OnUse::WeaponAmmo_PickupWeapon(player, entity, params)
{
	if(!::WeaponInfo.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayerEntityValid() || !player.IsSurvivor() ||
		entity == null || !entity.IsEntityValid())
		return;
	
	local classname = entity.GetClassname();
	if(classname.find("weapon_") == null || classname.find("_spawn") == null)
		return;
	
	classname = Utils.StringReplace(classname, "_spawn", "");
	Notifications.OnItemPickup.WeaponAmmo_PickupAmmo(player, classname, params);
}

function Notifications::OnReviveBegin::WeaponAmmo_BlockReload(subject, player, params)
{
	if(!::WeaponInfo.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsSurvivor() || player.IsDead() ||
		player.IsIncapacitated() || player.IsHangingFromLedge())
		return;
	
	local weapon = player.GetActiveWeapon();
	if(weapon == null || !weapon.IsEntityValid())
		return;
	
	local index = weapon.GetIndex();
	if(index in ::WeaponInfo.HasRelading && ::WeaponInfo.HasRelading[index])
	{
		::WeaponInfo.HasReloadBlocked[index] <- true;
		printl("player " + player.GetName() + " reload stopped by revive other");
	}
}

function Notifications::OnGrabbedLedge::WeaponAmmo_BlockReload(attacker, victim, params)
{
	if(!::WeaponInfo.ConfigVar.Enable)
		return;
	
	if(victim == null || !victim.IsSurvivor() || victim.IsDead())
		return;
	
	local weapon = victim.GetActiveWeapon();
	if(weapon == null || !weapon.IsEntityValid())
		return;
	
	local index = weapon.GetIndex();
	if(index in ::WeaponInfo.HasRelading && ::WeaponInfo.HasRelading[index])
	{
		::WeaponInfo.HasReloadBlocked[index] <- true;
		printl("player " + victim.GetName() + " reload stopped by ledge");
	}
}

/*
function Notifications::OnIncapacitated::WeaponAmmo_BlockReload(victim, attacker, params)
{
	if(!::WeaponInfo.ConfigVar.Enable)
		return;
	
	if(victim == null || !victim.IsSurvivor() || victim.IsDead())
		return;
	
	local weapon = victim.GetActiveWeapon();
	if(weapon == null || !weapon.IsEntityValid())
		return;
	
	local index = weapon.GetIndex();
	if(index in ::WeaponInfo.HasRelading && ::WeaponInfo.HasRelading[index])
	{
		::WeaponInfo.HasReloadBlocked[index] <- true;
		printl("player " + victim.GetName() + " reload stopped by incapacitated");
	}
}
*/

function CommandTriggersEx::maxammo(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	::WeaponInfo.Command_UpdateWeaponInfo(player, "ammo", ::WeaponInfo.GetWeaponDefaultAmmo, GetArgument(1), GetArgument(2));
}

function CommandTriggersEx::maxclip(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	::WeaponInfo.Command_UpdateWeaponInfo(player, "clip", ::WeaponInfo.GetWeaponDefalutClip, GetArgument(1), GetArgument(2));
}

function CommandTriggersEx::firespeed(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	::WeaponInfo.Command_UpdateWeaponInfo(player, "fire", @(entity) 1.0, GetArgument(1), GetArgument(2));
}

function CommandTriggersEx::reloadspeed(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	::WeaponInfo.Command_UpdateWeaponInfo(player, "reload", @(entity) 1.0, GetArgument(1), GetArgument(2));
}

function CommandTriggersEx::wpndmg(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	::WeaponInfo.Command_UpdateWeaponInfo(player, "damage", ::WeaponInfo.GetWeaponDefalutDamage, GetArgument(1), GetArgument(2));
}


::WeaponInfo.PLUGIN_NAME <- PLUGIN_NAME;
::WeaponInfo.ConfigVar = ::WeaponInfo.ConfigVarDef;

function Notifications::OnRoundStart::WeaponInfo_LoadConfig()
{
	RestoreTable(::WeaponInfo.PLUGIN_NAME, ::WeaponInfo.ConfigVar);
	if(::WeaponInfo.ConfigVar == null || ::WeaponInfo.ConfigVar.len() <= 0)
		::WeaponInfo.ConfigVar = FileIO.GetConfigOfFile(::WeaponInfo.PLUGIN_NAME, ::WeaponInfo.ConfigVarDef);

	// printl("[plugins] " + ::WeaponInfo.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::WeaponInfo_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::WeaponInfo.PLUGIN_NAME, ::WeaponInfo.ConfigVar);

	// printl("[plugins] " + ::WeaponInfo.PLUGIN_NAME + " saving...");
}
