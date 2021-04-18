//-----------------------------------------------------
Msg("Activating Realism\n");

DirectorOptions <- {
	weaponsToConvert = {
		weapon_first_aid_kit =	"weapon_pain_pills_spawn"
		weapon_autoshotgun	  = "weapon_pumpshotgun_spawn"
		weapon_shotgun_spas	 = "weapon_shotgun_chrome_spawn"
		weapon_rifle			= "weapon_smg_spawn"
		weapon_rifle_desert	 = "weapon_smg_spawn"
		weapon_rifle_sg552	  = "weapon_smg_mp5_spawn"
		weapon_rifle_ak47	   = "weapon_smg_silenced_spawn"
		weapon_hunting_rifle	= "weapon_smg_silenced_spawn"
		weapon_sniper_military  = "weapon_shotgun_chrome_spawn"
		weapon_sniper_awp	   = "weapon_shotgun_chrome_spawn"
		// weapon_sniper_scout	 = "weapon_pumpshotgun_spawn"
	}
	
	weaponsToRemove = {
		weapon_grenade_launcher = false
		weapon_chainsaw = false
		weapon_rifle_m60 = false
	}
	
	function ConvertWeaponSpawn( classname )
	{
		if ( classname in weaponsToConvert )
		{
			return weaponsToConvert[classname];
		}
		return 0;
	}
	
	function AllowWeaponSpawn( classname )
	{
		if ( classname in weaponsToRemove )
		{
			return weaponsToRemove[classname];
		}
		return true;
	}	
}

Convars.SetValue("z_tank_health", "8000")
