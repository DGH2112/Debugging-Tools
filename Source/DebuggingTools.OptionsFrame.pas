(**

  This module contains a frame for editing the plug-ins options in the IDE options dialogue.

  @Author  David Hoyle
  @Version 1.303
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
Unit DebuggingTools.OptionsFrame;

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
  ComCtrls,
  DebuggingTools.Types,
  DebuggingTools.Interfaces,
  StdCtrls;

Type
  (** A frame to describe and edit the plug-ins options in the IDE. **)
  TframeDDTOptions = Class(TFrame, IDDTOptions)
    lvOptions: TListView;
    lblCodeSiteMsg: TLabel;
    edtCodeSiteMsg: TEdit;
    lblCodeSiteOptions: TLabel;
    procedure lvOptionsChange(Sender: TObject; Item: TListItem; Change: TItemChange);
  Strict Private
    FChecks : TDDTChecks;
  Strict Protected
    Procedure LoadOptions(Const CheckOptions : TDDTChecks; Const strCodeSiteMsg : String);
    Procedure SaveOptions(Var CheckOptions : TDDTChecks; Var strCodeSiteMsg : String);
  Public
    Constructor Create(AOwner: TComponent); Override;
  End;

Implementation

{$R *.dfm}


Const
  (** A constant array of strings to provide text for each check option. **)
  strDDTCheck: Array [Low(TDDTCheck) .. High(TDDTCheck)] Of String = (
    'Check that CodeSiteLogging is in the DPR/DPK unit list',
    'Check that the project has Debugging DCUs checked',
    'Check that CodeSite path is in the library',
    'Log the Result of the CodeSite breakpoint to the event log',
    'Break at the CodeSite breakpoint',
    'Edit the breakpoint after its added'
    );

{ TframeDDTOptions }

(**

  A constructor for the TframeDDTOptions class.

  @precon  None.
  @postcon Populates the list view with options.

  @nocheck MissingCONSTInParam

  @param   AOwner as a TComponent

**)
Constructor TframeDDTOptions.Create(AOwner: TComponent);

Var
  iOp: TDDTCheck;
  Item: TListItem;

Begin
  Inherited Create(AOwner);
  For iOp := Low(TDDTCheck) To High(TDDTCheck) Do
    Begin
      Item := lvOptions.Items.Add;
      Item.Caption := strDDTCheck[iOp];
    End;
End;

(**

  This method loads the given options into the list view.

  @precon  None.
  @postcon The checked status of the list view items is updated based on the given check set.

  @param   CheckOptions   as a TDDTChecks as a constant
  @param   strCodeSiteMsg as a String as a constant

**)
Procedure TframeDDTOptions.LoadOptions(Const CheckOptions : TDDTChecks; Const strCodeSiteMsg : String);

Var
  iOp: TDDTCheck;

Begin
  FChecks := CheckOptions;
  For iOp := Low(TDDTCheck) To High(TDDTCheck) Do
    lvOptions.Items[Ord(iOp)].Checked := iOp In CheckOptions;
  edtCodeSiteMsg.Text := strCodeSiteMsg;
End;

(**

  This is an on change event handler for the List View control.

  @precon  None.
  @postcon Updates the internal check list with state changes.

  @param   Sender as a TObject
  @param   Item   as a TListItem
  @param   Change as a TItemChange

**)
Procedure TframeDDTOptions.lvOptionsChange(Sender: TObject; Item: TListItem; Change: TItemChange);

Begin
  If Change = ctState Then
    If Item.Checked Then
      Include(FChecks, TDDTCheck(Item.Index))
    Else
      Exclude(FChecks, TDDTCheck(Item.Index));
End;

(**

  This method saves the options from the list view to the given options set.

  @precon  None.
  @postcon The given options set is updated with the selected options.

  @param   CheckOptions   as a TDDTChecks as a reference
  @param   strCodeSiteMsg as a String as a reference

**)
Procedure TframeDDTOptions.SaveOptions(Var CheckOptions : TDDTChecks; Var strCodeSiteMsg : String);

Begin
  CheckOptions := FChecks;
  strCodeSiteMsg := edtCodeSiteMsg.Text;
End;

End.
