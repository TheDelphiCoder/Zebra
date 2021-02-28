{-----------------------------------------------------------------------------------------------------------------------
  # Unit ZPL2Label #

  Unit for creating labels with the Zebra ZPL2 printer language.
  All measuring units and position information are measured in dots!
  For details on the ZPL2 commands please see the "ZPL2 Programming Guide" from Zebra.

  Author: TheDelphiCoder

-----------------------------------------------------------------------------------------------------------------------}

unit ZPL2Label;

interface

uses
  Windows, SysUtils, Classes, Graphics, Math, StrUtils, Jpeg,
  ZPL2, ZPL2Barcodes;

type
  /// <summary>
  ///  Class for parsing, creating and drawing ZPL2 labels.
  /// </summary>
  TZPL2Label = class sealed
  strict private
    FCFItem: TZPL2CFItem;

    /// <summary>
    ///  List of all items the label consists of
    /// </summary>
    FItemList: TZPL2LabelItemList;

    /// <summary>
    ///  International font character set of the label.
    /// </summary>
    FInternationalFont: TZPL2InternationalFont;

    /// <summary>
    ///  Print height for the label, necessary for reverse printing.
    /// </summary>
    /// <seealso cref="ZPL2Label|TZPL2Label.FLabelReversePrint" />
    FLabelHeight: word10_32000;

    /// <summary>
    ///  X-coordinate of the label home position.
    /// </summary>
    FLabelHome_X: word0_32000;

    /// <summary>
    ///  Y-coordinate of the label home position.
    /// </summary>
    FLabelHome_Y: word0_32000;

    /// <summary>
    ///  Reverses the printing of the label, <see cref="ZPL2Label|TZPL2Label.FLabelHeight"/> must be set to a suitable
    ///  value.
    /// </summary>
    FLabelReversePrint: boolean;

    /// <summary>
    ///  Clears the bitmap buffer of the printer.
    /// </summary>
    FMapClear: boolean;

    /// <summary>
    ///  Adjusts the darkness relative to the current darkness setting of the printer.
    /// </summary>
    FMediaDarkness: extended;

    /// <summary>
    ///  The type of media used to print labels (continuous or non-continuous media) for purposes of tracking.
    /// </summary>
    FMediaTracking: TZPL2MediaTracking;

    /// <summary>
    ///  The type of print media used in the printer (thermal transfer or direct thermal media).
    /// </summary>
    FMediaType: TZPL2MediaType;

    /// <summary>
    ///  If set, the printer ignores the value of
    ///  <see cref="ZPL2Label|ZPL2Label.PrintQuantityTillPauseAndCut" />.
    /// </summary>
    FOverridePauseCount: boolean;

    /// <summary>
    ///  Determines the action the printer takes after a label or a group of labels has been printed.
    /// </summary>
    FPrintMode: TZPL2PrintMode;

    /// <summary>
    ///  The number of copies of the label the printer has to print.
    /// </summary>
    FPrintQuantity: cardinal1_99999999;

    /// <summary>
    ///  The printer pauses after every group of labes has been printed.
    /// </summary>
    FPrintQuantityTillPauseAndCut: cardinal0_99999999;

    /// <summary>
    ///  The speed the printer uses for printing.
    /// </summary>
    FPrintSpeed: TZPL2Speed;

    /// <summary>
    ///  Prints the label rotated by 180 degrees.
    /// </summary>
    FPrintUpsideDown: boolean;

    /// <summary>
    ///  Defines the max print width for the printer.
    /// </summary>
    FPrintWidth: word;

    /// <summary>
    ///  The number of replicates of each serial number.
    /// </summary>
    FReplicatesCount: cardinal0_99999999;

    /// <summary>
    ///  Suppresses forward feed of media to tear-off position depending on the current print mode.
    /// </summary>
    FSuppressBackfeed: boolean;

    /// <summary>
    ///  Draws the label with all its items on the canvas.
    /// </summary>
    procedure Draw(canvas: TCanvas);

    /// <summary>
    ///  Check if the first list item is a valid graphic box for reverse printing, otherwise create a new one.
    /// </summary>
    function GetGraphicBoxForReversePrinting(out FreeItemAfterUse: boolean): TZPL2GraphicBox;

    /// <summary>
    ///  Inserting back the previously in "AsString" or "Draw" deleted graphic box item.
    /// </summary>
    procedure InsertBackGraphicBox(gb: TZPL2GraphicBox; const FreeItemAfterUse: boolean);

    /// <summary>
    ///  Setter method for the Items property.
    /// </summary>
    procedure SetItems(const Value: TZPL2LabelItemList);

    /// <summary>
    ///  Setter method for the MediaDarkness property, checks the range of the media darkness parameter.
    /// </summary>
    procedure SetMediaDarkness(AMediaDarkness: extended);

  public
    /// <summary>
    ///  Calls "Draw" to draw the label on the bitmap, it must have been created before.
    /// </summary>
    procedure GetBitmap(const ABitmap: TBitmap);

    /// <summary>
    ///  Returns the all the label settings and items as a ZPL2 command string which in turn e.g., can be send to a
    ///  printer.
    /// </summary>
    function AsString: string;

    /// <summary>
    ///  Deletes all items in the item list, does not affect any other label settings.
    /// </summary>
    procedure Clear;

    /// <summary>
    ///  Calls the parameterless constructor and <see cref="LoadFromFile"/> with the given filename.
    /// </summary>
    constructor Create(const FileName: string); overload;

    /// <summary>
    ///  Creates the item list and calls <see cref="Init"/>.
    /// </summary>
    constructor Create; overload;

    /// <summary>
    ///  Destroys the item list.
    /// </summary>
    destructor Destroy; override;

    /// <summary>
    ///  Calls method <see cref="Clear"/> and resets all settings to their default values.
    /// </summary>
    procedure Init;

    /// <summary>
    ///  Loads the given file and calls <see cref="Parse"/> with its content.
    /// </summary>
    procedure LoadFromFile(const FileName: string);

    /// <summary>
    ///  Calls <see cref="GetBitmap"/> and saves a bitmap file with the given name.
    /// </summary>
    procedure SaveAsBitmap(const FileName: string);

    /// <summary>
    ///  Calls <see cref="GetBitmap"/> and saves a JPEG file with the given name, optionally the second parameter can
    ///  be used to set the jpg quality level (<c>100</c> = best, <c>1</c> = lowest).
    /// </summary>
    procedure SaveAsJPG(const FileName: string; const Quality: TJPEGQualityRange = 100);

    /// <summary>
    ///  Calls <see cref="AsString"/> and saves the result to the given filename.
    /// </summary>
    procedure SaveToFile(const FileName: string);

    property CF: TZPL2CFItem read FCFItem;

    /// <summary>
    ///  Property for the international font.
    /// </summary>
    property InternationalFont: TZPL2InternationalFont read FInternationalFont write FInternationalFont;

    /// <summary>
    ///  Property for the item list.
    /// </summary>
    property Items: TZPL2LabelItemList read FItemList write SetItems;

    /// <summary>
    ///  Property for the label height.
    /// </summary>
    property LabelHeight: word10_32000 read FLabelHeight write FLabelHeight;

    /// <summary>
    ///  Property for the x-coordinate of the label home position.
    /// </summary>
    property LabelHome_X: word0_32000 read FLabelHome_X write FLabelHome_X;

    /// <summary>
    ///  Property for the y-coordinate of the label home position.
    /// </summary>
    property LabelHome_Y: word0_32000 read FLabelHome_Y write FLabelHome_Y;

    /// <summary>
    ///  Property for the reverse printing setting.
    /// </summary>
    property LabelReversePrint: boolean read FLabelReversePrint write FLabelReversePrint;

    /// <summary>
    ///  Property for the map clear option.
    /// </summary>
    property MapClear: boolean read FMapClear write FMapClear;

    /// <summary>
    ///  Property for the media darkness.
    /// </summary>
    property MediaDarkness: extended read FMediaDarkness write SetMediaDarkness;

    /// <summary>
    ///  Property for the media tracking type.
    /// </summary>
    property MediaTracking: TZPL2MediaTracking read FMediaTracking write FMediaTracking;

    /// <summary>
    ///  Property for the media type.
    /// </summary>
    property MediaType: TZPL2MediaType read FMediaType write FMediaType;

    /// <summary>
    ///  Property for the OverridePauseCount option.
    /// </summary>
    property OverridePauseCount: boolean read FOverridePauseCount write FOverridePauseCount;

    /// <summary>
    ///  Property for the print mode.
    /// </summary>
    property PrintMode: TZPL2PrintMode read FPrintMode write FPrintMode;

    /// <summary>
    ///  Property for the print quantity.
    /// </summary>
    property PrintQuantity: cardinal1_99999999 read FPrintQuantity write FPrintQuantity;

    /// <summary>
    ///  Property for the PrintQuantityTillPauseAndCut value.
    /// </summary>
    property PrintQuantityTillPauseAndCut: cardinal0_99999999 read FPrintQuantityTillPauseAndCut write
      FPrintQuantityTillPauseAndCut;

    /// <summary>
    ///  Property for the print speed.
    /// </summary>
    property PrintSpeed: TZPL2Speed read FPrintSpeed write FPrintSpeed;

    /// <summary>
    ///  Property for the print upsidedown option.
    /// </summary>
    property PrintUpsideDown: boolean read FPrintUpsideDown write FPrintUpsideDown;

    /// <summary>
    ///  Property for the print width.
    /// </summary>
    property PrintWidth: word read FPrintWidth write FPrintWidth;

    /// <summary>
    ///  Property for the replicates count value.
    /// </summary>
    property ReplicatesCount: cardinal0_99999999 read FReplicatesCount write FReplicatesCount;

    /// <summary>
    ///  Property for the suppress backfeed option.
    /// </summary>
    property SuppressBackfeed: boolean read FSuppressBackfeed write FSuppressBackfeed;
  end;


implementation

uses
  ZPL2Parser;

const
  /// <summary>
  ///  Default initial size for the bitmap containing the label data.
  /// </summary>
  DefaultBitmapSize = 1024;

  { Array constants for easy converting of enum or boolean values to Delphi or ZPL2 character values. }
  ZPL2MediaTrackingChar: array[TZPL2MediaTracking] of char = ('N', 'Y', 'M');
  ZPL2MediaTypeChar: array[TZPL2MediaType] of char = ('T', 'D');
  ZPL2PrintModeChar: array[TZPL2PrintMode] of char = (#0, 'T', 'P', 'R', 'A', 'C');
  ZPL2PrintOrientationChar: array[boolean] of char = ('N', 'I');
  ZPL2SpeedString: array[TZPL2Speed] of string = ('2', '3', '4', '5', '6', '8', '9', '10', '11', '12');

{$region 'Unit Methods'}

/// <summary>
///  Deletes excessive white margin from a bitmap.
/// </summary>
/// <param name="Bitmap">
///  White margins of the bitmap will be deleted .
/// </param>
procedure TrimRightAndBottomMarginOfBitmap(Bitmap: TBitmap);
var
  max_x, max_y: integer;
  i, x, y, width: integer;
  p: PByteArray;
  nextline: boolean;
begin
  max_x := 0;
  max_y := 0;

  if Bitmap.Width mod 8 > 0 then
    Bitmap.Width := Bitmap.Width + 8 - (Bitmap.Width mod 8);

  width := Bitmap.Width div 8;

  // determine the actual dimension of the bitmap (right and bottom margin only)
  for y := Bitmap.Height - 1 downto 0 do
  begin
    nextline := false;
    p := Bitmap.ScanLine[y];

    for x := width - 1 downto 0 do
    begin
      for i := 0 to 7 do
      begin
        if p^[x] and (1 shl i) = 0 then
        begin
          if max_x < ((x + 1) * 8) - i then
            max_x := ((x + 1) * 8) - i;

          if max_y = 0 then
            max_y := y + 1;

          nextline := true;
        end;

        if nextline then
          break;
      end;

      if nextline then
        break;
    end;
  end;

  if (max_x > 0) and (max_y > 0) then
  begin
    BitBlt(Bitmap.canvas.Handle, 0, 0, max_x, max_y, Bitmap.canvas.Handle, 0, 0, SRCCOPY);
    Bitmap.SetSize(max_x, max_y);
  end;
end;

{$endregion}

{$region 'TZPL2Label' }

function TZPL2Label.AsString: string;
var
  i: integer;
  list: TStrings;
  gb: TZPL2GraphicBox;
  free_gb: boolean;
begin
  gb := nil;
  free_gb := false;
  result := '';

  if FItemList.Count = 0 then
    exit;

  list := TStringList.Create;

  try
    list.Append(ZPL2_XA);
    list.Append(ZPL2_MC + ZPL2YesNoChar[FMapClear]);
    list.Append(ZPL2_XZ);
    list.Append('');

    list.Append(ZPL2_XA);


    // DefaultFont and character height, [PrintWidth], LabelHome
    list.Append(ZPL2_CF + Chr(Ord(zfD)) + ',24' +
                IfThen(FPrintWidth >= 2, ZPL2_PW + IntToStr(FPrintWidth), '') +
                ZPL2_LH + Format('%u,%u', [FLabelHome_X, FLabelHome_Y])
               );

    // InternationalFont, PrintSpeed, PrintRate, MediaTracking, MediaType, [PrintMode], MediaDarkness, PrintOrienation, [LabelReversePrint]
    list.Append(ZPL2_CI + IntToStr(Ord(FInternationalFont)) +
                ZPL2_PR + ZPL2SpeedString[FPrintSpeed] +
                ZPL2_MN + ZPL2MediaTrackingChar[FMediaTracking] +
                ZPL2_MT + ZPL2MediaTypeChar[FMediaType] +
                IfThen(FPrintMode <> pmPrinterDefault, ZPL2_MM + ZPL2PrintModeChar[FPrintMode], '') +
                ZPL2_MD + FloatToStrF(FMediaDarkness, ffFixed, 3, 1, GetLocaleFormatSettingsWithDotDecimalSeparator) +
                ZPL2_PO + ZPL2PrintOrientationChar[FPrintUpsideDown] +
                IfThen(FLabelReversePrint, ZPL2_LR + ZPL2YesNoChar[FLabelReversePrint], '')
                );

    list.Append(ZPL2_XZ);
    list.Append('');

    list.Append(ZPL2_XA);
    list.Append(ZPL2_LR + ZPL2YesNoChar[FLabelReversePrint]);

    if FLabelReversePrint = true then
    begin
      gb := GetGraphicBoxForReversePrinting(free_gb);
      list.Append(gb.AsString);
    end;

    // All items in the list
    for i := 0 to FItemList.Count - 1 do
    begin
      if FItemList[i].Printable then
        list.Append(FItemList[i].AsString);
    end;

    InsertBackGraphicBox(gb, free_gb);

    // Print Quantity
    list.Append(Format(ZPL2_PQ + '%u,%u,%u,%s', [FPrintQuantity, FPrintQuantityTillPauseAndCut, FReplicatesCount, ZPL2YesNoChar[FOverridePauseCount]]));

    if SuppressBackfeed then
      list.Append(ZPL2_XB);

    list.Append(ZPL2_XZ);

    result := list.Text;
  finally
    list.Free;

    if free_gb then
      gb.Free;
  end;
end;

procedure TZPL2Label.Clear;
begin
  FItemList.Clear;
end;

constructor TZPL2Label.Create;
begin
  inherited Create;
  FItemList := TZPL2LabelItemList.Create;
  FCFItem := TZPL2CFItem.Create(nil);
  Init;
end;

constructor TZPL2Label.Create(const FileName: string);
begin
  Create;
  LoadFromFile(FileName);
end;

destructor TZPL2Label.Destroy;
begin
  FCFItem.Free;
  FItemList.Free;
  inherited;
end;

procedure TZPL2Label.Draw(canvas: TCanvas);
var
  i: integer;
  bitmap: TBitmap;
  gb: TZPL2GraphicBox;
  free_gb: boolean;
begin
  gb := nil;
  free_gb := false;
  bitmap := TBitmap.Create;

  try
    bitmap.PixelFormat := pf1bit;
    bitmap.SetSize(DefaultBitmapSize, DefaultBitmapSize);
    bitmap.Canvas.Pen.Color := clWhite;
    bitmap.Canvas.FillRect(Rect(0, 0, bitmap.Width, bitmap.Height));

    if FLabelReversePrint = true then
    begin
      gb := GetGraphicBoxForReversePrinting(free_gb);
      gb.Draw(bitmap.Canvas, gb.X, gb.Y);
    end;

    // All items in the list
    for i := 0 to FItemList.Count - 1 do
    begin
      if FItemList[i] is TZPL2CFItem then
      begin
        CF.Font := TZPL2CFItem(FItemList[i]).Font;
        CF.Height := TZPL2CFItem(FItemList[i]).Height;
        CF.Width := TZPL2CFItem(FItemList[i]).Width;
        CF.Height_Empty := TZPL2CFItem(FItemList[i]).Height_Empty;
        CF.Width_Empty := TZPL2CFItem(FItemList[i]).Width_Empty;
      end;

      if FItemList[i].Printable then
        FItemList[i].Draw(bitmap.canvas, FItemList[i].X, FItemList[i].Y, FLabelReversePrint = true);
    end;

    InsertBackGraphicBox(gb, free_gb);

    // Copy bitmap image content to the canvas
    BitBlt(canvas.Handle, 0, 0, bitmap.Width, bitmap.Height, bitmap.Canvas.Handle, 0, 0, SRCCOPY);
  finally
    bitmap.Free;

    if free_gb then
      gb.Free;
  end;
end;

procedure TZPL2Label.GetBitmap(const ABitmap: TBitmap);
const
  BORDER = 2;
var
  bitmap: TBitmap;
begin
  try
    // Prepare the bitmap for drawing
    ABitmap.PixelFormat := pf1bit;
    ABitmap.SetSize(DefaultBitmapSize, DefaultBitmapSize);
    ABitmap.Canvas.Pen.Color := clWhite;
    ABitmap.Canvas.FillRect(Rect(0, 0, ABitmap.Width, ABitmap.Height));

    Draw(ABitmap.Canvas);
    TrimRightAndBottomMarginOfBitmap(ABitmap);

    if FLabelReversePrint = false then
    begin
      bitmap := TBitmap.Create;

      try
        bitmap.PixelFormat := pf1bit;
        // Add some pixels to the bitmap for a small border
        bitmap.SetSize(ABitmap.Width + BORDER * 2, ABitmap.Height + BORDER * 2);
        bitmap.Canvas.Pen.Color := clWhite;
        bitmap.Canvas.FillRect(Rect(0, 0, ABitmap.Width, ABitmap.Height));

        BitBlt(bitmap.canvas.Handle, BORDER, BORDER, ABitmap.Width, ABitmap.Height, ABitmap.Canvas.Handle, 0, 0, SRCCOPY);
        ABitmap.Assign(bitmap);
      finally
        bitmap.Free;
      end;
    end;
  except
    raise;
  end;
end;

function TZPL2Label.GetGraphicBoxForReversePrinting(out FreeItemAfterUse: boolean): TZPL2GraphicBox;
begin
  if (FItemList.Count > 0)
    and (FItemList[0] is TZPL2GraphicBox)
    and ((FItemList[0] as TZPL2GraphicBox).X = 0)
    and ((FItemList[0] as TZPL2GraphicBox).Y = 0)
  then
  begin
    // Delete the item from the list (it's inserted back after the iteration over all other items)
    result := FItemList[0] as TZPL2GraphicBox;
    FItemList.Extract(result);
    FreeItemAfterUse := false;
  end
  else
  begin
    if FLabelHeight <= 10 then
      raise EParserError.Create('Label height needs to be set for reverse printing!');

    if FPrintWidth < 2 then
      raise EParserError.Create('Print width needs to be set for reverse printing!');

    result := CreateGraphicBox(0, 0, FPrintWidth, FLabelHeight, Min(FPrintWidth, FLabelHeight));
    FreeItemAfterUse := true;
  end;
end;

procedure TZPL2Label.Init;
begin
  Clear;
  FInternationalFont := zifUSA1;
  FLabelHeight := 10;
  FLabelHome_X := 0;
  FLabelHome_Y := 0;
  FLabelReversePrint := false;
  FMapClear := true;
  FMediaDarkness := 0;
  FMediaTracking := mnNonContinuousWeb;
  FMediaType := mtThermalTransferMedia;
  FOverridePauseCount := false;
  FPrintMode := pmPrinterDefault;
  FPrintUpsideDown := false;
  FPrintQuantity := 1;
  FPrintQuantityTillPauseAndCut := 0;
  FPrintSpeed := sp50_8mm;
  FPrintWidth := 0;
  FReplicatesCount := 0;
  FSuppressBackfeed := false;
end;

procedure TZPL2Label.InsertBackGraphicBox(gb: TZPL2GraphicBox; const FreeItemAfterUse: boolean);
begin
  if (FLabelReversePrint = true) and not FreeItemAfterUse then
    FItemList.Insert(0, gb);
end;

procedure TZPL2Label.LoadFromFile(const FileName: string);
var
  list: TStrings;
begin
  list := TStringList.Create;

  try
    list.LoadFromFile(FileName);

    with TZPL2Parser.Create do
    begin
      try
        Parse(list.Text, self);
      finally
        Free;
      end;
    end;
  finally
    list.Free;
  end;
end;

procedure TZPL2Label.SaveAsBitmap(const FileName: string);
var
  bitmap: TBitmap;
begin
  bitmap := TBitmap.Create;

  try
    GetBitmap(bitmap);
    bitmap.SaveToFile(ChangeFileExt(FileName, '.bmp'));
  finally
    bitmap.Free;
  end;
end;

procedure TZPL2Label.SaveAsJPG(const FileName: string; const Quality: TJPEGQualityRange);
var
  bitmap: TBitmap;
begin
  bitmap := TBitmap.Create;

  with TJpegImage.Create do
  begin
    try
      CompressionQuality := Quality;
      GetBitmap(bitmap);
      Assign(bitmap);
      SaveToFile(ChangeFileExt(Filename, '.jpg'));
    finally
      Free;
      bitmap.Free;
    end;
  end;
end;

procedure TZPL2Label.SaveToFile(const FileName: string);
var
  list: TStrings;
begin
  list := TStringList.Create;

  try
    list.Text := AsString;
    list.SaveToFile(FileName);
  finally
    list.Free;
  end;
end;

procedure TZPL2Label.SetItems(const Value: TZPL2LabelItemList);
begin
  FItemList.Assign(Value);
end;

procedure TZPL2Label.SetMediaDarkness(AMediaDarkness: extended);
begin
  if not InRange(AMediaDarkness, -30.0, 30.0) then
    raise ERangeError.Create('Invalid media darkness value: ' + FloatToStrF(AMediaDarkness, ffFixed, 5, 3) + sLineBreak +
                             'Value has to be arranged in range of -30.0 to +30.0!');
end;

{$endregion}

end.
