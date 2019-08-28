object frm_RemoteTerminal: Tfrm_RemoteTerminal
  Left = 0
  Top = 0
  Caption = 'Remote Terminal'
  ClientHeight = 430
  ClientWidth = 664
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object TerminalSession: TMemo
    Left = 0
    Top = 0
    Width = 664
    Height = 430
    Align = alClient
    TabOrder = 0
    OnKeyPress = TerminalSessionKeyPress
  end
end
