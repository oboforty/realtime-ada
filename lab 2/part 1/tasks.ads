with Ada.Real_Time;       use Ada.Real_Time;
with NXT.AVR;       use NXT.AVR;
with NXT;                 use NXT;
-- Add required sensor and actuator package --
with NXT.Display;   use NXT.Display;
with NXT.Last_Chance;
with NXT.Light_Sensors; use NXT.Light_Sensors;
with NXT.Light_Sensors.Ctors; use NXT.Light_Sensors.Ctors;
with System;


package Tasks is

  procedure Background;

  task HelloworldTask is
    -- define its priority higher than the main procedure --
    pragma Priority (System.Priority'First + 1);

    --  task memory allocation --
    pragma Storage_Size (4096);
  end HelloworldTask;

  private
  --  Define periods and times  --

  --  Define used sensor ports  --
  -- [3] Light Sensor
  PhotoDetector : Light_Sensor := Make(Sensor_3);

  --  Init sensors --

end Tasks;
