-- FlightFactor 757 - FF do have there own commands for boeing tca cfg
-- Use this as starting point for your plane config file and save it as improvedTCA_config.lua in the base folder of your plane

-- Do not change the next line
local knobRefs = ...

-- datarefs table; secondary knob functions activated by long knob press

knobRefs["alt"].turnRef = "757Avionics/ap/alt_act"
knobRefs["hdg"].turnRef = "757Avionics/ap/hdg_act"
knobRefs["spd"].turnRef = "757Avionics/ap/spd_act"
knobRefs["alt"].pressRef = "1-sim/comm/AP/altHoldButton"
knobRefs["hdg"].pressRef = "1-sim/command/AP/hdgConfButton_button"
knobRefs["spd"].pressRef = "1-sim/comm/AP/flchButton"