program DeterminantFiniteStateMachines;

uses Crt,Graph,Dos;

const
   MAXSTATES=256;
   ALPHALENGTH=2;
   ALPHABET:string='01';
   DidTrace:boolean=false;
   CharHeight:integer=8;
   InGr:boolean = false;
   GrInit:boolean = false;

type
   StateType=record
                accept:boolean; {True if accepting state}
                Vectors:array[1..ALPHALENGTH] of word;  {Vector table}
             end;
   MachineType=array [1..MAXSTATES] of StateType;
       {array used here for random-access}
   TraceType=^TraceData;
   TraceData=Record
                State:integer;        {Current state}
                Encountered:integer;  {What it encountered (0... for
                                       corresponding alphabetic characters,
                                       -1 for character not in alphabet}
                WentTo:integer;       {Where it went}
                next:TraceType;       {Pointer to next element}
             end;

{---------------- Global Variables -----------------}
var
   Machine:MachineType; {Array to store the machine}
   MachineString:string;{String the machine will use}
   NumOfStates:integer; {Number of states the machine has (used by SaveMachine
                         and LoadMachine)}
   MaxX,MaxY:word;      {X and Y resolution}
   Mode,Drivr:integer;  {Screen mode and driver #}
   traced:TraceType;    {Linked list of the execution path}
   LInit:boolean;       {Tells if the list has been initialized}

procedure GoToText;forward;

procedure GoToGraph;forward;

procedure ClearS;
{
 Clears the graphics screen.  Quickest Turbo algorithm is to switch from
 text back to graphics. (Does make the screen bounce.)
}

begin
GoToText;
GoToGraph;
end;

procedure Cls;
{
 Clears the screen independent of the screen mode.
}

begin
if InGr then
   ClearS
else
   ClrScr;
end;

procedure GoToGraph;
{
 Puts computer in graphics mode (initializes if necessary)
}

var
  Gd,Gm:integer;

begin
if GrInit then
   begin
   if not InGr then
      begin
      InitGraph(Drivr,Mode,'b:');
      InGr:=True;
      end;
   end
else
   begin
   Gd:=0;
   Gm:=0;
   InitGraph(Gd,Gm,'a:');
   if GraphResult=grOk then
      begin
      MaxX:=GetMaxX;
      MaxY:=GetMaxY;
      GrInit:=True;
      InGr:=True;
      Mode:=Gm;
      Drivr:=Gd;
      end
   else
      begin
      Writeln('This Program Requires Graphics (any type)');
      exit;
      end;
   end;
end;

procedure GoToText;
{
 Puts computer in text mode (if not already there).
}

begin
if GrInit then
   if InGr then
      begin
      InGr:=False;
      TextMode(LastMode);
      end;
end;

procedure Center(row:integer;ToWrite:string);
{
 Centers string 'ToWrite' on row 'row' for all screen modes.
}

begin
if not InGr then
   begin
   GoToXY(40-Length(ToWrite) div 2,row);
   Write(ToWrite);
   end
else
   begin
   OutTextXY((MaxX div 2) - (TextWidth(ToWrite) div 2),(row * CharHeight) - CharHeight,ToWrite);
   end;
end;


procedure Centerln(row:integer;ToWrite:string);
{
 Centers string 'ToWrite' on row 'row' and writes a CR-LF.
}

begin
Center(row,ToWrite);
if not InGr then
   Writeln;
end;

procedure Pause(line:integer);
{
 Writes 'Press a key when ready...' on line 'line' and waits for a keystroke.
 (independent of screen mode)
}

var
   d:char;

begin
Center(line,'Press a key when ready...');
d:=ReadKey;
end;

procedure Instructions;
{
 Writes instructions for program use on the screen.
}

const
   WasInGr:boolean=true;

var
   ArcCoords:ArcCoordsType;

begin
if not InGr then
   begin
   WasInGr:=false;
   GoToGraph;
   end;
Cls;
Center(1,'This program traces finite automata (finite state machines).  The program will');
Center(2,'ask you how many states the machine has.  It will then prompt you to input');
Center(3,'whether or not a given state is accepting or rejecting and where each state');
Center(4,'should jump in case of zero or one.  Then you give the program a string, and it');
Center(5,'will trace the machine for you.  Then you will have a set of options:');
Center(6,'(R)etrace machine runs the machine again with a new string.  (E)nter new');
Center(7,'machine lets you enter another machine for tracing.  (S)how execution shows');
Center(8,'the path that the machine took.  Sa(V)e machine saves a machine to a disk');
Center(9,'file. (L)oad machine loads a machine from a disk file. And e(X)it quits the');
Center(10,'program.  The starting state is always 1.  The states execute as shown');
Center(11,'below.');
Circle(200,200,20);
Circle(200,200,12);
Line(220,200,240,200);
line(240,200,237,197);
line(240,200,237,203);
line(200,216,200,236);
line(200,236,203,233);
line(200,236,197,233);
OutTextXY(224,190,'0');
OutTextXY(190,219,'1');
Arc(180,185,0,270,20);
OutTextXY(160,158,'Else');
GetArcCoords(ArcCoords);
with ArcCoords do
   begin
   line(Xend,Yend,Xend-4,Yend-4);
   line(Xend,Yend,Xend-4,Yend+4);
   end;
Pause(13);
if not WasInGr then
   GoToText;
end;

function GetInt(Prompt:string;MnInt,MxInt:integer):integer;
{
  pre:Prompt is a printable string
 post:MnInt<=GetInt<=MxInt
}

var
   DInt:integer;

begin
repeat
   begin
   write(Prompt);
   readln(DInt);
   if (Dint<MnInt) or (DInt>MxInt) then
      Writeln('Number must be between ',MnInt,' and ',MxInt);
   end;
until (DInt>=MnInt) and (DInt<=MxInt);
GetInt:=DInt;
end;

Function GetChar(Prompt:string;Acceptable:string):Char;
{
  pre:Prompt and Acceptable are printable strings
 post:GetChar is in Acceptable
}

var
   DChar:char;

begin
repeat
   begin
   write(Prompt);
   readln(DChar);
   if Pos(DChar,Acceptable)=0 then
      Writeln('Unacceptable character!');
   end;
until Pos(DChar,Acceptable)<>0;
GetChar:=DChar;
end;

procedure FindMaxCharHeight;
{
 Finds the height in pixels of the tallest character in a given font
}

var
   DNum:integer;
   DNum2:integer;
   DNum3:integer;

begin
DNum2:=0;
for DNum:=32 to 127 do
   begin
   DNum3:=TextHeight(Chr(DNum));
   if DNum3>DNum2 then
      DNum2:=DNum3;
   end;
CharHeight:=DNum2;
end;



procedure GetMachineString(var MachineString:string);
{
 Gets the string used by the machine.
}

var
 WasInGr:boolean;

begin
WasInGr:=InGr;
GoToText;
Write('Enter string for machine >');
Readln(MachineString);
if WasInGr then
   GoToGraph;
end;

function STRNG(d:integer):string;
{
 Functionized version of Str.
}

var ds:string;

begin
Str(d,ds);
STRNG:=ds;
end;


procedure GetMachine(var Machine:MachineType;
                     var NumOfStates:integer;
                     var MachineString:string);
{
 Lets user input the machine in the form number of states, A,R (accepting or
 rejecting), and where to go on 0 and 1.
}

var
   DString,HasBeenEntered:string;
   DNum,DNum2,DNum3:integer;
   WasInGr:boolean;
   Jump:integer;
   DCh:char;

begin
WasInGr:=InGr;
GoToText;
Centerln(1,'Enter your machine:');
DNum:=GetInt('Enter number of states (1 - '+strng(MAXSTATES)+') >',1,maxstates);
for DNum2:=1 to DNum do
   begin
   for DNum3:=1 to ALPHALENGTH do
      Machine[DNum2].Vectors[DNum3]:=0;
   HasBeenEntered:='';
   writeln('State ',DNum2);
   case UpCase(GetChar('   (A)ccepting or (R)ejecting >','ARar')) of
      'A':Machine[DNum2].accept:=True;
      'R':Machine[DNum2].accept:=False;
      end;
   repeat
      begin
      DCh:=GetChar('   on character >',ALPHABET+'*');
      Jump:=GetInt('   go to        >',1,DNum);
      if DCh='*' then
         begin
         for DNum3:=1 to ALPHALENGTH do
            begin
            if Machine[DNum2].Vectors[DNum3]=0 then
               Machine[DNum2].vectors[DNum3]:=jump;
            end;
         end
      else
         begin
         Machine[DNum2].Vectors[Pos(DCh,ALPHABET)]:=jump;
         if pos(DCh,HasBeenEntered)=0 then
            HasBeenEntered:=HasBeenEntered+DCh;
         end;
      end;
   until (DCh='*') or (length(HasBeenEntered)=ALPHALENGTH);
   end;
GetMachineString(MachineString);
NumOfStates:=DNum;
DidTrace:=false;
if WasInGr then
   GoToGraph;
end;

procedure Make(var l:TraceType;
                   s:integer;
                   e:integer;
                   w:integer);
{
 Makes a new list of TraceType using s for State,e for Encountered, and w for
 WhereTo.
}

begin
new(l);
l^.next:=nil;
l^.state:=s;
l^.encountered:=e;
l^.WentTo:=w;
end;

procedure Tack(var l:TraceType;
                   s:Integer;
                   e:integer;
                   w:integer);
{
 Functional equivalent of Append.
}

var
   begl:TraceType;
   l2:TraceType;

begin
begl:=l;
while l^.next<>nil do
   l:=l^.next;
Make(l2,s,e,w);
l^.next:=l2;
l:=begl;
end;

procedure Kill(var l:tracetype);
{
 Functional equivalent of KillList.
}

var next:TraceType;

begin
repeat
   begin
   next:=l^.next;
   dispose(l);
   l:=next;
   end;
until l=nil;
end;


Procedure TraceMachine(   Machine:MachineType;
                       var Traced:TraceType;
                       MachineString:string);
{
 Traces the machine 'Machine' using the string 'MachineString' and stores
 the results in the list 'Traced'.
}

var
   at,Indx,Jump:Integer;
   Enc:Shortint;
   LastState:boolean;

begin
GoToGraph;
Cls;
if LInit then
   begin
   Kill(Traced);
   LInit:=false;
   end;
At:=1;
LastState:=Machine[at].accept;
for Indx:=1 to length(MachineString) do
   begin
   if Pos(MachineString[Indx],ALPHABET)=0 then
      Enc:=-1
   else
      Enc:=Pos(MachineString[Indx],ALPHABET);
   if Enc>0 then
      Jump:=Machine[at].Vectors[Enc]
   else
      Jump:=At;
   if LInit then
      Tack(Traced,At,Enc,Jump)
   else
      begin
      Make(Traced,At,Enc,Jump);
      LInit:=True;
      end;
   At:=Jump;
   LastState:=Machine[at].accept;
   end;
Center(1,'String');
Center(2,MachineString);
if LastState then
   Center(3,'Accepted')
else
   Center(3,'Rejected');
DidTrace:=true;
pause(5);
end;


function Options:char;
{
 Displays the post-trace menu and returns a character in the set of menu
 choices.
}

var
   ch:char;

begin
GoToGraph;
cls;
center(1,'Your options are:');
center(3,'sho[W] machine     ');
center(4,'[E]nter machine    ');
center(5,'[S]how execution   ');
if DidTrace then
   center(6,'re[T]race machine  ')
else
   center(6,'[T]race machine    ');
center(7,'[L]oad machine     ');
Center(8,'sa[V]e machine     ');
center(9,'[I]nstructions     ');
center(10,'e[X]it             ');
center(12,'Which shall you do???????');
repeat
   ch:=UpCase(ReadKey);
until ch in ['W','E','S','T','L','V','I','X'];
Options:=ch;
end;

procedure ReTraceMachine(Machine:MachineType;
                         Traced:TraceType;
                         MachineString:string);

begin
GoToText;
Cls;
Write('Enter new string >');
Readln(MachineString);
TraceMachine(Machine,Traced,MachineString);
end;

procedure ShowTrace(Traced:TraceType;
                    Machine:MachineType);

var
   BegL:TraceType;
   OutF:text;
   outt:string;
   x:integer;

begin
GoToText;
begL:=Traced;
Write('Output device (enter for screen) >');
Readln(outt);
assign(Outf,outt);
Rewrite(OutF);
while traced<>nil do
   begin
   write(OutF,'At ',Traced^.state:3,' (');
   if Machine[Traced^.state].accept then
      write(OutF,'accepting')
   else
      write(OutF,'rejecting');
   write(OutF,'), I encountered ');
   case Traced^.encountered of
      0:write(OutF,'0');
      1:write(OutF,'1');
      -1:write(OutF,'a non-alphabetic character');
      end;
   if Traced^.WentTo=Traced^.state then
      writeln(OutF,' and stayed.')
   else
      writeln(OutF,' and went to ',Traced^.WentTo,'.');
   x:=Traced^.WentTo;
   Traced:=Traced^.next;
   end;
Write('At ',x:3,' I ');
if Machine[x].Accept then
   Writeln('accepted')
else
   Writeln('rejected');
close(OutF);
Traced:=BegL;
pause(25);
end;

procedure ShowMachine(var Machine:MachineType);

var
   Indx,Indx2:integer;
   OutF:text;
   DevcSpec:string;
   WasInGr:boolean;

begin
WasInGr:=InGr;
GoToText;
Cls;
Write('Output device (enter for screen) >');
Readln(DevcSpec);
assign(OutF,DevcSpec);
Rewrite(OutF);
for Indx:=1 to NumOfStates do
   begin
   Write(OutF,'State ',Indx);
   if Machine[Indx].accept then
      Writeln(OutF,' accepts')
   else
      Writeln(OutF,' rejects');
   for Indx2:=1 to ALPHALENGTH do
      begin
      Writeln(' on ',ALPHABET[Indx2],' go to ',Machine[Indx].Vectors[Indx2]);
      end;
   end;
close(OutF);
pause(25);
if WasInGr then
   GoToGraph;
end;

procedure SaveMachine(var Machine:MachineType);

var
   FileSpec:string;
   OutF:text;
   Indx,Indx2:integer;
   WasInGr:boolean;

begin
WasInGr:=InGr;
GoToText;
Cls;
Write('Name to save as (default extension is ".MAC") >');
Readln(FileSpec);
if pos('.',FileSpec)=0 then
   FileSpec:=FileSpec+'.MAC';
assign(OutF,FileSpec);
ReWrite(OutF);
Writeln(OutF,ALPHALENGTH);
Writeln(OutF,NumOfStates);
for Indx:=1 to NumOfStates do
   begin
   for Indx:=1 to ALPHALENGTH do
      Write(OutF,Machine[indx].Vectors[Indx2],' ');
   if Machine[indx].accept then
      Writeln(OutF,-1)
   else
      Writeln(OutF,0);
   end;
Close(OutF);
if WasInGr then
   GoToGraph;
end;

procedure LoadMachine(var Machine:MachineType);
{Loads}

var
   FileSpec:string;
   InF:text;
   Indx,Indx2:integer;
   Dir:SearchRec;
   WasInGr:boolean;
   Lines:byte;
   DidDir:boolean;
   Accept:shortint;

begin
WasInGr:=InGr;
GoToText;
Cls;
repeat
   begin
   DidDir:=false;
   Write('Load (* + spec for directory) >');
   Readln(FileSpec);
   if filespec[1]='*' then
      begin
      DidDir:=true;
      Lines:=0;
      findfirst(copy(filespec,2,length(filespec)),AnyFile,Dir);
      While DosError=0 do
         begin
         Writeln(Dir.name);
         inc(Lines);
         if lines=22 then
            begin
            Lines:=0;
            pause(23);
            writeln;
            end;
         FindNext(dir);
         end;
      end;
   end;
until DidDir=false;
if pos('.',filespec)=0 then
   filespec:=filespec+'.MAC';
assign(InF,filespec);
Reset(InF);
Readln(InF,NumOfStates);
for Indx:=1 to numofstates do
   begin
   for Indx2:=1 to ALPHALENGTH do
      Read(InF,Machine[Indx].Vectors[Indx2]);
   Readln(accept);
   if accept=0 then
      Machine[Indx].accept:=false
   else
      Machine[Indx].accept:=true;
   end;
close(Inf);
if WasInGr then
   GoToGraph;
DidTrace:=false
end;

procedure Driver;

var
   Indx:word;
   d:word;
   ch:char;

begin
GoToGraph;
SetTextStyle(0,0,3);
Cls;
FindMaxCharHeight;
Centerln(1,'Determinant');
Centerln(2,'Finite');
Centerln(3,'Automata');
Centerln(4,'Tracer');
pause(6);
Repeat
   begin
   ch:=Options;
   case ch of
      'T':if DidTrace then
             ReTraceMachine(Machine,Traced,MachineString)
          else
             begin
             GetMachineString(MachineString);
             TraceMachine(Machine,Traced,MachineString);
             end;
      'E':begin
          GetMachine(Machine,NumOfStates,MachineString);
          TraceMachine(Machine,Traced,MachineString);
          end;
      'S':ShowTrace(Traced,Machine);
      'L':LoadMachine(Machine);
      'I':Instructions;
      'V':SaveMachine(Machine);
      'W':ShowMachine(Machine);
      end;
   end;
until ch='X';
GoToText;
cls;
Centerln(1,'Goodbye!');
end;

begin
LInit:=False;
Driver;
GoToText;
end.
