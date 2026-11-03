unit httpClient;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, fphttpclient, opensslsockets,header,queryParam;
  type

  { THttpClient }

  THttpClient = class(TInterfacedObject)
  strict private
    fBaseUrl: String;
    fAllowRedirect: Boolean;
    fHeaders: THeaders;
    fQueryParams: TQueryParams;
  public
    procedure addHeader(key,value:string);
    procedure removeHeader(key:string);
    procedure addQueryParam(key_,value_:string);
    procedure removeQueryParam(key_:string);
    function get(path: String):TJSONData;
    constructor create;
    constructor create(baseUrl_:string;allowRedirect_:boolean=true;headers_:THeaders=nil;queryParams_:TQueryParams=nil);
    property allowRedirect: boolean read fAllowRedirect write fAllowRedirect;
    property headers: THeaders read fHeaders;
    property queryParams: TQueryParams read fQueryParams;
    property baseUrl: String read fBaseUrl write fBaseUrl;
  end;

implementation


{ THttpClient }

function THttpClient.get(path: String): TJSONData;
Var
  HTTP : TFPHttpClient;
  headerNo: integer;
  headerKey, headerValue: String;
  jsonData: TJSONData;
  queryUrl:string;
begin
  result:= TJSONObject.Create;
  HTTP := TFPHttpClient.Create(nil);
  HTTP.AllowRedirect:=allowRedirect;
  for headerNo := 0 to headers.size -1 do
    begin
      headerKey:= headers[headerNo].key;
      headerValue := headers[headerNo].value;
      HTTP.AddHeader(headerKey, headerValue);
    end;
  queryUrl:=baseUrl+path;
  if (queryParams.size > 0) then queryUrl:=queryUrl+'?'+queryParams.toString;
  writeln('Get query '+queryUrl);
  try
    result := GetJSON(HTTP.Get(queryUrl));
  finally
    http.free;
  end;

end;

constructor THttpClient.create;
begin
  fBaseUrl:='';
  fAllowRedirect:=true;
  fHeaders:=THeaders.create;
  fQueryParams:=TQueryParams.create;
end;

constructor THttpClient.create(baseUrl_:string;allowRedirect_:boolean=true;headers_:THeaders=nil;queryParams_:TQueryParams=nil);
begin
  fBaseUrl:=baseUrl_;
  fAllowRedirect:=allowRedirect_;
  if assigned(headers_) then fHeaders:=headers_ else fHeaders:=THeaders.create;
  if assigned(queryParams_) then fQueryParams:=queryParams_ else fQueryParams:= TQueryParams.create;
end;

procedure THttpClient.addHeader(key, value: string);
var
  existingHeader:THeader;
begin
  existingHeader:=headers.findByKey(key);
  if existingHeader = Nil
     then headers.push(THeader.create(key,value))
     else existingHeader.value:= value;
end;

procedure THttpClient.removeHeader(key: string);
var
  existingHeader:THeader;
begin
  existingHeader:=headers.findByKey(key);
  if existingHeader <> nil then headers.delete(existingHeader);
end;

procedure THttpClient.addQueryParam(key_, value_: string);
var
  existingQueryParam:TQueryParam;
begin
  existingQueryParam:=queryParams.findByName(key_);
  if not assigned(existingQueryParam)
     then queryParams.push(TQueryParam.create(key_,value_))
     else existingQueryParam.paramValue:=value_;
end;

procedure THttpClient.removeQueryParam(key_: string);
var
  existingQueryParam:TQueryParam;
begin
  existingQueryParam:=queryParams.findByName(key_);
  if assigned(existingQueryParam)
     then queryParams.delete(existingQueryParam);
end;

end.


