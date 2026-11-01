unit httpClient;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, fphttpclient, opensslsockets,header;
  type

  { THttpClient }

  THttpClient = class(TInterfacedObject)
  strict private
    fBaseUrl: String;
    fAllowRedirect: Boolean;
    fHeaders: THeaders;
  public
    procedure addHeader(key,value:string);
    procedure removeHeader(key:string);
    function get(path: String):TJSONObject;
    property allowRedirect: boolean read fAllowRedirect write fAllowRedirect;
    property headers: THeaders read fHeaders;
    property baseUrl: String read fBaseUrl write fBaseUrl;
  end;

implementation


{ THttpClient }

function THttpClient.get(path: String): TJSONObject;
Var
  HTTP : TFPHttpClient;
  headerNo: integer;
  headerKey, headerValue: String;
  jsonData: TJSONData;
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
  try
    jsonData := GetJSON(HTTP.Get(baseUrl+path));
    result.Add('results',TJSONObject(jsonData));
  finally
    http.free;
  end;

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

end.


