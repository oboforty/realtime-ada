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

  function clamp (v: Float) return Float is
  begin
    if v > 1.0 then
      return 1.0;
    elsif v < 0.0 then
      return 0.0;
    else
      return v;
    end if;
  end clamp;

  -------------
  --  Tasks  --
  -------------
  task body MotorTask is
    Next_Time : Time := Clock;
  begin

    loop
      -- Define a task "MotorcontrolTask" that "executes" the "driving command". 

      if (driving_command.duration > 0) then
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

      -- absolute delay
      Next_Time := Next_Time + Milliseconds(PERIOD_MOTOR);
      delay until Next_Time;
    end loop;
  end MotorTask;


  task body ButtonpressTask is
    btn_pressed : Boolean := False;

    Next_Time : Time := Clock;
  begin
    -- task body starts here ---

    -- chill a bit
    delay until Clock + Milliseconds(200);

    loop
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
              driving_command.has_started := True;
              UpPriority(PRIO_BUTTON, 500, PWM_Value(SPEED_MAX-SPEED_MIN));
            else
              driving_command.has_started := False;
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


      -- absolute delay
      Next_Time := Next_Time + Milliseconds(PERIOD_BTNSTOP);
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

    Sonar.Set_Mode(Ping);
 
    loop
      Sonar.Ping;
      Sonar.Get_Distance(Distance);

      if (driving_command.has_started) then
        if (Distance <= 20) then
          UpPriority(PRIO_DISTANCE, 500, 0);
        else
          UpPriority(PRIO_DISTANCE, 500, PWM_Value(SPEED_FORWARD));
        end if;
      end if;

      -- 100 ms absolute delay
      Next_Time := Next_Time + Milliseconds(PERIOD_DISTANCE);
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

      -- absolute delay
      Next_Time := Next_Time + Milliseconds(PERIOD_DISPLAY);
      delay until Next_Time;
    end loop;
  end DisplayTask;


  task body CalibrationTask is
    track_edge_black: Integer := -1;
    track_edge_white: Integer := -1;
    light_edge: Integer := -1;
    Prev_Light_val: Integer := -1;

    reading: Integer := -1;
    norm_light_val: Float := -1.0;

    Next_Time : Time := Clock;
  begin
    -- @TEMPORAL
    -- FOR DEBUGGING
    track_edge_black := 10;
    track_edge_white := 90;

    -- task body starts here ---
 
    Calib_Loop:
    loop
      Clear_Screen_Noupdate;
      Put_Noupdate("-----------");
      New_Line;
      Put_Noupdate(PhotoDetector.Light_Value);
      New_Line;

      Put_Noupdate(track_edge_white);
      Put_Noupdate(" | ");
      Put_Noupdate(track_edge_black);
      Put_Noupdate(" | ");
      New_Line;
      Put_Noupdate("-----------");
      New_Line;

      -- calibration buttons
      if NXT.AVR.Button = Right_Button then
        track_edge_black := PhotoDetector.Light_Value;
      end if;

      if NXT.AVR.Button = Left_Button then
        track_edge_white := PhotoDetector.Light_Value;
      end if;

      if NXT.AVR.Button = Middle_Button then
        if track_edge_black /= -1 and then track_edge_white /= -1 then
          light_edge := (track_edge_white + track_edge_black) / 2;
          exit Calib_Loop;
        end if;
      end if;

      -- absolute delay
      Next_Time := Next_Time + Milliseconds(PERIOD_CALIBRATION);
      delay until Next_Time;
    end loop Calib_Loop;


    -- second phase: keep reading the light value
    Reading_Loop:
    loop
      reading := PhotoDetector.Light_Value;

      -- PD controller
      norm_light_val := clamp(Float(reading - track_edge_black) / Float(track_edge_white - track_edge_black));

      Clear_Screen_Noupdate;
      Put_Noupdate("V: ");
      Put_Noupdate(reading);
      New_Line;

      -- Put_Noupdate("[");
      -- Put_Noupdate(track_edge_black);
      -- Put_Noupdate(",");
      -- Put_Noupdate(track_edge_white);
      -- Put_Noupdate("]");
      -- New_Line;


      if (driving_command.is_moving) then
        if (norm_light_val >= 0.4 and then norm_light_val <= 0.6) then
	  norm_light_val := 0.5;
	  UpPriority(PRIO_BUTTON, 500, PWM_Value(SPEED_FORWARD));
	else
	  
        
          UpPriorityTurn(PRIO_BUTTON, 500, PWM_Value(SPEED_MIN+(SPEED_MAX-SPEED_MIN)*(0.0+norm_light_val)), PWM_Value(SPEED_MIN+(SPEED_MAX-SPEED_MIN)*(1.0-norm_light_val)));
	end if;
        Put_Noupdate("Rm: ");
        Put_Noupdate(Integer(driving_command.speed_right));
        New_Line;
        Put_Noupdate("Lm: ");
        Put_Noupdate(Integer(driving_command.speed_left));
        New_Line;
      else
        Put_Noupdate("I am stopped.");
        New_Line;
      end if;

      -- absolute delay
      Next_Time := Next_Time + Milliseconds(PERIOD_CALIBRATION);
      delay until Next_Time;
    end loop Reading_Loop;


  end CalibrationTask;

end Tasks;
