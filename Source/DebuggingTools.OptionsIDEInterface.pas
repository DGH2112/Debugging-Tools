(**

  This module contains an a class to handle the installation of the options frame into the IDEs
  options dialogue.

  @Author  David Hoyle
  @Version 1.306
  @Date    26 Nov 2023

  @license

    DGH Debugging Tools is a RAD Studio plug-in to provide additional functionality
    in the RAD Studio IDE when debugging.

    Copyright (C) 2023  David Hoyle (https://github.com/DGH2112/Debugging-Tools/)

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
Unit DebuggingTools.OptionsIDEInterface;

Interface

{$INCLUDE CompilerDefinitions.inc}

Uses
  ToolsAPI,
  VCL.Forms,
  DebuggingTools.Interfaces;

Type
  (** An enumerate to define the frame type to be created. **)
  TDDTFrameType = (ftParent, ftOptions);

  (** A class which implements the INTAAddinOptions interface to added options frames
      to the IDEs options dialogue. **)
  TDDTIDEOptionsHandler = Class(TInterfacedObject, IUnknown, INTAAddInOptions)
  Strict Private
    FDDTFrame         : TCustomFrame;
    FDDTPluginOptions : IDDTPluginOptions;
    FFrameType        : TDDTFrameType;
  Strict Protected
    Procedure DialogClosed(Accepted: Boolean);
    Procedure FrameCreated(AFrame: TCustomFrame);
    Function  GetArea: String;
    Function  GetCaption: String;
    Function  GetFrameClass: TCustomFrameClass;
    Function  GetHelpContext: Integer;
    Function  IncludeInIDEInsight: Boolean;
    Function  ValidateContents: Boolean;
  Public
    Constructor Create(Const PluginOptions : IDDTPluginOptions; Const eFrameType : TDDTFrameType);
    Class Function  AddOptionsFrameHandler(Const eFrameType : TDDTFrameType;
      Const PluginOptions : IDDTPluginOptions) : INTAAddInOptions;
    Class Procedure RemoveOptionsFrameHandler(Const AddInOptions : INTAAddInOptions);
  End;

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  System.SysUtils,
  DebuggingTools.Types,
  DebuggingTools.OptionsFrame,
  DebuggingTools.ParentFrame;
(**

  This is a class method to add the options frame handler to the IDEs options dialogue.

  @precon  None.
  @postcon The IDE options handler is installed into the IDE.

  @param   eFrameType    as a TDDTFrameType as a constant
  @param   PluginOptions as an IDDTPluginOptions as a constant
  @return  an INTAAddInOptions

**)
Class Function TDDTIDEOptionsHandler.AddOptionsFrameHandler(Const eFrameType : TDDTFrameType;
  Const PluginOptions : IDDTPluginOptions) : INTAAddInOptions;

Var
  EnvironmentOptionsServices : INTAEnvironmentOptionsServices;

Begin
  Result := TDDTIDEOptionsHandler.Create(PluginOptions, eFrameType);
  If Supports(BorlandIDEServices, INTAEnvironmentOptionsServices, EnvironmentOptionsServices) Then
    EnvironmentOptionsServices.RegisterAddInOptions(Result);
End;

(**

  A constructor for the TDDTIDEOptionsHandler class.

  @precon  None.
  @postcon Stores the Options Read Writer interface reference.

  @param   PluginOptions as an IDDTPluginOptions as a constant
  @param   eFrameType    as a TDDTFrameType as a constant

**)
Constructor TDDTIDEOptionsHandler.Create(Const PluginOptions : IDDTPluginOptions;
  Const eFrameType : TDDTFrameType);

Begin
  Inherited Create;
  FDDTPluginOptions := PluginOptions;
  FFrameType := eFrameType;
End;

(**

  This method is called by the IDE when the IDEs options dialogue is closed.

  @precon  None.
  @postcon If the dialogue was accepted and the frame supports the interface then it saves
           the frame settings.

  @nocheck MissingCONSTInParam

  @param   Accepted as a Boolean

**)
Procedure TDDTIDEOptionsHandler.DialogClosed(Accepted: Boolean);

Var
  I   : IDDTOptions;
  Ops : TDDTChecks;
  strCodeSiteMsg: String;

Begin
  If Accepted Then
    If Supports(FDDTFrame, IDDTOptions, I) Then
      Begin
        I.SaveOptions(Ops, strCodeSiteMsg);
        FDDTPluginOptions.CodeSiteTemplate := strCodeSiteMsg;
        FDDTPluginOptions.CheckOptions := Ops;
        FDDTPluginOptions.SaveSettings;
      End;
End;

(**

  This method is called by the IDe when the frame is created.

  @precon  None.
  @postcon If the frame supports the interface its settings are loaded.

  @nocheck MissingCONSTInParam

  @param   AFrame as a TCustomFrame

**)
Procedure TDDTIDEOptionsHandler.FrameCreated(AFrame: TCustomFrame);

Var
  I : IDDTOptions;
  Options : TDDTChecks;
  strCodeSiteMsg : String;

Begin
  FDDTFrame := AFrame;
  If Supports(FDDTFrame, IDDTOptions, I) Then
    Begin
      Options := FDDTPluginOptions.CheckOptions;
      strCodeSiteMsg := FDDTPluginOptions.CodeSiteTemplate;
      I.LoadOptions(Options, strCodeSiteMsg);
    End;
End;

(**

  This is a getter method for the Area property.

  @precon  None.
  @postcon Called by the IDE. NULL string is returned to place the options frame under the
           third party node.

  @return  a String

**)
Function TDDTIDEOptionsHandler.GetArea: String;

Begin
  Result := '';
End;

(**

  This is a getter method for the Caption property.

  @precon  None.
  @postcon This is called by the IDe to get the caption of the options frame in the IDEs
           options dialogue in the left treeview.

  @return  a String

**)
Function TDDTIDEOptionsHandler.GetCaption: String;

ResourceString
  strDebugWithCodeSite = 'DGH Debugging Tools';
  strOptions = 'DGH Debugging Tools.Options';

Begin
  Case FFrameType Of
    ftParent:  Result := strDebugWithCodeSite;
    ftOptions: Result := strOptions;
  End;
End;

(**

  This is a getter method for the Frame Class property.

  @precon  None.
  @postcon This is called by the IDE to get the frame class to create when displaying the
           options dialogue.

  @return  a TCustomFrameClass

**)
Function TDDTIDEOptionsHandler.GetFrameClass: TCustomFrameClass;

Begin
  Case FFrameType Of
    ftParent:  Result := TfmDDTParentFrame;
    ftOptions: Result := TframeDDTOptions;
  Else
    Result := TfmDDTParentFrame;
  End;
End;

(**

  This is a getter method for the Help Context property.

  @precon  None.
  @postcon This is called by the IDe and returns 0 to signify no help.

  @return  an Integer

**)
Function TDDTIDEOptionsHandler.GetHelpContext: Integer;

Begin
  Result := 0;
End;

(**

  This is called by the IDE to determine whether the controls on the options frame are
  displayed in the IDE Insight search.

  @precon  None.
  @postcon Returns true to be include in IDE Insight.

  @return  a Boolean

**)
Function TDDTIDEOptionsHandler.IncludeInIDEInsight: Boolean;

Begin
  Result := True;
End;

(**

  This is a class method to remove the options frame handler from the IDEs options dialogue.

  @precon  None.
  @postcon The IDE options handler is removed from the IDE.

  @param   AddInOptions as an INTAAddInOptions as a constant

**)
Class Procedure TDDTIDEOptionsHandler.RemoveOptionsFrameHandler(Const AddInOptions : INTAAddInOptions);

Var
  EnvironmentOptionsServices : INTAEnvironmentOptionsServices;

Begin
  If Supports(BorlandIDEServices, INTAEnvironmentOptionsServices, EnvironmentOptionsServices) Then
    EnvironmentOptionsServices.UnregisterAddInOptions(AddInOptions);
End;

(**

  This method is called by the IDE to validate the frame.

  @precon  None.
  @postcon Not used so returns true.

  @return  a Boolean

**)
Function TDDTIDEOptionsHandler.ValidateContents: Boolean;

Begin
  Result := True;
End;

End.


