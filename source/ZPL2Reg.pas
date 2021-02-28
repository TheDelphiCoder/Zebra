unit ZPL2Reg;

interface

uses
  Classes;

procedure Register;

implementation

{$R 'ZPL2.dcr'}

uses
  ZPL2, ZPL2Barcodes;

procedure Register;
begin
  RegisterComponents('ZPL2', [
                              TZPL2TextField,
                              TZPL2BarcodeCode128,
                              TZPL2BarcodeCode39,
                              TZPL2BarcodeDatamatrix,
                              TZPL2BarcodeQR,
                              TZPL2GraphicBox,
                              TZPL2GraphicCircle,
                              TZPL2GraphicDiagonalLine,
                              TZPL2GraphicEllipse,
                              TZPL2GraphicField,
                              TZPL2CommentField
                             ]);
end;


end.
