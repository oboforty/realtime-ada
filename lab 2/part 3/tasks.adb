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
      -- Define a task "MotorcontrolTask" that "executes" the "driving command". 

      if (driving_command.duration > 0) then
        -- TODO: ITT: what is the driving period length?
        driving_command.duration := driving_command.duration - 1;

        -- if the motor still has time to work, then we set the speed
        Set_Power(Motor_A, driving_command.speed, False);
        Set_Power(Motor_B, driving_command.speed, False);
      else
        -- duration is zero/negative -> reset update_priority 
        driving_command.update_priority := PRIO_IDLE;

        -- and the motors
        Set_Power(Motor_A, 0, False);
        Set_Power(Motor_B, 0, False);
      end if;


      -- 50 ms absolute delay
      Next_Time := Next_Time + Milliseconds(50);
      delay until Next_Time;
    end loop;
  end MotorTask;


  task body ButtonpressTask is
    btn_pressed : Boolean := False;

    Next_Time : Time := Clock;
  begin
    -- task body starts here ---
    Put_Line ("Hello ButtonpressTask!");

    loop
      -- TODO: write a function change_driving_command with update_priority, speed and driving_duration
      --   as parameters that can be used by tasks to update the record.


      -- detect push sensor and create event
      if Pressed(Bumper) then
        if (not btn_pressed) then
          btn_pressed := True;
          -- Button down
          if (driving_command.update_priority <= PRIO_BUTTON) then
            -- write a new driving command

            -- move backwards for 1 second
            driving_command.duration := 1000;
            driving_command.speed := -100;

            driving_command.update_priority := PRIO_BUTTON;
          end if;
        end if;
      else
        if (btn_pressed) then
          btn_pressed := False;
          -- Button up

        end if;
      end if;


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
      -- TODO: Further, define a third task "DisplayTask" that outputs some useful information on the LCD

      
      -- reset button termination
      if NXT.AVR.Button = Power_Button then
        Put_Line ("Quitting program.");
        Power_Down;
      end if;

      -- 10 ms absolute delay
      Next_Time := Next_Time + Milliseconds(100);
      delay until Next_Time;
    end loop;
  end DisplayTask;



end Tasks;
