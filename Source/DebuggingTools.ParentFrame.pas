(**

  This modulel contains a frame for the root node of the BADI Options frame in the IDE.

  @Author  David Hoyle
  @Version 1.171
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
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

**)
Unit DebuggingTools.ParentFrame;

Interface

Uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls;

Type
  (** A class to represent the options frame. **)
  TfmDDTParentFrame = Class(TFrame)
    lblBADI: TLabel;
    lblAuthor: TLabel;
    lblBuild: TLabel;
    lblPleaseSelect: TLabel;
    lblBuildDate: TLabel;
    lblInformation: TMemo;
  Strict Private
  Strict Protected
  Public
    Constructor Create(AOwner : TComponent); Override;
  End;

Implementation

{$R *.dfm}

Uses
  DebuggingTools.Common;

(**

  This method intialises the frame with build information.

  @precon  None.
  @postcon The frame is initialised.

  @nocheck MissingCONSTInParam

  @param   AOwner as a TComponent

**)
Constructor TfmDDTParentFrame.Create(AOwner: TComponent);

ResourceString
  strAuthor = 'Author: David Hoyle (c)  2020 GNU GPL 3';
  strBrowseAndDocIt = 'DGH Debugging Tools %d.%d%s';
  {$IFDEF DEBUG}
  strDEBUGBuild = 'DEBUG Build %d.%d.%d.%d';
  {$ELSE}
  strBuild = 'Build %d.%d.%d.%d';
  {$ENDIF}
  strBuildDateFmt = 'ddd dd/mmm/yyyy hh:nn';
  strBuildDate = 'Build Date: %s';
  strInformation =
    'DGH Debugging Tools is a RAD Studio plug-in to provide additional functionality in the RAD ' +
    'Studio IDE when debugging.'#13#10 +
    ''#13#10 +
    'Copyright (C) 2020 David Hoyle '#13#10 +
    '(https://github.com/DGH2112/Debugging-Tools/)'#13#10 +
    ''#13#10 +
    'This program is free software: you can redistribute it and/or modify it under the terms of the ' +
    'GNU General Public License as published by the Free Software Foundation, either version 3 of ' +
    'the License, or (at your option) any later version.'#13#10 +
    ''#13#10 +
    'This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; ' +
    'without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See ' +
    'the GNU General Public License for more details.'#13#10 +
    ''#13#10 +
    'You should have received a copy of the GNU General Public License along with this program.  If ' +
    'not, see <https://www.gnu.org/licenses/>.';

Const
  strBugFix = ' abcdefghijklmnopqrstuvwxyz';

Var
  iMajor, iMinor, iBugFix, iBuild : Integer;
  dtDate : TDateTime;
  strModuleName : String;
  iSize : Integer;

Begin
  Inherited Create(AOwner);
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'LoadSettings', tmoTiming);{$ENDIF}
  BuildNumber(iMajor, iMinor, iBugFix, iBuild);
  lblAuthor.Caption := strAuthor;
  lblBADI.Caption := Format(strBrowseAndDocIt, [
    iMajor,
    iMinor,
    strBugFix[Succ(iBugFix)]
  ]);
  {$IFDEF DEBUG}
  lblBuild.Caption := Format(strDEBUGBuild, [iMajor, iMinor, iBugFix, iBuild]);
  lblBuild.Font.Color := clRed;
  {$ELSE}
  lblBuild.Caption := Format(strBuild, [iMajor, iMinor, iBugFix, iBuild]);
  {$ENDIF}
  SetLength(strModuleName, MAX_PATH);
  iSize := GetModuleFileName(hInstance, PChar(strModuleName), MAX_PATH);
  SetLength(strModuleName, iSize);
  FileAge(strModuleName, dtDate);
  lblBuildDate.Caption := Format(strBuildDate, [FormatDateTime(strBuildDateFmt, dtDate)]);
  lblInformation.Lines.Text := strInformation;
  {$IFDEF EUREKALOG}
  lblEurekaLog.Caption := Format(strEurekaLogStatus, [
    BoolToStr(IsEurekaLogInstalled, True),
    BoolToStr(IsEurekaLogActive, True)
  ]);
  lblEurekaLog.Font.Color := clGreen;
  {$ELSE}
  {$ENDIF}
End;

End.

