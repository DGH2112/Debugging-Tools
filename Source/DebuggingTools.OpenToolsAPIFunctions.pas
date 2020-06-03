(**
  
  This module contains a class which encapsulates custom Open Tools API functions to make it easier to
  work with the Open Tools API.

  @Author  David Hoyle
  @Version 1.001
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

**)
Unit DebuggingTools.OpenToolsAPIFunctions;

Interface

{$INCLUDE CompilerDefinitions.Inc}

Uses
  ToolsAPI;

Type
  (** A class to encapsulate the custom open tools API functions. **)
  TDDTOpenToolsAPIFunctions = Class
  Strict Private
  Strict Protected
    Class Function  EditorAsString(Const SourceEditor : IOTASourceEditor) : String;
    Class Function  ActiveSourceEditor : IOTASourceEditor;
    Class Function  IdentifierAtCursor(Const SourceEditor : IOTASourceEditor;
      Const EditPos : TOTAEditPos) : String; Overload;
    Class Function  SelectedText(Const SourceEditor : IOTASourceEditor) : String;
    Class Function  ProjectGroup: IOTAProjectGroup;
    Class Function  ActiveProject : IOTAProject;
    Class Function  ProjectModule(Const Project : IOTAProject) : IOTAModule;
  Public
    Class Function  IdentifierAtCursor : String; Overload;
    Class Function  SourceEditor(Const Module : IOTAModule) : IOTASourceEditor;
    Class Procedure CheckCodeSiteLogging;
    Class Procedure CheckDebuggingDCUs;
    Class Procedure CheckLibraryPath;
    Class Procedure OutputMsg(Const strMsg : String);
  End;

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF DEBUG}
  DCCStrs,
  System.SysUtils,
  System.Classes,
  System.RegularExpressions,
  System.Variants;

(**

  This method returns the active project in the IDE else returns Nil if there is
  no active project.

  @precon  None.
  @postcon Returns the active project in the IDE else returns Nil if there is
           no active project.

  @return  an IOTAProject

**)
Class Function TDDTOpenToolsAPIFunctions.ActiveProject : IOTAProject;

var
  G : IOTAProjectGroup;

Begin
  Result := Nil;
  G := ProjectGroup;
  If G <> Nil Then
    Result := G.ActiveProject;
End;

(**

  This method returns the Source Editor interface for the active source editor
  else returns nil.

  @precon  None.
  @postcon Returns the Source Editor interface for the active source editor
           else returns nil.

  @return  an IOTASourceEditor

**)
Class Function TDDTOpenToolsAPIFunctions.ActiveSourceEditor : IOTASourceEditor;

Var
  CM : IOTAModule;

Begin
  Result := Nil;
  If BorlandIDEServices = Nil Then
    Exit;
  CM := (BorlandIDEServices as IOTAModuleServices).CurrentModule;
  Result := SourceEditor(CM);
End;

(**

  This method checks the DPR or DPK file for CodeSiteLogging in the uses clause using regular
  expressions.

  @precon  None.
  @postcon A messages is output if CodeSiteLogging is not found between the Uses and the Begin of the
           project file.

**)
Class Procedure TDDTOpenToolsAPIFunctions.CheckCodeSiteLogging;

ResourceString
  strCSLNOTFOUND = 'CodeSiteLogging NOT FOUND in the project file.';

Const
  strUses                = '\bUses\b';
  strCodeSiteLoggingUses = '\bCodeSiteLogging\b';
  strBegin               = '\bBegin\b';

Var
  RegEx : TRegEx;
  strCode: String;
  SE: IOTASourceEditor;
  UsesMatch, CodeSiteLoggingMatch, BeginMatch: TMatch;

Begin
  SE := SourceEditor(ProjectModule(ActiveProject));
  If Assigned(SE) Then
    Begin
      strCode := EditorAsString(SE);
      RegEx := TRegEx.Create(strUses, [roIgnoreCase, roMultiLine, roCompiled]);
      UsesMatch := RegEx.Match(strCode);
      RegEx := TRegEx.Create(strCodeSiteLoggingUses, [roIgnoreCase, roMultiLine, roCompiled]);
      CodeSiteLoggingMatch := RegEx.Match(strCode);
      RegEx := TRegEx.Create(strBegin, [roIgnoreCase, roMultiLine, roCompiled]);
      BeginMatch := RegEx.Match(strCode);
      If Not(UsesMatch.Success And CodeSiteLoggingMatch.Success And BeginMatch.Success And
        (UsesMatch.Index < CodeSiteLoggingMatch.Index) And
        (CodeSiteLoggingMatch.Index < BeginMatch.Index)) Then
       OutputMsg(strCSLNOTFOUND);
    End;
End;

(**

  This method changes the active projects options to see if the Debugging DCUs is enabled. Outputs
  a message if they are not.

  @precon  None.
  @postcon Outputs a message if Debugging DCUs are not enabled.

**)
Class Procedure TDDTOpenToolsAPIFunctions.CheckDebuggingDCUs;

ResourceString
  strDebuggingDCUs = 'You need to build your project with debugging DCUs.';

Const
  strLinkdebugvcl = 'linkdebugvcl';

Var
  Options: TOTAOptionNameArray;
  iOp: Integer;
  V: Variant;
  AP: IOTAProject;

Begin
  AP := ActiveProject;
  If Assigned(AP) Then
    Begin
      Options := AP.ProjectOptions.GetOptionNames;
      For iOp := Low(options) To High(Options) Do
        If Pos(strLinkdebugvcl, LowerCase(Options[iOp].Name)) > 0 Then
          Begin
            V := ActiveProject.ProjectOptions.Values[Options[iOp].Name];
            If Not V Then
              OutputMsg(strDebuggingDCUs);
          End;
    End;
End;

(**

  This method checks that the CodeSiteLogging.dcu is on the project or IDEs search paths.

  @precon  None.
  @postcon Outputs a message if the CodeSiteLogging.dcu file is not found on the search paths.

**)
Class Procedure TDDTOpenToolsAPIFunctions.CheckLibraryPath;

ResourceString
  strCodeSiteLoggingNotFound = '''CodeSiteLogging.dcu'' not found in your library paths!';

Const
  strDCCLibraryPath = 'LibraryPath';
  strCodeSiteLoggingDcu = 'CodeSiteLogging.dcu';

Var
  slSearchLibrary: TStringList;
  POC: IOTAProjectOptionsConfigurations;
  S : IOTAServices;
  BDSMacros: TRegEx;
  M: TMatch;
  slMacros: TStringList;
  iMacro: Integer;

Begin
  slSearchLibrary := TStringList.Create;
  Try
    If Supports(ActiveProject.ProjectOptions, IOTAProjectOptionsConfigurations, POC) Then
      slSearchLibrary.Add(
        StringReplace(POC.ActiveConfiguration.Value[sUnitSearchPath], ';', #13#10, [rfReplaceAll]));
    If Supports(BorlandIDEServices, IOTAServices, S) Then
      //                                                                        s
      slSearchLibrary.Add(StringReplace(VarToStr(S.GetEnvironmentOptions.Values[strDCCLibraryPath]), ';',
        #13#10, [rfReplaceAll]));
    slMacros := TStringList.Create;
    Try
      BDSMacros := TRegEx.Create('\$\((\w+)\)', [roIgnoreCase, roMultiLine, roCompiled]);
      For M In BDSMacros.Matches(slSearchLibrary.Text) Do
        Begin
          If slMacros.IndexOfName(M.Groups.Item[1].Value) = -1 Then
            slMacros.Add(M.Groups.Item[1].Value + '=' + StringReplace(
              GetEnvironmentVariable(M.Groups.Item[1].Value), '\', '\\', [rfReplaceAll]));
        End;
      For iMacro := 0 To slMacros.Count - 1 Do
        Begin
          BDSMacros := TRegEx.Create('\$\(' + slMacros.Names[iMacro] + '\)',
            [roIgnoreCase, roMultiLine, roCompiled]);
          slSearchLibrary.Text := BDSMacros.Replace(slSearchLibrary.Text, slMacros.ValueFromIndex[iMacro]);
        End;
    Finally
      slMacros.Free;
    End;
    If Length(FileSearch(strCodeSiteLoggingDcu, StringReplace(slSearchLibrary.Text, #13#10, ';',
      [rfReplaceAll]))) = 0 Then
      OutputMsg(strCodeSiteLoggingNotFound);
  Finally
    slSearchLibrary.Free;
  End;
End;

(**

  This method returns the editor code as a string from the given source editor reference.

  @precon  SourceEditor must be a valid instance.
  @postcon returns the editor code as a string from the given source editor reference.

  @param   SourceEditor as an IOTASourceEditor as a constant
  @return  a String

**)
Class Function TDDTOpenToolsAPIFunctions.EditorAsString(Const SourceEditor : IOTASourceEditor) : String;

Const
  iBufferSize : Integer = 1024;

Var
  Reader : IOTAEditReader;
  iRead : Integer;
  iPosition : Integer;
  strBuffer : AnsiString;
  strTmp : AnsiString;

Begin
  Result := '';
  Reader := SourceEditor.CreateReader;
  Try
    iPosition := 0;
    Repeat
      SetLength(strBuffer, iBufferSize);
      iRead := Reader.GetText(iPosition, PAnsiChar(strBuffer), iBufferSize);
      SetLength(strBuffer, iRead);
      strTmp := strTmp + strBuffer;
      Inc(iPosition, iRead);
    Until iRead < iBufferSize;
    Result := UTF8ToUnicodeString(strTmp);
  Finally
    Reader := Nil;
  End;
End;

(**

  This method returns the identifier at the cursor position in the editor.

  @precon  SourceEditor must be a valid instance.
  @postcon Returns the identifier at the cursor position in the editor if found else returns null.

  @param   SourceEditor as an IOTASourceEditor as a constant
  @param   EditPos      as a TOTAEditPos as a constant
  @return  a String

**)
Class Function TDDTOpenToolsAPIFunctions.IdentifierAtCursor(Const SourceEditor : IOTASourceEditor;
  Const EditPos : TOTAEditPos) : String;

Const
  strValidIdentChars = ['a'..'z', 'A'..'Z', '_'];

Var
  slSrcCode : TStringList;
  iLine : Integer;
  iStart, iEnd : Integer;
  strLine : String;

Begin
  Result := '';
  slSrcCode := TStringList.Create;
  Try
    slSrcCode.Text := EditorAsString(SourceEditor);
    iLine := EditPos.Line - 1;
    If (iLine <= slSrcCode.Count - 1) And (EditPos.Col <= Length(slSrcCode[iLine])) Then
      Begin
        strLine := slSrcCode[iLine];
        iStart := EditPos.Col;
        // Search backwards for the start of a qualitied identifier
        While (iStart > 0) And CharInSet(strLine[iStart], strValidIdentChars + ['.']) Do
          Dec(iStart);
        Inc(iStart);
        iEnd := EditPos.Col;
        // Search forwards for the end of the current identifier
        While (iEnd < Length(strLine)) And CharInSet(strLine[iEnd], strValidIdentChars) Do
          Inc(iEnd);
        Result := Copy(strLine, iStart, iEnd - iStart);
      End;
  Finally
    slSrcCode.Free;
  End;
End;

(**

  This method returns the identifier at the cursor position in the passed module.

  @precon  Module must be a valid instance.
  @postcon The identifier at the module cursor position is returned if found.

  @return  a String

**)
Class Function TDDTOpenToolsAPIFunctions.IdentifierAtCursor : String;

Var
  SE : IOTASourceEditor;
  EditPos: TOTAEditPos;

Begin
  Result := '';
  SE := ActiveSourceEditor;
  EditPos := SE.EditViews[0].CursorPos;
  If Assigned(SE) Then
    Begin
      If SE.EditViews[0].CharPosToPos(SE.BlockStart) < SE.EditViews[0].CharPosToPos(SE.BlockAfter) Then
        Result := SelectedText(SE)
      Else
        Result := IdentifierAtCursor(SE, EditPos);
    End;
End;

(**

  This method outputs a tool message to the message view.

  @precon  None.
  @postcon A message is output the the message view.

  @param   strMsg as a String as a constant

**)
Class Procedure TDDTOpenToolsAPIFunctions.OutputMsg(Const strMsg : String);

Const
  strDebugWithCodeSite = 'DebugWithCodeSite';

Var
  ModS : IOTAModuleServices;
  MsgS : IOTAMessageServices;
  SE   : IOTASourceEditor;
  Ptr  : Pointer;

Begin
  If Supports(BorlandIDEServices, IOTAModuleServices, ModS) Then
    Begin
      SE := SourceEditor(ModS.CurrentModule);
      Ptr := Nil;
      If Supports(BorlandIDEServices, IOTAMessageServices, MsgS) Then
        Begin
          MsgS.AddToolMessage(
            ModS.CurrentModule.FileName,
            strMsg,
            strDebugWithCodeSite,
            SE.EditViews[0].CursorPos.Line,
            SE.EditViews[0].CursorPos.Col,
            Nil,
            Ptr
          );
          MsgS.ShowMessageView(Nil);
        End;
    End;
End;

(**

  This method returns the current project group reference or nil if there is no
  project group open.

  @precon  None.
  @postcon Returns the current project group reference or nil if there is no
           project group open.

  @return  an IOTAProjectGroup

**)
Class Function TDDTOpenToolsAPIFunctions.ProjectGroup: IOTAProjectGroup;

Var
  AModuleServices: IOTAModuleServices;
  AModule: IOTAModule;
  i: integer;
  AProjectGroup: IOTAProjectGroup;

Begin
  Result := Nil;
  AModuleServices := (BorlandIDEServices as IOTAModuleServices);
  For i := 0 To AModuleServices.ModuleCount - 1 Do
    Begin
      AModule := AModuleServices.Modules[i];
      If (AModule.QueryInterface(IOTAProjectGroup, AProjectGroup) = S_OK) Then
       Break;
    End;
  Result := AProjectGroup;
end;

(**

  This method returns the project module for the given project.

  @precon  Project must be a valid instance.
  @postcon Returns the project module for the given project.

  @param   Project as an IOTAProject as a constant
  @return  an IOTAModule

**)
Class Function TDDTOpenToolsAPIFunctions.ProjectModule(Const Project : IOTAProject) : IOTAModule;

Var
  AModuleServices: IOTAModuleServices;
  AModule: IOTAModule;
  i: integer;
  AProject: IOTAProject;

Begin
  Result := Nil;
  AModuleServices := (BorlandIDEServices as IOTAModuleServices);
  For i := 0 To AModuleServices.ModuleCount - 1 Do
    Begin
      AModule := AModuleServices.Modules[i];
      If (AModule.QueryInterface(IOTAProject, AProject) = S_OK) And
        (Project = AProject) Then
        Break;
    End;
  Result := AProject;
End;

(**

  This method returns the selected text in the editor.

  @precon  SourceEditor must be a valid instance.
  @postcon Returns the selected text in the editor.

  @param   SourceEditor as an IOTASourceEditor as a constant
  @return  a String

**)
Class Function TDDTOpenToolsAPIFunctions.SelectedText(Const SourceEditor : IOTASourceEditor) : String;

Var
  R: IOTAEditReader;
  iStart, iEnd : Integer;
  strAnsiBuffer : AnsiString;

Begin
  iStart := SourceEditor.EditViews[0].CharPosToPos(SourceEditor.BlockStart);
  iEnd := SourceEditor.EditViews[0].CharPosToPos(SourceEditor.BlockAfter);
  R := SourceEditor.CreateReader;
  SetLength(strAnsiBuffer, iEnd - iStart);
  R.GetText(
    iStart,
    PAnsiChar(strAnsiBuffer),
    iEnd - iStart
  );
  Result := String(strAnsiBuffer);
End;


(**

  This method returns the source code editor for the passed module.

  @precon  Module is the module for which a source ditor interface is required.
  @postcon Returns the source editor interface for the given module.

  @param   Module as an IOTAModule as a Constant
  @return  an IOTASourceEditor

**)
Class Function TDDTOpenToolsAPIFunctions.SourceEditor(Const Module : IOTAModule) : IOTASourceEditor;

Var
  iFileCount : Integer;
  i : Integer;

Begin
  Result := Nil;
  If Not Assigned(Module) Then
    Exit;
  iFileCount := Module.GetModuleFileCount;
  For i := 0 To iFileCount - 1 Do
    If Module.GetModuleFileEditor(i).QueryInterface(IOTASourceEditor, Result) = S_OK Then
      Break;
End;

End.
