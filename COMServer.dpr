program COMServer;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {SerialClientMainForm},
  Com in 'Com.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TSerialClientMainForm, SerialClientMainForm);
  Application.Run;
end.
