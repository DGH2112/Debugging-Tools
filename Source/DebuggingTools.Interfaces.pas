(**

  This module contains interfaces for use within the application.

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
Unit DebuggingTools.Interfaces;

Interface

Uses
  DebuggingTools.Types;

Type
  (** An interface for loading and save options from the Options frame. **)
  IDDTOptions = Interface
  ['{2C30AC8E-9C54-4544-A6AD-394DA361341F}']
    Procedure LoadOptions(Const CheckOptions : TDDTChecks; Const strCodeSiteMsg : String);
    Procedure SaveOptions(Var CheckOptions : TDDTChecks; Var strCodeSiteMsg : String);
  End;

  (** An interface for the Plug-in Options **)
  IDDTPluginOptions = Interface
  ['{C0C072B8-4F4C-4EE1-938A-333FF7BCE881}']
    Function  GetCodeSiteTemplate : String;
    Procedure SetCodeSiteTemplate(Const strCodeSiteTemplate : String);
    Function  GetCheckOptions : TDDTChecks;
    Procedure SetCheckOptions(Const setCheckOptions : TDDTChecks);
    Procedure LoadSettings;
    Procedure SaveSettings;
    (**
      This property gets and sets the CodeSite template that is used to fill the breakpoint evaluation
      expression.
      @precon  None.
      @postcon Gets and sets the CodeSite template that is used to fill the breakpoint evaluation
               expression.
      @return  a String
    **)
    Property CodeSiteTemplate : String Read GetCodeSiteTemplate Write SetCodeSiteTemplate;
    (**
      This property gets and sets the check options that is used to fill the breakpoint.
      @precon  None.
      @postcon Gets and sets the check options that is used to fill the breakpoint.
      @return  a TDDTChecks
    **)
    Property CheckOptions : TDDTChecks Read GetCheckOptions Write SetCheckOptions;
  End;

Implementation

End.
