with Ada.Real_Time;       use Ada.Real_Time;
with NXT.AVR;       use NXT.AVR;
with NXT;                 use NXT;
-- Add required sensor and actuator package --
with NXT.Display;   use NXT.Display;
with NXT.Last_Chance;
with NXT.Light_Sensors; use NXT.Light_Sensors;
with NXT.Light_Sensors.Ctors; use NXT.Light_Sensors.Ctors;


package Tasks is

  procedure Background;

  private

  --  Define periods and times  --

  --  Define used sensor ports  --
  -- [4] Light Sensor
  PhotoDetector : Light_Sensor := Make(Sensor_4, Floodlight_On => False);

  --  Init sensors --

end Tasks;
