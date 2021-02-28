{-----------------------------------------------------------------------------------------------------------------------
  # Unit ZPL2Barcodes #

  Unit for working with Zebra ZPL2 barcode commands.
  All measuring units and position information are measured in dots!
  For details on the ZPL2 commands please see the "ZPL2 Programming Guide" from Zebra.

  Author: TheDelphiCoder

-----------------------------------------------------------------------------------------------------------------------}

unit ZPL2Barcodes;

interface

uses
  Windows, SysUtils, Classes, Graphics, Math,
  ZPL2, zint, zint_render_bmp;

type
  /// <summary>
  ///  Base class for all ZPL2 Barcode items.
  /// </summary>
  TZPL2Barcode = class abstract(TZPL2TextLabelItem)
  strict protected
    function GetScale: single; virtual; abstract;

    procedure SetBitmapSize(Target_Bitmap, Source_Bitmap: TBitmap); virtual; abstract;

    /// <summary>
    ///  Abstract method for setting parameters of the "TZintBarcode" object, is called in template method
    ///  <see cref="GetBitmap"/>.
    /// </summary>
    procedure SetDrawingParams(ZintSymbol: TZintSymbol; RenderTarget: TZintRenderTargetBMP); virtual; abstract;

  public
    /// <summary>
    ///  Template method for all Barcode types, must NOT be overriden in subclasses!.
    /// </summary>
    procedure GetBitmap(Bitmap: TBitmap); override;

  end;

  /// <summary>
  ///  Base class for all ZPL2 1D Barcode items.
  /// </summary>
  TZPL2Barcode1D = class abstract(TZPL2Barcode)
  strict private
    /// <summary>
    ///  Height of the barcode item.
    /// </summary>
    FHeight: word1_32000;

    /// <summary>
    ///  Width of the narrow lines of the barcode item.
    /// </summary>
    FLinewidth: word1_32000;

    /// <summary>
    ///  Prints the content of the barcode item in plain text below the barcode itself.
    /// </summary>
    FPrintInterpretationLine: boolean;

    /// <summary>
    ///  The content is printed in plain text above the barcode, if
    ///  <see cref="TZPL2Barcode1D|FPrintInterpretationLine" /> equals <c>true</c>; this option only affects labels printed with a
    ///  ZPL2 printer.
    /// </summary>
    FPrintInterpretationLineAboveCode: boolean;

    procedure SetHeight(const Value: word1_32000);

    procedure SetLinewidth(const Value: word1_32000);

    procedure SetPrintInterpretationLine(const Value: boolean);

    procedure SetPrintInterpretationLineAboveCode(const Value: boolean);

  strict protected
    function GetScale: single; override;

    procedure SetBitmapSize(Target_Bitmap, Source_Bitmap: TBitmap); override;

    /// <summary>
    ///  Sets parameters for 1D barcodes, must be overriden by subclasses and called in the derived method.
    /// </summary>
    procedure SetDrawingParams(ZintSymbol: TZintSymbol; RenderTarget: TZintRenderTargetBMP); override;

  public
    /// <summary>
    ///  Returns the complete ZPL2 command of the item, including field origin and/or field separator and/or other
    ///  data, if necessary.
    /// </summary>
    function AsString: string; override;
    constructor Create(AOwner: TComponent); override;

  published
    /// <summary>
    ///  Property for the barcode height.
    /// </summary>
    property Height: word1_32000 read FHeight write SetHeight;

    /// <summary>
    ///  Property for the narrow line width of the barcode.
    /// </summary>
    property Linewidth: word1_32000 read FLinewidth write SetLinewidth;

    /// <summary>
    ///  Property for the intepretation line of the barcode.
    /// </summary>
    property PrintInterpretationLine: boolean read FPrintInterpretationLine write SetPrintInterpretationLine;

    /// <summary>
    ///  Property for the position of the barcode interpretation line.
    /// </summary>
    property PrintInterpretationLineAboveCode: boolean read FPrintInterpretationLineAboveCode write
      SetPrintInterpretationLineAboveCode;

  end;

  /// <summary>
  ///  Class for ZPL2 Barcode Code 128 item
  ///  <note type="warning">
  ///  Only Type B is supported
  ///  </note>
  /// </summary>
  TZPL2BarcodeCode128 = class(TZPL2Barcode1D)
  strict protected
    /// <summary>
    ///  Method for returning the ZPL2 command of the item.
    /// </summary>
    function GetCommand: string; override;

    /// <summary>
    ///  Sets parameters for Code128 barcode; inherited method MUST be called.
    /// </summary>
    procedure SetDrawingParams(ZintSymbol: TZintSymbol; RenderTarget: TZintRenderTargetBMP); override;

  public
    constructor Create(AOwner: TComponent); override;

  end;

  TZPL2BarcodeCode128Class = class of TZPL2BarcodeCode128;

  /// <summary>
  ///  Class for ZPL2 Barcode Code 39 item.
  /// </summary>
  TZPL2BarcodeCode39 = class(TZPL2Barcode1D)
  strict private
    /// <summary>
    ///  Switch for determining the useage of a checksum digit.
    /// </summary>
    FMod43CheckDigit: boolean;

    procedure SetMod43CheckDigit(const Value: boolean);

  strict protected
    /// <summary>
    ///  Method for returning the ZPL2 command of the item.
    /// </summary>
    function GetCommand: string; override;

    /// <summary>
    ///  Sets parameters for Code39 barcode; inherited method MUST be called.
    /// </summary>
    procedure SetDrawingParams(ZintSymbol: TZintSymbol; RenderTarget: TZintRenderTargetBMP); override;

  public
    constructor Create(AOwner: TComponent); override;

  published
    /// <summary>
    ///  Property for the Mod43CheckDigit switch.
    /// </summary>
    property Mod43CheckDigit: boolean read FMod43CheckDigit write SetMod43CheckDigit;

  end;

  TZPL2BarcodeCode39Class = class of TZPL2BarcodeCode39;

  /// <summary>
  ///  Class for ZPL2 Datamatrix item.
  /// </summary>
  TZPL2BarcodeDatamatrix = class(TZPL2Barcode)
  strict private
    /// <summary>
    ///  Size of each individual symbol element.
    /// </summary>
    FModulsize: word1_4095;

    /// <summary>
    ///  ECC level of the Datamatrix code, only ECC200 is used for Bitmap drawing.
    /// </summary>
    FQualityLevel: TZPL2QualityLevel;

    procedure SetModulsize(const Value: word1_4095);

    procedure SetQualityLevel(const Value: TZPL2QualityLevel);

  strict protected
    /// <summary>
    ///  Method for returning the ZPL2 command of the item.
    /// </summary>
    function GetCommand: string; override;

    function GetScale: single; override;

    procedure SetBitmapSize(Target_Bitmap, Source_Bitmap: TBitmap); override;

    /// <summary>
    ///  Sets parameters for Datamatrix code.
    /// </summary>
    procedure SetDrawingParams(Zint: TZintSymbol; RenderTarget: TZintRenderTargetBMP); override;

  public
    constructor Create(AOwner: TComponent); override;

    /// <summary>
    ///  Returns the complete ZPL2 command of the item, including field origin and/or field separator and/or other
    ///  data, if necessary.
    /// </summary>
    function AsString: string; override;

  published
    /// <summary>
    ///  Property for the symbol element size of the Datamatrix code.
    /// </summary>
    property Modulsize: word1_4095 read FModulsize write SetModulsize;

    /// <summary>
    ///  Property for the ECC quality level of the Datamatrix code.
    /// </summary>
    property QualityLevel: TZPL2QualityLevel read FQualityLevel write SetQualityLevel;
  end;

  TZPL2BarcodeDatamatrixClass = class of TZPL2BarcodeDatamatrix;

  /// <summary>
  ///  Class for ZPL2 QR-Code item.
  /// </summary>
  TZPL2BarcodeQR = class(TZPL2Barcode)
  strict private
    /// <summary>
    ///  Size of each individual symbol element.
    /// </summary>
    FMagnificationFactor: byte1_10;

    /// <summary>
    ///  error correction level of the QR code.
    /// </summary>
    FErrorCorrectionLevel: TZPL2ErrorCorrectionLevel;

    procedure SetErrorCorrectionLevel(const Value: TZPL2ErrorCorrectionLevel);

    procedure SetMagnificationFactor(const Value: byte1_10);

  strict protected
    /// <summary>
    ///  Method for returning the ZPL2 command of the item.
    /// </summary>
    function GetCommand: string; override;

    function GetScale: single; override;

    procedure SetBitmapSize(Target_Bitmap, Source_Bitmap: TBitmap); override;

    /// <summary>
    ///  Sets parameters for QR code.
    /// </summary>
    procedure SetDrawingParams(Zint: TZintSymbol; RenderTarget: TZintRenderTargetBMP); override;

  public
    constructor Create(AOwner: TComponent); override;

    /// <summary>
    ///  Returns the complete ZPL2 command of the item, including field origin and/or field separator and/or other
    ///  data, if necessary.
    /// </summary>
    function AsString: string; override;

  published
    /// <summary>
    ///  Property for the symbol element size of the QR code.
    /// </summary>
    property MagnificationFactor: byte1_10 read FMagnificationFactor write SetMagnificationFactor;

    /// <summary>
    ///  Property for the error correction level of the QR code.
    /// </summary>
    property ErrorCorrectionLevel: TZPL2ErrorCorrectionLevel read FErrorCorrectionLevel write SetErrorCorrectionLevel;

  end;

  TZPL2BarcodeQRClass = class of TZPL2BarcodeQR;

function CreateBarcodeCode128(const X, Y: word0_32000; const Text: string; const Height: word1_32000; const Linewidth:
  word1_32000 = 1; const PrintInterpretationLine: boolean = false; const PrintInterpretationLineAboveCode: boolean =
  false): TZPL2BarcodeCode128;

function CreateBarcodeCode39(const X, Y: word0_32000; const Text: string; const Height: word1_32000; const
  Mod43CheckDigit: boolean = false; const Linewidth: word1_32000 = 1; const PrintInterpretationLine: boolean = false;
  const PrintInterpretationLineAboveCode: boolean = false): TZPL2BarcodeCode39;

function CreateBarcodeDatamatrix(const X, Y: word0_32000; const Text: string; const Modulsize: word1_4095 = 3; const
  QualityLevel: TZPL2QualityLevel = ql_200): TZPL2BarcodeDatamatrix;

function CreateBarcodeQR(const X, Y: word0_32000; const Text: string; const MagnificationFactor: byte1_10 = 3; const
  ErrorCorrectionLevel: TZPL2ErrorCorrectionLevel = eclStandardLevel): TZPL2BarcodeQR;

implementation

uses
  zint_helper;

{$region 'Unit Methods'}

function CreateBarcodeCode128(const X, Y: word0_32000; const Text: string; const Height: word1_32000; const Linewidth:
  word1_32000; const PrintInterpretationLine: boolean; const PrintInterpretationLineAboveCode: boolean):
  TZPL2BarcodeCode128;
begin
  result := TZPL2BarcodeCode128.Create(nil);
  result.X := X;
  result.Y := Y;
  result.Text := Text;
  result.Height := Height;
  result.Linewidth := Linewidth;
  result.PrintInterpretationLine := PrintInterpretationLine;
  result.PrintInterpretationLineAboveCode := PrintInterpretationLineAboveCode;
end;

function CreateBarcodeCode39(const X, Y: word0_32000; const Text: string; const Height: word1_32000; const
  Mod43CheckDigit: boolean; const Linewidth: word1_32000; const PrintInterpretationLine: boolean; const
    PrintInterpretationLineAboveCode: boolean): TZPL2BarcodeCode39;
begin
  result := TZPL2BarcodeCode39.Create(nil);
  result.X := X;
  result.Y := Y;
  result.Text := Text;
  result.Height := Height;
  result.Mod43CheckDigit := Mod43CheckDigit;
  result.Linewidth := Linewidth;
  result.PrintInterpretationLine := PrintInterpretationLine;
  result.PrintInterpretationLineAboveCode := PrintInterpretationLineAboveCode;
end;

function CreateBarcodeDatamatrix(const X, Y: word0_32000; const Text: string; const Modulsize: word1_4095;
  const QualityLevel: TZPL2QualityLevel): TZPL2BarcodeDatamatrix;
begin
  result := TZPL2BarcodeDatamatrix.Create(nil);
  result.X := X;
  result.Y := Y;
  result.Text := Text;
  result.Modulsize := Modulsize;
  result.QualityLevel := QualityLevel;
end;

function CreateBarcodeQR(const X, Y: word0_32000; const Text: string; const MagnificationFactor: byte1_10; const
  ErrorCorrectionLevel: TZPL2ErrorCorrectionLevel): TZPL2BarcodeQR;
begin
  result := TZPL2BarcodeQR.Create(nil);
  result.X := X;
  result.Y := Y;
  result.Text := Text;
  result.MagnificationFactor := MagnificationFactor;
  result.ErrorCorrectionLevel := ErrorCorrectionLevel;
end;

type
  EBitmapError = class(Exception);

function RotateScanLine90(const angle: integer; const Bitmap: TBitmap): TBitmap;
const
  MaxPixelCount = 65536; // or some other arbitrarily large value
type
  TRGBArray    = array[0..MaxPixelCount - 1] of TRGBTriple;
  pRGBArray    = ^TRGBArray;

{ These four internal functions parallel the four cases in rotating a
  bitmap using the Pixels property.  See the RotatePixels example on
  the Image Processing page of efg's Computer Lab for an example of the
  use of the Pixels property (which is very slow). }

  /// <summary>
  ///  A Bitmap.Assign could be used for a simple copy.  A complete example using ScanLine is included here to help
  ///  explain the other three cases.
  /// </summary>
  function SimpleCopy: TBitmap;
  var
    i: integer;
    j: integer;
    rowIn: pRGBArray;
    rowOut: pRGBArray;
  begin
    result := TBitmap.Create;
    result.Width := Bitmap.Width;
    result.Height := Bitmap.Height;
    result.PixelFormat := Bitmap.PixelFormat; // only pf24bit for now

    // Out[i, j] = In[i, j]

    for j := 0 to Bitmap.Height - 1 do
    begin
      rowIn := Bitmap.ScanLine[j];
      rowOut := result.ScanLine[j];

      // Could optimize the following by using a function like CopyMemory
      // from the Windows unit.
      for i := 0 to Bitmap.Width - 1 do
      begin
        // Why does this crash with RowOut[i] := RowIn[i]?  Alignment?
        // Use this longer form as workaround.
        with rowOut[i] do
        begin
          rgbtRed := rowIn[i].rgbtRed;
          rgbtGreen := rowIn[i].rgbtGreen;
          rgbtBlue := rowIn[i].rgbtBlue;
        end
      end
    end
  end { SimpleCopy };

  function Rotate90DegreesCounterClockwise: TBitmap;
  var
    i: integer;
    j: integer;
    rowIn: pRGBArray;
  begin
    result := TBitmap.Create;
    result.Width := Bitmap.Height;
    result.Height := Bitmap.Width;
    result.PixelFormat := Bitmap.PixelFormat; // only pf24bit for now

    // Out[j, Right - i - 1] = In[i, j]
    for j := 0 to Bitmap.Height - 1 do
    begin
      rowIn := Bitmap.ScanLine[j];
      for i := 0 to Bitmap.Width - 1 do
        pRGBArray(result.ScanLine[Bitmap.Width - i - 1])[j] := rowIn[i]
    end
  end { Rotate90DegreesCounterClockwise };

  /// <summary>
  ///  Could use <see cref="Rotate90DegreesCounterClockwise"/> twice to get a <c>Rotate180DegreesCounterClockwise</c>.
  ///  Rotating 180 degrees is the same as a Flip and Reverse.
  /// </summary>
  function Rotate180DegreesCounterClockwise: TBitmap;
  var
    i: integer;
    j: integer;
    rowIn: pRGBArray;
    rowOut: pRGBArray;
  begin
    result := TBitmap.Create;
    result.Width := Bitmap.Width;
    result.Height := Bitmap.Height;
    result.PixelFormat := Bitmap.PixelFormat; // only pf24bit for now

    // Out[Right - i - 1, Bottom - j - 1] = In[i, j]
    for j := 0 to Bitmap.Height - 1 do
    begin
      rowIn := Bitmap.ScanLine[j];
      rowOut := result.ScanLine[Bitmap.Height - j - 1];

      for i := 0 to Bitmap.Width - 1 do
        rowOut[Bitmap.Width - i - 1] := rowIn[i]
    end
  end { Rotate180DegreesCounterClockwise };

  /// <summary>
  ///  Could use <see cref="Rotate90DegreesCounterClockwise"/> three times to get a Rotate270DegreesCounterClockwise.
  /// </summary>
  function Rotate270DegreesCounterClockwise: TBitmap;
  var
    i: integer;
    j: integer;
    rowIn: pRGBArray;
  begin
    result := TBitmap.Create;
    result.Width := Bitmap.Height;
    result.Height := Bitmap.Width;
    result.PixelFormat := Bitmap.PixelFormat; // only pf24bit for now

    // Out[Bottom - j - 1, i] = In[i, j]
    for j := 0 to Bitmap.Height - 1 do
    begin
      rowIn := Bitmap.ScanLine[j];

      for i := 0 to Bitmap.Width - 1 do
        pRGBArray(result.ScanLine[i])[Bitmap.Height - j - 1] := rowIn[i]
    end
  end { Rotate270DegreesCounterClockwise };

begin
  if Bitmap.PixelFormat <> pf24bit then
    raise EBitmapError.Create('Can Rotate90 only 24-bit bitmap');

  if (angle >= 0) and (angle mod 90 <> 0) then
    raise EBitmapError.Create('Rotate90:  Angle not positive multiple of 90 degrees');

  case (angle div 90) mod 4 of
    0: result := SimpleCopy;
    1: result := Rotate90DegreesCounterClockwise; // Anticlockwise for the Brits
    2: result := Rotate180DegreesCounterClockwise;
    3: result := Rotate270DegreesCounterClockwise
  else
    result := nil // avoid compiler warning
  end;
end { RotateScanLine90 };

{$endregion}

{$region 'TZPL2Barcode'}

procedure TZPL2Barcode.GetBitmap(Bitmap: TBitmap);
var
  bmp, bmp2: TBitmap;
  ZintSymbol: TZintSymbol;
  RenderTarget: TZintRenderTargetBMP;
begin
  ZintSymbol := TZintSymbol.Create(nil);
  RenderTarget := TZintRenderTargetBMP.Create(nil);
  bmp := TBitmap.Create;
  bmp2 := nil;

  try
    try
      //bmp.PixelFormat := Bitmap.PixelFormat;
      bmp.PixelFormat := pf24bit;

      RenderTarget.Bitmap := bmp;
      RenderTarget.RenderAdjustMode := ramInflate;

      SetDrawingParams(ZintSymbol, RenderTarget);

      ZintSymbol.primary := StrToArrayOfChar(Text);
      ZintSymbol.Encode(Text);

      RenderTarget.Render(ZintSymbol);

      case Rotation of
        zrROTATE_90_DEGREES: bmp2 := RotateScanLine90(90, bmp);
        zrROTATE_180_DEGREES: bmp2 := RotateScanLine90(180, bmp);
        zrROTATE_270_DEGREES: bmp2 := RotateScanLine90(270, bmp);
      else
        bmp2 := RotateScanLine90(0, bmp);
      end;

      SetBitmapSize(Bitmap, bmp2);

      StretchBlt(Bitmap.Canvas.Handle,
                 0, 0, Bitmap.Width, Bitmap.Height,
                 bmp2.Canvas.Handle,
                 0, 0, bmp2.Width, bmp2.Height,
                 SRCCOPY);
    finally
      RenderTarget.Free;
      ZintSymbol.Free;
      bmp.Free;
      bmp2.Free;
    end;
  except
    raise
  end;
end;

{$endregion}

{$region 'TZPL2Barcode1D' }

function TZPL2Barcode1D.AsString: string;
begin
  result := ZPL2_BY + IntToStr(FLinewidth) + GetFieldOrigin + GetCommand + GetFieldSeparator;
end;

constructor TZPL2Barcode1D.Create(AOwner: TComponent);
begin
  inherited;
  ShowHint := true;
  Height := 20;
  Linewidth := 2;
  PrintInterpretationLine := false;
  PrintInterpretationLineAboveCode := false;
end;

function TZPL2Barcode1D.GetScale: single;
begin
  result := FLinewidth / 1;
end;

procedure TZPL2Barcode1D.SetBitmapSize(Target_Bitmap, Source_Bitmap: TBitmap);
begin
  Target_Bitmap.SetSize(Round(Source_Bitmap.Width * GetScale), Source_Bitmap.Height);
end;

procedure TZPL2Barcode1D.SetDrawingParams(ZintSymbol: TZintSymbol; RenderTarget: TZintRenderTargetBMP);
begin
  RenderTarget.ShowText := FPrintInterpretationLine;
  RenderTarget.HeightDesired := Round(FHeight);

  if RenderTarget.ShowText then
  begin
    RenderTarget.HeightDesired := Round(RenderTarget.HeightDesired
                                      + RenderTarget.Font.Size * GetScale
                                      + RenderTarget.Whitespace.Bottom.Modules
                                      + RenderTarget.TextSpacing.Top.Modules);
  end;
end;

procedure TZPL2Barcode1D.SetHeight(const Value: word1_32000);
begin
  FHeight := Value;
  Invalidate;
end;

procedure TZPL2Barcode1D.SetLinewidth(const Value: word1_32000);
begin
  FLinewidth := Value;
  Invalidate;
end;

procedure TZPL2Barcode1D.SetPrintInterpretationLine(const Value: boolean);
begin
  FPrintInterpretationLine := Value;
  Invalidate;
end;

procedure TZPL2Barcode1D.SetPrintInterpretationLineAboveCode(const Value: boolean);
begin
  FPrintInterpretationLineAboveCode := Value;
  Invalidate;
end;

{$endregion}

{$region 'TZPL2BarcodeCode128' }

constructor TZPL2BarcodeCode128.Create(AOwner: TComponent);
begin
  inherited;
  Text := 'Barcode128';
end;

function TZPL2BarcodeCode128.GetCommand: string;
begin
  // The last parameter (UCC check digit) is set to "N" by default!
  result := Format(ZPL2_BC + '%s,%u,%s,%s,%s', [ZPL2RotationChar[Rotation], Height, ZPL2YesNoChar[PrintInterpretationLine], ZPL2YesNoChar[PrintInterpretationLineAboveCode], ZPL2YesNoChar[false]]) + FormatTextForLabel;
end;

procedure TZPL2BarcodeCode128.SetDrawingParams(ZintSymbol: TZintSymbol; RenderTarget: TZintRenderTargetBMP);
begin
  inherited;
  ZintSymbol.SymbolType := zsCODE128;
end;

{$endregion}

{$region 'TZPL2BarcodeCode39' }

constructor TZPL2BarcodeCode39.Create(AOwner: TComponent);
begin
  inherited;
  Text := 'Barcode39';
  Mod43CheckDigit := false;
end;

function TZPL2BarcodeCode39.GetCommand: string;
begin
  result := Format(ZPL2_B3 + '%s,%s,%u,%s,%s,%s', [ZPL2RotationChar[Rotation], ZPL2YesNoChar[FMod43CheckDigit], Height, ZPL2YesNoChar[PrintInterpretationLine], ZPL2YesNoChar[PrintInterpretationLineAboveCode], ZPL2YesNoChar[false]]) + FormatTextForLabel;
end;

procedure TZPL2BarcodeCode39.SetDrawingParams(ZintSymbol: TZintSymbol; RenderTarget: TZintRenderTargetBMP);
begin
  inherited;
  ZintSymbol.SymbolType := zsCODE39;
end;

procedure TZPL2BarcodeCode39.SetMod43CheckDigit(const Value: boolean);
begin
  FMod43CheckDigit := Value;
  Invalidate;
end;

{$endregion}

{$region 'TZPL2BarcodeDatamatrix' }

function TZPL2BarcodeDatamatrix.AsString: string;
begin
  result := GetFieldOrigin + GetCommand + GetFieldSeparator;
end;

constructor TZPL2BarcodeDatamatrix.Create(AOwner: TComponent);
begin
  inherited;
  Text := 'Datamatrix';
  ShowHint := true;
  Modulsize := 3;
  QualityLevel := ql_200;
end;

function TZPL2BarcodeDatamatrix.GetCommand: string;
begin
  result := Format(ZPL2_BX + '%s,%u,%s,,,,~', [ZPL2RotationChar[Rotation], FModulsize, IntToStr(Ord(FQualityLevel))]) + FormatTextForLabel;
end;

function TZPL2BarcodeDatamatrix.GetScale: single;
begin
  result := FModulsize;
end;

procedure TZPL2BarcodeDatamatrix.SetBitmapSize(Target_Bitmap, Source_Bitmap: TBitmap);
begin
  Target_Bitmap.SetSize(Round(Source_Bitmap.Width * GetScale), Round(Source_Bitmap.Height * GetScale));
end;

procedure TZPL2BarcodeDatamatrix.SetDrawingParams(Zint: TZintSymbol; RenderTarget: TZintRenderTargetBMP);
begin
  Zint.SymbolType := zsDATAMATRIX;
  Zint.DatamatrixOptions.ForceSquare := true;
  Zint.DatamatrixOptions.Size := dmsAuto;

  RenderTarget.ShowText := false;
end;

procedure TZPL2BarcodeDatamatrix.SetModulsize(const Value: word1_4095);
begin
  FModulsize := Value;
  Invalidate;
end;

procedure TZPL2BarcodeDatamatrix.SetQualityLevel(const Value: TZPL2QualityLevel);
begin
  FQualityLevel := Value;
  Invalidate;
end;

{$endregion}

{$region 'TZPL2BarcodeQR' }

function TZPL2BarcodeQR.AsString: string;
begin
  result := GetFieldOrigin + GetCommand + GetFieldSeparator;
end;

constructor TZPL2BarcodeQR.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Text := 'QR-Code';
  Rotation := zrNO_ROTATION;
  ShowHint := true;
  ErrorCorrectionLevel := eclHighDensityLevel;
  MagnificationFactor := 3;
end;

function TZPL2BarcodeQR.GetCommand: string;
const
  MODEL = 2;
begin
  result := Format(ZPL2_BQ + '%s,%u,%u', [ZPL2RotationChar[Rotation], MODEL, FMagnificationFactor]) + FormatTextForLabel;
  Insert(ZPL2ErrorCorrectionLevelChar[FErrorCorrectionLevel] + 'A,', result, Pos(ZPL2_FD, result) + Length(ZPL2_FD));
end;

function TZPL2BarcodeQR.GetScale: single;
begin
  result := FMagnificationFactor;
end;

procedure TZPL2BarcodeQR.SetBitmapSize(Target_Bitmap, Source_Bitmap: TBitmap);
begin
  Target_Bitmap.SetSize(Round(Source_Bitmap.Width * GetScale), Round(Source_Bitmap.Height * GetScale));
end;

procedure TZPL2BarcodeQR.SetDrawingParams(Zint: TZintSymbol; RenderTarget: TZintRenderTargetBMP);
begin
  Zint.SymbolType := zsQRCODE;
  Zint.QRCodeOptions.Size := qrsAuto;

  case FErrorCorrectionLevel of
    eclHighDensityLevel:          Zint.QRCodeOptions.ECCLevel := qreLevelL;
    eclStandardLevel:             Zint.QRCodeOptions.ECCLevel := qreLevelM;
    eclHighReliabilityLevel:      Zint.QRCodeOptions.ECCLevel := qreLevelQ;
    eclUltraHighReliabilityLevel: Zint.QRCodeOptions.ECCLevel := qreLevelH;
  end;

  RenderTarget.ShowText := false;
end;

procedure TZPL2BarcodeQR.SetErrorCorrectionLevel(const Value: TZPL2ErrorCorrectionLevel);
begin
  FErrorCorrectionLevel := Value;
  Invalidate;
end;

procedure TZPL2BarcodeQR.SetMagnificationFactor(const Value: byte1_10);
begin
  FMagnificationFactor := Value;
  Invalidate;
end;

{$endregion}

end.
