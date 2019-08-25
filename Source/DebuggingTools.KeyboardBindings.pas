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
  System.Classes;

Type
  (** A class to implement the editor keyboard bindings. **)
  TDDTKeyboardBindings = Class(TNotifierObject, IOTAKeyboardBinding)
  Strict Private
  Strict Protected
    // IOTAKeyboardBinding
    Procedure BindKeyboard(Const BindingServices: IOTAKeyBindingServices);
    Function GetBindingType: TBindingType;
    Function GetDisplayName: String;
    Function GetName: String;
    // General Methods
    Procedure AddBreakpoint(Const Context : IOTAKeyContext; KeyCode : TShortcut;
      Var BindingResult : TKeyBindingResult);
  Public
    Class Function  AddKeyboardBindings : Integer;
    Class Procedure RemoveKeyboardBindings(Const iIndex : Integer);
  End;

Implementation

Uses
  System.SysUtils,
  VCL.Menus,
  DebuggingTools.OpenToolsAPIFunctions;

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

  This class method installs the keyboard bindings into the IDE.

  @precon  None.
  @postcon The keyboard bindings are available in the IDE.

  @return  an Integer

**)
Class Function TDDTKeyboardBindings.AddKeyboardBindings: Integer;

Var
  KBS : IOTAKeyboardServices;

Begin
  Result := -1;
  If Supports(BorlandIDEServices, IOTAKeyboardServices, KBS) Then
    Result := KBS.AddKeyboardBinding(TDDTKeyboardBindings.Create);
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
  strCtrlAltShift = 'Ctrl+Shift+F8';

Begin
  BindingServices.AddKeyBinding([TextToShortCut(strCtrlAltShift)], AddBreakpoint, Nil);
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
