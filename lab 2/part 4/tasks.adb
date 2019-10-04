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
    driving_command.speed_left := newSpeed;
    driving_command.speed_right := newSpeed;

    driving_command.is_moving := newSpeed /= 0;
  end UpPriority;

  procedure UpPriorityTurn(newPriorit: Integer; newDuration: Integer; leftSpeed: PWM_Value; rightSpeed: PWM_Value) is
  begin
    driving_command.update_priority := newPriorit;
    driving_command.duration := newDuration;
    driving_command.speed_left := leftSpeed;
    driving_command.speed_right := rightSpeed;

    driving_command.is_moving := leftSpeed /= 0 or rightSpeed /= 0;
  end UpPriorityTurn;


  -------------
  --  Tasks  --
  -------------
  task body MotorTask is
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
        driving_command.speed_left := 0;
        driving_command.speed_right := 0;
      end if;

      Set_Power(Motor_A, driving_command.speed_left, False);
      Set_Power(Motor_B, driving_command.speed_right, False);

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
            driving_command.update_priority := PRIO_BUTTON;

            if (not driving_command.is_moving) then 
              -- stop and 2nd press
              UpPriority(PRIO_BUTTON, 60000, 85);
            else
              UpPriority(PRIO_BUTTON, 0, 0);
            end if;
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


      -- if (Distance <= 50) then
      --   if (driving_command.update_priority <= PRIO_DISTANCE) then
      --     -- decrease the speed gradually

      --     if (Distance <= 20) then
      --       -- Put_Noupdate("Halt!!");
      --       -- New_Line;
      --       UpPriority(PRIO_DISTANCE,0,0);
            
      --       UpPriority(PRIO_DISTANCE,1000,-50);
      --     elsif (Distance <= 30) then
      --       -- Put_Noupdate("Slow!!");
      --       -- New_Line;

      --       UpPriority(PRIO_DISTANCE,driving_command.duration,10);
      --     elsif (Distance <= 40) then
      --       UpPriority(PRIO_DISTANCE,driving_command.duration,30);
      --     elsif (Distance <= 50) then
      --       UpPriority(PRIO_DISTANCE,driving_command.duration,40);
      --     end if;

          
      --   end if;

      -- end if;



      -- 100 ms absolute delay
      Next_Time := Next_Time + Milliseconds(100);
      delay until Next_Time;
    end loop;
  end DistanceTask;

  task body DisplayTask is

    Next_Time : Time := Clock;
  begin
    -- task body starts here ---

    loop
      -- reset button termination
      if NXT.AVR.Button = Power_Button then
        --Put_Noupdate ("Quitting program.");
        --New_Line;
        Power_Down;
      end if;

      -- 100 ms absolute delay
      Next_Time := Next_Time + Milliseconds(100);
      delay until Next_Time;
    end loop;
  end DisplayTask;


  task body CalibrationTask is
    track_edge_black: Integer := -1;
    track_edge_white: Integer := -1;
    light_edge: Integer := -1;

    reading: Integer := -1;

    Next_Time : Time := Clock;
  begin
    -- @TEMPORAL
    -- FOR DEBUGGING
    track_edge_black := 31;
    track_edge_white := 47;

    -- task body starts here ---
    Put_Line("Push buttons to calibrate!");

    Calib_Loop:
    loop

      -- calibration buttons
      if NXT.AVR.Button = Right_Button then
        track_edge_black := PhotoDetector.Light_Value;

        -- wait for black line
        Clear_Screen_Noupdate; 
        Put_Noupdate("Calibrated black: ");
        Put_Noupdate(track_edge_black);
        New_Line;
      end if;

      if NXT.AVR.Button = Left_Button then
        track_edge_white := PhotoDetector.Light_Value;

        -- wait for white line
        Clear_Screen_Noupdate; 
        Put_Noupdate("Calibrated white: ");
        Put_Noupdate(track_edge_white);
        New_Line;
      end if;

      if NXT.AVR.Button = Middle_Button then
        if track_edge_black /= -1 and then track_edge_white /= -1 then
          light_edge := (track_edge_white + track_edge_black) / 2;

          Clear_Screen_Noupdate; 
          Put_Noupdate("Ready: ");
          Put_Noupdate(light_edge);
          New_Line;

          exit Calib_Loop;
        end if;
      end if;

      -- 100 ms absolute delay
      Next_Time := Next_Time + Milliseconds(100);
      delay until Next_Time;
    end loop Calib_Loop;


    -- second phase: keep reading the light value
    Reading_Loop:
    loop
      reading := PhotoDetector.Light_Value;

      Clear_Screen_Noupdate; 
      Put_Noupdate("V: ");
      Put_Noupdate(light_edge);
      New_Line;

      if (driving_command.is_moving) then

        if (reading > light_edge+2) then
          Put_Noupdate("[W] Turn right");
          New_Line;

          UpPriorityTurn(PRIO_BUTTON, 500, 100, 70);

        elsif (reading < light_edge-2) then
          Put_Noupdate("[B] Turn left");
          New_Line;

          UpPriorityTurn(PRIO_BUTTON, 500, 70, 100);
        else
          UpPriority(PRIO_BUTTON, 1000, 85);
        end if;
      else
        Put_Noupdate("I am stopped.");
        New_Line;
      end if;

      -- 200 ms absolute delay
      Next_Time := Next_Time + Milliseconds(200);
      delay until Next_Time;
    end loop Reading_Loop;


  end CalibrationTask;

end Tasks;
