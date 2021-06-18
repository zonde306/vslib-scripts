::ConnectHint <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,
		
		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
		
		// 是否开启连接提示
		Connected = true,
		
		// 是否开启断开连接提示
		Disconnected = true,
		
		// 是否开启队伍切换提示
		ChangeTeam = true,
		
		// 提示方式.1=聊天框.2=屏幕说明.4=控制台.8=只限于管理员
		HintMode = 14,
		
		// 连接服务器超过多少秒还没有成功就踢出
		ConnectTimeout = 180
	},

	ConfigVar = {},
	
	function Timer_KickConnectTimeout(playerInfo)
	{
		foreach(player in Players.Humans())
		{
			if(player.GetSteamID() != playerInfo.SteamID)
				continue;
			
			if(player.GetTeam() > 0)
				return;
			
			break;
		}
		
		printl("player " + playerInfo.Name + " kicked with Connection timed out.");
		SendToServerConsole("kickid \"" + playerInfo.SteamID + "\" \"Connection timed out\"");
	}
};

function Notifications::OnPlayerJoined::ConnectHintConnect(player, name, ip, steamId, params)
{
	if(!::ConnectHint.ConfigVar.Enable || !::ConnectHint.ConfigVar.Connected || "retry" in params)
		return;
	
	if(steamId == "" || steamId == null || steamId == "BOT" || ("bot" in params) && params["bot"])
		return;
	
	// ip 默认会带上断开号的，在这里去除端口号
	if(ip.find(":") != null)
		ip = ip.slice(0, ip.find(":"));
	
	// 专用服务器名字有时会无法获取
	if(name == null && player != null && player.IsValid())
		name = player.GetName();
	
	if(::ConnectHint.ConfigVar.HintMode & 1)
		Utils.SayToAll("player %s (%s) connect... ip:%s", name, steamId, ip);
	if(::ConnectHint.ConfigVar.HintMode & 2)
	{
		if(::ConnectHint.ConfigVar.HintMode & 8)
		{
			foreach(player in Players.Humans())
			{
				if(::AdminSystem.IsAdmin(player, false))
					player.PrintToChat("player " + name + " (" + steamId + ") connect... ip: " + ip);
			}
		}
		else
		{
			// 虽然这个有点卡
			Utils.PrintToChatAll("player " + name + " (" + steamId + ") connect... ip: " + ip);
		}
	}
	
	if(::ConnectHint.ConfigVar.HintMode & 4)
		printl("player " + name + " (" + steamId + ") connect... ip: " + ip);
	
	Timers.AddTimerOne("timer_kick_connect_stuck_" + steamId, ::ConnectHint.ConfigVar.ConnectTimeout,
		::ConnectHint.Timer_KickConnectTimeout, {SteamID = steamId, Name = name});
	
	Utils.PlaySoundToAllEx("buttons/bell1.wav");
}

function Notifications::OnTeamChanged::ConnectHintShowInfo(player, oldTeam, newTeam, params)
{
	if(!::ConnectHint.ConfigVar.Enable || !::ConnectHint.ConfigVar.ChangeTeam)
		return;
	
	if("isbot" in params && params["isbot"] || "disconnect" in params && params["disconnect"] ||
		player == null || !player.IsPlayer() || player.IsBot())
		return;
	
	if(newTeam != SURVIVORS && newTeam != INFECTED)
		return;
	
	local name = player.GetName();
	local language = player.GetClientConvarValue("cl_language");
	local lerp = player.GetClientConvarValue("cl_interp").tofloat() * 1000.0;
	local steamId = player.GetSteamID();
	if(steamId == null || steamId == "" || steamId == "BOT")
		return;
	
	if(::ConnectHint.ConfigVar.HintMode & 1)
		Utils.SayToAll("player %s join team %d lang %s lerp %.1f", newTeam, name, language, lerp);
	if(::ConnectHint.ConfigVar.HintMode & 2)
	{
		if(::ConnectHint.ConfigVar.HintMode & 8)
		{
			foreach(player in Players.Humans())
			{
				if(::AdminSystem.IsAdmin(player, false))
					player.PrintToChat("player " + name + " (" + language + " | " + lerp + ") join " + newTeam);
			}
		}
		else
		{
			// 虽然这个有点卡
			Utils.PrintToChatAll("player " + name + " (" + language + " | " + lerp + ") join " + newTeam);
		}
	}
	
	if(::ConnectHint.ConfigVar.HintMode & 4)
		printl("player " + name + " (" + language + " | " + lerp + ") join " + newTeam);
	
	/*
	if(player.ClientCommand("rate 10000", "cl_cmdrate 10", "cl_cmdupdate 10", "cl_interp 0.1"))
		printl("player " + player.GetName() + " exec command success");
	*/
}

function Notifications::OnPlayerLeft::ConnectHintDisconnect(player, name, steamId, params)
{
	if(!::ConnectHint.ConfigVar.Enable || !::ConnectHint.ConfigVar.Disconnected)
		return;
	
	if(steamId == "" || steamId == null || steamId == "BOT" || ("bot" in params) && params["bot"])
		return;
	
	if(::ConnectHint.ConfigVar.HintMode & 1)
		Utils.SayToAll("player %s (%s) disconnect [%s]", name, steamId, params["reason"]);
	if(::ConnectHint.ConfigVar.HintMode & 2)
	{
		if(::ConnectHint.ConfigVar.HintMode & 8)
		{
			foreach(player in Players.Humans())
			{
				if(::AdminSystem.IsAdmin(player, false))
					player.PrintToChat("player " + name + " (" + steamId + ") disconnect [" + params["reason"] + "]");
			}
		}
		else
		{
			// 虽然这个有点卡
			Utils.PrintToChatAll("player " + name + " (" + steamId + ") disconnect [" + params["reason"] + "]");
		}
	}
	
	if(::ConnectHint.ConfigVar.HintMode & 4)
		printl("player " + name + " (" + steamId + ") disconnect [" + params["reason"] + "]");
	
	Timers.RemoveTimerByName("timer_kick_connect_stuck_" + steamId);
	Utils.PlaySoundToAllEx("buttons/button4.wav");
}

function CommandTriggersEx::ca(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	/*
	if(Utils.BroadcastClientCommand("rate 10000", "cl_cmdrate 10", "cl_cmdupdate 10"))
		printl("exec broadcast command success");
	*/
}

function CommandTriggersEx::cc(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	local survivor = GetArgument(1);
	local command = GetArgument(2);
	local params = GetArgument(3);
	local target = Utils.GetPlayerFromName(survivor);
	
	if(survivor != null)
	{
		if(command != null && params != null)
			command += " " + params;
		
		local cl_cmd = null;
		if(survivor == "all" || survivor == "survivor" || survivor == "infected" || survivor == "!picker")
		{
			if(command == null || command == "")
			{
				printl("invalid commands " + command);
				return;
			}
			
			if(survivor == "survivor" || survivor == "infected")
				cl_cmd = Utils.CreateEntity("point_clientcommand", player.GetLocation());
		}
		
		if(survivor == "all")
		{
			Utils.BroadcastClientCommand(command);
			player.PrintToChat("broadcast command: " + survivor);
		}
		else if(survivor == "survivor")
		{
			foreach(client in Players.Survivors())
				client.ClientCommand(command);
		}
		else if(survivor == "infected")
		{
			foreach(client in Players.Infected())
				client.ClientCommand(command);
		}
		else if(survivor == "smoker")
		{
			foreach(client in Players.OfType(Z_SMOKER))
				client.ClientCommand(command);
		}
		else if(survivor == "boomer")
		{
			foreach(client in Players.OfType(Z_BOOMER))
				client.ClientCommand(command);
		}
		else if(survivor == "hunter")
		{
			foreach(client in Players.OfType(Z_HUNTER))
				client.ClientCommand(command);
		}
		else if(survivor == "spitter")
		{
			foreach(client in Players.OfType(Z_SPITTER))
				client.ClientCommand(command);
		}
		else if(survivor == "jockey")
		{
			foreach(client in Players.OfType(Z_JOCKEY))
				client.ClientCommand(command);
		}
		else if(survivor == "charger")
		{
			foreach(client in Players.OfType(Z_CHARGER))
				client.ClientCommand(command);
		}
		else if(survivor == "tank")
		{
			foreach(client in Players.OfType(Z_TANK))
				client.ClientCommand(command);
		}
		else if(survivor == "!picker" || target != null)
		{
			if(survivor == "!picker")
				target = player.GetLookingEntity();
			
			if(target != null)
				target.ClientCommand(command);
		}
		else
		{
			if(command != null)
				survivor += " " + survivor;
			
			Utils.BroadcastClientCommand(survivor);
			// player.ClientCommand(survivor);
			
			player.PrintToChat("exec command: " + survivor);
		}
		
		if(cl_cmd != null)
			cl_cmd.Kill();
	}
	else
	{
		player.ClientCommand("reset_gameconvars");
		player.PrintToChat("reset game convars");
	}
}

function CommandTriggersEx::qc(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	local survivor = GetArgument(1);
	local cvar = GetArgument(2);
	local target = Utils.GetPlayerFromName(survivor);
	
	if(survivor != null)
	{
		if(survivor == "all" || survivor == "survivor" || survivor == "infected" || survivor == "!picker")
		{
			if(cvar == null)
			{
				player.PrintToChat("invalid convars " + cvar);
				return;
			}
		}
		
		if(survivor == "all")
		{
			printl("========= " + cvar + " =========");
			foreach(client in Players.All())
				printl(client.GetName() + " -> " + client.GetClientConvarValue(cvar));
			printl("========= end =========");
		}
		else if(survivor == "survivor")
		{
			printl("========= " + cvar + " =========");
			foreach(client in Players.Survivors())
				printl(client.GetName() + " -> " + client.GetClientConvarValue(cvar));
			printl("========= end =========");
		}
		else if(survivor == "infected")
		{
			printl("========= " + cvar + " =========");
			foreach(client in Players.Infected())
				printl(client.GetName() + " -> " + client.GetClientConvarValue(cvar));
			printl("========= end =========");
		}
		else if(survivor == "smoker")
		{
			printl("========= " + cvar + " =========");
			foreach(client in Players.OfType(Z_SMOKER))
				printl(client.GetName() + " -> " + client.GetClientConvarValue(cvar));
			printl("========= end =========");
		}
		else if(survivor == "boomer")
		{
			printl("========= " + cvar + " =========");
			foreach(client in Players.OfType(Z_BOOMER))
				printl(client.GetName() + " -> " + client.GetClientConvarValue(cvar));
			printl("========= end =========");
		}
		else if(survivor == "hunter")
		{
			printl("========= " + cvar + " =========");
			foreach(client in Players.OfType(Z_HUNTER))
				printl(client.GetName() + " -> " + client.GetClientConvarValue(cvar));
			printl("========= end =========");
		}
		else if(survivor == "spitter")
		{
			printl("========= " + cvar + " =========");
			foreach(client in Players.OfType(Z_SPITTER))
				printl(client.GetName() + " -> " + client.GetClientConvarValue(cvar));
			printl("========= end =========");
		}
		else if(survivor == "jockey")
		{
			printl("========= " + cvar + " =========");
			foreach(client in Players.OfType(Z_JOCKEY))
				printl(client.GetName() + " -> " + client.GetClientConvarValue(cvar));
			printl("========= end =========");
		}
		else if(survivor == "charger")
		{
			printl("========= " + cvar + " =========");
			foreach(client in Players.OfType(Z_CHARGER))
				printl(client.GetName() + " -> " + client.GetClientConvarValue(cvar));
			printl("========= end =========");
		}
		else if(survivor == "tank")
		{
			printl("========= " + cvar + " =========");
			foreach(client in Players.OfType(Z_TANK))
				printl(client.GetName() + " -> " + client.GetClientConvarValue(cvar));
			printl("========= end =========");
		}
		else if(survivor == "!picker" || target != null)
		{
			if(survivor == "!picker")
				target = player.GetLookingEntity();
			
			if(target != null)
			{
				local val = target.GetClientConvarValue(cvar);
				player.PrintToChat("player " + target.GetName() + " " + cvar + " -> " + val);
				printl("player " + target.GetName() + " " + cvar + " -> " + val);
			}
		}
		else
		{
			local val = player.GetClientConvarValue(cvar);
			player.PrintToChat("self " + cvar + " -> " + val);
			printl("player " + player.GetName() + " " + cvar + " -> " + val);
		}
	}
	else
	{
		player.PrintToChat("invalid params. usag /qc <name> <cvar>");
	}
}


::ConnectHint.PLUGIN_NAME <- PLUGIN_NAME;
::ConnectHint.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::ConnectHint.ConfigVarDef);

function Notifications::OnRoundStart::ConnectHint_LoadConfig()
{
	RestoreTable(::ConnectHint.PLUGIN_NAME, ::ConnectHint.ConfigVar);
	if(::ConnectHint.ConfigVar == null || ::ConnectHint.ConfigVar.len() <= 0)
		::ConnectHint.ConfigVar = FileIO.GetConfigOfFile(::ConnectHint.PLUGIN_NAME, ::ConnectHint.ConfigVarDef);

	// printl("[plugins] " + ::ConnectHint.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::ConnectHint_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::ConnectHint.PLUGIN_NAME, ::ConnectHint.ConfigVar);

	// printl("[plugins] " + ::ConnectHint.PLUGIN_NAME + " saving...");
}
