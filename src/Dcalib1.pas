unit Dcalib1;

{$MODE Delphi}

{-------------------------------------------------------------------}
{                    Unit:    Dcalib1.pas                           }
{                    Project: EPANET2W                              }
{                    Version: 2.0                                   }
{                    Date:    5/29/00                               }
{                    Author:  L. Rossman                            }
{                                                                   }
{   Form unit containing a dialog form that obtains names of        }
{   calibration data files for different measurement variables.     }
{-------------------------------------------------------------------}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, ExtCtrls, StdCtrls, Buttons, Uglobals, LResources;

const
  TXT_PARAMETER = 'Parameter';
  TXT_NAME_OF_FILE = 'Name of Calibration File';
  TXT_SELECT_FILE = 'Select a Calibration File';
  TXT_FILE_FILTER = 'Data files (*.DAT)|*.DAT|All files|*.*';

type
  TCalibDataForm = class(TForm)
    StringGrid1: TStringGrid;
    BtnOK: TButton;
    BtnCancel: TButton;
    BtnHelp: TButton;
    BtnBrowse: TSpeedButton;
    BtnEdit: TSpeedButton;
    Bevel1: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnBrowseClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure BtnHelpClick(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//var
//  CalibDataForm: TCalibDataForm;

implementation

uses Fmain;


var
  Nlinkvars: Integer;
  Nnodevars: Integer;

procedure TCalibDataForm.FormCreate(Sender: TObject);
//-------------------------------------------------------
// OnCreate handler. Loads current calibration file names
// into the form's grid control.
//-------------------------------------------------------
var
  i,j: Integer;

begin
// Set font size and style
  Uglobals.SetFont(self);

// Get number of node and link variables that can have calib. data
  Nnodevars := High(NodeCalibData) - Low(NodeCalibData) + 1;
  Nlinkvars := High(LinkCalibData) - Low(LinkCalibData) + 1;

// Initialize the grid control
  with StringGrid1 do
  begin
    RowCount := Nnodevars + Nlinkvars;
    ColWidths[1] := ClientWidth - ColWidths[0];
    //Height := (DefaultRowHeight+1)*(RowCount) + 1;
    DefaultRowHeight := Height div RowCount - 1;
    RowHeights[0] := RowHeights[0] + RowCount - 2; //put the extra pixel on header
    Cells[0,0] := TXT_PARAMETER;
    Cells[1,0] := TXT_NAME_OF_FILE;
    for i := 1 to Nnodevars do
    begin
      j := Low(NodeCalibData) + i - 1;
      Cells[0,i] := NodeVariable[j].Name;
      Cells[1,i] := NodeCalibData[j].FileName;
    end;
    for i := 1 to Nlinkvars-1 do  //TODO: one var doesn't appear iven in Delphi why?
    begin                       //so i put -1 so we don't get error in tstringgrid
      j := Low(LinkCalibData) + i - 1;
      Cells[0,Nnodevars+i] := LinkVariable[j].Name;
      Cells[1,Nnodevars+i] := LinkCalibData[j].FileName;
    end;
  end;
end;

procedure TCalibDataForm.FormShow(Sender: TObject);
//------------------------------------------------------------
// OnShow handler for form. Makes the grid the active control.
//------------------------------------------------------------
begin
  StringGrid1Click(Sender);
end;

procedure TCalibDataForm.BtnBrowseClick(Sender: TObject);
//------------------------------------------------------
// OnClick handler for "Browse" button.
// Launches an Open File common dialog box.
//------------------------------------------------------
begin
  with MainForm.OpenDialog do
  begin
    Title := TXT_SELECT_FILE;
    Filter := TXT_FILE_FILTER;
    if Execute then with StringGrid1 do
      Cells[Col,Row] := Filename;
  end;
end;

procedure TCalibDataForm.BtnEditClick(Sender: TObject);
//----------------------------------------------------
// OnClick handler for "Edit" button.
// Launches editor for file name
// in current cell of grid control.
//-----------------------------------------------------
var
  fname: String;
  CmdLine: String;

begin
  with StringGrid1 do
    fname := Cells[1,Row];
  if Length(fname) > 0 then
  begin
  {$IFDEF windows}
    SysUtils.ExecuteProcess('Notepad', fname);
  {$ENDIF}
  {$IFDEF linux}
    try
      SysUtils.ExecuteProcess('gedit', fname);
    except
      try
        SysUtils.ExecuteProcess('kedit', fname);
      except
        try
          SysUtils.ExecuteProcess('emacs', fname);
       except
          try
            SysUtils.ExecuteProcess('gvim', fname);
          except
          end;
        end;
      end;
    end;
  {$ENDIF}
  {$IFDEF macos}
    ShowMessage('Please change Dcalib1 and compile');
  {$ENDIF}
  end;
end;

procedure TCalibDataForm.StringGrid1Click(Sender: TObject);
//---------------------------------------------------------
// OnClick handler for grid control.
// Puts grid in editing mode.
//---------------------------------------------------------
begin
  PostMessage(StringGrid1.Handle, LM_KeyDown, VK_F2, 0);
end;

procedure TCalibDataForm.BtnOKClick(Sender: TObject);
//---------------------------------------------------
// OnClick handler for "OK" button.
// Updates names of calibration files in database
// with the entries in the grid control.
//---------------------------------------------------
var
  i,j: Integer;
  s  : String;

begin
  for i := 1 to Nnodevars do
  begin
    j := Low(NodeCalibData) + i - 1;
    s := Trim(StringGrid1.Cells[1,i]);
    if (NodeCalibData[j].FileName <> s) then
    begin
      NodeCalibData[j].FileName := s;
      NodeCalibData[j].MeasError := DefMeasError;
      HasChanged := True;
    end;
  end;
  for i := 1 to Nlinkvars - 1 do  //TODO: one var doesn't appear iven in Delphi why?
  begin                       //so i put -1 so we don't get error in tstringgrid
    j := Low(LinkCalibData) + i - 1;
    s := Trim(StringGrid1.Cells[1,Nnodevars+i]);
    if (LinkCalibData[j].FileName <> s) then
    begin
      LinkCalibData[j].FileName := s;
      LinkCalibData[j].MeasError := DefMeasError;
      HasChanged := True;
    end;
  end;
end;

procedure TCalibDataForm.BtnHelpClick(Sender: TObject);
begin
  Application.HelpContext(178);
end;

initialization
  {$i Dcalib1.lrs}

end.
