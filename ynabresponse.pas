unit ynabResponse;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,fpjson;

type

  { TYnabResponse }

  TYnabResponse = class(TInterfacedObject)
    private
      fErrors:TJSONData;
      fResults:TJSONData;
      fSuccess:boolean;
      function getErrors:TJSONData;
      function getResults:TJSONData;
      function getSuccess:boolean;
    public
      constructor create(commandResult:TJSONData);
      property errors:TJSONData read getErrors;
      property results:TJSONData read getResults;
      property success:boolean read getSuccess;
  end;

implementation

{ TYnabResponse }

function TYnabResponse.getErrors: TJSONData;
begin
  result:=fErrors;
end;

function TYnabResponse.getResults: TJSONData;
begin
  result:=fResults;
end;

function TYnabResponse.getSuccess: boolean;
begin
  result:=fSuccess;
end;

constructor TYnabResponse.create(commandResult: TJSONData);
begin
  if (commandResult.FindPath('data') <> nil) then
    begin
    fResults:=commandResult.GetPath('data');
    fErrors:=nil;
    fSuccess:=true;
    end else if (commandResult.FindPath('error') <> nil) then
    begin
    fResults:=nil;
    fErrors:=commandResult.GetPath('error');
    fSuccess:=false;
    end;
end;

end.

