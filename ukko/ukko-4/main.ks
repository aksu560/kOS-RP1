lock throttle to 1.
lock steering to up - R(0, 5, 180).
wait 2.
print("Launch").
stage.
wait until ship:thrust > 300.
stage.
wait until altitude > 18000.
print("Rotation").
lock steering to prograde - R(0,45, 180).