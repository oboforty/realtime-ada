--The package Ada.Calendar defines the variable Clock, containing current system time.
--This can be used in the following way to create a periodic loop:


-- Note the different semantics of Duration and Time:
--    Variables of type Time store absolute time information, like (absolute) time points; 
--    Variables of type Duration store relative time information, like time intervals, i.e., the difference between two time points. 

-- The statements delay and delay until expect differently typed parameters.

   with Ada.Calendar;
   use Ada.Calendar;

   -- Prints a message periodically
   procedure Periodic_Put(Message : in String; Period : in Duration) is
         Next_Time : Time := Clock + Period;
      begin
         loop
            Ada.Text_IO.Put_Line(Message);
            delay until Next_Time;
            Next_Time := Next_Time + Period;
         end loop;
      end Periodic_Put;

-- http://www.it.uu.se/edu/course/homepage/realtid/ht19/labs/lab1/start_ada#time