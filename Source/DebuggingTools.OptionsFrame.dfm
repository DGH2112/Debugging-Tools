object frameDDTOptions: TframeDDTOptions
  Left = 0
  Top = 0
  Width = 490
  Height = 327
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object lblCodeSiteMsg: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 484
    Height = 13
    Align = alTop
    AutoSize = False
    Caption = 'Code Site Message (include at least 1 %s)'
    ExplicitWidth = 237
  end
  object lblCodeSiteOptions: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 52
    Width = 484
    Height = 16
    Align = alTop
    Caption = 'Debug with CodeSite Options'
    ExplicitWidth = 166
  end
  object lvOptions: TListView
    AlignWithMargins = True
    Left = 3
    Top = 74
    Width = 484
    Height = 250
    Align = alClient
    Checkboxes = True
    Columns = <
      item
        AutoSize = True
        Caption = 'Options'
      end>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnChange = lvOptionsChange
  end
  object edtCodeSiteMsg: TEdit
    AlignWithMargins = True
    Left = 3
    Top = 22
    Width = 484
    Height = 24
    Align = alTop
    TabOrder = 1
  end
end
