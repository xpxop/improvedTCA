-- JustFlight Bae-146 cfg
-- Use this as starting point for your plane config file and save it as improvedTCA_config.lua in the base folder of your plane

-- Do not change the next line
local knobRefs = ...

-- datarefs table; secondary knob functions activated by long knob press

knobRefs["spd"].turnRef = "thranda/anim/ASIbug4_pilot"
knobRefs["alt"].pressRef = "thranda/buttons/Button08"
knobRefs["hdg"].pressRef = "thranda/buttons/Button15"
knobRefs["spd"].pressRef = "thranda/buttons/Button16"
knobRefs["alt"].maxalt = 35000