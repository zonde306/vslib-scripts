//-----------------------------------------------------
Msg("Activating Mutation 4\n");
SendToServerConsole("abm_unlocksi 0");
SendToServerConsole("abm_autohard 0");

DirectorOptions <-
{
	ActiveChallenge = 1

	cm_SpecialRespawnInterval = 15
	cm_MaxSpecials = 8
	cm_BaseSpecialLimit = 2

	DominatorLimit = 8
}
