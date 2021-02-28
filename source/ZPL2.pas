{-----------------------------------------------------------------------------------------------------------------------
  # Unit ZPL2 #

  Unit for working with Zebra ZPL2 graphic and text commands.
  All measuring units and position information are measured in dots!
  For details on the ZPL2 commands please see the "ZPL2 Programming Guide" from Zebra.

  Author: TheDelphiCoder

-----------------------------------------------------------------------------------------------------------------------}

unit ZPL2;

interface

uses
  Windows, SysUtils, Classes, Controls, Graphics, Types, Contnrs, Math, Jpeg, StrUtils;

type
  byte0_8 = 0..8;
  byte1_10 = 1..10;
  cardinal0_99999999 = 0..99999999;
  cardinal1_99999999 = 1..99999999;
  word1_4095 = 1..4095;
  word3_4095 = 3..4095;
  word0_32000 = 0..32000;
  word1_32000 = 1..32000;
  word3_32000 = 3..32000;
  word10_32000 = 10..32000;

  /// <summary>
  ///  Enumeration of ZPL error correction levels for QR codes.
  /// </summary>
  TZPL2ErrorCorrectionLevel =
  (
    eclHighDensityLevel,
    eclStandardLevel,
    eclHighReliabilityLevel,
    eclUltraHighReliabilityLevel
  );

  /// <summary>
  ///  Enumeration of ZPL2 font types.
  /// </summary>
  TZPL2Font =
  (
    zfTRIUMVIRATE = $30,
    zfFONT1,
    zfFONT2,
    zfFONT3,
    zfFONT4,
    zfFONT5,
    zfFONT6,
    zfFONT7,
    zfFONT8,
    zfFONT9,
    zfA = 65,
    zfB,
    zfCUSTOM_C,
    zfD,
    zfOCR_B,
    zfF,
    zfG,
    zfOCR_A,
    zfCUSTOM_I,
    zfCUSTOM_J,
    zfCUSTOM_K,
    zfCUSTOM_L,
    zfCUSTOM_M,
    zfCUSTOM_N,
    zfCUSTOM_O,
    zfCUSTOM_P,
    zfCUSTOM_Q,
    zfCUSTOM_R,
    zfCUSTOM_S,
    zfCUSTOM_T,
    zfCUSTOM_U,
    zfCUSTOM_V,
    zfCUSTOM_W,
    zfCUSTOM_X,
    zfCUSTOM_Y,
    zfCUSTOM_Z
  );

  /// <summary>
  ///  Enumeration of ZPL2 international font character sets.
  /// </summary>
  TZPL2InternationalFont =
  (
    zifUSA1 = 0,
    zifUSA2,
    zifUK,
    zifHolland,
    zifDenmark_Norway,
    zifSweden_Finland,
    zifGermany,
    zifFrance1,
    zifFrance2,
    zifItaly,
    zifSpain,
    zifMiscellaneous,
    zifJapan,
    zifIBM_CodePage_850,
    zif16_Bit_Unicode_Encoded_Scalable_Fonts,
    zifShift_JIS_for_scalable_Japanese_Fonts,
    zifEUC_Kanji_for_scalable_Fonts,
    zifUnicode,
    ziReserved1,
    ziReserved2,
    ziReserved3,
    ziReserved4,
    ziReserved5,
    ziReserved6,
    zif8_Bit_access_to_Unicode_encoded_fonts,
    ziReserved7,
    zifAsian_fonts_with_ASCII_transparency
  );

  /// <summary>
  ///  Enumeration of ZPL2 line colors.
  /// </summary>
  TZPL2LineColor =
  (
    lcBlack,
    lcWhite
  );

  /// <summary>
  ///  Enumeration of ZPL2 line orientations.
  /// </summary>
  TZPL2LineOrientation =
  (
    loRightLeaning,
    loLeftLeaning
  );

  /// <summary>
  ///  Enumeration of ZPL2 media tracking values.
  /// </summary>
  TZPL2MediaTracking =
  (
    mnContinuous,
    mnNonContinuousWeb,
    mnNonContinuousMark
  );

  /// <summary>
  ///  Enumeration of ZPL2 media types.
  /// </summary>
  TZPL2MediaType =
  (
    mtThermalTransferMedia,
    mtDirectThermalMedia
  );

  /// <summary>
  ///  Enumeration of ZPL2 print modes.
  /// </summary>
  TZPL2PrintMode =
  (
    pmPrinterDefault,
    pmTearOff,
    pmPeelOff,
    pmRewind,
    pmApplicator,
    pmCutter
  );

  /// <summary>
  ///  Enumeration of ZPL2 ECC quality levels for Datamatrix codes.
  /// </summary>
  TZPL2QualityLevel =
  (
    ql_0 = 0,
    ql_50 = 50,
    ql_80 = 80,
    ql_100 = 100,
    ql_140 = 140,
    ql_200 = 200
  );

  /// <summary>
  ///  Enumeration of ZPL2 rotation values.
  /// </summary>
  TZPL2Rotation =
  (
    zrNO_ROTATION,
    zrROTATE_90_DEGREES,
    zrROTATE_180_DEGREES,
    zrROTATE_270_DEGREES
  );

  /// <summary>
  ///  Enumeration of ZPL2 print speed values.
  /// </summary>
  TZPL2Speed =
  (
   sp50_8mm,
   sp76_2mm,
   sp101_6mm,
   sp127mm,
   sp152_4mm,
   sp203_2mm,
   sp220_5mm,
   sp245mm,
   sp269_5mm,
   sp304_8mm
  );

type
  /// <summary>
  ///  Base class for all ZPL2 item types.
  /// </summary>
  TZPL2LabelItem = class abstract(TGraphicControl)
  strict private
    FMouseCoord: TPoint;

    FPrintable,
    FSelected: boolean;

    Fx,
    Fy: word0_32000;

    function GetX: word0_32000;
    function GetY: word0_32000;
    procedure SetPrintable(const Value: boolean);
    procedure SetSelected(const Value: boolean);
    procedure SetX(Value: word0_32000);
    procedure SetY(Value: word0_32000);
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;

  strict protected
    /// <summary>
    ///  Abstract method for returning the ZPL2 command of the item.
    /// </summary>
    function GetCommand: string; virtual; abstract;

    /// <summary>
    ///  Returns the ZPL2 command for the X/Y-coordinate of the item; to be used in overridden AsString method.
    /// </summary>
    function GetFieldOrigin: string;

    /// <summary>
    ///  Returns the ZPL2 command for the field separator; to be used in overridden AsString method, if necessary.
    /// </summary>
    function GetFieldSeparator: string;

  public
    /// <summary>
    ///  Abstract method for returning the complete ZPL2 command of the item, including field origin and/or field
    ///  separator and/or other data, if necessary.
    /// </summary>
    function AsString: string; virtual; abstract;

    constructor Create(AOwner: TComponent); override;

    /// <summary>
    ///  Method for drawing the item on a TCanvas object at the aX/aY-coordinate; must NOT be called, when overridden in
    ///  subclasses.
    /// </summary>
    procedure Draw(canvas: TCanvas; const aX, aY: word0_32000; Invert: boolean = false); virtual;

    /// <summary>
    ///  Abstract method for drawing the item on a TBitmap object.
    /// </summary>
    procedure GetBitmap(Bitmap: TBitmap); virtual; abstract;

    property Selected: boolean read FSelected write SetSelected;

  published
    property OnClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property Printable: boolean read FPrintable write SetPrintable;

    /// <summary>
    ///  X-coordinate property of the item.
    /// </summary>
    property X: word0_32000 read GetX write SetX;

    /// <summary>
    ///  Y-coordinate property of the item.
    /// </summary>
    property Y: word0_32000 read GetY write SetY;
  end;

  TZPL2CFItem = class(TZPL2LabelItem)
  strict private
    FFont: TZPL2Font;
    FHeight,
    FWidth: word10_32000;
    FHeight_Empty,
    FWidth_Empty: boolean;
  strict protected
    /// <summary>
    ///  Method for returning the ZPL2 command of the item.
    /// </summary>
    function GetCommand: string; override;
  public
    /// <summary>
    ///  Returns the complete ZPL2 command of the item, including field origin and/or field separator and/or other
    ///  data, if necessary.
    /// </summary>
    function AsString: string; override;

    constructor Create(AOwner: TComponent); override;

    /// <summary>
    ///  Method for drawing the item on a TCanvas object at the aX/aY-coordinate; must NOT call it's derived method.
    /// </summary>
    procedure Draw(canvas: TCanvas; const aX, aY: word0_32000; Invert: boolean = false); override;

    /// <summary>
    ///  Draws the item on a TBitmap object.
    /// </summary>
    procedure GetBitmap(Bitmap: TBitmap); override;

    property Font: TZPL2Font read FFont write FFont;

    /// <summary>
    ///  Property for the height of the CF item.
    /// </summary>
    property Height: word10_32000 read FHeight write FHeight;

    /// <summary>
    ///  Property for the width of the CF item.
    /// </summary>
    property Width: word10_32000 read FWidth write FWidth;

    /// <summary>
    ///  Property for the height of the CF item.
    /// </summary>
    property Height_Empty: boolean read FHeight_Empty write FHeight_Empty;

    /// <summary>
    ///  Property for the width of the CF item.
    /// </summary>
    property Width_Empty: boolean read FWidth_Empty write FWidth_Empty;
  end;

  /// <summary>
  ///  Class for ZPL2 comment item.
  /// </summary>
  TZPL2CommentField = class(TZPL2LabelItem)
  strict private
    /// <summary>
    ///  Text value of the item.
    /// </summary>
    FText: string;

    /// <summary>
    ///  Setter method for the text value used by the Text property, verifies the new text length.
    /// </summary>
    procedure SetText(const Value: string);

  strict protected
    /// <summary>
    ///  Method for returning the ZPL2 command of the item.
    /// </summary>
    function GetCommand: string; override;

  public
    /// <summary>
    ///  Returns the complete ZPL2 command of the item, including field origin and/or field separator and/or other
    ///  data, if necessary.
    /// </summary>
    function AsString: string; override;

    constructor Create(AOwner: TComponent); override;

    /// <summary>
    ///  Method for drawing the item on a TCanvas object at the aX/aY-coordinate; must NOT call it's derived method.
    /// </summary>
    procedure Draw(canvas: TCanvas; const aX, aY: word0_32000; Invert: boolean = false); override;

    /// <summary>
    ///  Draws the item on a TBitmap object.
    /// </summary>
    procedure GetBitmap(Bitmap: TBitmap); override;

  published
    /// <summary>
    ///  Property for the text value.
    /// </summary>
    property Text: string read FText write SetText;

  end;

  /// <summary>
  ///  Base class for rotatable ZPL2 items.
  /// </summary>
  TZPL2RotationLabelItem = class abstract(TZPL2LabelItem)
  strict private
    /// <summary>
    ///  Rotation value of the item.
    /// </summary>
    FRotation: TZPL2Rotation;
    procedure SetRotation(const ARotation: TZPL2Rotation);

  public
    constructor Create(AOwner: TComponent); override;

  published
    /// <summary>
    ///  Property for the rotation value.
    /// </summary>
    property Rotation: TZPL2Rotation read FRotation write SetRotation;

  end;

  /// <summary>
  ///  Base class for ZPL2 items containing text.
  /// </summary>
  TZPL2TextLabelItem = class abstract(TZPL2RotationLabelItem)
  strict private
    /// <summary>
    ///  Text value of the item.
    /// </summary>
    FText: string;

    /// <summary>
    ///  Setter method for the text value used by the Text property, verifies the new text length.
    /// </summary>
    procedure SetText(const Value: string);

  strict protected
    /// <summary>
    ///  converts the text in proper ZPL2 style.
    /// </summary>
    function FormatTextForLabel: string;

  public
    constructor Create(AOwner: TComponent); override;

  published
    /// <summary>
    ///  Property for the text value.
    /// </summary>
    property Text: string read FText write SetText;

  end;

  /// <summary>
  ///  Base class for all ZPL2 graphic items.
  /// </summary>
  TZPL2GraphicItem = class abstract(TZPL2LabelItem)
  strict private
    /// <summary>
    ///  Black or white line color of the graphic item.
    /// </summary>
    FLineColor: TZPL2LineColor;

    procedure SetLineColor(const Value: TZPL2LineColor);

  published
    /// <summary>
    ///  Property for the line color of the graphic item.
    /// </summary>
    property LineColor: TZPL2LineColor read FLineColor write SetLineColor;

  end;

  /// <summary>
  ///  Base class for ZPL2 graphic items only consisting of straight lines.
  /// </summary>
  TZPL2GraphicStraightLineItem = class abstract(TZPL2GraphicItem)
  strict protected
    /// <summary>
    ///  Border (line) width of the graphic item.
    /// </summary>
    FBorder: word1_32000;

    /// <summary>
    ///  Abstract setter method for the border (line) width of the graphic item.
    /// </summary>
    procedure SetBorder(const Value: word1_32000); virtual; abstract;

  published
    /// <summary>
    ///  Property for the border (line) width of the graphic item.
    /// </summary>
    property Border: word1_32000 read FBorder write SetBorder;

  end;

  /// <summary>
  ///  Base class for ZPL2 graphic items only consisting of round lines.
  /// </summary>
  TZPL2GraphicRoundLineItem = class abstract(TZPL2GraphicItem)
  strict protected
    /// <summary>
    ///  Border (line) width of the graphic item.
    /// </summary>
    FBorder: word1_4095;

    /// <summary>
    ///  Abstract method for drawing the outer circle of the item, is called in template method "GetBitmap".
    /// </summary>
    procedure DrawEllipse(Bitmap: TBitmap); virtual; abstract;

    /// <summary>
    ///  Abstract method for drawing the inner circle of the item, is called in template method "GetBitmap".
    /// </summary>
    procedure DrawInnerEllipse(Bitmap: TBitmap); virtual; abstract;

    /// <summary>
    ///  Abstract method for setting the bitmap size of the item, is called in template method "GetBitmap".
    /// </summary>
    procedure SetBitmapSize(Bitmap: TBitmap); virtual; abstract;

    /// <summary>
    ///  Abstract setter method for the border (line) width of the graphic item.
    /// </summary>
    procedure SetBorder(const Value: word1_4095); virtual; abstract;
  public

    /// <summary>
    ///  Draws the item on a TBitmap object, Template method for all subclasses, must NOT be overriden!.
    /// </summary>
    procedure GetBitmap(Bitmap: TBitmap); override;

  published
    /// <summary>
    ///  Property for the border (line) width of the graphic item.
    /// </summary>
    property Border: word1_4095 read FBorder write SetBorder;

  end;

  /// <summary>
  ///  Class for ZPL2 graphic box item.
  /// </summary>
  TZPL2GraphicBox = class(TZPL2GraphicStraightLineItem)
  strict private
    /// <summary>
    ///  Height of the graphic item.
    /// </summary>
    FHeight: word1_32000;

    /// <summary>
    ///  Width of the graphic item.
    /// </summary>
    FWidth: word1_32000;

    /// <summary>
    ///  Corner rounding of the item, <c>0</c> = no rounding; <c>8</c> = heaviest rounding.
    /// </summary>
    FCornerRounding: byte0_8;

    procedure SetCornerRounding(const Value: byte0_8);
    procedure SetHeight(const Value: word1_32000);
    procedure SetWidth(const Value: word1_32000);

  strict protected
    /// <summary>
    ///  Method for returning the ZPL2 command of the item.
    /// </summary>
    function GetCommand: string; override;

    /// <summary>
    ///  Setter method for the border (line) width of the graphic item.
    /// </summary>
    procedure SetBorder(const Value: word1_32000); override;

  public
    /// <summary>
    ///  Returns the complete ZPL2 command of the item, including field origin and/or field separator and/or other
    ///  data, if necessary.
    /// </summary>
    function AsString: string; override;

    constructor Create(AOwner: TComponent); override;

    /// <summary>
    ///  Draws the item on a TBitmap object.
    /// </summary>
    procedure GetBitmap(Bitmap: TBitmap); override;
  published
    /// <summary>
    ///  Property for the corner rounding value of the graphic item.
    /// </summary>
    property CornerRounding: byte0_8 read FCornerRounding write SetCornerRounding;

    /// <summary>
    ///  Property for the height of the graphic item.
    /// </summary>
    property Height: word1_32000 read FHeight write SetHeight;

    /// <summary>
    ///  Property for the width of the graphic item.
    /// </summary>
    property Width: word1_32000 read FWidth write SetWidth;

  end;

  TZPL2GraphicBoxClass = class of TZPL2GraphicBox;

  /// <summary>
  ///  Class for ZPL2 diagonal line item.
  /// </summary>
  TZPL2GraphicDiagonalLine = class(TZPL2GraphicStraightLineItem)
  strict private
    /// <summary>
    ///  Height of the graphic item.
    /// </summary>
    FHeight: word3_32000;

    /// <summary>
    ///  Width of the graphic item.
    /// </summary>
    FWidth: word3_32000;

    /// <summary>
    ///  Left or right leaning line orientation of the graphic item.
    /// </summary>
    FOrientation: TZPL2LineOrientation;

    procedure SetHeight(const Value: word3_32000);
    procedure SetOrientation(const Value: TZPL2LineOrientation);
    procedure SetWidth(const Value: word3_32000);

  strict protected
    /// <summary>
    ///  Method for returning the ZPL2 command of the item.
    /// </summary>
    function GetCommand: string; override;

    /// <summary>
    ///  Setter method for the border (line) width of the graphic item.
    /// </summary>
    procedure SetBorder(const Border: word1_32000); override;

  public
    constructor Create(AOwner: TComponent); override;

    /// <summary>
    ///  Returns the complete ZPL2 command of the item, including field origin and/or field separator and/or other
    ///  data, if necessary.
    /// </summary>
    function AsString: string; override;

    /// <summary>
    ///  Draws the item on a TBitmap object.
    /// </summary>
    procedure GetBitmap(Bitmap: TBitmap); override;

  published
    /// <summary>
    ///  Property for the height of the graphic item.
    /// </summary>
    property Height: word3_32000 read FHeight write SetHeight;

    /// <summary>
    ///  Property for the line orientation of the graphic item.
    /// </summary>
    property Orientation: TZPL2LineOrientation read FOrientation write SetOrientation;

    /// <summary>
    ///  Property for the width of the graphic item.
    /// </summary>
    property Width: word3_32000 read FWidth write SetWidth;
  end;

  TZPL2GraphicDiagonalLineClass = class of TZPL2GraphicDiagonalLine;

  /// <summary>
  ///  Class for ZPL2 circle item.
  /// </summary>
  TZPL2GraphicCircle = class(TZPL2GraphicRoundLineItem)
  strict private
    /// <summary>
    ///  Diameter of the graphic item.
    /// </summary>
    FDiameter: word3_4095;

    procedure SetDiameter(const Value: word3_4095);

  strict protected
    /// <summary>
    ///  Method for drawing the outer circle of the item, is called in template method "GetBitmap" of the derived class.
    /// </summary>
    procedure DrawEllipse(Bitmap: TBitmap); override;

    /// <summary>
    ///  Method for drawing the inner circle of the item, is called in template method "GetBitmap" of the derived class.
    /// </summary>
    procedure DrawInnerEllipse(Bitmap: TBitmap); override;

    /// <summary>
    ///  Method for returning the ZPL2 command of the item.
    /// </summary>
    function GetCommand: string; override;

    /// <summary>
    ///  Method for setting the bitmap size of the item, is called in template method "GetBitmap" of the derived class.
    /// </summary>
    procedure SetBitmapSize(Bitmap: TBitmap); override;

    /// <summary>
    ///  Setter method for the border (line) width of the graphic item.
    /// </summary>
    procedure SetBorder(const Border: word1_4095); override;

  public
    constructor Create(AOwner: TComponent); override;

    /// <summary>
    ///  Returns the complete ZPL2 command of the item, including field origin and/or field separator and/or other
    ///  data, if necessary.
    /// </summary>
    function AsString: string; override;

  published
    /// <summary>
    ///  Property for the diameter of the graphic item.
    /// </summary>
    property Diameter: word3_4095 read FDiameter write SetDiameter;

  end;

  TZPL2GraphicCircleClass = class of TZPL2GraphicCircle;

  /// <summary>
  ///  Class for ZPL2 ellipse item.
  /// </summary>
  TZPL2GraphicEllipse = class(TZPL2GraphicRoundLineItem)
  strict private
    /// <summary>
    ///  Height of the graphic item.
    /// </summary>
    FHeight: word3_4095;

    /// <summary>
    ///  Width of the graphic item.
    /// </summary>
    FWidth: word3_4095;

    procedure SetHeight(const Value: word3_4095);

    procedure SetWidth(const Value: word3_4095);

  strict protected
    /// <summary>
    ///  Method for drawing the outer circle of the item, is called in template method
    ///  <see cref="GetBitmap"/> of the derived class.
    /// </summary>
    procedure DrawEllipse(Bitmap: TBitmap); override;

    /// <summary>
    ///  Method for drawing the inner circle of the item, is called in template method
    ///  <see cref="GetBitmap"/> of the derived class.
    /// </summary>
    procedure DrawInnerEllipse(Bitmap: TBitmap); override;

    /// <summary>
    ///  Method for returning the ZPL2 command of the item.
    /// </summary>
    function GetCommand: string; override;

    /// <summary>
    ///  Method for setting the bitmap size of the item, is called in template method
    ///  <see cref="GetBitmap"/> of the derived class.
    /// </summary>
    procedure SetBitmapSize(Bitmap: TBitmap); override;

    /// <summary>
    ///  Setter method for the border (line) width of the graphic item.
    /// </summary>
    procedure SetBorder(const Border: word1_4095); override;

  public
    constructor Create(AOwner: TComponent); override;

    /// <summary>
    ///  Returns the complete ZPL2 command of the item, including field origin and/or field separator and/or other
    ///  data, if necessary.
    /// </summary>
    function AsString: string; override;

  published
    /// <summary>
    ///  Property for the height of the graphic item.
    /// </summary>
    property Height: word3_4095 read FHeight write SetHeight;

    /// <summary>
    ///  Property for the width of the graphic item.
    /// </summary>
    property Width: word3_4095 read FWidth write SetWidth;

  end;

  TZPL2GraphicEllipseClass = class of TZPL2GraphicEllipse;

  /// <summary>
  ///  Class for ZPL2 graphic field item.
  /// </summary>
  TZPL2GraphicField = class(TZPL2LabelItem)
  strict private
    /// <summary>
    ///  Hex string with the data of the graphic item.
    /// </summary>
    FData: string;

    /// <summary>
    ///  Total amount of bytes of the graphic data.
    /// </summary>
    FBytes: word;

    /// <summary>
    ///  Number of bytes in one row of the image.
    /// </summary>
    FBytesPerRow: word;

  strict protected
    /// <summary>
    ///  Method for returning the ZPL2 command of the item.
    /// </summary>
    function GetCommand: string; override;

  public
    /// <summary>
    ///  Returns the complete ZPL2 command of the item, including field origin and/or field separator and/or other
    ///  data, if necessary.
    /// </summary>
    function AsString: string; override;

    /// <summary>
    ///  Converts the bitmap in a ZPL2 valid hex string (best format is monochrome bitmap!).
    /// </summary>
    procedure ConvertGraphic(const Bitmap: TBitmap);

    constructor Create(AOwner: TComponent); override;

    /// <summary>
    ///  Draws the item on a TBitmap object.
    /// </summary>
    procedure GetBitmap(Bitmap: TBitmap); override;

    procedure LoadFromFile(const Filename: string);
    procedure SetGraphic(const Bytes, BytesPerRow: word; const Data: string);

  end;

  TZPL2GraphicFieldClass = class of TZPL2GraphicField;

  /// <summary>
  ///  Class for ZPL2 text field item.
  /// </summary>
  TZPL2TextField = class(TZPL2TextLabelItem)
  strict private
    /// <summary>
    ///  Font of the item.
    /// </summary>
    FFont: TZPL2Font;

    /// <summary>
    ///  Height of the text.
    /// </summary>
    FHeight: word10_32000;

    /// <summary>
    ///  Width of the text <c>(100 * width / height = width in percent)</c>.
    /// </summary>
    FWidth: word10_32000;

    /// <summary>
    ///  Getter method for the text width in percent of the item.
    /// </summary>
    function GetWidthPercent: double;

    procedure SetFont(const Value: TZPL2Font);
    procedure SetHeight(const Value: word10_32000);
    procedure SetWidth(const Value: word10_32000);

    /// <summary>
    ///  Setter method for the text width in percent of the item.
    /// </summary>
    procedure SetWidthPercent(const AWidthPercent: double);

  strict protected
    /// <summary>
    ///  Method for returning the ZPL2 command of the item.
    /// </summary>
    function GetCommand: string; override;

  public
    /// <summary>
    ///  Returns the complete ZPL2 command of the item, including field origin and/or field separator and/or other
    ///  data, if necessary.
    /// </summary>
    function AsString: string; override;

    constructor Create(AOwner: TComponent); override;

    /// <summary>
    ///  Method for drawing the item on a TCanvas object at the aX/aY-coordinate; must NOT call it's derived method.
    /// </summary>
    procedure Draw(canvas: TCanvas; const aX, aY: word0_32000; Invert: boolean = false); override;

    /// <summary>
    ///  Draws the item on a TBitmap object.
    /// </summary>
    procedure GetBitmap(Bitmap: TBitmap); override;

  published
    /// <summary>
    ///  Property for the font of the item.
    /// </summary>
    property Font: TZPL2Font read FFont write SetFont;

    /// <summary>
    ///  Property for the height of the item.
    /// </summary>
    property Height: word10_32000 read FHeight write SetHeight;

    /// <summary>
    ///  Property for the width of the item.
    /// </summary>
    property Width: word10_32000 read FWidth write SetWidth;

    /// <summary>
    ///  Property for the width in percent of the item.
    /// </summary>
    property WidthPercent: double read GetWidthPercent write SetWidthPercent;

  end;

  TZPL2TextFieldClass = class of TZPL2TextField;

  /// <summary>
  ///  List of ZPL2 items.
  /// </summary>
  TZPL2LabelItemList = class(TObjectList)
  strict protected
    function GetItem(Index: Integer): TZPL2LabelItem;
    procedure SetItem(Index: Integer; AItem: TZPL2LabelItem);

  public
    /// <summary>
    ///  Fügt ein <see cref="ZPL2|TZPL2LabelItem"/> hinzu.
    /// </summary>
    /// <remarks>
    ///  Falls man eine ganze Liste hinzufügen will, kann man das mit der Funktion <see cref="Assign"/> machen, wobei
    ///  es dann verschiedene Kopierarten gibt, wie z.B. <c>laOr</c> oder <c>laAnd</c>.
    ///  <note type="warning">
    ///  Standardmäßig gehören die Objekte der <see cref="ZPL2|TZPL2LabelItemList"/>, das man über das Property
    ///  <c>OwnsObjects := false;</c> ändern kann.
    ///  </note>
    ///  <code lang="delphi">
    ///  // var test: TCookingArea;
    ///  test := TCookingArea.Create(0,0,ktNormal,ktNormal);
    ///  test.ZPL2LabelItemList.OwnsObjects := false;
    ///  test.Refresh;
    ///  ZPL.Items.Assign(test.ZPL2LabelItemList, laOr);
    ///  test.Free;
    ///  </code>
    /// </remarks>
    function Add(AItem: TZPL2LabelItem): Integer;

    function Extract(Item: TZPL2LabelItem): TZPL2LabelItem;
    function Remove(AItem: TZPL2LabelItem): Integer;
    function IndexOf(AItem: TZPL2LabelItem): Integer;
    procedure Insert(Index: Integer; AItem: TZPL2LabelItem);
    function First: TZPL2LabelItem;
    function Last: TZPL2LabelItem;
    property Item[Index: Integer]: TZPL2LabelItem read GetItem write SetItem; default;

  end;


const
  /// <summary>
  ///  Transparent color for the label items, so they can be painted either in black over white or vice versa.
  /// </summary>
  ZPL2TransparentColor = clRed;

  { Array constans for easy converting of enum or boolean values to Delphi or ZPL2 character values }
  ZPL2ErrorCorrectionLevelChar: array[TZPL2ErrorCorrectionLevel] of char = ('L', 'M', 'Q', 'H');
  ZPL2RotationChar: array[TZPL2Rotation] of char = ('N', 'B', 'I', 'R');
  ZPL2YesNoChar: array[boolean] of char = ('N', 'Y');

  { ZPL2 command constants }
  ZPL2_A  = '^A';
  ZPL2_B3 = '^B3';
  ZPL2_BC = '^BC';
  ZPL2_BQ = '^BQ';
  ZPL2_BX = '^BX';
  ZPL2_BY = '^BY';
  ZPL2_CF = '^CF';
  ZPL2_CI = '^CI';
  ZPL2_FD = '^FD';
  ZPL2_FH = '^FH';
  ZPL2_FO = '^FO';
  ZPL2_FS = '^FS';
  ZPL2_FX = '^FX';
  ZPL2_GB = '^GB';
  ZPL2_GC = '^GC';
  ZPL2_GD = '^GD';
  ZPL2_GE = '^GE';
  ZPL2_GF = '^GF';
  ZPL2_LH = '^LH';
  ZPL2_LR = '^LR';
  ZPL2_MC = '^MC';
  ZPL2_MD = '^MD';
  ZPL2_MM = '^MM';
  ZPL2_MN = '^MN';
  ZPL2_MT = '^MT';
  ZPL2_PO = '^PO';
  ZPL2_PQ = '^PQ';
  ZPL2_PR = '^PR';
  ZPL2_PW = '^PW';
  ZPL2_XA = '^XA';
  ZPL2_XB = '^XB';
  ZPL2_XZ = '^XZ';

function CreateCommentField(const Text: string): TZPL2CommentField;
function CreateGraphicBox(const X, Y: word0_32000; const Width, Height: word1_32000; const Border: word1_32000 = 1; const LineColor: TZPL2LineColor = lcBlack): TZPL2GraphicBox;
function CreateGraphicCircle(const X, Y: word0_32000; const Diameter: word3_4095; const Border: word1_4095 = 1; const LineColor: TZPL2LineColor = lcBlack): TZPL2GraphicCircle;
function CreateGraphicDiagonalLine(const X, Y: word0_32000; const Width, Height: word3_32000; const Orientation: TZPL2LineOrientation = loRightLeaning; const Border: word1_32000 = 1; const LineColor: TZPL2LineColor = lcBlack): TZPL2GraphicDiagonalLine;
function CreateGraphicEllipse(const X, Y: word0_32000; const Width, Height: word3_4095; const Border: word1_4095 = 1; const LineColor: TZPL2LineColor = lcBlack): TZPL2GraphicEllipse;
function CreateGraphicField(const X, Y: word0_32000; const Filename: string): TZPL2GraphicField;
function CreateTextField(const X, Y: word0_32000; const Text: string; const Height: word10_32000 = 20; const WidthPercent: double = 100; const Font: TZPL2Font = zfTRIUMVIRATE): TZPL2TextField;

/// <summary>
///  Returns the current local format settings and sets the decimal separator to '.' (dot)
/// </summary>
/// <returns>
///  Local format settings with decimal separator set to '.' (dot).
/// </returns>
function GetLocaleFormatSettingsWithDotDecimalSeparator: TFormatSettings;

/// <summary>
///  Calculates a millimeter position to dots, depending on the given resolution (of the printer).
/// </summary>
function MillimeterToDots(const Millimeter: double; const Dpi: word = 300): cardinal;

implementation

const
  { Array constants for easy converting of enum or boolean values to Delphi or ZPL2 character values }
  ZPL2LineColor: array[TZPL2LineColor] of TColor = (clBlack, clWhite);
  ZPL2InversLineColor: array[TZPL2LineColor] of TColor = (clWhite, clBlack);
  ZPL2LineColorChar: array[TZPL2LineColor] of char = ('B', 'W');
  ZPL2LineOrientationChar: array[TZPL2LineOrientation] of char = ('R', 'L');
  ZPL2RotationDegree: array[TZPL2Rotation] of 0..270 = (0, 90, 180, 270);

{$region 'Unit Methods'}

function AddPoints(const p1, p2: TPoint): TPoint;
begin
  result.X := p1.X + p2.X;
  result.Y := p1.Y + p2.Y;
end;

/// <summary>
///  Wrapper for Windows API CharToOem.
/// </summary>
procedure AnsiToAscii(var s: string);
var
  buff: AnsiString;
begin
  if s <> '' then
  begin
    SetLength(buff, length(s) + 1);

    {$IFDEF UNICODE}
    if CharToOemW(PChar(s), PAnsiChar(buff)) then
    {$ELSE}
    if CharToOemA(PChar(s), PChar(buff)) then
    {$ENDIF}
      s := Trim(string(buff));
  end;
end;

function CreateCommentField(const Text: string): TZPL2CommentField;
begin
  result := TZPL2CommentField.Create(nil);
  result.Text := Text;
end;

function CreateGraphicBox(const X, Y: word0_32000; const Width, Height: word1_32000; const Border: word1_32000; const LineColor: TZPL2LineColor): TZPL2GraphicBox;
begin
  result := TZPL2GraphicBox.Create(nil);
  result.X := X;
  result.Y := Y;
  result.Width := Width;
  result.Height := Height;
  result.Border := Border;
  result.LineColor := LineColor;
end;

function CreateGraphicCircle(const X, Y: word0_32000; const Diameter: word3_4095; const Border: word1_4095; const LineColor: TZPL2LineColor): TZPL2GraphicCircle;
begin
  result := TZPL2GraphicCircle.Create(nil);
  result.X := X;
  result.Y := Y;
  result.Diameter := Diameter;
  result.Border := Border;
  result.LineColor := LineColor;
end;

function CreateGraphicDiagonalLine(const X, Y: word0_32000; const Width, Height: word3_32000; const Orientation: TZPL2LineOrientation; const Border: word1_32000; const LineColor: TZPL2LineColor): TZPL2GraphicDiagonalLine;
begin
  result := TZPL2GraphicDiagonalLine.Create(nil);
  result.X := X;
  result.Y := Y;
  result.Width := Width;
  result.Height := Height;
  result.Orientation := Orientation;
  result.Border := Border;
  result.LineColor := LineColor;
end;

function CreateGraphicEllipse(const X, Y: word0_32000; const Width, Height: word3_4095; const Border: word1_4095 = 1; const LineColor: TZPL2LineColor = lcBlack): TZPL2GraphicEllipse;
begin
  result := TZPL2GraphicEllipse.Create(nil);
  result.X := X;
  result.Y := Y;
  result.Width := Width;
  result.Height := Height;
  result.Border := Border;
  result.LineColor := LineColor;
end;

function CreateGraphicField(const X, Y: word0_32000; const Filename: string): TZPL2GraphicField;
begin
  result := TZPL2GraphicField.Create(nil);
  result.X := X;
  result.Y := Y;
  result.LoadFromFile(Filename);
end;

function CreateTextField(const X, Y: word0_32000; const Text: string; const Height: word10_32000; const WidthPercent: double; const Font: TZPL2Font): TZPL2TextField;
begin
  result := TZPL2TextField.Create(nil);
  result.X := X;
  result.Y := Y;
  result.Text := Text;
  result.Height := Height;
  result.WidthPercent := WidthPercent;
  result.Font := Font;
end;

function GetLocaleFormatSettingsWithDotDecimalSeparator: TFormatSettings;
begin
  {$if CompilerVersion >= 22.0}
  result := TFormatSettings.Create;
  {$else}
  SysUtils.GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, result);
  {$ifend}
  result.DecimalSeparator := '.';
end;

function MillimeterToDots(const Millimeter: double; const Dpi: word): cardinal;
const
  MillimeterPerInch = 25.4;
begin
  result := Round(Millimeter * Dpi / MillimeterPerInch)
end;

{$endregion}

{$region 'TZPL2LabelItem' }

constructor TZPL2LabelItem.Create(AOwner: TComponent);
begin
  inherited;
  FPrintable := true;
  SetBounds(Left, Top, 1, 1);
end;

procedure TZPL2LabelItem.Draw(canvas: TCanvas; const aX, aY: word0_32000; Invert: boolean = false);
var
  bitmap: TBitmap;
begin
  bitmap := TBitmap.Create;

  try
    GetBitmap(bitmap);
    SetBounds(Left, Top, bitmap.Width, bitmap.Height);
    bitmap.Transparent := not Invert; // Use transparency only in normal drawing mode, else the result looks ugly
    bitmap.TransparentColor := ZPL2TransparentColor;

    if Invert then
      InvertRect(bitmap.Canvas.Handle, Rect(0, 0, bitmap.Width, bitmap.Height));

    if not Printable then
    begin
      canvas.Brush.Color := clSilver;
      canvas.Pen.Color := canvas.Brush.Color;
      canvas.Rectangle(aX, aY, aX + bitmap.Width, aY + bitmap.Height);
    end;

    canvas.Draw(aX, aY, bitmap);
  finally
    bitmap.Free;
  end;
end;

function TZPL2LabelItem.GetFieldOrigin: string;
begin
  result := Format(ZPL2_FO + '%u,%u', [Fx, Fy]);
end;

function TZPL2LabelItem.GetFieldSeparator: string;
begin
  result := ZPL2_FS;
end;

function TZPL2LabelItem.GetX: word0_32000;
begin
  result := Fx;
end;

function TZPL2LabelItem.GetY: word0_32000;
begin
  result := Fy;
end;

procedure TZPL2LabelItem.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  CursorClipArea: TRect;
begin
  if Button = mbLeft then
  begin
    BringToFront;
    Selected := true;
    FMouseCoord := Point(X, Y);

    if Assigned(Parent) then
    begin
      CursorClipArea.TopLeft := AddPoints(Parent.ClientToScreen(Parent.ClientRect.TopLeft), FMouseCoord);
      CursorClipArea.BottomRight := AddPoints(Parent.ClientToScreen(Parent.ClientRect.BottomRight), Point(Width - X, Height - Y));
      ClipCursor(@CursorClipArea);
    end;
  end;

  inherited;
end;

procedure TZPL2LabelItem.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if ssLeft in Shift then
  begin
    Left := Left + X - FMouseCoord.X;
    Top := Top + Y - FMouseCoord.Y;
    Self.X := Left;
    Self.Y := Top;

    Invalidate;
  end;
end;

procedure TZPL2LabelItem.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(Parent) then
    ClipCursor(nil);

  Selected := false;
  Invalidate;
  inherited;
end;

procedure TZPL2LabelItem.Paint;
begin
  inherited;
  Draw(Canvas, 0, 0);

  if FSelected then
    Canvas.DrawFocusRect(ClientRect);
end;

procedure TZPL2LabelItem.SetPrintable(const Value: boolean);
begin
  FPrintable := Value;
  Invalidate;
end;

procedure TZPL2LabelItem.SetSelected(const Value: boolean);
begin
  FSelected := Value;
end;

procedure TZPL2LabelItem.SetX(Value: word0_32000);
begin
  Fx := Value;
  Left := Value;
  Invalidate;
end;

procedure TZPL2LabelItem.SetY(Value: word0_32000);
begin
  Fy := Value;
  Top := Value;
  Invalidate;
end;

{$endregion}

{$region 'TZPL2LabelItemList' }

function TZPL2LabelItemList.Add(AItem: TZPL2LabelItem): Integer;
begin
  Result := inherited Add(AItem);
end;

function TZPL2LabelItemList.Extract(Item: TZPL2LabelItem): TZPL2LabelItem;
begin
  Result := TZPL2LabelItem(inherited Extract(Item));
end;

function TZPL2LabelItemList.First: TZPL2LabelItem;
begin
  Result := TZPL2LabelItem(inherited First);
end;

function TZPL2LabelItemList.GetItem(Index: Integer): TZPL2LabelItem;
begin
  Result := TZPL2LabelItem(inherited Items[Index]);
end;

function TZPL2LabelItemList.IndexOf(AItem: TZPL2LabelItem): Integer;
begin
  Result := inherited IndexOf(AItem);
end;

procedure TZPL2LabelItemList.Insert(Index: Integer; AItem: TZPL2LabelItem);
begin
  inherited Insert(Index, AItem);
end;

function TZPL2LabelItemList.Last: TZPL2LabelItem;
begin
  Result := TZPL2LabelItem(inherited Last);
end;

function TZPL2LabelItemList.Remove(AItem: TZPL2LabelItem): Integer;
begin
  Result := inherited Remove(AItem);
end;

procedure TZPL2LabelItemList.SetItem(Index: Integer; AItem: TZPL2LabelItem);
begin
  inherited Items[Index] := AItem;
end;

{$endregion}

{$region 'TZPL2CFItem' }
function TZPL2CFItem.AsString: string;
begin
  result := GetCommand;
end;

constructor TZPL2CFItem.Create(AOwner: TComponent);
begin
  inherited;
  FFont := zfA;
  Height := 10;
  Width := 10;
  FHeight_Empty := false;
  FWidth_Empty := false;
end;

procedure TZPL2CFItem.Draw(canvas: TCanvas; const aX, aY: word0_32000; Invert: boolean = false);
begin
  // nothing to draw on a canvas
  exit;
end;

procedure TZPL2CFItem.GetBitmap(Bitmap: TBitmap);
begin
  // nothing to draw on a bitmap
  exit;
end;

function TZPL2CFItem.GetCommand: string;
begin
  result := ZPL2_CF + Chr(Ord(FFont)) + ',' + IfThen(FHeight_Empty, '', IntToStr(FHeight)) + ',' + IfThen(FWidth_Empty, '', IntToStr(FWidth))
end;
{$endregion}

{$region 'TZPL2CommentField' }
function TZPL2CommentField.AsString: string;
begin
  result := GetCommand + GetFieldSeparator;
end;

constructor TZPL2CommentField.Create(AOwner: TComponent);
begin
  inherited;
  X := 0;
  Y := 0;
  Text := 'Comment';
end;

procedure TZPL2CommentField.Draw(canvas: TCanvas; const aX, aY: word0_32000; Invert: boolean);
begin
  // nothing to draw on a canvas
  exit;
end;

procedure TZPL2CommentField.GetBitmap(Bitmap: TBitmap);
begin
  // nothing to draw on a bitmap
  exit;
end;

function TZPL2CommentField.GetCommand: string;
begin
  result := ZPL2_FX + FText;
end;

procedure TZPL2CommentField.SetText(const Value: string);
begin
  if Value = '' then
    raise Exception.Create('Comment text must not be empty!');

  FText := Value;
  Invalidate;
end;
{$endregion}

{$region 'TZPL2GraphicBox' }

function TZPL2GraphicBox.AsString: string;
begin
  result := GetFieldOrigin + GetCommand + GetFieldSeparator;
end;

constructor TZPL2GraphicBox.Create(AOwner: TComponent);
begin
  inherited;
  Width := 10;
  Height := 10;
  Border := 1;
  CornerRounding := 0;
  LineColor := lcBlack;
end;

procedure TZPL2GraphicBox.GetBitmap(Bitmap: TBitmap);
  function GetBorder: word1_32000;
  begin
    result := IfThen(Border > 0, Border, 1)
  end;

  function GetHeight: word1_32000;
  begin
    result := IfThen(FHeight > GetBorder, FHeight, GetBorder)
  end;

  function GetWidth: word1_32000;
  begin
    result := IfThen(FWidth > GetBorder, FWidth, GetBorder)
  end;

var
  rounding: word;
  r: TRect;
begin
  // Calculates the rect for the canvas according to the border size
  r := Rect(Floor(GetBorder / 4) - IfThen((GetBorder > 1) and (GetBorder < Min(Width, Height)), Round(1 - Frac(GetBorder / 4)), 0),
            Floor(GetBorder / 4) - IfThen((GetBorder > 1) and (GetBorder < Min(Width, Height)), Round(1 - Frac(GetBorder / 4)), 0),
            GetWidth - Trunc(GetBorder / 4) + IfThen((GetBorder > 1) and (GetBorder <= Min(Width, Height)), Round(1 - Frac(GetBorder / 4)), 0),
            GetHeight - Trunc(GetBorder / 4) + IfThen((GetBorder > 1) and (GetBorder <= Min(Width, Height)), Round(1 - Frac(GetBorder / 4)), 0));

  bitmap.canvas.Pen.Width := Round((GetBorder + 1) / 2);
  bitmap.Width := FWidth;
  bitmap.Height := FHeight;

  bitmap.canvas.Brush.Color := ZPL2TransparentColor;
  bitmap.canvas.Pen.Color := ZPL2LineColor[LineColor];

  if FCornerRounding = 0 then
    bitmap.canvas.Rectangle(r)
  else
  begin
    rounding := Round((FCornerRounding / 8) * (Min(GetWidth, GetHeight) / 2));
    bitmap.canvas.RoundRect(r.Left, r.Top, r.Right, r.Bottom, rounding, rounding);
  end;
end;

function TZPL2GraphicBox.GetCommand: string;
begin
  result := Format(ZPL2_GB + '%u,%u,%u,%s,%u', [Width, Height, Border, ZPL2LineColorChar[LineColor], CornerRounding]);
end;

procedure TZPL2GraphicBox.SetBorder(const Value: word1_32000);
begin
  if Value > Min(Width, Height) then
    FBorder := Min(Width, Height)
  else
    FBorder := Value;

  Invalidate;
end;

procedure TZPL2GraphicBox.SetCornerRounding(const Value: byte0_8);
begin
  FCornerRounding := Value;
  Invalidate;
end;

procedure TZPL2GraphicBox.SetHeight(const Value: word1_32000);
begin
  FHeight := Value;
  Invalidate;
end;

procedure TZPL2GraphicBox.SetWidth(const Value: word1_32000);
begin
  FWidth := Value;
  Invalidate;
end;

{$endregion}

{$region 'TZPL2GraphicCircle' }

function TZPL2GraphicCircle.AsString: string;
begin
  result := GetFieldOrigin + GetCommand + GetFieldSeparator;
end;

constructor TZPL2GraphicCircle.Create(AOwner: TComponent);
begin
  inherited;
  Diameter := 10;
  Border := 1;
  LineColor := lcBlack;
end;

procedure TZPL2GraphicCircle.DrawEllipse(Bitmap: TBitmap);
begin
  bitmap.canvas.Ellipse(0, 0, Diameter, Diameter);
end;

procedure TZPL2GraphicCircle.DrawInnerEllipse(Bitmap: TBitmap);
begin
  bitmap.canvas.Ellipse(Border, Border, Diameter - Border, Diameter - Border);
end;

function TZPL2GraphicCircle.GetCommand: string;
begin
  result := Format(ZPL2_GC + '%u,%u,%s', [Diameter, Border, ZPL2LineColorChar[LineColor]]);
end;

procedure TZPL2GraphicCircle.SetBitmapSize(Bitmap: TBitmap);
begin
  bitmap.SetSize(Diameter, Diameter);
end;

procedure TZPL2GraphicCircle.SetBorder(const Border: word1_4095);
begin
  if Border >= Diameter / 2 then
    FBorder := Round(Diameter / 2)
  else
    FBorder := Border;

  Invalidate;
end;

procedure TZPL2GraphicCircle.SetDiameter(const Value: word3_4095);
begin
  FDiameter := Value;
  Invalidate;
end;

{$endregion}

{$region 'TZPL2GraphicDiagonalLine' }

function TZPL2GraphicDiagonalLine.AsString: string;
begin
  result := GetFieldOrigin + GetCommand + GetFieldSeparator;
end;

constructor TZPL2GraphicDiagonalLine.Create(AOwner: TComponent);
begin
  inherited;
  Width := 10;
  Height := 10;
  Border := 1;
  Orientation := loRightLeaning;
  LineColor := lcBlack;
end;

procedure TZPL2GraphicDiagonalLine.GetBitmap(Bitmap: TBitmap);
begin
  bitmap.canvas.Pen.Color := ZPL2LineColor[LineColor];
  bitmap.canvas.Pen.Width := Border;
  bitmap.canvas.Brush.Color := ZPL2TransparentColor;
  bitmap.SetSize(Width, Height);

  case Orientation of
    loRightLeaning:
    begin
      bitmap.canvas.MoveTo(Round(Border / 2), Height - Round(Border / 2) - 1);
      bitmap.canvas.LineTo(Width - 1 - Round(Border / 2), Round(Border / 2));
    end;

    loLeftLeaning:
    begin
      bitmap.canvas.MoveTo(Round(Border / 2), Round(Border / 2));
      bitmap.canvas.LineTo(Width - 1 - Round(Border / 2), Height - Round(Border / 2) - 1);
    end;
  end;
end;

function TZPL2GraphicDiagonalLine.GetCommand: string;
begin
  result := Format(ZPL2_GD + '%u,%u,%u,%s,%s', [Width, Height, Border, ZPL2LineColorChar[LineColor], ZPL2LineOrientationChar[Orientation]]);
end;

procedure TZPL2GraphicDiagonalLine.SetBorder(const Border: word1_32000);
begin
  if Border >= Max(Width, Height) then
    FBorder := Max(Width, Height)
  else
    FBorder := Border;

  Invalidate;
end;

procedure TZPL2GraphicDiagonalLine.SetHeight(const Value: word3_32000);
begin
  FHeight := Value;
  Invalidate;
end;

procedure TZPL2GraphicDiagonalLine.SetOrientation(const Value: TZPL2LineOrientation);
begin
  FOrientation := Value;
  Invalidate;
end;

procedure TZPL2GraphicDiagonalLine.SetWidth(const Value: word3_32000);
begin
  FWidth := Value;
  Invalidate;
end;

{$endregion}

{$region 'TZPL2GraphicEllipse' }

function TZPL2GraphicEllipse.AsString: string;
begin
  result := GetFieldOrigin + GetCommand + GetFieldSeparator;
end;

constructor TZPL2GraphicEllipse.Create(AOwner: TComponent);
begin
  inherited;
  Width := 10;
  Height := 10;
  Border := 1;
  LineColor := lcBlack;
end;

procedure TZPL2GraphicEllipse.DrawEllipse(Bitmap: TBitmap);
begin
  bitmap.canvas.Ellipse(0, 0, Width, Height);
end;

procedure TZPL2GraphicEllipse.DrawInnerEllipse(Bitmap: TBitmap);
begin
  bitmap.canvas.Ellipse(Border, Border, Width - Border, Height - Border);
end;

function TZPL2GraphicEllipse.GetCommand: string;
begin
  result := Format(ZPL2_GE + '%u,%u,%u,%s', [Width, Height, Border, ZPL2LineColorChar[LineColor]]);
end;

procedure TZPL2GraphicEllipse.SetBitmapSize(Bitmap: TBitmap);
begin
  bitmap.SetSize(Width, Height);
end;

procedure TZPL2GraphicEllipse.SetBorder(const Border: word1_4095);
begin
  if Border >= Min(Width, Height) / 2 then
    FBorder := Round(Min(Width, Height) / 2)
  else
    FBorder := Border;

  Invalidate;
end;

procedure TZPL2GraphicEllipse.SetHeight(const Value: word3_4095);
begin
  FHeight := Value;
  Invalidate;
end;

procedure TZPL2GraphicEllipse.SetWidth(const Value: word3_4095);
begin
  FWidth := Value;
  Invalidate;
end;

{$endregion}

{$region 'TZPL2GraphicField' }

function TZPL2GraphicField.AsString: string;
begin
  result := GetFieldOrigin + GetCommand;
end;

procedure TZPL2GraphicField.ConvertGraphic(const Bitmap: TBitmap);
var
  p: PByteArray;
  b: byte;
  width, x, y: integer;
  s: string;
  Rows: TStrings;
begin
  Rows := TStringList.Create;

  try
    Bitmap.Monochrome := true;
    Bitmap.PixelFormat := pf1bit;

    FBytesPerRow := Ceil(Bitmap.Width / 8);
    width := Bitmap.Width div 8;

    // Reverse the bitmap and convert the pixel data to a string containing hex characters
    for y := 0 to Bitmap.Height - 1 do
    begin
      s := '';
      p := Bitmap.ScanLine[y];

      for x := 0 to width - 1 do
      begin
        b := not p^[x];
        s := s + IntToHex(b, 2);
        p^[x] := b;
      end;

      x := Bitmap.Width mod 8;

      if x > 0 then
      begin
        // Just use the pixels that really belong to the last byte of the pixel row!
        b := p^[width] xor (Trunc(IntPower(2, x) - 1) shl (8 - x));
        s := s + IntToHex(b, 2);
        p^[width] := b;
      end;

      while (Length(s) > 2) and (s[Length(s)] = '0') do
        Delete(s, Length(s), 1);

      if (s <> '') and Odd(Length(s)) then
        s := s + '0';

      if Length(s) < FBytesPerRow * 2 then
        s := s + ',';

      Rows.Append(s);
    end;

    if Rows.Count > 0 then
    begin
      s := Rows[Rows.count - 1];

      if (Length(s) > 0) and (s[Length(s)] = ',') then
        Delete(s, Length(s), 1);

      Rows[Rows.Count - 1] := s;
    end;

    FBytes := Rows.Count * FBytesPerRow;
    FData := Rows.Text;
  finally
    Rows.Free;
  end;
end;

constructor TZPL2GraphicField.Create(AOwner: TComponent);
begin
  inherited;
end;

procedure TZPL2GraphicField.GetBitmap(Bitmap: TBitmap);
var
  i, l, x: integer;
  s: string;
  p: PByteArray;
  b: byte;
  Rows: TStrings;
begin
  Rows := TStringList.Create;

  try
    l := 0;
    Rows.Text := FData;

    // Look for the row with the longest string
    for i := 0 to Rows.Count - 1 do
      l := Max(l, Length(Rows[i]) * 4);

    bitmap.PixelFormat := pf1bit;
    bitmap.Height := Rows.Count;
    bitmap.Width := l;

    for i := 0 to Rows.Count - 1 do
    begin
      if Rows[i] <> '' then
      begin
        x := 0;
        s := Rows[i];
        p := bitmap.ScanLine[i];

        while s <> '' do
        begin
          // convert the hex character string to bytes and set the bitmap pixels
          b := StrToIntDef('$' + Copy(s, 1, 2), 0);
          Delete(s, 1, 2);
          p^[x] :=  not b;
          Inc(x);
        end;
      end;
    end;


  finally
    Rows.Free;
  end;
end;

function TZPL2GraphicField.GetCommand: string;
var
  FDataList, list: TStrings;
  s: string;
  i: integer;
  Max_Len: word;
begin
  s := '';
  list := TStringList.Create;
  FDataList := TStringList.Create;

  try
    FDataList.Text := FData;
    Max_Len := FBytesPerRow * 2;

    for i := 0 to FDataList.Count - 1 do
    begin
      if Length(FDataList[i]) > 0 then
      begin
        s := s + FDataList[i];

        if (Length(FDataList[i]) < Max_Len) and (i < FDataList.Count) then
          s := s + ',';

        if Length(s) >= 80 then
        begin
          list.Append(Copy(s, 1, 80));
          Delete(s, 1, 80);
        end;
      end;
    end;

    list.Append(s);
    result := Format(ZPL2_GF + 'A,%u,%u,%u,' + sLineBreak + '%s', [FBytes, FBytes, FBytesPerRow, list.Text]);
  finally
    list.Free;
    FDataList.Free;
  end;
end;

procedure TZPL2GraphicField.LoadFromFile(const Filename: string);
var
  Picture: TPicture;
  JpegImage: TJpegImage;
begin
  Picture := TPicture.Create;

  try
    Picture.LoadFromFile(Filename);

    if (Picture.Graphic is TJPegImage)
    then
    begin
      JpegImage := TJpegImage.Create;
      try
        JpegImage.Assign(Picture.Graphic);
        Picture.Bitmap.Assign(JpegImage);
      finally
        JpegImage.Free;
      end;
    end;

    ConvertGraphic(Picture.Bitmap);
  finally
    Picture.Free;
  end;
end;

procedure TZPL2GraphicField.SetGraphic(const Bytes, BytesPerRow: word; const Data: string);
begin
  FBytes := Bytes;
  FBytesPerRow := BytesPerRow;
  FData := Data;
  Invalidate;
end;

{$endregion}

{$region 'TZPL2GraphicItem' }

procedure TZPL2GraphicItem.SetLineColor(const Value: TZPL2LineColor);
begin
  FLineColor := Value;
  Invalidate;
end;

{$endregion}

{$region 'TZPL2GraphicRoundLineItem' }

procedure TZPL2GraphicRoundLineItem.GetBitmap(Bitmap: TBitmap);
begin
  bitmap.canvas.Brush.Color := ZPL2TransparentColor;
  bitmap.canvas.Pen.Color := ZPL2LineColor[LineColor];
  bitmap.canvas.Pen.Width := 1;
  SetBitmapSize(bitmap);

  if Border > 2 then
  begin
    bitmap.canvas.Brush.Color := ZPL2LineColor[LineColor];
    DrawEllipse(bitmap);

    bitmap.canvas.Brush.Color := ZPL2TransparentColor;
    bitmap.canvas.Pen.Color := bitmap.canvas.Brush.Color;
    DrawInnerEllipse(bitmap);
  end
  else
  begin
    DrawEllipse(bitmap);
  end;
end;

{$endregion}

{$region 'TZPL2RotationLabelItem' }

constructor TZPL2RotationLabelItem.Create(AOwner: TComponent);
begin
  inherited;
  FRotation := zrNO_ROTATION;
end;

procedure TZPL2RotationLabelItem.SetRotation(const ARotation: TZPL2Rotation);
begin
  FRotation := ARotation;
  Invalidate;
end;

{$endregion}

{$region 'TZPL2TextField' }

function TZPL2TextField.AsString: string;
begin
  result := Format(ZPL2_A + '%s%s,%u,%u', [Chr(Ord(Font)), ZPL2RotationChar[Rotation], Height, Width]) + GetFieldOrigin + GetCommand + GetFieldSeparator;
end;

constructor TZPL2TextField.Create(AOwner: TComponent);
begin
  inherited;
  Text := 'Text';
  Height := 30;
  WidthPercent := 100;
  Font := zfTRIUMVIRATE;
end;

procedure TZPL2TextField.Draw(canvas: TCanvas; const aX, aY: word0_32000; Invert: boolean = false);
var
  bitmap: TBitmap;
  w, h: integer;
  stretch: double;
begin
  bitmap := TBitmap.Create;

  try
    GetBitmap(bitmap);
    bitmap.Transparent := not Invert; // Use transparency only in normal drawing mode, else the result looks ugly

    if Invert then
      InvertRect(bitmap.Canvas.Handle, Rect(0, 0, bitmap.Width, bitmap.Height));

    stretch := Width / Height;
    h := bitmap.canvas.TextHeight(Text);
    w := bitmap.canvas.TextWidth(Text);

    if not Printable then
    begin
      canvas.Brush.Color := clSilver;
      canvas.Pen.Color := canvas.Brush.Color;
    end;

    case Rotation of
      zrNO_ROTATION,
      zrROTATE_180_DEGREES:
      begin
        SetBounds(Left, Top, Round(w * stretch), h);

        if not Printable then
          canvas.Rectangle(aX, aY, aX + Round(w * stretch), aY + h);

        canvas.StretchDraw(Rect(aX, aY, aX + Round(w * stretch), aY + h), bitmap);
      end;

      zrROTATE_90_DEGREES,
      zrROTATE_270_DEGREES:
      begin
        SetBounds(Left, Top, h, Round(w * stretch));

        if not Printable then
          canvas.Rectangle(aX, aY, aY + h, aX + Round(w * stretch));

        canvas.StretchDraw(Rect(aX, aY, aX + h, aY + Round(w * stretch)), bitmap);
      end;
    end;
  finally
    bitmap.Free;
  end;
end;

procedure TZPL2TextField.GetBitmap(Bitmap: TBitmap);
var
  w, h: integer;
begin
  bitmap.canvas.Font.Style := bitmap.canvas.Font.Style + [fsBold];
  bitmap.canvas.Font.Orientation := ZPL2RotationDegree[Rotation] * 10;
  bitmap.canvas.Font.Height := FHeight;
  bitmap.canvas.Font.Color := clBlack;
  bitmap.canvas.Brush.Color := clWhite;
  bitmap.TransparentColor := clWhite;
  bitmap.canvas.Font.Name := 'Helvetica'; // Helvetica is almost (!) like printer font Triumvirate Cond.

  h := bitmap.canvas.TextHeight(Text);
  w := bitmap.canvas.TextWidth(Text);

  case Rotation of
    zrNO_ROTATION,
    zrROTATE_180_DEGREES: bitmap.SetSize(w, h);
    zrROTATE_90_DEGREES,
    zrROTATE_270_DEGREES: bitmap.SetSize(h, w);
  end;

  case Rotation of
    zrNO_ROTATION:        bitmap.canvas.TextOut(0, 0, Text);
    zrROTATE_90_DEGREES:  bitmap.canvas.TextOut(0, w, Text);
    zrROTATE_180_DEGREES: bitmap.canvas.TextOut(w, h, Text);
    zrROTATE_270_DEGREES: bitmap.canvas.TextOut(h, 0, Text);
  end;
end;

function TZPL2TextField.GetCommand: string;
begin
  result := FormatTextForLabel;
end;

function TZPL2TextField.GetWidthPercent: double;
begin
  result := FWidth * 100 / FHeight;
end;

procedure TZPL2TextField.SetFont(const Value: TZPL2Font);
begin
  FFont := Value;
  Invalidate;
end;

procedure TZPL2TextField.SetHeight(const Value: word10_32000);
begin
  FHeight := Value;
  Invalidate;
end;

procedure TZPL2TextField.SetWidth(const Value: word10_32000);
begin
  FWidth := Value;
  Invalidate;
end;

procedure TZPL2TextField.SetWidthPercent(const AWidthPercent: double);
begin
  if CompareValue(AWidthPercent, 5.0) = LessThanValue then
    raise Exception.Create('WidthPercent must not be lower than 5!');

  try
    FWidth := Round(AWidthPercent / 100 * FHeight);
    Invalidate;
  except
    on e:Exception do
    begin
      e.Message := 'Calculated Width is invalid: ' + IntToStr(Round(WidthPercent / 100 * FHeight)) + sLineBreak +
                   'Value has to be in range of 10 to 32000!';
      raise
    end;
  end;
end;

{$endregion}

{$region 'TZPL2TextLabelItem' }

constructor TZPL2TextLabelItem.Create(AOwner: TComponent);
begin
  inherited;
  Text := 'Text';
end;

function TZPL2TextLabelItem.FormatTextForLabel: string;
{$ifdef Unicode}
type
  zebra850string = type AnsiString(850);
{$endif}
var
  IncludesHex: boolean;
  tmp: {$ifdef Unicode}zebra850string{$else}string{$endif};
  s: string;
  i: integer;
begin
  s := '';
  IncludesHex := false;
  tmp := Text;

  {$ifndef Unicode}
  AnsiToAscii(tmp);
  {$endif}

  for i := 1 to Length(tmp) do
  begin
    if Ord(tmp[i]) < 126 then // Chr(126) = '~'
      s := s + tmp[i]
    else
    begin
      if not IncludesHex then
        IncludesHex := true;

      s := s + '_' + IntToHex(Ord(tmp[i]), 2);
    end;
  end;

  if not IncludesHex then
    result := ZPL2_FD + Text
  else
    result := ZPL2_FH + '_' + ZPL2_FD + s;
end;

procedure TZPL2TextLabelItem.SetText(const Value: string);
begin
  if Value = '' then
    raise Exception.Create('Text must not be empty!');

  if Length(Value) > 3072 then
    raise Exception.Create('Text length must not exceed more than 3072 characters!');

  FText := Value;
  Hint := Value;
  Invalidate;
end;

{$endregion}

end.
