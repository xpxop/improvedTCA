-- Improved Thrustmaster Boeing TCA Autopilot Control Integration Script for X-plane by Seb
-- Based on the "Thrustmaster Boeing TCA Autopilot Control Integration Script for X-plane by Andrew Spink (theegg52)"

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

-- datarefs table; secondary knob functions activated by long knob press
-- new knob dataref table with defaults - don't change these here for a new plane - just change the "table" entries later after "what plane is active" check

local knobRefs = {
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
		holdRef = ""
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



-- This part has been adapted from original script and contains the dataref definitions and plane related functions:
-- NOTE: A lot of this is currently untested as I don't have or use all the planes - either you test yourself and contribute or you ask me kindly if I could do it 
-- NOTE: (for free planes: typically no prob if I have time, payware: Either you send me the datarefs that are used or donate me the plane ;))
-- NOTE: So far I have tested: zibo mod in XP12
-- Thrustmaster Boeing TCA Autopilot Control Integration Script for X-plane by Andrew Spink (theegg52)
-- Thanks to x-plane.org forum user adamo_cze whos encoder smoothing and acceleration scripts ive integrated to provide those functions.

-- you have to use the new table structure for datarefs


local maxalt = 50001


-- Zibo Mod & Level Up 73x
if(PLANE_ICAO == "B736") or (PLANE_ICAO == "B737") or (PLANE_ICAO == "B738" and string.find(AIRCRAFT_PATH, "737NG")) or (PLANE_ICAO == "B738" and string.find(AIRCRAFT_PATH, "800X")) or (PLANE_ICAO == "B739") then
	knobRefs["spd"].turnRef = "laminar/B738/autopilot/mcp_speed_dial_kts_mach"
	knobRefs["spd"].pressRef = "laminar/B738/autopilot/mcp_speed_dial_kts_mach"
	knobRefs["hdg"].turnRef = "laminar/B738/autopilot/mcp_hdg_dial"
	knobRefs["hdg"].pressRef = "laminar/B738/autopilot/hdg_sel_press"
	knobRefs["alt"].turnRef = "laminar/B738/autopilot/mcp_alt_dial"
	knobRefs["alt"].pressRef = "laminar/B738/autopilot/alt_hld_press"
	knobRefs["spd2nd"].turnRef = "laminar/B738/EFIS/baro_sel_in_hg_pilot"
	knobRefs["spd2nd"].turnCheckRef = "laminar/B738/EFIS_control/capt/baro_in_hpa"
	knobRefs["spd2nd"].pressRef = "laminar/B738/EFIS_control/capt/push_button/std_press"
	knobRefs["hdg2nd"].turnRef = "laminar/B738/autopilot/course_pilot"
	knobRefs["hdg2nd"].pressRef = "laminar/B738/autopilot/app_press"
	knobRefs["alt2nd"].turnRef = "sim/cockpit/autopilot/vertical_velocity"
	knobRefs["alt2nd"].pressRef = "laminar/B738/autopilot/vs_press"
	dataref("reverser_1", "laminar/B738/flt_ctrls/reverse_lever1", "writable")
	dataref("reverser_2", "laminar/B738/flt_ctrls/reverse_lever2", "writable")
	-- inspired by https://github.com/BorisEagle suggestion
	create_command("FlyWithLua/improvedboetca/rev1_idle",			 -- command's name
	  "Reverser #1 idle while holding",					 -- description
	  "reverser_1 = 0.06001",												-- set DataRef on first press
	  "",                                                      -- continue while hold
	  "reverser_1 = 0")   			                  					   -- switch back on release

	create_command("FlyWithLua/improvedboetca/rev2_idle",			 -- command's name
	  "Reverser #2 idle while holding",					 -- description
	  "reverser_2 = 0.06001",												-- set DataRef on first press
	  "",                                                      -- continue while hold
	  "reverser_2 = 0")
	create_command("FlyWithLua/improvedboetca/rev1_25",			 -- command's name
	  "Reverser #1 25% while holding",					 -- description
	  "reverser_1 = 0.25",												-- set DataRef on first press
	  "",                                                      -- continue while hold
	  "reverser_1 = 0")   			                  					   -- switch back on release

	create_command("FlyWithLua/improvedboetca/rev2_25",			 -- command's name
	  "Reverser #2 25% while holding",					 -- description
	  "reverser_2 = 0.25",												-- set DataRef on first press
	  "",                                                      -- continue while hold
	  "reverser_2 = 0")
	create_command("FlyWithLua/improvedboetca/rev1_50",			 -- command's name
	  "Reverser #1 50% while holding",					 -- description
	  "reverser_1 = 0.5",												-- set DataRef on first press
	  "",                                                      -- continue while hold
	  "reverser_1 = 0")   			                  					   -- switch back on release

	create_command("FlyWithLua/improvedboetca/rev2_50",			 -- command's name
	  "Reverser #2 50% while holding",					 -- description
	  "reverser_2 = 0.5",												-- set DataRef on first press
	  "",                                                      -- continue while hold
	  "reverser_2 = 0")
	create_command("FlyWithLua/improvedboetca/rev1_100",			 -- command's name
	  "Reverser #1 100% while holding",					 -- description
	  "reverser_1 = 1.0",												-- set DataRef on first press
	  "",                                                      -- continue while hold
	  "reverser_1 = 0")   			                  					   -- switch back on release

	create_command("FlyWithLua/improvedboetca/rev2_100",			 -- command's name
	  "Reverser #2 100% while holding",					 -- description
	  "reverser_2 = 1.0",												-- set DataRef on first press
	  "",                                                      -- continue while hold
	  "reverser_2 = 0")   	  

-- Toliss Aircraft
elseif ((PLANE_ICAO == "A319") or (PLANE_ICAO == "A321") or (PLANE_ICAO == "A346")) and string.find(string.lower(AIRCRAFT_PATH), "toliss") then
	-- AirbusFBW/ALT100_1000
	knobRefs["alt"].pressRef = "AirbusFBW/PushAltitude"
	knobRefs["alt"].holdRef = "AirbusFBW/PullAltitude"
	knobRefs["alt2nd"].pressRef = "AirbusFBW/PushVSSel"
	knobRefs["alt2nd"].holdRef = "AirbusFBW/PullVSSel"
	knobRefs["hdg"].pressRef = "AirbusFBW/PushHDGSel"
	knobRefs["hdg"].holdRef = "AirbusFBW/PullHDGSel"
	knobRefs["spd"].pressRef = "AirbusFBW/PushSPDSel"
	knobRefs["spd"].holdRef = "AirbusFBW/PullSPDSel"
-- Inibuilds Aircraft
elseif (PLANE_ICAO == "A306") or (PLANE_ICAO == "A310") or (PLANE_ICAO == "A3ST")  then
	knobRefs["alt"].turnRef = "A300/MCDU/altitude_dial"
	knobRefs["hdg"].turnRef = "A300/MCDU/heading_dial"
	knobRefs["spd"].turnRef = "A300/MCDU/airspeed_dial"
	knobRefs["alt"].pressRef = "A300/MCUD/altitude_hold_engage"
	knobRefs["hdg"].pressRef = "A300/MCDU/heading_select"
	knobRefs["spd"].pressRef = "A300/MCDU/level_change"
-- Felis 742
elseif (PLANE_ICAO == "B742") then
	knobRefs["alt"].turnRef = "B742/AP_panel/altitude_set"
	knobRefs["hdg"].turnRef = "B742/AP_panel/heading_set"
	knobRefs["spd"].turnRef = "B742/AP_panel/AT_spd_set_rotary"
	knobRefs["alt"].pressRef = "B742/command/AP_ALT_HOLD"
	knobRefs["hdg"].pressRef = "FlyWithLua/b742/hdgsel"
	knobRefs["spd"].pressRef = "FlyWithLua/b742/pitchsel"
	dataref("bnav", "B742/AP_panel/AP_nav_mode_sel", "writable")
	dataref("bpitch", "B742/AP_panel/AP_pitch_mode_sel", "writable")
	create_command("FlyWithLua/b742/hdgsel",           -- command's name
		"HDG Select",                                        -- description
		"bnav = 1",                                  -- set DataRef on first press
		"",                                                     -- do nothing during hold
		"")   			                  					  -- do nothing on release
	create_command("FlyWithLua/b742/pitchsel",           -- command's name
		"IAS Select",                                        -- description
		"bpitch = 2",                                  -- set DataRef on first press
		"",                                                     -- do nothing during hold
		"")   			                  					  -- do nothing on release
-- FlightFactor 757 - FF do have there own commands for boeing tca
elseif (PLANE_ICAO == "B752") or (PLANE_ICAO == "B753") then
	knobRefs["alt"].turnRef = "757Avionics/ap/alt_act"
	knobRefs["hdg"].turnRef = "757Avionics/ap/hdg_act"
	knobRefs["spd"].turnRef = "757Avionics/ap/spd_act"
	knobRefs["alt"].pressRef = "1-sim/comm/AP/altHoldButton"
	knobRefs["hdg"].pressRef = "1-sim/command/AP/hdgConfButton_button"
	knobRefs["spd"].pressRef = "1-sim/comm/AP/flchButton"
-- Colimata Concorde
elseif (PLANE_ICAO == "CONC") then
	knobRefs["alt"].turnRef = "Colimata/CON_AP_sw_ALT_select_ft_i"
	knobRefs["hdg"].turnRef = "Colimata/CON_AP_sw_ap1_hdg_trk_DISPLAY_i"
	knobRefs["spd"].turnRef = "Colimata/CON_AP_sw_AT_knots_i"
	knobRefs["alt"].pressRef = "FlyWithLua/conc/altsel"
	knobRefs["hdg"].pressRef = "FlyWithLua/conc/hdgsel"
	knobRefs["spd"].pressRef = "FlyWithLua/conc/pitchsel"
	dataref("cnav", "Colimata/CON_AP_button_trk_hdg_i", "writable")
	dataref("cpitch", "Colimata/CON_AP_button_ias_hold_byap_i", "writable")
	dataref("calt", "Colimata/CON_AP_button_alt_hold_i", "writable")
	create_command("FlyWithLua/conc/hdgsel",           -- command's name
		"HDG Select",                                        -- description
		"cnav = 1 - cnav",                                  -- set DataRef on first press
		"",                                                     -- do nothing during hold
		"")   			                  					  -- do nothing on release
	create_command("FlyWithLua/conc/pitchsel",           -- command's name
		"IAS Select",                                        -- description
		"cpitch = 1 - cpitch",                                  -- set DataRef on first press
		"",                                                     -- do nothing during hold
		"")   			                  					  -- do nothing on release
	create_command("FlyWithLua/conc/altsel",           -- command's name
		"ALT Hold",                                        -- description
		"calt = 1 - calt",                                  -- set DataRef on first press
		"",                                                     -- do nothing during hold
		"")   			                  					  -- do nothing on release
	maxalt = 60001
-- Rotate MD80
elseif (PLANE_ICAO == "MD88") then

	knobRefs["hdg"].turnRef = "Rotate/md80/autopilot/hdg_sel_deg_pilot"
	knobRefs["spd"].turnRef = "Rotate/md80/autopilot/at_target_speed"
	knobRefs["alt"].pressRef = "Rotate/md80/autopilot/alt_hold_sel"
	knobRefs["hdg"].pressRef = "Rotate/md80/autopilot/hdg_sel_mode"
	knobRefs["spd"].pressRef = "Rotate/md80/autopilot/ias_mach_sel"
-- Rotate MD11
elseif (PLANE_ICAO == "MD11") then
	knobRefs["alt"].turnRef = "Rotate/aircraft/systems/gcp_alt_presel_ft"
	altrefmd11 = "Rotate/aircraft/systems/gcp_alt_sel_ft"
	knobRefs["hdg"].turnRef = "Rotate/aircraft/systems/gcp_hdg_presel_deg"
	knobRefs["spd"].turnRef = "Rotate/aircraft/systems/gcp_spd_presel_ias"
	knobRefs["alt"].pressRef = "Rotate/aircraft/controls_c/fgs_alt_mode_sel_up"
	knobRefs["hdg"].pressRef = "Rotate/aircraft/controls_c/fgs_hdg_mode_sel_dn"
	knobRefs["spd"].pressRef = "Rotate/aircraft/controls_c/fgs_spd_sel_mode_dn"
-- JustFlight Bae-146
elseif (PLANE_ICAO == "B461") or (PLANE_ICAO == "B462") or (PLANE_ICAO == "B463") then

	knobRefs["spd"].turnRef = "thranda/anim/ASIbug4_pilot"
	knobRefs["alt"].pressRef = "thranda/buttons/Button08"
	knobRefs["hdg"].pressRef = "thranda/buttons/Button15"
	knobRefs["spd"].pressRef = "thranda/buttons/Button16"
	maxalt = 35001
-- SSG E Jets
elseif (PLANE_ICAO == "E170") or (PLANE_ICAO == "E195") then
	knobRefs["alt"].turnRef = "ssg/B748/MCP/mcp_alt_target_act"
	knobRefs["hdg"].turnRef = "ssg/B748/MCP/mcp_heading_bug_act"
	knobRefs["spd"].turnRef = "ssg/B748/MCP/mcp_ias_mach_act"
	knobRefs["alt"].pressRef = "SSG/EJET/MCP/ALT_COMM8"
	knobRefs["hdg"].pressRef = "SSG/EJET/MCP/HDG_COMM"
	knobRefs["spd"].pressRef = "SSG/EJET/MCP/FLCH_COMM"
-- SSG B748
elseif (PLANE_ICAO == "B748") then
	knobRefs["alt"].turnRef = "ssg/B748/MCP/mcp_alt_target_act"
	knobRefs["hdg"].turnRef = "ssg/B748/MCP/mcp_heading_bug_act"
	knobRefs["spd"].turnRef = "ssg/B748/MCP/mcp_ias_mach_act"

-- Msparks B744
elseif (PLANE_ICAO == "B744") then
	knobRefs["alt"].turnRef = "laminar/B747/autopilot/heading/altitude_dial_ft"
	knobRefs["hdg"].turnRef = "laminar/B747/autopilot/heading/degrees"
	knobRefs["spd"].turnRef = "laminar/B747/autopilot/ias_dial_value"

-- Ixeg 733
elseif (PLANE_ICAO == "B733") then
	knobRefs["alt"].turnRef = "sim/cockpit2/autopilot/altitude_dial_ft"

-- FlyJSim B732
elseif (PLANE_ICAO == "B732") then
	knobRefs["alt"].turnRef = "sim/cockpit2/autopilot/altitude_dial_ft"

	knobRefs["alt"].pressRef = "FlyWithLua/b732/altsel"
	knobRefs["hdg"].pressRef = "FlyWithLua/b732/hdgsel"
	knobRefs["spd"].pressRef = "FlyWithLua/b732/pitchsel"
	dataref("bnav", "FJS/732/Autopilot/APHeadingSwitch", "read_only")
	dataref("bpitch", "FJS/732/Autopilot/APPitchSelector", "read_only")
	create_command("FlyWithLua/b732/hdgsel",           -- command's name
		"HDG Select",                                        -- description
		"fjshdg()",                                  -- set DataRef on first press
		"",                                                     -- do nothing during hold
		"")   			                  					  -- do nothing on release
	create_command("FlyWithLua/b732/pitchsel",           -- command's name
		"IAS Select",                                        -- description
		"fjsias()",                                  -- set DataRef on first press
		"",                                                     -- do nothing during hold
		"")   			                  					  -- do nothing on release
	create_command("FlyWithLua/b732/altsel",           -- command's name
		"ALT Hold",                                        -- description
		"fjsalt()",                                  -- set DataRef on first press
		"",                                                     -- do nothing during hold
		"")   			                  					  -- do nothing on release
	function fjsias()
	if bpitch == 0 then command_once("FJS/732/Autopilot/PitchSelectLeft") elseif bpitch == 1 then command_once("FJS/732/Autopilot/PitchSelectLeft") command_once("FJS/732/Autopilot/PitchSelectLeft") end end
	function fjsalt()
	if bpitch == 0 then command_once("FJS/732/Autopilot/PitchSelectRight") elseif bpitch == -1 then command_once("FJS/732/Autopilot/PitchSelectRight") command_once("FJS/732/Autopilot/PitchSelectRight") end end
	function fjshdg()
	if bnav == 1 then command_once("FJS/732/Autopilot/AP_HDG_DOWN") elseif bnav == 0 then command_once("FJS/732/Autopilot/AP_HDG_DOWN") command_once("FJS/732/Autopilot/AP_HDG_DOWN") end end
end


-- Here ends the dref defintion part

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
	if val >= maxalt then
	-- maxalt - 1 to be compatible with original script
		val = maxalt - 1
	end
	-- TODO: this has to be moved out of this function
	if PLANE_ICAO == "MD88" then			
		set("Rotate/md80/autopilot/alt_sel_ft",val/100)
	elseif PLANE_ICAO == "MD11" then
		set(altrefmd11,val)
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
