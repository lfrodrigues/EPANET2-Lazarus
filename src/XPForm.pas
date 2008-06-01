unit XPForm;

{$MODE Delphi}

(***********************************************************************

  This unit contains a Printing Progress dialog form that accompanies
  the TPrinterControl component contained in the XPrinter unit.

***********************************************************************)
  
interface

uses
  LCLIntf, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, LResources;

type

  { TProgressForm }

  TProgressForm = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//var
//  ProgressForm: TProgressForm;

implementation


{ TProgressForm }

procedure TProgressForm.Button1Click(Sender: TObject);
begin

end;

initialization
  {$i XPForm.lrs}

end.
