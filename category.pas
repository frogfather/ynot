unit category;

{$mode ObjFPC}{$H+}
{$MODESWITCH ADVANCEDRECORDS}
{$modeswitch TypeHelpers}
interface

uses
  Classes, SysUtils;

type

  { TCategory }

  TCategory = Class(TInterfacedObject)
  private
  fName:string;
  fId:string;
  fBudgeted: longInt;
  fActivity: longInt;
  public
  constructor create(name_,id_:string; budgeted_,activity_:longInt);
  property name: string read fName;
  property id: string read fId;
  property budgeted:longInt read fBudgeted write fBudgeted;
  property activity:longInt read fActivity write fActivity;
  end;

  TCategories = array of TCategory;

  { TCategoriesHelper }

  TCategoriesHelper = type Helper for TCategories
  function size: integer;
  function push(element:TCategory):integer;
  function indexOf(element:TCategory):integer;
  function findByName(elementName:string):TCategory;
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

{ TCategory }

constructor TCategory.create(name_, id_: string; budgeted_, activity_: longInt);
begin
  fName:=name_;
  fId:=id_;
  fbudgeted:=budgeted_;
  fActivity:=activity_;
end;

{ TCategoriesHelper }

function TCategoriesHelper.size: integer;
begin
  result:=length(self);
end;

function TCategoriesHelper.push(element: TCategory): integer;
begin
  if (self.indexOf(element) = -1) then
  setLength(self, succ(self.size));
  self[pred(self.size)] := element;
  result:=self.size;
end;

function TCategoriesHelper.indexOf(element: TCategory): integer;
begin
  result:= specialize getIndex<TCategory>(element,self);
end;

function TCategoriesHelper.findByName(elementName: string): TCategory;
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

procedure TCategoriesHelper.clear;
begin
  setLength(self,0);
end;

end.

