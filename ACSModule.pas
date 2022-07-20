unit ACSModule;

interface
uses Windows, Messages, Classes, StdCtrls, SysUtils, Menus, ACSModule_Ready;


type
  TErrSource         = (esInit, esOpen , esConnect, esGetStatus, esTransmit);
  TOnErrorEvent      = procedure(Sender: TObject; ErrSource: TErrSource; ErrCode: cardinal) of object;
  TOnLogDataEvent    = procedure(Sender: TObject; Location,Status,Data: string) of object;
  TOnProgressEvent   = procedure(Sender: TObject; Accessed: string; RecNo: integer) of object;

  TACSModule = class(TObject)
  protected
    FDebugging          : boolean;
    FContext            : integer;
    FInited             : boolean;
    FOpened             : boolean;
    FConnected          : boolean;
    FCardPresent        : boolean;
    FNumReaders         : integer;
    FUseReaderNum       : integer;
    FReaderList         : TStringlist;
    FAttrProtocol       : integer;
    FAttrICCType        : ansistring;
    FAttrCardATR        : ansistring;
    FAttrCardType       : ansistring;
    FAttrVendorName     : ansistring;
    FAttrViolationOnly  :boolean;
    FAttrVendorSerial   : ansistring;

    FOnReaderWaiting    : TNotifyEvent;
    FOnReaderListChange : TNotifyEvent;
    FOnCardInserted     : TNotifyEvent;
    FOnCardActive       : TNotifyEvent;
    FOnCardRemoved      : TNotifyEvent;
    FOnCardInvalid      : TNotifyEvent;
    FOnError            : TOnErrorEvent;
    FOnLogMessage       : TOnLogDataEvent;
    FOnProgress         : TOnProgressEvent;

    procedure SetReaderNum(Value: integer);
    procedure MessageWndProc(var Msg: TMessage);


  public
    constructor Create;
    destructor  Destroy; override;
    function    Init: boolean;
    function    Open: boolean;
    procedure   Close;
    function    Connect: boolean;
    procedure   Disconnect;
    function    SendPduToCard(const Apdu: ansistring): ansistring;

  published
    property UseReaderNum:       integer          read FUseReaderNum       write SetReaderNum  default -1;
    property OnCardInserted:     TNotifyEvent     read FOnCardInserted     write FOnCardInserted;
    property OnCardActive:       TNotifyEvent     read FOnCardActive       write FOnCardActive;
    property OnCardRemoved:      TNotifyEvent     read FOnCardRemoved      write FOnCardRemoved;
    property OnReaderWaiting:    TNotifyEvent     read FOnReaderWaiting    write FOnReaderWaiting;
    property OnReaderListChange: TNotifyEvent     read FOnReaderListChange write FOnReaderListChange;
    property OnError:            TOnErrorEvent    read FOnError            write FOnError;
    property OnLogMessage:       TOnLogDataEvent  read FOnLogMessage       write FOnLogMessage;

    property ReaderList:       TStringList  read FReaderList;
    property Inited:           boolean      read FInited;
    property Opened:           boolean      read FOpened;
    property Connected:        boolean      read FConnected;
    property AttrCardType:     ansistring   read FAttrCardType;
    property AttrViolationOnly:boolean      read FAttrViolationOnly;
    property Debugging:        boolean      read FDebugging               write FDebugging;

  end;



implementation
const MAX_BUFFER_LEN    = 256;
      MAXAPDULENGTH     = 260; // CLA + INS + P1..3 + 255Bytes
      WM_CARDSTATE     = WM_USER + 42;
var
  ActReaderState  : DWORD;
  LastReaderState : DWORD;
  InUseReader     : AnsiString;
  ReaderOpen      : boolean;
  NotifyHandle    : HWND;
  hContext        : SCARDCONTEXT;
  hCard           : SCARDCONTEXT;
  ioRequest       : SCARD_IO_REQUEST;
  dwActProtocol   : DWORD;

constructor TACSModule.Create;
begin
  inherited Create;
  FReaderList   := TStringlist.Create;
  FContext      := 0;
  FNumReaders   := 0;
  FUseReaderNum := 0;
  FDebugging    := false;
  FInited       := false;
  FOpened       := false;
  FConnected    := false;
  FCardPresent  := false;
  FAttrViolationOnly := false;
  FReaderList   := TStringlist.Create;
  FAttrProtocol := 0;
  FAttrICCType  := '';
  FAttrCardATR  := '';
  FAttrCardType := '';
  FAttrVendorName := '';
  FAttrViolationOnly := false;
  FAttrVendorSerial := '';

  ActReaderState  := SCARD_STATE_UNAWARE;
  LastReaderState := SCARD_STATE_UNAWARE;
  ReaderOpen      := false;
  NotifyHandle := AllocateHWnd(MessageWndProc);
end;

destructor TACSModule.Destroy;
begin
  FReaderList.Free;
  DeallocateHWnd(NotifyHandle);
  inherited Destroy;
end;

function TACSModule.Init: boolean;
var
  retCode    : DWORD;
  BufferLen  : DWORD;
  Buffer     : array [0..MAX_BUFFER_LEN] of AnsiChar;
  Index: Integer;
begin
  FInited := False;
  retCode := SCardEstablishContext(SCARD_SCOPE_USER,
                                   nil,
                                   nil,
                                   @hContext);
  if retCode  <> SCARD_S_SUCCESS then
  begin
    if Assigned(FOnError) then FOnError(Self, esInit, retCode);
    if FDebugging then
      if Assigned(OnLogMessage) then OnLogMessage(Self,'Init',IntToStr(retCode),GetScardErrMsg(retCode));
    Exit;
  end;

  //List PC/SC readers installed in the system
  BufferLen := MAX_BUFFER_LEN;
  retCode := SCardListReadersA(hContext,
                               nil,
                               @Buffer,
                               @BufferLen);
  if retCode <> SCARD_S_SUCCESS then
  begin
    if Assigned(FOnError) then FOnError(Self, esInit, retCode);
    if FDebugging then
      if Assigned(OnLogMessage) then OnLogMessage(Self,'Init',IntToStr(retCode),GetScardErrMsg(retCode));
    Exit;
  end;
  FInited := True;

  LoadListToControl(FReaderList,@buffer,bufferLen);
  FNumReaders := FReaderList.Count;
  if Assigned(OnReaderListChange) then OnReaderListChange(Self);

  Result := True;
end;

procedure TACSModule.MessageWndProc(var Msg: TMessage);
begin
      {if Msg.WParam <> SCARD_S_SUCCESS then
        if Assigned(FOnError) then FOnError(Self, esGetStatus, Msg.WParam); }
  if (Msg.Msg = WM_CARDSTATE) then
    begin
      if not FOpened then Exit;
      if ActReaderState <> LastReaderState then
      begin
        LastReaderState := ActReaderState;

        If ((ActReaderState and SCARD_STATE_PRESENT) > 0) And (FCardPresent = False) Then
        begin
          FCardPresent := True;
          if FDebugging then
            if Assigned(OnLogMessage) then OnLogMessage(Self,'CardWatcherThread','','SCARD_STATE_PRESENT');
          if Assigned(OnCardInserted) then OnCardInserted(Self);
        end;

        If ((ActReaderState and SCARD_STATE_EMPTY) > 0) And (FCardPresent = True) Then
        begin
          FCardPresent := False;
          if FDebugging then
            if Assigned(OnLogMessage) then OnLogMessage(Self,'CardWatcherThread','','SCARD_STATE_EMPTY');
          if Assigned(OnCardRemoved) then OnCardRemoved(Self);

          Disconnect;

          if FDebugging then
            if Assigned(OnLogMessage) then OnLogMessage(Self,'CardWatcherThread','','ReaderWaiting');
          if Assigned(OnReaderWaiting) then OnReaderWaiting(Self);

        end;
      end;
    end
    else Msg.Result := DefWindowProc(NotifyHandle, Msg.Msg, Msg.WParam, Msg.LParam);
end;

function CardWatcherThread(PContext: pointer): integer;
var
  RetVar   : Integer;
  RState   : SCARD_READERSTATE;
begin
  try
    RState.szReader := PAnsiChar(InUseReader);
    RState.pvUserData := nil;
    RState.dwEventStates := ActReaderState;

    while ReaderOpen do
    begin
      try
        RState.dwCurrentState := RState.dwEventStates;
        RetVar := LongintToDword(SCardGetStatusChangeA(hContext, 0, @RState, 1));
        ActReaderState := RState.dwEventStates;
        PostMessage(NotifyHandle, WM_CARDSTATE, RetVar, 0);
        Sleep(50);
      except
      end;
    end;

  finally
    Result := 0;
  end;
end;


function TACSModule.Open: boolean;
var ThreadID    : LongWord;
begin
  //Check Reader Is Open
  If FOpened Then
  begin
    if Assigned(FOnError) then FOnError(Self, esOpen, SCARD_E_READER_IS_ALR_OPEN);
    if FDebugging then
      if Assigned(OnLogMessage) then OnLogMessage(Self,'Open',IntToStr(SCARD_E_READER_IS_ALR_OPEN),GetScardErrMsg(SCARD_E_READER_IS_ALR_OPEN));
    exit;
  end;

  //Check Reader Num To Open It!
  if ((FUseReaderNum = 0) Or (FUseReaderNum > FNumReaders)) then
  begin
    if Assigned(FOnError) then FOnError(Self, esOpen, SCARD_E_SELECT_READER_FIRST);
    if FDebugging then
      if Assigned(OnLogMessage) then OnLogMessage(Self,'Open',IntToStr(SCARD_E_SELECT_READER_FIRST),GetScardErrMsg(SCARD_E_SELECT_READER_FIRST));
    exit;
  end;

  FOpened := True;
  ReaderOpen := True;

  ActReaderState  := SCARD_STATE_UNAWARE;
  LastReaderState := SCARD_STATE_UNAWARE;
  BeginThread(nil, 0, CardWatcherThread, @FContext, 0, ThreadID);
  if FDebugging then
    if Assigned(OnLogMessage) then OnLogMessage(Self,'CardWatcherThread','','ReaderWaiting');
  if Assigned(OnReaderWaiting) then OnReaderWaiting(Self);


  Result := True;
end;

procedure TACSModule.Close;
begin
  FOpened := False;
  ReaderOpen := False;
  SCardReleaseContext(FContext);
  FContext:= 0;
  hCard   := 0;
end;

function TACSModule.Connect: boolean;
var
  retCode    : DWORD;
  BufferLen  : DWORD;
  Buffer     : array [0..MAX_BUFFER_LEN] of AnsiChar;
  pdwState   : DWORD;
begin
  If not FOpened Then
  begin
    if Assigned(FOnError) then FOnError(Self, esConnect, SCARD_E_READER_IS_NOT_OPEN);
    if FDebugging then
      if Assigned(OnLogMessage) then OnLogMessage(Self,'Connect',IntToStr(SCARD_E_READER_IS_NOT_OPEN),GetScardErrMsg(SCARD_E_READER_IS_NOT_OPEN));
    exit;
  end;

  If FConnected Then
  begin
    if Assigned(FOnError) then FOnError(Self, esConnect, SCARD_E_READER_IS_ALR_CONNECT);
    if FDebugging then
      if Assigned(OnLogMessage) then OnLogMessage(Self,'Connect',IntToStr(SCARD_E_READER_IS_ALR_CONNECT),GetScardErrMsg(SCARD_E_READER_IS_ALR_CONNECT));
    exit;
  end;
  retCode := SCardConnectA(hContext,
                           PAnsichar(AnsiString(FReaderList.Strings[FUseReaderNum-1])),
                           SCARD_SHARE_SHARED,
                           SCARD_PROTOCOL_T0 or SCARD_PROTOCOL_T1,
                           @hCard,
                           @dwActProtocol);

  if retCode <> SCARD_S_SUCCESS then
  begin
    FConnected := False;
    if Assigned(FOnError) then FOnError(Self, esConnect, retCode);
    if FDebugging then
      if Assigned(OnLogMessage) then OnLogMessage(Self,'Connect',IntToStr(retCode),GetScardErrMsg(retCode));
    exit;
  end;

  //Get Card Attr
  BufferLen := MAX_BUFFER_LEN;
  retCode := SCardState(hCard,@pdwState,@dwActProtocol,@Buffer,@BufferLen);
  FAttrCardATR := Copy(Buffer, 0, BufferLen);
  case Buffer[14] of
    #$01:FAttrCardType := 'Mifare 1K';
    #$02:FAttrCardType := 'Mifare 4K';
    #$03:FAttrCardType := 'Mifare UltraLight';
    #$26:FAttrCardType := 'Mifare Mini';
  else
    FAttrCardType := 'Unknown';
  end;
  if Pos('ACR122',FReaderList.Strings[FUseReaderNum-1]) > 0 then FAttrViolationOnly := True;

  FConnected := True;
  if Assigned(OnCardActive) then OnCardActive(Self);

  Result := True;
end;

procedure TACSModule.Disconnect;
begin
  SCardDisconnect(hCard,SCARD_RESET_CARD);
  FCardPresent := False;
  FConnected := False;
end;

function TACSModule.SendPduToCard(const APDU: AnsiString): AnsiString;
var
  retCode  : DWORD;
  SendBuff : TBytes;
  RecvBuff : AnsiString;
  SendLen  : DWORD;
  RecvLen  : DWORD;
begin
  SendBuff := BytesOf(APDU);
  SendLen := Length(APDU);
  RecvBuff := StringOfChar(#0,MAXAPDULENGTH);
  RecvLen := MAXAPDULENGTH;
  ioRequest.dwProtocol := dwActProtocol;
  ioRequest.cbPciLength := sizeof(SCARD_IO_REQUEST);
  retCode := SCardTransmit(hCard,
                           @ioRequest,
                           Pointer(SendBuff),
                           SendLen,
                           Nil,
                           Pointer(RecvBuff),
                           @RecvLen);

  if retCode = SCARD_S_SUCCESS then
  begin
    Result := Copy(RecvBuff,1,RecvLen);
    if FDebugging then
      if Assigned(FOnLogMessage) then
        begin
          if Length(Result) = 2 then
            FOnLogMessage(Self,'SendPduToCard',IntToStr(retCode),DecodeResponseCode(BytesToCardinal(Result)))
          else
          begin
            FOnLogMessage(Self,'SendPduToCard',IntToStr(retCode),DecodeResponseCode(BytesToCardinal(Copy(Result,RecvLen-1,2))));
          end;
        end;

    if RecvLen > 2 then
      Result := Copy(Result,1,RecvLen-2);
  end
  else
  begin
    Result := '';
    if Assigned(FOnError) then FOnError(Self, esTransmit, retCode);
    if FDebugging then
      if Assigned(OnLogMessage) then OnLogMessage(Self,'SendPduToCard',IntToStr(retCode),GetScardErrMsg(retCode));
    Exit;
  end;
end;


procedure TACSModule.SetReaderNum(Value: integer);
begin
  FUseReaderNum := Value;
  InUseReader := PAnsiChar(AnsiString(FReaderList.Strings[FUseReaderNum-1]));
end;


end.







