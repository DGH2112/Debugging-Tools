(**

  This module contains a class to handle the plug-ins settings.

  @Author  David Hoyle
  @Version 1.3
  @Date    11 Aug 2019

**)
Unit DebuggingTools.PluginOptions;

Interface

Uses
  DebuggingTools.Types,
  DebuggingTools.Interfaces;

Type
  (** A class to handle the plug-ins settings. **)
  TDDTPluginOptions = Class(TInterfacedObject, IDDTPluginOptions)
  Strict Private
    FChecksOptions: TDDTChecks;
    FCodeSiteTemplate: String;
  Strict Protected
    Function  GetCheckOptions: TDDTChecks;
    Function  GetCodeSiteTemplate: String;
    Procedure SetCheckOptions(Const setCheckOptions: TDDTChecks);
    Procedure SetCodeSiteTemplate(Const strCodeSiteTemplate: String);
    Procedure LoadSettings;
    Procedure SaveSettings;
  Public
    Constructor Create;
  End;

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  Registry;

Const
  (** The registry key under which the settings are stored. **)
  strRegKey = 'Software\Season''s Fall\Debug with CodeSite\';
  (** A constant to define the INI Section Name for the settings. **)
  strSetupINISection = 'Setup';
  (** A constant to define the INI Key Name for the Code Site Message. **)
  strCodeSiteMsgINIKey = 'CodeSiteMsg';
  (** A constant to define the INI Key Name for the Code Site Options. **)
  strOptionsINIKey = 'Options';

{ TDDTPluginOptions }

(**

  A constructor for the TDDTPluginOptions class.

  @precon  None.
  @postcon Initialises the settings;

**)
Constructor TDDTPluginOptions.Create;

Const
  strCodeSiteSendMsg = 'CodeSite.Send(''%s'', %s)';

Begin
  FChecksOptions := [DDTcCodeSiteLogging .. DDTcBreak];
  FCodeSiteTemplate := strCodeSiteSendMsg;
  LoadSettings;
End;

(**

  This is a getter method for the CheckOptions property.

  @precon  None.
  @postcon Returns the check options.

  @return  a TDDTChecks

**)
Function TDDTPluginOptions.GetCheckOptions: TDDTChecks;

Begin
  Result := FChecksOptions;
End;

(**

  This is a getter method for the CoedSiteTemplate property.

  @precon  None.
  @postcon Returns the CodeSite template.

  @return  a String

**)
Function TDDTPluginOptions.GetCodeSiteTemplate: String;

Begin
  Result := FCodeSiteTemplate;
End;

(**

  This method loads the plug-ins settings from the regsitry.

  @precon  None.
  @postcon  The plug-ins settings are loaded.

**)
Procedure TDDTPluginOptions.LoadSettings;

Var
  R : TRegIniFile;

Begin
  R := TRegIniFile.Create(strRegKey);
  Try
    FCodeSiteTemplate := R.ReadString(strSetupINISection, strCodeSiteMsgINIKey, FCodeSiteTemplate);
    FChecksOptions := TDDTChecks(Byte(R.ReadInteger(strSetupINISection, strOptionsINIKey,
      Byte(FChecksOptions))));
  Finally
    R.Free;
  End;
End;

(**

  This method saves the settings to the registry.

  @precon  None.
  @postcon The settings are saved.

**)
Procedure TDDTPluginOptions.SaveSettings;

Var
  R: TRegIniFile;

Begin
  R := TRegIniFile.Create(strRegKey);
  Try
    R.WriteString(strSetupINISection, strCodeSiteMsgINIKey, FCodeSiteTemplate);
    R.WriteInteger(strSetupINISection, strOptionsINIKey, Byte(FChecksOptions));
  Finally
    R.Free;
  End;
End;

(**

  This is a setter method for the CheckOptions property.

  @precon  None.
  @postcon Updates the check options.

  @param   setCheckOptions as a TDDTChecks as a constant

**)
Procedure TDDTPluginOptions.SetCheckOptions(Const setCheckOptions: TDDTChecks);

Begin
  FChecksOptions := setCheckOptions;
End;

(**

  This is a setter method for the CodeSiteTemplate property.

  @precon  None.
  @postcon Updates the CodeSite template.

  @param   strCodeSiteTemplate as a String as a constant

**)
Procedure TDDTPluginOptions.SetCodeSiteTemplate(Const strCodeSiteTemplate: String);

Begin
  FCodeSiteTemplate := strCodeSiteTemplate;
End;

End.


