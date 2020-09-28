::IncapacitatedWeapon <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 7,

		// 倒地后单手枪变更为什么武器.0=不更改.1=单手枪.2=双手枪.3=马格南
		SinglePistol = 1,

		// 倒地后双手枪变更为什么武器.0=不更改.1=单手枪.2=双手枪.3=马格南
		DoublePistol = 2,

		// 倒地后马格南变更为什么武器.0=不更改.1=单手枪.2=双手枪.3=马格南
		MagnumPistol = 3,

		// 倒地后近战武器变更为什么武器.0=不更改.1=单手枪.2=双手枪.3=马格南
		Melee = 1,

		// 倒地后电锯变更为什么武器.0=不更改.1=单手枪.2=双手枪.3=马格南
		Chainsaw = 1,

		// 倒地伤害倍率
		IncapDmgModifier = 2.0,
		
		// 控制人特感伤害倍率
		GrabDmgModifier = 2.0
	},

	ConfigVar = {},

	DefaultWeapon = {},
	ReplaceWeapon = {},
	LastWeaponEntity = {},
	LastWeaponData = {},
	
	function Timer_UpdateChainsawClip(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.GetTeam() != SURVIVORS || player.IsDead())
			return;
		
		local index = player.GetIndex();
		local inv = player.GetHeldItems();
		if(!("slot1" in inv) || inv["slot1"] == null || !inv["slot1"].IsEntityValid() ||
			inv["slot1"].GetClassname() != "weapon_chainsaw")
			return;
		
		if(!(index in ::IncapacitatedWeapon.LastWeaponData) ||
			typeof(::IncapacitatedWeapon.LastWeaponData[index]) != "integer")
			return;
		
		inv["slot1"].SetClip(::IncapacitatedWeapon.LastWeaponData[index]);
		printl("player " + player.GetName() + "'s weapon_chainsaw updated.");
	}
	
	function TimerGive_OnPlayerRevived(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.GetTeam() != SURVIVORS || player.IsDead())
			return;
		
		local index = player.GetIndex();
		local inv = player.GetHeldItems();
		if("slot1" in inv && inv["slot1"] != null && inv["slot1"].IsEntityValid())
		{
			::IncapacitatedWeapon.LastWeaponEntity[index] <- inv["slot1"];
			return;
		}
		
		switch(::IncapacitatedWeapon.DefaultWeapon[index])
		{
			case 1:
				player.Give("weapon_pistol");
				break;
			case 2:
				player.Give("weapon_pistol");
				player.Give("weapon_pistol");
				break;
			case 3:
				player.Give("weapon_pistol_magnum");
				break;
			case 4:
				player.Give(::IncapacitatedWeapon.LastWeaponData[index]);
				break;
			case 5:
				player.Give("weapon_chainsaw");
				Timer_UpdateChainsawClip(player);
				break;
		}
		
		delete ::IncapacitatedWeapon.DefaultWeapon[index];
		delete ::IncapacitatedWeapon.ReplaceWeapon[index];
		delete ::IncapacitatedWeapon.LastWeaponData[index];
		return;
	},
	
	function TimerGive_OnPlayerIncapacitated(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.GetTeam() != SURVIVORS || player.IsDead())
			return;
		
		local index = player.GetIndex();
		local inv = player.GetHeldItems();
		if("slot1" in inv && inv["slot1"] != null && inv["slot1"].IsEntityValid())
		{
			::IncapacitatedWeapon.LastWeaponEntity[index] <- inv["slot1"];
			return;
		}
		
		switch(::IncapacitatedWeapon.ReplaceWeapon[index])
		{
			case 1:
				player.Give("weapon_pistol");
				break;
			case 2:
				player.Give("weapon_pistol");
				player.Give("weapon_pistol");
				break;
			case 3:
				player.Give("weapon_pistol_magnum");
				break;
		}
		
		return;
	},
	
	function Timer_OnIncapacitatedPost(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.GetTeam() != SURVIVORS || player.IsDead())
			return false;
		
		local index = player.GetIndex();
		if(!(index in ::IncapacitatedWeapon.LastWeaponEntity))
			return false;
		
		if(::IncapacitatedWeapon.LastWeaponEntity[index] == null ||
			!::IncapacitatedWeapon.LastWeaponEntity[index].IsEntityValid())
		{
			delete ::IncapacitatedWeapon.LastWeaponEntity[index];
			return false;
		}
		
		local inv = player.GetHeldItems();
		if("slot1" in inv && inv["slot1"] != null && inv["slot1"].IsEntityValid())
			return false;
		
		if(inv["slot1"] != ::IncapacitatedWeapon.LastWeaponEntity[index])
		{
			Notifications.OnIncapacitated.IncapacitatedWeapon_OnIncapPost(player, null, {});
			return false;
		}
		
		return true;
	}
};

function Notifications::OnPostSpawn::IncapacitatedWeapon_UpdateWeapon(player, params)
{
	Notifications.OnUse.IncapacitatedWeapon_UpdateWeapon(player, null, params);
}

function Notifications::OnUse::IncapacitatedWeapon_UpdateWeapon(player, entity, params)
{
	if(!::IncapacitatedWeapon.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayerEntityValid() || player.GetTeam() != SURVIVORS ||
		player.IsDead() || player.IsIncapacitated())
		return;
	
	local inv = player.GetHeldItems();
	if(!("slot1" in inv) || inv["slot1"] == null || !inv["slot1"].IsEntityValid())
		return;
	
	::IncapacitatedWeapon.LastWeaponEntity[player.GetIndex()] <- inv["slot1"];
}

function Notifications::OnBotReplacedPlayer::IncapacitatedWeapon_UpdateWeapon(player, bot, params)
{
	if(!::IncapacitatedWeapon.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayerEntityValid() ||
		bot == null || !bot.IsPlayerEntityValid())
		return;
	
	local index = player.GetIndex();
	if(index in ::IncapacitatedWeapon.LastWeaponEntity)
	{
		::IncapacitatedWeapon.LastWeaponEntity[bot.GetIndex()] <- ::IncapacitatedWeapon.LastWeaponEntity[index];
		delete ::IncapacitatedWeapon.LastWeaponEntity[index];
	}
}

function Notifications::OnPlayerReplacedBot::IncapacitatedWeapon_UpdateWeapon(player, bot, params)
{
	if(!::IncapacitatedWeapon.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayerEntityValid() ||
		bot == null || !bot.IsPlayerEntityValid())
		return;
	
	local index = bot.GetIndex();
	if(index in ::IncapacitatedWeapon.LastWeaponEntity)
	{
		::IncapacitatedWeapon.LastWeaponEntity[player.GetIndex()] <- ::IncapacitatedWeapon.LastWeaponEntity[index];
		delete ::IncapacitatedWeapon.LastWeaponEntity[index];
	}
}

function Notifications::OnIncapacitatedStart::IncapacitatedWeapon_OnIncapPre(victim, attacker, params)
{
	if(!::IncapacitatedWeapon.ConfigVar.Enable)
		return;
	
	if(victim == null || !victim.IsPlayerEntityValid() || victim.GetTeam() != SURVIVORS || victim.IsDead())
		return;
	
	local inv = victim.GetHeldItems();
	if(!("slot1" in inv) || inv["slot1"] == null || !inv["slot1"].IsEntityValid())
		return;
	
	local index = victim.GetIndex();
	local classname = inv["slot1"].GetClassname();
	
	switch(classname)
	{
		case "weapon_chainsaw":
			::IncapacitatedWeapon.DefaultWeapon[index] <- 5;
			::IncapacitatedWeapon.LastWeaponData[index] <- inv["slot1"].GetClip();
			break;
		case "weapon_melee":
			::IncapacitatedWeapon.DefaultWeapon[index] <- 4;
			::IncapacitatedWeapon.LastWeaponData[index] <- inv["slot1"].GetMeleeName();
			break;
		case "weapon_pistol_magnum":
			::IncapacitatedWeapon.DefaultWeapon[index] <- 3;
			::IncapacitatedWeapon.LastWeaponData[index] <- null;
			break;
		case "weapon_pistol":
			::IncapacitatedWeapon.DefaultWeapon[index] <- (inv["slot1"].GetNetPropBool("m_hasDualWeapons") ? 2 : 1);
			::IncapacitatedWeapon.LastWeaponData[index] <- null;
			break;
		default:
			::IncapacitatedWeapon.DefaultWeapon[index] <- 0;
			::IncapacitatedWeapon.LastWeaponData[index] <- null;
	}
	
	::IncapacitatedWeapon.LastWeaponEntity[index] <- inv["slot1"];
	printl("player " + victim.GetName() + " incap_start, weapon is " + classname + ", data is " + ::IncapacitatedWeapon.LastWeaponData[index]);
}

function Notifications::OnIncapacitated::IncapacitatedWeapon_OnIncapPost(victim, attacker, params)
{
	if(!::IncapacitatedWeapon.ConfigVar.Enable)
		return;
	
	if(victim == null || !victim.IsPlayerEntityValid() || victim.GetTeam() != SURVIVORS || victim.IsDead())
		return;
	
	local index = victim.GetIndex();
	if(!(index in ::IncapacitatedWeapon.DefaultWeapon) || ::IncapacitatedWeapon.DefaultWeapon[index] <= 0 ||
		!(index in ::IncapacitatedWeapon.LastWeaponEntity))
		return;
	
	local newWeapon = 0;
	switch(::IncapacitatedWeapon.DefaultWeapon[index])
	{
		case 1:
			newWeapon = ::IncapacitatedWeapon.ConfigVar.SinglePistol;
			break;
		case 2:
			newWeapon = ::IncapacitatedWeapon.ConfigVar.DoublePistol;
			break;
		case 3:
			newWeapon = ::IncapacitatedWeapon.ConfigVar.MagnumPistol;
			break;
		case 4:
			newWeapon = ::IncapacitatedWeapon.ConfigVar.Melee;
			break;
		case 5:
			newWeapon = ::IncapacitatedWeapon.ConfigVar.Chainsaw;
			break;
	}
	
	::IncapacitatedWeapon.ReplaceWeapon[index] <- newWeapon;
	if(newWeapon <= 0 || newWeapon > 3)
		return;
	
	local inv = victim.GetHeldItems();
	if("slot1" in inv && inv["slot1"] != null && inv["slot1"].IsEntityValid())
	{
		if((::IncapacitatedWeapon.DefaultWeapon[index] == ::IncapacitatedWeapon.ConfigVar.Melee ||
			::IncapacitatedWeapon.DefaultWeapon[index] == ::IncapacitatedWeapon.ConfigVar.Chainsaw) &&
			(inv["slot1"] == ::IncapacitatedWeapon.LastWeaponEntity[index]))
		{
			// delete ::IncapacitatedWeapon.LastWeaponEntity[index];
			Timers.AddTimerByName("timer_incappost_" + index, 0.1, true,
				::IncapacitatedWeapon.Timer_OnIncapacitatedPost);
			
			return;
		}
		
		delete ::IncapacitatedWeapon.LastWeaponEntity[index];
		inv["slot1"].Kill();
	}
	
	switch(newWeapon)
	{
		case 1:
			victim.Give("weapon_pistol");
			break;
		case 2:
			victim.Give("weapon_pistol");
			victim.Give("weapon_pistol");
			break;
		case 3:
			victim.Give("weapon_pistol_magnum");
			break;
	}
	
	// 某些时候会有武器没有给到的问题，需要进行检查
	Timers.AddTimerByName("timer_incapwpn_" + index, 0.1, false,
		::IncapacitatedWeapon.TimerGive_OnPlayerIncapacitated, victim);
}

function Notifications::OnReviveSuccess::IncapacitatedWeapon_ReviveRestore(subject, player, params)
{
	if(!::IncapacitatedWeapon.ConfigVar.Enable)
		return;
	
	if(subject == null || !subject.IsPlayerEntityValid() || subject.GetTeam() != SURVIVORS || subject.IsDead())
		return;
	
	local index = subject.GetIndex();
	if(!(index in ::IncapacitatedWeapon.DefaultWeapon) || ::IncapacitatedWeapon.DefaultWeapon[index] <= 0 ||
		!(index in ::IncapacitatedWeapon.ReplaceWeapon) || ::IncapacitatedWeapon.ReplaceWeapon[index] <= 0)
		return;
	
	if(/*::IncapacitatedWeapon.DefaultWeapon[index] == 4 || ::IncapacitatedWeapon.DefaultWeapon[index] == 5 ||*/
		::IncapacitatedWeapon.DefaultWeapon[index] == ::IncapacitatedWeapon.ReplaceWeapon[index])
		return;
	
	local inv = subject.GetHeldItems();
	if("slot1" in inv && inv["slot1"] != null && inv["slot1"].IsEntityValid())
		inv["slot1"].Kill();
	
	switch(::IncapacitatedWeapon.DefaultWeapon[index])
	{
		case 1:
			subject.Give("weapon_pistol");
			break;
		case 2:
			subject.Give("weapon_pistol");
			subject.Give("weapon_pistol");
			break;
		case 3:
			subject.Give("weapon_pistol_magnum");
			break;
		case 4:
			subject.Give(::IncapacitatedWeapon.LastWeaponData[index]);
			break;
		case 5:
			subject.Give("weapon_chainsaw");
			Timers.AddTimerByName("timer_updwpn_" + subject.GetIndex(), 0.1, false,
				::IncapacitatedWeapon.Timer_UpdateChainsawClip, subject);
			break;
	}
	
	// delete ::IncapacitatedWeapon.DefaultWeapon[index];
	// delete ::IncapacitatedWeapon.ReplaceWeapon[index];
	// delete ::IncapacitatedWeapon.LastWeaponData[index];
	Timers.AddTimerByName("timer_revivewpn_" + subject.GetIndex(), 0.1, false,
		::IncapacitatedWeapon.TimerGive_OnPlayerRevived, subject);
}

function Notifications::OnDeath::IncapacitatedWeapon_DropWeapon(victim, attacker, params)
{
	if(!::IncapacitatedWeapon.ConfigVar.Enable)
		return;
	
	if(victim == null || !victim.IsSurvivor() || victim.IsPlayerEntityValid())
		return;
	
	local index = victim.GetIndex();
	if(!(index in ::IncapacitatedWeapon.LastWeaponEntity))
		return;
	
	if(::IncapacitatedWeapon.LastWeaponEntity[index] == null ||
		!::IncapacitatedWeapon.LastWeaponEntity[index].IsEntityValid())
	{
		delete ::IncapacitatedWeapon.LastWeaponEntity[index];
		return;
	}
	
	if(::IncapacitatedWeapon.LastWeaponEntity[index].GetOwnerEntity() != victim)
		::IncapacitatedWeapon.LastWeaponEntity[index].SetNetPropEntity("m_hOwnerEntity", victim);
	
	// 因为倒地后会把原来的副武器移除，导致复活后原武器失踪
	// 在这里把原有的武器扔掉，这样玩家被复活后可以捡回自己的武器
	// 当然由于是掉落，也可以被其他玩家捡走，不过总比永远丢失好
	victim.DropWeaponSlot(SLOT_SECONDARY);
	// delete ::IncapacitatedWeapon.LastWeaponEntity[index];
}

function EasyLogic::OnTakeDamage::IncapacitatedWeapon_IncapDmgModifierKill(dmgTable)
{
	if(dmgTable["Victim"] == null || dmgTable["Attacker"] == null || dmgTable["DamageDone"] <= 0.0 ||
		!dmgTable["Attacker"].IsSurvivor() || dmgTable["Victim"].GetTeam() != INFECTED ||
		dmgTable["Weapon"] == null || !("GetClassname" in dmgTable["Weapon"]))
		return true;
	
	if(!(dmgTable["DamageType"] & DMG_BULLET) && !(dmgTable["DamageType"] & DMG_BUCKSHOT))
		return true;
	
	local type = dmgTable["Victim"].GetType();
	local classname = dmgTable["Weapon"].GetClassname();
	local modifier = 1.0;
	
	if(::IncapacitatedWeapon.ConfigVar.IncapDmgModifier > 1.0 && dmgTable["Attacker"].IsIncapacitated() &&
		(classname == "weapon_pistol" || classname == "weapon_pistol_magnum"))
		modifier += ::IncapacitatedWeapon.ConfigVar.IncapDmgModifier - 1.0;
	
	if(::IncapacitatedWeapon.ConfigVar.GrabDmgModifier > 1.0 && type >= Z_SMOKER && type <= Z_CHARGER &&
		dmgTable["Victim"].GetCurrentVictim() != null)
		modifier += ::IncapacitatedWeapon.ConfigVar.GrabDmgModifier - 1.0;
	
	if(modifier <= 1.0)
		return true;
	
	return (dmgTable["DamageDone"] * modifier);
}

function CommandTriggersEx::im(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	::IncapacitatedWeapon.ConfigVar.Enable = !::IncapacitatedWeapon.ConfigVar.Enable;
	
	printl("incap magnum setting " + ::IncapacitatedWeapon.ConfigVar.Enable);
}

::IncapacitatedWeapon.PLUGIN_NAME <- PLUGIN_NAME;
::IncapacitatedWeapon.ConfigVar = ::IncapacitatedWeapon.ConfigVarDef;

function Notifications::OnRoundStart::IncapacitatedWeapon_LoadConfig()
{
	RestoreTable(::IncapacitatedWeapon.PLUGIN_NAME, ::IncapacitatedWeapon.ConfigVar);
	if(::IncapacitatedWeapon.ConfigVar == null || ::IncapacitatedWeapon.ConfigVar.len() <= 0)
		::IncapacitatedWeapon.ConfigVar = FileIO.GetConfigOfFile(::IncapacitatedWeapon.PLUGIN_NAME, ::IncapacitatedWeapon.ConfigVarDef);

	// printl("[plugins] " + ::IncapacitatedWeapon.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::IncapacitatedWeapon_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::IncapacitatedWeapon.PLUGIN_NAME, ::IncapacitatedWeapon.ConfigVar);

	// printl("[plugins] " + ::IncapacitatedWeapon.PLUGIN_NAME + " saving...");
}
