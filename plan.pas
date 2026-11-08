unit plan;

{$mode ObjFPC}{$H+}
{$MODESWITCH ADVANCEDRECORDS}
{$modeswitch TypeHelpers}

interface

uses
  Classes, SysUtils,fpjson,categoryGroup;

type

  { TPlan }

  TPlan = class(TInterfacedObject)
    private
    fName: string;
    fId:string;
    fPlanServerKnowledge:string;
    fCatGroupsServerKnowledge:string;
    fCategoryGroups: TCategoryGroups;
    public
    constructor create(name_,id_:string);
    property name: string read fName;
    property id: string read fId;
    property categoryGroups:TCategoryGroups read fCategoryGroups write fCategoryGroups;
    property planServerKnowledge: String read fPlanServerKnowledge write fPlanServerKnowledge;
    property catGroupsServerKnowledge: string read fCatGroupsServerKnowledge write fCatGroupsServerKnowledge;
  end;

  { TPlans }
  TPlans = array of TPlan;

  { TPlanHelper }

  TPlanHelper = type Helper for TPlans
  function size: integer;
  function push(element:TPlan):integer;
  function indexOf(element:TPlan):integer;
  function findByName(elementName:string):TPlan;
  function findById(elementId:String):TPlan;
  procedure deleteByIndex(index:integer);
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

function TPlanHelper.findById(elementId: String): TPlan;
var
  index: integer;
begin
  result:=nil;
  if (self = nil) or (self.size = 0) then exit; //These are the same thing!
  for index:= 0 to pred(self.size) do
    begin
      if (Self[index].id = elementId) then
        begin
          result:=self[index];
          exit;
        end;
    end;
end;

procedure TPlanHelper.deleteByIndex(index:integer);
var
  currentPos:integer;
begin
  if (index > -1) then
  begin
    for currentPos:=index to pred(self.size) do
      if (currentPos < pred(self.size)) then self[currentPos]:= self[currentPos+1];
    setLength(Self,length(self)-1);
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
  fPlanServerKnowledge:='';
  fCatGroupsServerKnowledge:='';
end;


end.
