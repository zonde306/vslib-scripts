::g_PluginManager <- {};

::IncludePlugin <- function(fileName, pluginName)
{
	getroottable()["PLUGIN_NAME"] <- pluginName;
	
	// ::VSLib.FileIO.LoadConfigFromFile(pluginName);
	
	::g_PluginManager[pluginName] <- {};
	IncludeScript(fileName, ::g_PluginManager[pluginName]);
	// ::VSLib.FileIO.LoadPluginList[pluginName] <- fileName;
	// ::VSLib.FileIO.AddPluginToLoader(fileName, pluginName);
	
	// ::VSLib.FileIO.SaveDefaultConfigToFile(pluginName);
	
	if("Plugin" in ::g_PluginManager[pluginName])
		::g_PluginManager[pluginName]["g_Instance"] <- ::g_PluginManager[pluginName]["Plugin"]();
};

if(Director.GetGameMode() != "holdout")
{
	IncludeScript("plugins/resources_lite.nut");
	Msg("Activating resources lite.\n");
}

// ::IncludePlugin("plugins/object_spawner.nut", "objectspawner");
::IncludePlugin("plugins/object_spawner.nut", "objectspawner2");
// ::IncludePlugin("plugins/onbotupdate.nut", "onbotupdate");
// ::IncludePlugin("plugins/versus_bots.nut", "versusbots");

// ::IncludePlugin("plugins/shotgun_sound_fix.nut", "shotgunfix");
// ::IncludePlugin("plugins/kill_loot.nut", "killloot");
// ::IncludePlugin("plugins/bot_defib.nut", "botdefib");
// ::IncludePlugin("plugins/bot_pickup.nut", "botpickup");
// ::IncludePlugin("plugins/weapon_ammo.nut", "weaponammo");
// ::IncludePlugin("plugins/friend_fire.nut", "firendlyfire");
// ::IncludePlugin("plugins/incap_selfhelp.nut", "selfhelp");
// ::IncludePlugin("plugins/incap_weapon.nut", "incapweapon");
// ::IncludePlugin("plugins/map_change.nut", "autochangelevel");
// ::IncludePlugin("plugins/multiple_upgrade.nut", "multipleupgrade");
::IncludePlugin("plugins/round_end_check.nut", "noroundendcheck");
// ::IncludePlugin("plugins/round_supply.nut", "roundstartsupply");
// ::IncludePlugin("plugins/bot_grenade.nut", "botgrenade");
// ::IncludePlugin("plugins/heal_delay.nut", "painpillsdelay");
// ::IncludePlugin("plugins/help_bouns.nut", "helpbonus");
// ::IncludePlugin("plugins/gnome_heal.nut", "gnomeheal");
// ::IncludePlugin("plugins/ammo_pickup.nut", "allowpickupammo");
::IncludePlugin("plugins/connect_hint.nut", "connectinfo");
// ::IncludePlugin("plugins/tank_limit.nut", "tanklimit");
// ::IncludePlugin("plugins/damage_limit.nut", "damagefix");
// ::IncludePlugin("plugins/banalce.nut", "diffbalance");
// ::IncludePlugin("plugins/trap.nut", "trap");
::IncludePlugin("plugins/all_survivors.nut", "survivorfix");
::IncludePlugin("plugins/saferoom_melee.nut", "startmelee");
// ::IncludePlugin("plugins/point_save.nut", "pointsave");
// ::IncludePlugin("plugins/tank_open_door.nut", "tankcanopendoor");
// ::IncludePlugin("plugins/bunnyhop.nut", "bunnyhop");
// ::IncludePlugin("plugins/weapon_unlocker.nut", "weaponunlocker");
// ::IncludePlugin("plugins/damage_extra.nut", "damagextra");
// ::IncludePlugin("plugins/swimming.nut", "swim");
// ::IncludePlugin("plugins/saferoom_killer.nut", "saferoom_killer");
// ::IncludePlugin("plugins/heartbeat.nut", "heartbeat");
// ::IncludePlugin("plugins/evil_witch.nut", "evilwitch");
// ::IncludePlugin("plugins/pouncedfix.nut", "pouncedfix");
// ::IncludePlugin("plugins/tougher_survivorbots.nut", "toughersurvivorbots");
// ::IncludePlugin("plugins/awayfrom_witchtank.nut", "awayfromdanger");
// ::IncludePlugin("plugins/fastmeleefix.nut", "fastmeleefix");
// ::IncludePlugin("plugins/chargeidle_detect.nut", "chargeidledetect");
// ::IncludePlugin("plugins/fastladderfix.nut", "fastladderfix");
// ::IncludePlugin("plugins/aimbot.nut", "aimbot");
// ::IncludePlugin("plugins/witch_idle_fix.nut", "witchidlefix");
// ::IncludePlugin("plugins/grief_protect.nut", "griefprotect");
// ::IncludePlugin("plugins/pill_pass_fix.nut", "pillpassfix");
// ::IncludePlugin("plugins/special_spawnner.nut", "specialspawnner");
::IncludePlugin("plugins/round_start_pause.nut", "roundstartpause");
::IncludePlugin("plugins/ai_damagefix.nut", "aidamagefix");
::IncludePlugin("plugins/skill_detect.nut", "skilldetect");

// IncludeScript("entitytype/bunnyhop.nut");
// IncludeScript("entitytype/fall.nut");
// IncludeScript("entitytype/teleport.nut");

::g_VersusBotTriggers <- {};
// IncludeScript("versus_bots.nut", ::g_VersusBotTriggers);
