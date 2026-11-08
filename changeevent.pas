unit changeEvent;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type

  TChangeType = (CAT_GROUP_SELECTION,CAT_SELECTION);

  { TChangeEvent }

  TChangeEvent = class(TInterfacedObject)
    private
    fPlanId:string;
    fCatGroupId:string;
    fCategoryId:string;
    fChangeType:TChangeType;
    public
    constructor create(planId_,categoryGroupId_,categoryId_:string;changeType_:TChangeType);
    property planId: string read fPlanId;
    property catGroupId: string read fcatGroupId;
    property categoryId: string read fCategoryId;
    property changeType: TChangeType read fChangeType;
  end;


implementation

{ TChangeEvent }

constructor TChangeEvent.create(planId_,categoryGroupId_,categoryId_:string;changeType_:TChangeType);
begin
  fPlanId:=planId_;
  fChangeType:=changeType_;
  fcatGroupId:=categoryGroupId_;
  fCategoryId:=categoryId_;
end;

end.

