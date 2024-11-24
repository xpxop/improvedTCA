-- Rotate MD11 cfg
-- Use this as starting point for your plane config file and save it as improvedTCA_config.lua in the base folder of your plane

-- Do not change the next line
local knobRefs = ...

-- datarefs table; secondary knob functions activated by long knob press

knobRefs["alt"].turnRef = "Rotate/aircraft/systems/gcp_alt_presel_ft"
knobRefs["hdg"].turnRef = "Rotate/aircraft/systems/gcp_hdg_presel_deg"
knobRefs["spd"].turnRef = "Rotate/aircraft/systems/gcp_spd_presel_ias"
knobRefs["alt"].pressRef = "Rotate/aircraft/controls_c/fgs_alt_mode_sel_up"
knobRefs["hdg"].pressRef = "Rotate/aircraft/controls_c/fgs_hdg_mode_sel_dn"
knobRefs["spd"].pressRef = "Rotate/aircraft/controls_c/fgs_spd_sel_mode_dn"
