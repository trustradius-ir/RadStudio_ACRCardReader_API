object MainForm: TMainForm
  Left = 0
  Top = 0
  BiDiMode = bdRightToLeft
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = #1705#1575#1585#1578' '#1582#1608#1575#1606
  ClientHeight = 351
  ClientWidth = 503
  Color = clBtnFace
  Constraints.MinHeight = 32
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  ParentBiDiMode = False
  Position = poDesktopCenter
  Scaled = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 503
    Height = 49
    Align = alTop
    Caption = ' '#1575#1585#1578#1576#1575#1591' '#1576#1575' '#1705#1575#1585#1578#8204#1582#1608#1575#1606': '
    TabOrder = 0
    object Label1: TLabel
      Left = 396
      Top = 20
      Width = 98
      Height = 13
      Caption = #1601#1607#1585#1587#1578' '#1705#1575#1585#1578#8204#1582#1608#1575#1606#8204#1607#1575':'
    end
    object CB_ReaderList: TComboBox
      Left = 175
      Top = 17
      Width = 215
      Height = 21
      Style = csDropDownList
      BiDiMode = bdLeftToRight
      ParentBiDiMode = False
      TabOrder = 0
    end
    object BT_OpenReader: TButton
      Left = 8
      Top = 18
      Width = 75
      Height = 25
      Caption = #1575#1578#1589#1575#1604
      TabOrder = 1
      OnClick = BT_OpenReaderClick
    end
    object BT_InitReader: TButton
      Left = 89
      Top = 18
      Width = 75
      Height = 25
      Caption = #1576#1585#1585#1587#1740' '#1605#1580#1583#1583
      TabOrder = 2
      OnClick = BT_InitReaderClick
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 178
    Width = 503
    Height = 157
    Align = alBottom
    Caption = ' '#1585#1608#1740#1583#1575#1583#1607#1575' '
    TabOrder = 1
    object LB_Logs: TListBox
      Left = 2
      Top = 15
      Width = 499
      Height = 140
      Align = alClient
      BiDiMode = bdRightToLeft
      ItemHeight = 13
      ParentBiDiMode = False
      TabOrder = 0
    end
  end
  object GroupBox3: TGroupBox
    Left = 0
    Top = 49
    Width = 503
    Height = 128
    Align = alTop
    Caption = ' '#1593#1605#1604#1740#1575#1578#8204#1607#1575': '
    TabOrder = 2
    object BT_FormatDefaultCard: TButton
      Left = 297
      Top = 16
      Width = 93
      Height = 25
      Caption = #1601#1585#1605#1578' '#1705#1575#1585#1578' '#1582#1575#1605
      TabOrder = 0
      OnClick = BT_FormatDefaultCardClick
    end
    object BT_ReadDefaultCard: TButton
      Left = 400
      Top = 16
      Width = 94
      Height = 25
      Caption = #1582#1608#1575#1606#1583#1606' '#1705#1575#1585#1578' '#1582#1575#1605
      TabOrder = 1
      OnClick = BT_ReadDefaultCardClick
    end
    object BT_ReadIAUSCard: TButton
      Left = 400
      Top = 47
      Width = 94
      Height = 25
      Caption = #1582#1608#1575#1606#1583#1606' '#1705#1575#1585#1578
      TabOrder = 2
      OnClick = BT_ReadIAUSCardClick
    end
    object BT_FormatIAUSCard: TButton
      Left = 297
      Top = 47
      Width = 94
      Height = 25
      Caption = #1601#1585#1605#1578' '#1705#1575#1585#1578' '#1576#1607' '#1582#1575#1604#1740
      TabOrder = 3
      OnClick = BT_FormatIAUSCardClick
    end
    object BT_FormatIAUSCardToDefault: TButton
      Left = 193
      Top = 47
      Width = 94
      Height = 25
      Caption = #1601#1585#1605#1578' '#1705#1575#1585#1578' '#1576#1607' '#1582#1575#1605
      TabOrder = 4
      OnClick = BT_FormatIAUSCardToDefaultClick
    end
    object BT_GetCardUID: TButton
      Left = 193
      Top = 16
      Width = 94
      Height = 25
      Caption = #1705#1583' '#1705#1575#1585#1578
      TabOrder = 5
      OnClick = BT_GetCardUIDClick
    end
    object GroupBox4: TGroupBox
      Left = 2
      Top = 15
      Width = 175
      Height = 111
      Align = alLeft
      Caption = ' '#1593#1605#1604#1740#1575#1578' '#1582#1575#1589': '
      TabOrder = 6
      object Label2: TLabel
        Left = 131
        Top = 19
        Width = 34
        Height = 13
        Caption = #1587#1705#1578#1608#1585':'
      end
      object Label3: TLabel
        Left = 51
        Top = 19
        Width = 25
        Height = 13
        Caption = #1576#1604#1575#1705':'
      end
      object SP_Sector: TSpinEdit
        Left = 85
        Top = 17
        Width = 40
        Height = 22
        MaxValue = 15
        MinValue = 0
        TabOrder = 0
        Value = 0
      end
      object SP_Block: TSpinEdit
        Left = 5
        Top = 17
        Width = 40
        Height = 22
        MaxValue = 3
        MinValue = 0
        TabOrder = 1
        Value = 0
      end
      object BT_Write: TButton
        Left = 8
        Top = 45
        Width = 75
        Height = 25
        Caption = #1606#1608#1588#1578#1606
        TabOrder = 2
        OnClick = BT_WriteClick
      end
      object BT_ReadCustom: TButton
        Left = 91
        Top = 45
        Width = 75
        Height = 25
        Caption = #1582#1608#1575#1606#1583#1606
        TabOrder = 3
        OnClick = BT_ReadCustomClick
      end
      object ED_CustomData: TEdit
        Left = 7
        Top = 77
        Width = 158
        Height = 21
        MaxLength = 16
        TabOrder = 4
      end
    end
    object CB_Debug: TCheckBox
      Left = 397
      Top = 102
      Width = 97
      Height = 17
      Caption = #1575#1588#1705#1575#1604' '#1586#1583#1575#1740#1740
      TabOrder = 7
      OnClick = CB_DebugClick
    end
    object BT_ReadTransCard: TButton
      Left = 400
      Top = 78
      Width = 94
      Height = 25
      Caption = #1582#1608#1575#1606#1583#1606' '#1705#1575#1585#1578' '#1578#1585#1583#1583
      TabOrder = 8
      OnClick = BT_ReadTransCardClick
    end
  end
  object PB_Sector: TProgressBar
    Left = 0
    Top = 335
    Width = 503
    Height = 16
    Align = alBottom
    Min = 1
    Max = 16
    Position = 1
    TabOrder = 3
  end
end
