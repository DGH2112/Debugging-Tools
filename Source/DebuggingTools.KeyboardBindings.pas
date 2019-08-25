(**
  
  This module contains a class which implements editor keyboard bindings in the IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    25 Aug 2019
  
**)
Unit DebuggingTools.KeyboardBindings;

Interface

Uses
  ToolsAPI,
  System.Classes,
  DebuggingTools.Interfaces;

Type
  (** A class to implement the editor keyboard bindings. **)
  TDDTKeyboardBindings = Class(TNotifierObject, IOTAKeyboardBinding)
  Strict Private
    FPluginOptions : IDDTPluginOptions;
  Strict Protected
    // IOTAKeyboardBinding
    Procedure BindKeyboard(Const BindingServices: IOTAKeyBindingServices);
    Function GetBindingType: TBindingType;
    Function GetDisplayName: String;
    Function GetName: String;
    // General Methods
    Procedure AddBreakpoint(Const Context : IOTAKeyContext; KeyCode : TShortcut;
      Var BindingResult : TKeyBindingResult);
    Procedure AddCodeSiteBreakpoint(Const Context : IOTAKeyContext; KeyCode : TShortcut;
      Var BindingResult : TKeyBindingResult);
  Public
    Constructor Create(Const PluginOptions : IDDTPluginOptions);
    Class Function  AddKeyboardBindings(Const PluginOptions : IDDTPluginOptions) : Integer;
    Class Procedure RemoveKeyboardBindings(Const iIndex : Integer);
  End;

Implementation

Uses
  System.SysUtils,
  VCL.Menus,
  DebuggingTools.OpenToolsAPIFunctions, DebuggingTools.Types;

(**

  This method either adds a new source breakpoint or allows the user to edit the existing one.

  @precon  None.
  @postcon The existing or new breakpoint is displayed for editing.

  @nocheck MissingCONSTInParam
  @nohint  Context Keycode Binding

  @param   Context       as an IOTAKeyContext as a constant
  @param   KeyCode       as a TShortcut
  @param   BindingResult as a TKeyBindingResult as a reference

**)
Procedure TDDTKeyboardBindings.AddBreakpoint(Const Context: IOTAKeyContext; KeyCode: TShortcut;
  Var BindingResult: TKeyBindingResult);

  (**

    This method attempts to find the source breakpoint corresponding to the given line and filename.

    @precon  DebuggingServices must be a valid instance.
    @postcon Returns the breakpoint interface reference if found else returns nil.

    @param   DebuggingServices as an IOTADebuggerServices as a constant
    @param   strFileName       as a String as a constant
    @param   iLine             as an Integer as a constant
    @return  an IOTABreakpoint

  **)
  Function FindExistingBreakpoint(Const DebuggingServices : IOTADebuggerServices;
    Const strFileName : String; Const iLine : Integer) : IOTABreakpoint;

  Var
    iBreakpoint: Integer;
  
  Begin
    Result := Nil;
    For iBreakpoint := 0 To DebuggingServices.SourceBkptCount - 1 Do
      If (DebuggingServices.SourceBkpts[iBreakpoint].LineNumber = iLine) Then
        If AnsiCompareFileName(DebuggingServices.SourceBkpts[iBreakpoint].FileName, strFileName) = 0 Then
          Begin
            Result := DebuggingServices.SourceBkpts[iBreakpoint];
            Break;
          End;
  End;

Var
  MS : IOTAModuleServices;
  Source: IOTASourceEditor;
  CursorPos: TOTAEditPos;
  DS : IOTADebuggerServices;
  Breakpoint : IOTABreakpoint;
  
Begin
  If Supports(BorlandIDEServices, IOTAModuleServices, MS) Then
    Begin
      Source := TDDTOpenToolsAPIFunctions.SourceEditor(MS.CurrentModule);
      CursorPos := Source.EditViews[0].CursorPos;
      If Supports(BorlandIDEServices, IOTADebuggerServices, DS) Then
        Begin
          Breakpoint := FindExistingBreakpoint(DS, Source.FileName, CursorPos.Line);
          If Not Assigned(Breakpoint) Then
            Breakpoint := DS.NewSourceBreakpoint(Source.FileName, CursorPos.Line, Nil);
          Breakpoint.Edit(True)
        End;
    End;
  BindingResult := krHandled;
End;

(**

  This is the on click event handler for the editor Debug With CodeSite contetx menu.

  @precon  None.
  @postcon Adds a breakpoint on the line of the cursor with CodeSite information in the EvalExpression 
           property for the identifier at the cursor. nocheck MissingCONSTInParam nohint Context 
           KeyCode

  @nocheck MissingCONSTInParam
  @nohint  Context Keycode

  @param   Context       as an IOTAKeyContext as a constant
  @param   KeyCode       as a TShortcut
  @param   BindingResult as a TKeyBindingResult as a reference

**)
Procedure TDDTKeyboardBindings.AddCodeSiteBreakpoint(Const Context: IOTAKeyContext; KeyCode: TShortcut;
  Var BindingResult: TKeyBindingResult);

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
        strIdentifierAtCursor := TDDTOpenToolsAPIFunctions.IdentifierAtCursor;
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
              TDDTOpenToolsAPIFunctions.CheckCodeSiteLogging;
            If DDTcDebuggingDCUs In FPluginOptions.CheckOptions Then
              TDDTOpenToolsAPIFunctions.CheckDebuggingDCUs;
            If DDTcLibraryPath In FPluginOptions.CheckOptions Then
              TDDTOpenToolsAPIFunctions.CheckLibraryPath;
            If DDTcEditBreakpoint In FPluginOptions.CheckOptions Then
              BP.Edit(True);
          End Else
            TDDTOpenToolsAPIFunctions.OutputMsg(strThereNoIdentifierAtCursorPosition);
      End;
  BindingResult := krHandled;
End;

(**

  This class method installs the keyboard bindings into the IDE.

  @precon  None.
  @postcon The keyboard bindings are available in the IDE.

  @param   PluginOptions as an IDDTPluginOptions as a constant
  @return  an Integer

**)
Class Function TDDTKeyboardBindings.AddKeyboardBindings(Const PluginOptions : IDDTPluginOptions) : Integer;

Var
  KBS : IOTAKeyboardServices;

Begin
  Result := -1;
  If Supports(BorlandIDEServices, IOTAKeyboardServices, KBS) Then
    Result := KBS.AddKeyboardBinding(TDDTKeyboardBindings.Create(PluginOptions));
End;

(**

  This method regsiters the keyboard bindings with the IDE - it ios called by the IDE when the keyboard
  binding class is loaded.

  @precon  None.
  @postcon The keyboard bindings are installed into the IDE.

  @param   BindingServices as an IOTAKeyBindingServices as a constant

**)
Procedure TDDTKeyboardBindings.BindKeyboard(Const BindingServices: IOTAKeyBindingServices);

Const
  strCtrlShiftF8 = 'Ctrl+Shift+F8';
  strCtrlShiftF7 = 'Ctrl+Shift+F7';

Begin
  BindingServices.AddKeyBinding([TextToShortCut(strCtrlShiftF8)], AddBreakpoint, Nil);
  BindingServices.AddKeyBinding([TextToShortCut(strCtrlShiftF7)], AddCodeSiteBreakpoint, Nil);
End;

(**

  A constructor for the TDDTKeyboardBindings class.

  @precon  None.
  @postcon Stores an interface reference to the plugin options.

  @param   PluginOptions as an IDDTPluginOptions as a constant

**)
Constructor TDDTKeyboardBindings.Create(Const PluginOptions: IDDTPluginOptions);

Begin
  FPluginOptions := PluginOptions;
End;

(**

  This is a getter method for the BindingType property.

  @precon  None.
  @postcon Returns that this is a partial binding (i.e. adds to the main binding).

  @return  a TBindingType

**)
Function TDDTKeyboardBindings.GetBindingType: TBindingType;

Begin
  Result := btPartial;
End;

(**

  This is a getter method for the DisplayName property.

  @precon  None.
  @postcon Returns the display name of the binding which appears in the list of available bindings.

  @return  a String

**)
Function TDDTKeyboardBindings.GetDisplayName: String;

ResourceString
  strDisplayName = 'DGH Debugging Tools';

Begin
  Result := strDisplayName;
End;

(**

  This is a getter method for the Name property.

  @precon  None.
  @postcon Returns the name of the Keyboard Binding.

  @return  a String

**)
Function TDDTKeyboardBindings.GetName: String;

ResourceString
  strName = 'Season''s Fall.DGH Debugging Tools';

Begin
  Result := strName;
End;

(**

  This class method remove the indexed keybindings from the IDE.

  @precon  None.
  @postcon The keyboard bindings are no longer registered with the IDE.

  @param   iIndex as an Integer as a constant

**)
Class Procedure TDDTKeyboardBindings.RemoveKeyboardBindings(Const iIndex: Integer);

Var
  KBS : IOTAKeyboardServices;

Begin
  If Supports(BorlandIDEServices, IOTAKeyboardServices, KBS) Then
    KBS.RemoveKeyboardBinding(iIndex);
End;

End.
