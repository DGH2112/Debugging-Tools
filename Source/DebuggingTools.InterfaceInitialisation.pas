(**

  This module contains the code to load the wizard in to the RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.303
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
Unit DebuggingTools.InterfaceInitialisation;

Interface

Uses
  ToolsAPI;

Procedure Register;
Function InitWizard(Const BorlandIDEServices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc;
  Var Terminate: TWizardTerminateProc): Boolean; StdCall;

Exports
  InitWizard Name WizardEntryPoint;

Implementation

Uses
  DebuggingTools.Wizard;

(**

  This method is requested by the RAD Studio IDE in order to load the plug-in as a DLL wizard.

  @precon  None.
  @postcon Creates the plug-in.

  @nocheck MissingCONSTInParam
  @nohint  Terminate

  @param   BorlandIDEServices as an IBorlandIDEServices as a constant
  @param   RegisterProc       as a TWizardRegisterProc
  @param   Terminate          as a TWizardTerminateProc as a reference
  @return  a Boolean

**)
Function InitWizard(Const BorlandIDEServices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc;
  Var Terminate: TWizardTerminateProc): Boolean; StdCall; //FI:O804

Begin
  Result := BorlandIDEServices <> Nil;
  RegisterProc(TDDTWizard.Create);
End;

(**

  This method is required by the RAD Studio IDE in order to load the plug-in as a package.

  @precon  None.
  @postcon Creates the plug-in wizard.

**)
Procedure Register;

Begin
  RegisterPackageWizard(TDDTWizard.Create);
End;

End.
