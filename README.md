# Zebra
Create, edit and preview Zebra ZPL/ZPL2 labels

## Dependencies

1. [zint](https://github.com/TheDelphiCoder/Zint-Barcode-Generator-for-Delphi) framework for creating different kind of barcodes
1. [PerlRegEx](https://github.com/TheDelphiCoder/PerlRegEx) framework for Delphi versions **older** than Delphi XE,  
Delphi XE and newer use the build-in RegEx library:

```
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

> - **^A  
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
> - ^XZ**  
 
## Demo usage

To be continued...
