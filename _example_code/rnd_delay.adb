
  procedure rnd_delay is
    Period_rnd: Duration := 0.0;
    f_rnd: float := 0.0;

    delay_ms : Rand_Draw;
  begin
    -- add a random delay here
    delay_ms := Rand_Int.Random(seed);
    f_rnd := 0.1 * Float(delay_ms);
    Period_rnd := Duration(f_rnd);

    --Put("      RND: ");
    --Put_Line(Rand_Draw'Image(delay_ms));

    delay Duration(Period_rnd);
  end rnd_delay;