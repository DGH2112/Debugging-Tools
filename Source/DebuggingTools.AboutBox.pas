(**

  This module contains two procedures for adding and removing an about box entry in the RAD Studio
  IDE.

  @Author  David Hoyle
  @Version 1.387
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
Unit DebuggingTools.AboutBox;

Interface

{$INCLUDE CompilerDefinitions.inc}

  Procedure AddAboutBoxEntry;
  Procedure RemoveAboutBoxEntry;

Implementation

Uses
  ToolsAPI,
  SysUtils,
  {$IFDEF RS110}
  Graphics,
  {$ELSE}
  Windows,
  {$ENDIF RS110}
  DebuggingTools.Common,
  Forms;

Var
  (** This is an internal reference for the about box entry`s plug-in index - required for
      removal. **)
  iAboutPlugin : Integer;

(**

  This method adds an About box entry to the RAD Studio IDE.

  @precon  None.
  @postcon The about box entry is added to the IDE and its plug-in index stored in iAboutPlugin.

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
  {$IFDEF RS110}
  AboutBoxBitMap : TBitmap;
  {$ELSE}
  bmSplashScreen : HBITMAP;
  {$ENDIF RS110}

Begin
  BuildNumber(iMajor, iMinor, iBugFix, iBuild);
  {$IFDEF RS110}
  AboutBoxBitMap := TBitmap.Create;
  Try
    AboutBoxBitMap.LoadFromResourceName(hInstance, strDDTSplashScreenBitMap);
    iAboutPlugin := (BorlandIDEServices As IOTAAboutBoxServices).AddPluginInfo(
      Format(strSplashScreenName, [iMajor, iMinor, Copy(strRevision, iBugFix + 1, 1),
        Application.Title]),
      strIDEPlugInDescription,
      [AboutBoxBitMap],
      {$IFDEF DEBUG} True {$ELSE}  False {$ENDIF},
      Format(strSplashScreenBuild, [iMajor, iMinor, iBugfix, iBuild]),
      Format(strSKUBuild, [iMajor, iMinor, iBugfix, iBuild])
    );
  Finally
    AboutBoxBitMap.Free;
  End;
  {$ELSE}
  bmSplashScreen := LoadBitmap(hInstance, strDDTSplashScreenBitMap);
  iAboutPlugin := (BorlandIDEServices As IOTAAboutBoxServices).AddPluginInfo(
    Format(strSplashScreenName, [iMajor, iMinor, Copy(strRevision, iBugFix + 1, 1),
      Application.Title]),
    strIDEPlugInDescription,
    bmSplashScreen,
    {$IFDEF DEBUG} True {$ELSE}  False {$ENDIF},
    Format(strSplashScreenBuild, [iMajor, iMinor, iBugfix, iBuild]),
    Format(strSKUBuild, [iMajor, iMinor, iBugfix, iBuild])
  );
  {$ENDIF RS110}
End;

(**

  This method removes the indexed about box entry from the RAD Studio IDE.

  @precon  None.
  @postcon The about box entry is removed from the IDE.

**)
Procedure RemoveAboutBoxEntry;

Begin
  If iAboutPlugin > iWizardFailState Then
    (BorlandIDEServices As IOTAAboutBoxServices).RemovePluginInfo(iAboutPlugin);
End;

End.
