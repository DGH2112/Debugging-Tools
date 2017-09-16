(**

  This module contains the main IDE wizard which manages the life time of all objects.

  @Author  David Hoyle
  @Version 1.0
  @Date    16 Sep 2017

**)
Unit DebugWithCodeSite.Wizard;

Interface

{$INCLUDE CompilerDefinitions.Inc}

Uses
  Classes,
  ToolsAPI,
  Menus,
  ActnList,
  ExtCtrls,
  ImgList,
  DebugWithCodeSite.Types,
  DebugWithCodeSite.Interfaces;

Type
  (** A class which implements the OIOTAWizard interface to provide the plug-ins main IDE wizard. **)
  TDWCSWizard = Class(TInterfacedObject, IOTANotifier, IOTAWizard, IDWCSOptionsReadWriter)
  Strict Private
    FMenuTimer     : TTimer;
    FMenuInstalled : Boolean;
    FChecks        : TDWCSChecks;
    FCodeSiteMsg   : String;
  Strict Protected
    // IOTAWizard
    Procedure Execute;
    Function  GetIDString: String;
    Function  GetName: String;
    Function  GetState: TWizardState;
    // IOTANotifier
    Procedure AfterSave;
    Procedure BeforeSave;
    Procedure Destroyed;
    Procedure Modified;
    // IDWCSOptionsReadWriter
    Procedure ReadOptions(Var Options: TDWCSChecks; Var strCodeSiteMsg : String);
    Procedure WriteOptions(Const Options: TDWCSChecks; Const strCodeSiteMsg : String);
    // General Methods
    Function  AddImageToList(Const ImageList : TCustomImageList) : Integer;
    Procedure AddMenuToEditorContextMenu;
    Procedure MenuInstallerTimer(Sender : TObject);
    Procedure DebugWithCodeSiteClick(Sender : TObject);
    Procedure LoadSettings;
    Procedure SaveSettings;
  Public
    Constructor Create;
    Destructor Destroy; Override;
  End;

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils,
  Windows,
  Controls,
  Graphics,
  Forms,
  ActnPopup,
  DebugWithCodeSite.Functions,
  Dialogs,
  Registry,
  DebugWithCodeSite.AboutBox,
  DebugWithCodeSite.SplashScreen,
  DebugWithCodeSite.OptionsIDEInterface;

Const
  (** The registry key under which the settings are stored. **)
  strRegKey = 'Software\Season''s Fall\Debug with CodeSite\';

{ TDWCSWizard }

(**

  This method adds an image to the given image list so that there is an image for the context menu in the
  IDEs editor.

  @precon  ImageList must be a valid instance.
  @postcon The image is loaded from the resource and added to the given image list.

  @param   ImageList as a TCustomImageList as a constant
  @return  an Integer

**)
Function TDWCSWizard.AddImageToList(Const ImageList : TCustomImageList): Integer;

Const
  strImageName = 'DWCSMenuBitMap16x16';

Var
  BM       : TBitMap;

Begin
  Result := -1;
  If FindResource(hInstance, strImageName, RT_BITMAP) > 0 Then
    Begin
      BM := TBitMap.Create;
      Try
        BM.LoadFromResourceName(hInstance, strImageName);
        Result := ImageList.AddMasked(BM, clLime);
      Finally
        BM.Free;
      End;
    End;
End;

(**

  This method adds the Debug with CodeSite context menu to the editors menu.

  @precon  None.
  @postcon The contect menu is added and disables the timer if the editor context menu it found.

**)
Procedure TDWCSWizard.AddMenuToEditorContextMenu;

  (**

    This method searches the screens objects forms for the form with the given class name.

    @precon  None.
    @postcon The form reference is returned IF found else nil.

    @return  a TForm

  **)
  Function FindEditWindow : TForm;

  Var
    iForm: Integer;

  Begin
    Result := Nil;
    For iForm := 0 To Screen.FormCount - 1 Do
      If CompareText(Screen.Forms[iForm].ClassName, 'TEditWindow') = 0 Then
        Begin
          Result := Screen.Forms[iForm];
          Break;
        End;
  End;

  (**

    This method returns the component of the given component with the given name and class type.

    @precon  OwnerConponent must be a valid instance.
    @postcon Returns the component of the owner with the name and class type provided if found else
             returns nil.

    @param   OwnerComponent as a TComponent as a constant
    @param   strName        as a String as a constant
    @param   ClsType        as a TClass as a constant
    @return  a TComponent

  **)
  Function FindComponent(Const OwnerComponent : TComponent; Const strName : String;
    Const ClsType : TClass) : TComponent;

  Var
    iComponent: Integer;

  Begin
    Result := Nil;
    For iComponent := 0 To OwnerComponent.ComponentCount - 1 Do
      If CompareText(OwnerComponent.Components[iComponent].Name, strName) = 0 Then
        If OwnerComponent.Components[iComponent] Is ClsType Then
          Begin
            Result := OwnerComponent.Components[iComponent];
            Break;
          End;
  End;

Var
  F: TForm;
  CM: TPopupActionBar;
  iImageIndex: Integer;
  MenuItem: TMenuItem;

Begin
  F := FindEditWindow;
  If Assigned(F) Then
    Begin
      CM := FindComponent(F, 'EditorLocalMenu', TPopupActionBar) As TPopupActionBar;
      If Assigned(CM) Then
        Begin
          iImageIndex := AddImageToList(CM.Images);
          MenuItem := TMenuItem.Create(CM);
          MenuItem.Name := 'miDWCSDebugWithCodeSite';
          MenuItem.Caption := 'Debug &with CodeSite';
          MenuItem.OnClick := DebugWithCodeSiteClick;
          MenuItem.ImageIndex := iImageIndex;
          CM.Items.Add(MenuItem);
        End;
      FMenuTimer.Enabled := False;
    End;
End;

(**

  This method does nothing in the context of an IOTAWizard.

  @precon  None.
  @postcon None.

**)
Procedure TDWCSWizard.AfterSave;

Begin
  // Do nothing in the context of an IOTAWizard
End;

(**

  This method does nothing in the context of an IOTAWizard.

  @precon  None.
  @postcon None.

**)
Procedure TDWCSWizard.BeforeSave;

Begin
  // Do nothing
End;

(**

  A constructor for the TDWVSWizard class.

  @precon  None.
  @postcon Adds a splash screena dn about box and start the timer for installing the context menu.

**)
Constructor TDWCSWizard.Create;

Var
  OptionsReadWriter : IDWCSOptionsReadWriter;

Begin
  Inherited Create;
  AddSplashScreen;
  AddAboutBoxEntry;
  If Supports(Self, IDWCSOptionsReadWriter, OptionsReadWriter) Then
    TDWCSIDEOptionsHandler.AddOptionsFrameHandler(OptionsReadWriter);
  FMenuInstalled := False;
  FMenuTimer := TTimer.Create(Nil);
  FMenuTimer.Interval := 1000;
  FMenuTimer.OnTimer := MenuInstallerTimer;
  FMenuTimer.Enabled := True;
  FChecks := [dwcscCodeSiteLogging..dwcscBreak];
  FCodeSiteMsg := 'CodeSite.Send(''%s'', %s)';
  LoadSettings;
End;

(**

  This is the on click event handler for the editor Debug With CodeSite contetx menu.

  @precon  None.
  @postcon Adds a breakpoint on the line of the cursor with CodeSite information in the EvalExpression
                  property for the identifier at the cursor.

  @param   Sender as a TObject

**)
Procedure TDWCSWizard.DebugWithCodeSiteClick(Sender: TObject);

Var
  ES : IOTAEditorServices;
  DS : IOTADebuggerServices;
  CP: TOTAEditPos;
  BP: IOTABreakpoint;
  strIdentifierAtCursor: String;
  strMsg : String;
  iPos: Integer;

Begin
  If Supports(BorlandIDEServices, IOTAEditorServices, ES) Then
    If Supports(BorlandIDEServices, IOTADebuggerServices, DS) Then
      Begin
        CP := ES.TopView.CursorPos;
        strIdentifierAtCursor := GetIdentifierAtCursor(CP);
        If strIdentifierAtCursor <> '' Then
          Begin
            BP := DS.NewSourceBreakpoint(ES.TopBuffer.FileName, CP.Line, Nil);
            strMsg := FCodeSiteMsg;
            iPos := Pos('%s', strMsg);
            While iPos > 0 Do
              Begin
                strMsg := Copy(strMsg, 1, Pred(iPos)) + strIdentifierAtCursor +
                  Copy(strMsg, iPos + 2, Length(strMsg) - iPos - 1);
                iPos := Pos('%s', strMsg);
              End;
            BP.EvalExpression := strMsg;
            BP.LogResult := dwcscLogResult In FChecks;
            BP.DoBreak := dwcscBreak In FChecks;
            If dwcscCodeSiteLogging In FChecks Then
              CheckCodeSiteLogging;
            If dwcscDebuggingDCUs In FChecks Then
              CheckDebuggingDCUs;
            If dwcscLibraryPath In FChecks Then
              CheckLibraryPath;
            If dwcscEditBreakpoint In FChecks Then
              BP.Edit(True);
          End Else
            MessageDlg('There is no identifier at the cursor position!', mtWarning, [mbOK], 0);
      End;
End;

(**

  A destructor for the TDWCSWizard class.

  @precon  None.
  @postcon Removes the about box and frees the contet menu timer.

**)
Destructor TDWCSWizard.Destroy;

Begin
  SaveSettings;
  TDWCSIDEOptionsHandler.RemoveOptionsFrameHandler;
  RemoveAboutBoxEntry;
  FMenuTimer.Free;
  Inherited Destroy;
End;

(**

  This method does nothing in the context of an IOTAWizard.

  @precon  None.
  @postcon None.

**)
Procedure TDWCSWizard.Destroyed;

Begin
  // Do nothing
End;

(**

  This method does nothing in the context of an IOTAWizard.

  @precon  None.
  @postcon None.

**)
Procedure TDWCSWizard.Execute;

Begin
  // Do nothing
End;

(**

  This is a getter method for the IDString property.

  @precon  None.
  @postcon Returns the ID String for the wizard.

  @return  a String

**)
Function TDWCSWizard.GetIDString: String;

Begin
  Result := 'Season''s Fall Music.David Hoyle.Debug with CodeSite';
End;

(**

  This is a getter method for the Name property.

  @precon  None.
  @postcon Returns the name of the wizard.

  @return  a String

**)
Function TDWCSWizard.GetName: String;

Begin
  Result := 'Debug with CodeSite';
End;

(**

  This is a getter method for the WizardState property.

  @precon  None.
  @postcon Returns the state that the wizard is enabled.

  @return  a TWizardState

**)
Function TDWCSWizard.GetState: TWizardState;

Begin
  Result := [wsEnabled];
End;

(**

  This method loads the plug-ins settings from the regsitry.

  @precon  None.
  @postcon  The plug-ins settings are loaded.

**)
Procedure TDWCSWizard.LoadSettings;

Var
  R : TRegIniFile;

Begin
  R := TRegIniFile.Create(strRegKey);
  Try
    FCodeSiteMsg := R.ReadString('Setup', 'CodeSiteMsg', FCodeSiteMsg);
    FChecks := TDWCSChecks(Byte(R.ReadInteger('Setup', 'Options', Byte(FChecks))));
  Finally
    R.Free;
  End;
End;

(**

  This is an on timer event handler.

  @precon  None.
  @postcon Tries to install the editoer context menu.

  @param   Sender as a TObject

**)
Procedure TDWCSWizard.MenuInstallerTimer(Sender: TObject);

Begin
  AddMenuToEditorContextMenu;
End;

(**

  This method does nothing in the context of an IOTAWizard.

  @precon  None.
  @postcon None.

**)
Procedure TDWCSWizard.Modified;

Begin
  // Do nothing
End;

(**

  This method returns the current state of the check options.

  @precon  None.
  @postcon The check options are returned to the calling code.

  @param   Options        as a TDWCSChecks as a reference
  @param   strCodeSiteMsg as a String as a reference

**)
Procedure TDWCSWizard.ReadOptions(Var Options: TDWCSChecks; Var strCodeSiteMsg : String);

Begin
  Options := FChecks;
  strCodeSiteMsg := FCodeSiteMsg;
End;

(**

  This method saves the settings to the registry.

  @precon  None.
  @postcon The settings are saved.

**)
Procedure TDWCSWizard.SaveSettings;

Var
  R: TRegIniFile;

Begin
  R := TRegIniFile.Create(strRegKey);
  Try
    R.WriteString('Setup', 'CodeSiteMsg', FCodeSiteMsg);
    R.WriteInteger('Setup', 'Options', Byte(FChecks));
  Finally
    R.Free;
  End;
End;

(**

  This method updates the check options with the given options.

  @precon  None.
  @postcon The check options are updated.

  @param   Options        as a TDWCSChecks as a constant
  @param   strCodeSiteMsg as a String as a constant

**)
Procedure TDWCSWizard.WriteOptions(Const Options: TDWCSChecks; Const strCodeSiteMsg : String);

Begin
  FChecks := Options;
  FCodeSiteMsg := strCodeSiteMsg;
  SaveSettings;
End;

End.
