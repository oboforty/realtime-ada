with Ada.Real_Time;       use Ada.Real_Time;
with NXT.AVR;       use NXT.AVR;
with NXT;                 use NXT;
-- Add required sensor and actuator package --
with NXT.Display;   use NXT.Display;
with NXT.Last_Chance;
with NXT.Light_Sensors; use NXT.Light_Sensors;
with NXT.Light_Sensors.Ctors; use NXT.Light_Sensors.Ctors;
with NXT.Touch_Sensors;  use NXT.Touch_Sensors;
with NXT.Ultrasonic_Sensors;        use NXT.Ultrasonic_Sensors;
with NXT.Ultrasonic_Sensors.Ctors;  use NXT.Ultrasonic_Sensors.Ctors;
with System;


package Tasks is

  procedure Background;

  procedure UpPriority(newPriorit: Integer; newDuration: Integer; newSpeed: PWM_Value);
  -- TASKS
  task MotorTask is
    -- Define priority
    pragma Priority (System.Priority'First + 4);
    pragma Storage_Size(2048);
  end MotorTask;

  task ButtonpressTask is
    -- Define priority
    pragma Priority (System.Priority'First + 2);
    pragma Storage_Size(2048);
  end ButtonpressTask;

  task DistanceTask is
    -- Define priority
    pragma Priority (System.Priority'First + 3);
   pragma Storage_Size(2048);
  end DistanceTask;

  task DisplayTask is
    -- Define priority
    pragma Priority (System.Priority'First + 1);
    pragma Storage_Size(2048);
  end DisplayTask;


  -- Records
  type Driving_Command_Type is
    record
      duration: Integer;
      speed: PWM_Value;

      update_priority: Integer := 0;
    end record;

  driving_command: Driving_Command_Type;

  PRIO_IDLE: Integer := 1;
  PRIO_DISTANCE: Integer := 2;
  PRIO_BUTTON: Integer := 3;


  private

  --  Init sensors --
  -- [4] Light Sensor
  PhotoDetector : Light_Sensor := Make(Sensor_4, Floodlight_On => False);

  -- [1] Push/Touch sensor
  Bumper : Touch_Sensor (Sensor_1);

  -- [2] Ultrasonic
  Sonar : Ultrasonic_Sensor := Make (Sensor_2);

end Tasks;
