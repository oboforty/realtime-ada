--Cyclic scheduler with a watchdog:

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.discrete_Random;

use Ada.Calendar;
use Ada.Text_IO;

-- add packages to use randam number generator


procedure cyclic_wd is
  Message: constant String := "Cyclic scheduler";
  -- change/add your declarations here
  Start_Time: Time := Clock;
  Period: Duration := 0.5; -- 0.5s absolute delay time
  Next_Time : Time := Start_Time + Period;

  s: Integer := 0;
  Period_rnd: Duration := 0.0;

  -- RND delay
  type Rand_Draw is range 1..3;
  package Rand_Int is new Ada.Numerics.Discrete_Random(Rand_Draw);
  seed : Rand_Int.Generator; Num : Rand_Draw;

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

    delay Duration(Period_rnd);
  end f3;


  begin
    loop
      -- change/add your code inside this loop

      if (s mod 2 = 0) then
        f1;
        f2;
      end if;

      if (s mod 4 = 1) then
        f3;
      end if;

      s := s + 1;

      -- absolute delay
      delay until Next_Time;
      Next_Time := Next_Time + Period;
    end loop;
end cyclic_wd;
