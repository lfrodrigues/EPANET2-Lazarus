unit Fenergy;

{$MODE Delphi}

{-------------------------------------------------------------------}
{                    Unit:    Fenergy.pas                           }
{                    Project: EPANET2W                              }
{                    Version: 2.0                                   }
{                    Date:    5/29/00                               }
{                             12/29/00                              }
{                    Author:  L. Rossman                            }
{                                                                   }
{   MDI child form that displays an Energy Report summarizing       }
{   the energy usage for each pump in the network.                  }
{                                                                   }
{   The form contains a PageControl where Tabsheet1 displays        }
{   tabular statistics in a StringGrid while Tabsheet2 displays     }
{   a graphical comparison of a particular statistic in barchart    }
{   form. The choice of statistic to compare is selected from a     }
{   RadioGroup.                                                     }
{-------------------------------------------------------------------}

interface

uses
   LCLIntf, LCLType, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, ComCtrls, ExtCtrls, StdCtrls,
  Clipbrd, Xprinter, Uglobals, Uutils, TAGraph, TASeries, LResources, DynamicArray;


const
  ColHeading1: array[0..6] of String =
    (' ', 'Percent', 'Average', 'Kw-hr', 'Average', 'Peak', 'Cost');
  ColHeading2: array[0..6] of String =
    (' Pump', 'Utilization', 'Efficiency', ' ', 'Kwatts', 'Kwatts', '/day');
  TXT_DEMAND_CHARGE = 'Demand Charge';
  TXT_TOTAL_COST = 'Total Cost';
  TXT_perM3 = '/m3';
  TXT_perMGAL = '/Mgal';

type

  { TEnergyForm }

  TEnergyForm = class(TForm)
    Grid1: TDrawGrid;
    PageControl1: TPageControl;
    TAChart1: TChart;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    RadioGroup1: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure Grid1DrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect;
      aState: TGridDrawState);
    procedure RadioGroup1Click(Sender: TObject);

  private
    { Private declarations }
    ChartType: Integer;
    procedure CopyToBitmap(const Fname: String);
    procedure CopyToMetafile(const Fname: String);
    procedure CopyToString(const Fname: String);
    procedure RefreshTable;
    procedure RefreshChart;
    procedure SetAxisStyle(Axis: TChartAxis);

  public
    { Public declarations }
    procedure CopyTo;
    procedure Print(Destination: TDestination);
    procedure RefreshEnergyReport;
  end;

var
//  EnergyForm: TEnergyForm;
  TABarSeries1: TBarSeries;
  DataCells: array of array of String;

implementation


uses Dcopy, Fmain, Uoutput;

procedure TEnergyForm.FormCreate(Sender: TObject);
//------------------------------------------------
// Form's OnCreate handler.
//------------------------------------------------
begin
  TABarSeries1 := TBarSeries.Create(TAChart1);
  TAChart1.AddSerie(TABarSeries1);

// Set form's font size
  Uglobals.SetFont(self);

// Set dimensions of table's grid
  with Grid1 do
  begin

  // Adjust row heights to accomodate font. Notice use of
  // minus sign on Font.Height to conform to Delphi convention.
    RowHeights[0] := DefaultRowHeight + (-Font.Height);

  // Adjust width of grid's columns
    ColCount := 7;
    DefaultColWidth := 72;
    ColWidths[0] := 112;
  end;

// Set axis properties of chart
  TAChart1.BottomAxis.Title.Caption := 'Bomba';
  with TAChart1 do
  begin
    SetAxisStyle(BottomAxis);
    SetAxisStyle(LeftAxis);
  end;

  TAChart1.BottomAxis.Title.Caption := 'Bomba';

// Set initial page to display
  PageControl1.ActivePage := TabSheet1;
  RadioGroup1.ItemIndex := 2;
end;


procedure TEnergyForm.SetAxisStyle(Axis: TChartAxis);
//---------------------------------------------------
// Sets font style of a chart's axis
//---------------------------------------------------
begin
  with Axis do
  begin
    if BoldFonts then
      Title.Font.Style := Title.Font.Style + [fsBold]
    else
      Title.Font.Style := [];
      //TODO labels font in tachart
//    LabelsFont.Assign(Title.Font);
  end;
end;


procedure TEnergyForm.FormClose(Sender: TObject; var Action: TCloseAction);
//----------------------------------------
// Form's OnClose handler.
// Frees all memory associated with form.
//----------------------------------------
begin
  Action := caFree;
  TAChart1.Series.Clear;
  TABarSeries1.Free;
end;


procedure TEnergyForm.FormActivate(Sender: TObject);
//--------------------------------------------------
// Form's OnActivate handler.
// Disables Options speedbutton on Mainform.
//--------------------------------------------------
begin
  MainForm.TBOptions.Enabled := False;
  Grid1.Refresh;
end;

procedure TEnergyForm.Grid1DrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
//--------------------------------------------------------
// OnDrawCell handler for StringGrid1.
// Provides customized display of entries in Energy table.
//--------------------------------------------------------
var
  s : String;
begin
  with Grid1 do
  begin
  // Draw column headings in row 0
    if aRow = 0 then
    begin
      canvas.FillRect(aRect);

    //Use Win API DrawText function to enable word-wraping
      s := ColHeading1[aCol]+#13+ColHeading2[aCol];
     if aCol = 0 then
        TextOutAlign(Canvas, aRect, taCenter, s)
      else
        TextOutAlign(Canvas, aRect, taCenter, s);
    end
  // Draw cell in leftmost column
    else if aCol = 0 then
    begin
      if (gdSelected in aState) then
      begin
        Canvas.Brush.Color := Color;
        Canvas.Font.Color := clBlack;
      end;
      Canvas.FillRect(aRect);
      TextOutAlign(Canvas, aRect, taLeftJustify, DataCells[aCol,aRow]);
    end

  // Draw cell value for body of table
    else
    begin
      if (gdSelected in aState) then
      begin
        Canvas.Brush.Color := clInfoBk;
        Canvas.Font.Color := clBlack;
      end;
      Canvas.Brush.Color := clInfoBk;   //$0080FFFF;
      Canvas.FillRect(aRect);
      SetBkMode(Canvas.Handle,TRANSPARENT);
      TextOutAlign(Canvas, aRect, taRightJustify, DataCells[aCol,aRow]);
    end;
  end;
end;




procedure TEnergyForm.RadioGroup1Click(Sender: TObject);
//-------------------------------------------------------
// OnClick handler for RadioGroup1.
// Redraws chart with newly selected variable.
//-------------------------------------------------------
begin
  RefreshChart;
end;


procedure TEnergyForm.RefreshEnergyReport;
//-----------------------------------------------
// Refreshes report after a new analysis is made.
//-----------------------------------------------
begin
  RefreshTable;
  RefreshChart;
end;


procedure TEnergyForm.RefreshTable;
//---------------------------------------
// Refreshes table page of Energy Report.
//---------------------------------------
var
  i, j, k: Integer;
  x: array[0..5] of Single;
  Dcharge: Single;
  Csum: Single;

begin
// Get flow volume units of Kw-hr per unit of flow
// (Mil. gal. for US units, cubic meters for SI)
  if (UnitSystem = usSI) then
    ColHeading2[3] := TXT_perM3
  else
    ColHeading2[3] := TXT_perMGAL;

{*** Updated 12/29/00 ***}
  RadioGroup1.Items[2] := ColHeading1[3] + ColHeading2[3];

// Table has one row for each pump plus rows for
// Headings, Demand Charge & Total Cost
  Csum := 0;
  Grid1.RowCount := Network.Lists[PUMPS].Count + 3;

  SetLength(DataCells, Grid1.ColCount);
  for i := 0 to Length(DataCells)-1 do
    SetLength(DataCells[i], Grid1.RowCount);
    
// Examine each pump
  for j := 0 to Network.Lists[PUMPS].Count-1 do
  begin

  // Column 0 contains pump ID
    DataCells[0,j+1] := GetID(PUMPS,j);

  // If no energy usage results available then fill cells with N/A
    k := Link(PUMPS,j).Zindex;
    if (k < 0) then for i := 1 to 6 do
      DataCells[i,j+1] := NA

  // Otherwise retrieve energy results in array x
    else
    begin
      Uoutput.GetPumpEnergy(k,x,Dcharge);
      // Fill cells with string format of numerical values
        for i := 1 to 6 do
          DataCells[i,j+1] := FloatToStrF(x[i-1], ffFixed, 7, 2);
      // Accumulate total pumping cost
        Csum := Csum + x[5];
    end;
  end;

// Display total cost & demand charge
  with Grid1 do
  begin
    DataCells[0,RowCount-2] := TXT_TOTAL_COST;
    DataCells[0,RowCount-1] := TXT_DEMAND_CHARGE;
    for i := 1 to 5 do
    begin
      DataCells[i,RowCount-2] := '';
      DataCells[i,RowCount-1] := '';
    end;
    DataCells[6,RowCount-2] := FloatToStrF(Csum, ffFixed, 7, 2);
    DataCells[6,RowCount-1] := FloatToStrF(Dcharge, ffFixed, 7, 2);
    Row := 1;
  end;
  Grid1.Refresh;
end;


procedure TEnergyForm.RefreshChart;
//---------------------------------------
// Refreshes chart page of Energy Report.
//---------------------------------------
var
  r: Integer;
  y: Single;
  u: Single;

begin
// Determine which statistic to plot
  ChartType := RadioGroup1.ItemIndex + 1;
  TAChart1.Title.Text[0] := RadioGroup1.Items[ChartType-1];

// Add data to chart
  TABarSeries1.Clear;
  with TABarSeries1, Grid1 do
  begin
    for r := 1 to RowCount - 3 do
    begin

    //Add value to chart only if pump is utilized
      Uutils.GetSingle(DataCells[1,r],u);
      if u > 0 then
        if Uutils.GetSingle(DataCells[ChartType,r],y) then begin
          AddXY(r-1, y, DataCells[0,r],clRed); //FIXME
        end;
    end;
  end;
end;


procedure TEnergyForm.CopyTo;
//---------------------------------------------------
// Copies table or chart to file or to the Clipboard.
//---------------------------------------------------
begin
// Create the CopyTo dialog form
  with TCopyToForm.Create(self) do
  try

  // If table is showing then disable the graphic format choices
    if PageControl1.ActivePage = TabSheet1 then
    begin
      FormatGroup.ItemIndex := 2;
      FormatGroup.Enabled := False;
    end;

  // Show the dialog and retrieve name of file (DestFileName)
  // (If name is empty then graph is copied to the Clipboard)
    if ShowModal = mrOK then
    begin

    // Copy using selected format
      case FormatGroup.ItemIndex of
      0: CopyToBitmap(DestFileName);
      1: CopyToMetafile(DestFileName);
      2: CopyToString(DestFileName);
      end;
    end;
  finally
    Free;
  end;
end;


procedure TEnergyForm.CopyToBitmap(const Fname: String);
//-----------------------------------------------------
// Copies energy chart to file Fname (or to Clipboard)
// in bitmap format.
//-----------------------------------------------------
begin
  if Length(Fname) > 0 then
    TAChart1.SaveToBitmapFile(Fname)
  else
    TAChart1.CopyToClipboardBitmap;
end;


procedure TEnergyForm.CopyToMetafile(const Fname: String);
//-----------------------------------------------------
// Copies energy chart to file Fname (or to Clipboard)
// in enhanced metafile format.
//-----------------------------------------------------
begin
  ShowMessage('Not Implemented');
{TODO wont ever have metafile
  if Length(Fname) > 0 then
    Chart1.SaveToMetafileEnh(Fname)
  else
    Chart1.CopyToClipBoardMetaFile(True);
}
end;


procedure TEnergyForm.CopyToString(const Fname: String);
//-------------------------------------------------------
// Copies energy table to file Fname or to Clipboard.
//-------------------------------------------------------
var
  Slist: TStringList;
  C,R  : LongInt;
  S    : String;
begin
// Create a stringlist to hold each row of grid
  Slist := TStringList.Create;
  try
    with Grid1 do
    begin

    // Add title to stringlist
      Slist.Add(Network.Options.Title);
      Slist.Add(Caption);
      Slist.Add(' ');

    // Add column headings to stringlist
      S := Format('%-16s',[ColHeading1[0]]);
      for C := 1 to ColCount-1 do
        S := S + #9 + Format('%-16s',[ColHeading1[C]]);
      Slist.Add(S);
      S := Format('%-16s',[ColHeading2[0]]);
      for C := 1 to ColCount-1 do
        S := S + #9 + Format('%-16s',[ColHeading2[C]]);
      Slist.Add(S);

    // Add remaining rows to stringlist
      for R := 1 to RowCount-1 do
      begin

      // Build up tab-delimited string of entry in each column
        S := Format('%-16s',[DataCells[0,R]]);
        for C := 1 to ColCount-1 do
          S := S + #9 + Format('%-16s',[DataCells[C,R]]);

      // Add tab-delimited string to list
        Slist.Add(S);
      end;
    end;

  // Save stringlist to file if file name supplied
    if Length(Fname) > 0 then Slist.SaveToFile(Fname)

  // Otherwise place text of stringlist onto clipboard
    else Clipboard.SetTextBuf(PChar(Slist.Text));

// Free the stringlist.
  finally
    Slist.Free;
  end;
end;


procedure TEnergyForm.Print(Destination: TDestination);
//----------------------------------------------------------------
// Prints Energy Report to Destination using thePrinter object.
//----------------------------------------------------------------

var
  j,r,n   : Integer;
  Pwidth,
  Pheight : Single;
  T,W,L,H : Single;
  aPicture: TPicture;
begin
  aPicture := TPicture.Create;
  with MainForm.thePrinter, PageLayout do
  try
  // Initiate the print job
    BeginJob;
    SetDestination(Destination);
    SetFontInformation('Times New Roman',11,[]);

  // Get width & height of printable area
    Pwidth := GetPageWidth - LMargin - RMargin;
    Pheight := GetPageHeight - TMargin - BMargin;

  // Print window caption
    PrintCenter(Caption);
    NextLine;
    NextLine;

  // Print the report's table
    if PageControl1.ActivePage = TabSheet1 then with Grid1 do
    begin
      CreateTable(ColCount);
      W := Pwidth/ColCount;
      if (W > 1) then W := 1;
      L := LMargin + (Pwidth - ColCount*W)/2;
      for j := 1 to ColCount do
      begin
        SetColumnHeaderText(j,1,ColHeading1[j-1]);
        SetColumnHeaderText(j,2,ColHeading2[j-1]);
        SetColumnDimensions(j,L,W);
        SetColumnHeaderAlignment(j,jCenter);
        L := L + W;
      end;
      SetColumnHeaderAlignment(1,jLeft);
      SetTableStyle([sBorder, sVerticalGrid, sHorizontalGrid]);
      n := RowCount-3;
      BeginTable;
      for r := 1 to n do
      begin
        PrintColumnLeft(1,DataCells[0,r]);
        for j := 2 to ColCount do
           PrintColumnCenter(j,DataCells[j-1,r]);
        NextTableRow((r >= n));
      end;
      EndTable;
      SetTableStyle([sBorder, sHorizontalGrid]);
      for r := n+1 to n+2 do
      begin
        PrintColumnLeft(1,DataCells[0,r]);
        PrintColumnCenter(ColCount,DataCells[ColCount-1,r]);
        NextTableRow((r >= n+2));
      end;
      EndTable;
    end

  // Print the report's chart
    else
    begin
      Uutils.ChartToPicture(TAChart1, aPicture);
      Uutils.FitChartToPage(TAChart1, PWidth, PHeight, W, H);
      T := GetYPos;;
      L := LMargin + (Pwidth - W)/2;
      StretchGraphic(L, T, L+W, T+H, aPicture);
    end;
    EndJob;
  finally
    aPicture.Free;
  end;
end;

initialization
  {$i Fenergy.lrs}

end.
