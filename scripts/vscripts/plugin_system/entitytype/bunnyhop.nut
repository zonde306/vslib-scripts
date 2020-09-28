class ::ObjectSpawner2.Entity_BunnyHop extends ::ObjectSpawner2.BaseEntityType
{
	constructor(entity)
	{
		base.constructor(entity);
	}
	
	function _typeof()
	{
		return "OBJECT_SPAWNER_BUNNYHOP";
	}
	
	_bHasDissipating = false;
	_bHasFaded = false;
	_fFadeTime = 0.5;
	_timerFade = null;
	_fResetTime = 1.0;
	_timerReset = null;
}

::EntityType.Creator["bhop"] <- ::ObjectSpawner2.Entity_BunnyHop;
::EntityType.Creator["bunnyhop"] <- ::ObjectSpawner2.Entity_BunnyHop;
::EntityType.Creator["bh"] <- ::ObjectSpawner2.Entity_BunnyHop;

function ObjectSpawner2::Entity_BunnyHop::OnCreate(params)
{
	if("param1" in params)
		_fFadeTime = params["param1"];
	if("param2" in params)
		_timerReset = params["param2"];
}

function ObjectSpawner2::Entity_BunnyHop::OnGround(player)
{
	if(_bHasDissipating)
		return;
	
	_bHasDissipating = true;
	_timerFade = Timers.AddTimerByName(
		"timer_et_bhop_" + _ent.GetIndex() + "_fade", _fFadeTime, false,
		function(entity)
		{
			this.OnFadeStart();
		}, _ent);
}

function ObjectSpawner2::Entity_BunnyHop::OnFadeStart()
{
	_bHasDissipating = false;
	_bHasFaded = true;
	_timerFade = null;
	_timerReset = Timers.AddTimerByName(
		"timer_et_bhop_" + _ent.GetIndex() + "_reset", _fResetTime, false,
		function(entity)
		{
			this.OnFadeEnd();
		}, _ent);
}

function ObjectSpawner2::Entity_BunnyHop::OnFadeEnd()
{
	_bHasFaded = false;
	_timerReset = null;
}
