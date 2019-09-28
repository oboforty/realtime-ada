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
  --  Tasks  --
  -------------
  task body MotorTask is
    Speed : constant PWM_Value := 100;
    Stop : constant PWM_Value := 0;

    Next_Time : Time := Clock;
  begin
    Put_Line ("Hello MotorTask!");

    loop

      -- TODO: ITT

      -- 10 ms absolute delay
      Next_Time := Next_Time + Milliseconds(300);
      delay until Next_Time;
    end loop;
  end MotorTask;


  task body ButtonpressTask is

    Next_Time : Time := Clock;
  begin
    -- task body starts here ---
    Put_Line ("Hello ButtonpressTask!");

    loop
      -- TODO: ITT

      -- 10 ms absolute delay
      Next_Time := Next_Time + Milliseconds(300);
      delay until Next_Time;
    end loop;
  end ButtonpressTask;


  task body DisplayTask is

    Next_Time : Time := Clock;
  begin
    -- task body starts here ---
    Put_Line ("Hello DisplayTask!");

    loop
      -- TODO: ITT

      -- 10 ms absolute delay
      Next_Time := Next_Time + Milliseconds(300);
      delay until Next_Time;
    end loop;
  end DisplayTask;



end Tasks;
