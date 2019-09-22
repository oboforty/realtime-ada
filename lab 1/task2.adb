--Cyclic scheduler with a watchdog:

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.discrete_Random;

use Ada.Calendar;
use Ada.Text_IO;

-- add packages to use randam number generator


procedure main is
  Message: constant String := "Cyclic scheduler";
  -- change/add your declarations here
  Start_Time: Time := Clock;
  Period: Duration := 0.5; -- 0.5s absolute delay time
  Next_Time : Time := Start_Time + Period;

  s: Integer := 0;
  Period_rnd: Duration := 0.0;

  -- RND delay
  type Rand_Draw is range 4..6;
  package Rand_Int is new Ada.Numerics.Discrete_Random(Rand_Draw);
   seed : Rand_Int.Generator; Num : Rand_Draw;

   f3_started_flag: Boolean := False;
   f3_deadline_flag: Boolean := False;

   frame_f1: Integer := 2;
   frame_f3: Integer := 4;

   -- Entries

  procedure f1 is
    Message: constant String := "f1 executing, time is now";
  begin
    Put(Message);
    Put_Line(Duration'Image(Clock - Start_Time));
  end f1;

  procedure f2 is
    Message: constant String := "f2 executing, time is now";
  begin
    Put(Message);
    Put_Line(Duration'Image(Clock - Start_Time));
  end f2;

  procedure f3 is
    Message: constant String := "f3 executing, time is now";
    f_rnd: float := 0.0;
  begin
    Put(Message);
    Put_Line(Duration'Image(Clock - Start_Time));

    -- add a random delay here
    Num := Rand_Int.Random(seed);
    f_rnd := 0.1 * Float(Num);
    Period_rnd := Duration(f_rnd);

      Put("      RND: ");
      Put_Line(Rand_Draw'Image(Num));

    delay Duration(Period_rnd);
  end f3;

  task Watchdog is
      -- add your task entries for communication
      entry F3Finished;
  end Watchdog;
  task body Watchdog is
  begin
      loop
         -- add your task code inside this loop
         if f3_started_flag then

            select
               accept F3Finished;
               f3_started_flag := False;
            or
               delay 0.5;

               -- missed the deadline of F3
               Put("  F3 Missed deadline!  ");
               Put_Line(Duration'Image(Clock - Start_Time));

               -- set the flag for main
               f3_deadline_flag := True;
            end select;

         end if;
      end loop;
  end Watchdog;


      f3_Start_Time: Time;
      f3_End_Time: Time;
      Exec_Overtime: Duration;

  begin
    loop
      -- change/add your code inside this loop

      if (s mod 2 = 0) then
        f1;
        f2;
      end if;

      if (s mod 4 = 1) then
         f3_started_flag := True;
         f3_Start_Time := Clock;
         f3;
         f3_End_Time := Clock;
         Watchdog.F3Finished;

         -- check if F3 has missed its deadline (set by Watchdog)
         if f3_deadline_flag then
            -- Shift the execution frames by 2 (1s):

            -- reset the flag
            f3_deadline_flag := False;

            -- syncronize delay time
            Exec_Overtime := f3_End_Time - f3_Start_Time - Period;

            Put_Line(Duration'Image(1.0-Exec_Overtime));
            --Put_Line(Duration'Image(Exec_Overtime));

            --Next_Time := Next_Time + (1.0 - Exec_Overtime);
            -- Next_Time has an old value before f3 misses its deadline ;) 
            Next_Time := f3_End_Time + (1.0 - Exec_Overtime);
            --Start_time := Start_Time + (1.0 - Exec_Overtime);
            -- NO Need to reset Start_Time
         end if;
      end if;

      s := s + 1;

      -- absolute delay
      delay until Next_Time;
      Next_Time := Next_Time + Period;

    end loop;
end main;