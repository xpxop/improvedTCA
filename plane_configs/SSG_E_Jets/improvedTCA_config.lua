-- SSG E Jets cfg
-- Use this as starting point for your plane config file and save it as improvedTCA_config.lua in the base folder of your plane

-- Do not change the next line
local knobRefs = ...

-- datarefs table; secondary knob functions activated by long knob press

knobRefs["alt"].turnRef = "ssg/B748/MCP/mcp_alt_target_act"
knobRefs["hdg"].turnRef = "ssg/B748/MCP/mcp_heading_bug_act"
knobRefs["spd"].turnRef = "ssg/B748/MCP/mcp_ias_mach_act"
knobRefs["alt"].pressRef = "SSG/EJET/MCP/ALT_COMM8"
knobRefs["hdg"].pressRef = "SSG/EJET/MCP/HDG_COMM"
knobRefs["spd"].pressRef = "SSG/EJET/MCP/FLCH_COMM"