unit xml_doc_handler;

{$mode objfpc}{$H+}
interface

uses
  Classes, SysUtils,
  laz2_DOM,
  laz2_XMLRead,
  laz2_XMLWrite,
  laz2_XMLUtils;

type
  { TXMLDocumentHandler }

  TXMLDocumentHandler = class(TInterfacedObject)
    private
    fDocument:TXMLDocument;
    function findInXML(
      startNode: TDomNode;
      nodeName: string;
      findTextValue: boolean): TDomNode;
    function getNode(
      node: TDOMNode;
      findTextValue: boolean): TDOMNode;
    procedure addAttributes(node:TDOMNode; attributes: TStringArray);
    procedure addTextValue(node:TDOMNode; textValue:string);
    public
    constructor create;
    procedure initializeDoc;
    procedure setDocument(doc:TXMLDocument);
    function createNode(
      nodeName:string;
      Text: string= '';
      attributes:TStringArray = nil):TDOMNode;
    function getNode(
      nodeName: string;
      findTextValue: boolean=false;
      parent:TDOMNode=nil;
      addIfNotFound:boolean=false): TDomNode;
    function addNode(
      parent, child: string;
      Text: string = '';
      attributes:TStringArray = nil):TDOMNode;
    function addNode(
      parent, child: TDOMNode;
      Text: string = '';
      attributes: TStringArray = nil): TDOMNode;
    function getNodeTextValue(nodeName:string):string;
    function getNodeAttributes(nodeName:string):TDOMNamedNodeMap;
    function load(filename: string):boolean;
    procedure save(filename: string);
    property document:TXMLDocument read fDocument write setDocument;
  end;


implementation

{ TXMLDocumentHandler }
function TXMLDocumentHandler.load(filename: string):boolean;
begin
  try
    result:=true;
    if FileExists(filename) then
       ReadXMLFile(fDocument, filename)
    else result:=false;
    except
      //log an error
    end;
end;

procedure TXMLDocumentHandler.save(filename: string);
begin
  if fDocument = nil then exit;
  writeXMLFile(fDocument, filename);
end;

function TXMLDocumentHandler.findInXML(startNode: TDomNode; nodeName: string;
  findTextValue: boolean): TDomNode;
var
  Count: integer;
  currentNodeName: string;
begin
  Result := nil;
  If startNode = nil then exit;
  if findTextValue then
    currentNodeName := startNode.textContent
  else
    currentNodeName := startNode.NodeName;
  if currentNodeName = nodeName then
    Result := startNode
  else if startNode.ChildNodes.Count > 0 then
    for Count := 0 to pred(startNode.ChildNodes.Count) do
    begin
      Result := findInXml(startNode.ChildNodes[Count], nodeName, findTextValue);
      if Result <> nil then
        exit;
    end;
end;

function TXMLDocumentHandler.addNode(parent,child: string; Text: string; attributes: TStringArray): TDOMNode;
var
  parentNode, childNode: TDOMNode;
begin
  if parent <> '' then
    begin
    parentNode := getNode(parent);
    if parentNode = nil then exit;
    end else parentNode:= document.DocumentElement;
  childNode := document.CreateElement(child);
  result:= addNode(parentNode,childNode,text,attributes);
end;

function TXMLDocumentHandler.addNode(parent, child: TDOMNode; Text: string; attributes: TStringArray): TDOMNode;
begin
  if child = nil then exit;
  addTextValue(child,text);
  addAttributes(child,attributes);
  parent.AppendChild(child);
  result:= child;
end;

function TXMLDocumentHandler.getNode(node: TDOMNode;findTextValue: boolean): TDOMNode;
begin
  result:=getNode(node.NodeName,findTextValue);
end;

procedure TXMLDocumentHandler.addAttributes(node:TDOMNode; attributes: TStringArray);
var
  attrIndex:integer;
begin
  if length(attributes) > 0 then
    attrIndex:=0;
    while attrIndex < pred(length(attributes)) do
      begin
      TDOMElement(node).SetAttribute(attributes[attrIndex], attributes[attrIndex+1]);
      attrIndex:=attrIndex + 2;
      end;
end;

procedure TXMLDocumentHandler.addTextValue(node: TDOMNode; textValue: string);
var
  textNode: TDOMNode;
begin
  if (TextValue <> '') then
    begin
    textNode := document.CreateTextNode(TextValue);
    node.AppendChild(textNode);
    end;
end;

function TXMLDocumentHandler.getNode(nodeName: string;
  findTextValue: boolean; parent: TDOMNode; addIfNotFound: boolean): TDomNode;
var
  startNode,foundNode: TDomNode;
begin
  if parent = nil then
     startNode := document
  else startNode:= parent;
  foundNode := findInXml(startNode, nodeName, findTextValue);
  if (foundNode = nil) and (addIfNotFound) then
    foundNode:= addNode(startNode.NodeName,nodeName);
  result:= foundNode;
end;

function TXMLDocumentHandler.getNodeTextValue(nodeName: string): string;
var
  foundNode:TDOMNode;
begin
  result:='';
  foundNode:=getNode(nodeName);
  if (foundNode <> nil) then result:= foundNode.TextContent;
end;

function TXMLDocumentHandler.getNodeAttributes(nodeName: string): TDOMNamedNodeMap;
var
  foundNode:TDOMNode;
begin
  result:=nil;
  foundNode:=getNode(nodeName,true);
  if (foundNode <> nil) then result:= foundNode.Attributes;
end;

constructor TXMLDocumentHandler.create;
begin
  initializeDoc;
end;

procedure TXMLDocumentHandler.initializeDoc;
begin
  fDocument:=TXMLDocument.Create;
  fDocument.AppendChild(fDocument.CreateElement('git-what'));
end;


procedure TXMLDocumentHandler.setDocument(doc: TXMLDocument);
begin
  fDocument:=doc;
end;

function TXMLDocumentHandler.createNode(nodeName:string;
      Text: string= '';
      attributes:TStringArray = nil): TDOMNode;
begin
  if document = nil then document:=TXMLDocument.Create;
  result:=document.createElement(nodeName);
  addTextValue(result,text);
  addAttributes(result,attributes);
end;


end.

