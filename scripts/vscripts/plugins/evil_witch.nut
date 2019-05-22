::EvilWitch <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = false,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = false,
		
		// 是否禁止燃烧的 Witch 转移目标
		NoBurning = true,
		
		// 触发 Witch 转移目标条件.1=击杀.2=击倒
		WitchTrigger = 3,
		
		// Witch 转移目标做的事情.-1=关闭.0~99=不高兴.100=发怒攻击其他目标
		WitchAngry = 50
	},
	
	ConfigVar = {},
	
	WitchTarget = {},
	
	function CreateWitch(position = null, angles = QAngle(0, 0, 0), rage = 0.0)
	{
		local witch = Utils.GetEntityOrPlayer(Utils.SpawnZombie(Z_WITCH, position, angles));
		if(witch == null || rage < 0.0)
			return null;
		
		if(rage > 1.0)
			rage = 1.0;
		
		// 让 witch 愤怒
		witch.SetNetPropFloat("m_rage", rage.tofloat());
		
		if(rage >= 1.0)
		{
			// 强制 witch 选择一个目标开始攻击
			witch.SetNetPropInt("m_mobRush", 1);
		}
		
		return witch;
	}
};

function Notifications::OnWitchStartled::EvilWitch_OnWitchAngry(victim, attacker, params)
{
	if(!::EvilWitch.ConfigVar.Enable)
		return;
	
	if(attacker == null || !attacker.IsSurvivor() || victim == null || !victim.IsEntityValid())
		return;
	
	local index = victim.GetIndex();
	::EvilWitch.WitchTarget[index] <- attacker;
	::EvilWitch.WitchTarget[attacker.GetIndex()] <- witch;
	printl("witch " + index + " angry with " + attacker);
}

function Notifications::OnWitchKilled::EvilWitch_OnWitchDeath(victim, attacker, params)
{
	if(victim == null || !victim.IsEntityValid())
		return;
	
	local index = victim.GetIndex();
	if(!(index in ::EvilWitch.WitchTarget))
		return;
	
	if(::EvilWitch.WitchTarget[index] != null && ::EvilWitch.WitchTarget[index].IsEntityValid())
	{
		local idx = ::EvilWitch.WitchTarget[index].GetIndex();
		if(idx in ::EvilWitch.WitchTarget)
			delete ::EvilWitch.WitchTarget[idx];
	}
	
	delete ::EvilWitch.WitchTarget[index];
	printl("witch " + index + " killed by " + attacker);
}

function Notifications::OnIncapacitated::EvilWitch_OnSurvivorDropped(victim, attacker, params)
{
	if(!::EvilWitch.ConfigVar.Enable)
		return;
	
	if(!(::EvilWitch.ConfigVar.WitchTrigger & 2))
		return;
	
	if(victim == null || !victim.IsSurvivor())
		return;
	
	local index = victim.GetIndex();
	if(!(index in ::EvilWitch.WitchTarget))
		return;
	
	local witch = ::EvilWitch.WitchTarget[index];
	if(witch == null || !witch.IsEntityValid())
	{
		delete ::EvilWitch.WitchTarget[index];
		return;
	}
	
	if(::EvilWitch.ConfigVar.NoBurning && witch.GetNetPropBool("m_bIsBurning"))
		return;
	
	if(::EvilWitch.CreateWitch(witch.GetLocation(), witch.GetAngles(),
		::EvilWitch.ConfigVar.WitchAngry * 0.01) != null)
	{
		delete ::EvilWitch.WitchTarget[index];
		index = witch.GetIndex();
		if(index in ::EvilWitch.WitchTarget)
			delete ::EvilWitch.WitchTarget[index];
		
		witch.Input("Kill");
		printl("a witch replaced by " + victim + " incap.");
	}
}

function Notifications::OnDeath::EvilWitch_OnSurvivorKilled(victim, attacker, params)
{
	if(!::EvilWitch.ConfigVar.Enable)
		return;
	
	if(victim == null || !victim.IsSurvivor())
		return;
	
	if(!(::EvilWitch.ConfigVar.WitchTrigger & 1))
		return;
	
	if(victim == null || !victim.IsSurvivor())
		return;
	
	local index = victim.GetIndex();
	if(!(index in ::EvilWitch.WitchTarget))
		return;
	
	local witch = ::EvilWitch.WitchTarget[index];
	if(witch == null || !witch.IsEntityValid())
	{
		delete ::EvilWitch.WitchTarget[index];
		return;
	}
	
	if(::EvilWitch.ConfigVar.NoBurning && witch.GetNetPropBool("m_bIsBurning"))
		return;
	
	if(::EvilWitch.CreateWitch(witch.GetLocation(), witch.GetAngles(),
		::EvilWitch.ConfigVar.WitchAngry * 0.01) != null)
	{
		delete ::EvilWitch.WitchTarget[index];
		index = witch.GetIndex();
		if(index in ::EvilWitch.WitchTarget)
			delete ::EvilWitch.WitchTarget[index];
		
		witch.Input("Kill");
		printl("a witch replaced by " + victim + " killed.");
	}
}

function CommandTriggersEx::ew(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	::EvilWitch.ConfigVar.Enable = !::EvilWitch.ConfigVar.Enable;
	printl("evil witch " + ::EvilWitch.ConfigVar.Enable);
}

::EvilWitch.PLUGIN_NAME <- PLUGIN_NAME;
::EvilWitch.ConfigVar = ::EvilWitch.ConfigVarDef;

function Notifications::OnRoundStart::EvilWitch_LoadConfig()
{
	RestoreTable(::EvilWitch.PLUGIN_NAME, ::EvilWitch.ConfigVar);
	if(::EvilWitch.ConfigVar == null || ::EvilWitch.ConfigVar.len() <= 0)
		::EvilWitch.ConfigVar = FileIO.GetConfigOfFile(::EvilWitch.PLUGIN_NAME, ::EvilWitch.ConfigVarDef);

	// printl("[plugins] " + ::EvilWitch.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::EvilWitch_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::EvilWitch.PLUGIN_NAME, ::EvilWitch.ConfigVar);

	// printl("[plugins] " + ::EvilWitch.PLUGIN_NAME + " saving...");
}
