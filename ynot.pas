unit ynot;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, fpjson, StdCtrls,ynabApi;

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
  fYnabApi:TYnabApi;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormShow(Sender: TObject);
begin
  fYnabApi:=TYnabApi.create(getUserDir+'/.ynot/settings.csv');
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  plansArray:TJsonArray;
  plan:TJsonObject;
  arrPos:Integer;
begin
  //Call plans
  plansArray:=fYnabApi.getPlans;
  lbPlans.Clear;
  if (plansArray.Count > 0) then
    for arrPos:=0 to pred(plansArray.Count) do
    begin
    plan:=TJsonObject(plansArray[arrPos]);
    lbPlans.Items.Add(plan.Get('name'));
    end;
end;

end.

