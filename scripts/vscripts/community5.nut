//-----------------------------------------------------
Msg("死亡之门\n");
Msg("Made by Rayman1103\n");


DirectorOptions <-
{
	ActiveChallenge = 1

	cm_ShouldHurry = 1
	cm_AllowPillConversion = 0
	cm_AllowSurvivorRescue = 1
	SurvivorMaxIncapacitatedCount = 0

	weaponsToConvert =
	{
		weapon_first_aid_kit =	"weapon_pain_pills_spawn",
		// weapon_adrenaline =	"weapon_pain_pills_spawn",
	}

	function ConvertWeaponSpawn( classname )
	{
		if ( classname in weaponsToConvert )
		{
			return weaponsToConvert[classname];
		}
		return 0;
	}

	DefaultItems =
	[
		"weapon_pistol",
		"weapon_pistol",
	]

	function GetDefaultItem( idx )
	{
		if ( idx < DefaultItems.len() )
		{
			return DefaultItems[idx];
		}
		return 0;
	}

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
	if(DirectorOptions.TempHealthDecayRate <= 0.01)
		DirectorOptions.RecalculateHealthDecay();
}
