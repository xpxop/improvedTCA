-- Colimata Concorde cfg
-- Use this as starting point for your plane config file and save it as improvedTCA_config.lua in the base folder of your plane

-- Do not change the next line
local knobRefs = ...

-- datarefs table; secondary knob functions activated by long knob press
knobRefs["alt"].turnRef = "Colimata/CON_AP_sw_ALT_select_ft_i"
knobRefs["hdg"].turnRef = "Colimata/CON_AP_sw_ap1_hdg_trk_DISPLAY_i"
knobRefs["spd"].turnRef = "Colimata/CON_AP_sw_AT_knots_i"
knobRefs["alt"].pressRef = "FlyWithLua/conc/altsel"
knobRefs["hdg"].pressRef = "FlyWithLua/conc/hdgsel"
knobRefs["spd"].pressRef = "FlyWithLua/conc/pitchsel"
knobRefs["alt"].maxalt = 60000
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
