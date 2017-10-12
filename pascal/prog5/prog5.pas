program Inventory(input,output);
{This program was created by Exalted Leader Marc Ramirez on 6/24/88
 It is saved on the hand-in disk as MAR5.PAS}

{Global variables}
var
 o_rings,d_cells : integer;

procedure getint(var I:integer);
{robust procedure that guards against bad input of numbers}

var
 strng:string[8];
 b,c:integer;

begin
b:=1;
while b<>0 do
 begin
 Readln(strng);
 val(strng,c,b);
 if b<>0 then
  begin
  writeln('Give me some credit, I know that "',strng[b],'" is not a digit!');
  write('Try again > ');
  end;
 end;
I:=c;
end;      {getint}

procedure GetInventory(var O,D:integer);

begin
write('Please enter number of O-rings currently in stock> ');
getint(O);
write('Please enter number of D-batteries currently in stock> ');
getint(D);
writeln;
end;      {GetInventory}

function getitem(func:string):char;
{Gets the letter of the item which the user wants to increase or decrease}


var
 I:char;

begin
repeat
 begin
 write(func,' inventory of what item? (O,D)> ');
 readln(I);
 I:=UpCase(I);
 if not (I in ['O','D']) then
  writeln('I did not understand that. Please type a capital O or a capital D.');
 end;
until (I in ['O','D']);
getitem:=I;
end;     {getitem}

function getnum(func:string):integer;
{Gets the number of items to increase or decrease by for Increase and Decrease
}


var
 I:integer;

begin
repeat
 begin
 write(func,' by how much?> ');
 getint(I);
 if I<0 then
  writeln('There is no such thing as a negative amount.');
 end;
until (I>=0);
getnum:=I;
end;     {getnum}

procedure Increase(var O,D:integer);
{Increases then inventory of an item.  Called by GetComms.}


var
 I:char;
 n:integer;

begin
I:=getitem('Increase');
n:=getnum('Increase');
if I='O' then
 begin
 O:=O+n;
 writeln('Current inventory of O-rings is now ',O);
 end
else
 begin
 D:=D+n;
 writeln('Current inventory of D-batteries is now ',D);
 end;
writeln;
end;      {Increase}

procedure Decrease(var O,D:integer);
{Decreases inventory of an item.  Called by GetComms.}


var
 I:char;
 n:integer;

begin
I:=getitem('Decrease');
n:=getnum('Decrease');
if I='O' then
 if n>O then
  writeln('Only ',O,' O-rings in stock, sorry.')
 else
  begin
  O:=O-n;
  writeln('Current inventory of O-rings is now ',O);
  end
else
 if n>D then
  writeln('Only ',D,' D-batteries in stock, sorry.')
 else
  begin
  D:=D-n;
  writeln('Current inventory of D-batteries is now ',D);
  end;
writeln;
end;      {Decrease}

procedure GetComms(var x,y:integer);
{Displays the 'Enter command' prompt and calls Increase or Decrease
accordingly.}


var
 I:char;

begin
while I<>'Q' do
 begin
 repeat
  begin
  write('Enter command (I,D,Q)> ');
  readln(I);
  I:=UpCase(I);
  if not (I in ['I','D','Q']) then
   writeln('I did not understand that. Please type a capital I, D, or Q.');
  end;
 until (I in ['I','D','Q']);
 case I of
  'I' : Increase(x,y);
  'D' : Decrease(x,y);
  end;
 end;
end;      {GetComms}

procedure BlankScreen;
{writes 25 spaces to blank out the screen}

var
 x:byte;

begin
for x:=1 to 25 do
 writeln;
end;      {BlankScreen}

begin
BlankScreen;
writeln('INVENTORY CONTROL PROGRAM');
GetInventory(o_rings,d_cells);
GetComms(o_rings,d_cells);
writeln('Thank you for using the INVENTORY CONTROL PROGRAM.');
end.
