unit categoryGroup;

{$mode ObjFPC}{$H+}
{$MODESWITCH ADVANCEDRECORDS}
{$modeswitch TypeHelpers}

interface

uses
  Classes, SysUtils,category,changeEvent;

type
  
  { TCategoryGroup }

  TCategoryGroup = Class(TInterfacedObject)
  private
  fName:string;
  fId:string;
  fPlanId:string;
  fCategoryGroupSelected:boolean;
  fCategories:TCategories;
  fCategoryGroupChanged:TNotifyEvent;
  function getCategoryGroupSelected:boolean;
  procedure setCategoryGroupSelection(selection_: boolean);
  public
  constructor create(name_,id_,planId_:string;onCatGroupChanged:TNotifyEvent);
  property name: string read fName;
  property id: string read fId;
  property GroupSelected: boolean read getCategoryGroupSelected write setCategoryGroupSelection;
  property categories: TCategories read fCategories;
  end;

  TCategoryGroups = array of TCategoryGroup;

  { TCategoryGroupHelper }

  TCategoryGroupHelper = type Helper for TCategoryGroups
  function size: integer;
  function push(element:TCategoryGroup):integer;
  function indexOf(element:TCategoryGroup):integer;
  function findByName(elementName:string):TCategoryGroup;
  function findById(elementId:string):TCategoryGroup;
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

{ TCategoryGroup }

procedure TCategoryGroup.setCategoryGroupSelection(selection_:boolean);
var
  index:integer;
begin
  fCategoryGroupSelected:=selection_;
  for index:=0 to pred(fCategories.size) do
    fCategories[index].categorySelected:=fCategoryGroupSelected;
  fCategoryGroupChanged(TChangeEvent.create(fPlanId,fId,'',TChangeType.CAT_GROUP_SELECTION));
end;

function TCategoryGroup.getCategoryGroupSelected: boolean;
begin
  result:=fCategoryGroupSelected;
end;

constructor TCategoryGroup.create(name_,id_,planId_: string;onCatGroupChanged:TNotifyEvent);
begin
  fName:=name_;
  fId:=id_;
  fCategoryGroupChanged:=onCatGroupChanged;
  fPlanId:=planId_;
end;

{ TCategoryGroupHelper }

function TCategoryGroupHelper.size: integer;
begin
  result:=length(self);
end;

function TCategoryGroupHelper.push(element: TCategoryGroup): integer;
begin
  if (self.indexOf(element) = -1) then
  setLength(self, succ(self.size));
  self[pred(self.size)] := element;
  result:=self.size;
end;

function TCategoryGroupHelper.indexOf(element: TCategoryGroup): integer;
begin
  result:= specialize getIndex<TCategoryGroup>(element,self);
end;

function TCategoryGroupHelper.findByName(elementName: string): TCategoryGroup;
var
  index: integer;
begin
  result:=nil;
  if (self = nil) or (self.size = 0) then exit; //These are the same thing!
  for index:= 0 to pred(self.size) do
    begin
      if (Self[index].name.trim = elementName.trim) then
        begin
          result:=self[index];
          exit;
        end;
    end;
end;

function TCategoryGroupHelper.findById(elementId: string): TCategoryGroup;
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

procedure TCategoryGroupHelper.clear;
begin
  setLength(self,0);
end;

end.

