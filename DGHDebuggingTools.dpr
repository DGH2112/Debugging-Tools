(**

  This module contains the main project code for a RAD Studio IDE plug-in for adding CodeSite
  debugging messages via a breakpoint.

  @Author  David Hoyle
  @Version 1.392
  @Date    03 Jun 2020

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

  @nocheck EmptyBeginEnd

**)
Library DGHDebuggingTools;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

{$R 'DebuggingTools.res' 'Images\DebuggingTools.rc'}
{$R 'DDTITHVerInfo.res' 'DDTITHVerInfo.RC'}
{$INCLUDE Source\CompilerDefinitions.inc}
{$INCLUDE Source\LibrarySuffixes.inc}

uses
  DebuggingTools.InterfaceInitialisation in 'Source\DebuggingTools.InterfaceInitialisation.pas',
  DebuggingTools.Wizard in 'Source\DebuggingTools.Wizard.pas',
  DebuggingTools.AboutBox in 'Source\DebuggingTools.AboutBox.pas',
  DebuggingTools.Common in 'Source\DebuggingTools.Common.pas',
  DebuggingTools.SplashScreen in 'Source\DebuggingTools.SplashScreen.pas',
  DebuggingTools.OptionsIDEInterface in 'Source\DebuggingTools.OptionsIDEInterface.pas',
  DebuggingTools.OptionsFrame in 'Source\DebuggingTools.OptionsFrame.pas' {frameDDTOptions: TFrame},
  DebuggingTools.Types in 'Source\DebuggingTools.Types.pas',
  DebuggingTools.Interfaces in 'Source\DebuggingTools.Interfaces.pas',
  DebuggingTools.PluginOptions in 'Source\DebuggingTools.PluginOptions.pas',
  DebuggingTools.KeyboardBindings in 'Source\DebuggingTools.KeyboardBindings.pas',
  DebuggingTools.OpenToolsAPIFunctions in 'Source\DebuggingTools.OpenToolsAPIFunctions.pas',
  DebuggingTools.DebuggingTools in 'Source\DebuggingTools.DebuggingTools.pas',
  DebuggingTools.ParentFrame in 'Source\DebuggingTools.ParentFrame.pas' {fmDDTParentFrame: TFrame};

{$R *.res}

Begin

End.
