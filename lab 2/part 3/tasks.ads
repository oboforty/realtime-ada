with Ada.Real_Time;       use Ada.Real_Time;
with NXT.AVR;       use NXT.AVR;
with NXT;                 use NXT;
-- Add required sensor and actuator package --
with NXT.Display;   use NXT.Display;
with NXT.Last_Chance;
with NXT.Light_Sensors; use NXT.Light_Sensors;
with NXT.Light_Sensors.Ctors; use NXT.Light_Sensors.Ctors;
with NXT.Touch_Sensors;  use NXT.Touch_Sensors;
with System;


package Tasks is

  procedure Background;

  private

  -- TASKS
  task MotorTask is
    -- Define priority
    pragma Storage_Size(4096);
  end MotorTask;

  task ButtonpressTask is
    -- Define priority
    pragma Storage_Size(4096);
  end ButtonpressTask;

  task DisplayTask is
    -- Define priority
    pragma Storage_Size(4096);
  end DisplayTask;

  --  Define used sensor ports  --
  -- [4] Light Sensor
  PhotoDetector : Light_Sensor := Make(Sensor_4, Floodlight_On => False);

  -- [1] Push/Touch sensor
  Bumper : Touch_Sensor (Sensor_1);

  --  Init sensors --

end Tasks;
