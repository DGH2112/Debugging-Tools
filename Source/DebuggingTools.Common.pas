(**

  This module contains some common resource strings and a procedure for setting the wizard /expert /
  plug-ins build information for the splash screen and about box.

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
Unit DebuggingTools.Common;

Interface

Uses
  ToolsAPI;

  Procedure BuildNumber(var iMajor, iMinor, iBugFix, iBuild : Integer);

{$IFNDEF _FIXINSIGHT_}
Resourcestring
  (** This resource string is used for the bug fix number in the splash screen and about box
      entries. **)
  strRevision = ' abcdefghijklmnopqrstuvwxyz';
  (** This resource string is used in the splash screen and about box entries. **)
  strSplashScreenName = 'DGH Debugging Tools %d.%d%s for %s';
  strIDEPlugInDescription = 'A RAD Studio IDE plug-in to added additional debugging tools.';
  (** This resource string is used in the splash screen and about box entries. **)
  strSplashScreenBuild = 'Freeware by David Hoyle (Build %d.%d.%d.%d)';

Const
  (** A constant to define the failed state for a notifier not installed. **)
  iWizardFailState = -1; //FI:O803
{$ENDIF}

Implementation

Uses
  SysUtils,
  Windows;

(**

  This procedure returns the build information for the OTA Plugin.

  @precon  None.
  @postcon the build information for the OTA plugin is returned.

  @param   iMajor  as an Integer as a reference
  @param   iMinor  as an Integer as a reference
  @param   iBugFix as an Integer as a reference
  @param   iBuild  as an Integer as a reference

**)
Procedure BuildNumber(var iMajor, iMinor, iBugFix, iBuild : Integer);

Const
  iRightShift = 16;
  iWordMask = $FFFF;

Var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
  strBuffer : Array[0..MAX_PATH] Of Char;

Begin
  { Build Number }
  GetModuleFilename(hInstance, strBuffer, MAX_PATH);
  VerInfoSize := GetFileVersionInfoSize(strBuffer, Dummy);
  If VerInfoSize <> 0 Then
    Begin
      GetMem(VerInfo, VerInfoSize);
      Try
        GetFileVersionInfo(strBuffer, 0, VerInfoSize, VerInfo);
        VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
        iMajor := VerValue^.dwFileVersionMS shr iRightShift;
        iMinor := VerValue^.dwFileVersionMS and iWordMask;
        iBugFix := VerValue^.dwFileVersionLS shr iRightShift;
        iBuild := VerValue^.dwFileVersionLS and iWordMask;
      Finally
        FreeMem(VerInfo, VerInfoSize);
      End;
    End;
End;

End.
