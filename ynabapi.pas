unit ynabApi;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, httpClient,fpjson, jsonparser,fileUtilities;
type
  { TYnabApi }

  TYnabApi = class(TInterfacedObject)
    private
    fToken:string;
    function getClient: THttpClient;
    public
    constructor create(configFile: string);
    function getPlans: TJSONArray;
    function getPlan(planId:string):TJSONObject;
  end;

implementation

{ TYnabApi }
const baseUrl: string = 'https://api.ynab.com/v1';
  //plans

function TYnabApi.getClient: THttpClient;
begin
  result:=THttpClient.Create;
  result.baseUrl:= baseUrl;
  result.addHeader('Authorization', 'Bearer '+fToken);
  result.addHeader('User-Agent', 'Mozilla/5.0 (compatible; fpweb)');
  result.addHeader('Content-Type', 'application/json');
end;

constructor TYnabApi.create(configFile: string);
var
  fileLines:TStringArray;
  index:integer;
begin
  if fileexists(configFile) then
  fileLines:=openFileAsArray(configFile, #$0A);
  if (length(fileLines) > 0) then for index:= 0 to pred(length(filelines)) do
    begin
      if (fileLines[index].Split(',')[0] = 'ApiToken')
        then fToken:=fileLines[index].Split(',')[1];
    end;
end;

function TYnabApi.getPlans: TJSONArray;
var
  jData:TJsonData;
begin
  jData:=getClient.get('/plans').GetPath('results').getPath('data');
  result:=TJSONObject(jData).Arrays['plans'];
end;

function TYnabApi.getPlan(planId: string): TJSONObject;
begin
  result:=getClient.get('/plans/'+planId);
end;

end.

