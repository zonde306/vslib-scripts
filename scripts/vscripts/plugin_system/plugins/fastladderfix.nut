::FastLadderFix <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
		
		// 思考间隔
		ThinkInterval = 0.1
	},
	
	ConfigVar = {},
	
	LastOnLadder = {},
	
	function Timer_CheckFastClimb(params)
	{
		if(!::FastLadderFix.ConfigVar.Enable)
			return;
		
		foreach(player in Players.Humans())
		{
			local index = player.GetIndex();
			if(!player.IsAlive())
			{
				if(index in ::FastLadderFix.LastOnLadder)
				{
					delete ::FastLadderFix.LastOnLadder[index];
					player.EnableButton(BUTTON_MOVELEFT);
					player.EnableButton(BUTTON_MOVERIGHT);
					// printl("player " + player.GetName() + " enable button with death");
				}
				continue;
			}
			
			if(player.GetMoveType() == MOVETYPE_LADDER)
			{
				local button = player.GetPressedButtons();
				if((button & BUTTON_FORWARD) || (button & BUTTON_BACK))
				{
					if(button & BUTTON_MOVELEFT)
					{
						player.DisableButton(BUTTON_MOVELEFT);
						// printl("player " + player.GetName() + " try fast climb, disable BUTTON_MOVELEFT");
						
						if(!(index in ::FastLadderFix.LastOnLadder))
							::FastLadderFix.LastOnLadder[index] <- true;
					}
					
					if(button & BUTTON_MOVERIGHT)
					{
						player.DisableButton(BUTTON_MOVERIGHT);
						// printl("player " + player.GetName() + " try fast climb, disable BUTTON_MOVERIGHT");
						
						if(!(index in ::FastLadderFix.LastOnLadder))
							::FastLadderFix.LastOnLadder[index] <- true;
					}
				}
				else if(index in ::FastLadderFix.LastOnLadder)
				{
					delete ::FastLadderFix.LastOnLadder[index];
					player.EnableButton(BUTTON_MOVELEFT);
					player.EnableButton(BUTTON_MOVERIGHT);
					// printl("player " + player.GetName() + " enable button with stopped");
				}
			}
			else if(index in ::FastLadderFix.LastOnLadder)
			{
				delete ::FastLadderFix.LastOnLadder[index];
				player.EnableButton(BUTTON_MOVELEFT);
				player.EnableButton(BUTTON_MOVERIGHT);
				// printl("player " + player.GetName() + " enable button with left");
			}
		}
	}
};

function Notifications::OnRoundBegin::FastLadderFix(params)
{
	Timers.AddTimerByName("timer_fastladderfix", ::FastLadderFix.ConfigVar.ThinkInterval, true,
		::FastLadderFix.Timer_CheckFastClimb);
}

function Notifications::FirstSurvLeftStartArea::FastLadderFix(player, params)
{
	Timers.AddTimerByName("timer_fastladderfix", ::FastLadderFix.ConfigVar.ThinkInterval, true,
		::FastLadderFix.Timer_CheckFastClimb);
}

::FastLadderFix.PLUGIN_NAME <- PLUGIN_NAME;
::FastLadderFix.ConfigVar = ::FastLadderFix.ConfigVarDef;

function Notifications::OnRoundStart::FastLadderFix_LoadConfig()
{
	RestoreTable(::FastLadderFix.PLUGIN_NAME, ::FastLadderFix.ConfigVar);
	if(::FastLadderFix.ConfigVar == null || ::FastLadderFix.ConfigVar.len() <= 0)
		::FastLadderFix.ConfigVar = FileIO.GetConfigOfFile(::FastLadderFix.PLUGIN_NAME, ::FastLadderFix.ConfigVarDef);

	// printl("[plugins] " + ::FastLadderFix.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::FastLadderFix_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::FastLadderFix.PLUGIN_NAME, ::FastLadderFix.ConfigVar);

	// printl("[plugins] " + ::FastLadderFix.PLUGIN_NAME + " saving...");
}
