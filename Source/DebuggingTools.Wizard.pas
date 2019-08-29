(**

  This module contains the main IDE wizard which manages the life time of all objects.

  @Author  David Hoyle
  @Version 1.3
  @Date    29 Aug 2019

  @license
  
    DGH Debugging Tools is a RAD Studio plug-in to provide additional functionality
    in the RAD Studio IDE when debugging.
    
    Copyright (C) 2019  David Hoyle (https://github.com/DGH2112/Debugging-Tools/)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License

**)
Unit DebuggingTools.Wizard;

Interface

{$INCLUDE CompilerDefinitions.Inc}

Uses
  ToolsAPI,
  System.Classes,
  VCL.Forms,
  VCL.Menus,
  VCL.ExtCtrls,
  VCL.ImgList,
  VCL.ActnPopup,
  DebuggingTools.Types,
  DebuggingTools.Interfaces;

Type
  (** A class which implements the OIOTAWizard interface to provide the plug-ins main IDE wizard. **)
  TDDTWizard = Class(TNotifierObject, IOTANotifier, IOTAWizard)
  Strict Private
    FMenuTimer            : TTimer;
    FMenuInstalled        : Boolean;
    FPluginOptions        : IDDTPluginOptions;
    FKeyboardBindingIndex : Integer;
    FImageIndex           : Integer;
    FEditorPopupMethod    : TMethod;
    FDebuggingToolsMenu   : TMenuItem;
  Strict Protected
    // IOTAWizard
    Procedure Execute;
    Function  GetIDString: String;
    Function  GetName: String;
    Function  GetState: TWizardState;
    // General Methods
    Function  AddImageToList(Const ImageList : TCustomImageList) : Integer;
    Procedure MenuInstallerTimer(Sender : TObject);
    Procedure HookEditorPopupMenu;
    Procedure UnhookEditorPopupMenu;
    Procedure DebuggingToolsPopupEvent(Sender : TObject);
    Procedure AddBreakpoint(Sender : TObject);
    Procedure DebugWithCodeSite(Sender : TObject);
    Function  FindEditorPopup : TPopupActionBar;
    Function  FindComponent(Const OwnerComponent : TComponent; Const strName : String;
      Const ClsType : TClass) : TComponent;
    Function  FindEditWindow : TForm;
  Public
    Constructor Create;
    Destructor Destroy; Override;
  End;

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  System.SysUtils,
  System.Win.Registry,
  VCL.Controls,
  VCL.Graphics,
  Winapi.Windows,
  DebuggingTools.AboutBox,
  DebuggingTools.SplashScreen,
  DebuggingTools.OptionsIDEInterface,
  DebuggingTools.PluginOptions,
  DebuggingTools.KeyboardBindings,
  DebuggingTools.DebuggingTools;

(**

  This is an on click event handler for the Add Breakpoint IDE context menu.

  @precon  None.
  @postcon Adds a breakpoint at the curssor position in the active source code editor.

  @param   Sender as a TObject

**)
Procedure TDDTWizard.AddBreakpoint(Sender: TObject);

Begin
  TDDTDebuggingTools.AddBreakpoint;
End;

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
  strImageName = 'DDTMenuBitMap16x16'; //: @todo Need individual images for the menus...

Var
  BM : VCL.Graphics.TBitMap;

Begin
  Result := -1;
  If FindResource(hInstance, strImageName, RT_BITMAP) > 0 Then
    Begin
      BM := VCL.Graphics.TBitMap.Create;
      Try
        BM.LoadFromResourceName(hInstance, strImageName);
        Result := ImageList.AddMasked(BM, clLime);
      Finally
        BM.Free;
      End;
    End;
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
  FKeyboardBindingIndex := TDDTKeyboardBindings.AddKeyboardBindings(FPluginOptions);
  FEditorPopupMethod.Data := Nil;
  FMenuInstalled := False;
  FMenuTimer := TTimer.Create(Nil);
  FMenuTimer.Interval := iTimerInterval;
  FMenuTimer.OnTimer := MenuInstallerTimer;
  FMenuTimer.Enabled := True;
End;

(**

  This is the replacement IDE Editor Context menu OnPopup event handler.

  @precon  None.
  @postcon It first calls the existing event handler it found (if found) and then installs the menus for
           the Debugging Tools.

  @param   Sender as a TObject

**)
Procedure TDDTWizard.DebuggingToolsPopupEvent(Sender: TObject);

ResourceString
  strDebuggingTools = 'Debugging Tools';
  strAddBreakpoint = 'Add Breakpoint';
  strDebugWithCodeSiteCaption = 'Debug &with CodeSite';

Var
  NotifyEvent : TNotifyEvent;
  EditorPopupMenu: TPopupActionBar;
  MI: TMenuItem;

Begin
  If Assigned(FEditorPopupMethod.Data) Then
    Begin
      NotifyEvent := TNotifyEvent(FEditorPopupMethod);
      NotifyEvent(Sender);
    End;
  EditorPopupMenu := FindEditorPopup;
  If Assigned(EditorPopupMenu) Then
    Begin
      If Assigned(FDebuggingToolsMenu) Then
        FDebuggingToolsMenu.Free;
      // Create Main Menu Item
      FDebuggingToolsMenu := TMenuItem.Create(EditorPopupMenu);
      FDebuggingToolsMenu.Caption := strDebuggingTools;
      //FDebuggingToolsMenu.OnClick := DebugWithCodeSite;
      FDebuggingToolsMenu.ImageIndex := FImageIndex;
      EditorPopupMenu.Items.Add(FDebuggingToolsMenu);
      // Create Add Breapoint
      MI := TMenuItem.Create(FDebuggingToolsMenu);
      MI.Caption := strAddBreakpoint;
      MI.OnClick := AddBreakpoint;
      MI.ImageIndex := FImageIndex;
      FDebuggingToolsMenu.Add(MI);
      // Create Debug with CodeSite
      MI := TMenuItem.Create(FDebuggingToolsMenu);
      MI.Caption := strDebugWithCodeSiteCaption;
      MI.OnClick := DebugWithCodeSite;
      MI.ImageIndex := FImageIndex;
      FDebuggingToolsMenu.Add(MI);
    End;
End;

(**

  This is an on click event handler for the Debug with CodeSite IDE context menu item.

  @precon  None.
  @postcon Adds an evaluation breakpoint at the current cursor position in the active editor containing
           a CodeSite Send() message.

  @param   Sender as a TObject

**)
Procedure TDDTWizard.DebugWithCodeSite(Sender : TObject);

Begin
  TDDTDebuggingTools.AddCodeSiteBreakpoint(FPluginOptions);
End;

(**

  A destructor for the TDDTWizard class.

  @precon  None.
  @postcon Removes the about box and frees the contet menu timer.

**)
Destructor TDDTWizard.Destroy;

Begin
  UnhookEditorPopupMenu;
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
Procedure TDDTWizard.Execute;

Begin
  // Do nothing
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
Function TDDTWizard.FindComponent(Const OwnerComponent : TComponent; Const strName : String;
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

(**

  This method attempts to find the editors popup menu and returna  reference to it.

  @precon  None.
  @postcon Returns a reference to the editors popup menu if found else returns nil.

  @return  a TPopupActionBar

**)
Function  TDDTWizard.FindEditorPopup : TPopupActionBar;

Const
  strEditorLocalMenuComponentName = 'EditorLocalMenu';
  
Var
  EditorForm: TForm;

Begin
  Result := Nil;
  EditorForm := FindEditWindow;
  If Assigned(EditorForm) Then
    Begin
      Result := FindComponent(
        EditorForm,
        strEditorLocalMenuComponentName,
        TPopupActionBar
      ) As TPopupActionBar;
    End;
End;

(**

  This method searches the screens objects forms for the form with the given class name.

  @precon  None.
  @postcon The form reference is returned IF found else nil.

  @return  a TForm

**)
Function TDDTWizard.FindEditWindow : TForm;

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

  This is method hooks the Editors popup menu.

  @precon  None.
  @postcon The code search the IDE for the editor and then its context menu and hooks the popup menus
           OnPopup event handler so that it can add menus to the context menu when it is displayed.

**)
Procedure TDDTWizard.HookEditorPopupMenu;

Var
  EditorPopupMenu : TPopupActionBar;

Begin
  EditorPopupMenu := FindEditorPopup;
  If Assigned(EditorPopupMenu) Then
    Begin
      FImageIndex := AddImageToList(EditorPopupMenu.Images);
      If Assigned(EditorPopupMenu.OnPopup) Then
        Begin
          FEditorPopupMethod := TMethod(EditorPopupMenu.OnPopup);
          EditorPopupMenu.OnPopup := DebuggingToolsPopupEvent;
        End Else
          EditorPopupMenu.OnPopup := DebuggingToolsPopupEvent;
      FMenuTimer.Enabled := False;
    End;
End;

(**

  This is an on timer event handler.

  @precon  None.
  @postcon Tries to install the editoer context menu.

  @param   Sender as a TObject

**)
Procedure TDDTWizard.MenuInstallerTimer(Sender: TObject);

Begin
  HookEditorPopupMenu;
End;

(**

  This method attempts to remove the IDE Editor popup menu OnPopup hook when the plug-in is removed.
  This is only here for BPLs as the editor does not exist at the point in time this wizard is
  destroyed.

  @precon  None.
  @postcon The IDE Editor onctext menu opopup hook is removed if found.

**)
Procedure TDDTWizard.UnhookEditorPopupMenu;

Var
  EditorPopupMenu : TPopupActionBar;

Begin
  {$IFDEF DEBUG} CodeSite.TraceMethod(Self, 'UnhookEditorPopupMenu', tmoTiming); {$ENDIF DEBUG}
  EditorPopupMenu := FindEditorPopup;
  If Assigned(EditorPopupMenu) And Assigned(EditorPopupMenu.OnPopup) Then
    EditorPopupMenu.OnPopup := TNotifyEvent(FEditorPopupMethod);
End;

End.
