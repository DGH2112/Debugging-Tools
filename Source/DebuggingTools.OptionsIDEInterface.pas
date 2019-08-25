(**

  This module contains an a class to handle the installation of the options frame into the IDEs
  options dialogue.

  @Author  David Hoyle
  @Version 1.3
  @Date    11 Aug 2019

**)
Unit DebuggingTools.OptionsIDEInterface;

Interface

{$INCLUDE CompilerDefinitions.inc}

{$IFDEF DXE00}

Uses
  ToolsAPI,
  DebuggingTools.OptionsFrame,
  Forms,
  DebuggingTools.Interfaces;

Type
  (** A class which implements the INTAAddingOptions interface to added options frames
      to the IDEs options dialogue. **)
  TDDTIDEOptionsHandler = Class(TInterfacedObject, IUnknown, INTAAddInOptions)
  Strict Private
    Class Var
      (** A class variable to hold the instance reference for this IDE options handler. **)
      FDDTIDEOptions : TDDTIDEOptionsHandler;
  Strict Private
    FDDTOptionsFrame  : TframeDDTOptions;
    FDDTPluginOptions : IDDTPluginOptions;
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
    Constructor Create(Const PluginOptions : IDDTPluginOptions);
    Class Procedure AddOptionsFrameHandler(Const PluginOptions : IDDTPluginOptions);
    Class Procedure RemoveOptionsFrameHandler;
  End;
{$ENDIF}

Implementation

{$IFDEF DXE00}

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  {$IFDEF DXE20}System.SysUtils{$ELSE}SysUtils{$ENDIF},
  DebuggingTools.Types;

(**

  This is a class method to add the options frame handler to the IDEs options dialogue.

  @precon  None.
  @postcon The IDE options handler is installed into the IDE.

  @param   PluginOptions as an IDDTPluginOptions as a constant

**)
Class Procedure TDDTIDEOptionsHandler.AddOptionsFrameHandler(Const PluginOptions : IDDTPluginOptions);

Var
  EnvironmentOptionsServices : INTAEnvironmentOptionsServices;

Begin
  FDDTIDEOptions := TDDTIDEOptionsHandler.Create(PluginOptions);
  If Supports(BorlandIDEServices, INTAEnvironmentOptionsServices, EnvironmentOptionsServices) Then
    EnvironmentOptionsServices.RegisterAddInOptions(FDDTIDEOptions);
End;

(**

  A constructor for the TDWVSIDEOptionsHandler class.

  @precon  None.
  @postcon Stores the Options Read Wrtier interface reference.

  @param   PluginOptions as an IDDTPluginOptions as a constant

**)
Constructor TDDTIDEOptionsHandler.Create(Const PluginOptions : IDDTPluginOptions);

Begin
  Inherited Create;
  FDDTPluginOptions := PluginOptions;
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
    If Supports(FDDTOptionsFrame, IDDTOptions, I) Then
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
  FDDTOptionsFrame := AFrame As TframeDDTOptions;
  If Supports(FDDTOptionsFrame, IDDTOptions, I) Then
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
  strDebugWithCodeSite = 'DGH Debugging Tools.Debug With CodeSite';

Begin
  Result := strDebugWithCodeSite;
End;

(**

  This is a getter method for the FrameClass property.

  @precon  None.
  @postcon This is called by the IDE to get the frame class to create when displaying the
           options dialogue.

  @return  a TCustomFrameClass

**)
Function TDDTIDEOptionsHandler.GetFrameClass: TCustomFrameClass;

Begin
  Result := TframeDDTOptions;
End;

(**

  This is a getter method for the HelpContext property.

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

**)
Class Procedure TDDTIDEOptionsHandler.RemoveOptionsFrameHandler;

Var
  EnvironmentOptionsServices : INTAEnvironmentOptionsServices;

Begin
  If Supports(BorlandIDEServices, INTAEnvironmentOptionsServices, EnvironmentOptionsServices) Then
    EnvironmentOptionsServices.UnregisterAddInOptions(FDDTIDEOptions);
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

{$ENDIF}

End.


