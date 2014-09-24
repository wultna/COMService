object SerialClientMainForm: TSerialClientMainForm
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'SerialClient'
  ClientHeight = 346
  ClientWidth = 617
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  GlassFrame.Enabled = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object OpenComPortButton: TButton
    Left = 8
    Top = 62
    Width = 601
    Height = 25
    Caption = 'Port '#246'ffnen'
    TabOrder = 0
    OnClick = OpenComPortButtonClick
  end
  object PortNumber: TComboBox
    Left = 8
    Top = 8
    Width = 105
    Height = 21
    ItemIndex = 0
    TabOrder = 1
    Text = 'COM 1'
    Items.Strings = (
      'COM 1'
      'COM 2'
      'COM 3'
      'COM 4'
      'COM 5'
      'COM 6'
      'COM 7'
      'COM 8'
      'COM 9'
      'COM 10'
      'COM 11'
      'COM 12'
      'COM 13'
      'COM 14'
      'COM 15'
      'COM 16')
  end
  object Baudrate: TComboBox
    Left = 8
    Top = 35
    Width = 105
    Height = 21
    ItemIndex = 8
    TabOrder = 2
    Text = '9600 Baud'
    Items.Strings = (
      '50 Baud'
      '75 Baud'
      '110 Baud'
      '300 Baud'
      '600 Baud'
      '1200 Baud'
      '2400 Baud'
      '4800 Baud'
      '9600 Baud'
      '19200 Baud'
      '38400 Baud'
      '56000 Baud'
      '57600 Baud'
      '115200 Baud')
  end
  object Console: TMemo
    Left = 8
    Top = 112
    Width = 601
    Height = 225
    Color = clBtnFace
    Lines.Strings = (
      '--- SerialClient Alpha 1 ---')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object DataBitsField: TComboBox
    Left = 119
    Top = 8
    Width = 106
    Height = 21
    ItemIndex = 4
    TabOrder = 4
    Text = '8 Daten-Bits'
    Items.Strings = (
      '4 Daten-Bits'
      '5 Daten-Bits'
      '6 Daten-Bits'
      '7 Daten-Bits'
      '8 Daten-Bits')
  end
  object StopBitsField: TComboBox
    Left = 119
    Top = 35
    Width = 106
    Height = 21
    ItemIndex = 0
    TabOrder = 5
    Text = '1 Stopp-Bit'
    Items.Strings = (
      '1 Stopp-Bit'
      '1,5 Stopp-Bits'
      '2 Stopp-Bits')
  end
  object ParityField: TComboBox
    Left = 231
    Top = 8
    Width = 106
    Height = 21
    TabOrder = 6
    Text = 'Parit'#228't'
    Items.Strings = (
      'keine (none)'
      'gerade (even)'
      'ungerade (odd)'
      'Markierung (Mark)'
      'Leerzeichen (Space)')
  end
end
