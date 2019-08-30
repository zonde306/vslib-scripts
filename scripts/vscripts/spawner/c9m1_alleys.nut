::VSLib.Utils.CreateEntity("env_physics_blocker", Vector(156, -6648, -22), QAngle(0, 0, 0), {mins = Vector(0, 0, 0), maxs = Vector(530, 126, 333), initialstate = 1, BlockType = 1}, []);
::VSLib.Utils.CreateEntity("env_physics_blocker", Vector(28, -6652, -25), QAngle(0, 0, 0), {mins = Vector(0, -770, 0), maxs = Vector(130, 0, 410), initialstate = 1, BlockType = 1}, []);
::VSLib.Utils.CreateEntity("env_physics_blocker", Vector(-1027, -5054, 172), QAngle(0, 0, 0), {mins = Vector(-100, 0, -116), maxs = Vector(0, 100, 100), initialstate = 1, BlockType = 1}, []);
try { ::VSLib.Entity("howitzer_burn_trigger").SetKeyValue("damage", 200); ::VSLib.Entity("howitzer_burn_trigger").SetKeyValue("damagecap", 200); } catch(error) { }
