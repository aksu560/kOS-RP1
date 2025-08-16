lock throttle to 1.
lock steering to up - R(0, 5, 180).
declare e to 6.
wait 2.
print("Launch").
stage.
wait 2.
stage.
wait until altitude > 18000.
print("Rotation").
lock steering to prograde - R(0,0, 90).
wait until ship:resources[e]:amount < 100.
stage.
wait 2.
stage.