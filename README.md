# improvedTCA
Improved Thrustmaster Boeing TCA Autopilot Control Integration LUA Script for X-plane by Seb

Based on the "[Thrustmaster Boeing TCA Autopilot Control Integration Script for X-plane by Andrew Spink (theegg52)](https://forums.x-plane.org/index.php?/files/file/79047-flywithlua-script-for-thrustmaster-boeing-tca-quadrant-autopilot/)"

# Changelog

## New in v1.0.2-beta

* Hopefully better smoothing of the knob

## New in v1.0.1
* Thanks to suggestions form [BorisEagle](https://github.com/BorisEagle) for the zibomod you can now also assign different reverser levels (idle, 25%, 50%, 100%) to the two reverser knobs - just assign the commands "Reverser #1 (#2) xxx while holding" to the respective buttons.

* The "knob press" function has some nice new features:
  * short / click like press -> behaves as in v1.0.0
  * slightly longer press -> a different command can be assigned (in the script - not yet done)
  * a long press -> switches knob to secondary mode: Based on the mode selection (SPD, HDG, ALT) the knob now modifies (BARO, CRS, VS) and short click fires different commands. So far this is only implemented for the zibomod. After 3 seconds of inactivity (no pressing or turning the knob) the knob switches back to primary mode, switching to a different mode via "the ring thing" also always goes to primary mode. The times for what is slighty longer and long press, aswell as the inactivity timeout can be configured in the script (see under Advanced)


# Install

Download & copy [lua/improvedTCA.lua](https://github.com/xpxop/improvedTCA/blob/main/lua/improvedTCA.lua) to YOUR_XPLANE_FOLDER\Resources\plugins\FlyWithLua\Scripts

# Setup

## Simple

Assign buttons in X-plane to script commands as shown here:

![button assignment screenshot][btnasgn1]
![button assignment screenshot][btnasgn2]

[btnasgn1]: https://github.com/xpxop/improvedTCA/blob/main/imgs/assign_buttons1.JPG "button assignment screenshot 1"
[btnasgn2]: https://github.com/xpxop/improvedTCA/blob/main/imgs/assign_buttons2.JPG "button assignment screenshot 2"

### New in v1.0.1
* Thanks to suggestions form [BorisEagle](https://github.com/BorisEagle) for the zibomod you can now also assign different reverser levels (idle, 25%, 50%, 100%) to the two reverser knobs - just assign the commands "Reverser #1 (#2) xxx while holding" to the respective buttons.

* The "knob press" function has some nice new features:
  * short / click like press -> behaves as in v1.0.0
  * slightly longer press -> a different command can be assigned (in the script - not yet done)
  * a long press -> switches knob to secondary mode: Based on the mode selection (SPD, HDG, ALT) the knob now modifies (BARO, CRS, VS) and short click fires different commands. So far this is only implemented for the zibomod. After 3 seconds of inactivity (no pressing or turning the knob) the knob switches back to primary mode, switching to a different mode via "the ring thing" also always goes to primary mode. The times for what is slighty longer and long press, aswell as the inactivity timeout can be configured in the script (see under Advanced)

## Advanced

### Increments for normal/fast mode
**NEW in v1.0.1**
Change these variables (only the values not the names) to adjust the increments/decrements per "click" of the knob:

```lua
increments = {
	spd = {
		normal = 1,
		fast = 2,		
	},
	hdg = {
		normal = 1,
		fast = 2,		
	},
	alt = {
		normal = 100,
		fast = 1000,		
	},
	spd2nd = {
		normal = 0.01,
		fast = 0.1,		
	},
	hdg2nd = {
		normal = 1,
		fast = 2,		
	},
	alt2nd = {
		normal = 50,
		fast = 100,		
	}
}
```

normal for normal / slow knob turn speed
fast for fast knob turn speed

Remark: "Fast" is detected via the "button hold" that the knob sends at higher turn speeds

### Knob press behavior
**NEW in v1.0.1**

Change

```lua
local minSelHoldTime = 0.5
local minSelLongHoldTime = 2
local secondaryModeTimeOut = 3
```

to values (seconds) that work for you.

minSELHoldTime -> after this amount of seconds holding down the knob button (sel) the hold action will be fired (not used yet)

minSelLongHoldTime -> long hold time in seconds -> after this time the knob switches to the secondary mode

secondaryModeTimeOut -> if you do not press the knob or turn the knob for this amount of seconds the knob defaults back to primary mode

## Adjust the fast / normal speed responsiveness

**NEW/CHANGED in Experimental**

This new approach to get a smoother knob uses floating average. The knob click to click time (DT) gets checked against 
the floating average of n = lengthTickValues (default 3). Ff DT is smaller than floating average - maxDeviationSecs - 
this click gets ignored. Abrupt direction changes are also ignored if direction changes happen in under directionChangeDtThresholdSecs

```lua
local maxDeviationSecs = 0.1 -- increase this value to make the knob more responsive (and probably more bouncy)
local minHoldTimeFastTicksSecs = 0.1 -- increase this value to make the knob wait longer before switching to fast turning mode
local minHoldTickDtSecs = 0.05 -- decrease this value to get faster fast tick speed
local directionChangeDtThresholdSecs = 0.5 -- increase this value to make knob less sensitive to sudden direction changes
local lengthTickValues = 3 -- increase this value to increase the number of values for floating average -> larger values mean slower & smoother, 1 turns that off, must be >= 1
```

Remark: minHoldCounterNormTicks has to be smaller than minHoldCounterFastTicks 

# Troubleshooting

* Cannot find the _improvedboetca_ section under FlyWithLua in XPlane to assign functions to buttons!
  * Try to reload all lua scripts via the Plugins->FlyWithLUA menu while a plane is loaded
