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

constructor TYnabApi.create(apiToken_:string);
begin
 fToken:=apiToken_;
end;

function TYnabApi.getPlans: TYNABResponse;
begin
  result:=TYNABResponse.create(getClient.get('/plans'));
end;

function TYnabApi.getPlan(planId: string): TYNABResponse;
begin
  result:=TYNABResponse.create(getClient.get('/plans/'+planId));
end;

end.

