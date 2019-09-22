--Process commnication: Ada lab part 3

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random;

use Ada.Calendar;
use Ada.Text_IO;
use Ada.Numerics.Float_Random;


procedure comm1 is
  Message: constant String := "Process communication";

  -- random number generator
  G: Generator;

  function Rnd(MAX: Integer) return Float is
  begin
    -- generates a random round float in the range of [0, MAX]
    return Float'Rounding(Float(Max)*Random(G));
  end Rnd;

  -- BUFFER TASK: a task that accepts and input numbers and stores them in a buffer --
  task buffer is
      -- add your task entries for communication
    entry put(X: in integer);
    entry get(x: out integer);
    entry terminate_task;
  end buffer;

  task body buffer is
    Message: constant String := "buffer executing";
    -- change/add your local declarations here
    exit_task: Boolean := False;

    -- circular queue implementation: implements a FIFO buffer
    size: constant Integer := 10;
    type circular_queue is array(0..size) of Integer;
    queue : circular_queue;
    -- number of elements stored in the buffer
    counter: Integer := 0;
    head: Integer := 0;
    tail: Integer := 0;
  begin
    Put_Line(Message);

    Main_Loop:
    loop
      -- add your task code inside this loop

      -- wait for until the queue gets free space
      if (counter /= size) then
        select
          accept put(x: in integer) do
            -- circular queue put
            queue(tail) := x;

            counter := counter + 1;
            tail := (tail mod size) + 1;

          end put;
        or
          -- don't wait forever, because it might block the other entry
          delay 0.2;
        end select;
      end if;

      -- wait for until the queue has values
      if (counter > 0) then
        select

          accept get(x: out integer) do
            -- circular queue get
            x := queue(head);

            counter := counter - 1;
            head := (head mod size) + 1;
          end get;
        or
          -- don't wait forever, because it might block the other entry
          delay 0.2;
        end select;
      end if;

      -- wait for a termination signal
      select
        accept terminate_task do
          exit_task := True;
        end terminate_task;
      or
        delay 0.1;
      end select;

      -- termination signal was given; stop execution
      if (exit_task) then
        exit Main_Loop;
      end if;

      if (counter < 0) then
        -- unexpected error happened (this line should never execute in theory)
        Put_Line("ERR: COUNTER IS <0");
      end if;


    end loop Main_Loop;
  end buffer;


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
      -- @TODO: protected buffer

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
      -- @TODO: protected buffer

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

    -- add your code to stop executions of other tasks
    -- send signal to terminate other two running tasks as well
    Put_Line("Ending the consumer");
    producer.terminate_task;

    exception
      when TASKING_ERROR =>
        Put_Line("Buffer finished before producer");

  end consumer;
begin
  Put_Line(Message);
end comm1;
