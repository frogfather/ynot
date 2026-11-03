unit ynabApi;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, httpClient,fpjson, jsonparser,ynabResponse;
type
  { TYnabApi }

  TYnabApi = class(TInterfacedObject)
    private
    fToken:string;
    function getClient: THttpClient;
    public
    constructor create(apiToken_: string);
    function getPlans: TYNABResponse;
    function getPlan(planId:string):TYNABResponse;
    function getPlan(planId:string;serverKnowledge_:string):TYNABResponse;
    function getCategories(planId:string):TYNABResponse;
    function getCategories(planId:string;serverKnowledge_:string):TYNABResponse;
  end;

implementation

{ TYnabApi }
const baseUrl: string = 'https://api.ynab.com/v1';
  //plans

function TYnabApi.getClient: THttpClient;
begin
  result:=THttpClient.Create(baseUrl);
  result.addHeader('Authorization', 'Bearer '+fToken);
  result.addHeader('User-Agent', 'Mozilla/5.0 (compatible; fpweb)');
  result.addHeader('Content-Type', 'application/json');
end;

constructor TYnabApi.create(apiToken_:string);
begin
 fToken:=apiToken_;
end;

function TYnabApi.getPlans: TYNABResponse;
var
  client:THttpClient;
begin
  client:=getClient;
  result:=TYNABResponse.create(client.get('/plans'));
end;

function TYnabApi.getPlan(planId: string): TYNABResponse;
var
  client:THttpClient;
begin
  client:=getClient;
  result:=TYNABResponse.create(client.get('/plans/'+planId));
end;

function TYnabApi.getPlan(planId: string; serverKnowledge_: string
  ): TYNABResponse;
var
  client:THttpClient;
begin
  client:=getClient;
  client.addQueryParam('server_knowledge',serverKnowledge_);
  result:=TYNABResponse.create(client.get('/plans/'+planId));
end;

function TYnabApi.getCategories(planId: string): TYNABResponse;
var
  client:THttpClient;
begin
  client:=getClient;
  result:=TYNABResponse.create(client.get('/plans/'+planId+'/categories'));
end;

function TYnabApi.getCategories(planId: string; serverKnowledge_: string
  ): TYNABResponse;
var
  client:THttpClient;
begin
  client:=getClient;
  client.addQueryParam('server_knowledge',serverKnowledge_);
  result:=TYNABResponse.create(client.get('/plans/'+planId+'/categories'));
end;

end.

