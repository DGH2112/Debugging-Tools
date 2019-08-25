(**

  This module contains the main IDE wizard which manages the life time of all objects.

  @Author  David Hoyle
  @Version 1.3
  @Date    25 Aug 2019

**)
Unit DebuggingTools.Wizard;

Interface

{$INCLUDE CompilerDefinitions.Inc}

Uses
  Classes,
  ToolsAPI,
  Menus,
  ActnList,
  ExtCtrls,
  ImgList,
  DebuggingTools.Types,
  DebuggingTools.Interfaces;

Type
  (** A class which implements the OIOTAWizard interface to provide the plug-ins main IDE wizard. **)
  TDDTWizard = Class(TInterfacedObject, IOTANotifier, IOTAWizard)
  Strict Private
    FMenuTimer            : TTimer;
    FMenuInstalled        : Boolean;
    FPluginOptions        : IDDTPluginOptions;
    FKeyboardBindingIndex : Integer;
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
    // General Methods
    Function  AddImageToList(Const ImageList : TCustomImageList) : Integer;
    Procedure AddMenuToEditorContextMenu;
    Procedure MenuInstallerTimer(Sender : TObject);
    Procedure DebugWithCodeSiteClick(Sender : TObject);
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
  DebuggingTools.Functions,
  Dialogs,
  Registry,
  DebuggingTools.AboutBox,
  DebuggingTools.SplashScreen,
  DebuggingTools.OptionsIDEInterface,
  DebuggingTools.PluginOptions,
  DebuggingTools.KeyboardBindings;

{ TDDTWizard }

(**

  This method adds an image to the given image list so that there is an image for the context menu in the
  IDEs editor.

  @precon  ImageList must be a valid instance.
  @postcon The image is loaded from the resource and added to the given image list.

  @param   ImageList as a TCustomImageList as a constant
  @return  an Integer

**)
Function TDDTWizard.AddImageToList(Const ImageList : TCustomImageList): Integer;

Const
  strImageName = 'DDTMenuBitMap16x16';

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
Procedure TDDTWizard.AddMenuToEditorContextMenu;

  (**

    This method searches the screens objects forms for the form with the given class name.

    @precon  None.
    @postcon The form reference is returned IF found else nil.

    @return  a TForm

  **)
  Function FindEditWindow : TForm;

  Const
    strTEditWindowClassName = 'TEditWindow';

  Var
    iForm: Integer;

  Begin
    Result := Nil;
    For iForm := 0 To Screen.FormCount - 1 Do
      If CompareText(Screen.Forms[iForm].ClassName, strTEditWindowClassName) = 0 Then
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

ResourceString
  strDebugWithCodeSiteCaption = 'Debug &with CodeSite';

Const
  strEditorLocalMenuComponentName = 'EditorLocalMenu';
  strMenuName = 'miDDTDebugWithCodeSite';

Var
  F: TForm;
  CM: TPopupActionBar;
  iImageIndex: Integer;
  MenuItem: TMenuItem;

Begin
  F := FindEditWindow;
  If Assigned(F) Then
    Begin
      CM := FindComponent(F, strEditorLocalMenuComponentName, TPopupActionBar) As TPopupActionBar;
      If Assigned(CM) Then
        Begin
          iImageIndex := AddImageToList(CM.Images);
          MenuItem := TMenuItem.Create(CM);
          MenuItem.Name := strMenuName;
          MenuItem.Caption := strDebugWithCodeSiteCaption;
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

  @nocheck EmptyMethod
  
**)
Procedure TDDTWizard.AfterSave;

Begin
  // Do nothing in the context of an IOTAWizard
End;

(**

  This method does nothing in the context of an IOTAWizard.

  @precon  None.
  @postcon None.

  @nocheck EmptyMethod
  
**)
Procedure TDDTWizard.BeforeSave;

Begin
  // Do nothing
End;

(**

  A constructor for the TDWVSWizard class.

  @precon  None.
  @postcon Adds a splash screena dn about box and start the timer for installing the context menu.

**)
Constructor TDDTWizard.Create;

Const
  iTimerInterval = 1000;

Begin
  Inherited Create;
  AddSplashScreen;
  AddAboutBoxEntry;
  FPluginOptions := TDDTPluginOptions.Create;
  TDDTIDEOptionsHandler.AddOptionsFrameHandler(FPluginOptions);
  FKeyboardBindingIndex := TDDTKeyboardBindings.AddKeyboardBindings;
  FMenuInstalled := False;
  FMenuTimer := TTimer.Create(Nil);
  FMenuTimer.Interval := iTimerInterval;
  FMenuTimer.OnTimer := MenuInstallerTimer;
  FMenuTimer.Enabled := True;
End;

(**

  This is the on click event handler for the editor Debug With CodeSite contetx menu.

  @precon  None.
  @postcon Adds a breakpoint on the line of the cursor with CodeSite information in the EvalExpression
                  property for the identifier at the cursor.

  @param   Sender as a TObject

**)
Procedure TDDTWizard.DebugWithCodeSiteClick(Sender: TObject);

ResourceString
  strThereNoIdentifierAtCursorPosition = 'There is no identifier at the cursor position!';

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
        strIdentifierAtCursor := GetIdentifierAtCursor;
        If strIdentifierAtCursor <> '' Then
          Begin
            BP := DS.NewSourceBreakpoint(ES.TopBuffer.FileName, CP.Line, Nil);
            strMsg := FPluginOptions.CodeSiteTemplate;
            iPos := Pos('%s', strMsg);
            While iPos > 0 Do
              Begin
                strMsg := Copy(strMsg, 1, Pred(iPos)) + strIdentifierAtCursor +
                  Copy(strMsg, iPos + 2, Length(strMsg) - iPos - 1);
                iPos := Pos('%s', strMsg);
              End;
            BP.EvalExpression := strMsg;
            BP.LogResult := DDTcLogResult In FPluginOptions.CheckOptions;
            BP.DoBreak := DDTcBreak In FPluginOptions.CheckOptions;
            If DDTcCodeSiteLogging In FPluginOptions.CheckOptions Then
              CheckCodeSiteLogging;
            If DDTcDebuggingDCUs In FPluginOptions.CheckOptions Then
              CheckDebuggingDCUs;
            If DDTcLibraryPath In FPluginOptions.CheckOptions Then
              CheckLibraryPath;
            If DDTcEditBreakpoint In FPluginOptions.CheckOptions Then
              BP.Edit(True);
          End Else
            MessageDlg(strThereNoIdentifierAtCursorPosition, mtWarning, [mbOK], 0);
      End;
End;

(**

  A destructor for the TDDTWizard class.

  @precon  None.
  @postcon Removes the about box and frees the contet menu timer.

**)
Destructor TDDTWizard.Destroy;

Begin
  FPluginOptions.SaveSettings;
  TDDTKeyboardBindings.RemoveKeyboardBindings(FKeyboardBindingIndex);
  TDDTIDEOptionsHandler.RemoveOptionsFrameHandler;
  RemoveAboutBoxEntry;
  FMenuTimer.Free;
  Inherited Destroy;
End;

(**

  This method does nothing in the context of an IOTAWizard.

  @precon  None.
  @postcon None.

  @nocheck EmptyMethod
  
**)
Procedure TDDTWizard.Destroyed;

Begin
  // Do nothing
End;

(**

  This method does nothing in the context of an IOTAWizard.

  @precon  None.
  @postcon None.

  @nocheck EmptyMethod
  
**)
Procedure TDDTWizard.Execute;

Begin
  // Do nothing
End;

(**

  This is a getter method for the IDString property.

  @precon  None.
  @postcon Returns the ID String for the wizard.

  @return  a String

**)
Function TDDTWizard.GetIDString: String;

Const
  strIDString = 'Season''s Fall Music.David Hoyle.DGH Debugging Tools';

Begin
  Result := strIDString;
End;

(**

  This is a getter method for the Name property.

  @precon  None.
  @postcon Returns the name of the wizard.

  @return  a String

**)
Function TDDTWizard.GetName: String;

ResourceString
  strDebugWithCodeSite = 'DGH Debugging Tools';

Begin
  Result := strDebugWithCodeSite;
End;

(**

  This is a getter method for the WizardState property.

  @precon  None.
  @postcon Returns the state that the wizard is enabled.

  @return  a TWizardState

**)
Function TDDTWizard.GetState: TWizardState;

Begin
  Result := [wsEnabled];
End;

(**

  This is an on timer event handler.

  @precon  None.
  @postcon Tries to install the editoer context menu.

  @param   Sender as a TObject

**)
Procedure TDDTWizard.MenuInstallerTimer(Sender: TObject);

Begin
  AddMenuToEditorContextMenu;
End;

(**

  This method does nothing in the context of an IOTAWizard.

  @precon  None.
  @postcon None.

  @nocheck EmptyMethod
  
**)
Procedure TDDTWizard.Modified;

Begin
  // Do nothing
End;

End.


