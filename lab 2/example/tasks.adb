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
      Speed : constant PWM_Value := -100;
      Stop : constant PWM_Value := 0;
   begin
      loop
         -- Start the motors on button push
         Event.wait(TouchOnEvent);
         Set_Power(Motor_A, Speed, False);
         Set_Power(Motor_B, Speed, False);

         -- Stop the motors on buttonr release
         Event.wait(TouchOffEvent);
         Set_Power(Motor_A, Stop, False);
         Set_Power(Motor_B, Stop, False);

         -- 10 ms relative delay
         delay until Clock + Milliseconds(10);
      end loop;
   end MotorTask;


   task body EventdispatcherTask is
      btn_pressed : Boolean := False;
   begin
      loop
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



        -- 10 ms relative delay
        delay until Clock + Milliseconds(10);
      end loop;
   end EventdispatcherTask;

   task body HelloworldTask is
      Next_Time : Time := Clock;
      --Period_Display: Duration := Milliseconds(300);
   begin
      -- task body starts here ---
      Put_Line ("Hello World!");

      loop

         -- read light sensors and print ----
         Put_Noupdate (PhotoDetector.Light_Value);
         Put_Noupdate ("%,  0x");
         Put_Hex (NXT.AVR.Raw_Input (Sensor_4));
         New_Line;

         -- reset button
         if NXT.AVR.Button = Power_Button then
            Power_Down;
         end if;
         
         Next_Time := Next_Time + Milliseconds(300);
         delay until Next_Time;
      end loop;
   end HelloworldTask;
    
end Tasks;
