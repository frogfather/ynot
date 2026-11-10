unit Ynab;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,fpjson,xml_doc_handler,laz2_DOM,ynabApi,plan,ynabResponse,categoryGroup,category,changeEvent;

type
  
  { TYnab }

  TYnab = class(TInterfacedObject)
    private
    fXMLDocumentHandler:TXMLDocumentHandler;
    fDataFile:string;
    fApiToken:String;
    fPlans:TPlans;
    fCurrentPlan:TPlan;
    fDataChanged:TNotifyEvent;
    procedure toXML;
    procedure fromXML;
    procedure updateData;
    procedure onCategoryDataChanged(sender:TObject);
    function getPlansFromServer:TYNABResponse;
    function getPlanFromServer(plan_:TPlan):TYNABResponse;
    function getCategoriesFromServer(plan:TPlan):TYNABResponse;
    function groupIsValid(catGroupObject_:TJSONObject):boolean;
    public
    constructor create(apiToken_,dataFile_:String;onPlanChanged_:TNotifyEvent);
    function loadFromFile:Boolean;
    function saveToFile:Boolean;
    property xmlDocumentHandler:TXMLDocumentHandler read fXMLDocumentHandler;
    property dataFile:string read fDataFile;
    property plans:TPlans read fPlans;
    property currentPlan:TPlan read fcurrentPlan write fCurrentPlan;
  end;

implementation

{ TYnab }

//Only save data for plans that are active
procedure TYnab.toXML;
var
  planIndex,catGroupindex,categoryIndex:integer;
  plansNode,planNode,categoryGroupsNode,categoryGroupNode,categoriesNode,categoryNode:TDOMNode;
  planAttributes,categoryGroupsAttributes:TStringArray;
  currentPlanId:string;
begin
  planAttributes:=TStringArray.create;
  categoryGroupsAttributes:=TStringArray.create;
  setLength(planAttributes,2);
  setLength(categoryGroupsAttributes,2);
  planAttributes[0]:='server_knowledge';
  categoryGroupsAttributes[0]:='server_knowledge';
  with xmlDocumentHandler do
    begin
    initializeDoc;
    if assigned(currentPlan) then currentPlanId:=currentPlan.id else currentPlanId:='';
    addNode('','current-plan',currentPlanId);
    plansNode:=addNode('','plans');
    for planIndex:=0 to pred(fPlans.size) do
      begin
      planAttributes[1]:=fPlans[planIndex].planServerKnowledge;
      planNode:=createNode('plan','',planAttributes);
      planNode.AppendChild(createNode('name',fPlans[planIndex].name));
      planNode.AppendChild(createNode('id',fPlans[planIndex].id));

      categoryGroupsAttributes[1]:=fPlans[planIndex].catGroupsServerKnowledge;
      categoryGroupsNode:=createNode('categoryGroups','',categoryGroupsAttributes);
      for catGroupIndex:=0 to pred(fplans[planIndex].categoryGroups.size) do
        begin
        categoryGroupNode:=createNode('categoryGroup','');
        categoryGroupNode.AppendChild(createNode('name',fplans[planIndex].categoryGroups[catGroupIndex].name));
        categoryGroupNode.AppendChild(createNode('id',fplans[planIndex].categoryGroups[catGroupIndex].id));
        categoriesNode:=createNode('categories','');
        for categoryIndex:= 0 to pred(fplans[planIndex].categoryGroups[catGroupIndex].categories.size) do
          begin
          categoryNode:=createNode('category','');
          categoryNode.AppendChild(createNode('name',fplans[planIndex].categoryGroups[catGroupIndex].categories[categoryIndex].name));
          categoryNode.AppendChild(createNode('id',fplans[planIndex].categoryGroups[catGroupIndex].categories[categoryIndex].id));
          categoryNode.AppendChild(createNode('budgeted',fplans[planIndex].categoryGroups[catGroupIndex].categories[categoryIndex].budgeted.ToString));
          categoryNode.AppendChild(createNode('activity',fplans[planIndex].categoryGroups[catGroupIndex].categories[categoryIndex].activity.ToString));
          categoriesNode.AppendChild(categoryNode);
          end;
        categoryGroupNode.AppendChild(categoriesNode);
        categoryGroupsNode.AppendChild(categoryGroupNode);
        end;
      planNode.AppendChild(categoryGroupsNode);
      plansNode.AppendChild(planNode);
      end;
    end;
end;

procedure TYnab.fromXML;
var
  plansNode,planNode,categoryGroupNode,categoryNode,
    planNameNode,planIdNode,categoryGroupsNode,catGroupNameNode,
    catGroupIdNode,categoriesNode,categoryNameNode,categoryIdNode,
    categoryBudgetedNode,categoryActivityNode:TDOMNode;
  planEnumerator,categoryGroupEnumerator,categoryEnumerator:TDomNodeEnumerator;
  newPlan:TPlan;
  newCategoryGroup:TCategoryGroup;
  newCategory:TCategory;
  currentPlanId:string;
begin
  fPlans.clear;
  currentPlanId:= xmlDocumentHandler.getNodeTextValue('current-plan');
  plansNode:= xmlDocumentHandler.getNode('plans');
  if assigned(plansNode) and (plansNode.GetChildCount > 0) then
    begin
    planEnumerator:= plansNode.GetEnumerator;
    while planEnumerator.MoveNext do
      begin
      //Get the child nodes of the plan
      planNode:=planEnumerator.Current;
      //should check plan node child count
      planNameNode:=planNode.ChildNodes[0];
      planIdNode:=planNode.ChildNodes[1];
      categoryGroupsNode:=planNode.ChildNodes[2];
      newPlan:=TPlan.create(planNameNode.TextContent,planIdNode.TextContent);
      newPlan.planServerKnowledge:=planNode.Attributes.GetNamedItem('server_knowledge').TextContent;
      newPlan.catGroupsServerKnowledge:=categoryGroupsNode.Attributes.GetNamedItem('server_knowledge').TextContent;
      if (currentPlanId = planNode.ChildNodes[1].TextContent)
         then currentPlan:=newPlan;

      categoryGroupEnumerator:=categoryGroupsNode.GetEnumerator;
      while categoryGroupEnumerator.MoveNext do
        begin
        categoryGroupNode:=categoryGroupEnumerator.Current;
        //We should have at least 3 children - 0:name, 1:id, 2:categories
        catGroupNameNode:=categoryGroupNode.ChildNodes[0];
        catGroupIdNode:=categoryGroupNode.ChildNodes[1];
        categoriesNode:=categoryGroupNode.ChildNodes[2];
        newCategoryGroup:=TCategoryGroup.create(
                                                catGroupNameNode.TextContent,
                                                catGroupIdNode.TextContent,
                                                newPlan.id,
                                                @onCategoryDataChanged);
        categoryEnumerator:=categoriesNode.GetEnumerator;
        while categoryEnumerator.MoveNext do
          begin
          categoryNode:=categoryEnumerator.Current;
          categoryNameNode:=categoryNode.ChildNodes[0];
          categoryIdNode:=categoryNode.ChildNodes[1];
          categoryBudgetedNode:=categoryNode.ChildNodes[2];
          categoryActivityNode:=categoryNode.ChildNodes[3];
          newCategory:=TCategory.create(
                                        categoryNameNode.TextContent,
                                        categoryIdNode.TextContent,
                                        newCategoryGroup.id,
                                        newPlan.id,
                                        categoryBudgetedNode.TextContent.ToInt64,
                                        categoryActivityNode.TextContent.ToInt64,
                                        @onCategoryDataChanged);
          newCategoryGroup.categories.push(newCategory);
          end;
        newPlan.categoryGroups.push(newCategoryGroup);
        end;
       fPlans.push(newPlan);
      end;
    end;
end;

procedure TYnab.updateData;
var
  currentPlansResponse,currentPlanResponse,categoryGroupsResponse:TYNABResponse;
  currentPlansList,categoryGroupList,categoryList:TJSONArray;
  currentCatGroupObject,currentCategoryObject:TJSONObject;
  index,catGroupIndex,categoryIndex:integer;
  retrievedPlans:TPlans;
  retrievedCategoryGroups:TCategoryGroups;
  newCategoryGroup:TCategoryGroup;
  newCategory:TCategory;
  planServerKnowledge,catGroupsServerKnowledge:string;
  planName,planId:string;
  retrievalOK:boolean;
begin
  retrievalOK:=true;
  retrievedPlans:=TPlans.create;
  currentPlansResponse:=getPlansFromServer;
  if (currentPlansResponse.success = false) then
    begin
    exit; //Log error here
    end;
  currentPlansList:=TJSONObject(currentPlansResponse.results).Arrays['plans'];
  for index:=0 to pred(currentPlansList.Count) do
    begin
    planName:=TJSONObject(currentPlansList[index]).Get('name');
    planId:= TJSONObject(currentPlansList[index]).Get('id');
    retrievedPlans.push(TPlan.create(planName,planId));
    end;
  //Add missing
  for index:=0 to pred(retrievedPlans.size) do
    if (Plans.findById(retrievedPlans[index].id) = nil)
       then Plans.push(retrievedPlans[index]);
  //Remove deleted
  for index:=0 to pred(Plans.size) do
    if not assigned(retrievedPlans.findById(Plans[index].id))
       then Plans.deleteByIndex(index);
  //We can get each plan and see if it's changed
  for index:=0 to pred(Plans.size) do
    begin
    currentPlanResponse:=getPlanFromServer(plans[index]);
    if (currentPlanResponse.success = false) then
      begin
      //log an error
      retrievalOK:=false;
      break;
      end;
    if assigned(currentPlanResponse.results.FindPath('server_knowledge')) then
      begin
        planServerKnowledge:=currentPlanResponse.results.GetPath('server_knowledge').AsString;
        if (plans[index].planServerKnowledge = planServerKnowledge) then
        begin
        //Log that the plan has not changed
        break;
        end;
      end;
    plans[index].planServerKnowledge:=planServerKnowledge;
    //If the server knowledge has changed we need to update the categories for the plan
    categoryGroupsResponse:=getCategoriesFromServer(Plans[index]);
    if (categoryGroupsResponse.success = false) then
      begin
      //log an error and move on to next plan
      break;
      end;
    if assigned(categoryGroupsResponse.results.FindPath('server_knowledge')) then
      begin
      catGroupsServerKnowledge:=categoryGroupsResponse.results.GetPath('server_knowledge').AsString;
    if catGroupsServerKnowledge = plans[index].catGroupsServerKnowledge then
        begin
        //Log that category groups have not changed
        break;
        end;
      end;
    plans[index].catGroupsServerKnowledge:=catGroupsServerKnowledge;
    retrievedCategoryGroups:=TCategoryGroups.create;
    categoryGroupList:=TJSONObject(categoryGroupsResponse.results).Arrays['category_groups'];
    //For each category group that isn't hidden,internal or deleted
    //See if we already have a record of it
    for catGroupIndex:=0 to pred(categoryGroupList.Count) do
      begin
      currentCatGroupObject:=TJSONObject(categoryGroupList[catGroupIndex]);
      if (groupIsValid(currentCatGroupObject)) then
        begin
        newCategoryGroup:=TCategoryGroup.create(
                                                currentCatGroupObject.Get('name'),
                                                currentCatGroupObject.Get('id'),
                                                plans[index].id,
                                                @onCategoryDataChanged);
        categoryList:=currentCatGroupObject.Arrays['categories'];
        for categoryIndex:=0 to pred(categoryList.Count) do
          begin
          currentCategoryObject:=TJSONObject(categoryList[categoryIndex]);
          newCategory:=TCategory.create(
                                        currentCategoryObject.Get('name'),
                                        currentCategoryObject.Get('id'),
                                        newCategoryGroup.id,
                                        plans[index].id,
                                        currentCategoryObject.Get('budgeted'),
                                        currentCategoryObject.Get('activity'),
                                        @onCategoryDataChanged);
          newCategoryGroup.categories.push(newCategory);
          end;
        retrievedCategoryGroups.push(newCategoryGroup);
        end;
      end;
    plans[index].categoryGroups:=retrievedCategoryGroups;
    end;
  if retrievalOK then saveToFile;
end;

procedure TYnab.onCategoryDataChanged(sender: TObject);
begin
  fDataChanged(sender);
  //Fire notify event indicating something has changed
end;

function TYnab.getPlansFromServer: TYNABResponse;
var
  ynabApi: TYnabApi;
begin
  ynabApi:=TYNABApi.create(fApiToken);
  result:=ynabApi.getPlans;
end;

function TYnab.getPlanFromServer(plan_:TPlan):TYNABResponse;
var
  ynabApi: TYnabApi;
begin
  ynabApi:=TYNABApi.create(fApiToken);
  result:=ynabApi.getPlan(plan_.id,plan_.planServerKnowledge);

end;

function TYnab.getCategoriesFromServer(plan:TPlan): TYNABResponse;
var
  ynabApi: TYnabApi;
begin
  ynabApi:=TYNABApi.create(fApiToken);
  result:=ynabApi.getCategories(plan.id,plan.catGroupsServerKnowledge);
end;

function TYnab.groupIsValid(catGroupObject_: TJSONObject): boolean;
var
  groupName:string;
begin
  result:=false;
  groupName:=catGroupObject_.Get('name');
  writeln(groupName);
  if (catGroupObject_.IndexOfName('hidden') > -1)
     and not (catGroupObject_.FindPath('hidden').IsNull)
     and (catGroupObject_.Get('hidden',false) = true) then exit;

  if (catGroupObject_.IndexOfName('internal') > -1)
     and not (catGroupObject_.FindPath('internal').IsNull)
     and (catGroupObject_.Get('internal',false) = true) then exit;

  if (catGroupObject_.IndexOfName('deleted') > -1)
     and not (catGroupObject_.FindPath('deleted').IsNull)
     and (catGroupObject_.Get('deleted',false) = true) then exit;
  result:=true;
end;

constructor TYnab.create(apiToken_,dataFile_: String;onPlanChanged_:TNotifyEvent);
begin
  fXMLDocumentHandler:=TXMLDocumentHandler.create('ynot');
  fApiToken:=apiToken_;
  //Set to empty values in case there's no data file.
  fPlans:=TPlans.create;
  fCurrentPlan:=nil;
  fDataFile:=dataFile_;
  fDataChanged:=onPlanChanged_;
  //Call various apis based on server_knowledge
  loadFromFile;
  updateData;
end;

function TYnab.loadFromFile: Boolean;
begin
  result:=false;
  if fileExists(dataFile) then
    begin
    xmlDocumentHandler.load(dataFile);
    fromXML;
    result:=true;
    end;
end;

function TYnab.saveToFile: Boolean;
begin
  result:=false;
  toXML;
  xmlDocumentHandler.save(dataFile);
  result:=true;
end;

end.

