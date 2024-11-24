-- Felis 742 cfg
-- Use this as starting point for your plane config file and save it as improvedTCA_config.lua in the base folder of your plane

-- Do not change the next line
local knobRefs = ...

-- datarefs table; secondary knob functions activated by long knob press

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