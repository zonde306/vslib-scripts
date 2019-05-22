
::ASMCC_GIVE <- 0;
::ASMCC_KILL <- 1;
::ASMCC_KICK <- 2;
::ASMCC_SPAWN <- 3;
::ASMCC_REVIVE <- 4;
::ASMCC_UPGRADE <- 5;

::AdminSystemMenu <-
{
	DefinedCommand =
	[
		// ::ASMCC_GIVE
		[
			"smg",
			"smg_silenced",
			"smg_mp5",
			"pumpshotgun",
			"shotgun_chrome",
			
			
		],
	];
	
	CurrentCommand = "",
	CurretnParams = "",
	CurrentTarget = [],
	
	CC_GIVE = 1,
	
	function SetCommand(command, params)
	{
		
	},
	
	function SetTarget(target)
	{
		
	},
	
	
};