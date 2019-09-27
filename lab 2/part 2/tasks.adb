with Ada.Real_Time; use Ada.Real_Time;
with NXT.AVR;       use NXT.AVR;


package body Tasks is
  ----------------------------
  --  Background procedure  --
  ----------------------------
  procedure Background is
  begin
    loop
      null;
    end loop;
  end Background;

  -------------
  --  Event  --
  -------------
  protected body Event is
    entry Wait(event_id : out Integer) when Signalled is
    begin
      event_id := Current_event_id;
      Signalled := False;
    end Wait;

    procedure Signal(event_id : in Integer) is
    begin
      Current_event_id := event_id;
      Signalled := True;
    end Signal;
  end Event;

   -------------
   --  Tasks  --
   -------------

  task body MotorTask is
    Speed : constant PWM_Value := 100;
    Stop : constant PWM_Value := 0;

    Next_Time : Time := Clock;
  begin
    -- A task that waits for an interrupt and starts/stops the motors accordingly
    loop
      -- TODO: itt:
      -- how do we wait for 2 events?

      -- Event.wait(TouchOnEvent);
      -- Event.wait(TouchOffEvent);
      -- Event.wait(GroundEnteredEvent);
      -- Event.wait(GroundLeftEvent);


      -- Start the motors on button push
      Event.wait(TouchOnEvent);
      Set_Power(Motor_A, Speed, False);
      Forward(Motor_A);
      Set_Power(Motor_B, Speed, False);
      Forward(Motor_B);

      -- -- Stop the motors on buttonr release
      Event.wait(TouchOffEvent);
      Set_Power(Motor_A, Stop, False);
      Forward(Motor_A);
      Set_Power(Motor_B, Stop, False);
      Forward(Motor_B);

      -- 10 ms absolute delay
      Next_Time := Next_Time + Milliseconds(300);
      delay until Next_Time;
    end loop;
  end MotorTask;


  task body EventdispatcherTask is
    btn_pressed : Boolean := False;
    over_ground : Boolean := True;

    Next_Time : Time := Clock;
  begin
    -- task body starts here ---
    Put_Line ("Hello World!");

    loop
      -- TODO: In order for MotorcontrolTask to have priority over EventdispatcherTask, make sure to assign a lower priority to the latter.

      -- TODO: add absolute delay
      
      -- reset button termination
      if NXT.AVR.Button = Power_Button then
        Power_Down;
      end if;

      -- detect push sensor and create event
      if Pressed(Bumper) then
        if (not btn_pressed) then
          btn_pressed := True;
          Event.signal(TouchOnEvent);
        end if;
      else
        if (btn_pressed) then
          btn_pressed := False;
          Event.signal(TouchOffEvent);
        end if;
      end if;

      -- detect light sensor values and create event
      if (PhotoDetector.Light_Value > 20) then
        if (over_ground) then
          -- the idea is that too big of a light would mean the end of the table is reached
          -- so therefore, we left the safe ground
          Put_Line ("I see no more ground!");

          over_ground := False;
          Event.signal(GroundLeftEvent);
        end if;
      else
        if (not over_ground) then
          -- the car is now over safe grounds
          Put_Line ("I am over ground now!");

          over_ground := True;
          Event.signal(GroundEnteredEvent);
        end if;        
      end if;

      -- 10 ms absolute delay
      Next_Time := Next_Time + Milliseconds(300);
      delay until Next_Time;
    end loop;
  end EventdispatcherTask;



end Tasks;
