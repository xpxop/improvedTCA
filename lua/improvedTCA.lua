-- Improved Thrustmaster Boeing TCA Autopilot Control Integration Script for X-plane by Seb
-- Based on the "Thrustmaster Boeing TCA Autopilot Control Integration Script for X-plane by Andrew Spink (theegg52)"

-- NEW: path to plane config file - if you do not have one script will use default settings
local aircraftCfgPath = AIRCRAFT_PATH .. "improvedTCA_config.lua"

modeset = 1
dataref("TIME", "sim/time/total_running_time_sec")

-- Here you can define the changes for normal (normIncr) and fast (fastIncr) knob turn speed
-- Fast is detected via the button hold that the knob sends at higher turn speeds
-- store increments in table for each mode (default secondary modes SPD -> baro, HDG -> CRS, ALT -> VS)


local increments = {
	spd = {
		normal = 1,
		fast = 2,
	},
	hdg = {
		normal = 1,
		fast = 2,
	},
	alt = {
		normal = 100,
		fast = 1000,
	},
	spd2nd = {
		normal = 0.01,
		fast = 0.1,		
	},
	hdg2nd = {
		normal = 1,
		fast = 2,
	},
	alt2nd = {
		normal = 50,
		fast = 100,		
	}
}

-- This is a new approach to get a smoother knob experience
-- The knob click to click time (DT) gets checked against the floating average of n = lengthTickValues (default 3)
-- if DT is smaller than floating average - maxDeviationSecs - this click gets ignored
-- abrupt direction changes are also ignored if direction changes happen in under directionChangeDtThresholdSecs

local maxDeviationSecs = 0.1 -- increase this value to make the knob more responsive (and probably more bouncy)
local minHoldTimeFastTicksSecs = 0.1 -- increase this value to make the knob wait longer before switching to fast turning mode
local minHoldTickDtSecs = 0.05 -- decrease this value to get faster fast tick speed
local directionChangeDtThresholdSecs = 0.5 -- increase this value to make knob less sensitive to sudden direction changes
local lengthTickValues = 3 -- increase this value to increase the number of values for floating average -> larger values mean slower & smoother, 1 turns that off, must be >= 1

-- These are the times in sec that define the sel / knob click behavior - at the momenent double click is not used;
local doubleClickTime = 0.5
-- Hold times define how long you have to hold down the knob to actuate Hold or LongHold actions (LongHold switches knob to secondary function mode)
local minSelHoldTime = 0.5
local minSelLongHoldTime = 2
-- This timeout in sec defines how long the secondary mode stays activated without any inputs
local secondaryModeTimeOut = 3

-- Don't change these
local lastPressTime = 0
local lastHoldTime = 0
local lastReleaseTime = 0
local holdActive = false
local lastSelClickTime = 0
local selHoldTime = 0
local lastMode = 0
local lastSecondaryModeChangeTime = 0
local secondaryModeOffset = 3
local maxMode = 6
local secondaryModeActive = false
local lastDirection = 0
local lastTickValues = {}
if lengthTickValues <= 0 then
	lengthTickValues = 1
end
for i=1,lengthTickValues do
	table.insert(lastTickValues, 0)
end

-- mode ID to mode table - don't change these
local modes = {
	[1] = "spd",
	[2] = "hdg",
	[3] = "alt",
	[4] = "spd2nd",
	[5] = "hdg2nd",
	[6] = "alt2nd"
}

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

-- datarefs table; secondary knob functions activated by long knob press
-- new knob dataref table with defaults - don't change these here for a new plane - just change the "table" entries later after "what plane is active" check 
-- or better use the improvedTCA_default_config.lua as template for a plane specific config file that you place in the base folder of the respective plane(s)

knobRefs = {
		spd = {
			turnRef = "sim/cockpit/autopilot/airspeed", -- this is the dataref holding the value that will be changed
			turnCommandOnce = false, 					-- this bool can be used if value can only be changed via turnRefUP & turnRefDN button type data refs
			turnRefUP = "", 							-- button type data ref that increases value if commanded once
			turnRefDN = "", 							-- button type data ref that decreases value if commanded once
			turnCheckRef = "",							-- a dataref (typically of 0 or 1 type) to be checked to allow modification via turnValueModifier value
			turnValueModifier = nil,					-- value that is used to modifie value (example baro value is always saved in inHg -> so if hPa is displayed each increase by 1 needs to be modified to reflect repsective change in inHg
			pressRef = "sim/autopilot/level_change",	-- button type data that gets fired when knob is briefly pressed
			holdRef = ""								-- button type data that gets fired when knob is longer pressed / held down
		},
		hdg = {
			turnRef = "sim/cockpit/autopilot/heading",
			turnCommandOnce = false,
			turnRefUP = "",
			turnRefDN = "",
			turnCheckRef = "",
			turnValueModifier = nil,
			pressRef = "sim/autopilot/heading",
			holdRef = ""
		},
		alt = {
			turnRef = "sim/cockpit/autopilot/altitude",
			turnCommandOnce = false,
			turnRefUP = "",
			turnRefDN = "",
			turnCheckRef = "",
			turnValueModifier = nil,
			pressRef = "sim/autopilot/altitude_hold",
			holdRef = "",
			maxalt = 50000
		},
		spd2nd = { -- default use to turn baro knob
			turnRef = "",
			turnCommandOnce = false,
			turnRefUP = "",
			turnRefDN = "",
			turnCheckRef = "",
			turnValueModifier = 2.9529980164712, -- hPa -> inHg for baro
			pressRef = "",
			holdRef = ""
		},
		hdg2nd = { -- default use to turn CRS knob
			turnRef = "",
			turnCommandOnce = false,
			turnRefUP = "",
			turnRefDN = "",
			turnCheckRef = "",
			turnValueModifier = nil,
			pressRef = "",
			holdRef = ""
		},
		alt2nd = { -- default use to turn VS knob
			turnRef = "",
			turnCommandOnce = false,
			turnRefUP = "",
			turnRefDN = "",
			turnCheckRef = "",
			turnValueModifier = nil,
			pressRef = "",
			holdRef = ""
		}
	}
	
-- NEW This part has been reworked to remove all the plane specific configs into their own files!
-- NOTE: A lot of this is currently untested as I don't have or use all the planes - either you test yourself and contribute or you ask me kindly if I could do it 
-- NOTE: (for free planes: typically no prob if I have time, payware: Either you send me the datarefs that are used or donate me the plane ;))
-- NOTE: So far I have tested: zibo mod in XP12
-- Acknowledgment of original script authors and contributors:
-- Thrustmaster Boeing TCA Autopilot Control Integration Script for X-plane by Andrew Spink (theegg52)
-- Thanks to x-plane.org forum user adamo_cze whos encoder smoothing and acceleration scripts ive integrated to provide those functions.

-- you have to use the new table structure for datarefs!



if file_exists(aircraftCfgPath) then
	logMsg("plane lua config found - trying to load now...")
	assert(loadfile(aircraftCfgPath))(knobRefs)
	logMsg("plane lua config loaded")
else
	logMsg("No plane lua config file found!")
end
	

function isempty(s)
  return s == nil or s == ''
end

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- function for future more complex value requests
function get_current_value(knobRef)
	return get(knobRef.turnRef)
end

function calcValidSPD(knobRef, chg)
	return get_current_value(knobRef) + chg
end

function calcValidHDG(knobRef, chg)
	return (get_current_value(knobRef) + chg) % 360
end

function calcValidALT(knobRef, chg)
	val = get_current_value(knobRef) + chg
	val = math.ceil(val/100)*100
	if val >= knobRef["maxalt"] then
	-- NEW maxalt - 1 replaced! compatibility with original script removed
		val = knobRef["maxalt"]
	end
	-- fix for turning around ALT
	if val <= 0 then
		val = 0
	end
	-- TODO: this has to be moved out of this function
	if PLANE_ICAO == "MD88" then			
		set("Rotate/md80/autopilot/alt_sel_ft",val/100)
	elseif PLANE_ICAO == "MD11" then
		set("Rotate/aircraft/systems/gcp_alt_sel_ft",val)
	end
	return val
end

function calcValidSPD2nd(knobRef, chg)
	modifyVal = false
	if ((not isempty(knobRef.turnCheckRef)) and (not isempty(knobRef.turnValueModifier))) then
		if get(knobRef.turnCheckRef) > 0 then
			modifyVal = true
		end
	end
	if modifyVal then
		val = get_current_value(knobRef) + chg * knobRef.turnValueModifier
	else
		val = get_current_value(knobRef) + chg
	end
	return round(val, 2)
end

function calcValidHDG2nd(knobRef, chg)
	return calcValidHDG(knobRef, chg)
end

function calcValidALT2nd(knobRef, chg)
	return get_current_value(knobRef) + chg
end


local calcValidValue = {
	spd = calcValidSPD,
	hdg = calcValidHDG,
	alt = calcValidALT,
	spd2nd = calcValidSPD2nd, -- set baro
	hdg2nd = calcValidHDG2nd, -- 4 is CRS -> same calc as HDG
	alt2nd = calcValidALT2nd, -- VS
}
	

-- does all the value changes

function changeValue(modeid, direction, fastMode)
	keepSecondaryModeAlive()
	local valueChange
	local newValue
	local mode = modes[modeid]
	
	if fastMode == true then
		valueChange = increments[mode].fast
	else
		valueChange = increments[mode].normal
	end
	if knobRefs[mode].turnCommandOnce then
		-- dref is a button type
		if direction > 0 then
			if not isempty(knobRefs[mode].turnRefUP) then command_once(knobRefs[mode].turnRefUP) end
		else
			if not isempty(knobRefs[mode].turnRefDN) then command_once(knobRefs[mode].turnRefDN) end
		end
	else
		if not isempty(knobRefs[mode].turnRef) then 
			-- checks and recalcs valid values
			newValue = calcValidValue[mode](knobRefs[mode], direction * valueChange)
			-- set the dataref to the new value
			set(knobRefs[mode].turnRef, newValue)
		end
	end
end

function averageTick(a)
	local sum = 0
	for index, value in ipairs(a) do
		sum = sum + value
	end
	return sum / table.getn(a)
end

function push_pop(a, e)
	table.insert(a, 1, e)
	table.remove(a)
	return a
end

function rotHold(direction)
	local now = TIME
	if (now - lastHoldTime > minHoldTickDtSecs) and (now - lastPressTime >= minHoldTimeFastTicksSecs) then
		changeValue(modeset, direction, true)
		lastHoldTime = now
		holdActive = true
		--print(string.format("HOLD delta time: %.4f direction: %d, last direction: %d", dt, direction, lastDirection))
	end
	lastDirection = direction
end

function rotRelease(direction)
	local now = TIME
	local dt = now - lastReleaseTime
	push_pop(lastTickValues, dt)
	local avg = averageTick(lastTickValues)
	if ((lastDirection == direction) or (dt > directionChangeDtThresholdSecs)) and not holdActive then
		if (dt >= avg - maxDeviationSecs) then
			changeValue(modeset, direction, false)
		end
		lastReleaseTime = now
		lastDirection = direction
	end
	holdActive = false
end

function rotPress(direction)
	lastPressTime = TIME
	--print(string.format("PRESS delta time since release: %.4f direction: %d, last direction: %d", dt, direction, lastDirection))
end


function selClick()
	selClickTime = TIME
	lastSelClickTime = selClickTime
end


function selHold()
	logMsg("sel hold down")
end


function selRelease()
	if (TIME - lastSelClickTime) >= minSelLongHoldTime then
		selLongHoldAction()
	elseif (TIME - lastSelClickTime) >= minSelHoldTime then
		selHoldAction()
	else
		selClickAction()
	end
end


function secondaryModeCheckReset()
	checktime = TIME
	if checktime - lastSecondaryModeChangeTime >= secondaryModeTimeOut then
		return true
	else
		return false
	end
end

function keepSecondaryModeAlive()
	if secondaryModeActive then
		lastSecondaryModeChangeTime = TIME
	end
end

function selLongHoldAction()
	-- logMsg("Sel long hold")
	if modeset + secondaryModeOffset <= maxMode then
		if not isempty(knobRefs[modes[modeset + secondaryModeOffset]].turnRef) then
			-- logMsg("Switch to secondary mode")
			lastSecondaryModeChangeTime = TIME
			secondaryModeActive = true
			lastMode = modeset
			modeset = modeset + secondaryModeOffset
			-- logMsg(modeset)
		end
	end
end


function selHoldAction()
	-- logMsg("Sel Hold")
	if not isempty(knobRefs[modes[modeset]].holdRef) then command_once(knobRefs[modes[modeset]].holdRef) end
end

function selClickAction()
	-- logMsg("Sel Click")
	if not isempty(knobRefs[modes[modeset]].pressRef) then command_once(knobRefs[modes[modeset]].pressRef) end
end

function checkholdset(modeid)
	if ((modeid ~= modeset and secondaryModeCheckReset()) or modeid ~= lastMode) then
		modeset = modeid
		lastMode = modeid
		secondaryModeActive = false
	end
end

function draw_improvedtca_info()
	if secondaryModeActive then
		draw_string(50, 50, "Secondary knob mode active", "red")
	end
end

do_every_draw("draw_improvedtca_info()")


create_command("FlyWithLua/improvedboetca/turnincr",           -- command's name
  "Value Increase",                                        -- description
  "rotPress(1)",                                  -- first press
  "rotHold(1)",                                                     --  hold
  "rotRelease(1)")   			                  					  -- release
  
create_command("FlyWithLua/improvedboetca/turndecr",           -- command's name
  "Value Decrease",                                        -- description
  "rotPress(-1)",                                  -- first press
  "rotHold(-1)",                                                     --  hold
  "rotRelease(-1)")   			                  					  -- release
  
create_command("FlyWithLua/improvedboetca/modesel",           -- command's name
  "Mode Selector",                                        -- description
  "selClick()",                                  -- set DataRef on first press
  "",                                                     -- do nothing during hold
  "selRelease()")   			                  					  -- do nothing on release
  
create_command("FlyWithLua/improvedboetca/setias",           -- command's name
  "IAS",                                        -- description
  "modeset = 1",                                  -- set DataRef on first press
  "checkholdset(1)",                                                     -- do nothing during hold
  "")   			                  					  -- do nothing on release
  
create_command("FlyWithLua/improvedboetca/sethdg",           -- command's name
  "HDG",                                        -- description
  "modeset = 2",                                  -- set DataRef on first press
  "checkholdset(2)",                                                     -- do nothing during hold
  "")   			                  					  -- do nothing on release
  
create_command("FlyWithLua/improvedboetca/setalts",           -- command's name
  "ALT",                                        -- description
  "modeset = 3",                                  -- set DataRef on first press
  "checkholdset(3)",                                                     -- do nothing during hold
  "")  
