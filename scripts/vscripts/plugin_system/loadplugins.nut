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
};

if(Director.GetGameMode() != "holdout")
{
	IncludeScript("plugin_system/plugins/resources_lite.nut");
	Msg("Activating resources lite.\n");
}

// ::IncludePlugin("plugin_system/plugins/object_spawner.nut", "objectspawner");
::IncludePlugin("plugin_system/plugins/object_spawner.nut", "objectspawner2");
// ::IncludePlugin("plugin_system/plugins/onbotupdate.nut", "onbotupdate");
// ::IncludePlugin("plugin_system/plugins/versus_bots.nut", "versusbots");

// ::IncludePlugin("plugin_system/plugins/shotgun_sound_fix.nut", "shotgunfix");
// ::IncludePlugin("plugin_system/plugins/kill_loot.nut", "killloot");
// ::IncludePlugin("plugin_system/plugins/bot_defib.nut", "botdefib");
// ::IncludePlugin("plugin_system/plugins/bot_pickup.nut", "botpickup");
// ::IncludePlugin("plugin_system/plugins/weapon_ammo.nut", "weaponammo");
::IncludePlugin("plugin_system/plugins/friend_fire.nut", "firendlyfire");
// ::IncludePlugin("plugin_system/plugins/incap_selfhelp.nut", "selfhelp");
// ::IncludePlugin("plugin_system/plugins/incap_weapon.nut", "incapweapon");
// ::IncludePlugin("plugin_system/plugins/map_change.nut", "autochangelevel");
// ::IncludePlugin("plugin_system/plugins/multiple_upgrade.nut", "multipleupgrade");
::IncludePlugin("plugin_system/plugins/round_end_check.nut", "noroundendcheck");
// ::IncludePlugin("plugin_system/plugins/round_supply.nut", "roundstartsupply");
// ::IncludePlugin("plugin_system/plugins/bot_grenade.nut", "botgrenade");
// ::IncludePlugin("plugin_system/plugins/heal_delay.nut", "painpillsdelay");
::IncludePlugin("plugin_system/plugins/help_bouns.nut", "helpbonus");
// ::IncludePlugin("plugins/gnome_heal.nut", "gnomeheal");
// ::IncludePlugin("plugins/ammo_pickup.nut", "allowpickupammo");
::IncludePlugin("plugins/connect_hint.nut", "connectinfo");
// ::IncludePlugin("plugin_system/plugins/tank_limit.nut", "tanklimit");
// ::IncludePlugin("plugin_system/plugins/damage_limit.nut", "damagefix");
// ::IncludePlugin("plugin_system/plugins/banalce.nut", "diffbalance");
// ::IncludePlugin("plugin_system/plugins/trap.nut", "trap");
::IncludePlugin("plugin_system/plugins/all_survivors.nut", "survivorfix");
::IncludePlugin("plugin_system/plugins/saferoom_melee.nut", "startmelee");
// ::IncludePlugin("plugin_system/plugins/point_save.nut", "pointsave");
// ::IncludePlugin("plugin_system/plugins/tank_open_door.nut", "tankcanopendoor");
// ::IncludePlugin("plugin_system/plugins/bunnyhop.nut", "bunnyhop");
// ::IncludePlugin("plugin_system/plugins/weapon_unlocker.nut", "weaponunlocker");
// ::IncludePlugin("plugin_system/plugins/damage_extra.nut", "damagextra");
// ::IncludePlugin("plugin_system/plugins/swimming.nut", "swim");
// ::IncludePlugin("plugin_system/plugins/saferoom_killer.nut", "saferoom_killer");
// ::IncludePlugin("plugin_system/plugins/heartbeat.nut", "heartbeat");
// ::IncludePlugin("plugin_system/plugins/evil_witch.nut", "evilwitch");
::IncludePlugin("plugin_system/plugins/pouncedfix.nut", "pouncedfix");
// ::IncludePlugin("plugin_system/plugins/tougher_survivorbots.nut", "toughersurvivorbots");
::IncludePlugin("plugin_system/plugins/awayfrom_witchtank.nut", "awayfromdanger");
// ::IncludePlugin("plugin_system/plugins/fastmeleefix.nut", "fastmeleefix");
::IncludePlugin("plugin_system/plugins/chargeidle_detect.nut", "chargeidledetect");
// ::IncludePlugin("plugin_system/plugins/fastladderfix.nut", "fastladderfix");
::IncludePlugin("plugin_system/plugins/aimbot.nut", "aimbot");
// ::IncludePlugin("plugin_system/plugins/witch_idle_fix.nut", "witchidlefix");
::IncludePlugin("plugin_system/plugins/grief_protect.nut", "griefprotect");
// ::IncludePlugin("plugin_system/plugins/pill_pass_fix.nut", "pillpassfix");
// ::IncludePlugin("plugin_system/plugins/special_spawnner.nut", "specialspawnner");

// IncludeScript("plugin_system/entitytype/bunnyhop.nut");
// IncludeScript("plugin_system/entitytype/fall.nut");
// IncludeScript("plugin_system/entitytype/teleport.nut");

::g_VersusBotTriggers <- {};
// IncludeScript("plugin_system/versus_bots.nut", ::g_VersusBotTriggers);
