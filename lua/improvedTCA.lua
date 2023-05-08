-- Improved Thrustmaster Boeing TCA Autopilot Control Integration Script for X-plane by Seb
-- Based on the "Thrustmaster Boeing TCA Autopilot Control Integration Script for X-plane by Andrew Spink (theegg52)"

modeset = 1
dataref("TIME", "sim/time/total_running_time_sec")

-- Here you can define the changes for normal (normIncr) and fast (fastIncr) knob turn speed
-- Fast is detected via the button hold that the knob sends at higher turn speeds
-- store increments in array corresponding to mode 1 = SPD, 2 = HDG, 3 = ALT -> {SPD, HDG, ALT}

local normIncr = {1, 1, 100}
local fastIncr = {10, 10, 1000}

-- These are empiric values to modulate the fast / slow turn speed detection sensitivity / response a bit
-- Feel free to play around with these but don't expect too much :) the rotary / knob is quite "bouncy"

local minFastTickDT = 0.01
local minNormTickDT = 0.05
local minHoldCounterNormTicks = 6
local minHoldCounterFastTicks = 18

-- Don't change these - just initialized to 0
local lastTickTime = 0
local holdCounter = 0

-- This part is unchanged from original script and contains the dataref definitions and plane related functions:
-- Thrustmaster Boeing TCA Autopilot Control Integration Script for X-plane by Andrew Spink (theegg52)
-- Thanks to x-plane.org forum user adamo_cze whos encoder smoothing and acceleration scripts ive integrated to provide those functions.

-- possible to replace the plane stuff here from original script in case some more are added

local altref
local hdgref
local spdref
local altcom
local hdgcom
local spdcom
local maxalt = 50001



if (PLANE_ICAO == "B738" and string.find(AIRCRAFT_PATH, "Laminar")) then
	altref = "sim/cockpit/autopilot/altitude"
	hdgref = "sim/cockpit/autopilot/heading"
	spdref = "sim/cockpit/autopilot/airspeed"
	altcom = "sim/autopilot/altitude_hold"
	hdgcom = "sim/autopilot/heading"
	spdcom = "sim/autopilot/level_change"
-- Zibo Mod & Level Up 73x
	elseif(PLANE_ICAO == "B736") or (PLANE_ICAO == "B737") or (PLANE_ICAO == "B738" and string.find(AIRCRAFT_PATH, "737NG")) or (PLANE_ICAO == "B738" and string.find(AIRCRAFT_PATH, "800X")) or (PLANE_ICAO == "B739") then
	altref = "laminar/B738/autopilot/mcp_alt_dial"
	hdgref = "laminar/B738/autopilot/mcp_hdg_dial"
	spdref = "laminar/B738/autopilot/mcp_speed_dial_kts_mach"
	altcom = "laminar/B738/autopilot/alt_hld_press"
	hdgcom = "laminar/B738/autopilot/hdg_sel_press"
	spdcom = "laminar/B738/autopilot/lvl_chg_press"
	dataref("thrrev1", "sim/cockpit2/engine/actuators/prop_mode", "writable", 0)
	dataref("thrrev2", "sim/cockpit2/engine/actuators/prop_mode", "writable", 1)
-- Toliss Aircraft
	elseif (PLANE_ICAO == "A319") or (PLANE_ICAO == "A321") or (PLANE_ICAO == "A346")  then
	altref = "sim/cockpit/autopilot/altitude"
	hdgref = "sim/cockpit/autopilot/heading"
	spdref = "sim/cockpit/autopilot/airspeed"
	altcom = "AirbusFBW/PushVSSel"
	hdgcom = "AirbusFBW/PullHDGSel"
	spdcom = "AirbusFBW/PullAltitude"
-- Inibuilds Aircraft
	elseif (PLANE_ICAO == "A306") or (PLANE_ICAO == "A310") or (PLANE_ICAO == "A3ST")  then
	altref = "A300/MCDU/altitude_dial"
	hdgref = "A300/MCDU/heading_dial"
	spdref = "A300/MCDU/airspeed_dial"
	altcom = "A300/MCUD/altitude_hold_engage"
	hdgcom = "A300/MCDU/heading_select"
	spdcom = "A300/MCDU/level_change"
-- Felis 742
	elseif (PLANE_ICAO == "B742") then
	altref = "B742/AP_panel/altitude_set"
	hdgref = "B742/AP_panel/heading_set"
	spdref = "B742/AP_panel/AT_spd_set_rotary"
	altcom = "B742/command/AP_ALT_HOLD"
	hdgcom = "FlyWithLua/b742/hdgsel"
	spdcom = "FlyWithLua/b742/pitchsel"
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
	altref = "757Avionics/ap/alt_act"
	hdgref = "757Avionics/ap/hdg_act"
	spdref = "757Avionics/ap/spd_act"
	altcom = "1-sim/comm/AP/altHoldButton"
	hdgcom = "1-sim/command/AP/hdgConfButton_button"
	spdcom = "1-sim/comm/AP/flchButton"
-- Colimata Concorde
	elseif (PLANE_ICAO == "CONC") then
	altref = "Colimata/CON_AP_sw_ALT_select_ft_i"
	hdgref = "Colimata/CON_AP_sw_ap1_hdg_trk_DISPLAY_i"
	spdref = "Colimata/CON_AP_sw_AT_knots_i"
	altcom = "FlyWithLua/conc/altsel"
	hdgcom = "FlyWithLua/conc/hdgsel"
	spdcom = "FlyWithLua/conc/pitchsel"
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
	altref = "sim/cockpit/autopilot/altitude"
	hdgref = "Rotate/md80/autopilot/hdg_sel_deg_pilot"
	spdref = "Rotate/md80/autopilot/at_target_speed"
	altcom = "Rotate/md80/autopilot/alt_hold_sel"
	hdgcom = "Rotate/md80/autopilot/hdg_sel_mode"
	spdcom = "Rotate/md80/autopilot/ias_mach_sel"
-- Rotate MD11
	elseif (PLANE_ICAO == "MD11") then
	altref = "Rotate/aircraft/systems/gcp_alt_presel_ft"
	altrefmd11 = "Rotate/aircraft/systems/gcp_alt_sel_ft"
	hdgref = "Rotate/aircraft/systems/gcp_hdg_presel_deg"
	spdref = "Rotate/aircraft/systems/gcp_spd_presel_ias"
	altcom = "Rotate/aircraft/controls_c/fgs_alt_mode_sel_up"
	hdgcom = "Rotate/aircraft/controls_c/fgs_hdg_mode_sel_dn"
	spdcom = "Rotate/aircraft/controls_c/fgs_spd_sel_mode_dn"
-- JustFlight Bae-146
	elseif (PLANE_ICAO == "B461") or (PLANE_ICAO == "B462") or (PLANE_ICAO == "B463") then
	altref = "sim/cockpit/autopilot/altitude"
	hdgref = "sim/cockpit/autopilot/heading"
	spdref = "thranda/anim/ASIbug4_pilot"
	altcom = "thranda/buttons/Button08"
	hdgcom = "thranda/buttons/Button15"
	spdcom = "thranda/buttons/Button16"
	maxalt = 35001
-- SSG E Jets
	elseif (PLANE_ICAO == "E170") or (PLANE_ICAO == "E195") then
	altref = "ssg/B748/MCP/mcp_alt_target_act"
	hdgref = "ssg/B748/MCP/mcp_heading_bug_act"
	spdref = "ssg/B748/MCP/mcp_ias_mach_act"
	altcom = "SSG/EJET/MCP/ALT_COMM8"
	hdgcom = "SSG/EJET/MCP/HDG_COMM"
	spdcom = "SSG/EJET/MCP/FLCH_COMM"
-- SSG B748
	elseif (PLANE_ICAO == "B748") then
	altref = "ssg/B748/MCP/mcp_alt_target_act"
	hdgref = "ssg/B748/MCP/mcp_heading_bug_act"
	spdref = "ssg/B748/MCP/mcp_ias_mach_act"
	altcom = "sim/autopilot/altitude_hold"
	hdgcom = "sim/autopilot/heading"
	spdcom = "sim/autopilot/level_change"
-- Msparks B744
	elseif (PLANE_ICAO == "B744") then
	altref = "laminar/B747/autopilot/heading/altitude_dial_ft"
	hdgref = "laminar/B747/autopilot/heading/degrees"
	spdref = "laminar/B747/autopilot/ias_dial_value"
	altcom = "sim/autopilot/altitude_hold"
	hdgcom = "sim/autopilot/heading"
	spdcom = "sim/autopilot/level_change"
-- Ixeg 733
	elseif (PLANE_ICAO == "B733") then
	altref = "sim/cockpit2/autopilot/altitude_dial_ft"
	hdgref = "sim/cockpit/autopilot/heading"
	spdref = "sim/cockpit/autopilot/airspeed"
	altcom = "sim/autopilot/altitude_hold"
	hdgcom = "sim/autopilot/heading"
	spdcom = "sim/autopilot/level_change"
-- FlyJSim B732
	elseif (PLANE_ICAO == "B732") then
	altref = "sim/cockpit2/autopilot/altitude_dial_ft"
	hdgref = "sim/cockpit/autopilot/heading"
	spdref = "sim/cockpit/autopilot/airspeed"
	altcom = "FlyWithLua/b732/altsel"
	hdgcom = "FlyWithLua/b732/hdgsel"
	spdcom = "FlyWithLua/b732/pitchsel"
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
	
	else
-- Default Datarefs/Commands
	altref = "sim/cockpit/autopilot/altitude"
	hdgref = "sim/cockpit/autopilot/heading"
	spdref = "sim/cockpit/autopilot/airspeed"
	altcom = "sim/autopilot/altitude_hold"
	hdgcom = "sim/autopilot/heading"
	spdcom = "sim/autopilot/level_change"
	end


-- Here ends the unchanged part from original script

local targetRefs = {spdref, hdgref, altref}
local targetComs = {spdcom, hdgcom, altcom}

-- does all the value changes
function changeValue(mode, direction, fastMode)
	-- Special case CL60 - untested
	if (PLANE_ICAO == "CL60") then
		if mode == 1 then
			-- SPD
			if direction > 0 then
				command_once("sim/autopilot/airspeed_up")
			else
				command_once("sim/autopilot/airspeed_down")
			end				
		elseif mode == 2 then
			-- HDG
			if direction > 0 then
				command_once("sim/autopilot/heading_up")
			else
				command_once("sim/autopilot/heading_down")
			end	
		else
			-- ALT
			if direction > 0 then
				command_once("sim/autopilot/altitude_up")
			else
				command_once("sim/autopilot/altitude_down")
			end	
		end
	else		
		local drefval
		local targetdref = targetRefs[mode]
		local valueChange
		
		if fastMode == true then
			valueChange = fastIncr[mode]
		else
			valueChange = normIncr[mode]
		end
		
		drefval = get(targetdref) + direction * valueChange
		
		if mode == 2 then
		-- HDG mode
			drefval = drefval % 360
		end
		if mode == 3 then
		-- ALT mode
			drefval = math.ceil(drefval/100)*100
			if drefval >= maxalt then
			-- maxalt - 1 to be compatible with original script
				drefval = maxalt - 1
			end
			if PLANE_ICAO == "MD88" then			
				set("Rotate/md80/autopilot/alt_sel_ft",drefval/100)
			elseif PLANE_ICAO == "MD11" then
				set(altrefmd11,drefval)
			end
		end	
		
		set(targetdref, drefval)
	end
end


-- wrapper for normal speed turns
function normalTurn(direction)
	if (TIME - lastTickTime) >= minNormTickDT then
		changeValue(modeset, direction, false)
		lastTickTime = TIME
	end	
end

-- wrapper for fast speed turns based on the "button hold" status without release at high turn speeds of the TCA knob
function fastTurnStart(direction)
	holdCounter = holdCounter + 1
	if (TIME - lastTickTime) >= minFastTickDT then
		if (holdCounter >= minHoldCounterNormTicks and holdCounter < minHoldCounterFastTicks) then
			changeValue(modeset, direction, false)		    
			lastTickTime = TIME
		elseif holdCounter >= minHoldCounterFastTicks then
			changeValue(modeset, direction, true)			
			lastTickTime = TIME
		end
	end
end


function fastTurnStop()
	holdCounter = 0
end


function modesel()
	command_begin(targetComs[modeset])
end

function modesel1()
	command_end(targetComs[modeset])
end


function checkholdset(mode)
	if mode ~= modeset then
		modeset = mode
	end
end


create_command("FlyWithLua/improvedboetca/turnincr",           -- command's name
  "Value Increase",                                        -- description
  "normalTurn(1)",                                  -- set DataRef on first press
  "fastTurnStart(1)",                                                     -- do nothing during hold
  "fastTurnStop()")   			                  					  -- do nothing on release
  
create_command("FlyWithLua/improvedboetca/turndecr",           -- command's name
  "Value Decrease",                                        -- description
  "normalTurn(-1)",                                  -- set DataRef on first press
  "fastTurnStart(-1)",                                                     -- do nothing during hold
  "fastTurnStop()")   			                  					  -- do nothing on release
  
create_command("FlyWithLua/improvedboetca/modesel",           -- command's name
  "Mode Selector",                                        -- description
  "modesel()",                                  -- set DataRef on first press
  "",                                                     -- do nothing during hold
  "modesel1()")   			                  					  -- do nothing on release
  
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

create_command("FlyWithLua/boetca/rev1on",			 -- command's name
  "Reverser #1 on while holding",					 -- description
  "thrrev1 = 3",												-- set DataRef on first press
  "thrrev1 = 3",                                                      -- continue while hold
  "thrrev1 = 1")   			                  					   -- switch back on release

create_command("FlyWithLua/boetca/rev2on",			 -- command's name
  "Reverser #2 on while holding",					 -- description
  "thrrev2 = 3",												-- set DataRef on first press
  "thrrev2 = 3",                                                     -- continue while hold
  "thrrev2 = 1")   			                  					  -- switch back on release
