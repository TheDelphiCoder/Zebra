# Zebra
Create, edit and preview Zebra ZPL/ZPL2 labels

## Dependencies

1. [zint](https://github.com/TheDelphiCoder/Zint-Barcode-Generator-for-Delphi) framework for creating different kind of barcodes
1. [PerlRegEx](https://github.com/TheDelphiCoder/PerlRegEx) framework for Delphi versions **older** than Delphi XE,  
Delphi XE and newer use the build-in RegEx library:

```pascal
{$if CompilerVersion >= 22.0}
  System.UITypes,
  System.RegularExpressions,
  System.RegularExpressionsCore;
{$else}
  PerlRegEx;
{$ifend}
```

## Units

1. **ZPL2Label.pas**  
contains the "main" class of the framework: **``TZPL2Label``**  
It consists of different printing options for a label and stores the corresponding ZPL objects

1. **ZPL2.pas**  
contains the declaration of basic types used by different ZPL commands and ZPL command classes (except barcode commands!)

1. **ZPL2Barcodes.pas**  
contains the ZPL command classes for 1D (e.g. Code39, Code128) and 2D (e.g. DataMatrix, QR-Code) codes

1. **ZPL2Parser.pas**  
contains the class **``TZPL2Parser``** (only used by **``TZPL2Label``**).  
Parses a ZPL label string into it's objects and adds them to a **``TZPL2Label``**

1. **ZPL2Reg.pas**  
Used to register the ZPL classes as components in the IDE when used in a package

## Supported ZPL commands

> - ^A  
> - ^B3  
> - ^BC  
> - ^BQ  
> - ^BX  
> - ^BY  
> - ^CF  
> - ^CI  
> - ^FD  
> - ^FH  
> - ^FO  
> - ^FS  
> - ^FX  
> - ^GB  
> - ^GC  
> - ^GD  
> - ^GE  
> - ^GF  
> - ^LH  
> - ^LR  
> - ^MC  
> - ^MD  
> - ^MM  
> - ^MN  
> - ^MT  
> - ^PO  
> - ^PQ  
> - ^PR  
> - ^PW  
> - ^XA  
> - ^XB  
> - ^XZ
 
## Demo usage

```pascal
uses
  // [...]
  ZPL2, ZPL2Barcodes, ZPL2Label;
  
var
  zpl: TZPL2Label;
begin
  zpl := TZPL2Label.Create;
  
  try
    case rdogrpLabelItems.ItemIndex of
      0: ZPL2LabelItem := CreateBarcodeCode128(0, 0, 'Code128', 30);
      1: ZPL2LabelItem := CreateBarcodeCode39(0, 0, 'Code39', 30);
      2: ZPL2LabelItem := CreateBarcodeDatamatrix(0, 0, 'Datamatrix');
      3: ZPL2LabelItem := CreateBarcodeQR(0, 0, 'QR Code');
      4: ZPL2LabelItem := CreateGraphicBox(0, 0, 30, 30);
      5: ZPL2LabelItem := CreateGraphicDiagonalLine(0, 0, 30, 30);
      6: ZPL2LabelItem := CreateGraphicCircle(0, 0, 30);
      7: ZPL2LabelItem := CreateGraphicEllipse(0, 0, 40, 20);
      8:
      begin
        with TOpenPictureDialog.Create(nil) do
        try
          if Execute then
            ZPL2LabelItem := CreateGraphicField(0, 0, FileName)
          else
            exit;
        finally
          Free;
        end;
      end;
      9: ZPL2LabelItem := CreateTextField(0, 0, 'Text', 30);
      10: ZPL2LabelItem := CreateCommentField('Comment');
    else
      raise Exception.Create('Unknown index!');
    end;

    zpl.Items.Add(ZPL2LabelItem);
    mmoLabelText.Text := zpl.AsString;
    zpl.GetBitmap(imgLabel.Picture.Bitmap);
  finally
    zpl.Free;
  end;
end;
```
