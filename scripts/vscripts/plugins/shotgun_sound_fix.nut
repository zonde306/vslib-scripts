::ShotgunSoundFix <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = false,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31
	},
	
	ConfigVar = {},
	
	EnableShotGunSound = {},
	
	smoker = [30, 31, 32, 36, 37, 38, 39],
	boomer = [30, 31, 32, 33],
	hunter = [38, 39, 40, 41, 42, 43, 45, 46, 47, 48, 49],
	spitter = [17, 18, 19, 20],
	jockey = [8, 15, 16, 17, 18],
	charger = [5, 27, 28, 29, 31, 32, 33, 34, 35, 39, 40, 41, 42],
	tank = [28, 29, 30, 31, 49, 50, 51, 73, 74, 75, 76, 77],
	nick = [626, 625, 624, 623, 622, 621, 661, 662, 664, 665, 666, 667, 668, 670, 671, 672, 673, 674, 620, 680],
	rochelle = [674, 678, 679, 630, 631, 632, 633, 634, 668, 677, 681, 680, 676, 675, 673, 672, 671, 670, 687, 629],
	croch = [656, 622, 623, 624, 625, 626, 663, 662, 661, 660, 659, 658, 657, 654, 653, 652, 651, 621, 620, 669],
	ellis = [625, 675, 626, 627, 628, 629, 630, 631, 678, 677, 676, 575, 674, 673, 672, 671, 670, 669, 668, 667, 666, 665, 684],
	bill = [528, 759, 763, 764, 529, 530, 531, 532, 533, 534, 753, 676, 675, 761, 758, 757, 756, 755, 754, 527, 772, 762],
	zoey = [537, 819, 823, 824, 538, 539, 540, 541, 542, 543, 813, 828, 825, 822, 821, 820, 818, 817, 816, 815, 814, 536, 809],
	francis = [532, 533, 534, 535, 536, 537, 769, 768, 767, 766, 765, 764, 763, 762, 761, 760, 759, 758, 757, 756, 531, 530, 775],
	louis = [529, 530, 531, 532, 533, 534, 766, 765, 764, 763, 762, 761, 760, 759, 758, 757, 756, 755, 754, 753, 527, 772, 528],
	adawong = [674, 678, 679, 630, 631, 632, 633, 634, 668, 677, 681, 680, 676, 675, 673, 672, 671, 670, 687, 629],
	
	function IsPlayerThirdPerson(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead())
			return false;
		
		if(player.GetNetPropFloat("m_TimeForceExternalView") > Time() ||
			player.GetNetPropInt("m_iObserverMode") == 1 ||
			player.IsPummelVictim() || player.IsCarryVictim() || player.IsPounceVictim() ||
			player.IsBeingJockeyed() || player.IsHangingFromLedge() ||
			player.GetNetPropEntity("m_reviveTarget") != null ||
			player.GetNetPropFloat("m_staggerTimer") > -1.0)
			return true;
		
		local useAction = player.GetNetPropInt("m_iCurrentUseAction");
		switch(useAction)
		{
			case 1:
				local target = player.GetNetPropEntity("m_useActionTarget");
				local owner = player.GetNetPropInt("m_useActionOwner");
				if(target != null && owner != null && target.IsEntityValid() && owner.IsEntityValid())
				{
					if(target.GetIndex() == owner.GetIndex() || target.GetIndex() != player.GetIndex())
						return true;
				}
				break;
			case 4:
			case 6:
			case 7:
			case 8:
			case 9:
				return true;
		}
		
		local sequence = player.GetNetPropInt("m_nSequence");
		local zombie = player.GetType();
		switch(zombie)
		{
			case Z_SMOKER:
			{
				if(::ShotgunSoundFix.smoker.find(sequence) != null)
					return true;
				break;
			}
			case Z_BOOMER:
			{
				if(::ShotgunSoundFix.boomer.find(sequence) != null)
					return true;
				break;
			}
			case Z_HUNTER:
			{
				if(::ShotgunSoundFix.hunter.find(sequence) != null)
					return true;
				break;
			}
			case Z_SPITTER:
			{
				if(::ShotgunSoundFix.spitter.find(sequence) != null)
					return true;
				break;
			}
			case Z_JOCKEY:
			{
				if(::ShotgunSoundFix.jockey.find(sequence) != null)
					return true;
				break;
			}
			case Z_CHARGER:
			{
				if(::ShotgunSoundFix.charger.find(sequence) != null)
					return true;
				break;
			}
			case Z_TANK:
			{
				if(::ShotgunSoundFix.tank.find(sequence) != null)
					return true;
				break;
			}
			case Z_SURVIVOR:
			{
				local character = player.GetSurvivorCharacter();
				switch(character)
				{
					case 0:
					{
						if(::ShotgunSoundFix.nick.find(sequence) != null)
							return true;
						break;
					}
					case 1:
					{
						if(::ShotgunSoundFix.rochelle.find(sequence) != null)
							return true;
						break;
					}
					case 2:
					{
						if(::ShotgunSoundFix.croch.find(sequence) != null)
							return true;
						break;
					}
					case 3:
					{
						if(::ShotgunSoundFix.ellis.find(sequence) != null)
							return true;
						break;
					}
					case 4:
					{
						if(::ShotgunSoundFix.bill.find(sequence) != null)
							return true;
						break;
					}
					case 5:
					{
						if(::ShotgunSoundFix.zoey.find(sequence) != null)
							return true;
						break;
					}
					case 6:
					{
						if(::ShotgunSoundFix.francis.find(sequence) != null)
							return true;
						break;
					}
					case 7:
					{
						if(::ShotgunSoundFix.louis.find(sequence) != null)
							return true;
						break;
					}
					case 8:
					{
						if(::ShotgunSoundFix.adawong.find(sequence) != null)
							return true;
						break;
					}
				}
				break;
			}
		}
		
		return false;
	}
};

function Notifications::OnWeaponFire::ShotgunSndFix_SoundPlayer(player, classname, params)
{
	if(!::ShotgunSoundFix.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayerEntityValid() || player.IsDead() || player.IsBot())
		return;
	
	local index = player.GetIndex();
	if(!::ShotgunSoundFix.IsPlayerThirdPerson(player) && !(index in ::ShotgunSoundFix.EnableShotGunSound))
		return;
	
	/*
	if(player.GetClientConvarValue("c_thirdpersonshoulder").tointeger() == 0)
		return;
	*/
	
	local weapon = player.GetActiveWeapon();
	if(weapon == null || !weapon.IsEntityValid() || weapon.GetClassname() != classname)
		return;
	
	local hasUpgradeAmmo = ((weapon.GetNetPropInt("m_upgradeBitVec") & 3) != 0 &&
		weapon.GetNetPropInt("m_nUpgradedPrimaryAmmoLoaded") > 0);
	
	switch(classname)
	{
		case "weapon_autoshotgun":
			// player.PlaySound("weapons/auto_shotgun/gunfire/auto_shotgun_fire_1.wav");
			
			if(hasUpgradeAmmo)
				player.PlaySound("AutoShotgun.FireIncendiary");
			else
				player.PlaySound("AutoShotgun.Fire");
			
			break;
		case "weapon_shotgun_spas":
			// player.PlaySound("weapons/auto_shotgun_spas/gunfire/shotgun_fire_1.wav");
			
			if(hasUpgradeAmmo)
				player.PlaySound("AutoShotgun_Spas.FireIncendiary");
			else
				player.PlaySound("AutoShotgun_Spas.Fire");
			
			break;
		case "weapon_pumpshotgun":
			// player.PlaySound("weapons/shotgun/gunfire/shotgun_fire_1.wav");
			
			if(hasUpgradeAmmo)
				player.PlaySound("Shotgun.FireIncendiary");
			else
				player.PlaySound("Shotgun.Fire");
			
			break;
		case "weapon_shotgun_chrome":
			// player.PlaySound("weapons/shotgun_chrome/gunfire/shotgun_fire_1.wav");
			
			if(hasUpgradeAmmo)
				player.PlaySound("Shotgun_Chrome.FireIncendiary");
			else
				player.PlaySound("Shotgun_Chrome.Fire");
			
			break;
	}
}

function CommandTriggersEx::ss(player, args, text)
{
	if( player == null || !player.IsValid() || player.IsBot() )
		return;
	
	local index = player.GetIndex();
	if(index in ::ShotgunSoundFix.EnableShotGunSound)
	{
		delete ::ShotgunSoundFix.EnableShotGunSound[index];
		player.ShowHint("shotgun sound off");
	}
	else
	{
		::ShotgunSoundFix.EnableShotGunSound[index] <- true;
		player.ShowHint("shotgun sound on");
	}
}

::ShotgunSoundFix.PLUGIN_NAME <- PLUGIN_NAME;
::ShotgunSoundFix.ConfigVar = ::ShotgunSoundFix.ConfigVarDef;

function Notifications::OnRoundStart::ShotgunSoundFix_LoadConfig()
{
	RestoreTable(::ShotgunSoundFix.PLUGIN_NAME, ::ShotgunSoundFix.ConfigVar);
	if(::ShotgunSoundFix.ConfigVar == null || ::ShotgunSoundFix.ConfigVar.len() <= 0)
		::ShotgunSoundFix.ConfigVar = FileIO.GetConfigOfFile(::ShotgunSoundFix.PLUGIN_NAME, ::ShotgunSoundFix.ConfigVarDef);

	// printl("[plugins] " + ::ShotgunSoundFix.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::ShotgunSoundFix_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::ShotgunSoundFix.PLUGIN_NAME, ::ShotgunSoundFix.ConfigVar);

	// printl("[plugins] " + ::ShotgunSoundFix.PLUGIN_NAME + " saving...");
}
