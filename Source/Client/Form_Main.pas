{


  This source has created by Maickonn Richard.
  Any questions, contact-me: senjaxus@gmail.com

  My Github: https://www.github.com/Senjaxus

  Join our Facebook group: https://www.facebook.com/groups/1202680153082328/

  Are totally free!


}

{$R ResFile.res}
unit Form_Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Buttons, System.Win.ScktComp, Vcl.AppEvnts, Vcl.ComCtrls, Winapi.MMSystem,
  Registry, Vcl.Menus, Vcl.Mask, Clipbrd, sndkey32, StreamManager, ZLIBEX;

type
  TThread_Connection_Main = class(TThread)
    Socket: TCustomWinSocket;
    constructor Create(aSocket: TCustomWinSocket); overload;
    procedure Execute; override;
  end;

type
  TThread_Connection_Desktop = class(TThread)
    Socket: TCustomWinSocket;
    constructor Create(aSocket: TCustomWinSocket); overload;
    procedure Execute; override;
  end;

type
  TThread_Connection_Keyboard = class(TThread)
    Socket: TCustomWinSocket;
    constructor Create(aSocket: TCustomWinSocket); overload;
    procedure Execute; override;
  end;

type
  TThread_Connection_Files = class(TThread)
    Socket: TCustomWinSocket;
    constructor Create(aSocket: TCustomWinSocket); overload;
    procedure Execute; override;
  end;

type
  Tfrm_Main = class(TForm)
    TopBackground_Image: TImage;
    Logo_Image: TImage;
    Title1_Label: TLabel;
    Title2_Label: TLabel;
    GroupBox1: TGroupBox;
    background_label_Image: TImage;
    YourID_Label: TLabel;
    YourPassword_Label: TLabel;
    background_label_Image2: TImage;
    YourID_Edit: TEdit;
    YourPassword_Edit: TEdit;
    background_label_Image3: TImage;
    TargetID_Label: TLabel;
    Connect_BitBtn: TBitBtn;
    Status_Image: TImage;
    Status_Label: TLabel;
    Bevel1: TBevel;
    Image1: TImage;
    Image2: TImage;
    Reconnect_Timer: TTimer;
    Image3: TImage;
    Main_Socket: TClientSocket;
    Desktop_Socket: TClientSocket;
    ApplicationEvents1: TApplicationEvents;
    Keyboard_Socket: TClientSocket;
    Files_Socket: TClientSocket;
    Timeout_Timer: TTimer;
    About_BitBtn: TBitBtn;
    TargetID_MaskEdit: TMaskEdit;
    Clipboard_Timer: TTimer;
    procedure Connect_BitBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Reconnect_TimerTimer(Sender: TObject);
    procedure Main_SocketConnecting(Sender: TObject; Socket: TCustomWinSocket);
    procedure Main_SocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Main_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure Main_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Desktop_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure Desktop_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Keyboard_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure Keyboard_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure TargetID_EditKeyPress(Sender: TObject; var Key: Char);
    procedure Files_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure Files_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Timeout_TimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure About_BitBtnClick(Sender: TObject);
    procedure TargetID_MaskEditKeyPress(Sender: TObject; var Key: Char);
    procedure Clipboard_TimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    MyID                                         : string;
    MyPassword                                   : string;
    Viewer                                       : Boolean;
    ResolutionTargetWidth, ResolutionTargetHeight: Integer;
    procedure ClearConnection;
    procedure SetOffline;
    procedure SetOnline;
    procedure Reconnect;
    procedure CloseSockets;
    { Public declarations }
  end;

var
  frm_Main                         : Tfrm_Main;
  ResolutionWidth, ResolutionHeight: Integer;
  Timeout                          : Integer;
  OldWallpaper                     : string;
  OldClipboardText                 : string;
  Accessed, LostConnection         : Boolean;

const
  Host              = 'localhost';    // Host of Sockets  (Insert the IP Address or DNS of your Server)
  Port              = 3898;           // Port of Sockets
  ConnectionTimeout = 60;             // Timeout of connection (in secound)
  ProcessingSlack   = 2;              // Processing slack for Sleep Commands

implementation

{$R *.dfm}

uses
  Form_Password, Form_RemoteScreen, Form_Chat, Form_ShareFiles;

constructor TThread_Connection_Main.Create(aSocket: TCustomWinSocket);
begin
  inherited Create(False);
  Socket          := aSocket;
  FreeOnTerminate := true;
end;

constructor TThread_Connection_Desktop.Create(aSocket: TCustomWinSocket);
begin
  inherited Create(False);
  Socket          := aSocket;
  FreeOnTerminate := true;
end;

constructor TThread_Connection_Keyboard.Create(aSocket: TCustomWinSocket);
begin
  inherited Create(False);
  Socket          := aSocket;
  FreeOnTerminate := true;
end;

constructor TThread_Connection_Files.Create(aSocket: TCustomWinSocket);
begin
  inherited Create(False);
  Socket          := aSocket;
  FreeOnTerminate := true;
end;

// Get current Version
function GetAppVersionStr: string;
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

function GetWallpaperDirectory: string;
var
  Reg: TRegistry;
begin
  Reg := nil;
  try
    Reg         := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey('Control Panel\Desktop', False);
    Result := Reg.ReadString('Wallpaper');
  finally
    FreeAndNil(Reg);
  end;
end;

procedure ChangeWallpaper(Directory: string);
var
  Reg: TRegistry;
begin
  Reg := nil;
  try
    Reg         := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey('Control Panel\Desktop', False);
    Reg.WriteString('Wallpaper', Directory);
    SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, nil, SPIF_SENDWININICHANGE);
  finally
    FreeAndNil(Reg);
  end;
end;

procedure Tfrm_Main.About_BitBtnClick(Sender: TObject);
begin
  MessageBox(0, 'This software has created by Maickonn Richard and source code are free!' + #13 + #13'Any questions, contact-me: senjaxus@gmail.com' + #13#13 + 'My Github: https://www.github.com/Senjaxus', 'About AllaKore Remote', MB_ICONASTERISK + MB_TOPMOST);
end;

procedure Tfrm_Main.ClearConnection;
begin
  frm_Main.ResolutionTargetWidth  := 986;
  frm_Main.ResolutionTargetHeight := 600;

  with frm_RemoteScreen do
  begin
    MouseIcon_Image.Picture.Assign(MouseIcon_unchecked_Image.Picture);
    KeyboardIcon_Image.Picture.Assign(KeyboardIcon_unchecked_Image.Picture);
    ResizeIcon_Image.Picture.Assign(ResizeIcon_checked_Image.Picture);

    MouseRemote_CheckBox.Checked    := False;
    KeyboardRemote_CheckBox.Checked := False;
    Resize_CheckBox.Checked         := true;
    CaptureKeys_Timer.Enabled       := False;

    Screen_Image.Picture.Assign(ScreenStart_Image.Picture);

    Width  := 986;
    Height := 646;

  end;

  with frm_ShareFiles do
  begin
    Download_BitBtn.Enabled       := true;
    Upload_BitBtn.Enabled         := true;
    Download_ProgressBar.Position := 0;
    Upload_ProgressBar.Position   := 0;
    SizeDownload_Label.Caption    := 'Size: 0 B / 0 B';
    SizeUpload_Label.Caption      := 'Size: 0 B / 0 B';

    Directory_Edit.Text := 'C:\';
    ShareFiles_ListView.Items.Clear;

    if (Visible) then
      Close;
  end;

  with frm_Chat do
  begin
    Width  := 230;
    Height := 340;

    Left := Screen.WorkAreaWidth - Width;
    Top  := Screen.WorkAreaHeight - Height;

    Chat_RichEdit.Clear;
    YourText_Edit.Clear;
    Chat_RichEdit.SelStart            := Chat_RichEdit.GetTextLen;
    Chat_RichEdit.SelAttributes.Style := [fsBold];
    Chat_RichEdit.SelAttributes.Color := clWhite;
    Chat_RichEdit.SelText             := 'AllaKore Remote - Chat' + #13 + #13;

    FirstMessage      := true;
    LastMessageAreYou := False;

    if (Visible) then
      Close;
  end;

end;

procedure Tfrm_Main.Clipboard_TimerTimer(Sender: TObject);
begin
  try
    Clipboard.Open;

    if (Clipboard.HasFormat(CF_TEXT)) then
    begin
      if not(OldClipboardText = Clipboard.AsText) then
      begin
        OldClipboardText := Clipboard.AsText;
        Main_Socket.Socket.SendText('<|REDIRECT|><|CLIPBOARD|>' + Clipboard.AsText + '<<|');
      end;
    end;

  finally
    Clipboard.Close;
  end;

end;

// Return size (B, KB, MB or GB)
function GetSize(bytes: Int64): string;
begin
  if bytes < 1024 then
    Result := IntToStr(bytes) + ' B'
  else if bytes < 1048576 then
    Result := FloatToStrF(bytes / 1024, ffFixed, 10, 1) + ' KB'
  else if bytes < 1073741824 then
    Result := FloatToStrF(bytes / 1048576, ffFixed, 10, 1) + ' MB'
  else if bytes > 1073741824 then
    Result := FloatToStrF(bytes / 1073741824, ffFixed, 10, 1) + ' GB';
end;

// Function to List Folders
function ListFolders(Directory: string): string;
var
  FileName, Filelist, Dirlist: string;
  Searchrec                  : TWin32FindData;
  FindHandle                 : THandle;
  ReturnStr                  : string;
begin
  ReturnStr := '';

  try
    FindHandle := FindFirstFile(PChar(Directory + '*.*'), Searchrec);
    if FindHandle <> INVALID_HANDLE_VALUE then
      repeat
        FileName := Searchrec.cFileName;
        if (FileName = '.') then
          Continue;
        if ((Searchrec.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0) then
        begin
          Dirlist := Dirlist + (FileName + #13);
        end
        else
        begin
          Filelist := Filelist + (FileName + #13);
        end;
      until FindNextFile(FindHandle, Searchrec) = False;
  finally
    Winapi.Windows.FindClose(FindHandle);
  end;
  ReturnStr := (Dirlist);
  Result    := ReturnStr;
end;

// Function to List Files
function ListFiles(FileName, Ext: string): string;
var
  SearchFile: TSearchRec;
  FindResult: Integer;
  Arc       : TStrings;
begin
  Arc        := TStringList.Create;
  FindResult := FindFirst(FileName + Ext, faArchive, SearchFile);
  try
    while FindResult = 0 do
    begin
      Application.ProcessMessages;
      Arc.Add(SearchFile.Name);
      FindResult := FindNext(SearchFile);
    end;
  finally
    FindClose(SearchFile)
  end;
  Result := Arc.Text;
end;

procedure Tfrm_Main.Reconnect;
begin

  if not Main_Socket.Active then
    Main_Socket.Active := true;

end;

procedure Tfrm_Main.CloseSockets;
begin

  Main_Socket.Close;
  Desktop_Socket.Close;
  Keyboard_Socket.Close;
  Files_Socket.Close;

  Viewer := False;

  // Restore Wallpaper
  if (Accessed) then
  begin
    Accessed := False;
    ChangeWallpaper(OldWallpaper);
  end;

  // Show main form and repaint
  if not(Visible) then
  begin
    Show;
    Repaint;
  end;

  ClearConnection;
end;

procedure Tfrm_Main.SetOffline;
begin

  YourID_Edit.Text    := 'Offline';
  YourID_Edit.Enabled := False;

  YourPassword_Edit.Text    := 'Offline';
  YourPassword_Edit.Enabled := False;

  TargetID_MaskEdit.Clear;
  TargetID_MaskEdit.Enabled := False;

  Connect_BitBtn.Enabled := False;

  Timeout_Timer.Enabled   := False;
  Clipboard_Timer.Enabled := False;

end;

procedure SetConnected;
begin
  with frm_Main do
  begin
    YourID_Edit.Text    := 'Receiving...';
    YourID_Edit.Enabled := False;

    YourPassword_Edit.Text    := 'Receiving...';
    YourPassword_Edit.Enabled := False;

    TargetID_MaskEdit.Clear;
    TargetID_MaskEdit.Enabled := False;

    Connect_BitBtn.Enabled := False;
  end;
end;

procedure Tfrm_Main.SetOnline;
begin

  YourID_Edit.Text    := MyID;
  YourID_Edit.Enabled := true;

  YourPassword_Edit.Text    := MyPassword;
  YourPassword_Edit.Enabled := true;

  TargetID_MaskEdit.Clear;
  TargetID_MaskEdit.Enabled := true;

  Connect_BitBtn.Enabled := true;

end;

// Compress Stream with zLib
function CompressStream(SrcStream: TMemoryStream): Boolean;
var
  InputStream, OutputStream: TMemoryStream;
  inbuffer, outbuffer      : Pointer;
  count, outcount          : longint;
begin
  Result := False;

  InputStream  := nil;
  OutputStream := nil;
  inbuffer     := nil;
  outbuffer    := nil;

  if not assigned(SrcStream) then
    Exit;

  try
    InputStream  := TMemoryStream.Create;
    OutputStream := TMemoryStream.Create;

    InputStream.LoadFromStream(SrcStream);
    count := InputStream.Size;
    getmem(inbuffer, count);
    InputStream.ReadBuffer(inbuffer^, count);
    zcompress(inbuffer, count, outbuffer, outcount, zcMax);
    OutputStream.Write(outbuffer^, outcount);
    SrcStream.Clear;
    SrcStream.LoadFromStream(OutputStream);
    Result := true;
  finally
    FreeAndNil(InputStream);
    FreeAndNil(OutputStream);
    FreeMem(inbuffer, count);
    FreeMem(outbuffer, outcount);
  end;
end;

// Decompress Stream with zLib
function DeCompressStream(SrcStream: TMemoryStream): Boolean;
var
  InputStream, OutputStream: TMemoryStream;
  inbuffer, outbuffer      : Pointer;
  count, outcount          : longint;
begin
  Result := False;

  InputStream  := nil;
  OutputStream := nil;
  inbuffer     := nil;
  outbuffer    := nil;

  if not assigned(SrcStream) then
    Exit;

  try
    InputStream  := TMemoryStream.Create;
    OutputStream := TMemoryStream.Create;

    InputStream.LoadFromStream(SrcStream);
    count := InputStream.Size;
    getmem(inbuffer, count);
    InputStream.ReadBuffer(inbuffer^, count);
    zdecompress(inbuffer, count, outbuffer, outcount);
    OutputStream.Write(outbuffer^, outcount);
    SrcStream.Clear;
    SrcStream.LoadFromStream(OutputStream);
    Result := true;
  finally
    FreeAndNil(InputStream);
    FreeAndNil(OutputStream);
    FreeMem(inbuffer, count);
    FreeMem(outbuffer, outcount);
  end;
end;

function MemoryStreamToString(M: TMemoryStream): AnsiString;
begin
  SetString(Result, PAnsiChar(M.Memory), M.Size);
end;

procedure Tfrm_Main.Connect_BitBtnClick(Sender: TObject);
begin
  if not(TargetID_MaskEdit.Text = '   -   -   ') then
  begin
    if (TargetID_MaskEdit.Text = MyID) then
      MessageBox(0, 'You can not connect with yourself!', 'AllaKore Remote', MB_ICONASTERISK + MB_TOPMOST)
    else
    begin
      Main_Socket.Socket.SendText('<|FINDID|>' + TargetID_MaskEdit.Text + '<<|');
      TargetID_MaskEdit.Enabled := False;
      Connect_BitBtn.Enabled    := False;
      Status_Image.Picture.Assign(Image1.Picture);
      Status_Label.Caption := 'Finding the ID...';
    end;
  end;
end;

procedure Tfrm_Main.Desktop_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
var
  Thread_Connection_Desktop: TThread_Connection_Desktop;
begin
  // If connected, then send MyID for identification on Server
  Socket.SendText('<|DESKTOPSOCKET|>' + MyID + '<<|');
  Thread_Connection_Desktop := TThread_Connection_Desktop.Create(Socket);

end;

procedure Tfrm_Main.Desktop_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;
end;

procedure Tfrm_Main.Files_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
var
  Thread_Connection_Files: TThread_Connection_Files;
begin
  Socket.SendText('<|FILESSOCKET|>' + MyID + '<<|');
  Thread_Connection_Files := TThread_Connection_Files.Create(Socket);
end;

procedure Tfrm_Main.Files_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;
end;

procedure Tfrm_Main.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Restore Wallpaper
  if (Accessed) then
  begin
    Accessed := False;
    ChangeWallpaper(OldWallpaper);
  end;
end;

procedure Tfrm_Main.FormCreate(Sender: TObject);
var
  _Host: AnsiString;
  _Port: Integer;
begin
  // Insert version on Caption of the Form
  Caption := Caption + ' - ' + GetAppVersionStr;

  // Reads two exe params - host and port. If not supplied uses constants. to use: client.exe HOST PORT, for ex. AllaKore_Remote_Client.exe 192.168.16.201 3398
  if (ParamStr(1) <> '') then
    _Host := ParamStr(1)
  else
    _Host := Host;

  if (ParamStr(2) <> '') then
    _Port := StrToIntDef(ParamStr(2), Port)
  else
    _Port := Port;

  // Define Host, Port and Timeout of Sockets
  Main_Socket.Host := _Host;
  Main_Socket.Port := _Port;

  Desktop_Socket.Host := _Host;
  Desktop_Socket.Port := _Port;

  Keyboard_Socket.Host := _Host;
  Keyboard_Socket.Port := _Port;

  Files_Socket.Host := _Host;
  Files_Socket.Port := _Port;
  //
  ResolutionTargetWidth  := 986;
  ResolutionTargetHeight := 600;

  SetOffline;
  Reconnect;
end;

procedure Tfrm_Main.Keyboard_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
var
  Thread_Connection_Keyboard: TThread_Connection_Keyboard;
begin
  Socket.SendText('<|KEYBOARDSOCKET|>' + MyID + '<<|');
  Thread_Connection_Keyboard := TThread_Connection_Keyboard.Create(Socket);
end;

procedure Tfrm_Main.Keyboard_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;
end;

procedure Tfrm_Main.Main_SocketConnect(Sender: TObject; Socket: TCustomWinSocket);
var
  Thread_Connection_Main: TThread_Connection_Main;
begin
  if (LostConnection) then
  begin
    Status_Image.Picture.Assign(Image2.Picture);
    Status_Label.Caption := 'Lost connection to PC!';
    FlashWindow(Handle, true);
    LostConnection := False;
  end
  else
  begin
    Status_Image.Picture.Assign(Image3.Picture);
    Status_Label.Caption := 'You are connected!';
  end;

  Timeout := 0;

  Timeout_Timer.Enabled := true;

  Socket.SendText('<|MAINSOCKET|>');

  Thread_Connection_Main := TThread_Connection_Main.Create(Socket);

end;

procedure Tfrm_Main.Main_SocketConnecting(Sender: TObject; Socket: TCustomWinSocket);
begin
  Status_Image.Picture.Assign(Image1.Picture);
  Status_Label.Caption := 'Connecting to Server...';
end;

procedure Tfrm_Main.Main_SocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  if (frm_RemoteScreen.Visible) then
    frm_RemoteScreen.Close;

  SetOffline;

  Status_Image.Picture.Assign(Image2.Picture);
  Status_Label.Caption := 'Failed connect to Server.';

  CloseSockets;
end;

procedure Tfrm_Main.Main_SocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;

  if (frm_RemoteScreen.Visible) then
    frm_RemoteScreen.Close;

  SetOffline;

  Status_Image.Picture.Assign(Image2.Picture);
  Status_Label.Caption := 'Failed connect to Server.';

  CloseSockets;
end;

procedure Tfrm_Main.TargetID_MaskEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Connect_BitBtn.Click;
    Key := #0;
  end
end;

procedure Tfrm_Main.Reconnect_TimerTimer(Sender: TObject);
begin
  // Reconnect Sockets
  Reconnect;
end;

procedure Tfrm_Main.TargetID_EditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Connect_BitBtn.Click;
    Key := #0;
  end
end;

procedure Tfrm_Main.Timeout_TimerTimer(Sender: TObject);
begin
  if (Timeout > ConnectionTimeout) then
  begin
    if (frm_RemoteScreen.Visible) then
      frm_RemoteScreen.Close
    else
    begin
      frm_Main.SetOffline;
      frm_Main.CloseSockets;
      frm_Main.Reconnect;
    end;
  end;
  Inc(Timeout);
end;

// Connection are Main
procedure TThread_Connection_Main.Execute;
var
  s, s2               : string;
  MousePosX, MousePosY: Integer;
  i                   : Integer;
  FoldersAndFiles     : TStringList;
  L                   : TListItem;
  FileToUpload        : TFileStream;
  Extension           : string;
begin
  inherited;

  FoldersAndFiles := nil;
  FileToUpload    := nil;

  while Socket.Connected do
  begin

    try
      if (Socket.ReceiveLength > 0) then
      begin
        s := Socket.ReceiveText;

        // Received data, then resets the timeout
        Timeout := 0;

        // If receive ID, are Online
        if (Pos('<|ID|>', s) > 0) then
        begin
          s2 := s;
          Delete(s2, 1, Pos('<|ID|>', s2) + 5);

          frm_Main.MyID := Copy(s2, 1, Pos('<|>', s2) - 1);
          Delete(s2, 1, Pos('<|>', s2) + 2);

          frm_Main.MyPassword := Copy(s2, 1, Pos('<<|', s2) - 1);

          Synchronize(frm_Main.SetOnline);

          // If this Socket are connected, then connect the Desktop Socket, Keyboard Socket, File Download Socket and File Upload Socket
          Synchronize(
            procedure
            begin
              with frm_Main do
              begin
                Desktop_Socket.Active := true;
                Keyboard_Socket.Active := true;
                Files_Socket.Active := true;

                TargetID_MaskEdit.SetFocus;
              end;
            end);
        end;

        // Ping
        if (Pos('<|PING|>', s) > 0) then
        begin
          Socket.SendText('<|PONG|>');
        end;

        // Warns access and remove Wallpaper
        if (Pos('<|ACCESSING|>', s) > 0) then
        begin
          OldWallpaper := GetWallpaperDirectory;
          ChangeWallpaper('');

          Synchronize(
            procedure
            begin
              with frm_Main do
              begin
                TargetID_MaskEdit.Enabled := False;
                Connect_BitBtn.Enabled := False;
                Status_Image.Picture.Assign(frm_Main.Image3.Picture);
                Status_Label.Caption := 'Connected support!';
              end;
            end);
          Accessed := true;
        end;

        if (Pos('<|IDEXISTS!REQUESTPASSWORD|>', s) > 0) then
        begin
          Synchronize(
            procedure
            begin
              with frm_Main do
              begin
                frm_Main.Status_Label.Caption := 'Waiting for authentication...';
                frm_Password.ShowModal;
              end;
            end);
        end;

        if (Pos('<|IDNOTEXISTS|>', s) > 0) then
        begin
          Synchronize(
            procedure
            begin
              with frm_Main do
              begin
                Status_Image.Picture.Assign(frm_Main.Image2.Picture);
                Status_Label.Caption := 'ID does nor exists.';
                TargetID_MaskEdit.Enabled := true;
                Connect_BitBtn.Enabled := true;
                TargetID_MaskEdit.SetFocus;
              end;
            end);
        end;

        if (Pos('<|ACCESSDENIED|>', s) > 0) then
        begin
          Synchronize(
            procedure
            begin

              with frm_Main do
              begin
                Status_Image.Picture.Assign(Image2.Picture);
                Status_Label.Caption := 'Wrong password!';
                TargetID_MaskEdit.Enabled := true;
                Connect_BitBtn.Enabled := true;
                TargetID_MaskEdit.SetFocus;
              end;
            end);
        end;

        if (Pos('<|ACCESSBUSY|>', s) > 0) then
        begin
          Synchronize(
            procedure
            begin

              with frm_Main do
              begin
                Status_Image.Picture.Assign(Image2.Picture);
                Status_Label.Caption := 'PC is Busy!';
                TargetID_MaskEdit.Enabled := true;
                Connect_BitBtn.Enabled := true;
                TargetID_MaskEdit.SetFocus;
              end;
            end);
        end;

        if (Pos('<|ACCESSGRANTED|>', s) > 0) then
        begin
          Synchronize(
            procedure
            begin
              with frm_Main do
              begin
                Status_Image.Picture.Assign(Image3.Picture);
                Status_Label.Caption := 'Access granted!';
                Viewer := true;

                Clipboard_Timer.Enabled := true;

                ClearConnection;
                frm_RemoteScreen.Show;
                Hide;
                Socket.SendText('<|RELATION|>' + MyID + '<|>' + TargetID_MaskEdit.Text + '<<|');
              end;
            end);
        end;

        if (Pos('<|DISCONNECTED|>', s) > 0) then
        begin
          Synchronize(
            procedure
            begin
              with frm_Main do
              begin
                frm_RemoteScreen.Close;

                LostConnection := true;

                SetOffline;
                CloseSockets;
                Reconnect;

              end;
            end);
        end;

        { Redirected commands }

        // Desktop Remote
        if (Pos('<|RESOLUTION|>', s) > 0) then
        begin
          s2 := s;
          Delete(s2, 1, Pos('<|RESOLUTION|>', s2) + 13);

          frm_Main.ResolutionTargetWidth := strToInt(Copy(s2, 1, Pos('<|>', s2) - 1));
          Delete(s2, 1, Pos('<|>', s2) + 2);

          frm_Main.ResolutionTargetHeight := strToInt(Copy(s2, 1, Pos('<<|', s2) - 1));
        end;

        if (Pos('<|SETMOUSEPOS|>', s) > 0) then
        begin
          s2 := s;
          Delete(s2, 1, Pos('<|SETMOUSEPOS|>', s2) + 14);

          MousePosX := strToInt(Copy(s2, 1, Pos('<|>', s2) - 1));
          Delete(s2, 1, Pos('<|>', s2) + 2);

          MousePosY := strToInt(Copy(s2, 1, Pos('<<|', s2) - 1));

          SetCursorPos(MousePosX, MousePosY);
        end;

        if (Pos('<|SETMOUSELEFTCLICKDOWN|>', s) > 0) then
        begin
          s2 := s;
          Delete(s2, 1, Pos('<|SETMOUSELEFTCLICKDOWN|>', s2) + 24);

          MousePosX := strToInt(Copy(s2, 1, Pos('<|>', s2) - 1));
          Delete(s2, 1, Pos('<|>', s2) + 2);

          MousePosY := strToInt(Copy(s2, 1, Pos('<<|', s2) - 1));

          SetCursorPos(MousePosX, MousePosY);
          Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
        end;

        if (Pos('<|SETMOUSELEFTCLICKUP|>', s) > 0) then
        begin
          s2 := s;
          Delete(s2, 1, Pos('<|SETMOUSELEFTCLICKUP|>', s2) + 22);

          MousePosX := strToInt(Copy(s2, 1, Pos('<|>', s2) - 1));
          Delete(s2, 1, Pos('<|>', s2) + 2);

          MousePosY := strToInt(Copy(s2, 1, Pos('<<|', s2) - 1));

          SetCursorPos(MousePosX, MousePosY);
          Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
        end;

        if (Pos('<|SETMOUSERIGHTCLICKDOWN|>', s) > 0) then
        begin
          s2 := s;
          Delete(s2, 1, Pos('<|SETMOUSERIGHTCLICKDOWN|>', s2) + 25);

          MousePosX := strToInt(Copy(s2, 1, Pos('<|>', s2) - 1));
          Delete(s2, 1, Pos('<|>', s2) + 2);

          MousePosY := strToInt(Copy(s2, 1, Pos('<<|', s2) - 1));

          SetCursorPos(MousePosX, MousePosY);
          Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
        end;

        if (Pos('<|SETMOUSERIGHTCLICKUP|>', s) > 0) then
        begin
          s2 := s;
          Delete(s2, 1, Pos('<|SETMOUSERIGHTCLICKUP|>', s2) + 23);

          MousePosX := strToInt(Copy(s2, 1, Pos('<|>', s2) - 1));
          Delete(s2, 1, Pos('<|>', s2) + 2);

          MousePosY := strToInt(Copy(s2, 1, Pos('<<|', s2) - 1));

          SetCursorPos(MousePosX, MousePosY);
          Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
        end;

        if (Pos('<|SETMOUSEMIDDLEDOWN|>', s) > 0) then
        begin
          s2 := s;
          Delete(s2, 1, Pos('<|SETMOUSEMIDDLEDOWN|>', s2) + 21);

          MousePosX := strToInt(Copy(s2, 1, Pos('<|>', s2) - 1));
          Delete(s2, 1, Pos('<|>', s2) + 2);

          MousePosY := strToInt(Copy(s2, 1, Pos('<<|', s2) - 1));

          SetCursorPos(MousePosX, MousePosY);
          Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MIDDLEDOWN, 0, 0, 0, 0);
        end;

        if (Pos('<|SETMOUSEMIDDLEUP|>', s) > 0) then
        begin
          s2 := s;
          Delete(s2, 1, Pos('<|SETMOUSEMIDDLEUP|>', s2) + 19);

          MousePosX := strToInt(Copy(s2, 1, Pos('<|>', s2) - 1));
          Delete(s2, 1, Pos('<|>', s2) + 2);

          MousePosY := strToInt(Copy(s2, 1, Pos('<<|', s2) - 1));

          SetCursorPos(MousePosX, MousePosY);
          Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MIDDLEUP, 0, 0, 0, 0);
        end;

        if (Pos('<|SETMOUSEDOUBLECLICK|>', s) > 0) then
        begin
          Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
          Sleep(10);
          Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
          Sleep(10);
          Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
          Sleep(10);
          Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
        end;

        if (Pos('<|WHEELMOUSE|>', s) > 0) then
        begin
          s2 := s;
          Delete(s2, 1, Pos('<|WHEELMOUSE|>', s2) + 13);

          s2 := Copy(s2, 1, Pos('<<|', s2) - 1);
          Mouse_Event(MOUSEEVENTF_WHEEL, 0, 0, DWORD(strToInt(s2)), 0);
        end;

        // Clipboard Remote
        if (Pos('<|CLIPBOARD|>', s) > 0) then
        begin
          s2 := s;
          Delete(s2, 1, Pos('<|CLIPBOARD|>', s2) + 12);

          s2 := Copy(s2, 1, Pos('<<|', s2) - 1);

          try
            Clipboard.Open;
            Clipboard.AsText := s2;
          finally
            Clipboard.Close;
          end;
        end;

        // Chat
        if (Pos('<|CHAT|>', s) > 0) then
        begin
          s2 := s;
          Delete(s2, 1, Pos('<|CHAT|>', s2) + 7);

          s2 := Copy(s2, 1, Pos('<<|', s2) - 1);
          Synchronize(
            procedure
            begin
              with frm_Chat do
              begin
                if (FirstMessage) then
                begin
                  LastMessageAreYou := False;
                  Chat_RichEdit.SelStart := Chat_RichEdit.GetTextLen;
                  Chat_RichEdit.SelAttributes.Style := [fsBold];
                  Chat_RichEdit.SelAttributes.Color := clGreen;
                  Chat_RichEdit.SelText := #13 + #13 + 'He say:';
                  FirstMessage := False;
                end;

                if (LastMessageAreYou) then
                begin
                  LastMessageAreYou := False;
                  Chat_RichEdit.SelStart := Chat_RichEdit.GetTextLen;
                  Chat_RichEdit.SelAttributes.Style := [fsBold];
                  Chat_RichEdit.SelAttributes.Color := clGreen;
                  Chat_RichEdit.SelText := #13 + #13 + 'He say:' + #13;

                  Chat_RichEdit.SelStart := Chat_RichEdit.GetTextLen;
                  Chat_RichEdit.SelAttributes.Color := clWhite;
                  Chat_RichEdit.SelText := '   •   ' + s2;
                end
                else
                begin
                  Chat_RichEdit.SelStart := Chat_RichEdit.GetTextLen;
                  Chat_RichEdit.SelAttributes.Style := [];
                  Chat_RichEdit.SelAttributes.Color := clWhite;
                  Chat_RichEdit.SelText := #13 + '   •   ' + s2;
                end;

                SendMessage(Chat_RichEdit.Handle, WM_VSCROLL, SB_BOTTOM, 0);

                if not(Visible) then
                begin
                  PlaySound('BEEP', 0, SND_RESOURCE or SND_ASYNC);
                  Show;
                end;

                if not(Active) then
                begin
                  PlaySound('BEEP', 0, SND_RESOURCE or SND_ASYNC);
                  FlashWindow(frm_Main.Handle, true);
                  FlashWindow(frm_Chat.Handle, true);
                end;
              end;
            end);
        end;

        // Share Files
        // Request Folder List
        if (Pos('<|GETFOLDERS|>', s) > 0) then
        begin
          s2 := s;
          Delete(s2, 1, Pos('<|GETFOLDERS|>', s2) + 13);

          s2 := Copy(s2, 1, Pos('<<|', s2) - 1);

          Socket.SendText('<|REDIRECT|><|FOLDERLIST|>' + ListFolders(s2) + '<<|FOLDERLIST');
        end;

        // Request Files List
        if (Pos('<|GETFILES|>', s) > 0) then
        begin
          s2 := s;
          Delete(s2, 1, Pos('<|GETFILES|>', s2) + 11);

          s2 := Copy(s2, 1, Pos('<<|', s2) - 1);

          Socket.SendText('<|REDIRECT|><|FILESLIST|>' + ListFiles(s2, '*.*') + '<<|FILESLIST');
        end;

        // Receive Folder List
        if (Pos('<|FOLDERLIST|>', s) > 0) then
        begin

          while Socket.Connected do
          begin
            if (Pos('<<|FOLDERLIST', s) > 0) then
              break;

            if (Socket.ReceiveLength > 0) then
              s := s + Socket.ReceiveText;

            Sleep(ProcessingSlack);
          end;

          s2 := s;
          Delete(s2, 1, Pos('<|FOLDERLIST|>', s2) + 13);

          FoldersAndFiles      := TStringList.Create;
          FoldersAndFiles.Text := Copy(s2, 1, Pos('<<|', s2) - 1);
          FoldersAndFiles.Sort;

          Synchronize(
            procedure
            begin
              frm_ShareFiles.ShareFiles_ListView.Clear;
            end);
          for i := 0 to FoldersAndFiles.count - 1 do
          begin
            Synchronize(
              procedure
              begin
                L := frm_ShareFiles.ShareFiles_ListView.Items.Add;
                if (FoldersAndFiles.Strings[i] = '..') then
                begin
                  L.Caption := 'Return';
                  L.ImageIndex := 0;
                end
                else
                begin
                  L.Caption := FoldersAndFiles.Strings[i];
                  L.ImageIndex := 1;
                end;
                frm_ShareFiles.Caption := 'Share Files - ' + IntToStr(frm_ShareFiles.ShareFiles_ListView.Items.count) + ' Items found';
              end);

            Sleep(5); // Effect
          end;
          FreeAndNil(FoldersAndFiles);

          Socket.SendText('<|REDIRECT|><|GETFILES|>' + frm_ShareFiles.Directory_Edit.Text + '<<|');
        end;

        // Receive Files List
        if (Pos('<|FILESLIST|>', s) > 0) then
        begin

          while Socket.Connected do
          begin
            if (Pos('<<|FILESLIST', s) > 0) then
              break;

            if (Socket.ReceiveLength > 0) then
              s := s + Socket.ReceiveText;

            Sleep(ProcessingSlack);
          end;

          s2 := s;
          Delete(s2, 1, Pos('<|FILESLIST|>', s2) + 12);

          FoldersAndFiles      := TStringList.Create;
          FoldersAndFiles.Text := Copy(s2, 1, Pos('<<|', s2) - 1);
          FoldersAndFiles.Sort;

          for i := 0 to FoldersAndFiles.count - 1 do
          begin
            Synchronize(
              procedure
              begin
                L := frm_ShareFiles.ShareFiles_ListView.Items.Add;
                L.Caption := FoldersAndFiles.Strings[i];
                Extension := LowerCase(ExtractFileExt(L.Caption));
                if (Extension = '.exe') then
                  L.ImageIndex := 3
                else if (Extension = '.txt') then
                  L.ImageIndex := 4
                else if (Extension = '.rar') then
                  L.ImageIndex := 5
                else if (Extension = '.mp3') then
                  L.ImageIndex := 6
                else if (Extension = '.zip') then
                  L.ImageIndex := 7
                else if (Extension = '.jpg') then
                  L.ImageIndex := 8
                else if (Extension = '.bat') then
                  L.ImageIndex := 9
                else if (Extension = '.xml') then
                  L.ImageIndex := 10
                else if (Extension = '.sql') then
                  L.ImageIndex := 11
                else if (Extension = '.html') then
                  L.ImageIndex := 12
                else if (Extension = '.xls') then
                  L.ImageIndex := 13
                else if (Extension = '.png') then
                  L.ImageIndex := 14
                else if (Extension = '.doc') then
                  L.ImageIndex := 15
                else if (Extension = '.docx') then
                  L.ImageIndex := 15
                else if (Extension = '.pdf') then
                  L.ImageIndex := 16
                else if (Extension = '.dll') then
                  L.ImageIndex := 17
                else
                  L.ImageIndex := 2;

                frm_ShareFiles.Caption := 'Share Files - ' + IntToStr(frm_ShareFiles.ShareFiles_ListView.Items.count) + ' Items found';
              end);

            Sleep(5); // Effect
          end;
          FreeAndNil(FoldersAndFiles);

          Synchronize(
            procedure
            begin
              frm_ShareFiles.Directory_Edit.Enabled := true;
              frm_ShareFiles.Caption := 'Share Files - ' + IntToStr(frm_ShareFiles.ShareFiles_ListView.Items.count) + ' Items found';
            end);

        end;

        if (Pos('<|UPLOADPROGRESS|>', s) > 0) then
        begin
          s2 := s;
          Delete(s2, 1, Pos('<|UPLOADPROGRESS|>', s2) + 17);

          s2 := Copy(s2, 1, Pos('<<|', s2) - 1);

          Synchronize(
            procedure
            begin
              frm_ShareFiles.Upload_ProgressBar.Position := strToInt(s2);
              frm_ShareFiles.SizeUpload_Label.Caption := 'Size: ' + GetSize(frm_ShareFiles.Upload_ProgressBar.Position) + ' / ' + GetSize(frm_ShareFiles.Upload_ProgressBar.Max);
            end);
        end;

        if (Pos('<|UPLOADCOMPLETE|>', s) > 0) then
        begin
          Synchronize(
            procedure
            begin
              with frm_ShareFiles do
              begin
                Upload_ProgressBar.Position := 0;
                Upload_BitBtn.Enabled := true;
                Directory_Edit.Enabled := False;
                frm_ShareFiles.SizeUpload_Label.Caption := 'Size: 0 B / 0 B';
              end;
            end);

          frm_Main.Main_Socket.Socket.SendText('<|REDIRECT|><|GETFOLDERS|>' + frm_ShareFiles.Directory_Edit.Text + '<<|');

          Synchronize(
            procedure
            begin
              MessageBox(0, 'File sent!', 'AllaKore Remote - Share Files', MB_ICONASTERISK + MB_TOPMOST);
            end);
        end;

        if (Pos('<|DOWNLOADFILE|>', s) > 0) then
        begin
          s2 := s;
          Delete(s2, 1, Pos('<|DOWNLOADFILE|>', s2) + 15);

          s2 := Copy(s2, 1, Pos('<<|', s2) - 1);

          FileToUpload := TFileStream.Create(s2, fmOpenRead);
          frm_Main.Files_Socket.Socket.SendText('<|SIZE|>' + IntToStr(FileToUpload.Size) + '<<|');
          frm_Main.Files_Socket.Socket.SendStream(FileToUpload);
        end;

      end;

    except
    end;

    Sleep(ProcessingSlack); // Avoids using 100% CPU
  end;
end;

procedure TThread_Connection_Keyboard.Execute;
var
  s: string;
begin
  while (Socket.Connected) do
  begin

    if (Socket.ReceiveLength > 0) then
    begin
      s := Socket.ReceiveText;

      // Combo Keys
      if (Pos('<|ALTDOWN|>', s) > 0) then
      begin
        s := StringReplace(s, '<|ALTDOWN|>', '', [rfReplaceAll]);
        keybd_event(18, 0, 0, 0);
      end;

      if (Pos('<|ALTUP|>', s) > 0) then
      begin
        s := StringReplace(s, '<|ALTUP|>', '', [rfReplaceAll]);
        keybd_event(18, 0, KEYEVENTF_KEYUP, 0);
      end;

      if (Pos('<|CTRLDOWN|>', s) > 0) then
      begin
        s := StringReplace(s, '<|CTRLDOWN|>', '', [rfReplaceAll]);
        keybd_event(17, 0, 0, 0);
      end;

      if (Pos('<|CTRLUP|>', s) > 0) then
      begin
        s := StringReplace(s, '<|CTRLUP|>', '', [rfReplaceAll]);
        keybd_event(17, 0, KEYEVENTF_KEYUP, 0);
      end;

      if (Pos('<|SHIFTDOWN|>', s) > 0) then
      begin
        s := StringReplace(s, '<|SHIFTDOWN|>', '', [rfReplaceAll]);
        keybd_event(16, 0, 0, 0);
      end;

      if (Pos('<|SHIFTUP|>', s) > 0) then
      begin
        s := StringReplace(s, '<|SHIFTUP|>', '', [rfReplaceAll]);
        keybd_event(16, 0, KEYEVENTF_KEYUP, 0);
      end;

      if (Pos('?', s) > 0) then
      begin
        if (GetKeyState(VK_SHIFT) < 0) then
        begin
          keybd_event(16, 0, KEYEVENTF_KEYUP, 0);
          SendKeys(PWideChar(s), False);
          keybd_event(16, 0, 0, 0);
        end;

      end
      else
        SendKeys(PWideChar(s), False);

    end;

    Sleep(ProcessingSlack); // Avoids using 100% CPU
  end;
end;

// Connection of Desktop screens
procedure TThread_Connection_Desktop.Execute;
var
  s, s2: string;
  MyFirstBmp, MySecondBmp, MyCompareBmp, UnPackStream, MyTempStream, PackStream: TMemoryStream;
  ReceiveBmpSize, SendBMPSize: Int64;
  ReceivingBmp               : Boolean;
begin
  inherited;

  MyFirstBmp   := nil;
  MySecondBmp  := nil;
  MyCompareBmp := nil;
  UnPackStream := nil;
  MyTempStream := nil;
  PackStream   := nil;

  try

    MyFirstBmp   := TMemoryStream.Create;
    UnPackStream := TMemoryStream.Create;
    MyTempStream := TMemoryStream.Create;
    MySecondBmp  := TMemoryStream.Create;
    MyCompareBmp := TMemoryStream.Create;
    PackStream   := TMemoryStream.Create;
    ReceivingBmp := False;

    while Socket.Connected do
    begin

      Sleep(ProcessingSlack); // Avoids using 100% CPU

      try
        if (Socket.ReceiveLength > 0) then
        begin

          s := Socket.ReceiveText;

          if (Pos('<|GETFULLSCREENSHOT|>', s) > 0) then
          begin

            ResolutionWidth  := Screen.Width;
            ResolutionHeight := Screen.Height;

            frm_Main.Main_Socket.Socket.SendText('<|REDIRECT|><|RESOLUTION|>' + IntToStr(Screen.Width) + '<|>' + IntToStr(Screen.Height) + '<<|');

            ReceiveBmpSize := 0;
            MyFirstBmp.Clear;
            UnPackStream.Clear;
            MyTempStream.Clear;
            MySecondBmp.Clear;
            MyCompareBmp.Clear;
            PackStream.Clear;
            ReceivingBmp := False;

            Synchronize(
              procedure
              begin
                GetScreenToBmp(False, MyFirstBmp, ResolutionWidth, ResolutionHeight);
              end);

            MyFirstBmp.Position := 0;
            PackStream.LoadFromStream(MyFirstBmp);

            CompressStream(PackStream);
            CompressStream(PackStream);

            PackStream.Position := 0;
            SendBMPSize         := PackStream.Size;

            Socket.SendText('<|SIZE|>' + IntToStr(SendBMPSize) + '<<|' + MemoryStreamToString(PackStream));
          end;

          if (Pos('<|GETPARTSCREENSHOT|>', s) > 0) then
          begin
            Synchronize(
              procedure
              begin
                CompareStream(MyFirstBmp, MySecondBmp, MyCompareBmp, ResolutionWidth, ResolutionHeight);
              end);

            MyCompareBmp.Position := 0;
            PackStream.LoadFromStream(MyCompareBmp);

            CompressStream(PackStream);
            CompressStream(PackStream);

            PackStream.Position := 0;
            SendBMPSize         := PackStream.Size;
            Socket.SendText('<|SIZE|>' + IntToStr(SendBMPSize) + '<<|' + MemoryStreamToString(PackStream));
          end;

          if not(ReceivingBmp) then
          begin
            if (Pos('<|SIZE|>', s) > 0) then
            begin
              s2 := s;
              Delete(s2, 1, Pos('<|SIZE|>', s2) + 7);
              s2 := Copy(s2, 1, Pos('<<|', s2) - 1);

              ReceiveBmpSize := strToInt(s2);

              Delete(s, 1, Pos('<<|', s) + 2);
              ReceivingBmp := true;

              Synchronize(
                procedure
                begin
                  frm_RemoteScreen.Caption := 'AllaKore Remote - ' + GetSize(ReceiveBmpSize);
                end);
            end;
          end;

          if (Length(s) > 0) and (ReceivingBmp) then
          begin
            MyTempStream.Write(AnsiString(s)[1], Length(s));

            if (MyTempStream.Size >= ReceiveBmpSize) then
            begin

              Socket.SendText('<|GETPARTSCREENSHOT|>');

              MyTempStream.Position := 0;
              UnPackStream.Clear;
              UnPackStream.LoadFromStream(MyTempStream);
              DeCompressStream(UnPackStream);
              DeCompressStream(UnPackStream);

              if (MyFirstBmp.Size = 0) then
              begin
                MyFirstBmp.CopyFrom(UnPackStream, 0);
                MyFirstBmp.Position := 0;

                Synchronize(
                  procedure
                  begin
                    frm_RemoteScreen.Screen_Image.Picture.Bitmap.LoadFromStream(MyFirstBmp);
                    if (frm_RemoteScreen.Resize_CheckBox.Checked) then
                      ResizeBmp(frm_RemoteScreen.Screen_Image.Picture.Bitmap, frm_RemoteScreen.Screen_Image.Width, frm_RemoteScreen.Screen_Image.Height);
                    frm_RemoteScreen.Caption := 'AllaKore Remote';
                  end);

              end
              else
              begin
                MyCompareBmp.Clear;
                MySecondBmp.Clear;

                MyCompareBmp.CopyFrom(UnPackStream, 0);
                ResumeStream(MyFirstBmp, MySecondBmp, MyCompareBmp);

                Synchronize(
                  procedure
                  begin
                    frm_RemoteScreen.Screen_Image.Picture.Bitmap.LoadFromStream(MySecondBmp);
                    if (frm_RemoteScreen.Resize_CheckBox.Checked) then
                      ResizeBmp(frm_RemoteScreen.Screen_Image.Picture.Bitmap, frm_RemoteScreen.Screen_Image.Width, frm_RemoteScreen.Screen_Image.Height);
                  end);
              end;

              ReceiveBmpSize := 0;
              UnPackStream.Clear;
              MyTempStream.Clear;
              MySecondBmp.Clear;
              MyCompareBmp.Clear;
              PackStream.Clear;
              ReceivingBmp := False;

            end;

          end;

        end;

      except
      end;

    end;

  finally

    FreeAndNil(MyFirstBmp);
    FreeAndNil(UnPackStream);
    FreeAndNil(MyTempStream);
    FreeAndNil(MySecondBmp);
    FreeAndNil(MyCompareBmp);
    FreeAndNil(PackStream);
  end;

end;

// Connection of Share Files
procedure TThread_Connection_Files.Execute;
var
  ReceivingFile: Boolean;
  FileSize     : Int64;
  s, s2        : string;
  FileStream   : TFileStream;
begin
  inherited;

  try

    ReceivingFile := False;
    FileStream    := nil;

    while Socket.Connected do
    begin

      Sleep(ProcessingSlack); // Avoids using 100% CPU

      try
        if (Socket.ReceiveLength > 0) then
        begin
          s := Socket.ReceiveText;

          if not(ReceivingFile) then
          begin

            if (Pos('<|DIRECTORYTOSAVE|>', s) > 0) then
            begin
              s2 := s;
              Delete(s2, 1, Pos('<|DIRECTORYTOSAVE|>', s2) + 18);

              s2 := Copy(s2, 1, Pos('<|>', s2) - 1);

              frm_ShareFiles.DirectoryToSaveFile := s2;
            end;

            if (Pos('<|SIZE|>', s) > 0) then
            begin
              s2 := s;
              Delete(s2, 1, Pos('<|SIZE|>', s2) + 7);
              s2 := Copy(s2, 1, Pos('<<|', s2) - 1);

              FileSize   := strToInt(s2);
              FileStream := TFileStream.Create(frm_ShareFiles.DirectoryToSaveFile + '.tmp', fmCreate or fmOpenReadWrite);

              if (frm_Main.Viewer) then
                Synchronize(
                  procedure
                  begin
                    frm_ShareFiles.Download_ProgressBar.Max := FileSize;
                    frm_ShareFiles.Download_ProgressBar.Position := 0;
                    frm_ShareFiles.SizeDownload_Label.Caption := 'Size: ' + GetSize(FileStream.Size) + ' / ' + GetSize(FileSize);
                  end);

              Delete(s, 1, Pos('<<|', s) + 2);
              ReceivingFile := true;
            end;
          end;

          if (Length(s) > 0) and (ReceivingFile) then
          begin
            FileStream.Write(AnsiString(s)[1], Length(s));
            if (frm_Main.Viewer) then
              Synchronize(
                procedure
                begin
                  frm_ShareFiles.Download_ProgressBar.Position := FileStream.Size;
                  frm_ShareFiles.SizeDownload_Label.Caption := 'Size: ' + GetSize(FileStream.Size) + ' / ' + GetSize(FileSize);
                end)
            else
              frm_Main.Main_Socket.Socket.SendText('<|REDIRECT|><|UPLOADPROGRESS|>' + IntToStr(FileStream.Size) + '<<|');

            if (FileStream.Size = FileSize) then
            begin
              FreeAndNil(FileStream);

              if (FileExists(frm_ShareFiles.DirectoryToSaveFile)) then
                DeleteFile(frm_ShareFiles.DirectoryToSaveFile);

              RenameFile(frm_ShareFiles.DirectoryToSaveFile + '.tmp', frm_ShareFiles.DirectoryToSaveFile);

              if not(frm_Main.Viewer) then
                frm_Main.Main_Socket.Socket.SendText('<|REDIRECT|><|UPLOADCOMPLETE|>')
              else
                Synchronize(
                  procedure
                  begin
                    frm_ShareFiles.Download_ProgressBar.Position := 0;
                    frm_ShareFiles.Download_BitBtn.Enabled := true;
                    frm_ShareFiles.SizeDownload_Label.Caption := 'Size: 0 B / 0 B';
                    MessageBox(0, 'Download complete!', 'AllaKore Remote - Share Files', MB_ICONASTERISK + MB_TOPMOST);
                  end);

              ReceivingFile := False;
            end;

          end;

        end;

      except
      end;

    end;

  finally
    FreeAndNil(FileStream);
  end;

end;

end.
