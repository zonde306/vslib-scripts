::VSLib.PluginBase <- {};
::Plugins <- {};

class ::VSLib.BasePlugin
{
	constructor(name)
	{
		this._name = name;
		this._config = {};
		
		this.AddConfigValue("Enable", true);
		this.AddConfigValue("EnableMode", 31);
		
		::VSLib.PluginBase[name] <- this.weakref();
	}
	
	function _typeof()
	{
		return "PLUGIN_" + this._name.toupper();
	}
	
	function _cmp(other)
	{
		return this._name == other._name;
	}
	
	function _tostring(previdx = 0)
	{
		return this._name;
	}
	
	static _vsEntityClass = "VSLIB_PLUGIN";
	_name = null;
	_config = {};
	_enable = true;
}

function VSLib::BasePlugin::SetEnable(on, override = false)
{
	local oldValue = this._enable;
	this._enable = on;
	
	if(override && "Enable" in this._config)
		this._config["Enable"] <- on;
	
	return oldValue;
}

function VSLib::BasePlugin::GetConfigValue(name)
{
	if(!(name in this._config))
		return null;
	
	return this._config[name];
}

function VSLib::BasePlugin::AddConfigValue(name, value)
{
	return this._config[name] <- value;
}

function VSLib::BasePlugin::OnLoad(data)
{
	if(data != null)
		this._config = data;
}

function VSLib::BasePlugin::OnUnload()
{
	return this._config;
}

function VSLib::BasePlugin::OnGameMode(gamemode)
{
	if(!this.GetConfigValue("Enable"))
		this.SetEnable(false);
	
	local flags = this.GetConfigValue("EnableMode");
	switch(gamemode.tolower())
	{
		case "coop":
		case "realism":
		{
			this.SetEnable(!!(flags & 1));
			break;
		}
		case "survival":
		{
			this.SetEnable(!!(flags & 2));
			break;
		}
		case "versus":
		{
			this.SetEnable(!!(flags & 4));
			break;
		}
		case "scavenge":
		{
			this.SetEnable(!!(flags & 8));
			break;
		}
		case "survivalversus":
		{
			this.SetEnable((flags & 6) == 6);
			break;
		}
	}
}

function Notifications::OnRoundStart::PluginLoadData()
{
	local configTable = null;
	RestoreTable("plugins", configTable);
	
	if(configTable != null)
		foreach(name, inst in ::VSLib.PluginBase)
			if(inst != null && name in configTable)
				inst.OnLoad(configTable[name]);
}

function EasyLogic::OnShutdown::PluginSaveData( reason, nextmap )
{
	if ( reason > 0 && reason < 4 )
	{
		local configTable = {};
		foreach(name, inst in ::VSLib.PluginBase)
			if(inst != null)
				configTable[name] <- inst.OnUnload();
		SaveTable("plugins", configTable);
	}
}

function Notifications::OnModeStart::PluginCheckEnable( gamemode )
{
	foreach(name, inst in ::VSLib.PluginBase)
		if(inst != null)
			inst.OnGameMode(gamemode);
}
