unit Dabout;

{$MODE Delphi}

{-------------------------------------------------------------------}
{                    Unit:    Dabout.pas                            }
{                    Project: EPANET2W                              }
{                    Version: 2.0                                   }
{                    Date:    5/31/00                               }
{                             9/7/00                                }
{                             12/29/00                              }
{                             1/5/01                                }
{                             3/1/01                                }
{                             11/19/01                              }
{                             12/8/01                               }
{                             6/24/02                               }
{                    Author:  L. Rossman                            }
{                                                                   }
{   Form unit containing the "About" dialog box for EPANET2W.       }
{-------------------------------------------------------------------}

interface

uses {WinTypes, WinProcs,} Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, LResources;

type

  { TAboutBoxForm }

  TAboutBoxForm = class(TForm)
    Build1: TLabel;
    Label10: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Panel1: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    ProductName: TLabel;
    ProductName1: TLabel;
    ProgramIcon1: TImage;
    Version: TLabel;
    Label3: TLabel;
    Button1: TButton;
    Build: TLabel;
    Panel2: TPanel;
    ProgramIcon: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Version1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//var
//  AboutBoxForm: TAboutBoxForm;

implementation


procedure TAboutBoxForm.FormCreate(Sender: TObject);
begin
   //Build.Caption := 'Build 2.00.11';
end;

procedure TAboutBoxForm.Button1Click(Sender: TObject);
begin

end;

initialization
  {$i Dabout.lrs}
  {$i Dabout.lrs}

end.

