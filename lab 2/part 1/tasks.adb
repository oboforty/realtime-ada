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
