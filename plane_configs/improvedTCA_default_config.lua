-- this is the default "knob config"
-- Use this as starting point for your plane config file and save it as improvedTCA_config.lua in the base folder of your plane

-- Do not change the next line
local knobRefs = ...

-- datarefs table; secondary knob functions activated by long knob press
-- Here you can adjust
-- default SPD config
knobRefs["spd"].turnRef = "sim/cockpit/autopilot/airspeed" -- this is the dataref holding the value that will be changed
knobRefs["spd"].turnCommandOnce = false					   -- this bool can be used if value can only be changed via turnRefUP & turnRefDN button type data refs
knobRefs["spd"].turnRefUP = "" 	    					   -- button type data ref that increases value if commanded once
knobRefs["spd"].turnRefDN = ""                             -- button type data ref that decreases value if commanded once
knobRefs["spd"].turnCheckRef = ""                          -- a dataref (typically of 0 or 1 type) to be checked to allow modification via turnValueModifier value
knobRefs["spd"].turnValueModifier = nil                    -- value that is used to modifie value (example baro value is always saved in inHg -> so if hPa is displayed each increase by 1 needs to be modified to reflect repsective change in inHg
knobRefs["spd"].pressRef = "sim/autopilot/level_change"    -- button type data that gets fired when knob is briefly pressed
knobRefs["spd"].holdRef = ""							   -- button type data that gets fired when knob is longer pressed / held down
-- default HDG config
knobRefs["hdg"].turnRef = "sim/cockpit/autopilot/heading" 
knobRefs["hdg"].turnCommandOnce = false					   
knobRefs["hdg"].turnRefUP = "" 	    					   
knobRefs["hdg"].turnRefDN = ""                             
knobRefs["hdg"].turnCheckRef = ""                          
knobRefs["hdg"].turnValueModifier = nil                    
knobRefs["hdg"].pressRef = "sim/autopilot/heading"    
knobRefs["hdg"].holdRef = ""
-- default ALT config
knobRefs["alt"].turnRef = "sim/cockpit/autopilot/altitude" 
knobRefs["alt"].turnCommandOnce = false					   
knobRefs["alt"].turnRefUP = "" 	    					   
knobRefs["alt"].turnRefDN = ""                             
knobRefs["alt"].turnCheckRef = ""                          
knobRefs["alt"].turnValueModifier = nil                    
knobRefs["alt"].pressRef = "sim/autopilot/altitude_hold"    
knobRefs["alt"].holdRef = ""
knobRefs["alt"].maxalt = 50001 -- special for alt (and NEW) 
-- default SPD 2nd config, default use to turn baro knob
knobRefs["spd2nd"].turnRef = "" 
knobRefs["spd2nd"].turnCommandOnce = false					   
knobRefs["spd2nd"].turnRefUP = "" 	    					   
knobRefs["spd2nd"].turnRefDN = ""                             
knobRefs["spd2nd"].turnCheckRef = ""                          
knobRefs["spd2nd"].turnValueModifier = 2.9529980164712, -- hPa -> inHg for baro                    
knobRefs["spd2nd"].pressRef = ""    
knobRefs["spd2nd"].holdRef = ""
-- default HDG 2nd config, default use to turn CRS knob
knobRefs["hdg2nd"].turnRef = "" 
knobRefs["hdg2nd"].turnCommandOnce = false					   
knobRefs["hdg2nd"].turnRefUP = "" 	    					   
knobRefs["hdg2nd"].turnRefDN = ""                             
knobRefs["hdg2nd"].turnCheckRef = ""                          
knobRefs["hdg2nd"].turnValueModifier = nil                    
knobRefs["hdg2nd"].pressRef = ""    
knobRefs["hdg2nd"].holdRef = ""
-- default ALT 2nd config, default use to turn VS knob
knobRefs["alt2nd"].turnRef = "" 
knobRefs["alt2nd"].turnCommandOnce = false					   
knobRefs["alt2nd"].turnRefUP = "" 	    					   
knobRefs["alt2nd"].turnRefDN = ""                             
knobRefs["alt2nd"].turnCheckRef = ""                          
knobRefs["alt2nd"].turnValueModifier = nil                    
knobRefs["alt2nd"].pressRef = ""    
knobRefs["alt2nd"].holdRef = ""
