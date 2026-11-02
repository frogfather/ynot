unit Ynab;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,fpjson,xml_doc_handler,laz2_DOM,ynabApi,plan,ynabResponse,categoryGroup;

type
  
  { TYnab }

  TYnab = class(TInterfacedObject)
    private
    fXMLDocumentHandler:TXMLDocumentHandler;
    fApiToken:String;
    fPlans:TPlans;
    fCurrentPlan:TPlan;
    procedure toXML;
    procedure fromXML;
    procedure updateData;
    function getPlansFromServer:TJSONArray;
    public
    constructor create(apiToken_,dataFile_:String);
    function loadFromFile(fileName_:String):Boolean;
    function saveToFile(fileName_:String):Boolean;
    property xmlDocumentHandler:TXMLDocumentHandler read fXMLDocumentHandler;
    property plans:TPlans read fPlans;
    property currentPlan:TPlan read fcurrentPlan;
  end;

implementation

{ TYnab }

//Only save data for plans that are active
procedure TYnab.toXML;
var
  planIndex,catGroupindex:integer;
  plansNode,planNode,categoryGroupsNode,categoryGroupNode,categoriesNode,categoryNode:TDOMNode;
  planAttributes,categoryGroupsAttributes:TStringArray;
begin
  setLength(planAttributes,2);
  setLength(categoryGroupsAttributes,2);
  planAttributes[0]:='server_knowledge';
  categoryGroupsAttributes[0]:='server_knowledge';
  with xmlDocumentHandler do
    begin
    initializeDoc;
    addNode('','current-plan',currentPlan.id);
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
        categoryGroupsNode.AppendChild(categoryGroupNode);
        end;

      planNode.AppendChild(categoryGroupsNode);
      plansNode.AppendChild(planNode);
      end;
    end;
end;

procedure TYnab.fromXML;
begin

end;

//Call various apis to update the current data
//plans doesn't have a server_knowledge property
procedure TYnab.updateData;
var
  currentPlans:TJSONArray;
  index:integer;
begin
  currentPlans:=getPlansFromServer;
  if (currentPlans.Count <> fPlans.size) then
    begin
    //replace with current data
    fPlans.clear;
    for index:=0 to pred(currentPlans.Count) do
      fPlans.push(TPlan.create(currentPlans[index]));
    end;
end;

function TYnab.getPlansFromServer: TJSONArray;
var
  ynabApi: TYnabApi;
  getPlansResponse:TYnabResponse;
begin
  ynabApi:=TYNABApi.create(fApiToken);
  getPlansResponse:=ynabApi.getPlans;
  if (getPlansResponse.success = true) then
    begin
    result:=TJSONObject(getPlansResponse.results).Arrays['plans'];
    //Add any missing plans
    end else
    begin
    result:=TJSONArray.Create;
    end;

end;

constructor TYnab.create(apiToken_,dataFile_: String);
begin
  fXMLDocumentHandler:=TXMLDocumentHandler.create;
  fApiToken:=apiToken_;
  //Set to empty values in case there's no data file.
  fPlans:=TPlans.create;
  fCurrentPlan:=nil;
  //Call various apis based on server_knowledge
  loadFromFile(dataFile_);
  updateData;
end;

function TYnab.loadFromFile(fileName_: String): Boolean;
begin
  result:=false;
  if fileExists(fileName_) then
    begin
    xmlDocumentHandler.load(fileName_);
    fromXML;
    result:=true;
    end;
end;

function TYnab.saveToFile(fileName_: String): Boolean;
begin
  result:=false;
  if fileExists(fileName_) then
    begin
    toXML;
    xmlDocumentHandler.save(fileName_);
    result:=true;
    end;
end;

end.

