unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,SUISkinForm, SUISkinControl, ExtCtrls,
  SUIForm, ACSModule , ACSModule_Ready, ComCtrls, Spin;

type
  TMainForm = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    CB_ReaderList: TComboBox;
    BT_OpenReader: TButton;
    BT_InitReader: TButton;
    GroupBox2: TGroupBox;
    LB_Logs: TListBox;
    GroupBox3: TGroupBox;
    BT_FormatDefaultCard: TButton;
    BT_ReadDefaultCard: TButton;
    BT_ReadIAUSCard: TButton;
    BT_FormatIAUSCard: TButton;
    BT_FormatIAUSCardToDefault: TButton;
    BT_GetCardUID: TButton;
    PB_Sector: TProgressBar;
    GroupBox4: TGroupBox;
    SP_Sector: TSpinEdit;
    Label2: TLabel;
    SP_Block: TSpinEdit;
    Label3: TLabel;
    BT_Write: TButton;
    BT_ReadCustom: TButton;
    ED_CustomData: TEdit;
    CB_Debug: TCheckBox;
    BT_ReadTransCard: TButton;
    procedure BT_InitReaderClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BT_OpenReaderClick(Sender: TObject);
    procedure BT_FormatDefaultCardClick(Sender: TObject);
    procedure BT_ReadDefaultCardClick(Sender: TObject);
    procedure BT_ReadIAUSCardClick(Sender: TObject);
    procedure BT_FormatIAUSCardClick(Sender: TObject);
    procedure BT_FormatIAUSCardToDefaultClick(Sender: TObject);
    procedure BT_GetCardUIDClick(Sender: TObject);
    procedure BT_ReadCustomClick(Sender: TObject);
    procedure BT_WriteClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CB_DebugClick(Sender: TObject);
    procedure BT_ReadTransCardClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure OnCardInserted(Sender: TObject);
    procedure OnCardRemoved(Sender: TObject);
    procedure OnLogMessage(Sender: TObject;Location,Status,Data:String);
    procedure OnCardActive(Sender: TObject);
    procedure OnCardInvalid(Sender: TObject);
    procedure OnReaderWaiting(Sender: TObject);
    procedure OnReaderListChange(Sender: TObject);
    procedure OnError(Sender: TObject;ErrSource:TErrSource;ErrCode:Cardinal);
    procedure OnProgress(Sender: TObject;Str1:String;Code1:Integer);
    procedure AddLog(Description:String);
    procedure InitReader;
    procedure ConnectToReader;
    function GetUID:ansistring;
    function SetAttributeToReaderViolation(Sector,Key:Integer):AnsiString;
    function SetAttributeToReaderNonViolation(Sector,Key,KeyStore:Integer):AnsiString;
    function AuthenticationMifare(Block,Key:Integer;KeyLocation:Integer = 32):AnsiString;
    function ReadBinaryBlock(Block:Integer):AnsiString;
    function WriteBinaryBlock(Block:Integer;Data:AnsiString):AnsiString;
    function Complete16Byte(Data:AnsiString):AnsiString;
  end;

Const
  OperationComplete = #$90#$00;
  DefaultKey = #$FF#$FF#$FF#$FF#$FF#$FF;
  DefaultData = #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00;
  DefaultSecret = #$FF#$07#$80#$69;
  IAUSAttr : Array[0..17,1..2] of String = (
  (#$AC#$B9#$26#$21#$63#$3F,#$3F#$A9#$B4#$35#$43#$6C),
  (#$41#$41#$6F#$3F#$3F#$EE,#$3F#$69#$3F#$3F#$A3#$3F),
  (#$63#$3F#$1F#$3F#$3F#$3F,#$3F#$3F#$55#$3F#$3F#$0B),
  (#$6A#$1B#$29#$35#$52#$3F,#$1C#$43#$3F#$3F#$42#$2F),
  (#$3F#$4B#$20#$A8#$58#$A8,#$3B#$41#$4C#$4F#$3F#$35),
  (#$4F#$A9#$3F#$3F#$08#$7E,#$2D#$F9#$79#$08#$AE#$3F),
  (#$76#$B1#$3F#$E7#$B4#$3B,#$55#$3F#$51#$3F#$3F#$B3),
  (#$3F#$45#$76#$43#$04#$3F,#$3F#$51#$3F#$3F#$3F#$30),
  (#$6C#$32#$6F#$7B#$27#$F7,#$3F#$61#$3F#$B9#$A2#$48),
  (#$4E#$45#$3F#$73#$A9#$4C,#$5C#$3F#$3F#$7E#$3F#$FB),
  (#$79#$41#$20#$3F#$A2#$3B,#$6B#$11#$3F#$3F#$3F#$1C),
  (#$1E#$A2#$07#$55#$3A#$0F,#$10#$E9#$4B#$E7#$4F#$1A),
  (#$3F#$3F#$09#$62#$55#$6D,#$3F#$3F#$70#$B1#$38#$BC),
  (#$B7#$3F#$3F#$3F#$3F#$3F,#$3F#$70#$1E#$20#$3F#$06),
  (#$E0#$35#$3F#$50#$20#$3E,#$3F#$44#$36#$3F#$65#$AC),
  (#$62#$3F#$49#$69#$7F#$01,#$A6#$3F#$35#$50#$3F#$E9),
  (#$FF#$FF#$FF#$FF#$FF#$FF,#$FF#$FF#$FF#$FF#$FF#$FF),  //Default Key
  (#$48#$41#$52#$49#$53#$48,#$48#$41#$52#$49#$53#$48));
var
  MainForm: TMainForm;
  Reader:TACSModule;
implementation

{$R *.dfm}



procedure TMainForm.AddLog(Description:String);
begin
  LB_Logs.Items.Add(Description);
  LB_Logs.ItemIndex := LB_Logs.Count - 1;
end;

procedure TMainForm.OnCardInserted(Sender: TObject);
begin
  AddLog('کارت در کارت خوان قرار گرفته است');
  Reader.Connect;
end;

procedure TMainForm.OnCardRemoved(Sender: TObject);
begin
  AddLog('کارت از کارت خوان خارج شد');
end;

procedure TMainForm.OnLogMessage(Sender: TObject;Location,Status,Data:String);
begin
  AddLog(Location+' '+Status+' '+Data);
end;

procedure TMainForm.OnCardActive(Sender: TObject);
begin
  AddLog('اتصال به کارت برقرار شد');
  AddLog('نوع کارت شناسایی شده: '+Reader.AttrCardType);
  AddLog('کد کارت: '+GetUID);

 {if Reader.AttrCardType <> 'Mifare 1K' then
  begin
    AddLog('کارت مورد نظر Mifare 1K نمی باشد');
    Reader.Disconnect;
  end; }

end;

procedure TMainForm.OnCardInvalid(Sender: TObject);
begin
  AddLog('کارت قابل شناسایی نیست');
end;

procedure TMainForm.OnReaderWaiting(Sender: TObject);
begin
  AddLog('کارت خوان در انتظار دریافت کارت است...');
end;

procedure TMainForm.OnReaderListChange(Sender: TObject);
var
  I: Integer;
begin
  AddLog('فهرست کارت‌خوان‌ها بروز شد');
  CB_ReaderList.Clear;
  CB_ReaderList.Items.AddStrings(Reader.ReaderList);
  for I := 0 to CB_ReaderList.Items.Count - 1 do
  begin
    If Pos('PICC',CB_ReaderList.Items.Strings[I]) > 0 Then
    Begin
      CB_ReaderList.ItemIndex:=I;
      Break;
    End;
    If Pos('ACR122',CB_ReaderList.Items.Strings[I]) > 0 Then
    Begin
      CB_ReaderList.ItemIndex:=I;
      Break;
    End;
  end;
end;

procedure TMainForm.OnError(Sender: TObject;ErrSource:TErrSource;ErrCode:Cardinal);
var Error:String;
begin
  case ErrSource of
    esInit: Error := 'خطا در مقداردهی: ';
    esConnect: Error := 'خطا در ارتباط: ';
    esGetStatus: Error := 'خطا در دریافت: ';
    esTransmit: Error := 'خطا در انتقال: ';
  end;
  AddLog(Error+'کد خطای '+InttoStr(ErrCode));
end;

procedure TMainForm.OnProgress(Sender: TObject;Str1:String;Code1:Integer);
begin
  AddLog('OnProgress');
end;

procedure TMainForm.InitReader;
Var   Lists:TStringList;
begin
  Reader := TACSModule.Create;
  Reader.Debugging:= False;
  Reader.OnCardInserted := OnCardInserted;
  Reader.OnCardRemoved := OnCardRemoved;
  Reader.OnLogMessage := OnLogMessage;
  Reader.OnCardActive := OnCardActive;
//  Reader.OnCardInvalid := OnCardInvalid;
  Reader.OnReaderWaiting := OnReaderWaiting;
  Reader.OnReaderListChange := OnReaderListChange;
//  Reader.OnProgress := OnProgress;
  Reader.OnError := OnError;
  Reader.Init;
end;

procedure TMainForm.ConnectToReader;
begin
  if not Reader.Inited then Exit;
  if CB_ReaderList.ItemIndex < 0 then Exit;
  Reader.UseReaderNum := CB_ReaderList.ItemIndex + 1;
  if not Reader.Opened then Reader.Open;
end;

function TMainForm.GetUID:AnsiString;
begin
  if Reader.Connected then
    Result := StringtoHexMerge(Reader.SendPduToCard(#$FF#$CA#$00#$00#$00))
  else
    Result := '';
end;

function TMainForm.SetAttributeToReaderViolation(Sector,Key:Integer):AnsiString;
begin
  if Reader.Connected then
  begin
    if Reader.AttrViolationOnly then
      Result := Reader.SendPduToCard(#$FF#$82#$00#$00#$06+IAUSAttr[Sector,Key])
    else
      Result := Reader.SendPduToCard(#$FF#$82#$00#$20#$06+IAUSAttr[Sector,Key])
  end
  else
    Result := '';
end;

function TMainForm.SetAttributeToReaderNonViolation(Sector,Key,KeyStore:Integer):AnsiString;
begin
  if Reader.Connected then
      Result := Reader.SendPduToCard(#$FF#$82#$20+Char(KeyStore)+#$06+IAUSAttr[Sector,Key])
  else
    Result := '';
end;

function TMainForm.AuthenticationMifare(Block,Key:Integer;KeyLocation:Integer = 32):AnsiString;
var DoRetry:Boolean;
Label Retry;
begin
  DoRetry := False;
Retry:
  if Reader.Connected then
  begin
      if Reader.AttrViolationOnly then  KeyLocation := 0;
      if (Key = 1) then
        Result := Reader.SendPduToCard(#$FF#$88#$00+Chr(Block)+#$60+Chr(KeyLocation))
      else
        Result := Reader.SendPduToCard(#$FF#$88#$00+Chr(Block)+#$61+Chr(KeyLocation))
  end
  else
    Result := '';

  if (not DoRetry) And (Result <> OperationComplete) And (Block <= 3) then
  begin
    SetAttributeToReaderViolation(17,1);
    DoRetry := True;
    Goto Retry;
  end;
end;

function TMainForm.ReadBinaryBlock(Block:Integer):AnsiString;
begin
  if Reader.Connected then
  begin
    Result := Reader.SendPduToCard(#$FF#$B0#$00+Chr(Block)+#$10)
  end
  else
    Result := '';
end;

function TMainForm.WriteBinaryBlock(Block:Integer;Data:AnsiString):AnsiString;
begin
  if Reader.Connected then
  begin
    Result := Reader.SendPduToCard(#$FF#$D6#$00+Chr(Block)+#$10+Data)
  end
  else
    Result := '';
end;


procedure TMainForm.BT_FormatDefaultCardClick(Sender: TObject);
var
  I,J: Integer;
begin
  for I := 1 to 16 do
  begin
    if SetAttributeToReaderViolation(16,1) = OperationComplete Then
      if AuthenticationMifare((I*4)-1,1) = OperationComplete Then
      begin
        for J := 4 downto 2 do
        begin
          AuthenticationMifare((I*4)-1,1);
          if WriteBinaryBlock((I*4)-J,DefaultData) = OperationComplete Then
            AddLog('فرمت سکتور شماره '+IntToStr(I-1)+' بلاک '+IntToStr(4-J)+' انجام شد')
          else
            AddLog('فرمت سکتور شماره '+IntToStr(I-1)+' بلاک '+IntToStr(4-J)+' با خطا مواجه شد');
        end;
        //Format Security Block
        J := 1;
        if WriteBinaryBlock((I*4)-J,IAUSAttr[I-1,1]+DefaultSecret+IAUSAttr[I-1,2]) = OperationComplete Then
          AddLog('فرمت سکتور شماره '+IntToStr(I-1)+' بلاک '+IntToStr(4-J)+' انجام شد')
        else
          AddLog('فرمت سکتور شماره '+IntToStr(I-1)+' بلاک '+IntToStr(4-J)+' با خطا مواجه شد');
      end
      else
      begin
        AddLog('کارت مورد نظر خام نمی باشد');
        break;
      end;
    PB_Sector.Position := I;
  end;
  AddLog('عملیات مورد نظر به پایان رسید');
  PB_Sector.Position := 1;
end;

procedure TMainForm.BT_FormatIAUSCardClick(Sender: TObject);
var
  I,J: Integer;
begin
  for I := 1 to 16 do
  begin
    if SetAttributeToReaderViolation(I-1,1) = OperationComplete Then
      if AuthenticationMifare((I*4)-1,1) = OperationComplete Then
      begin
        for J := 4 downto 2 do
        begin
          AuthenticationMifare((I*4)-1,1);
          if WriteBinaryBlock((I*4)-J,DefaultData) = OperationComplete Then
            AddLog('فرمت سکتور شماره '+IntToStr(I-1)+' بلاک '+IntToStr(4-J)+' انجام شد')
          else
            AddLog('فرمت سکتور شماره '+IntToStr(I-1)+' بلاک '+IntToStr(4-J)+' با خطا مواجه شد');
        end;
        //Format Security Block
        J := 1;
        if WriteBinaryBlock((I*4)-J,IAUSAttr[I-1,1]+DefaultSecret+IAUSAttr[I-1,2]) = OperationComplete Then
          AddLog('فرمت سکتور شماره '+IntToStr(I-1)+' بلاک '+IntToStr(4-J)+' انجام شد')
        else
          AddLog('فرمت سکتور شماره '+IntToStr(I-1)+' بلاک '+IntToStr(4-J)+' با خطا مواجه شد');
      end
      else
      begin
        AddLog('امکان ارتباط با کارت وجود ندارد (ممکن است کارت خام باشد)');
        break;
      end;
    PB_Sector.Position := I;
  end;
  AddLog('عملیات مورد نظر به پایان رسید');
  PB_Sector.Position := 1;
end;

procedure TMainForm.BT_FormatIAUSCardToDefaultClick(Sender: TObject);
var
  I,J: Integer;
begin
  for I := 1 to 16 do
  begin
    if SetAttributeToReaderViolation(I-1,1) = OperationComplete Then
      if AuthenticationMifare((I*4)-1,1) = OperationComplete Then
      begin
        for J := 4 downto 2 do
        begin
          AuthenticationMifare((I*4)-1,1);
          if WriteBinaryBlock((I*4)-J,DefaultData) = OperationComplete Then
            AddLog('فرمت سکتور شماره '+IntToStr(I-1)+' بلاک '+IntToStr(4-J)+' انجام شد')
          else
            AddLog('فرمت سکتور شماره '+IntToStr(I-1)+' بلاک '+IntToStr(4-J)+' با خطا مواجه شد');
        end;
        //Format Security Block
        J := 1;
        if WriteBinaryBlock((I*4)-J,IAUSAttr[16,1]+DefaultSecret+IAUSAttr[16,2]) = OperationComplete Then
          AddLog('فرمت سکتور شماره '+IntToStr(I-1)+' بلاک '+IntToStr(4-J)+' انجام شد')
        else
          AddLog('فرمت سکتور شماره '+IntToStr(I-1)+' بلاک '+IntToStr(4-J)+' با خطا مواجه شد');
      end
      else
      begin
        AddLog('امکان ارتباط با کارت وجود ندارد (ممکن است کارت خام باشد)');
        break;
      end;
    PB_Sector.Position := I;
  end;
  AddLog('عملیات مورد نظر به پایان رسید');
  PB_Sector.Position := 1;
end;

procedure TMainForm.BT_GetCardUIDClick(Sender: TObject);
begin
  AddLog('کد کارت: '+GetUID);
end;

procedure TMainForm.BT_InitReaderClick(Sender: TObject);
begin
  InitReader;
end;

procedure TMainForm.BT_OpenReaderClick(Sender: TObject);
begin
  ConnectToReader;
end;

procedure TMainForm.BT_ReadCustomClick(Sender: TObject);
var
  I,J: Integer;
  BlockData:AnsiString;
begin
  if SP_Block.Value = 3 then
  begin
    AddLog('امکان خواندن بلاک‌های امنیتی وجود ندارد');
    exit;
  end;

  I := SP_Sector.Value+1;
  J := 4 - SP_Block.Value;
  if SetAttributeToReaderViolation(I-1,1) = OperationComplete Then
    if AuthenticationMifare((I*4)-1,1) = OperationComplete Then
    begin
      BlockData := ReadBinaryBlock((I*4)-J);
      ED_CustomData.Text := BlockData;
      AddLog('اطلاعات سکتور شماره '+IntToStr(I-1)+' بلاک '+IntToStr(SP_Block.Value)+': '+StringtoHexMerge(BlockData));
    end
    else
    begin
      AddLog('امکان ارتباط با کارت وجود ندارد (ممکن است کارت خام باشد)');
    end;
  AddLog('عملیات مورد نظر به پایان رسید');
end;

procedure TMainForm.BT_ReadDefaultCardClick(Sender: TObject);
var
  I,J: Integer;
  BlockData:AnsiString;
begin
  for I := 1 to 16 do
  begin
    if SetAttributeToReaderViolation(16,1) = OperationComplete Then
      if AuthenticationMifare((I*4)-1,1) = OperationComplete Then
      begin
        for J := 4 downto 1 do
        begin
          AuthenticationMifare((I*4)-1,1);
          BlockData := ReadBinaryBlock((I*4)-J);
          AddLog('اطلاعات سکتور شماره '+IntToStr(I-1)+' بلاک '+IntToStr(4-J)+': '+StringtoHexMerge(BlockData))
        end;
      end
      else
      begin
        AddLog('کارت مورد نظر خام نمی باشد');
        break;
      end;
    PB_Sector.Position := I;
  end;
  AddLog('عملیات مورد نظر به پایان رسید');
  PB_Sector.Position := 1;
end;

procedure TMainForm.BT_ReadIAUSCardClick(Sender: TObject);
var
  I,J: Integer;
begin
  for I := 1 to 16 do
  begin
    if SetAttributeToReaderViolation(I-1,1) = OperationComplete Then
      if AuthenticationMifare((I*4)-1,1) = OperationComplete Then
      begin
        for J := 4 downto 1 do
        begin
          AuthenticationMifare((I*4)-1,1);
          AddLog('اطلاعات سکتور شماره '+IntToStr(I-1)+' بلاک '+IntToStr(4-J)+': '+StringtoHexMerge(ReadBinaryBlock((I*4)-J)));
        end;
      end
      else
      begin
        AddLog('امکان ارتباط با کارت وجود ندارد (ممکن است کارت خام باشد)');
        break;
      end;
    PB_Sector.Position := I;
  end;
  AddLog('عملیات مورد نظر به پایان رسید');
  PB_Sector.Position := 1;
end;

procedure TMainForm.BT_ReadTransCardClick(Sender: TObject);
var
  I,J: Integer;
  BlockData:AnsiString;
begin
  for I := 1 to 16 do
  begin
    if SetAttributeToReaderViolation(17,1) = OperationComplete Then
      if AuthenticationMifare((I*4)-1,1) = OperationComplete Then
      begin
        for J := 4 downto 1 do
        begin
          AuthenticationMifare((I*4)-1,1);
          BlockData := ReadBinaryBlock((I*4)-J);
          AddLog('اطلاعات سکتور شماره '+IntToStr(I-1)+' بلاک '+IntToStr(4-J)+': '+StringtoHexMerge(BlockData))
        end;
      end
      else
      begin
        AddLog('کارت مورد نظر تردد نمی باشد');
        break;
      end;
    PB_Sector.Position := I;
  end;
  AddLog('عملیات مورد نظر به پایان رسید');
  PB_Sector.Position := 1;
end;


procedure TMainForm.CB_DebugClick(Sender: TObject);
begin
  Reader.Debugging := CB_Debug.Checked;
end;

function  TMainForm.Complete16Byte(Data:AnsiString):AnsiString;
Var I:Integer;
begin
   Data := Data + StringOfChar(#0,16-Length(Data));
   Result := Data;
end;

procedure TMainForm.BT_WriteClick(Sender: TObject);
var
  I,J: Integer;
  BlockData:AnsiString;
begin
  if SP_Block.Value = 3 then
  begin
    AddLog('امکان نوشتن در بلاک‌های امنیتی وجود ندارد');
    exit;
  end;

  I := SP_Sector.Value+1;
  J := 4 - SP_Block.Value;
  if SetAttributeToReaderViolation(I-1,1) = OperationComplete Then
    if AuthenticationMifare((I*4)-1,1) = OperationComplete Then
    begin
      BlockData := Complete16Byte(ED_CustomData.Text);
      WriteBinaryBlock((I*4)-J,BlockData);
      AddLog('اطلاعات سکتور شماره '+IntToStr(I-1)+' بلاک '+IntToStr(SP_Block.Value)+': '+StringtoHexMerge(BlockData));
    end
    else
    begin
      AddLog('امکان ارتباط با کارت وجود ندارد (ممکن است کارت خام باشد)');
    end;
  AddLog('عملیات مورد نظر به پایان رسید');
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Reader.Connected then Reader.Disconnect;
  if Reader.Opened then Reader.Close;
  Reader.Destroy;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  InitReader;
end;

{
  //Get UID
  //AddLog(StringtoHex(Reader.SendPduToCard(#$1FF#$CA#$00#$00#$00)));

  //Set Reader Attribute To Violation Memory Location
  //AddLog(StringtoHex(Reader.SendPduToCard(#$FF#$82#$00#$20#$06#$FF#$FF#$FF#$FF#$FF#$FF)));

  //Set Reader Attribute To Non Violation Memory Location
  //00H-1FH Current #$05
  //AddLog(StringtoHex(Reader.SendPduToCard(#$FF#$82#$20#$05#$06#$FF#$FF#$FF#$FF#$FF#$FF)));


  //Authentication For Mifare 1k/4K
  //$01 Block
  //A=#$60 B=#$61
  ///#$20 = Session ---- Other 00H-1FH Current #$05
  //AddLog(StringtoHex(Reader.SendPduToCard(#$FF#$88#$00#$01#$60#$20)));

  //Read Binary Block From Block 01 - 16 Byte
  //AddLog(StringtoHex(Reader.SendPduToCard(#$FF#$B0#$00#$01#$10)));

  //Write Binary Block To Block 01 - 16 Byte
  //AddLog(StringtoHex(Reader.SendPduToCard(#$FF#$D6#$00#$01#$10+'ABCDABCDABCDABCD')));
}
end.
