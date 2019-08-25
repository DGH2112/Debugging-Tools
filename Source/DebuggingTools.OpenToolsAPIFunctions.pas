(**
  
  This module contains a class which encapsulates custom Open Tools API functions to make it easier to
  work with the Open Tools API.

  @Author  David Hoyle
  @Version 1.0
  @Date    25 Aug 2019
  
**)
Unit DebuggingTools.OpenToolsAPIFunctions;

Interface

Uses
  ToolsAPI;

Type
  (** A class to encapsulate the custom open tools API functions. **)
  TDDTOpenToolsAPIFunctions = Class
  Strict Private
  Strict Protected
  Public
    Class Function SourceEditor(Const Module : IOTAModule) : IOTASourceEditor;
  End;

Implementation

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
