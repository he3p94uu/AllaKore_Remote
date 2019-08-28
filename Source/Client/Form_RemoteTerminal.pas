unit Form_RemoteTerminal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  Tfrm_RemoteTerminal = class(TForm)
    TerminalSession: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TerminalSessionKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_terminal: Tfrm_RemoteTerminal;
  path: string;

implementation

{$R *.dfm}

uses
  Form_Main;

procedure Tfrm_RemoteTerminal.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if (frm_Main.ConnectType.ItemIndex = 2) then
  begin
    frm_Main.SetOffline;
    frm_Main.CloseSockets;
    frm_Main.Reconnect;
    frm_Main.ReconnectSecundarySockets;
  end;
end;

procedure Tfrm_RemoteTerminal.FormCreate(Sender: TObject);
begin
  TerminalSession.Color := RGB(0, 0, 0);
  TerminalSession.Font.Color := RGB(192, 192, 192);
  TerminalSession.Font.Name := 'Courier New'; // 'Lucida Console';
  TerminalSession.Font.Style := TerminalSession.Font.Style + [fsBold];
  TerminalSession.Font.Size := 10;

  TerminalSession.HideSelection := false;

  TerminalSession.Clear;
end;

procedure Tfrm_RemoteTerminal.FormShow(Sender: TObject);
begin
  frm_main.Main_Socket.Socket.SendText('<|REDIRECT|><|TERMINAL|>' + 'C:\>CMD' + '<|END|>');

  TerminalSession.SelStart:=length(TerminalSession.Text);
end;

procedure Tfrm_RemoteTerminal.TerminalSessionKeyPress(Sender: TObject; var Key: Char);
  var
  s, s1, s2: string;
  i, n: integer;
  p: TPoint;
  flag: boolean;
begin
if ord(key)=13 then
begin

    s1:='';

    i := TerminalSession.Lines.Count - 1;
    flag := false;
    while ((i > 0) and not flag) do
    begin
      s1 := TerminalSession.Lines.Strings[i];
      if (trim(s1)<>'') then
        flag:=true;
      dec(i);
    end;

    s := copy(s1, 1, pos('>', s1)); //строка до команды
    Delete(s1, 1, pos('>', s1));   //команда
    if ( UpperCase(s1)='CLR') then
      TerminalSession.Text:=''
    else
      frm_main.Main_Socket.Socket.SendText('<|REDIRECT|><|TERMINAL|>' + s+s1
        + '<|END|>');
end;
end;

end.
