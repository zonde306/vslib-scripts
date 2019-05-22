/*  
 * Copyright (c) 2013 LuKeM aka Neil - 119 and Rayman1103
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software
 * and associated documentation files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all copies or
 * substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
 * BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 */


/**
* File I/O functions that simplify the saving and loading of data.
*/
::VSLib.FileIO <- {};
::VSLib.FileIO.SaveConfig <- {};
::VSLib.FileIO.DefaultConfig <- {};
::VSLib.FileIO.ConfigSaveEvent <- {};
::VSLib.FileIO.ConfigLoadEvent <- {};
::VSLib.FileIO.ConfigSaveOne <- {};
::VSLib.FileIO.ConfigLoadOne <- {};
::VSLib.FileIO.LoadPluginList <- {};

/**
 * Recursively serializes a table and returns the string. This command ignores all functions within
 * the table, saving only the primitive types (i.e. integers, floats, strings, etc with definite values).
 * The indexes that you use for your table need to be programmatically "clean," meaning that the index
 * cannot contain invalid characters like +-=!@#$%^&*() etc. Indexes that contain any kind of
 * invalid character is completely ignored. If you are trying to store player information,
 * use Player::GetUniqueID() instead of Player::GetSteamID() for the index ID.
 *
 * You probably won't need to use this function by itself. @see VSLib::FileIO::SaveTable()
 */
function VSLib::FileIO::SerializeTable(object, predicateStart = "{\n", predicateEnd = "}\n", indice = true)
{
	local baseString = predicateStart;
	
	foreach (idx, val in object)
	{
		local idxType = typeof idx;
		
		if (idxType == "instance" || idxType == "class" || idxType == "function")
			continue;
		
		// Check for invalid characters
		local idxStr = idx.tostring();
		local reg = regexp("^[a-zA-Z0-9_]*$");
		
		if (!reg.match(idxStr))
		{
			printf("VSLib Warning: Index '%s' is invalid (invalid characters found), skipping...", idxStr);
			continue;
		}
		
		// Check for numeric fields and prefix them so system can compile
		reg = regexp("^[0-9]+$");
		if (reg.match(idxStr))
			idxStr = "_vslInt_" + idxStr;
		
		
		local preCompileString = ((indice) ? (idxStr + " = ") : "");
		
		switch (typeof val)
		{
			case "table":
				baseString += preCompileString + ::VSLib.FileIO.SerializeTable(val);
				break;
			
			case "string":
				baseString += preCompileString + "\"" + ::VSLib.Utils.StringReplace(::VSLib.Utils.StringReplace(val, "\"", "{VSQUOTE}"), @"\\", "{VSSLASH}") + "\"\n"; // "
				break;
			
			case "integer":
				baseString += preCompileString + val + "\n";
				break;
			
			case "float":
				baseString += preCompileString + val + "\n";
				break;
			
			case "array":
				baseString += preCompileString + ::VSLib.FileIO.SerializeTable(val, "[\n", "]\n", false);
				break;
				
			case "bool":
				baseString += preCompileString + ((val) ? "true" : "false") + "\n";
				break;
		}
	}
	
	baseString += predicateEnd;
	
	return baseString;
}

/**
 * This function will serialize and save a table to the hard disk; useful for storing stats,
 * round times, and other important information.
 */
function VSLib::FileIO::SaveTable(fileName, table)
{
	fileName += ".tbl";
	return StringToFile(fileName, ::VSLib.FileIO.SerializeTable(table));
}

/**
 * This function will clean table input.
 */
function VSLib::FileIO::DeserializeReviseTable(t)
{
	foreach (idx, val in t)
	{
		if (typeof val == "string")
			t[idx] = ::VSLib.Utils.StringReplace(::VSLib.Utils.StringReplace(val, "{VSQUOTE}", "\""), "{VSSLASH}", @"\"); // "
		else if (typeof val == "table")
			t[idx] = DeserializeReviseTable(val);
	}
	
	return t;
}

/**
 * This function will deserialize and return the compiled table.
 * If the table does not exist, null is returned.
 */
function VSLib::FileIO::LoadTable(fileName)
{
	local contents = FileToString(fileName + ".tbl");
	
	if (!contents)
		return null;
	
	local t = compilestring( "return " + contents )();
	
	foreach (idx, val in t)
	{
		local idxStr = idx.tostring();
		
		if (idxStr.find("_vslInt_") != null)
		{
			idxStr = Utils.StringReplace(idxStr, "_vslInt_", "");
			t[idxStr.tointeger()] <- val;
			delete t[idx];
		}
	}
	
	t = DeserializeReviseTable(t);
	
	return t;
}


/**
 * This function will make the filename unique for each mapname.
 * @authors Rayman1103
 */
function VSLib::FileIO::MakeFileName( mapname, modename )
{
	return "VSLib_" + mapname + "_" + modename;
}

/**
 * This function will serialize and save a table to the hard disk from the current mapname; useful for storing stats,
 * round times, and other important information individually for every mapname.
 * @authors Rayman1103
 */
function VSLib::FileIO::SaveTableFileName(mapname, modename, table)
{
	return ::VSLib.FileIO.SaveTable(::VSLib.FileIO.MakeFileName( mapname, modename ), table);
}

/**
 * This function will deserialize and return the compiled table from the current mapname.
 * If the table does not exist, null is returned.
 * @authors Rayman1103
 */
function VSLib::FileIO::LoadTableFileName(mapname, modename)
{
	return ::VSLib.FileIO.LoadTable(::VSLib.FileIO.MakeFileName( mapname, modename ));
}

function VSLib::FileIO::GetConfigTable(tableName, defaultData)
{
	local t = {};
	RestoreTable(tableName, t);
	if(t != null && t.len() > 0)
		return t;
	
	if(tableName in ::VSLib.FileIO.SaveConfig)
		return ::VSLib.FileIO.SaveConfig[tableName].weakref();
	
	::VSLib.FileIO.SaveConfig[tableName] <- defaultData;
	::VSLib.FileIO.DefaultConfig[tableName] <- defaultData;
	return ::VSLib.FileIO.SaveConfig[tableName].weakref();
}

function VSLib::FileIO::SetConfigTable(tableName, defaultData)
{
	::VSLib.FileIO.SaveConfig[tableName] <- defaultData;
	::VSLib.FileIO.DefaultConfig[tableName] <- defaultData;
	return ::VSLib.FileIO.SaveConfig[tableName].weakref();
}

function VSLib::FileIO::AddToConfigTable(tableName, varName, varDefault)
{
	if(!(tableName in ::VSLib.FileIO.SaveConfig))
		::VSLib.FileIO.SaveConfig[tableName] <- {};
	
	::VSLib.FileIO.SaveConfig[tableName][varName] <- varDefault;
	return ::VSLib.FileIO.SaveConfig[tableName][varName].weakref();
}

function VSLib::FileIO::GetConfigByTable(tableName, varName, varDefault)
{
	if(!(tableName in ::VSLib.FileIO.SaveConfig))
		::VSLib.FileIO.SaveConfig[tableName] <- {};
	if(!(tableName in ::VSLib.FileIO.DefaultConfig))
		::VSLib.FileIO.DefaultConfig[tableName] <- {};
	
	if(!(varName in ::VSLib.FileIO.SaveConfig[tableName]))
	{
		::VSLib.FileIO.SaveConfig[tableName][varName] <- varDefault;
		::VSLib.FileIO.DefaultConfig[tableName][varName] <- varDefault;
	}
	
	return ::VSLib.FileIO.SaveConfig[tableName][varName].weakref();
}

function VSLib::FileIO::SetConfigByTable(tableName, varName, varValue)
{
	if(!(tableName in ::VSLib.FileIO.SaveConfig))
		::VSLib.FileIO.SaveConfig[tableName] <- {};
	if(!(tableName in ::VSLib.FileIO.DefaultConfig))
		::VSLib.FileIO.DefaultConfig[tableName] <- {};
	
	if(!(varName in ::VSLib.FileIO.SaveConfig[tableName]))
		::VSLib.FileIO.SaveConfig[tableName][varName] <- varValue;
	else
		::VSLib.FileIO.SaveConfig[tableName][varName] = varValue;
	
	return ::VSLib.FileIO.SaveConfig[tableName][varName].weakref();
}

function VSLib::FileIO::LoadConfigFromFile(tableName)
{
	if(tableName in ::VSLib.FileIO.SaveConfig && ::VSLib.FileIO.SaveConfig[tableName].len() > 0)
		return false;
	
	::VSLib.FileIO.SaveConfig[tableName] <- ::VSLib.FileIO.LoadTable("plugins/" + tableName);
	if(::VSLib.FileIO.SaveConfig[tableName] == null)
	{
		delete ::VSLib.FileIO.SaveConfig[tableName];
		return false;
	}
	
	return true;
}

function VSLib::FileIO::GetConfigOfFile(tableName, defaultTable = {})
{
	local t = ::VSLib.FileIO.LoadTable("plugins/" + tableName);
	if(t == null || t.len() < defaultTable.len())
	{
		::VSLib.FileIO.SaveTable("plugins/" + tableName, defaultTable);
		return defaultTable;
	}
	
	return t;
}

function VSLib::FileIO::SaveDefaultConfigToFile(tableName)
{
	if(!(tableName in ::VSLib.FileIO.DefaultConfig) || ::VSLib.FileIO.DefaultConfig[tableName].len() <= 0)
		return false;
	
	if(FileToString("plugins/" + tableName + ".tbl"))
		return false;
	
	::VSLib.FileIO.SaveTable("plugins/" + tableName, ::VSLib.FileIO.DefaultConfig[tableName]);
	return true;
}

function VSLib::FileIO::AddPluginToLoader(fileName, pluginName)
{
	::VSLib.FileIO.LoadPluginList[pluginName] <- fileName;
}

function VSLib::FileIO::RegisterConfigLoader()
{
	Notifications.OnRoundStart["__VSLib_FileIO_LoadTable"] <- function()
	{
		local t = {};
		RestoreTable("vslib_config_save", t);
		
		if(t == null)
		{
			if(::VSLib.FileIO.SaveConfig == null)
				::VSLib.FileIO.SaveConfig = ::VSLib.FileIO.DefaultConfig;
			
			printl("cannot load config (" + ::VSLib.FileIO.SaveConfig.len() + ")");
		}
		else
		{
			/*
			foreach(tableName, tableData in t)
			{
				if(!(tableName in ::VSLib.FileIO.SaveConfig))
				{
					::VSLib.FileIO.SaveConfig[tableName] <- tableData;
					continue;
				}
				
				if(typeof(tableData) == "table" || typeof(tableData) == "array")
				{
					foreach(varName, varData in tableData)
					{
						if(varName in ::VSLib.FileIO.SaveConfig[tableName])
							::VSLib.FileIO.SaveConfig[tableName][varName] = varData;
						else
							::VSLib.FileIO.SaveConfig[tableName][varName] <- varData;
					}
				}
				else
				{
					::VSLib.FileIO.SaveConfig[tableName] = tableData;
				}
			}
			*/
			
			::VSLib.FileIO.SaveConfig = t;
			printl("load config done (" + ::VSLib.FileIO.SaveConfig.len() + ")");
		}
		
		foreach(pluginName, pluginFile in ::VSLib.FileIO.LoadPluginList)
		{
			getroottable()["PLUGIN_NAME"] <- pluginName;
			
			if(t == null)
				::VSLib.FileIO.LoadConfigFromFile(pluginName);
			
			IncludeScript(pluginFile);
			
			::VSLib.FileIO.SaveDefaultConfigToFile(pluginName);
		}
		
		foreach(plugins, table in ::VSLib.FileIO.SaveConfig)
		{
			if(plugins in ::VSLib.FileIO.ConfigLoadOne)
				func(table.weakref());
		}
		
		foreach(func in ::VSLib.FileIO.ConfigLoadEvent)
		{
			func(::VSLib.FileIO.SaveConfig.weakref());
		}
		
		printl("plugins loaded, total: " + ::VSLib.FileIO.SaveConfig.len() + "/" + ::VSLib.FileIO.LoadPluginList.len());
	};
	
	EasyLogic.OnShutdown["__VSLib_FileIO_SaveTable"] <- function(reason, nextmap)
	{
		if(reason > 0 && reason < 4)
		{
			local total = 0;
			foreach(plugins, table in ::VSLib.FileIO.SaveConfig)
			{
				if(plugins in ::VSLib.FileIO.ConfigSaveOne)
				{
					local result = ::VSLib.FileIO.ConfigSaveOne[plugins](table.weakref());
					if(typeof(result) == "table" || typeof(result) == "array")
					{
						::VSLib.FileIO.SaveConfig[plugins] = result;
						total += 1;
						
						SaveTable(plugins, result);
					}
				}
			}
			
			foreach(func in ::VSLib.FileIO.ConfigSaveEvent)
			{
				func(::VSLib.FileIO.SaveConfig.weakref());
			}
			
			SaveTable("vslib_config_save", ::VSLib.FileIO.SaveConfig);
			printl("plugins config saved, total: " + total + "/" + ::VSLib.FileIO.SaveConfig.len());
		}
	};
	
	printl("RegisterConfigLoader finish");
}

// Add a weak reference to the global table.
::FileIO <- ::VSLib.FileIO.weakref();