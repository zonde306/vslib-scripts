::BunnyHop <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
		
		DoubleJump = {},
		AutoBunnyHop = {}
	},

	ConfigVar = {},

	JumpFlags = {},
	PlayerJumping = {},
	JF_None = 0,
	JF_Jumping = 1,
	JF_FirstJump = 2,
	JF_LastReleased = 4,
	JF_CanDoubleJump = 8,
	JF_CanBunnyHop = 16,
	
	function IsValidPlayer(player)
	{
		if(player == null || !("IsPlayerEntityValid" in player) || !player.IsPlayerEntityValid() ||
			player.GetTeam() <= SPECTATORS)
			return false;
		
		if(player.IsSurvivor())
		{
			if(player.IsDead())
				return false;
		}
		else
		{
			if(player.IsDead() && !player.IsGhost())
				return false;
		}
		
		return true;
	},
	
	function IsPlayerGround(player)
	{
		if(!::BunnyHop.IsValidPlayer(player))
			return false;
		
		return (player.GetNetPropEntity("m_hGroundEntity") != null);
	},
	
	function IsNeedHelp(player)
	{
		if(!::BunnyHop.IsValidPlayer(player))
			return false;
		
		if(player.IsIncapacitated() || player.IsHangingFromLedge() || player.IsHangingFromTongue() ||
			player.IsBeingJockeyed() || player.IsPounceVictim() || player.IsTongueVictim() ||
			player.IsCarryVictim() || player.IsPummelVictim())
			return true;
		
		return false;
	},
	
	function CanBunnyHop(player)
	{
		if(!::BunnyHop.IsValidPlayer(player) || ::BunnyHop.IsNeedHelp(player) || !::BunnyHop.IsPlayerGround(player))
			return false;
		
		if(typeof(::BunnyHop.ConfigVar.AutoBunnyHop) == "table")
		{
			local idx = player.GetIndex();
			foreach(index, allowed in ::BunnyHop.ConfigVar.AutoBunnyHop)
			{
				if(allowed && index == idx)
					return true;
			}
		}
		else if(::BunnyHop.ConfigVar.AutoBunnyHop == true || ::BunnyHop.ConfigVar.AutoBunnyHop == 1)
			return true;
		
		return false;
	},
	
	function CanDoubleJump(player)
	{
		if(!::BunnyHop.IsValidPlayer(player) || ::BunnyHop.IsNeedHelp(player) || ::BunnyHop.IsPlayerGround(player))
			return false;
		
		local idx = player.GetIndex();
		if(typeof(::BunnyHop.ConfigVar.DoubleJump) == "table")
		{
			foreach(index, allowed in ::BunnyHop.ConfigVar.DoubleJump)
			{
				if(index == idx && allowed > 0 && (!(idx in ::BunnyHop.PlayerJumping) ||
					allowed > ::BunnyHop.PlayerJumping[idx]))
					return true;
			}
		}
		else if(::BunnyHop.ConfigVar.DoubleJump > 0)
		{
			if(!(idx in ::BunnyHop.PlayerJumping) || ::BunnyHop.ConfigVar.DoubleJump > ::BunnyHop.PlayerJumping[idx])
				return true;
		}
		
		return false;
	},
	
	function ForceJump(player, vel = 275.0)
	{
		local velocity = player.GetVelocity();
		
		// 向上速度
		velocity.z = vel;
		
		// 修复摩擦力 bug 无法起跳的问题
		player.SetNetPropEntity("m_hGroundEntity", null);
		player.SetVelocity(velocity);
	},
	
	function Timer_CheckPlayerJump(params)
	{
		if(!::BunnyHop.ConfigVar.Enable)
			return;
		
		local index = 0;
		local buttons = 0;
		foreach(player in Players.AliveSurvivors())
		{
			if(::BunnyHop.IsNeedHelp(player))
				continue;
			
			index = player.GetIndex();
			if(!(index in ::BunnyHop.JumpFlags))
				continue;
			
			buttons = player.GetPressedButtons();
			if(buttons & BUTTON_JUMP)
			{
				// 双重跳
				if(::BunnyHop.CanDoubleJump(player) && (::BunnyHop.JumpFlags[index] & ::BunnyHop.JF_CanDoubleJump))
				{
					// 恢复到允许连跳状态
					::BunnyHop.JumpFlags[index] = (::BunnyHop.JumpFlags[index] | ::BunnyHop.JF_CanBunnyHop);
					::BunnyHop.JumpFlags[index] = (::BunnyHop.JumpFlags[index] & ~(::BunnyHop.JF_CanDoubleJump | ::BunnyHop.JF_LastReleased));
					
					if(index in ::BunnyHop.PlayerJumping)
						::BunnyHop.PlayerJumping[index] += 1;
					else
						::BunnyHop.PlayerJumping[index] <- 1;
					
					// player.ShowHint("jumping x" + ::BunnyHop.PlayerJumping[index] + ": " + ::BunnyHop.JumpFlags[index]);
					
					// 进行双重跳
					::BunnyHop.ForceJump(player);
				}
				
				// 连跳
				if(::BunnyHop.CanBunnyHop(player) && (::BunnyHop.JumpFlags[index] & ::BunnyHop.JF_CanBunnyHop))
				{
					// 或者 player.IsOnGround() 也行，但是准度不够高，可能会在空中也触发
					/*
					if(player.GetNetPropEntity("m_hGroundEntity") != null)
						player.SetNetPropFloat("m_jumpSupressedUntil", Time() + 0.15);
					else
						player.SetNetPropFloat("m_jumpSupressedUntil", Time());
					*/
					
					if(player.GetMoveType() == MOVETYPE_LADDER || (buttons & (BUTTON_USE|BUTTON_WALK)) ||
						player.GetNetPropInt("m_nWaterLevel") > 1)
					{
						// 玩家现在 不能/放弃 继续连跳
						::BunnyHop.JumpFlags[index] = (::BunnyHop.JumpFlags[index] & ~(::BunnyHop.JF_CanBunnyHop | ::BunnyHop.JF_CanDoubleJump));
					}
					else if(::BunnyHop.IsPlayerGround(player))
					{
						// 进行连跳
						::BunnyHop.ForceJump(player);
					}
				}
			}
			else
			{
				if(!(::BunnyHop.JumpFlags[index] & ::BunnyHop.JF_LastReleased))
				{
					// 这个脚本语言不支持 |= 这种操作
					::BunnyHop.JumpFlags[index] = (::BunnyHop.JumpFlags[index] | ::BunnyHop.JF_LastReleased | ::BunnyHop.JF_CanDoubleJump);
					
					if(::BunnyHop.CanDoubleJump(player))
					{
						// 在进行双重跳时不要同时进行连跳
						::BunnyHop.JumpFlags[index] = (::BunnyHop.JumpFlags[index] & ~(::BunnyHop.JF_CanBunnyHop));
					}
					
					// player.ShowHint("released: " + ::BunnyHop.JumpFlags[index]);
				}
				
				if(player.GetNetPropEntity("m_hGroundEntity") != null)
				{
					// 玩家不想再继续跳了，还原设置
					delete ::BunnyHop.JumpFlags[index];
					
					if(index in ::BunnyHop.PlayerJumping)
						delete ::BunnyHop.PlayerJumping[index];
				}
			}
		}
	}
}

function Notifications::OnRoundBegin::BunnyHop_Active(params)
{
	Timers.AddTimerByName("timer_bunnyhop", 0.01, true, ::BunnyHop.Timer_CheckPlayerJump);
}

function Notifications::FirstSurvLeftStartArea::BunnyHop_Active(player, params)
{
	Timers.AddTimerByName("timer_bunnyhop", 0.01, true, ::BunnyHop.Timer_CheckPlayerJump);
}

function Notifications::OnJump::BunnyHop_CheckJumpStats(player, params)
{
	if(player == null || !player.IsPlayerEntityValid())
		return;
	
	// 第一次起跳(这时可能还在地面上)
	::BunnyHop.JumpFlags[player.GetIndex()] <- (::BunnyHop.JF_Jumping | ::BunnyHop.JF_FirstJump);
}

function Notifications::OnJumpApex::BunnyHop_CheckJumpStats(player, params)
{
	if(player == null || !player.IsPlayerEntityValid())
		return;
	
	local index = player.GetIndex();
	
	// 达到最高位置后刚开始落下时
	if(index in ::BunnyHop.JumpFlags)
	{
		::BunnyHop.JumpFlags[index] <- (::BunnyHop.JumpFlags[index] | ::BunnyHop.JF_CanBunnyHop);
		::BunnyHop.JumpFlags[index] <- (::BunnyHop.JumpFlags[index] & ~(::BunnyHop.JF_FirstJump));
	}
	/*
	else
	{
		// 原因可能是尝试按住空格跳楼
		::BunnyHop.JumpFlags[index] <- 0;
	}
	*/
}

function CommandTriggersEx::bhop(player, arg, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	local strTarget = GetArgument(1);
	local target = Utils.GetPlayerFromName(strTarget);
	local mode = GetArgument(2);
	
	if(strTarget != null)
	{
		if(strTarget == "all")
		{
			foreach(survivor in Players.Humans())
			{
				local index = survivor.GetIndex();
				if(mode == null || mode == "")
				{
					if(index in ::BunnyHop.ConfigVar.AutoBunnyHop)
						delete ::BunnyHop.ConfigVar.AutoBunnyHop[index];
					else
						::BunnyHop.ConfigVar.AutoBunnyHop[index] <- true;
				}
				else if(mode == "on" || mode == "enable" || mode == "active")
				{
					::BunnyHop.ConfigVar.AutoBunnyHop[index] <- true;
				}
				else if(mode == "off" || mode == "disabled" || mode == "stop" || mode == "remove")
				{
					if(index in ::BunnyHop.ConfigVar.AutoBunnyHop)
						delete ::BunnyHop.ConfigVar.AutoBunnyHop[index];
				}
			}
		}
		else if(strTarget == "survivor")
		{
			foreach(survivor in Players.Survivors())
			{
				if(survivor.IsBot())
					continue;
				
				local index = survivor.GetIndex();
				if(mode == null || mode == "")
				{
					if(index in ::BunnyHop.ConfigVar.AutoBunnyHop)
						delete ::BunnyHop.ConfigVar.AutoBunnyHop[index];
					else
						::BunnyHop.ConfigVar.AutoBunnyHop[index] <- true;
				}
				else if(mode == "on" || mode == "enable" || mode == "active")
				{
					::BunnyHop.ConfigVar.AutoBunnyHop[index] <- true;
				}
				else if(mode == "off" || mode == "disabled" || mode == "stop" || mode == "remove")
				{
					if(index in ::BunnyHop.ConfigVar.AutoBunnyHop)
						delete ::BunnyHop.ConfigVar.AutoBunnyHop[index];
				}
			}
		}
		else if(strTarget == "infected")
		{
			foreach(survivor in Players.Infected())
			{
				if(survivor.IsBot())
					continue;
				
				local index = survivor.GetIndex();
				if(mode == null || mode == "")
				{
					if(index in ::BunnyHop.ConfigVar.AutoBunnyHop)
						delete ::BunnyHop.ConfigVar.AutoBunnyHop[index];
					else
						::BunnyHop.ConfigVar.AutoBunnyHop[index] <- true;
				}
				else if(mode == "on" || mode == "enable" || mode == "active")
				{
					::BunnyHop.ConfigVar.AutoBunnyHop[index] <- true;
				}
				else if(mode == "off" || mode == "disabled" || mode == "stop" || mode == "remove")
				{
					if(index in ::BunnyHop.ConfigVar.AutoBunnyHop)
						delete ::BunnyHop.ConfigVar.AutoBunnyHop[index];
				}
			}
		}
		else
		{
			if(strTarget == "!picker")
				target = player.GetLookingEntity();
			else if(target == null)
			{
				target = player;
				mode = strTarget;
			}
			
			if(!::BunnyHop.IsValidPlayer(target))
				return;
			
			local index = target.GetIndex();
			if(mode == null || mode == "")
			{
				if(index in ::BunnyHop.ConfigVar.AutoBunnyHop)
					delete ::BunnyHop.ConfigVar.AutoBunnyHop[index];
				else
					::BunnyHop.ConfigVar.AutoBunnyHop[index] <- true;
			}
			else if(mode == "on" || mode == "enable" || mode == "active")
			{
				::BunnyHop.ConfigVar.AutoBunnyHop[index] <- true;
			}
			else if(mode == "off" || mode == "disabled" || mode == "stop" || mode == "remove")
			{
				if(index in ::BunnyHop.ConfigVar.AutoBunnyHop)
					delete ::BunnyHop.ConfigVar.AutoBunnyHop[index];
			}
		}
	}
	else
	{
		local index = player.GetIndex();
		if(index in ::BunnyHop.ConfigVar.AutoBunnyHop)
			delete ::BunnyHop.ConfigVar.AutoBunnyHop[index];
		else
			::BunnyHop.ConfigVar.AutoBunnyHop[index] <- true;
	}
}

function CommandTriggersEx::double(player, arg, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	local strTarget = GetArgument(1);
	local target = Utils.GetPlayerFromName(strTarget);
	local mode = GetArgument(2);
	
	if(strTarget != null)
	{
		if(strTarget == "all")
		{
			foreach(survivor in Players.Humans())
			{
				local index = survivor.GetIndex();
				if(mode == null || mode == "")
				{
					if(index in ::BunnyHop.ConfigVar.DoubleJump)
						delete ::BunnyHop.ConfigVar.DoubleJump[index];
					else
						::BunnyHop.ConfigVar.DoubleJump[index] <- 1;
				}
				else if(mode == "on" || mode == "enable" || mode == "active")
				{
					::BunnyHop.ConfigVar.DoubleJump[index] <- 1;
				}
				else if(mode == "off" || mode == "disabled" || mode == "stop" || mode == "remove")
				{
					if(index in ::BunnyHop.ConfigVar.DoubleJump)
						delete ::BunnyHop.ConfigVar.DoubleJump[index];
				}
				else
				{
					local number = mode.tointeger();
					if(number > 0)
						::BunnyHop.ConfigVar.DoubleJump[index] <- number;
					else if(index in ::BunnyHop.ConfigVar.DoubleJump)
						delete ::BunnyHop.ConfigVar.DoubleJump[index];
				}
			}
		}
		else if(strTarget == "survivor")
		{
			foreach(survivor in Players.Survivors())
			{
				if(survivor.IsBot())
					continue;
				
				local index = survivor.GetIndex();
				if(mode == null || mode == "")
				{
					if(index in ::BunnyHop.ConfigVar.DoubleJump)
						delete ::BunnyHop.ConfigVar.DoubleJump[index];
					else
						::BunnyHop.ConfigVar.DoubleJump[index] <- 1;
				}
				else if(mode == "on" || mode == "enable" || mode == "active")
				{
					::BunnyHop.ConfigVar.DoubleJump[index] <- 1;
				}
				else if(mode == "off" || mode == "disabled" || mode == "stop" || mode == "remove")
				{
					if(index in ::BunnyHop.ConfigVar.DoubleJump)
						delete ::BunnyHop.ConfigVar.DoubleJump[index];
				}
				else
				{
					local number = mode.tointeger();
					if(number > 0)
						::BunnyHop.ConfigVar.DoubleJump[index] <- number;
					else if(index in ::BunnyHop.ConfigVar.DoubleJump)
						delete ::BunnyHop.ConfigVar.DoubleJump[index];
				}
			}
		}
		else if(strTarget == "infected")
		{
			foreach(survivor in Players.Infected())
			{
				if(survivor.IsBot())
					continue;
				
				local index = survivor.GetIndex();
				if(mode == null || mode == "")
				{
					if(index in ::BunnyHop.ConfigVar.DoubleJump)
						delete ::BunnyHop.ConfigVar.DoubleJump[index];
					else
						::BunnyHop.ConfigVar.DoubleJump[index] <- 1;
				}
				else if(mode == "on" || mode == "enable" || mode == "active")
				{
					::BunnyHop.ConfigVar.DoubleJump[index] <- 1;
				}
				else if(mode == "off" || mode == "disabled" || mode == "stop" || mode == "remove")
				{
					if(index in ::BunnyHop.ConfigVar.DoubleJump)
						delete ::BunnyHop.ConfigVar.DoubleJump[index];
				}
				else
				{
					local number = mode.tointeger();
					if(number > 0)
						::BunnyHop.ConfigVar.DoubleJump[index] <- number;
					else if(index in ::BunnyHop.ConfigVar.DoubleJump)
						delete ::BunnyHop.ConfigVar.DoubleJump[index];
				}
			}
		}
		else
		{
			if(strTarget == "!picker")
				target = player.GetLookingEntity();
			else if(target == null)
				target = player;
			
			if(mode == null)
				mode = strTarget;
			
			if(!::BunnyHop.IsValidPlayer(target))
				return;
			
			local index = target.GetIndex();
			if(mode == null || mode == "")
			{
				if(index in ::BunnyHop.ConfigVar.DoubleJump)
					delete ::BunnyHop.ConfigVar.DoubleJump[index];
				else
					::BunnyHop.ConfigVar.DoubleJump[index] <- 1;
			}
			else if(mode == "on" || mode == "enable" || mode == "active")
			{
				::BunnyHop.ConfigVar.DoubleJump[index] <- 1;
			}
			else if(mode == "off" || mode == "disabled" || mode == "stop" || mode == "remove")
			{
				if(index in ::BunnyHop.ConfigVar.DoubleJump)
					delete ::BunnyHop.ConfigVar.DoubleJump[index];
			}
			else
			{
				local number = mode.tointeger();
				if(number > 0)
					::BunnyHop.ConfigVar.DoubleJump[index] <- number;
				else if(index in ::BunnyHop.ConfigVar.DoubleJump)
					delete ::BunnyHop.ConfigVar.DoubleJump[index];
			}
			
			// player.ShowHint("mode is " + mode + ", strTarget is " + strTarget);
		}
	}
	else
	{
		local index = player.GetIndex();
		if(index in ::BunnyHop.ConfigVar.DoubleJump)
			delete ::BunnyHop.ConfigVar.DoubleJump[index];
		else
			::BunnyHop.ConfigVar.DoubleJump[index] <- 1;
	}
}


::BunnyHop.PLUGIN_NAME <- PLUGIN_NAME;
::BunnyHop.ConfigVar = ::BunnyHop.ConfigVarDef;

function Notifications::OnRoundStart::BunnyHop_LoadConfig()
{
	RestoreTable(::BunnyHop.PLUGIN_NAME, ::BunnyHop.ConfigVar);
	if(::BunnyHop.ConfigVar == null || ::BunnyHop.ConfigVar.len() <= 0)
		::BunnyHop.ConfigVar = FileIO.GetConfigOfFile(::BunnyHop.PLUGIN_NAME, ::BunnyHop.ConfigVarDef);

	// printl("[plugins] " + ::BunnyHop.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::BunnyHop_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::BunnyHop.PLUGIN_NAME, ::BunnyHop.ConfigVar);

	// printl("[plugins] " + ::BunnyHop.PLUGIN_NAME + " saving...");
}
