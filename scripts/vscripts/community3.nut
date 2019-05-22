Msg("骑乘派对\n");
SendToServerConsole("abm_unlocksi 0");
SendToServerConsole("abm_autohard 0");

DirectorOptions <-
{
	ActiveChallenge = 1
	
	cm_CommonLimit = 0
	
	BoomerLimit = 0
	ChargerLimit = 0
	HunterLimit = 0
	JockeyLimit = 4
	SmokerLimit = 0
	SpitterLimit = 0
	cm_MaxSpecials = 4
	
	cm_SpecialRespawnInterval = 1
	cm_SpecialSlotCountdownTime = 5
	
	function ConvertZombieClass(id)
	{
		return 5;
	}
}