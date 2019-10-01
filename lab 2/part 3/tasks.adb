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

  procedure UpPriority(newPriorit: Integer; newDuration: Integer; newSpeed: PWM_Value) is
  begin
    driving_command.update_priority := newPriorit;
    driving_command.duration := newDuration;
    driving_command.speed := newSpeed;
  end UpPriority;


  -------------
  --  Tasks  --
  -------------
  task body MotorTask is
    Speed : constant PWM_Value := 100;
    Stop : constant PWM_Value := 0;

    Next_Time : Time := Clock;
  begin

    loop
      -- Define a task "MotorcontrolTask" that "executes" the "driving command". 
      -- 50 ms delay needs 20 cycles to make 1000 ms

      if (driving_command.duration > 0) then
        -- TODO: ITT: what is the driving period length?
        driving_command.duration := driving_command.duration - 20;

        -- if the motor still has time to work, then we set the speed
        driving_command.update_priority := PRIO_IDLE;
      else
        -- duration is zero/negative -> reset update_priority 
        driving_command.update_priority := PRIO_IDLE;

        -- and the motors stop
        driving_command.speed := 0;
      end if;

      Set_Power(Motor_A, driving_command.speed, False);
      Set_Power(Motor_B, driving_command.speed, False);

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

    -- chill a bit
    delay until Clock + Milliseconds(100);

    loop
      -- TODO: write a function change_driving_command with update_priority, speed and driving_duration
      --   as parameters that can be used by tasks to update the record.


      -- detect push sensor and create event
      if Pressed(Bumper) then
        if (not btn_pressed) then

          btn_pressed := True;

          -- -- Button down
          if (driving_command.update_priority <= PRIO_BUTTON) then
            -- write a new driving command

            -- move backwards for 1 second
            

            --driving_command.update_priority := PRIO_BUTTON;
            UpPriority(PRIO_BUTTON,10000,-50);
          end if;
        end if;
      else
        if (btn_pressed) then
          btn_pressed := False;
          -- Button up

        end if;
      end if;


      -- 10 ms absolute delay
      Next_Time := Next_Time + Milliseconds(10);
      delay until Next_Time;
    end loop;
  end ButtonpressTask;



  task body DistanceTask is
    too_close : Boolean := False;

    --Detected     : Distances (1 .. 256);
    --Num_Detected : Natural;

    Distance : Natural;

    Next_Time : Time := Clock;
  begin
    -- task body starts here ---  
    -- chill a bit
    delay until Clock + Milliseconds(100);

    Sonar.Set_Mode (Ping);

    loop
      Sonar.Ping;
      Sonar.Get_Distance(Distance);


      if (Distance <= 50) then
        if (driving_command.update_priority <= PRIO_DISTANCE) then
          -- decrease the speed gradually

          if (Distance <= 20) then
            -- Put_Noupdate("Halt!!");
            -- New_Line;
            UpPriority(PRIO_DISTANCE,0,0);
            
            UpPriority(PRIO_DISTANCE,1000,50);
          elsif (Distance <= 30) then
            -- Put_Noupdate("Slow!!");
            -- New_Line;

            UpPriority(PRIO_DISTANCE,driving_command.duration,-10);
          elsif (Distance <= 40) then
            UpPriority(PRIO_DISTANCE,driving_command.duration,-30);
          elsif (Distance <= 50) then
            UpPriority(PRIO_DISTANCE,driving_command.duration,-40);
          end if;

          
        end if;

      end if;



      -- 100 ms absolute delay
      Next_Time := Next_Time + Milliseconds(100);
      delay until Next_Time;
    end loop;
  end DistanceTask;

  task body DisplayTask is

    Next_Time : Time := Clock;
  begin
    -- task body starts here ---
    Put_Line("Hello world!");

    loop
      -- TODO: Further, define a third task "DisplayTask" that outputs some useful information on the LCD
      -- Put_Noupdate("Duration: ");
      -- Put_Noupdate (Integer(driving_command.duration));
      -- New_Line;
      -- Put_Noupdate("Speed: ");
      -- Put_Noupdate (Integer(driving_command.speed));
      -- New_Line;
      -- Clear_Screen_Noupdate; 

      
      -- reset button termination
      if NXT.AVR.Button = Power_Button then
        Put_Noupdate ("Quitting program.");
        New_Line;
        Power_Down;
      end if;

      -- 100 ms absolute delay
      Next_Time := Next_Time + Milliseconds(100);
      delay until Next_Time;
    end loop;
  end DisplayTask;



end Tasks;
