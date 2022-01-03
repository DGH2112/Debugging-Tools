(**

  This module contains a procedure to add a splash screen entry to the RAD Studio splash screen on
  start-up.

  @Author  David Hoyle
  @Version 1.375
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
Unit DebuggingTools.SplashScreen;

Interface

{$INCLUDE CompilerDefinitions.inc}

  Procedure AddSplashScreen;

Implementation

Uses
  ToolsAPI,
  SysUtils,
  {$IFDEF RS110}
  Graphics,
  {$ELSE}
  Windows,
  {$ENDIF RS110}
  Forms,
  DebuggingTools.Common;

(**

  This method installs an entry in the RAD Studio IDE splash screen.

  @precon  None.
  @postcon An entry is added to the splash screen for this plug-in.

**)
Procedure AddSplashScreen;

Const
  {$IFDEF D2007}
  strDDTSplashScreenBitMap = 'DDTSplashScreenBitMap24x24';
  {$ELSE}
  strDDTSplashScreenBitMap = 'DDTSplashScreenBitMap48x48';
  {$ENDIF}

Var
  iMajor : Integer;
  iMinor : Integer;
  iBugFix : Integer;
  iBuild : Integer;
  {$IFDEF RS110}
  SplashScreenBitMap : TBitMap;
  {$ELSE}
  bmSplashScreen : HBITMAP;
  {$ENDIF RS110}

Begin
  BuildNumber(iMajor, iMinor, iBugFix, iBuild);
  {$IFDEF RS110}
  SplashScreenBitMap := TBitmap.Create;
  Try
    SplashScreenBitMap.LoadFromResourceName(hInstance, strDDTSplashScreenBitMap);
    (SplashScreenServices As IOTASplashScreenServices).AddPluginBitmap(
      Format(strSplashScreenName, [iMajor, iMinor, Copy(strRevision, iBugFix + 1, 1),
        Application.Title]),
      [SplashScreenBitMap],
      {$IFDEF DEBUG} True {$ELSE}  False {$ENDIF},
      Format(strSplashScreenBuild, [iMajor, iMinor, iBugfix, iBuild]), ''
    );
  Finally
    SplashScreenBitMap.Free;
  End;
  {$ELSE}
  bmSplashScreen := LoadBitmap(hInstance, strDDTSplashScreenBitMap);
  (SplashScreenServices As IOTASplashScreenServices).AddPluginBitmap(
    Format(strSplashScreenName, [iMajor, iMinor, Copy(strRevision, iBugFix + 1, 1),
      Application.Title]),
    bmSplashScreen,
    {$IFDEF DEBUG} True {$ELSE}  False {$ENDIF},
    Format(strSplashScreenBuild, [iMajor, iMinor, iBugfix, iBuild]), ''
  );
  {$ENDIF RS110}
End;

End.
