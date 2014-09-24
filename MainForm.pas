unit MainForm;

interface

uses
  Com, Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Actions,
  Vcl.ActnList;

type
  TSerialClientMainForm = class(TForm)
    OpenComPortButton: TButton;
    PortNumber: TComboBox;
    Baudrate: TComboBox;
    Console: TMemo;
    DataBitsField: TComboBox;
    StopBitsField: TComboBox;
    ParityField: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure OpenComPortButtonClick(Sender: TObject);
    function ReadBaud: cardinal;
    function ReadDataBits: cardinal;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

  TReceiveLoop = class(TThread)
    procedure execute; override;
  end;

var
  SerialClientMainForm: TSerialClientMainForm;
  COM: TCOM;
  ReceiveLoop: TReceiveLoop;

implementation

{$R *.dfm}

function TSerialClientMainForm.ReadBaud: cardinal;
begin
  case BaudRate.ItemIndex of
     0: result := 50;
     1: result := 75;
     2: result := 110;
     3: result := 300;
     4: result := 600;
     5: result := 1200;
     6: result := 2400;
     7: result := 4800;
     8: result := 9600;
     9: result := 19200;
    10: result := 38400;
    11: result := 56000;
    12: result := 57600;
    13: result := 115200;
  end;
end;

function TSerialClientMainForm.ReadDataBits: cardinal;
begin
  case BaudRate.ItemIndex of
     0: result := 50;
     1: result := 75;
     2: result := 110;
     3: result := 300;
     4: result := 600;
     5: result := 1200;
     6: result := 2400;
     7: result := 4800;
     8: result := 9600;
     9: result := 19200;
    10: result := 38400;
    11: result := 56000;
    12: result := 57600;
    13: result := 115200;
  end;
end;

procedure TSerialClientMainForm.OpenComPortButtonClick(Sender: TObject);
var
  Connected: boolean;
begin
  if COM.IsOpen = false then
  begin
    COM.Baud := ReadBaud;
    Console.Lines.Add('Öffne COM ' + IntToStr((PortNumber.ItemIndex) + 1) + sLineBreak + ' ...');
    OpenComPortButton.Enabled := false;
    Connected := COM.TestComPortAvailable((PortNumber.ItemIndex) + 1);
    PortNumber.Enabled := false;
    BaudRate.Enabled := false;
    if COM.IsOpen then
    begin
      Console.Lines.add('COM ' + IntToStr(COM.ComNo) + ' geöffnet mit ' + IntToStr(COM.Baud) + ' Baud!' + sLineBreak +
        'Datenbits: ' + IntToStr(Com.Databits) + sLineBreak +
        'Stoppbits: ' + COM.Stopbits + sLineBreak +
        'Parität: ' + COM.Parity + sLineBreak);
      ReceiveLoop := TReceiveLoop.Create(false);
      OpenComPortButton.Enabled := true;
      OpenComPortButton.Caption := 'Port schließen';
    end
    else begin
      Console.Lines.add('COM ' + IntToStr(COM.ComNo) + ' nicht geöffnet! Fehlercode ' + IntToStr(COM.Error) + sLineBreak);
      OpenComPortButton.Enabled := true;
      PortNumber.Enabled := true;
      BaudRate.Enabled := true;
    end;
  end
  else begin
    ReceiveLoop.Terminate;
    ReceiveLoop.WaitFor;
    ReceiveLoop.free;
    Console.Lines.Add('schließe COM ' + IntToStr(COM.ComNo) + sLineBreak + ' ...');
    OpenComPortButton.Enabled := false;
    PortNumber.Enabled := false;
    BaudRate.Enabled := false;
    COM.Close;
    if COM.IsOpen then
    begin
      OpenComPortButton.Enabled := true;
      Console.Lines.add('COM ' + IntToStr(COM.ComNo) + ' nicht geschlossen! Fehlercode ' + IntToStr(COM.Error) + sLineBreak);
    end
    else begin
      OpenComPortButton.Enabled := true;
      OpenComPortButton.Caption := 'Port öffnen';
      PortNumber.Enabled := true;
      BaudRate.Enabled := true;
      Connected := false;
      Console.Lines.Add('COM ' + IntToStr(COM.ComNo) + ' geschlossen!' + sLineBreak);
    end;
  end;

end;

procedure TSerialClientMainForm.FormCreate(Sender: TObject);
begin
  COM := TCOM.Create(SerialClientMainForm);
end;

procedure TSerialClientMainForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ReceiveLoop <> nil then
  begin
    ReceiveLoop.Terminate;
  end;
  if COM <> nil then COM.free;
end;


// ---------------------------------------------------------------


procedure TReceiveLoop.Execute;
var
  RxData: byte;
  RxString: String;
  i: integer;
  SomeThingInBuffer: boolean;
  RxBinaryData: byte;
begin
  RxData := 0;
  while not terminated do
  begin
    SomeThingInBuffer := false;
    while COM.GetChar(RxData) do begin
      RxString := RxString + Char(RxData);
      SomeThingInBuffer := true;
    end;
    if SomeThingInBuffer then SerialClientMainForm.Console.Lines.Add(RxString);
    RxString := '';
    sleep(1);
  end;
end;

end.
