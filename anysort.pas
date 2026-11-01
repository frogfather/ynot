unit anysort;

{$ifdef fpc}{$mode delphi}{$H+}{$endif}

interface

type
  TCompareFunc = function (const elem1, elem2): integer;

procedure AnySort(var Arr; Count: Integer; Stride: Integer; CompareFunc: TCompareFunc; start:integer=0);

implementation

type
  TByteArray = array [Word] of byte;
  PByteArray = ^TByteArray;

procedure AnyQuickSort(var Arr; idxL, idxH: Integer;
  Stride: Integer; CompareFunc: TCompareFunc; var SwapBuf, MedBuf);
var
  ls,hs : Integer;
  li,hi : Integer;
  mi    : Integer;
  ms    : Integer;
  pb    : PByteArray;
begin
  pb:=@Arr;
  li:=idxL;
  hi:=idxH;
  mi:=(li+hi) div 2;
  ls:=li*Stride;
  hs:=hi*Stride;
  ms:=mi*Stride;
  Move(pb[ms], medBuf, Stride);
  repeat
    while CompareFunc( pb[ls], medBuf) < 0 do begin
      inc(ls, Stride);
      inc(li);
    end;
    while CompareFunc( medBuf, pb[hs] ) < 0 do begin
      dec(hs, Stride);
      dec(hi);
    end;
    if ls <= hs then begin
      Move(pb[ls], SwapBuf, Stride);
      Move(pb[hs], pb[ls], Stride);
      Move(SwapBuf, pb[hs], Stride);
      // begin fix 11/11/2021: update ms if the reference point is moved
      if li=mi then ms:=hs;
      if hi=mi then ms:=ls;
      // end fix
      inc(ls, Stride); inc(li); //increase ls by stride and li by 1
      dec(hs, Stride); dec(hi); //decrease hs by stride and hi by 1
    end;
  until ls>hs; //continue until ls is greater than hs
  if hi>idxL then AnyQuickSort(Arr, idxL, hi, Stride, CompareFunc, SwapBuf, MedBuf);
  if li<idxH then AnyQuickSort(Arr, li, idxH, Stride, CompareFunc, SwapBuf, MedBuf);
end;

procedure AnySort(var Arr; Count: Integer; Stride: Integer; CompareFunc: TCompareFunc; start:integer=0);
type
  TByteArray = array of byte;
var
  buf: TByteArray;
begin
  if Count <= 1 then Exit; // should be more than 1 to be sortable
  SetLength(buf, Stride*2);
  AnyQuickSort(Arr, start, Count-1+start, Stride, compareFunc, buf[0], buf[Stride]);
end;

end.
