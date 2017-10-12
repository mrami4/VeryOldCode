{
 A copious comment:
 A machine is stored as an array of states.
 A state is stored as a boolean to tell whether or not it accepts, and
  vectors to tell where to go for each letter of alphabet.
 The alphabet is stored as a string containing every character in that
  alphabet.
 To input a state, you must tell if it accepts, and where to go for each
  character.
 The '*' wildcard during state input denotes all characters that have
  not been specified.
 A machine file is stored as:

  The number of characters in the alphabet.
  The number of states in the machine.
  from 1 to the number of states
    where state x should go for each character,
    last number is 0 if rejecting, -1 if accepting

 The instructions have not been updated since the fixed alphabet version.
  (it does have a good illustration)
 Characters not in alphabet are treated as an else vector (as in illustration)
 The trace is stored as a linked list.
 The functions Make, Tack, and Kill belong to TraceList.
}

program DeterminantFiniteStateMachines;

uses Crt,Graph,Dos;

const
   MAXSTATES=256;
   ALPHALENGTH=2;
   ALPHABET:string='01';
   DidTrace:boolean=false;
   DidMachine:Boolean=false;
   CharHeight:integer=8;
   InGr:boolean = false;
   GrInit:boolean = false;
   OptionArray:array [1..11] of string[19]=('[E]nter machine    ',  {1}
                                           '[I]nstructions     ',   {2}
                                           '[L]oad machine     ',   {3}
                                           'e[X]it             ',   {4}
                                           're[T]race machine  ',   {5}
                                           '[T]race machine    ',   {6}
                                           'sho[W] machine     ',   {7}
                                           '[S]how execution   ',   {8}
                                           'sa[V]e machine     ',   {9}
                                           '[E]nter new machine',   {10}
                                           'e[D]it machine     '); {11}
   OptionsDidMachine:array[0..8] of integer=(8,2,10,3,9,6,7,11,4);
   OptionsDidTrace:array[0..9] of integer=(9,2,10,3,9,5,7,8,11,4);
   OptionsStart:array[0..4] of integer=(4,2,1,3,4);
   KeysStart='IELX';
   KeysDidMachine='IELXVTWD';
   KeysDidTrace='IELXVTWSD';

type
   StateType=record
                accept:boolean; {True if accepting state}
                Vectors:array[1..ALPHALENGTH] of word;  {Vector table}
             end;
	MachineType=record
						Machine:array [1..MAXSTATES] of StateType;
                  NumOfStates:integer;
               end;
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
   MaxX,MaxY:word;      {X and Y resolution}
   Mode,Drivr:integer;  {Screen mode and driver #}

{-----------Procedure Table Of Contents------------------------------}

{-----------General Purpose Procedures-------------------------------}

procedure GoToText; forward;
procedure GoToGraph; forward;
procedure ClearS; forward;
procedure Cls; forward;
procedure Center(row:integer;ToWrite:string); forward;
procedure Centerln(row:integer;ToWrite:string); forward;
procedure WriteAt(row,col:integer;ToWrite:string); forward;
procedure Pause(line:integer); forward;

{-----------Machine-Making procedures--------------------------------}

procedure GetMachineString(var MachineString:string); forward;
procedure FillInMachine(From,UpTo:integer;var M:MachineType); forward;
procedure GetMachine(var M:MachineType); forward;

{-----------Machine-Tracing procedures-------------------------------}

procedure Make(var l:TraceType;s:integer;e:integer;w:integer); forward;
procedure Tack(var l:TraceType;s:Integer;e:integer;w:integer); forward;
procedure Kill(var l:tracetype); forward;
procedure TraceMachine(var M:MachineType;var Traced:TraceType;MachineString:string;var LInit:boolean); forward;
procedure ReTraceMachine(M:MachineType;Traced:TraceType;MachineString:string;LInit:boolean); forward;
procedure ShowTrace(Traced:TraceType;var M:MachineType); forward;

{-----------Machine Editing procedures-------------------------------}

procedure DisplayVector(var M:MachineType;VectorRow,VectorCol,FirstRow,FirstCol,Color:integer); forward;
procedure DisplayTable(FirstRow,LastRow,FirstCol,LastCol:integer;var M:MachineType); forward;
procedure AddStates(var Ending:integer;var StartNum:integer;var M:MachineType); forward;
procedure ChangeVector(var M:MachineType;State:integer;Vector:integer); forward;
procedure IncCol(var M:MachineType;var Start,Nd,Current:integer); forward;
procedure IncRow(var Start,Nd,Current:integer); forward;
procedure DecAll(var Start,Nd,Current:integer); forward;
procedure ChangeState(Start,Current:integer;var M:MachineType); forward;
procedure EditStates(var Start,nd,Current:integer;StartRow,EndRow:integer;var M:MachineType); forward;
procedure EditMachine(var M:MachineType); forward;

{-----------Machine Transference procedures--------------------------}

procedure ShowMachine(var M:MachineType); forward;
procedure SaveMachine(var M:MachineType); forward;
procedure LoadMachine(var M:MachineType); forward;

{-----------Instructions---------------------------------------------}

procedure Instructions; forward;

{-----------Miscellaneous--------------------------------------------}

procedure FindMaxCharHeight; forward;

{-----------General-Purpose functions--------------------------------}

function GetInt(Prompt:string;MnInt,MxInt:integer):integer; forward;
function GetChar(Prompt:string;Acceptable:string):Char; forward;
function Strng(d:integer):string; forward;
function GetIntAt(X,Y:Integer;Prompt:string;MnInt,MxInt:integer):Integer; forward;

{-----------Menu function--------------------------------------------}

function Options:char; forward;

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
   InitGraph(Gd,Gm,'');
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
      halt(1);
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
			case LastMode of
				mono:TextMode(mono);
				bw40:textMode(bw80);
				bw80:textmode(bw80);
				co40,co80:textmode(co80);
			end;
		end;
TextAttr:=White;
end;

procedure Center;
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


procedure Centerln;
{
 Centers string 'ToWrite' on row 'row' and writes a CR-LF.
}

begin
Center(row,ToWrite);
if not InGr then
   Writeln;
end;

procedure WriteAt;

{
 Writes 'ToWrite' at row,col independent of screen mode.
}

begin
if InGr then
   OutTextXY(col*CharHeight,row*CharHeight,ToWrite)
else
   begin
   GoToXY(col,row);
   Write(ToWrite);
   end;
end;

procedure Pause;
{
 Writes 'Press a key when ready...' on line 'line' and waits for a keystroke.
 (independent of screen mode)
}

var
   d:char;

begin
Center(line,'Press a key when ready...');
d:=ReadKey;
Center(line,'                         ');
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
Center(1,'This program traces finite automata (finite state machines).  The program will ');
Center(2,'give you a menu to [E]nter a machine, [L]oad a file, come here, or e[X]it.     ');
Center(3,'Entering a machine consists of entering the number of states in a machine, if  ');
Center(4,'the state is an acceptance or rejection state, and where it sholud jump on     ');
Center(5,'character X of the alphabet.  A useful character is the * character, which     ');
Center(6,'repersents all characters not yet specified (an else vector).  The loading     ');
Center(7,'process consists of prompting you for a filename, and loading the file.  The   ');
Center(8,'default extension for all machine files is ''.MAC''.  If the file specification  ');
Center(9,'is preceded by a *, the following string is treated as a directory wildcard,   ');
Center(10,'and a directory listing is produced. (For example, **.MAC will display all     ');
Center(11,'files with a ''.MAC'' extension.)  After a machine has been put into memory,     ');
Pause(13);
Cls;
Center(1,'some items are added to the menu.  First, you now have the option of saving    ');
Center(2,'your machine.  Save works just like load (with no directory function).  You    ');
Center(3,'will also see [T]race, which allows you to enter a string and see if the       ');
Center(4,'machine accepted or rejected it.  You will also see sho[W] machine, which      ');
Center(5,'displays the machine in a table like the one shown below.  There is also the   ');
Center(6,'e[D]it machine function, which I will now go into detail about.  When you start');
Center(7,'the edit machine function, you will see the machine laid out in a fasion       ');
Center(8,'resembling the show machine function.  But if you move the cursor keys, you    ');
Center(9,'will notice that different numbers will flash.  The cursor is represented by    ');
Center(10,'making the number that it is on flash.  To change a number, place the cursor   ');
Center(11,'on that number and press Enter.  It will then prompt you for a vector to       ');
Center(20,'  1   2   3   4   5   ');
Center(21,'  A   R   R   R   R   ');
Center(22,'  --------------------');
Center(23,'0|1   3   5   2   4   ');
Center(24,'1|2   4   1   3   5   ');
Center(18,'Divisible by 5');
Pause(13);
Cls;
Center(1,'replace the old vector.  ''A'' will add states to the machine.  The add command  ');
Center(2,'uses the same format as the enter machine command.  ''S'' moves the cursor into  ');
Center(3,'the accepting/rejecting field of the states and lets you change them.  And, the');
Center(4,'Esc key leaves the editing screen.  After you do a trace, you have the option  ');
Center(5,'of [S]howing the trace, which lists the path the program took to execute the   ');
Center(6,'machine.  A note: when the machine is executed, all non-alphabetic characters  ');
Center(7,'point to the state the machine is currently in. (A drawing is shown below for  ');
Center(8,'the binary alphabet.)                                                          ');
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

function GetInt;
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

Function GetChar;
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



procedure GetMachineString;

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

function Strng;
{
 Functionized version of Str.
}

var ds:string;

begin
Str(d,ds);
Strng:=ds;
end;


procedure FillInMachine;

var
   DNum2,DNum3:integer;
   DCh:char;
   HasBeenEntered:string;
   Jump:integer;

begin
for DNum2:=From to UpTo do
   begin
   for DNum3:=1 to ALPHALENGTH do
      M.Machine[DNum2].Vectors[DNum3]:=0;
   HasBeenEntered:='';
   writeln('State ',DNum2);
   case UpCase(GetChar('   (A)ccepting or (R)ejecting >','ARar')) of
      'A':M.Machine[DNum2].accept:=True;
      'R':M.Machine[DNum2].accept:=False;
      end;
   repeat
      begin
      DCh:=GetChar('   on character >',ALPHABET+'*');
      Jump:=GetInt('   go to        >',1,upto);
      if DCh='*' then
         begin
         for DNum3:=1 to ALPHALENGTH do
            begin
            if M.Machine[DNum2].Vectors[DNum3]=0 then
               M.Machine[DNum2].vectors[DNum3]:=jump;
            end;
         end
      else
         begin
         M.Machine[DNum2].Vectors[Pos(DCh,ALPHABET)]:=jump;
         if pos(DCh,HasBeenEntered)=0 then
            HasBeenEntered:=HasBeenEntered+DCh;
         end;
      end;
   until (DCh='*') or (length(HasBeenEntered)=ALPHALENGTH);
   end;
end;



procedure GetMachine;
{
 Lets user input the machine in the form number of states, A,R (accepting or
 rejecting), and where to go on 0 and 1.
}

var
   DString:string;
   DNum:integer;
   WasInGr:boolean;

begin
WasInGr:=InGr;
GoToText;
Centerln(1,'Enter your machine:');
DNum:=GetInt('Enter number of states (1 - '+Strng(MAXSTATES)+') >',1,maxstates);
FillInMachine(1,DNum,M);
M.NumOfStates:=DNum;
DidTrace:=false;
DidMachine:=true;
if WasInGr then
   GoToGraph;
end;


procedure Make;
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


procedure Tack;
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


procedure Kill;
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


Procedure TraceMachine;
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
If LInit then
   begin
   Kill(Traced);
   LInit:=false;
   end;
At:=1;
LastState:=M.Machine[at].accept;
for Indx:=1 to length(MachineString) do
   begin
   if Pos(MachineString[Indx],ALPHABET)=0 then
      Enc:=-1
   else
      Enc:=Pos(MachineString[Indx],ALPHABET);
   if Enc>0 then
      Jump:=M.Machine[at].Vectors[Enc]
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
   LastState:=M.Machine[at].accept;
   end;
Center(1,'String');
Center(2,MachineString);
if LastState then
   Center(3,'Accepted')
else
   Center(3,'Rejected');
DidTrace:=true;
Pause(5);
end;


function Options;
{
 Displays the post-trace menu and returns a character in the set of menu
 choices.
}

var
   ch:char;
   Indx:integer;
   Legal:string;
   Cols:integer;

begin
GoToGraph;
Cls;
Center(1,'Your options are:');
if DidMachine then
   if DidTrace then
      begin
      for Indx:=1 to OptionsDidTrace[0] do
         Center(Indx+2,OptionArray[OptionsDidTrace[Indx]]);
      Cols:=OptionsDidTrace[0];
      Legal:=KeysDidTrace;
      end
   else
      begin
      for Indx:=1 to OptionsDidMachine[0] do
         Center(Indx+2,OptionArray[OptionsDidMachine[Indx]]);
      Cols:=OptionsDidMachine[0];
      Legal:=KeysDidMachine;
      end
else
   begin
   for Indx:=1 to OptionsStart[0] do
      Center(Indx+2,OptionArray[OptionsStart[Indx]]);
   Cols:=OptionsStart[0];
   Legal:=KeysStart;
   end;
Center(3+cols+2,'Which shall you do???????');
repeat
   ch:=UpCase(ReadKey);
until pos(ch,Legal)<>0;
Options:=ch;
end;

procedure ReTraceMachine;

begin
GoToText;
Cls;
Write('Enter new string >');
Readln(MachineString);
TraceMachine(M,Traced,MachineString,LInit);
end;

procedure ShowTrace;

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
   if M.Machine[Traced^.state].accept then
      write(OutF,'accepting')
   else
      write(OutF,'rejecting');
   write(OutF,'), I encountered ');
   if Traced^.encountered>0 then
      Write(OutF,ALPHABET[Traced^.encountered])
   else
      Write(OutF,'a non-alphabetic character');
   if Traced^.WentTo=Traced^.state then
      writeln(OutF,' and stayed.')
   else
      writeln(OutF,' and went to ',Traced^.WentTo,'.');
   x:=Traced^.WentTo;
   Traced:=Traced^.next;
   end;
Write(OutF,'At ',x:3,' I ');
if M.Machine[x].Accept then
   Writeln(OutF,'accepted')
else
   Writeln(OutF,'rejected');
close(OutF);
Traced:=BegL;
Pause(25);
end;

procedure ShowMachine;

var
   Indx,Indx2:integer;
   OutF:text;
   DevcSpec:string;
   WasInGr:boolean;

begin
WasInGr:=InGr;
GoToGraph;
Cls;
for Indx:=1 to M.NumOfStates do
   begin
   WriteAt(3,Indx*4+3,Strng(Indx));
   if M.Machine[Indx].accept then
      WriteAt(4,Indx*4+3,'A')
   else
      WriteAt(4,Indx*4+3,'R');
   WriteAt(5,Indx*4+3,'---');
   end;
for Indx:=1 to ALPHALENGTH do
   begin
   WriteAt(Indx+5,4,Alphabet[Indx]+'|');
   end;
for Indx:=1 to M.NumOfStates do
   begin
   for Indx2:=1 to ALPHALENGTH do
      begin
      WriteAt(Indx2+5,Indx*4+3,Strng(M.Machine[Indx].Vectors[Indx2]));
      end;
   end;
Pause(25);
if WasInGr then
   GoToGraph
else
   GoToText;
end;

procedure DisplayVector;
{
 Writes the machine vector for character VectorRow in state VectorCol.
}

var
  LastAttr:Byte;
  Formula1,Formula2:integer;

begin
LastAttr:=TextAttr;
TextAttr:=byte(Color);
Formula1:=((VectorCol-FirstCol)*4)+3;
Formula2:=VectorRow-FirstRow+5;
GoToXY(Formula1,Formula2);
Write('    ');
GoToXY(Formula1,Formula2);
Write(M.Machine[VectorCol].Vectors[VectorRow]);
TextAttr:=LastAttr;
end;


procedure DisplayTable;
{
 Writes a table for the machine (like ShowMachine)
}

var
   DInt,Indx,Indx2:integer;

begin
for Indx:=FirstCol to LastCol do
   begin
   DInt:=((Indx-FirstCol)*4)+3;
   GoToXY(DInt,2);
   Write('    ');
   GoToXY(DInt,2);
   Write(Indx);
   GoToXY(DInt,3);
   if M.Machine[Indx].Accept then
      Write('A')
   else
      Write('R');
   GoToXY(DInt,4);
   Write('----');
   end;
for Indx:=FirstRow to LastRow do
   begin
   GoToXY(1,Indx-FirstRow+5);
   Write(Alphabet[Indx],'| ');
   end;
For Indx:=FirstCol to LastCol do
   for Indx2:=FirstRow to LastRow do
      begin
      DisplayVector(M,Indx2,Indx,FirstRow,FirstCol,White);
      end;
end;

procedure AddStates;
{
 Adds extra states onto the machine.
}

var
   DNum:integer;

begin
Cls;
Centerln(1,'Enter extra states:');
DNum:=GetInt('How many extra states do you want? >',1,MAXSTATES-M.NumOfStates);
FillInMachine(M.NumOfStates+1,M.NumOfStates+DNum,M);
M.NumOfStates:=M.NumOfStates+DNum;
StartNum:=1;
if M.NumOfStates>19 then
   Ending:=19
else
   Ending:=M.NumOfStates;
Cls;
end;

function GetIntAt;

var
   DInt,DInt2:integer;
   DString:string;
   DCh:char;

begin
repeat
   begin
   GoToXY(x,y);
   write(Prompt);
   readln(DInt);
   if (Dint<MnInt) or (DInt>MxInt) then
      begin
      GoToXY(x,y);
      for DInt:=1 to length(prompt)+length(Strng(DInt)) do
         Write(' ');
      GoToXY(x,y);
      DString:='Number must be between '+Strng(MnInt)+' and '+Strng(MxInt)+
                  '.  Press a key...';
      Writeln(DString);
      DCh:=ReadKey;
      GoToXY(x,y);
      for DInt:=1 to length(DString) do
         Write(' ');
      end;
   end;
until (DInt>=MnInt) and (DInt<=MxInt);
GetIntAt:=DInt;
GoToXY(x,y);
for DInt2:=1 to length(Prompt)+Length(Strng(DInt)) do
   Write(' ');
end;



procedure ChangeVector;
{
 Changes vector for character Vector in state State.
}

var
   DNum:integer;

begin
DNum:=GetIntAt(1,1,'Old vector was '+Strng(M.Machine[State].Vectors[Vector])+
                   '.  New vector is >',1,M.NumOfStates);
M.Machine[State].Vectors[Vector]:=DNum;
end;

procedure IncCol;
{
 Scrolls table left (called Inc because it scoots the range forward one.
}

begin
Inc(Nd);
if Nd>M.NumOfStates then
   Dec(Nd)
else
   begin
   Inc(Start);
   Inc(Current);
   end;
if Current>Nd then
   Current:=Nd;
end;

procedure IncRow;
{
 Scrolls table up.
}

begin
Inc(Nd);
if Nd>ALPHALENGTH then
   Dec(Nd)
else
   begin
   Inc(Start);
   Inc(Current);
   end;
if Current>Nd then
   Current:=Nd
end;

procedure DecAll;
{
 Scrolls table left or down (ambiguous parameters, specificity not needed)
}

begin
Dec(Start);
if Start<1 then
   Inc(Start)
else
   begin
   Dec(Nd);
   Dec(Current);
   end;
if Current<Start then
   Current:=Start;
end;

procedure ChangeState;
{
 prompts user for an A or R.
}

var
   Indx:integer;
   DCh:Char;
   DString,DString2:String;

begin
Repeat
   begin
   GoToXY(1,1);
   DString:='Old state was ';
   if m.Machine[Current].accept then
      DString:=DString+'accepting'
   else
      DString:=DString+'rejecting';
   DString:=DString+'.  What should I make it? (A/R) >';
   Write(DString);
   Readln(DString2);
   DCh:=DString2[1];
   GoToXY(1,1);
   for Indx:=1 to length(DString)+Length(DString2) do
      Write(' ');
   if not (UpCase(DCh) in ['A','R']) then
      begin
      gotoXY(1,1);
      DString:='The character must be A or R. Press a key.';
      Write(DString);
      DString[5]:=ReadKey;
      for Indx:=1 to length(DString) do
         Write(' ');
      end;
   end;
until UpCase(DCh) in ['A','R'];
if UpCase(DCh)='A' then
   M.Machine[Current].Accept:=True
else
   M.Machine[Current].Accept:=False;
end;

procedure EditStates;

{
 Procedure for editing acceptance/rejection.
}

const
   ROW=3;
   WantsToEnd:boolean=False;

var
   DCh:Char;
   Formula:integer;
   Old:integer;
   Moved:boolean;

begin
Old:=Current;
repeat
   begin
   Moved:=False;
   Formula:=((Current-Start)*4)+3;
   GoToXY(Formula,ROW);
   TextAttr:=White+Blink;
   if M.Machine[Current].Accept then
      Write('A')
   else
      Write('R');
   TextAttr:=White;
   DCh:=UpCase(ReadKey);
   if DCh=#0 then
      DCh:=UpCase(ReadKey);
   case DCh of
      #13:ChangeState(Start,Current,M);
      #27:WantsToEnd:=True;
      'K':begin
          Dec(Current);
          if Current<Start then
             begin
             Moved:=True;
             DecAll(Start,nd,Current);
             end;
          end;
      'M':begin
          Inc(Current);
          if Current>Nd then
             begin
             Moved:=True;
             IncCol(M,Start,Nd,Current);
             end;
          end;
      end;
   if (Moved=True) and (Old<>Current) then
      DisplayTable(StartRow,EndRow,Start,nd,M);
   GoToXY(Formula,ROW);
   TextAttr:=White;
   if M.Machine[Old].Accept then
      Write('A')
   else
      Write('R');
   Old:=Current;
   end;
until WantsToEnd;
end;


procedure EditMachine;

{
 Basically a spreadsheet procedure.
}

Const
   Col=false;
   Row=true;

var
   CurrentRow,CurrentCol,StartRow,StartCol:integer;
   DCh:char;
   Cols,Rows,EndCol,EndRow:integer;
   OldRow,OldCol:integer;
   WantsToEnd:boolean;
   Moved:boolean;

begin
GoToText;
Cls;
if M.NumOfStates<20 then
   Cols:=M.NumOfStates
else
   Cols:=19;
StartCol:=1;
EndCol:=Cols;
if M.NumOfStates<21 then
   Rows:=M.NumOfStates
else
   Rows:=20;
StartRow:=1;
if ALPHALENGTH<21 then
   EndRow:=ALPHALENGTH
else
   EndRow:=20;
OldRow:=1;
OldCol:=1;
DisplayTable(StartRow,EndRow,StartCol,EndCol,M);
CurrentRow:=StartRow;
CurrentCol:=StartCol;
WantsToEnd:=false;
repeat
   begin
   DisplayVector(M,CurrentRow,CurrentCol,StartRow,StartCol,LightGray*16);
   GoToXY(1,1);
   Moved:=False;
   Write('Command>');
   DCh:=UpCase(ReadKey);
   if DCh in ['A'..'Z'] then
      Write(DCh);
   if DCh=#0 then
      begin
      DCh:=ReadKey;
      end;
   case DCh of
      'A':AddStates(EndCol,StartCol,M);
      #13:ChangeVector(M,CurrentCol,CurrentRow);
      'H':begin
          Dec(CurrentRow);
          Write(#24);
          if CurrentRow<StartRow then
             begin
             Moved:=True;
             DecAll(StartRow,EndRow,CurrentRow);
             end;
          end;
      'K':begin
          Dec(CurrentCol);
          Write(#27);
          if CurrentCol<StartCol then
             begin
             Moved:=True;
             DecAll(StartCol,EndCol,CurrentCol);
             end;
          end;
      'M':begin
          Inc(CurrentCol);
          Write(#26);
          if CurrentCol>EndCol then
             begin
             Moved:=True;
             IncCol(M,StartCol,EndCol,CurrentCol);
             end;
          end;
      'P':begin
          Inc(CurrentRow);
          Write(#25);
          if CurrentRow>EndRow then
             begin
             Moved:=True;
             IncRow(StartRow,EndRow,CurrentRow);
             end;
          end;
      #27:WantsToEnd:=true;
      'S':begin
          DisplayVector(M,CurrentRow,CurrentCol,StartRow,StartCol,White);
          EditStates(StartCol,EndCol,CurrentCol,StartRow,EndRow,M);
          end;
      end;
   if (DCh='A') or (Moved and ((CurrentCol<>OldCol) or (CurrentRow<>OldRow)))
                                                                          then
      begin
      if CurrentCol>EndCol then
         CurrentCol:=EndCol;
      DisplayTable(StartRow,EndRow,StartCol,EndCol,M);
      end;
   DisplayVector(M,OldRow,OldCol,StartRow,StartCol,White);
   OldRow:=CurrentRow;
   OldCol:=CurrentCol;
   end;
until WantsToEnd=true;
end;



procedure SaveMachine;

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
Writeln(OutF,M.NumOfStates);
for Indx:=1 to M.NumOfStates do
   begin
   for Indx2:=1 to ALPHALENGTH do
      Write(OutF,M.Machine[indx].Vectors[Indx2],' ');
   if M.Machine[indx].accept then
      Writeln(OutF,-1)
   else
      Writeln(OutF,0);
   end;
Close(OutF);
if WasInGr then
   GoToGraph;
end;

procedure LoadMachine;
{Loads}

var
   FileSpec:string;
   InF:text;
   Indx,Indx2,Alphanum:integer;
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
            Pause(23);
            writeln;
            end;
         FindNext(dir);
         end;
      end;
   end;
until DidDir=false;
M.NumOfStates:=0;
if pos('.',filespec)=0 then
   filespec:=filespec+'.MAC';
assign(InF,filespec);
Reset(InF);
Readln(InF,Alphanum);
if Alphanum<>ALPHALENGTH then
   begin
   Writeln('This file has a different alphabet!!! I can''t load this!');
   Pause(25);
   end
else
   begin
   Readln(InF,M.NumOfStates);
   for Indx:=1 to M.NumOfStates do
     begin
      for Indx2:=1 to ALPHALENGTH do
         Read(InF,M.Machine[Indx].Vectors[Indx2]);
      Readln(InF,accept);
      if accept=0 then
         M.Machine[Indx].accept:=false
      else
         M.Machine[Indx].accept:=true;
      end;
   end;
close(Inf);
if WasInGr then
   GoToGraph;
if M.NumOfStates<>0 then
   begin
   DidTrace:=false;
   DidMachine:=true;
   end;
end;

procedure Driver(var M:MachineType;
                 var MachineString:String;
                 Traced:TraceType;
                 var LInit:boolean);

var
   Indx:word;
   d:word;
   ch:char;

begin
GoToGraph;
Cls;
FindMaxCharHeight;
Centerln(1,'Determinant');
Centerln(2,'Finite');
Centerln(3,'Automata');
Centerln(4,'Tracer');
Pause(6);
Repeat
   begin
   ch:=Options;
   case ch of
      'E':GetMachine(M);
      'L':LoadMachine(M);
      'I':Instructions;
      end;
   if DidMachine then
      case ch of
         'T':if DidTrace then
                ReTraceMachine(M,Traced,MachineString,LInit)
             else
                begin
                GetMachineString(MachineString);
                TraceMachine(M,Traced,MachineString,LInit);
                end;
         'S':ShowTrace(Traced,M);
         'V':SaveMachine(M);
         'W':ShowMachine(M);
         'D':EditMachine(M);
         end;
   end;
until ch='X';
GoToText;
Cls;
Centerln(1,'Goodbye!');
end;

var
   M:MachineType; {Array to store the machine}
   MachineString:string;{String the machine will use}
   traced:TraceType;    {Linked list of the execution path}
   LInit:boolean;       {Tells if the list has been initialized}

begin
TextAttr:=White;
LInit:=False;
Driver(M,MachineString,Traced,LInit);
GoToText;
end.
