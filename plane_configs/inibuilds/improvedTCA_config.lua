-- Inibuilds Aircraft cfg
-- Use this as starting point for your plane config file and save it as improvedTCA_config.lua in the base folder of your plane

-- Do not change the next line
local knobRefs = ...

-- datarefs table; secondary knob functions activated by long knob press

knobRefs["alt"].turnRef = "A300/MCDU/altitude_dial"
knobRefs["hdg"].turnRef = "A300/MCDU/heading_dial"
knobRefs["spd"].turnRef = "A300/MCDU/airspeed_dial"
knobRefs["alt"].pressRef = "A300/MCUD/altitude_hold_engage"
knobRefs["hdg"].pressRef = "A300/MCDU/heading_select"
knobRefs["spd"].pressRef = "A300/MCDU/level_change"