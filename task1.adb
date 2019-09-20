with Ada.Calendar;
with Ada.Text_IO;
use Ada.Calendar;
use Ada.Text_IO;

procedure cyclic is
  Message: constant String := "Cyclic scheduler";
  -- change/add your declarations here
  Start_Time: Time := Clock;
  Period: Duration := 0.5; -- 0.5s absolute delay time
  Next_Time : Time := Start_Time + Period;
  
  s: Integer := 0;

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
  begin
    Put(Message);
    Put_Line(Duration'Image(Clock - Start_Time));
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
end cyclic;
