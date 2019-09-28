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

  -- TASKS
  task MotorTask is
    -- Define priority and mem alloc
    pragma Priority (System.Priority'First + 3);
    pragma Storage_Size(4096);
  end MotorTask;

  task EventdispatcherTask is
    -- Define priority and mem alloc
    pragma Priority (System.Priority'First + 2);
    pragma Storage_Size(4096);
  end EventdispatcherTask;

  private
  --  Define periods and times  --

  -- Push button events
  TouchOnEvent : Integer := 1;
  TouchOffEvent : Integer := 2;
  
  -- Ground events (related to light sensor)
  GroundEnteredEvent : Integer := 3;
  GroundLeftEvent : Integer := 4;


  --  Init sensors --
  -- [4] Light Sensor
  PhotoDetector : Light_Sensor := Make(Sensor_4, Floodlight_On => False);

  -- [1] Push/Touch sensor
  Bumper : Touch_Sensor (Sensor_1);


  -- EVENT definition
  protected Event is
    entry Wait(event_id : out Integer);
    procedure Signal(event_id : in Integer);
  private
    -- assign priority that is ceiling of the user tasks priorities --
    pragma Priority (System.Priority'First + 1);

    -- Event data declaration
    Current_event_id : Integer;
    -- This is flag for event signal
    Signalled : Boolean := False;
  end Event;

end Tasks;
