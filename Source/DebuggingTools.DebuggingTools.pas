(**
  
  This module contains a class with class methods that perform the various debugging operations.

  @Author  David Hoyle
  @Version 1.0
  @Date    29 Aug 2019
  
**)
Unit DebuggingTools.DebuggingTools;

Interface

Uses
  DebuggingTools.Interfaces;

Type
  (** A clas encapsulating the debugging tools operations. **)
  TDDTDebuggingTools = Class
  Strict Private
  Strict Protected
    Class Procedure RunChecks(Const PluginOptions : IDDTPluginOptions);
  Public
    Class Procedure AddBreakpoint;
    Class Procedure AddCodeSiteBreakpoint(Const PluginOptions : IDDTPluginOptions);
  End;

Implementation

Uses
  ToolsAPI,
  System.SysUtils,
  DebuggingTools.Types,
  DebuggingTools.OpenToolsAPIFunctions;

(**

  This method adds a breakpoint to the current source file at the line of the cursor and displays the
  breakpoitn editor (if is already exists it is displayed).

  @precon  None.
  @postcon The Breakpoint editor is displayed.

**)
Class Procedure TDDTDebuggingTools.AddBreakpoint;

  (**

    This method attempts to find the source breakpoint corresponding to the given line and filename.

    @precon  DebuggingServices must be a valid instance.
    @postcon Returns the breakpoint interface reference if found else returns nil.

    @param   DebuggingServices as an IOTADebuggerServices as a constant
    @param   strFileName       as a String as a constant
    @param   iLine             as an Integer as a constant
    @return  an IOTABreakpoint

  **)
  Function FindExistingBreakpoint(Const DebuggingServices : IOTADebuggerServices;
    Const strFileName : String; Const iLine : Integer) : IOTABreakpoint;

  Var
    iBreakpoint: Integer;
  
  Begin
    Result := Nil;
    For iBreakpoint := 0 To DebuggingServices.SourceBkptCount - 1 Do
      If (DebuggingServices.SourceBkpts[iBreakpoint].LineNumber = iLine) Then
        If AnsiCompareFileName(DebuggingServices.SourceBkpts[iBreakpoint].FileName, strFileName) = 0 Then
          Begin
            Result := DebuggingServices.SourceBkpts[iBreakpoint];
            Break;
          End;
  End;

Var
  MS : IOTAModuleServices;
  Source: IOTASourceEditor;
  CursorPos: TOTAEditPos;
  DS : IOTADebuggerServices;
  Breakpoint : IOTABreakpoint;
  
Begin
  If Supports(BorlandIDEServices, IOTAModuleServices, MS) Then
    Begin
      Source := TDDTOpenToolsAPIFunctions.SourceEditor(MS.CurrentModule);
      CursorPos := Source.EditViews[0].CursorPos;
      If Supports(BorlandIDEServices, IOTADebuggerServices, DS) Then
        Begin
          Breakpoint := FindExistingBreakpoint(DS, Source.FileName, CursorPos.Line);
          If Not Assigned(Breakpoint) Then
            Breakpoint := DS.NewSourceBreakpoint(Source.FileName, CursorPos.Line, Nil);
          Breakpoint.Edit(True)
        End;
    End;
End;

(**

  This method adds an evaluation expression to a breakpoint using CodeSite to output messages rather than
  inserrt them into the code.

  @precon  PluginOptions must be a valid instance.
  @postcon The breakpoint is created containing the identifier at the cursor and optionally displayed.

  @param   PluginOptions as an IDDTPluginOptions as a constant

**)
Class Procedure TDDTDebuggingTools.AddCodeSiteBreakpoint(Const PluginOptions : IDDTPluginOptions);

ResourceString
  strThereNoIdentifierAtCursorPosition = 'There is no identifier at the cursor position!';

Const
  strStringFmt = '%s';

Var
  ES : IOTAEditorServices;
  DS : IOTADebuggerServices;
  CP: TOTAEditPos;
  BP: IOTABreakpoint;
  strIdentifierAtCursor: String;

Begin
  If Supports(BorlandIDEServices, IOTAEditorServices, ES) Then
    If Supports(BorlandIDEServices, IOTADebuggerServices, DS) Then
      Begin
        CP := ES.TopView.CursorPos;
        strIdentifierAtCursor := TDDTOpenToolsAPIFunctions.IdentifierAtCursor;
        If strIdentifierAtCursor <> '' Then
          Begin
            BP := DS.NewSourceBreakpoint(ES.TopBuffer.FileName, CP.Line, Nil);
            BP.EvalExpression := StringReplace(PluginOptions.CodeSiteTemplate, strStringFmt, strIdentifierAtCursor,
              [rfReplaceAll]);
            BP.LogResult := DDTcLogResult In PluginOptions.CheckOptions;
            BP.DoBreak := DDTcBreak In PluginOptions.CheckOptions;
            RunChecks(PluginOptions);
            If DDTcEditBreakpoint In PluginOptions.CheckOptions Then
              BP.Edit(True);
          End Else
            TDDTOpenToolsAPIFunctions.OutputMsg(strThereNoIdentifierAtCursorPosition);
      End;
End;

(**

  This method performs a number of checks (if enabled) on the configuration of the IDE to ensure that
  the CodeSite Breakpoint will work.

  @precon  PluginOptions must be a valid instance.
  @postcon The checks are performed, if enabled, and they output messages if there are issues.

  @param   PluginOptions as an IDDTPluginOptions as a constant

**)
Class Procedure TDDTDebuggingTools.RunChecks(Const PluginOptions : IDDTPluginOptions);

Begin
  If DDTcCodeSiteLogging In PluginOptions.CheckOptions Then
    TDDTOpenToolsAPIFunctions.CheckCodeSiteLogging;
  If DDTcDebuggingDCUs In PluginOptions.CheckOptions Then
    TDDTOpenToolsAPIFunctions.CheckDebuggingDCUs;
  If DDTcLibraryPath In PluginOptions.CheckOptions Then
    TDDTOpenToolsAPIFunctions.CheckLibraryPath;
End;

End.
