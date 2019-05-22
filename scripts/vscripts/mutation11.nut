//-----------------------------------------------------
Msg("Activating Mutation 11\n");

DirectorOptions <-
{
	ActiveChallenge = 1

	/*
	weaponsToRemove =
	{
		weapon_first_aid_kit = 0
		weapon_pain_pills = 0
		weapon_adrenaline = 0
		weapon_defibrillator = 0
	}

	function AllowWeaponSpawn( classname )
	{
		if ( classname in weaponsToRemove )
		{
			return false;
		}
		return true;
	}
	*/
	
	weaponsToConvert =
	{
		weapon_first_aid_kit =	"weapon_pain_pills_spawn",
		weapon_defibrillator =	"weapon_adrenaline",
	}

	function ConvertWeaponSpawn( classname )
	{
		if ( classname in weaponsToConvert )
		{
			return weaponsToConvert[classname];
		}
		return 0;
	}
}
