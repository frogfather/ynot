unit ynot;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, fpjson, StdCtrls,ynab,fileUtilities,plan;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    lbPlans: TListBox;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

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
      begin
      fYnab:=TYnab.create(token,dataFile);
      end else
      begin
      messagedlg('','No api token found. Set API token',mtError,[mbOK],'');
      //Exit at this point, but allow user to enter token
      application.Terminate;
      end;
    end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  planList:TPlans;
  plan:TPlan;
  arrPos:Integer;
begin
  //Call plans
  planList:=fYnab.plans;
  lbPlans.Clear;
  if (planList.size > 0) then
    for arrPos:=0 to pred(planList.size) do
    begin
    plan:=planList[arrPos];
    lbPlans.Items.Add(plan.name);
    end;
end;

end.

