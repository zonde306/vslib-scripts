//-----------------------------------------------------
Msg("Activating Mutation 16\n");
SendToServerConsole("abm_unlocksi 0");
SendToServerConsole("abm_autohard 0");

DirectorOptions <-
{
	ActiveChallenge = 1

	cm_SpecialSlotCountdownTime = 15
	cm_SpecialRespawnInterval = 1
	cm_MaxSpecials = 4

	HunterLimit = 4
	BoomerLimit = 0
	SmokerLimit = 0
	SpitterLimit = 0
	ChargerLimit = 0
	JockeyLimit = 0
	
	DominatorLimit = 4
}
