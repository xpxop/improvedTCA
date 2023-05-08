# improvedTCA
Improved Thrustmaster Boeing TCA Autopilot Control Integration LUA Script for X-plane by Seb

Based on the "[Thrustmaster Boeing TCA Autopilot Control Integration Script for X-plane by Andrew Spink (theegg52)](https://forums.x-plane.org/index.php?/files/file/79047-flywithlua-script-for-thrustmaster-boeing-tca-quadrant-autopilot/)"

# Install

Download & copy [lua/improvedTCA.lua](https://github.com/xpxop/improvedTCA/blob/main/lua/improvedTCA.lua) to YOUR_XPLANE_FOLDER\Resources\plugins\FlyWithLua\Scripts

# Setup

## Simple

Assign buttons in X-plane to script commands as shown here:

![button assignment screenshot][btnasgn1]
![button assignment screenshot][btnasgn2]

[btnasgn1]: https://github.com/xpxop/improvedTCA/blob/main/imgs/assign_buttons1.JPG "button assignment screenshot 1"
[btnasgn2]: https://github.com/xpxop/improvedTCA/blob/main/imgs/assign_buttons2.JPG "button assignment screenshot 2"

## Advanced

Change these variables to adjust the increments/decrements per "click" of the knob:

local normIncr = {1, 1, 100}
local fastIncr = {10, 10, 1000}

Position inside {} defines the values that gets changed by one click:
1 = SPD, 2 = HDG, 3 = ALT -> {SPD, HDG, ALT}

normIncr -> for normal / slow knob turn speed
fastIncr -> for fast knob turn speed

Remark: "Fast" is detected via the "button hold" that the knob sends at higher turn speeds

## Adjust the fast / normal speed responsiveness

Adjusting these values allows you to play with the responsiveness of the knob.

minFastTickDT & minNormTickDT values [in s] try to prevent / limit the bouncy behavior of the knob - lower values result in quicker response but also much more aggressive over-turning / "bouncyness"

minHoldCounterNormTicks & minHoldCounterFastTicks values [in counted hold-button-down ticks] are thresholds to decide wether you are really turning fast or if the knob is just a bit bouncy. If the counter is between Norm and Fast just fire a normal speed change if value >= Fast fire a fast value change. So the lower you set the Fast value the earlier the script fires fast turn value changes. If you set them to low the knob gets sensitive again for bouncing... 

local minFastTickDT = 0.01
local minNormTickDT = 0.05
local minHoldCounterNormTicks = 6
local minHoldCounterFastTicks = 18

Remark: minHoldCounterNormTicks has to be smaller than minHoldCounterFastTicks 
