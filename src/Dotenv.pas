unit Dotenv;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, StrUtils;

procedure LoadDotEnv(const FileName: string);
procedure RequireEnvVars(const RequiredVars: array of string);
function DotEnvGet(const Key: string; const DefaultValue: string = ''): string;

implementation

var
  EnvStore: TStringList;

function UnescapeValue(const S: string): string;
var
  I: Integer;
  C: Char;
  ResultStr: string;
begin
  ResultStr := '';
  I := 1;
  while I <= Length(S) do
  begin
    C := S[I];
    if C = '\' then
    begin
      Inc(I);
      if I <= Length(S) then
      begin
        case S[I] of
          'n': ResultStr := ResultStr + #10;
          'r': ResultStr := ResultStr + #13;
          't': ResultStr := ResultStr + #9;
          '\': ResultStr := ResultStr + '\';
          '"': ResultStr := ResultStr + '"';
        else
          ResultStr := ResultStr + S[I];
        end;
      end;
    end
    else
      ResultStr := ResultStr + C;
    Inc(I);
  end;
  Result := ResultStr;
end;

function ExpandVariables(const S: string): string;
var
  StartPos, EndPos: Integer;
  VarName, VarValue: string;
  ResultStr: string;
begin
  ResultStr := S;
  StartPos := Pos('${', ResultStr);
  while StartPos > 0 do
  begin
    EndPos := PosEx('}', ResultStr, StartPos);
    if EndPos = 0 then Break;

    VarName := Copy(ResultStr, StartPos + 2, EndPos - StartPos - 2);
    VarValue := DotEnvGet(VarName, '');
    ResultStr := Copy(ResultStr, 1, StartPos - 1) + VarValue + Copy(ResultStr, EndPos + 1, MaxInt);

    StartPos := Pos('${', ResultStr);
  end;
  Result := ResultStr;
end;

procedure LoadDotEnv(const FileName: string);
var
  Lines: TStringList;
  Line, Key, Value: string;
  EqPos, i: Integer;
begin
  if EnvStore = nil then
  begin
    EnvStore := TStringList.Create;
    EnvStore.NameValueSeparator := '=';
    EnvStore.CaseSensitive := False;
    EnvStore.Duplicates := dupIgnore;
  end;

  if not FileExists(FileName) then
    Exit;

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(FileName);
    for i := 0 to Lines.Count - 1 do
    begin
      Line := Trim(Lines[i]);
      if (Line = '') or (Line[1] = '#') then
        Continue;

      EqPos := Pos('=', Line);
      if EqPos = 0 then
        Continue;

      Key := Trim(Copy(Line, 1, EqPos - 1));
      Value := Trim(Copy(Line, EqPos + 1, MaxInt));

      // Remove quotes if present
      if (Length(Value) >= 2) and ((Value[1] = '"') and (Value[Length(Value)] = '"')) then
        Value := UnescapeValue(Copy(Value, 2, Length(Value) - 2))
      else if (Length(Value) >= 2) and ((Value[1] = '''') and (Value[Length(Value)] = '''')) then
        Value := Copy(Value, 2, Length(Value) - 2);

      // Expand ${VAR} using our internal store
      Value := ExpandVariables(Value);

      // Store in memory (overwrite if already present)
      EnvStore.Values[Key] := Value;
    end;
  finally
    Lines.Free;
  end;
end;

function DotEnvGet(const Key: string; const DefaultValue: string = ''): string;
begin
  if (EnvStore <> nil) and (EnvStore.IndexOfName(Key) <> -1) then
    Result := EnvStore.Values[Key]
  else
    Result := DefaultValue;
end;

procedure RequireEnvVars(const RequiredVars: array of string);
var
  VarName: string;
begin
  for VarName in RequiredVars do
  begin
    if DotEnvGet(VarName, '') = '' then
      raise Exception.CreateFmt('Required environment variable "%s" is not set!', [VarName]);
  end;
end;

initialization
  EnvStore := nil;

finalization
  EnvStore.Free;

end.
