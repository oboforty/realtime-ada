with Tasks;
with System;

procedure mainlego is

   pragma Priority (System.Priority'First);

begin

   Tasks.Background;

end mainlego;
