-- FlyJSim B732 cfg
-- Use this as starting point for your plane config file and save it as improvedTCA_config.lua in the base folder of your plane

-- Do not change the next line
local knobRefs = ...

-- datarefs table; secondary knob functions activated by long knob press

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