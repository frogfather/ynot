unit plan;

{$mode ObjFPC}{$H+}
{$MODESWITCH ADVANCEDRECORDS}
{$modeswitch TypeHelpers}

interface

uses
  Classes, SysUtils,fpjson;

type

  { TPlan }

  TPlan = class(TInterfacedObject)
    private
    fName: string;
    fId:string;
    fServerKnowledge:string;
    public
    constructor create(name_,id_:string);
    constructor create(plan_data_:TJSONData);
    property name: string read fName;
    property id: string read fId;
    property serverKnowledge: String read fServerKnowledge write fServerKnowledge;
  end;

  { TPlans }
  TPlans = array of TPlan;

  { TPlanHelper }

  TPlanHelper = type Helper for TPlans
  function size: integer;
  function push(element:TPlan):integer;
  function indexOf(element:TPlan):integer;
  function findByName(elementName:string):TPlan;
  procedure clear;
  end;

implementation

generic function GetIndex<T>(aItem:T; aArr: specialize TArray<T>): SizeInt;
begin
  for Result := 0 to High(aArr) do
    if aArr[Result] = aItem then
      Exit;
  Result := -1;
end;

{ TPlanHelper }

function TPlanHelper.size: integer;
begin
  result:=length(self);
end;

function TPlanHelper.push(element: TPlan): integer;
begin
  if (self.indexOf(element) = -1) then
  setLength(self, succ(self.size));
  self[pred(self.size)] := element;
  result:=self.size;
end;

function TPlanHelper.indexOf(element: TPlan): integer;
begin
  result:= specialize getIndex<TPlan>(element,self);
end;

function TPlanHelper.findByName(elementName: string): TPlan;
var
  index: integer;
begin
  result:=nil;
  if (self = nil) or (self.size = 0) then exit; //These are the same thing!
  for index:= 0 to pred(self.size) do
    begin
      if (Self[index].name = elementName) then
        begin
          result:=self[index];
          exit;
        end;
    end;
end;

procedure TPlanHelper.clear;
begin
  setLength(self,0);
end;

{ TPlan }

constructor TPlan.create(name_,id_: string);
begin
  fName:=name_;
  fId:=id_;
end;

constructor TPlan.create(plan_data_: TJSONData);
begin
  fName:=plan_data_.GetPath('name').AsString;
  fId:=plan_data_.GetPath('id').AsString;
end;

end.
