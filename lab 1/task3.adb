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

    -- rnd delay
    type Rand_Draw is range 1..5;
    package Rand_Int is new Ada.Numerics.Discrete_Random(Rand_Draw);
    seed : Rand_Int.Generator;


    -- random number
    G: Generator;

  function Rnd(MAX: Integer) return Float is
  begin
    return Float'Rounding(Float(Max)*Random(G));
  end Rnd;

  -- BUFFER: --
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

    -- circular queue implementation
    size: constant Integer := 10;
    type circular_queue is array(0..size) of Integer;
    queue : circular_queue;
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
          delay 1.0;
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
          delay 1.0;
        end select;
      end if;

      --if (counter = size) then
      --  Put_Line("ERR: COUNTER IS <0");
      --end if;


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

      if (counter < 0) then
        Put_Line("ERR: COUNTER IS <0");
      end if;


    end loop Main_Loop;
  end buffer;


  -- PRODUCER: --
  task producer is
    -- add your task entries for communication
    entry terminate_task;
  end producer;

  task body producer is
    Message: constant String := "producer executing";
                -- change/add your local declarations here

    -- rnd number generator
    Num : Integer;
    exit_task: Boolean := False;
  begin
     --Put_Line(Message);
     Main_Loop:
     loop
      -- your task code inside this loop
      -- random delay
      --delay Duration'Rnd(3);

      -- random number
      Num := Integer(Rnd(20));

      Put("Producer: -> ");
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

      delay Duration(Rnd(3));
    end loop Main_Loop;
  end producer;


  -- CONSUMER --
  task consumer is
            -- add your task entries for communication
  end consumer;

  task body consumer is
    Message: constant String := "consumer executing";
    -- change/add your local declarations here
    Num: Integer;
    SumNumbers: Integer := 0;
  begin
    --Put_Line(Message);
    Main_Cycle:
    loop
      -- add your task code inside this loop
      buffer.get(Num);

      Put("Consumer: <- ");
      Put_Line(Integer'Image(Num));

      SumNumbers := SumNumbers + Num;

      if (SumNumbers > 100) then
        Put_Line("Big");

        -- terminate other two running tasks
        producer.terminate_task;
        buffer.terminate_task;

        exit Main_Cycle;

      end if;

      delay Duration(Rnd(2));
    end loop Main_Cycle;

    -- add your code to stop executions of other tasks
    exception
      when TASKING_ERROR =>
        Put_Line("Buffer finished before producer");
    Put_Line("Ending the consumer");

  end consumer;
begin
  --Put_Line(Message);
  null;
end comm1;
