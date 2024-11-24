-- this is the Zibo mod config
-- Use this as starting point for your plane config file and save it as improvedTCA_config.lua in the base folder of your plane

-- Do not change the next line
local knobRefs = ...

-- datarefs table; secondary knob functions activated by long knob press
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