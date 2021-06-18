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
 * \brief A timer system to call a function after a certain amount of time.
 *
 *  The Timer table allows the developer to easily add synchronized callbacks.
 */
::VSLib.Timers <-
{
	TimersList = {}
	TimersID = {}
	ClockList = {}
	count = 0
}

/*
 * Constants
 */

// Passable constants
getconsttable()["NO_TIMER_PARAMS"] <- null; /** No timer params */

// Internal constants
const UPDATE_RATE = 0.01; /** Fastest possible update rate */

// Flags
getconsttable()["TIMER_FLAG_KEEPALIVE"] <- (1 << 1); /** Keep timer alive even after RoundEnd is called */
getconsttable()["TIMER_FLAG_COUNTDOWN"] <- (1 << 2); /** Fire the timer the specified number of times before the timer removes itself */
getconsttable()["TIMER_FLAG_DURATION"] <- (1 << 3); /** Fire the timer each interval for the specified duration */
getconsttable()["TIMER_FLAG_DURATION_VARIANT"] <- (1 << 4); /** Fire the timer each interval for the specified duration, regardless of internal function call time loss */
getconsttable()["TIMER_FLAG_REPEAT"] <- (1 << 5);

/**
 * Creates a named timer that will be added to the timers list. If a named timer already exists,
 * it will be replaced.
 *
 * @return Name of the created timer
 */
function VSLib::Timers::AddTimerByName(strName, delay, repeat, func, paramTable = null, flags = 0, value = {})
{
	if("action" in value)
	{
		if(value["action"] == "once")
		{
			if(strName in ::VSLib.Timers.TimersID)
				return null;
		}
		else if(value["action"] == "reset")
		{
			if(strName in ::VSLib.Timers.TimersID)
				::VSLib.Timers.RemoveTimerByName(strName);
		}
	}
	else
		::VSLib.Timers.RemoveTimerByName(strName);
	
	::VSLib.Timers.TimersID[strName] <- ::VSLib.Timers.AddTimer(delay, repeat, func, paramTable, flags, value);
	return strName;
}

function VSLib::Timers::AddTimerOne(strName, delay, func, paramTable = null, flags = 0, value = {})
{
	if (strName in ::VSLib.Timers.TimersID)
		return false;
	
	::VSLib.Timers.TimersID[strName] <- ::VSLib.Timers.AddTimer(delay, (flags & TIMER_FLAG_REPEAT), func, paramTable, flags, value);
	return true;
}

function VSLib::Timers::RequestFrame(func, paramTable = null, value = {})
{
	::VSLib.Timers.AddTimer(UPDATE_RATE, false, func, paramTable, 0, value);
}

/**
 * Deletes a named timer.
 */
function VSLib::Timers::RemoveTimerByName(strName)
{
	if (strName in ::VSLib.Timers.TimersID)
	{
		local id = ::VSLib.Timers.TimersID[strName];
		delete ::VSLib.Timers.TimersID[strName];
		return ::VSLib.Timers.RemoveTimer(id);
	}
	
	return false;
}

/**
 * Calls a function and passes the specified table to the callback after the specified delay.
 */
function VSLib::Timers::AddTimer(delay, repeat, func, paramTable = null, flags = 0, value = {})
{
	local TIMER_FLAG_COUNTDOWN = (1 << 2);
	local TIMER_FLAG_DURATION = (1 << 3);
	local TIMER_FLAG_DURATION_VARIANT = (1 << 4);
	local TIMER_FLAG_REPEAT = (1 << 5);
	
	delay = delay.tofloat();
	repeat = repeat.tointeger();
	
	local rep = (repeat > 0 || (flags & TIMER_FLAG_REPEAT)) ? true : false;
	
	if (delay < UPDATE_RATE)
	{
		printl("VSLib Warning: Timer delay cannot be less than " + UPDATE_RATE + " second(s). Delay has been reset to " + UPDATE_RATE + ".");
		delay = UPDATE_RATE;
	}
	
	if (paramTable == null)
		paramTable = {};
	
	if (typeof value != "table")
	{
		printf("VSLib Timer Error: Illegal parameter: 'value' parameter needs to be a table.");
		return -1;
	}
	else if (flags & TIMER_FLAG_COUNTDOWN && !("count" in value))
	{
		printf("VSLib Timer Error: Could not create the countdown timer because the 'count' field is missing from 'value'.");
		return -1;
	}
	else if ((flags & TIMER_FLAG_DURATION || flags & TIMER_FLAG_DURATION_VARIANT) && !("duration" in value))
	{
		printf("VSLib Timer Error: Could not create the duration timer because the 'duration' field is missing from 'value'.");
		return -1;
	}
	
	// Convert the flag into countdown
	if (flags & TIMER_FLAG_DURATION)
	{
		flags = flags & ~TIMER_FLAG_DURATION;
		flags = flags | TIMER_FLAG_COUNTDOWN;
		
		value["count"] <- floor(value["duration"].tofloat() / delay);
	}
	
	++count;
	TimersList[count] <-
	{
		_delay = delay
		_func = func
		_params = paramTable
		_startTime = Time()
		_baseTime = Time()
		_repeat = rep
		_flags = flags
		_opval = value
	}
	
	return count;
}

/**
 * Removes the specified timer.
 */
function VSLib::Timers::RemoveTimer(idx)
{
	local removed = false;
	
	if (idx in TimersList)
	{
		delete ::VSLib.Timers.TimersList[idx];
		removed = true;
	}
	
	foreach(named, index in ::VSLib.Timers.TimersID)
	{
		if(index == idx)
		{
			delete ::VSLib.Timers.TimersID[named];
			removed = true;
			break;
		}
	}
	
	return removed;
}

/**
 * Manages VSLib timers.
 */
function VSLib::Timers::ManageTimer(idx, command, value = null, allowNegTimer = false)
{
	if ( idx in ::VSLib.Timers.ClockList && value == null )
	{
		::VSLib.Timers.ClockList[idx]._command <- command;
		::VSLib.Timers.ClockList[idx]._allowNegTimer <- allowNegTimer;
	}
	else
	{
		if ( value == null )
			value = 0;
		
		::VSLib.Timers.ClockList[idx] <-
		{
			_value = value
			_startTime = Time()
			_lastUpdateTime = Time()
			_command = command
			_allowNegTimer = allowNegTimer
		}
	}
}

/**
 * Returns the value of a VSLib timer.
 */
function VSLib::Timers::ReadTimer(idx)
{
	if ( idx in ::VSLib.Timers.ClockList )
		return ::VSLib.Timers.ClockList[idx]._value;
	
	return null;
}

/**
 * Returns a VSLib timer as a displayable string --:--.
 */
function VSLib::Timers::DisplayTime(idx)
{
	return ::VSLib.Utils.GetDisplayTime(::VSLib.Timers.ReadTimer(idx));
}

/**
 * Manages all timers and provides interface for custom updates.
 */
::VSLib.Timers._thinkFunc <- function()
{
	local TIMER_FLAG_COUNTDOWN = (1 << 2);
	local TIMER_FLAG_DURATION_VARIANT = (1 << 4);
	local TIMER_FLAG_REPEAT = (1 << 5);
	
	// current time
	local curtime = Time();
	// local throwRetry = [];
	
	// Execute timers as needed
	foreach (idx, timer in ::VSLib.Timers.TimersList)
	{
		if ((curtime - timer._startTime) >= timer._delay)
		{
			if (timer._flags & TIMER_FLAG_COUNTDOWN)
			{
				timer._params["TimerCount"] <- timer._opval["count"];
				
				if ((--timer._opval["count"]) <= 0)
				{
					timer._repeat = false;
					timer._flags = timer._flags & (~TIMER_FLAG_REPEAT);
				}
			}
			
			if (timer._flags & TIMER_FLAG_DURATION_VARIANT && (curtime - timer._baseTime) > timer._opval["duration"])
			{
				delete ::VSLib.Timers.TimersList[idx];
				continue;
			}
			
			/*
			// 非重复的 timer 提前删除，避免无法再次启动
			if(!(timer._repeat || (timer._flags & TIMER_FLAG_REPEAT)))
				::VSLib.Timers.RemoveTimer(idx);
			*/
			
			local retry = false;
			
			try
			{
				local result = timer._func(timer._params);
				if (result == false)
				{
					timer._repeat = false;
					timer._flags = timer._flags & (~TIMER_FLAG_REPEAT);
				}
				if(typeof(result) == "integer" || typeof(result) == "float")
				{
					if(result == 0)
					{
						timer._repeat = false;
						timer._flags = timer._flags & (~TIMER_FLAG_REPEAT);
					}
					else
					{
						timer._delay = result;
						
						// 允许非重复的 timer 重启
						retry = true;
					}
				}
			}
			catch (id)
			{
				printf("VSLib Timer caught exception; closing timer %d. Error was: %s", idx, id.tostring());
				local deadFunc = timer._func;
				local params = timer._params;
				::VSLib.Timers.RemoveTimer(idx);
				deadFunc(params); // this will most likely throw
				// throwRetry.append(id);
				continue;
			}
			
			if (timer._repeat || (timer._flags & TIMER_FLAG_REPEAT) || retry)
				timer._startTime = curtime;
			else
				::VSLib.Timers.RemoveTimer(idx);
		}
	}
	foreach (idx, timer in ::VSLib.Timers.ClockList)
	{
		if ( Time() > timer._lastUpdateTime )
		{
			local newTime = Time() - timer._lastUpdateTime;
			
			if ( timer._command == 1 )
				timer._value += newTime;
			else if ( timer._command == 2 )
			{
				if ( timer._allowNegTimer )
					timer._value -= newTime;
				else
				{
					if ( timer._value > 0 )
						timer._value -= newTime;
				}
			}
			
			timer._lastUpdateTime <- Time();
		}
	}
	
	/*
	foreach(exception in throwRetry)
		throw exception;
	*/
}

/*
 * Create a think timer
 */
if (!("_thinkTimer" in ::VSLib.Timers))
{
	// ::VSLib.Timers._thinkTimer <- SpawnEntityFromTable("info_target", { targetname = "vslib_timer" });
	::VSLib.Timers._thinkTimer <- SpawnEntityFromTable("logic_timer", { targetname = "vslib_timer", RefireTime = UPDATE_RATE });
	if (::VSLib.Timers._thinkTimer != null)
	{
		::VSLib.Timers._thinkTimer.ValidateScriptScope();
		local scrScope = ::VSLib.Timers._thinkTimer.GetScriptScope();
		scrScope["ThinkTimer"] <- ::VSLib.Timers._thinkFunc;
		// AddThinkToEnt(::VSLib.Timers._thinkTimer, "ThinkTimer");
		::VSLib.Timers._thinkTimer.ConnectOutput("OnTimer", "ThinkTimer");
		EntFire("!self", "Enable", null, 0, ::VSLib.Timers._thinkTimer);
	}
	else
		throw "VSLib Error: Timer system could not be created; Could not create logic_timer";
}


// Add a weakref
::Timers <- ::VSLib.Timers.weakref();