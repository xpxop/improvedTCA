-- Rotate MD80 cfg
-- Use this as starting point for your plane config file and save it as improvedTCA_config.lua in the base folder of your plane

-- Do not change the next line
local knobRefs = ...

-- datarefs table; secondary knob functions activated by long knob press
knobRefs["hdg"].turnRef = "Rotate/md80/autopilot/hdg_sel_deg_pilot"
knobRefs["spd"].turnRef = "Rotate/md80/autopilot/at_target_speed"
knobRefs["alt"].pressRef = "Rotate/md80/autopilot/alt_hold_sel"
knobRefs["hdg"].pressRef = "Rotate/md80/autopilot/hdg_sel_mode"
knobRefs["spd"].pressRef = "Rotate/md80/autopilot/ias_mach_sel"		                  					  -- do nothing on release
