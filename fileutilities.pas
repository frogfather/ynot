unit fileUtilities;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  fpjson,
  arrayUtils,
  fileUtil;

function readStream(fnam: string): string;
procedure writeStream(fnam: string; txt: string);
function openFileAsArray(fnam: string; separator: char;removeBlankLines:Boolean=true): TStringArray;
function getUsrDir(dirName:string): string;
function getPathToDirectory(currentPath,dirName: string):string;
implementation

//This complete mess is required because getUserDir on MacOS Catalina returns '/'
function getUsrDir(dirName:String): string;
var
  currentDir:string;
  directoryList:TStringlist;
  index:integer;
begin
  directoryList:=TStringlist.create;
  currentDir:=getCurrentDir;
  if (currentDir <> '/') then
    directoryList.Add(getPathToDirectory(currentDir,dirName))
    else
    begin
    directoryList:= findAllDirectories('/',false);
    if (directoryList.IndexOf('/Users') > -1) then
      begin
      chdir('Users');
      directoryList:=findAllDirectories('/Users/',false);
      if (directoryList.IndexOf('Shared') > -1) then directoryList.Delete(directorylist.IndexOf('Shared'));
      if (dirName <> '')and(directoryList.IndexOf('/Users/'+dirName)> -1) then
        begin
        chdir(dirName);
        result:='/Users/'+dirName;
        exit;
        end;
      end;
    end;
  if (directoryList.count > 0) then result:=directoryList[0] else result:='';
end;

function getPathToDirectory(currentPath,dirName: string): string;
var
  pathParts:TStringArray;
  index:integer;
begin
  result:='';
  pathParts:=currentPath.Split('/');
  for index:= 0 to pred(pathParts.size) do
    begin
    result:=result + pathParts[index];
    if (pathParts[index] <> dirName)
      then result:= result+ '/'
      else exit;
    end;
end;

function openFileAsArray(fnam: string; separator: char;removeBlankLines:boolean=true): TStringArray;
var
  option:TStringSplitOptions;
  fileContents:String;
begin
if FileExists(fNam) then
  begin
  if removeBlankLines
    then option:=TStringSplitOptions.ExcludeEmpty
  else option:=TStringSplitOptions.None;
  fileContents:=readStream(fNam);
  //remove separator as last character
  if fileContents[length(fileContents)] = separator
    then fileContents:= fileContents.Remove(pred(length(fileContents)),1);
  result := fileContents.Split(separator,option);
  end;
end;

//File I/O methods
function readStream(fnam: string): string;
var
  strm: TFileStream;
  n: longint;
  txt: string;
  begin
    txt := '';
    strm := TFileStream.Create(fnam, fmOpenRead);
    try
      n := strm.Size;
      SetLength(txt, n);
      strm.Read(txt[1], n);
    finally
      strm.Free;
    end;
    result := txt;
  end;

procedure writeStream(fnam: string; txt: string);
var
  strm: TFileStream;
  n: longint;
begin
  try
    strm := TFileStream.Create(fnam, fmCreate);
    n := Length(txt);
    strm.Position := 0;
    strm.Write(txt[1], n);
  finally
    strm.Free;
  end;
end;

end.

