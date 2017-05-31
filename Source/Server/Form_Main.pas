{


  This source has created by Maickonn Richard.
  Any questions, contact-me: senjaxus@gmail.com

  My Github: https://www.github.com/Senjaxus

  Join our Facebook group: https://www.facebook.com/groups/1202680153082328/

  Are totally free!


}

unit Form_Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, AppEvnts, System.Win.ScktComp;

// Thread to Define type connection, if Main, Desktop Remote, Download or Upload Files.
type
  TThreadConnection_Define = class(TThread)
  private
    AThread_Define: TCustomWinSocket;
  public
    constructor Create(AThread: TCustomWinSocket); overload;
    procedure Execute; override;
  end;

  // Thread to Define type connection are Main.
type
  TThreadConnection_Main = class(TThread)
  private
    AThread_Main                          : TCustomWinSocket;
    AThread_Main_Target                   : TCustomWinSocket;
    ID, Password, TargetID, TargetPassword: string;
    StartPing, EndPing                    : Integer;
  public
    constructor Create(AThread: TCustomWinSocket); overload;
    procedure Execute; override;
    procedure AddItems;
    procedure InsertTargetID;
    procedure InsertPing;
  end;

  // Thread to Define type connection are Desktop.
type
  TThreadConnection_Desktop = class(TThread)
  private
    AThread_Desktop       : TCustomWinSocket;
    AThread_Desktop_Target: TCustomWinSocket;
    MyID                  : string;
  public
    constructor Create(AThread: TCustomWinSocket; ID: string); overload;
    procedure Execute; override;
  end;

  // Thread to Define type connection are Keyboard.
type
  TThreadConnection_Keyboard = class(TThread)
  private
    AThread_Keyboard       : TCustomWinSocket;
    AThread_Keyboard_Target: TCustomWinSocket;
    MyID                   : string;
  public
    constructor Create(AThread: TCustomWinSocket; ID: string); overload;
    procedure Execute; override;
  end;

  // Thread to Define type connection are Files.
type
  TThreadConnection_Files = class(TThread)
  private
    AThread_Files       : TCustomWinSocket;
    AThread_Files_Target: TCustomWinSocket;
    MyID                : string;
  public
    constructor Create(AThread: TCustomWinSocket; ID: string); overload;
    procedure Execute; override;
  end;

type
  Tfrm_Main = class(TForm)
    Splitter1: TSplitter;
    Logs_Memo: TMemo;
    Connections_ListView: TListView;
    ApplicationEvents1: TApplicationEvents;
    Ping_Timer: TTimer;
    Main_ServerSocket: TServerSocket;
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure FormCreate(Sender: TObject);
    procedure Ping_TimerTimer(Sender: TObject);
    procedure Main_IdTCPServerExecute(AContext: TCustomWinSocket);
    procedure Main_IdTCPServerConnect(AContext: TCustomWinSocket);
    procedure Main_ServerSocketClientConnect(Sender: TObject; Socket: TCustomWinSocket);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_Main: Tfrm_Main;

const
  Port            = 3898; // Port for Indy Socket;
  ProcessingSlack = 2;    // Processing slack for Sleep Commands

implementation

{$R *.dfm}

constructor TThreadConnection_Define.Create(AThread: TCustomWinSocket);
begin
  inherited Create(False);
  AThread_Define  := AThread;
  FreeOnTerminate := true;
end;

constructor TThreadConnection_Main.Create(AThread: TCustomWinSocket);
begin
  inherited Create(False);
  AThread_Main    := AThread;
  FreeOnTerminate := true;
end;

constructor TThreadConnection_Desktop.Create(AThread: TCustomWinSocket; ID: string);
begin
  inherited Create(False);
  AThread_Desktop := AThread;
  MyID            := ID;
  FreeOnTerminate := true;
end;

constructor TThreadConnection_Keyboard.Create(AThread: TCustomWinSocket; ID: string);
begin
  inherited Create(False);
  AThread_Keyboard := AThread;
  MyID             := ID;
  FreeOnTerminate  := true;
end;

constructor TThreadConnection_Files.Create(AThread: TCustomWinSocket; ID: string);
begin
  inherited Create(False);
  AThread_Files   := AThread;
  MyID            := ID;
  FreeOnTerminate := true;
end;

// Get current Version
function GetAppVersionStr: string;
type
  TBytes = array of Byte;
var
  Exe         : string;
  Size, Handle: DWORD;
  Buffer      : TBytes;
  FixedPtr    : PVSFixedFileInfo;
begin
  Exe  := ParamStr(0);
  Size := GetFileVersionInfoSize(PChar(Exe), Handle);
  if Size = 0 then
    RaiseLastOSError;
  SetLength(Buffer, Size);
  if not GetFileVersionInfo(PChar(Exe), Handle, Size, Buffer) then
    RaiseLastOSError;
  if not VerQueryValue(Buffer, '\', Pointer(FixedPtr), Size) then
    RaiseLastOSError;
  Result := Format('%d.%d.%d.%d', [LongRec(FixedPtr.dwFileVersionMS).Hi, // major
    LongRec(FixedPtr.dwFileVersionMS).Lo, // minor
    LongRec(FixedPtr.dwFileVersionLS).Hi,  // release
    LongRec(FixedPtr.dwFileVersionLS).Lo]) // build
end;

function GenerateID(): string;
var
  i     : Integer;
  ID    : string;
  Exists: Boolean;
begin

  Exists := False;

  while true do
  begin
    Randomize;
    ID := IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9)) + '-' + IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9)) + '-' + IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9));

    i := 0;
    while i < frm_Main.Connections_ListView.Items.Count - 1 do
    begin

      if (frm_Main.Connections_ListView.Items.Item[i].SubItems[2] = ID) then
      begin
        Exists := true;
        break;
      end
      else
        Exists := False;

      Inc(i);
    end;
    if not(Exists) then
      break;
  end;

  Result := ID;
end;

function GeneratePassword(): string;
begin
  Randomize;
  Result := IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9));
end;

function FindListItemID(ID: string): TListItem;
var
  i: Integer;
begin
  i := 0;
  while i < frm_Main.Connections_ListView.Items.Count do
  begin
    if (frm_Main.Connections_ListView.Items.Item[i].SubItems[1] = ID) then
      break;

    Inc(i);
  end;
  Result := frm_Main.Connections_ListView.Items.Item[i];
end;

function CheckIDExists(ID: string): Boolean;
var
  i     : Integer;
  Exists: Boolean;
begin

  Exists := False;
  i      := 0;
  while i < frm_Main.Connections_ListView.Items.Count do
  begin
    if (frm_Main.Connections_ListView.Items.Item[i].SubItems[1] = ID) then
    begin
      Exists := true;
      break;
    end;

    Inc(i);
  end;
  Result := Exists;
end;

function CheckIDPassword(ID, Password: string): Boolean;
var
  i      : Integer;
  Correct: Boolean;
begin

  Correct := False;
  i       := 0;
  while i < frm_Main.Connections_ListView.Items.Count do
  begin
    if (frm_Main.Connections_ListView.Items.Item[i].SubItems[1] = ID) and (frm_Main.Connections_ListView.Items.Item[i].SubItems[2] = Password) then
    begin
      Correct := true;
      break;
    end;

    Inc(i);
  end;

  Result := Correct;

end;

procedure Tfrm_Main.ApplicationEvents1Exception(Sender: TObject; E: Exception);
begin
  Logs_Memo.Lines.Add(' ');
  Logs_Memo.Lines.Add(' ');
  Logs_Memo.Lines.Add(E.Message);
end;

procedure Tfrm_Main.FormCreate(Sender: TObject);
begin
  Main_ServerSocket.Port   := Port;
  Main_ServerSocket.Active := true;

  Caption := Caption + ' - ' + GetAppVersionStr;
end;

procedure Tfrm_Main.Main_IdTCPServerConnect(AContext: TCustomWinSocket);
var
  Connection: TThreadConnection_Define;
begin
  // Create Defines Thread of Connections
  Connection := TThreadConnection_Define.Create(AContext);

end;

procedure Tfrm_Main.Main_IdTCPServerExecute(AContext: TCustomWinSocket);
begin
  Sleep(ProcessingSlack);
end;

procedure Tfrm_Main.Main_ServerSocketClientConnect(Sender: TObject; Socket: TCustomWinSocket);
var
  Connection: TThreadConnection_Define;
begin
  // Create Defines Thread of Connections
  Connection := TThreadConnection_Define.Create(Socket);

end;

{ TThreadConnection_Define }
// Here it will be defined the type of connection.
procedure TThreadConnection_Define.Execute;
var
  s, s2, ID     : string;
  position      : Integer;
  ThreadMain    : TThreadConnection_Main;
  ThreadDesktop : TThreadConnection_Desktop;
  ThreadKeyboard: TThreadConnection_Keyboard;
  ThreadFiles   : TThreadConnection_Files;
begin
  inherited;

  try
    while AThread_Define.Connected do
    begin

      Sleep(ProcessingSlack);

      if AThread_Define.ReceiveLength < 1 then
        Continue;

      s := AThread_Define.ReceiveText;

      position := Pos('<|MAINSOCKET|>', s); // Storing the position in an integer variable will prevent it from having to perform two searches, gaining more performance
      if position > 0 then
      begin
        // Create the Thread for Main Socket
        ThreadMain := TThreadConnection_Main.Create(AThread_Define);

        break; // Break the while
      end;

      position := Pos('<|DESKTOPSOCKET|>', s);  // For example, I stored the position of the string I wanted to find
      if position > 0 then
      begin
        s2 := s;

        Delete(s2, 1, position + 16); // So since I already know your position, I do not need to pick it up again
        ID := Copy(s2, 1, Pos('<<|', s2) - 1);

        // Create the Thread for Desktop Socket
        ThreadDesktop := TThreadConnection_Desktop.Create(AThread_Define, ID);

        break; // Break the while
      end;

      position := Pos('<|KEYBOARDSOCKET|>', s);
      if position > 0 then
      begin
        s2 := s;

        Delete(s2, 1, position + 17);
        ID := Copy(s2, 1, Pos('<<|', s2) - 1);

        // Create the Thread for Keyboard Socket
        ThreadKeyboard := TThreadConnection_Keyboard.Create(AThread_Define, ID);

        break; // Break the while
      end;

      position := Pos('<|FILESSOCKET|>', s);
      if position > 0 then
      begin
        s2 := s;

        Delete(s2, 1, Pos('<|FILESSOCKET|>', s) + 14);
        ID := Copy(s2, 1, Pos('<<|', s2) - 1);

        // Create the Thread for Files Socket
        ThreadFiles := TThreadConnection_Files.Create(AThread_Define, ID);

        break; // Break the while
      end;

    end;

  except
  end;

end;

{ TThreadConnection_Main }

procedure TThreadConnection_Main.AddItems;
var
  L: TListItem;
begin

  ID        := GenerateID;
  Password  := GeneratePassword;
  L         := frm_Main.Connections_ListView.Items.Add;
  L.Caption := IntToStr(AThread_Main.Handle);
  L.SubItems.Add(AThread_Main.RemoteAddress);
  L.SubItems.Add(ID);
  L.SubItems.Add(Password);
  L.SubItems.Add('');
  L.SubItems.Add('Calculating...');
  L.SubItems.Objects[4] := TObject(0);
end;

// The connection type is the main.
procedure TThreadConnection_Main.Execute;
var
  s, s2: string;
  position: Integer;
  L, L2: TListItem;
begin
  inherited;

  Synchronize(AddItems);

  L                     := frm_Main.Connections_ListView.FindCaption(0, IntToStr(AThread_Main.Handle), False, true, False);
  L.SubItems.Objects[0] := TObject(Self);

  AThread_Main.SendText('<|ID|>' + ID + '<|>' + Password + '<<|');
  try
    while AThread_Main.Connected do
    begin

      Sleep(ProcessingSlack);

      if AThread_Main.ReceiveLength < 1 then
        Continue;

      s := AThread_Main.ReceiveText;

      position := Pos('<|FINDID|>', s);
      if position > 0 then
      begin
        s2 := s;
        Delete(s2, 1, position + 9);

        TargetID := Copy(s2, 1, Pos('<<|', s2) - 1);

        if (CheckIDExists(TargetID)) then
          if (FindListItemID(TargetID).SubItems[3] = '') then
            AThread_Main.SendText('<|IDEXISTS!REQUESTPASSWORD|>')
          else
            AThread_Main.SendText('<|ACCESSBUSY|>')
        else
          AThread_Main.SendText('<|IDNOTEXISTS|>');
      end;

      if Pos('<|PONG|>', s) > 0 then
      begin
        EndPing := GetTickCount - StartPing;
        Synchronize(InsertPing);
      end;

      position := Pos('<|CHECKIDPASSWORD|>', s);
      if position > 0 then
      begin
        s2 := s;
        Delete(s2, 1, position + 18);

        position := Pos('<|>', s2);
        TargetID := Copy(s2, 1, position - 1);

        Delete(s2, 1, position + 2);

        TargetPassword := Copy(s2, 1, Pos('<<|', s2) - 1);

        if (CheckIDPassword(TargetID, TargetPassword)) then
        begin
          AThread_Main.SendText('<|ACCESSGRANTED|>');
        end
        else
          AThread_Main.SendText('<|ACCESSDENIED|>');
      end;

      position := Pos('<|RELATION|>', s);
      if position > 0 then
      begin
        s2 := s;
        Delete(s2, 1, position + 11);

        position := Pos('<|>', s2);
        ID := Copy(s2, 1, position - 1);

        Delete(s2, 1, position + 2);

        TargetID := Copy(s2, 1, Pos('<<|', s2) - 1);

        L  := FindListItemID(ID);
        L2 := FindListItemID(TargetID);

        Synchronize(InsertTargetID);

        // Relates the main Sockets
        TThreadConnection_Main(L.SubItems.Objects[0]).AThread_Main_Target := TThreadConnection_Main(L2.SubItems.Objects[0]).AThread_Main;
        TThreadConnection_Main(L2.SubItems.Objects[0]).AThread_Main_Target := TThreadConnection_Main(L.SubItems.Objects[0]).AThread_Main;

        // Relates the Remote Desktop
        TThreadConnection_Desktop(L.SubItems.Objects[1]).AThread_Desktop_Target := TThreadConnection_Desktop(L2.SubItems.Objects[1]).AThread_Desktop;
        TThreadConnection_Desktop(L2.SubItems.Objects[1]).AThread_Desktop_Target := TThreadConnection_Desktop(L.SubItems.Objects[1]).AThread_Desktop;

        // Relates the Keyboard Socket
        TThreadConnection_Keyboard(L.SubItems.Objects[2]).AThread_Keyboard_Target := TThreadConnection_Keyboard(L2.SubItems.Objects[2]).AThread_Keyboard;

        // Relates the Share Files
        TThreadConnection_Files(L.SubItems.Objects[3]).AThread_Files_Target := TThreadConnection_Files(L2.SubItems.Objects[3]).AThread_Files;
        TThreadConnection_Files(L2.SubItems.Objects[3]).AThread_Files_Target := TThreadConnection_Files(L.SubItems.Objects[3]).AThread_Files;

        // Get first screenshot
        TThreadConnection_Desktop(L.SubItems.Objects[1]).AThread_Desktop_Target.SendText('<|GETFULLSCREENSHOT|>');

        // Warns Access
        TThreadConnection_Main(L.SubItems.Objects[0]).AThread_Main_Target.SendText('<|ACCESSING|>');
      end;

      // Redirect commands
      position := Pos('<|REDIRECT|>', s);
      if position > 0 then
      begin
        s2 := s;
        Delete(s2, 1, position + 11);

        if (Pos('<|FOLDERLIST|>', s2) > 0) then
        begin
          while (AThread_Main.Connected) do
          begin

            Sleep(ProcessingSlack); // Avoids using 100% CPU

            if (Pos('<<|FOLDERLIST', s2) > 0) then
              break;

            s2 := s2 + AThread_Main.ReceiveText;

          end;
        end;

        if (Pos('<|FILESLIST|>', s2) > 0) then
        begin

          while (AThread_Main.Connected) do
          begin

            Sleep(ProcessingSlack); // Avoids using 100% CPU

            if (Pos('<<|FILESLIST', s2) > 0) then
              break;

            s2 := s2 + AThread_Main.ReceiveText;

          end;
        end;

        while AThread_Main_Target.SendText(s2) < 0 do
          Sleep(ProcessingSlack);

      end;

    end;
  except

    while AThread_Main_Target.SendText('<|DISCONNECTED|>') < 0 do
      Sleep(ProcessingSlack);

    L.Delete;
  end;
end;

procedure TThreadConnection_Main.InsertPing;
var
  L: TListItem;
begin

  L := frm_Main.Connections_ListView.FindCaption(0, IntToStr(AThread_Main.Handle), False, true, False);
  if (L <> nil) then
    L.SubItems[4] := IntToStr(EndPing) + ' ms';

end;

procedure TThreadConnection_Main.InsertTargetID;
var
  L, L2: TListItem;
begin
  L := frm_Main.Connections_ListView.FindCaption(0, IntToStr(AThread_Main.Handle), False, true, False);
  if (L <> nil) then
  begin
    L2 := FindListItemID(TargetID);

    L.SubItems[3]  := TargetID;
    L2.SubItems[3] := ID;
  end;
end;

{ TThreadConnection_Desktop }
// The connection type is the Desktop Screens
procedure TThreadConnection_Desktop.Execute;
var
  s: string;
  L: TListItem;
begin
  inherited;

  L                     := FindListItemID(MyID);
  L.SubItems.Objects[1] := TObject(Self);

  try
    while AThread_Desktop.Connected do
    begin

      Sleep(ProcessingSlack);

      if AThread_Desktop.ReceiveLength < 1 then
        Continue;

      s := AThread_Desktop.ReceiveText;

      while AThread_Desktop_Target.SendText(s) < 0 do
        Sleep(ProcessingSlack);
    end;
  except
  end;
end;

// The connection type is the Keyboard Remote
procedure TThreadConnection_Keyboard.Execute;
var
  s: string;
  L: TListItem;
begin
  inherited;

  L                     := FindListItemID(MyID);
  L.SubItems.Objects[2] := TObject(Self);

  try
    while AThread_Keyboard.Connected do
    begin

      Sleep(ProcessingSlack);

      if AThread_Keyboard.ReceiveLength < 1 then
        Continue;

      s := AThread_Keyboard.ReceiveText;

      while AThread_Keyboard_Target.SendText(s) < 0 do
        Sleep(ProcessingSlack);

    end;
  except
  end;
end;

{ TThreadConnection_Files }
// The connection type is to Share Files
procedure TThreadConnection_Files.Execute;
var
  s: string;
  L: TListItem;
begin
  inherited;

  L                     := FindListItemID(MyID);
  L.SubItems.Objects[3] := TObject(Self);

  try
    while AThread_Files.Connected do
    begin

      Sleep(ProcessingSlack);

      if AThread_Files.ReceiveLength < 1 then
        Continue;

      s := AThread_Files.ReceiveText;

      while AThread_Files_Target.SendText(s) < 0 do
        Sleep(ProcessingSlack);

    end;
  except
  end;
end;

procedure Tfrm_Main.Ping_TimerTimer(Sender: TObject);
var
  i: Integer;
begin
  i := 0;

  while i < Connections_ListView.Items.Count do
  begin
    try

      // Request Ping
      TThreadConnection_Main(Connections_ListView.Items.Item[i].SubItems.Objects[0]).AThread_Main.SendText('<|PING|>');
      TThreadConnection_Main(Connections_ListView.Items.Item[i].SubItems.Objects[0]).StartPing := GetTickCount;

      // Check if Target ID exists, if not, delete it
      if not(Connections_ListView.Items.Item[i].SubItems[3] = '') then
      begin
        if not(CheckIDExists(Connections_ListView.Items.Item[i].SubItems[3])) then
        begin
          Connections_ListView.Items.Item[i].Delete;
          Dec(i);
        end;

      end;

      Inc(i);
    except
      // Any error, delete
      Connections_ListView.Items.Item[i].Delete;
    end;
  end;
end;

end.
