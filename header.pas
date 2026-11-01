unit header;

{$mode ObjFPC}{$H+}
{$MODESWITCH ADVANCEDRECORDS}
{$modeswitch TypeHelpers}

interface

uses
  Classes, SysUtils;
type
  
  { THeader }

  THeader = class(TInterfacedObject)
    private
    fkey:string;
    fvalue:string;
    public
    Constructor create(key,value:string);
    property key:string read fKey;
    property value: string read fValue write fValue;
  end;

  THeaders = array of THeader;

  THeaderHelper = type Helper for THeaders
  function size: integer;
  function push(element:THeader):integer;
  function indexOf(element:THeader):integer;
  function findByKey(key:string):THeader;
  procedure clear;
  procedure delete(header:THeader);
  end;

implementation

generic function GetIndex<T>(aItem:T; aArr: specialize TArray<T>): SizeInt;
begin
  for Result := 0 to High(aArr) do
    if aArr[Result] = aItem then
      Exit;
  Result := -1;
end;

{ THeader }

constructor THeader.create(key, value: string);
begin
  fKey:=key;
  fValue:=value;
end;

{ THeaderHelper }
function THeaderHelper.size: integer;
begin
  result:=length(self);
end;

function THeaderHelper.push(element: THeader): integer;
begin
  if (self.indexOf(element) = -1) then
  setLength(self, succ(self.size));
  self[pred(self.size)] := element;
  result:=self.size;
end;

function THeaderHelper.indexOf(element: THeader): integer;
begin
  result:= specialize getIndex<THeader>(element,self);
end;

function THeaderHelper.findByKey(key: string): THeader;
var
  index: integer;
begin
  result:=nil;
  if (self = nil) or (self.size = 0) then exit; //These are the same thing!
  for index:= 0 to pred(self.size) do
    begin
      if (Self[index].key = key) then
        begin
          result:=self[index];
          exit;
        end;
    end;
end;

procedure THeaderHelper.clear;
begin
  setLength(self,0);
end;

procedure THeaderHelper.delete(header: THeader);
var
  itemAt, index:integer;
begin
  itemAt:=self.indexOf(header);
  if (itemAt > -1) then
  begin
    for index:=itemAt to pred(self.size) do
      if (index < pred(self.size)) then self[index]:= self[index+1];
    setLength(Self,length(self)-1);
  end;
end;

end.

