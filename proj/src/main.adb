--Process commnication: Ada lab part 4

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random;

use Ada.Calendar;
use Ada.Text_IO;
use Ada.Numerics.Float_Random;


procedure comm1 is
  Message: constant String := "Process communication; No Buffer Task";

  -- random number generator
  G: Generator;

  function Rnd(MAX: Integer) return Float is
  begin
    -- generates a random round float in the range of [0, MAX]
    return Float'Rounding(Float(Max)*Random(G));
  end Rnd;


  -- PRODUCER TASK: creates random numbers and passes them to the buffer --
  task producer is
    -- add your task entries for communication
    entry terminate_task;
  end producer;
  task body producer is
    Message: constant String := "producer executing";
    -- change/add your local declarations here

    -- rnd number to be added to the buffer
    Num : Integer;
    exit_task: Boolean := False;
  begin
     Put_Line(Message);
     Main_Loop:
     loop
      -- your task code inside this loop

      -- get random integer to push
      Num := Integer(Rnd(20));

      Put("Producer -> ");
      Put_Line(Integer'Image(Num));

      -- put it into the queue
      buffer.put(Num);

      -- wait for the termination signal
      select
        accept terminate_task do
          exit_task := True;
        end terminate_task;
      or
        delay 0.1;
      end select;

      if (exit_task) then
        exit Main_Loop;
      end if;

      -- random delay: 1 to 3 seconds
      delay Duration(Rnd(2)+1.0);
    end loop Main_Loop;
  end producer;


  -- CONSUMER TASK: retrieves integers from the buffer and outputs them --
  task consumer is
    -- add your task entries for communication
  end consumer;
  task body consumer is
    Message: constant String := "consumer executing";
    -- change/add your local declarations here
    Num: Integer;
    SumNumbers: Integer := 0;
  begin
    Put_Line(Message);

    Main_Cycle:
    loop
      -- add your task code inside this loop
      buffer.get(Num);

      Put("Consumer <- ");
      Put_Line(Integer'Image(Num));

      -- add up received numbers and quit when it's over 100
      SumNumbers := SumNumbers + Num;

      if (SumNumbers > 100) then
        -- first, the consumer stops its own main cycle
        Put_Line("SumNumbers > 100. Quitting program...");

        exit Main_Cycle;
      end if;

      -- random delay, 1 - 4 seconds
      delay Duration(Rnd(3)+1.0);
    end loop Main_Cycle;

    -- send signal to terminate other two running tasks as well
    Put_Line("Ending the consumer");
    producer.terminate_task;
    buffer.terminate_task;

    -- add your code to stop executions of other tasks
    exception
      when TASKING_ERROR =>
        Put_Line("Buffer finished before producer");

  end consumer;
begin
  Put_Line(Message);
end comm1;
