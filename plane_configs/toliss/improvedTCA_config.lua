-- this is the ToLiss Airbus mod config
-- Use this as starting point for your plane config file and save it as improvedTCA_config.lua in the base folder of your plane

-- Do not change the next line
local knobRefs = ...

-- datarefs table; secondary knob functions activated by long knob press
-- AirbusFBW/ALT100_1000
knobRefs["alt"].pressRef = "AirbusFBW/PushAltitude"
knobRefs["alt"].holdRef = "AirbusFBW/PullAltitude"
knobRefs["alt2nd"].pressRef = "AirbusFBW/PushVSSel"
knobRefs["alt2nd"].holdRef = "AirbusFBW/PullVSSel"
knobRefs["hdg"].pressRef = "AirbusFBW/PushHDGSel"
knobRefs["hdg"].holdRef = "AirbusFBW/PullHDGSel"
knobRefs["spd"].pressRef = "AirbusFBW/PushSPDSel"
knobRefs["spd"].holdRef = "AirbusFBW/PullSPDSel"