(**

  This module contains two procedures for adding and removing an about box entry in the RAD Studio
  IDE.

  @Author  David Hoyle
  @Version 1.3
  @Date    29 Aug 2019

  @license
  
    DGH Debugging Tools is a RAD Studio plug-in to provide additional functionality
    in the RAD Studio IDE when debugging.
    
    Copyright (C) 2019  David Hoyle (https://github.com/DGH2112/Debugging-Tools/)

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
Unit DebuggingTools.AboutBox;

Interface

{$INCLUDE CompilerDefinitions.inc}

  Procedure AddAboutBoxEntry;
  Procedure RemoveAboutBoxEntry;

Implementation

Uses
  ToolsAPI,
  SysUtils,
  Windows,
  DebuggingTools.Common,
  Forms;

{$IFDEF D2005}
Var
  (** This is an internal reference for the about box entry`s plugin index - requried for
      removal. **)
  iAboutPlugin : Integer;
{$ENDIF}

(**

  This method adds an Aboutbox entry to the RAD Studio IDE.

  @precon  None.
  @postcon The about box entry is added to the IDE and its plugin index stored in iAboutPlugin.

**)
Procedure AddAboutBoxEntry;

ResourceString
  strSKUBuild = 'SKU Build %d.%d.%d.%d';

Const
  strDDTSplashScreenBitMap = 'DDTSplashScreenBitMap48x48';

Var
  iMajor : Integer;
  iMinor : Integer;
  iBugFix : Integer;
  iBuild : Integer;
  bmSplashScreen : HBITMAP;

Begin //FI:W519
  {$IFDEF D2005}
  BuildNumber(iMajor, iMinor, iBugFix, iBuild);
  bmSplashScreen := LoadBitmap(hInstance, strDDTSplashScreenBitMap);
  iAboutPlugin := (BorlandIDEServices As IOTAAboutBoxServices).AddPluginInfo(
    Format(strSplashScreenName, [iMajor, iMinor, Copy(strRevision, iBugFix + 1, 1),
      Application.Title]),
    strIDEPlugInDescription,
    bmSplashScreen,
    {$IFDEF DEBUG} True {$ELSE}  False {$ENDIF},
    Format(strSplashScreenBuild, [iMajor, iMinor, iBugfix, iBuild]),
    Format(strSKUBuild, [iMajor, iMinor, iBugfix, iBuild]));
  {$ENDIF}
End;

(**

  This method removes the indexed abotu box entry from the RAD Studio IDE.

  @precon  None.
  @postcon The about box entry is remvoed from the IDE.

**)
Procedure RemoveAboutBoxEntry;

Begin //FI:W519
  {$IFDEF D2010}
  If iAboutPlugin > iWizardFailState Then
    (BorlandIDEServices As IOTAAboutBoxServices).RemovePluginInfo(iAboutPlugin);
  {$ENDIF}
End;

End.
