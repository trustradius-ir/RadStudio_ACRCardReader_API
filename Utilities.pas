unit Utilities;

interface
uses SysUtils;
type
  TDelimiters           = set of Char;

  function OrdD(const From: string; const Index: integer): integer;     overload;
  function OrdD(const From: widestring; const Index: integer): integer; overload;
  function HexStringToString(const Input: string): string;
  function WordToBytes(const Input: word): string;
  function BinToHexExt(const Input: string; const Spaces: boolean = true; const UpCase: boolean = true): string;
  function BinToHex(const Input: string): string;
  function SortOutSubstrings(const From: string; var Values: array of string;
                             const Delim: TDelimiters = [' ',';'];
                             const ConcatDelim: boolean = true): integer;
  function StringtoHex(Data: AnsiString): AnsiString;
  function StringtoHexMerge(Data: AnsiString): AnsiString;
  function BytesToCardinal(const Input: ansistring): cardinal;


implementation
const
  HexChars      = '0123456789ABCDEFabcdef';

function BytesToCardinal(const Input: ansistring): cardinal;
begin
  case Length(Input) of
    0  : Result := 0;
    1  : Result := Ord(Input[1]);
    2  : Result := (Ord(Input[1]) shl 8) + Ord(Input[2]);
    3  : Result := (Ord(Input[1]) shl 16) + (Ord(Input[2]) shl 8) + Ord(Input[3]);
    else Result := (Ord(Input[1]) shl 24) + (Ord(Input[2]) shl 16) + (Ord(Input[3]) shl 8) + Ord(Input[4]);
    end;
end;

function StringtoHexMerge(Data: AnsiString): AnsiString;
var
  i, i2: Integer;
  Res: string;
begin
  Res := '';
  for i := 1 to Length(Data) do
  begin
    Res := Res + IntToHex(Ord(Data[i]), 2);
  end;
  Result := Res;
end;

function StringtoHex(Data: AnsiString): AnsiString;
var
  i, i2: Integer;
  Res: string;
begin
  Res := '';
  for i := 1 to Length(Data) do
  begin
    Res := Res + IntToHex(Ord(Data[i]), 2);
    if i < Length(Data) then Res := Res + ' ';
  end;
  Result := Res;
end;

function OrdD(const From: string; const Index: integer): integer;
begin
  if (Index < 1) or
     (Index > Length(From)) then Result := 0
                            else Result := Ord(From[Index]);
end;

function OrdD(const From: widestring; const Index: integer): integer;
begin
  if (Index < 1) or
     (Index > Length(From)) then Result := 0
                            else Result := Ord(From[Index]);
end;
function HexStringToString(const Input: string): string;
var
  Hex, Output: string;
  i,j        : integer;
begin
  Hex := StringOfChar(#0,Length(Input));
  i := 1;
  j := 1;
  while i <= Length(Input) do
    begin
    if Pos(Input[i], HexChars) > 0 then
      begin
      Hex[j] := Input[i];
      Inc(j);
      end;
    Inc(i);
    end;
  Hex := Trim(Hex);
  i := 1;
  if Length(Hex) > 1 then
    repeat
    Output := Output + Chr(StrToInt('$' + Copy(Hex,i,2)));
    Inc(i,2);
    until i > Length(Hex);
  Result := Output;
end;

function WordToBytes(const Input: word): string;
begin
  Result := HexStringToString(IntToHex(Input,4));
end;

function EightToSevenBit(const Input: string): string;
var
  BitQueue : integer;
  NumBits  : integer;
  NextBits : integer;
  i        : integer;
begin
  BitQueue := 0;
  NumBits  := 0;
  for i := 1 to Length(Input) do
    begin
    NextBits := Ord(Input[i]) and $7F;
    BitQueue := BitQueue or (NextBits shl NumBits);
    NumBits  := NumBits + 7;
    if NumBits > 7 then
       begin
       Result   := Result + Chr(BitQueue and $FF);
       BitQueue := BitQueue shr 8;
       NumBits  := NumBits - 8;
       end;
    end;
  if NumBits > 0 then Result := Result + Chr(BitQueue and $FF);
end;


function BinToHexExt(const Input: string; const Spaces: boolean = true; const UpCase: boolean = true): string;
var
  Loop      : integer;
  HexResult : string;
begin
  if Spaces then SetLength(HexResult,Length(Input) * 3)
            else SetLength(HexResult,Length(Input) * 2);
  if Spaces then
    for Loop := 1 to Length(Input) do
      begin
      HexResult[Loop*3-2] := HexChars[((Ord(Input[Loop]) and $F0) shr 4) + 1];
      HexResult[Loop*3-1] := HexChars[ (Ord(Input[Loop]) and $0F)        + 1];
      HexResult[Loop*3]   := ' ';
      end
  else HexResult := BinToHex(Input);
  if UpCase then Result := AnsiUpperCase(HexResult)
            else Result := AnsiLowerCase(HexResult);
end;

function BinToHex(const Input: string): string;
var
  Loop : integer;
  s    : string;
begin
  SetLength(s,Length(Input) * 2);
  for Loop := 1 to Length(Input) do
    begin
    s[Loop*2-1] := HexChars[((Ord(Input[Loop]) and $F0) shr 4) + 1];
    s[Loop*2]   := HexChars[ (Ord(Input[Loop]) and $0F)        + 1];
    end;
  Result := s;
end;


function SortOutSubstrings(const From: string; var Values: array of string;
                           const Delim: TDelimiters = [' ',';'];
                           const ConcatDelim: boolean = true): integer;
var
  i,Start,Len,TheEnd : integer;
  LastCharWasSep     : boolean;
  ValPtr             : integer;
begin
  i      := 1;
  ValPtr := Low(Values);
  TheEnd := Length(From);
  Start  := 0;
  Len    := 0;
  LastCharWasSep := ConcatDelim;
  Values[ValPtr] := '';

  while i <= TheEnd do
    begin
    if not (From[i] in Delim) then
      begin
      Inc(Len);
      LastCharWasSep := false;
      end
    else
      begin
      if not LastCharWasSep then
        begin
        SetString(Values[ValPtr],PChar(From) + Start,Len);
        Inc(ValPtr);
        if ValPtr > High(Values) then Break;
        Values[ValPtr] := '';
        end;
      if ConcatDelim then LastCharWasSep := true;
      Start := i;
      Len := 0;
      end;
    Inc(i);
    end;

  if (ValPtr <= High(Values)) and (Len > 0) then
    begin
    SetString(Values[ValPtr],PChar(From) + Start,Len);
    Inc(ValPtr);
    end;

  for i := ValPtr to High(Values) do Values[i] := '';
  Result := ValPtr - Low(Values);
end;

end.
