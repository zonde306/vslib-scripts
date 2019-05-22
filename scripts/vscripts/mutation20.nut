//-----------------------------------------------------
Msg("Activating Mutation 20\n");


DirectorOptions <-
{
	ActiveChallenge = 1

	/*
	weaponsToRemove =
	{
		weapon_first_aid_kit = 0
		weapon_pain_pills = 0
		weapon_adrenaline = 0
	}

	function AllowWeaponSpawn( classname )
	{
		if ( classname in weaponsToRemove )
		{
			return false;
		}
		return true;
	}*/
	
	weaponsToConvert =
	{
		weapon_first_aid_kit =	"weapon_pain_pills_spawn",
		// weapon_defibrillator =	"weapon_adrenaline",
	}

	function ConvertWeaponSpawn( classname )
	{
		if ( classname in weaponsToConvert )
		{
			return weaponsToConvert[classname];
		}
		return 0;
	}

	// Challenge vars
	cm_TempHealthOnly = 1
	cm_AllowPillConversion = 0
	cm_HealingGnome = 1
	
	TempHealthDecayRate = 0.001
	function RecalculateHealthDecay()
	{
		if ( Director.HasAnySurvivorLeftSafeArea() )
		{
			TempHealthDecayRate = 0.27 // pain_pills_decay_rate default
		}
	}
}

function Update()
{
	DirectorOptions.RecalculateHealthDecay();
}
