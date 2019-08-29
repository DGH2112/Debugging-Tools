(**

  This module contains the main project code for a RAD Studio IDE plug-in for adding CodeSite
  debugging messages via a breakpoint.

  @Author  David Hoyle
  @Version 1.3
  @date    28 Aug 2019

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
  DebuggingTools.Functions in 'Source\DebuggingTools.Functions.pas',
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
  DebuggingTools.DebuggingTools in 'Source\DebuggingTools.DebuggingTools.pas';

{$R *.res}

Begin

End.
