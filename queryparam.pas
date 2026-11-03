unit queryParam;

{$mode ObjFPC}{$H+}
{$MODESWITCH ADVANCEDRECORDS}
{$modeswitch TypeHelpers}

interface

uses
  Classes, SysUtils;

type
  
  { TQueryParam }

  TQueryParam = class(TInterfacedObject)
  private
  fParamName:String;
  fParamValue:String;
  public
  constructor create(paramName_,paramValue_:String);
  property paramName: string read fParamName;
  property paramValue: string read fParamValue write fParamValue;
  end;

  { TQueryParams }
  TQueryParams = array of TQueryParam;

  { TQueryParamsHelper }

  TQueryParamsHelper = type Helper for TQueryParams
  function size: integer;
  function indexOf(element:TQueryParam):integer;
  function push(element:TQueryParam):integer;
  function findByName(elementName:string):TQueryParam;
  procedure delete(queryParam_:TQueryParam);
  procedure clear;
  function toString:String;
  end;

implementation

generic function GetIndex<T>(aItem:T; aArr: specialize TArray<T>): SizeInt;
begin
  for Result := 0 to High(aArr) do
    if aArr[Result] = aItem then
      Exit;
  Result := -1;
end;

{ TQueryParam }

constructor TQueryParam.create(paramName_, paramValue_: String);
begin
  fParamName:=paramName_;
  fParamValue:=paramValue_;
end;

{ TQueryParamsHelper }

function TQueryParamsHelper.size: integer;
begin
  result:=length(self);
end;

function TQueryParamsHelper.indexOf(element: TQueryParam): integer;
begin
  result:= specialize getIndex<TQueryParam>(element,self);
end;

function TQueryParamsHelper.push(element: TQueryParam): integer;
begin
  if (self.findByName(element.paramName) = nil) then
  setLength(self, succ(self.size));
  self[pred(self.size)] := element;
  result:=self.size;
end;

function TQueryParamsHelper.findByName(elementName: string): TQueryParam;
var
  index: integer;
begin
  result:=nil;
  if (self = nil) or (self.size = 0) then exit; //These are the same thing!
  for index:= 0 to pred(self.size) do
    begin
      if (Self[index].paramName = elementName) then
        begin
          result:=self[index];
          exit;
        end;
    end;
end;

procedure TQueryParamsHelper.delete(queryParam_: TQueryParam);
var
  itemAt, index:integer;
begin
  itemAt:=self.indexOf(queryParam_);
  if (itemAt > -1) then
  begin
    for index:=itemAt to pred(self.size) do
      if (index < pred(self.size)) then self[index]:= self[index+1];
    setLength(Self,length(self)-1);
  end;
end;

procedure TQueryParamsHelper.clear;
begin
  setLength(self,0);
end;

function TQueryParamsHelper.toString: String;
var
  index:integer;
begin
  result:='';
  for index:= 0 to pred(self.size) do
    begin
    result:=result+self[index].paramName+'='+self[index].paramValue;
    if (index < pred(self.size)) then result:=result+'&';
    end;
end;

end.

