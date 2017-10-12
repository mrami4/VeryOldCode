program AreaCalc(input,output);

{Function RectangleArea modified, function TrapezoidArea created, procedure
 Driver, TheFunction modified all by Exalted Leader Marc Ramirez on 6/23/88}

const
    NUMINTERVALS = 100;     {the number of intervals tested}
    NUMBEROFPOINTS = 1000;  {number of points used in monte-carlo}

function TheFunction(x : real) : real;
{specification: this function used to driver other procedures
                The function should lie entirely above the x-axis
                for current implementation of the procedures(not any more)}
var y:real;

begin
    y:=1/(1+x*x);  {This local variable is used to make the formula
                    a bit more accessible, and to aid in debugging}
    TheFunction := abs(y); {Flips negative parts of graph onto the
                            positive}
end; {TheFunction}

{************************************************************************}

function ComputeMax(firstX,secondX : real) : real;
{specification: computes the maximum value of TheFunction
                between x-coordinates specified by the
                two parameters. Granularity of search is
                specified by global constant.}
var
    i : integer;            {loop variable}
    funcval : real;         {used to avoid repeated calls to TheFunction}
    MaxValue,               {maximum value of counter in the interval}
    increment : real;       {the value x-coordinate is incremented}
begin

    increment := (secondX - firstX)/NUMINTERVALS;

    MaxValue := 0;      {can start at 0 since function above x-axis}
    for i := 1 to NUMINTERVALS do
    begin
        funcval := TheFunction(firstX);
        if  funcval > MaxValue
        then
            MaxValue := funcval;
        firstX := firstX + increment;
    end;
    ComputeMax := MaxValue

end; {ComputeMax}

{************************************************************************}

function TrapezoidArea(firstX,secondX:real):real;
{spec.: computes area under a curve between x-coordinates specified by
        parameters by  using trapezoids.}

var
 bases:array[1..2] of real;
 area,increment:real;
 i:integer;

begin
area:=0;
bases[1]:=TheFunction(firstX);
increment:=(secondX-firstX)/NUMINTERVALS;
for i:=1 to NUMINTERVALS do
 begin
 firstX:=firstX+increment;
 bases[2]:=TheFunction(firstX);
 area:=area+((1.0/2.0)*(bases[1]+bases[2])*increment);
 bases[1]:=bases[2];
 end;
TrapezoidArea:=area;
end;         {TrapezoidArea}

{************************************************************************}

function RectangleArea(firstX,secondX : real) : real;
{specification: computes area under curve between x-coordinates
                specified by parameters by using rectangles evaluated
                at left-endpoints.}

var
    i : integer;
    increment, average, area, distance : real;
begin
    increment := (secondX - firstX)/NUMINTERVALS;
    distance:=secondx-firstx;
    area := 0;
    for i := 1 to NUMINTERVALS do
    begin
    area := area + TheFunction(firstX);
    firstX := firstX + increment
    end;
    average:=area/NUMINTERVALS;
    RectangleArea := average*distance;

end; {RectangleArea}

{************************************************************************}

function RandomArea(firstX,secondX : real) : real;
{specification: computes area under curve between x-coordinates
                specified by parameters using Monte-Carlo method.
                Number of points used is specified by local constant}
var
    increment,                  {used in calculation of random x-coordinate}
    RandomX,                    {random x-coordinate whose value is checked}
    RandomY,                    {random y-coordinate}
    MaxValue,                   {the largest function value in interval}
    LargerArea       : real;    {area of "dart board" (large rectangle)}

    i,                          {loop control}
    PointsUnderCurve : integer; {number of points under curve}
begin
    increment := (secondX - firstX)/NUMINTERVALS;
    PointsUnderCurve := 0;

    MaxValue := ComputeMax(firstX,secondX);
    for i := 1 to NUMBEROFPOINTS do
    begin
        RandomX := random(NUMINTERVALS)*increment + firstX;
        RandomY := random*MaxValue;

        if TheFunction(RandomX) > RandomY
        then
            PointsUnderCurve := PointsUnderCurve + 1;
    end;

    LargerArea := (secondX - firstX)*MaxValue;
    RandomArea := PointsUnderCurve/NUMBEROFPOINTS * LargerArea;

end; {RandomArea}

{************************************************************************}

procedure Driver;
var
    startX,
    endX,temp : real;
begin
    write('enter leftmost x-coordinate  > ');
    readln(startX);
    write('enter rightmost x-coordinate > ');
    readln(endX);

    if startX>endX then
      begin
      temp:=startX;
      startX:=endX;
      endX:=temp;
      end;

    writeln('Using ',NUMINTERVALS,' rectangles the area under the curve');
    writeln('= ',RectangleArea(startX,endX):4:4);

    writeln('Using a monte-carlo method with ',NUMBEROFPOINTS,' trials,');
    writeln('the area under the curve = ',RandomArea(startX,endX):4:4);

    Writeln('Using ',numintervals-1,' trapezoids the area under the curve');
    writeln('= ',TrapezoidArea(startX,endX):4:4);
end;

begin
    Driver;
end.