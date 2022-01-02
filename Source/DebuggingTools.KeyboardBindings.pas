(**
  
  This module contains a class which implements editor keyboard bindings in the IDE.

  @Author  David Hoyle
  @Version 1.016
  @Date    02 Jan 2022
  
  @license
  
    DGH Debugging Tools is a RAD Studio plug-in to provide additional functionality
    in the RAD Studio IDE when debugging.
    
    Copyright (C) 2020  David Hoyle (https://github.com/DGH2112/Debugging-Tools/)

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
  DebuggingTools.DebuggingTools;

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
Procedure TDDTKeyboardBindings.AddBreakpoint(Const Context: IOTAKeyContext; KeyCode: TShortcut; //FI:O804
  Var BindingResult: TKeyBindingResult);

Begin
  TDDTDebuggingTools.AddBreakpoint;
  BindingResult := krHandled;
End;

(**

  This is the on click event handler for the editor Debug With CodeSite context menu.

  @precon  None.
  @postcon Adds a breakpoint on the line of the cursor with CodeSite information in the Evaluation
           Expression property for the identifier at the cursor.

  @nocheck MissingCONSTInParam
  @nohint  Context Keycode

  @param   Context       as an IOTAKeyContext as a constant
  @param   KeyCode       as a TShortcut
  @param   BindingResult as a TKeyBindingResult as a reference

**)
Procedure TDDTKeyboardBindings.AddCodeSiteBreakpoint(Const Context: IOTAKeyContext; KeyCode: TShortcut; //FI:O804
  Var BindingResult: TKeyBindingResult);

Begin
  TDDTDebuggingTools.AddCodeSiteBreakpoint(FPluginOptions);
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

  This method registers the keyboard bindings with the IDE - it is called by the IDE when the keyboard
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
  @postcon Stores an interface reference to the plug-in options.

  @param   PluginOptions as an IDDTPluginOptions as a constant

**)
Constructor TDDTKeyboardBindings.Create(Const PluginOptions: IDDTPluginOptions);

Begin
  Inherited Create;
  FPluginOptions := PluginOptions;
End;

(**

  This is a getter method for the Binding Type property.

  @precon  None.
  @postcon Returns that this is a partial binding (i.e. adds to the main binding).

  @return  a TBindingType

**)
Function TDDTKeyboardBindings.GetBindingType: TBindingType;

Begin
  Result := btPartial;
End;

(**

  This is a getter method for the Display Name property.

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
  strName = 'David Hoyle.DGH Debugging Tools';

Begin
  Result := strName;
End;

(**

  This class method remove the indexed key bindings from the IDE.

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
