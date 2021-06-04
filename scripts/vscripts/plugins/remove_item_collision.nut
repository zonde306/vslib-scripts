::RemoveCollision <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
	},
	
	ConfigVar = {},
	
	function Timer_RemoveColision(entity)
	{
		if(entity)
		{
			::RemoveCollision.RemoveColision(entity);
		}
		else
		{
			foreach(ent in Objects.OfClassname("we*"))
				::RemoveCollision.RemoveColision(ent);
			
			foreach(ent in Objects.OfClassname("p*"))
				if(ent.HasNetProp("m_isCarryable"))
					::RemoveCollision.RemoveColision(ent);
		}
	},
	
	function RemoveColision(entity)
	{
		try
		{
			if(entity != null && entity.IsValid() && entity.GetType() == null)
				entity.SetNetPropInt("m_CollisionGroup", 2);
		}
		catch(e)
		{
		}
	},
};

function Notifications::OnWeaponDropped::RemoveCollision(player, entity, params)
{
	if(!::RemoveCollision.ConfigVar.Enable)
		return;
	
	::RemoveCollision.RemoveColision(entity);
}

function Notifications::OnRoundBegin::RemoveCollision(params)
{
	if(!::RemoveCollision.ConfigVar.Enable)
		return;
	
	Timers.AddTimerByName("remove_collision", 0.2, false, ::RemoveCollision.Timer_RemoveColision);
}

function Notifications::OnEntityVisible::RemoveCollision(player, entity, params)
{
	if(!::RemoveCollision.ConfigVar.Enable)
		return;
	
	::RemoveCollision.RemoveColision(entity);
}

::RemoveCollision.PLUGIN_NAME <- PLUGIN_NAME;
::RemoveCollision.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::RemoveCollision.ConfigVarDef);

function Notifications::OnRoundStart::RemoveCollision_LoadConfig()
{
	RestoreTable(::RemoveCollision.PLUGIN_NAME, ::RemoveCollision.ConfigVar);
	if(::RemoveCollision.ConfigVar == null || ::RemoveCollision.ConfigVar.len() <= 0)
		::RemoveCollision.ConfigVar = FileIO.GetConfigOfFile(::RemoveCollision.PLUGIN_NAME, ::RemoveCollision.ConfigVarDef);

	// printl("[plugins] " + ::RemoveCollision.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::RemoveCollision_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::RemoveCollision.PLUGIN_NAME, ::RemoveCollision.ConfigVar);

	// printl("[plugins] " + ::RemoveCollision.PLUGIN_NAME + " saving...");
}
