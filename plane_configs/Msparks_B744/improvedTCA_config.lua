-- Msparks B744 cfg
-- Use this as starting point for your plane config file and save it as improvedTCA_config.lua in the base folder of your plane

-- Do not change the next line
local knobRefs = ...

-- datarefs table; secondary knob functions activated by long knob press

knobRefs["alt"].turnRef = "laminar/B747/autopilot/heading/altitude_dial_ft"
knobRefs["hdg"].turnRef = "laminar/B747/autopilot/heading/degrees"
knobRefs["spd"].turnRef = "laminar/B747/autopilot/ias_dial_value"