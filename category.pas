unit category;

{$mode ObjFPC}{$H+}
{$MODESWITCH ADVANCEDRECORDS}
{$modeswitch TypeHelpers}
interface

uses
  Classes, SysUtils,changeEvent;

type

  { TCategory }

  TCategory = Class(TInterfacedObject)
  private
  fName:string;
  fId:string;
  fPlanId:string;
  fCategoryGroupId:string;
  fBudgeted: longInt;
  fActivity: longInt;
  fCategorySelected:Boolean;
  fCategoryChanged:TNotifyEvent;
  procedure setCategorySelection(selection_:boolean);
  function getCategorySelected:boolean;
  public
  constructor create(name_,id_,categoryGroupId,planId_:string; budgeted_,activity_:longInt;onCategoryChanged:TNotifyEvent);
  property name: string read fName;
  property id: string read fId;
  property budgeted:longInt read fBudgeted write fBudgeted;
  property activity:longInt read fActivity write fActivity;
  property categorySelected: boolean read getCategorySelected write setCategorySelection;
  end;

  TCategories = array of TCategory;

  { TCategoriesHelper }

  TCategoriesHelper = type Helper for TCategories
  function size: integer;
  function push(element:TCategory):integer;
  function indexOf(element:TCategory):integer;
  function findByName(elementName:string):TCategory;
  function findById(elementId:string):TCategory;
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

procedure TCategory.setCategorySelection(selection_: boolean);
var
  changeEvent_:TChangeEvent;
begin
  fCategorySelected:=selection_;
  changeEvent_:=TChangeEvent.Create(fPlanId,fCategoryGroupId,fId,TChangeType.CAT_SELECTION);
  fcategoryChanged(changeEvent_);
end;

function TCategory.getCategorySelected: boolean;
begin
  result:=fCategorySelected;
end;

constructor TCategory.create(name_, id_,categoryGroupId,planId_: string; budgeted_, activity_: longInt;onCategoryChanged:TNotifyEvent);
begin
  fName:=name_;
  fId:=id_;
  fCategoryGroupId:=categoryGroupId;
  fbudgeted:=budgeted_;
  fActivity:=activity_;
  fPlanId:=planId_;
  fCategoryChanged:=onCategoryChanged;
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
      if (Self[index].name.Trim = elementName.trim) then
        begin
          result:=self[index];
          exit;
        end;
    end;
end;

function TCategoriesHelper.findById(elementId: string): TCategory;
var
  index: integer;
begin
  result:=nil;
  if (self = nil) or (self.size = 0) then exit; //These are the same thing!
  for index:= 0 to pred(self.size) do
    begin
      if (Self[index].id.trim = elementId.trim) then
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

