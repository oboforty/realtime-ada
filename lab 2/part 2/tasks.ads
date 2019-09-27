with Ada.Real_Time;       use Ada.Real_Time;
with NXT.AVR;       use NXT.AVR;
with NXT;                 use NXT;
-- Add required sensor and actuator package --
with NXT.Display;   use NXT.Display;
with NXT.Last_Chance;
with NXT.Light_Sensors; use NXT.Light_Sensors;
with NXT.Light_Sensors.Ctors; use NXT.Light_Sensors.Ctors;
with NXT.Touch_Sensors;  use NXT.Touch_Sensors;


package Tasks is

  procedure Background;

  private

  --  Define periods and times  --
  -- Push button events
  TouchOnEvent : Integer := 1;
  TouchOffEvent : Integer := 2;
  
  -- Ground events (related to light sensor)
  GroundEnteredEvent : Integer := 3;
  GroundLeftEvent : Integer := 4;


  -- EVENT definition
  protected Event is
    entry Wait(event_id : out Integer);
    procedure Signal(event_id : in Integer);
  private
    -- assign priority that is ceiling of the user tasks priorities --
    Current_event_id : Integer;     -- Event data declaration
    Signalled : Boolean := False;   -- This is flag for event signal
  end Event;


  -- TASKS
  task MotorTask is
    -- Define priority
    pragma Storage_Size(4096);
  end MotorTask;

  task EventdispatcherTask is
    -- Define priority
    pragma Storage_Size(4096);
  end EventdispatcherTask;

  task HelloworldTask is
    -- define its priority higher than the main procedure --
    pragma Storage_Size (4096); --  task memory allocation --
  end HelloworldTask;

  --  Define used sensor ports  --
  -- [4] Light Sensor
  PhotoDetector : Light_Sensor := Make(Sensor_4, Floodlight_On => False);

  -- [1] Push/Touch sensor
  Bumper : Touch_Sensor (Sensor_1);

  --  Init sensors --

end Tasks;
