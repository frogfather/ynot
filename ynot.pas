unit ynot;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, fpjson, StdCtrls,
  CheckLst, ynab, fileUtilities, plan,categoryGroup,category,changeEvent;

type

  { TForm1 }

  TForm1 = class(TForm)
    cbPlans: TComboBox;
    clbCatGroups: TCheckListBox;
    lbMessages: TListBox;
    lPlans: TLabel;
    procedure cbPlansChange(Sender: TObject);
    procedure clbCatGroupsClickCheck(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure syncCatGroupSelection(groupName_,name_:string;selected_:boolean;changeType:TChangeType);
  private
    procedure populatePlans;
    procedure onPlansChanged(sender:TObject);
  public

  end;

var
  Form1: TForm1;
  fYnab:TYnab;

implementation

{$R *.lfm}

const configFile = '.ynot/settings.csv';
const dataFile = '.ynot/data.xml';
{ TForm1 }

procedure TForm1.FormShow(Sender: TObject);
var
  fileLines:TStringArray;
  index:integer;
  filePath,token:string;
begin
  filePath:=getUserDir+configFile;
  if fileexists(filePath) then
    begin
    fileLines:=openFileAsArray(filePath, #$0A);
    if (length(fileLines) > 0) then for index:= 0 to pred(length(filelines)) do
      begin
        if (fileLines[index].Split(',')[0] = 'ApiToken')
          then token:=fileLines[index].Split(',')[1];
      end;

    if (token <> '') then
      fYnab:=TYnab.create(token,getUserDir+dataFile,@onPlansChanged) else
      begin
      messagedlg('','No api token found. Set API token',mtError,[mbOK],'');
      //Exit at this point, but allow user to enter token
      application.Terminate;
      end;
    //Populate the plans dropdown
    populatePlans;
    end;
end;

procedure TForm1.syncCatGroupSelection(groupName_,name_: string; selected_: boolean;changeType:TChangeType);
var
  index:integer;
  nameToFind,currentItem:string;
  currentGroupName:string;
begin
  If changeType = TChangeType.CAT_GROUP_SELECTION
     then nameToFind:=name_ else nameToFind:='  '+name_;

  for index:=0 to pred(clbCatGroups.Items.Count) do
    begin
    currentItem:=clbCatGroups.Items[index];
    if not currentItem.StartsWith('  ')
       then currentGroupName:=clbCatGroups.Items[index];

    if (nameToFind = currentItem)
    and (currentGroupName = groupName_)
    and (clbCatGroups.Checked[index] <> selected_) then
      begin
      clbCatGroups.Checked[index]:=selected_;
      exit;
      end;
    end;
end;

procedure TForm1.cbPlansChange(Sender: TObject);
var
  catGroupIndex,catIndex:integer;
  selectedPlan:TPlan;
begin
  //First set the current plan
  clbCatGroups.Clear;
  selectedPlan:= fYnab.plans.findByName(cbPlans.Text);
  if not assigned(selectedPlan) then exit;
  fYnab.currentPlan:=selectedPlan;
  //When the plan changes, list all the categories.
  for catGroupIndex:=0 to pred(selectedPlan.categoryGroups.size) do
    begin
    clbCatGroups.Items.Add(fYnab.currentPlan.categoryGroups[catGroupIndex].name);
    for catIndex:=0 to pred(fYnab.currentPlan.categoryGroups[catGroupindex].categories.size) do
      begin
      clbCatGroups.Items.Add('  '+fYnab.currentPlan.categoryGroups[catGroupIndex].categories[catIndex].name);
      end;
    end;
  //Need to save selected info and retain it when syncing.
end;

procedure TForm1.clbCatGroupsClickCheck(Sender: TObject);
var
  index:integer;
  currentGroupName,currentCategoryName:string;
  currentGroup:TCategoryGroup;
  currentCategory:TCategory;
begin
  for index:=0 to pred(clbCatGroups.Items.Count) do
    begin
    if not clbCatGroups.Items[index].StartsWith('  ')
       then currentGroupName:=clbCatGroups.Items[index];
    if clbCatGroups.Selected[index] then
      begin
      //If it starts with spaces it's a category whose group is the currently
      //set group
      currentGroup:=fYNab.currentPlan.categoryGroups.findByName(currentGroupname);
      if assigned(currentGroup) then
         begin
         if clbCatGroups.Items[index].StartsWith('  ') then
           begin
           currentCategoryName:=clbCatGroups.Items[index].Trim;
           currentCategory:=currentGroup.categories.findByName(currentCategoryName);
           if assigned(currentCategory) then currentCategory.categorySelected:=clbCatGroups.Checked[index];
           end else currentGroup.GroupSelected:=clbCatGroups.Checked[index];
         end else lbMessages.Items.insert(0,'Could not find group with name '+currentGroupName);
      end;
    end;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
if not assigned(fYnab) then exit;
fYnab.saveToFile;
end;

procedure TForm1.populatePlans;
var
  planIndex:integer;
  currentPlanIndex:integer;
begin
  cbPlans.Clear;
  currentPlanIndex:=-1;
  if not assigned(fYnab) then exit;
  for planIndex:=0 to pred(fYnab.plans.size) do
    begin
    cbPlans.Items.Add(fYnab.plans[planIndex].name);
    if fYnab.plans[planIndex].id = fYnab.currentPlan.id
      then currentPlanIndex:=planIndex;
    end;
  cbPlans.ItemIndex:=currentPlanIndex;
  cbPlansChange(cbPlans);
end;
//If the category group selected status changes, then the category group itself
//will change the selected status of all the categories it owns to match
//So this event will be triggered once for the group and once for each category
procedure TForm1.onPlansChanged(sender: TObject);
var
  catgroup:TCategoryGroup;
  changedCategory:TCategory;
begin
  if not assigned(fYnab) then exit;
  if sender is TChangeEvent then with sender as TChangeEvent do
    begin
    if (fYnab.currentPlan.id <> planId) then exit;
    if (changeType = TChangeType.CAT_GROUP_SELECTION) then
      begin
      catGroup:=fYnab.currentPlan.categoryGroups.findById(catGroupId);
      if assigned(catGroup) then
        begin
        lbMessages.Items.Insert(0,'Group '+catGroup.name+' selected status changed '+catGroup.GroupSelected.ToString);
        syncCatGroupSelection(catGroup.name,catGroup.name,catGroup.GroupSelected,changeType);
        end;
      end else
    if (changeType = TChangeType.CAT_SELECTION) then
      begin
      //Find the categoryGroup for this category
      catGroup:=fYnab.currentPlan.categoryGroups.findById(catGroupId);
      if assigned(catGroup) then
         begin
         changedCategory:=catGroup.categories.findById(categoryId);
         if assigned(changedCategory) then
           begin
           lbMessages.Items.Insert(0,'Category '+changedCategory.name+' in group '+catGroup.name+' selected status changed '+changedCategory.categorySelected.ToString);
           syncCatGroupSelection(catGroup.name,changedCategory.name,changedCategory.categorySelected,changeType);
           end;
         end;
      end;
    end;
end;


end.

