-- SSG B748 cfg
-- Use this as starting point for your plane config file and save it as improvedTCA_config.lua in the base folder of your plane

-- Do not change the next line
local knobRefs = ...

-- datarefs table; secondary knob functions activated by long knob press

knobRefs["alt"].turnRef = "ssg/B748/MCP/mcp_alt_target_act"
knobRefs["hdg"].turnRef = "ssg/B748/MCP/mcp_heading_bug_act"
knobRefs["spd"].turnRef = "ssg/B748/MCP/mcp_ias_mach_act"