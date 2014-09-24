unit Com;

interface

uses
  WinTypes, WinProcs, Classes, SysUtils;

type
  TRTSMode = (RTS_DISABLED, RTS_ENABLED, RTS_HANDSHAKE, RTS_TOGGLE);
  TDTRMode = (DTR_DISABLED, DTR_ENABLED, DTR_HANDSHAKE);
  TParity = (NOPARITY, ODDPARITY, EVENPARITY, MARKPARITY, SPACEPARITY);
  TStopbits = (ONESTOPBIT, ONE5STOPBITS, TWOSTOPBITS);
  TCOM = class(TComponent)
  private
    FDCB: TDCB;
    FHandle: Cardinal;
    FTimeouts: TCommTimeouts;
    FError: Cardinal;
    FComNo: byte;
    FBaud: cardinal;
    FParity: TParity;
    FDatabits: byte;
    FStopbits: TStopbits;

    function GetRTS: boolean;
    procedure SetRTS(const Value: boolean);
    function GetDTR: boolean;
    procedure SetDTR(const Value: boolean);
    function GetDCD: boolean;
    function GetDSR: boolean;
    function GetRI: boolean;
    function GetCTS: boolean;
    function GetIsOpen: boolean;
    function GetInBufUsed: cardinal;
    function GetOutBufUsed: cardinal;
    function GetParity: String;
    function GetStopBits: String;
    function GetBaudRate: cardinal;
    function GetDataBits: byte;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function TestComPortAvailable(ComNo: integer): boolean;
    function Open(ComNo: integer; RTSMode: TRTSMode; DTRMode: TDTRMode): boolean;
    function RxFlush: boolean;
    function TxFlush: boolean;
    function Send(Data: Char): boolean; overload;
    function Send(Data: PChar; Len: cardinal): boolean; overload;
    function GetChar(var data: byte): boolean;

    procedure Close;
    procedure Reset;
  published
    property ComNo: byte read FComNo;
    property Baud: cardinal read GetBaudRate write FBaud;
    property Databits: byte read GetDatabits write FDatabits;
    property Stopbits: String read GetStopBits;
    property Parity: String read GetParity;
    property IsOpen: boolean read GetIsOpen;
    property InBufUsed: cardinal read GetInBufUsed;
    property OutBufUsed: cardinal read GetOutBufUsed;
    property Error: cardinal read FError;
    property RTS: boolean read GetRTS write SetRTS;
    property CTS: boolean read GetCTS;
    property DTR: boolean read GetDTR write SetDTR;
    property DSR: boolean read GetDSR;
    property RI: boolean read GetRI;
    property DCD: boolean read GetDCD;
  end;

var FCOM: TCOM;

implementation


{----------------------------------------------------------------------------------------------}

constructor TCOM.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHandle := INVALID_HANDLE_VALUE;

  Baud := CBR_9600;
  FDatabits := 8;
  FParity := NOPARITY;
  FStopBits := ONESTOPBIT;
end;

{----------------------------------------------------------------------------------------------}

destructor TCOM.Destroy;
begin
  if IsOpen then Close; { Port schließen falls geöffnet          }
  inherited destroy;
end;

{----------------------------------------------------------------------------------------------}

function TCOM.TestComPortAvailable(ComNo: integer): boolean;
begin
  Result := Open(ComNo, RTS_DISABLED, DTR_DISABLED);
end;

{----------------------------------------------------------------------------------------------}

function TCOM.Open(ComNo: integer; RTSMode: TRTSMode; DTRMode: TDTRMode): boolean;
var init: string;
begin
  if FHandle = INVALID_HANDLE_VALUE then
  begin
    init := '\\.\COM' + IntToStr(ComNo);
    FHandle := CreateFile(@init[1],
      GENERIC_READ or GENERIC_WRITE,
      0, nil,
      OPEN_EXISTING,
      FILE_ATTRIBUTE_NORMAL,
      0);
    if FHandle <> INVALID_HANDLE_VALUE then
    begin
      FComNo := ComNo;
      // aktuelle Einstellungen ermitteln
      if GetCommState(FHandle, FDCB) then
      begin
        // rudimentäre Parameter setzen
        FDCB.Baudrate := FBaud;
        FDCB.Bytesize := FDatabits;
        FDCB.Parity := Ord(FParity);
        FDCB.Stopbits := Ord(FStopbits);

        // RTS Modus setzen
        FDCB.flags := FDCB.flags and $CFFB; {RTS aus}
        case RTSMode of
          RTS_ENABLED: FDCB.flags := FDCB.flags or $1000; {RTS ein}
          RTS_HANDSHAKE: FDCB.flags := FDCB.flags or $2004; {RTS Handshake ein (gekoppelt an RX Buffer 0= Empfangspuffer zu 3/4 voll)}
          RTS_TOGGLE: FDCB.flags := FDCB.flags or $3000; {RTS gekoppelt an Tx Buffer (1=Daten im Sendepuffer)}
        end;
        // DTR Modus setzen
        FDCB.flags := FDCB.flags and $FFC7; {DTR aus (und bleibt aus)}
        case DTRMode of
          DTR_ENABLED: FDCB.flags := FDCB.flags or $0010; {DTR ein (und bleibt ein)}
          DTR_HANDSHAKE: FDCB.flags := FDCB.flags or $0028; {DTR Handshake ein}
        end;

        if SetCommState(FHandle, FDCB) then
        begin
          if SetupComm(FHandle, 1024, 1024) then {Rx-/Tx-Buffer-Einstellungen}
          begin
            FTimeouts.ReadIntervalTimeout := 0; {Timeoutzeiten setzen}
            FTimeouts.ReadTotalTimeoutMultiplier := 0;
            FTimeouts.ReadTotalTimeoutConstant := 1;
            FTimeouts.WriteTotalTimeoutMultiplier := 0;
            FTimeouts.WriteTotalTimeoutConstant := 0;
            SetCommTimeouts(FHandle, FTimeouts);
          end;
        end;
      end;
    end;
  end;

  FError := GetLastError;

  if Error <> 0 then
  begin
    Close;
  end;

  Result := Error = 0; { Ergebnis zurückgeben                   }
end;

{-----------------------------------------------------------------------------------------------}

function TCOM.GetCTS: boolean;
var nStatus: cardinal;
begin
  Result := false;
  if FHandle <> INVALID_HANDLE_VALUE then
  begin
    if GetCommModemStatus(FHandle, nStatus) then
      Result := (nStatus and MS_CTS_ON) > 0;
  end;
end;

{-----------------------------------------------------------------------------------------------}

function TCOM.GetDSR: boolean;
var nStatus: cardinal;
begin
  Result := false;
  if FHandle <> INVALID_HANDLE_VALUE then
  begin
    if GetCommModemStatus(FHandle, nStatus) then
      Result := (nStatus and MS_DSR_ON) > 0;
  end;
end;

{-----------------------------------------------------------------------------------------------}

function TCOM.GetIsOpen: boolean;
begin
  Result := FHandle <> INVALID_HANDLE_VALUE;
end;

{-----------------------------------------------------------------------------------------------}

function TCOM.GetInBufUsed: cardinal;
var
  Comstat: _Comstat;
  Errors: DWord;
begin
  if ClearCommError(FHandle, Errors, @Comstat) then
    Result := Comstat.cbInQue else Result := 0;
end;
{-----------------------------------------------------------------------------------------------}

function TCOM.GetOutBufUsed: cardinal;
var
  Comstat: _Comstat;
  Errors: DWord;
begin
  if ClearCommError(FHandle, Errors, @Comstat) then
    Result := Comstat.cbOutQue else Result := 0;
end;

{-----------------------------------------------------------------------------------------------}

function TCOM.GetRI: boolean;
var nStatus: cardinal;
begin
  Result := false;
  if FHandle <> INVALID_HANDLE_VALUE then
  begin
    if GetCommModemStatus(FHandle, nStatus) then
      Result := (nStatus and MS_RING_ON) > 0;
  end;
end;

{-----------------------------------------------------------------------------------------------}

function TCOM.GetRTS: boolean;
begin
  Result := false;
  if GetCommState(FHandle, FDCB) then
  begin
    Result := (FDCB.Flags and $3000) > 0;
  end;
end;

{-----------------------------------------------------------------------------------------------}

procedure TCOM.SetRTS(const Value: boolean);
begin
  if (Value = True) then
    EscapeCommFunction(FHandle, WinTypes.SETRTS)
  else
    EscapeCommFunction(FHandle, WinTypes.CLRRTS);
end;

{-----------------------------------------------------------------------------------------------}

function TCOM.GetDTR: boolean;
begin
  Result := false;
  if GetCommState(FHandle, FDCB) then
  begin
    Result := (FDCB.Flags and $0010) > 0;
  end;
end;
{-----------------------------------------------------------------------------------------------}

procedure TCOM.SetDTR(const Value: boolean);
begin
  if (Value = True) then
    EscapeCommFunction(FHandle, WinTypes.SETDTR)
  else
    EscapeCommFunction(FHandle, WinTypes.CLRDTR);
end;
{-----------------------------------------------------------------------------------------------}

function TCOM.GetDCD: boolean;
var nStatus: cardinal;
begin
  Result := false;
  if FHandle <> INVALID_HANDLE_VALUE then
  begin
    if GetCommModemStatus(FHandle, nStatus) then
      Result := (nStatus and MS_RLSD_ON) > 0;
  end;
end;

{-----------------------------------------------------------------------------------------------}

function TCOM.GetParity: String;
begin
  case FDCB.Parity of
    0: result := 'keine';
    1: result := 'ungerade';
    2: result := 'gerade';
    3: result := 'Markierung';
    4: result := 'Leerzeichen';
  end;
end;

{-----------------------------------------------------------------------------------------------}

function TCOM.GetStopBits: String;
begin
  case FDCB.Stopbits of
    0: result := '1';
    1: result := '1,5';
    2: result := '2';
  end;
end;

{-----------------------------------------------------------------------------------------------}

function TCOM.GetBaudRate: cardinal;
begin
  result := FDCB.Baudrate;
end;

{-----------------------------------------------------------------------------------------------}

function TCOM.GetDataBits: byte;
begin
  result := FDCB.ByteSize;
end;

{-----------------------------------------------------------------------------------------------}

procedure TCOM.Close;
begin
  if CloseHandle(FHandle) then { Schnittstelle schließen                }
    FHandle := INVALID_HANDLE_VALUE;

  FError := GetLastError;
end;

{-----------------------------------------------------------------------------------------------}

procedure TCOM.Reset;
begin
  if not EscapeCommFunction(FHandle, WinTypes.RESETDEV) then
    FError := GetLastError;
end;

{-----------------------------------------------------------------------------------------------}

function TCOM.RxFlush: boolean;
begin
  if FHandle <> INVALID_HANDLE_VALUE then
  begin
    PurgeComm(FHandle, PURGE_RXCLEAR);
    FError := GetLastError;
  end;

  Result := FError = 0;
end;

{-----------------------------------------------------------------------------------------------}

function TCOM.TxFlush: boolean;
begin
  if FHandle <> INVALID_HANDLE_VALUE then
  begin
    PurgeComm(FHandle, PURGE_TXCLEAR);
    FError := GetLastError;
  end;

  Result := FError = 0;
end;

{-----------------------------------------------------------------------------------------------}

function TCOM.Send(Data: Char): boolean;
var nWritten, nCount: Cardinal;
begin
  Result := false;

  if FHandle <> INVALID_HANDLE_VALUE then
  begin
    nCount := SizeOf(Data);
    if WriteFile(FHandle, Data, nCount, nWritten, nil) then
    begin
      Result := nCount = nWritten;
    end;
    FError := GetLastError;
  end;
end;

{-----------------------------------------------------------------------------------------------}

function TCOM.Send(Data: PChar; Len: cardinal): boolean;
var nWritten, nCount: Cardinal;
begin
  Result := false;

  if FHandle <> INVALID_HANDLE_VALUE then
  begin
    nCount := Len;
    if WriteFile(FHandle, Data^, nCount, nWritten, nil) then
    begin
      Result := nCount = nWritten;
    end;
    FError := GetLastError;
  end;
end;

{-----------------------------------------------------------------------------------------------}

function TCOM.GetChar(var data: byte): boolean;
var nCount, nRead: cardinal;
begin
  Result := false;
  if FHandle <> INVALID_HANDLE_VALUE then
  begin
    nCount := SizeOf(data);

    if InBufUsed >= nCount then
    begin
      if ReadFile(FHandle, data, nCount, nRead, nil) then
      begin
        Result := nCount = nRead;
      end;
    end;

    FError := GetLastError;
  end;
end;


end.
