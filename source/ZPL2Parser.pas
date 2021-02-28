unit ZPL2Parser;

interface

uses
  Windows, SysUtils, Classes,
  ZPL2, ZPL2Barcodes, ZPL2Label;

type
  TZPL2Parser = class
  strict private
    FZPL2Label: TZPL2Label;

    procedure ParseACommand(const A_Command: string; ZPL2TextField: TZPL2TextField);

    procedure ParseBarcode128(const BC_Command, BY_Command, FO_Command, FD_Command: string);

    procedure ParseBarcode39(const B3_Command, BY_Command, FO_Command, FD_Command: string);

    procedure ParseB3Command(const B3_Command: string; ZPL2BarcodeCode39: TZPL2BarcodeCode39);

    procedure ParseBCCommand(const BC_Command: string; ZPL2BarcodeCode128: TZPL2BarcodeCode128);

    procedure ParseBQCommand(const BQ_Command: string; ZPL2BarcodeQR: TZPL2BarcodeQR);

    procedure ParseBXCommand(const BX_Command: string; ZPL2BarcodeDatamatrix: TZPL2BarcodeDatamatrix);

    procedure ParseBYCommand(const BY_Command: string; ZPL2Barcode1D: TZPL2Barcode1D);

    procedure ParseCFCommand(const CF_Command: string);
    /// <summary>
    ///  Parses the command for the international font settings.
    /// </summary>
    procedure ParseCICommand(const CI_Command: string);

    procedure ParseComment(const FX_Command: string);

    procedure ParseDatamatrix(const BX_Command, FO_Command, FD_Command: string);

    procedure ParseFDCommand(const FD_Command: string; ZPL2TextLabelItem: TZPL2TextLabelItem; FH: boolean = false;
      FH_Inidicator: char = #0);

    procedure ParseFOCommand(const FO_Command: string; ZPL2LabelItem: TZPL2LabelItem);

    procedure ParseFXCommand(const FX_Command: string; ZPL2CommentField: TZPL2CommentField);

    procedure ParseGBCommand(const GB_Command: string; ZPL2GraphicBox: TZPL2GraphicBox);

    procedure ParseGCCommand(const GC_Command: string; ZPL2GraphicCircle: TZPL2GraphicCircle);

    procedure ParseGDCommand(const GD_Command: string; ZPL2GraphicDiagonalLine: TZPL2GraphicDiagonalLine);

    procedure ParseGECommand(const GE_Command: string; ZPL2GraphicEllipse: TZPL2GraphicEllipse);

    procedure ParseGFCommand(GF_Command: string; ZPL2GraphicField: TZPL2GraphicField);

    procedure ParseGraphicBox(const GB_Command, FO_Command: string);

    procedure ParseGraphicCircle(const GC_Command, FO_Command: string);

    procedure ParseGraphicDiagonalLine(const GD_Command, FO_Command: string);

    procedure ParseGraphicEllipse(const GE_Command, FO_Command: string);

    procedure ParseGraphicField(const GF_Command, FO_Command: string);

    /// <summary>
    ///  Parses the command for the label home settings.
    /// </summary>
    procedure ParseLHCommand(const LH_Command: string);

    /// <summary>
    ///  Parses the command for the media darkness setting.
    /// </summary>
    procedure ParseMDCommand(const MD_Command: string);

    /// <summary>
    ///  Parses the command for the print quantity settings.
    /// </summary>
    procedure ParsePQCommand(const PQ_Command: string);

    /// <summary>
    ///  Parses the command for the print rate settings.
    /// </summary>
    procedure ParsePRCommand(const PR_Command: string);

    /// <summary>
    ///  Parses the command for the print width setting.
    /// </summary>
    procedure ParsePWCommand(const PW_Command: string);

    procedure ParseQRCode(const BQ_Command, FO_Command, FD_Command: string);

    procedure ParseRotation(const Rotation: char; ZPL2RotationLabelItem: TZPL2RotationLabelItem);

    procedure ParseTextField(const A_Command, FO_Command, FD_Command: string; const FH: boolean = false; const
      FH_Inidicator: char = #0);

  public
    /// <summary>
    ///  Parses the given data of the label to the item list and settings and checks for errors (throws exceptions!).
    /// </summary>
    procedure Parse(const LabelData: string; ZPL2Label: TZPL2Label);
  end;

implementation

uses
{$if CompilerVersion >= 22.0}
  System.UITypes,
  System.RegularExpressions,
  System.RegularExpressionsCore;
{$else}
  PerlRegEx;
{$ifend}

{$region 'Unit Methods'}

/// <summary>
///  Wrapper for Windows API OemToChar.
/// </summary>
procedure AsciiToAnsi(var s: string);
var
  buff: string;
begin
  if s <> '' then
  begin
    SetLength(buff, length(s) + 1);

    {$IFDEF UNICODE}
    if OemToCharW(PAnsiChar(AnsiString(s)), PWideChar(buff)) then
    {$ELSE}
    if OemToCharA(PChar(s), PChar(buff)) then
    {$ENDIF}
      s := Trim(string(buff));
  end;
end;

{$endregion}

{$region 'TZPL2Parser' }
procedure TZPL2Parser.Parse(const LabelData: string; ZPL2Label: TZPL2Label);
const
  REGEX_LABEL_PARSING = '(\^|~)[a-zA-Z][0-9a-zA-Z@][\S *(\r\n)]*(?=(\r\n)*\^|~|$)';
  INVALID_DATA = 'Invalid label data.';
var
  A,
  Barcode,
  BY,
  FO: string;
  FH: boolean;
  FH_Indicator: Char;
  sMatchedText: string;
begin
  A := '';
  BY := 'BY2';
  FO := '';
  FH_Indicator := #0;
  FH := false;

  if not Assigned(ZPL2Label)
    or (Trim(LabelData) = '')
  then
    exit;

  FZPL2Label := ZPL2Label;
  FZPL2Label.Init;

  with TPerlRegEx.Create do
  begin
    try
      Options := Options + [preUnGreedy];
      RegEx := REGEX_LABEL_PARSING;
      Subject := UTF8String(LabelData);

      if Match then
      begin
        sMatchedText := string(MatchedText);
        if Trim(sMatchedText) <> ZPL2_XA then
        begin
          raise EParserError.Create(INVALID_DATA + ' First command must be ''' + ZPL2_XA + '''!' + sLineBreak + 'Found: ''' + sMatchedText + '''');
        end;

        while MatchAgain do
        begin
          sMatchedText := string(MatchedText);

          {$REGION 'ZPL2_A  (Scaleable/Bitmapped font)'}
          if Pos(ZPL2_A, sMatchedText) = 1 then
          begin
            A := sMatchedText;
            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_B3 (Barcode Code 39)'}
          if Pos(ZPL2_B3, sMatchedText) = 1 then
          begin
            Barcode := sMatchedText;

            while MatchAgain do
            begin
              sMatchedText := string(MatchedText);

              if (Pos(ZPL2_FH, sMatchedText) = 1)
                or (Pos(ZPL2_FD, sMatchedText) = 1)
              then
              begin
                if (Pos(ZPL2_FH, sMatchedText) = 1) then
                begin
                  FH := true;
                  continue;
                end;

                if (Pos(ZPL2_FD, sMatchedText) = 1)
                then
                begin
                  ParseBarcode39(Barcode, BY, FO, sMatchedText);
                  FO := '';
                  FH := false;
                end
                else
                  raise EParserError.Create(INVALID_DATA + ' No ' + ZPL2_FD + ' command found after the ' + ZPL2_B3 + ' command ' + Barcode);
              end
              else
                raise EParserError.Create(INVALID_DATA + ' No (valid) command found after the ' + ZPL2_B3 + ' command ' + Barcode);

              break;
            end;

            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_BC (Barcode Code 128)'}
          if Pos(ZPL2_BC, sMatchedText) = 1 then
          begin
            Barcode := sMatchedText;

            while MatchAgain do
            begin
              sMatchedText := string(MatchedText);

              if (Pos(ZPL2_FH, sMatchedText) = 1)
                or (Pos(ZPL2_FD, sMatchedText) = 1)
              then
              begin
                if (Pos(ZPL2_FH, sMatchedText) = 1) then
                begin
                  FH := true;
                  continue;
                end;

                if (Pos(ZPL2_FD, sMatchedText) = 1)
                then
                begin
                  // delete Subset B start character
                  sMatchedText := StringReplace(sMatchedText, '>:', '', [rfReplaceAll]);
                  ParseBarcode128(Barcode, BY, FO, sMatchedText);
                  FO := '';
                  FH := false;
                end
                else
                  raise EParserError.Create(INVALID_DATA + ' No ' + ZPL2_FD + ' command found after the ' + ZPL2_BC + ' command ' + Barcode);
              end
              else
                raise EParserError.Create(INVALID_DATA + ' No (valid) command found after the ' + ZPL2_BC + ' command ' + Barcode);

              break;
            end;

            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_BQ (QR Code)'}
          if Pos(ZPL2_BQ, sMatchedText) = 1 then
          begin
            Barcode := sMatchedText;

            while MatchAgain do
            begin
              sMatchedText := string(MatchedText);

              if (Pos(ZPL2_FH, sMatchedText) = 1)
                or (Pos(ZPL2_FD, sMatchedText) = 1)
              then
              begin
                if (Pos(ZPL2_FH, sMatchedText) = 1) then
                begin
                  FH := true;
                  continue;
                end;

                if (Pos(ZPL2_FD, sMatchedText) = 1)
                then
                begin
                  ParseQRCode(Barcode, FO, sMatchedText);
                  FO := '';
                  FH := false;
                end
                else
                  raise EParserError.Create(INVALID_DATA + ' No ' + ZPL2_FD + ' command found after the ' + ZPL2_BQ + ' command ' + Barcode);
              end
              else
                raise EParserError.Create(INVALID_DATA + ' No (valid) command found after the ' + ZPL2_BQ + ' command ' + Barcode);

              break;
            end;

            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_BX (Datamatrix Code)'}
          if Pos(ZPL2_BX, sMatchedText) = 1 then
          begin
            Barcode := sMatchedText;

            while MatchAgain do
            begin
              sMatchedText := string(MatchedText);

              if (Pos(ZPL2_FH, sMatchedText) = 1)
                or (Pos(ZPL2_FD, sMatchedText) = 1)
              then
              begin
                if (Pos(ZPL2_FH, sMatchedText) = 1) then
                begin
                  FH := true;
                  continue;
                end;

                if (Pos(ZPL2_FD, sMatchedText) = 1) then
                begin
                  ParseDatamatrix(Barcode, FO, sMatchedText);
                  FO := '';
                  FH := false;
                end
                else
                  raise EParserError.Create(INVALID_DATA + ' No ' + ZPL2_FD + ' command found after the ' + ZPL2_BX + ' command ' + Barcode);
              end
              else
                raise EParserError.Create(INVALID_DATA + ' No (valid) command found after the ' + ZPL2_BX + ' command ' + Barcode);

              break;
            end;

            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_BY (Barcode Field Default)'}
          if Pos(ZPL2_BY, sMatchedText) = 1 then
          begin
            BY := sMatchedText;
            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_CF (Change International font)'}
          if Pos(ZPL2_CF, sMatchedText) = 1 then
          begin
            ParseCFCommand(sMatchedText);
            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_CI (Change International font)'}
          if Pos(ZPL2_CI, sMatchedText) = 1 then
          begin
            ParseCICommand(sMatchedText);
            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_FO (Field Orientation)'}
          if Pos(ZPL2_FO, sMatchedText) = 1 then
          begin
            FO := sMatchedText;
            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_FD (Field Data)'}
          if (Pos(ZPL2_FD, sMatchedText) = 1) then //and (A <> '') then
          begin
            ParseTextField(A, FO, sMatchedText, FH, FH_Indicator);
            A := '';
            FO := '';
            FH := false;
            FH_Indicator := #0;
            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_FH (Field Hexadezimal indicator)'}
          if Pos(ZPL2_FH, sMatchedText) = 1 then
          begin
            FH := true;

            if Length(MatchedText) > 3 then
              FH_Indicator := Char(MatchedText[4]);

            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_FX (Comment)'}
          if Pos(ZPL2_FX, sMatchedText) = 1 then
          begin
            ParseComment(sMatchedText);
            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_GB (Graphic Box)'}
          if Pos(ZPL2_GB, sMatchedText) = 1 then
          begin
            ParseGraphicBox(sMatchedText, FO);
            FO := '';
            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_GC (Graphic Circle)'}
          if Pos(ZPL2_GC, sMatchedText) = 1 then
          begin
            ParseGraphicCircle(sMatchedText, FO);
            FO := '';
            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_GD (Graphic Diagonal line)'}
          if Pos(ZPL2_GD, sMatchedText) = 1 then
          begin
            ParseGraphicDiagonalLine(sMatchedText, FO);

            FO := '';
            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_GE (Graphic Ellipse)'}
          if Pos(ZPL2_GE, sMatchedText) = 1 then
          begin
            ParseGraphicEllipse(sMatchedText, FO);
            FO := '';
            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_GF (Graphic Field)'}
          if Pos(ZPL2_GF, sMatchedText) = 1 then
          begin
            ParseGraphicField(sMatchedText, FO);
            FO := '';
            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_LH (Label Home)'}
          if Pos(ZPL2_LH, sMatchedText) = 1 then
          begin
            ParseLHCommand(sMatchedText);
            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_LR (Label Reverse print)'}
          if Pos(ZPL2_LR, sMatchedText) = 1 then
          begin
            if Length(sMatchedText) > 3 then
            begin
              case MatchedText[4] of
                'Y': FZPL2Label.LabelReversePrint := true;
                'N': FZPL2Label.LabelReversePrint := false;
              else
                raise EParserError.Create('Invalid label reverse print data (value): ' + MatchedText[4]);
              end;
            end
            else
              raise EParserError.Create('Invalid label reverse print data: ' + sMatchedText);

            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_MC (Map Clear)'}
          if Pos(ZPL2_MC, sMatchedText) = 1 then
          begin
            if Length(MatchedText) > 3 then
            begin
              case MatchedText[4] of
                'Y': FZPL2Label.MapClear := true;
                'N': FZPL2Label.MapClear := false;
              else
                raise EParserError.Create('Invalid map clear data (value): ' + MatchedText[4]);
              end;
            end
            else
              raise EParserError.Create('Invalid map clear data: ' + sMatchedText);

            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_MD (Media Darkness)'}
          if Pos(ZPL2_MD, sMatchedText) = 1 then
          begin
            ParseMDCommand(sMatchedText);
            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_MM (Print Mode)'}
          if Pos(ZPL2_MM, sMatchedText) = 1 then
          begin
            if Length(sMatchedText) > 3 then
            begin
              case MatchedText[4] of
                'T': FZPL2Label.PrintMode := pmTearOff;
                'P': FZPL2Label.PrintMode := pmPeelOff;
                'R': FZPL2Label.PrintMode := pmRewind;
                'A': FZPL2Label.PrintMode := pmApplicator;
                'C': FZPL2Label.PrintMode := pmCutter;
              else
                raise EParserError.Create('Invalid print mode data (value): ' + MatchedText[4]);
              end;
            end
            else
              raise EParserError.Create('Invalid print mode data: ' + sMatchedText);

            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_MN (Media Tracking)'}
          if Pos(ZPL2_MN, sMatchedText) = 1 then
          begin
            if Length(sMatchedText) > 3 then
            begin
              case MatchedText[4] of
                'N': FZPL2Label.MediaTracking := mnContinuous;
                'Y',
                'W': FZPL2Label.MediaTracking := mnNonContinuousWeb;
                'M': FZPL2Label.MediaTracking := mnNonContinuousMark;
              else
                raise EParserError.Create('Invalid media tracking data (value): ' + MatchedText[4]);
              end;
            end
            else
              raise EParserError.Create('Invalid media tracking data: ' + sMatchedText);

            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_MT (Media Type)'}
          if Pos(ZPL2_MT, sMatchedText) = 1 then
          begin
            if Length(sMatchedText) > 3 then
            begin
              case MatchedText[4] of
                'T': FZPL2Label.MediaType := mtThermalTransferMedia;
                'D': FZPL2Label.MediaType := mtDirectThermalMedia;
              else
                raise EParserError.Create('Invalid media type data (value): ' + MatchedText[4]);
              end;
            end
            else
              raise EParserError.Create('Invalid media type data: ' + sMatchedText);

            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_PO (Print Orientation)'}
          if Pos(ZPL2_PO, sMatchedText) = 1 then
          begin
            if Length(sMatchedText) > 3 then
            begin
              case MatchedText[4] of
                'I': FZPL2Label.PrintUpsideDown := true;
                'N': FZPL2Label.PrintUpsideDown := false;
              else
                raise EParserError.Create('Invalid print orientation data (value): ' + MatchedText[4]);
              end;
            end
            else
              raise EParserError.Create('Invalid print orientation data: ' + sMatchedText);

            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_PQ (Print Quantity)'}
          if Pos(ZPL2_PQ, sMatchedText) = 1 then
          begin
            ParsePQCommand(sMatchedText);
            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_PR (Print Rate)'}
          if Pos(ZPL2_PR, sMatchedText) = 1 then
          begin
            ParsePRCommand(sMatchedText);
            continue;
          end;
          {$ENDREGION}

          {$REGION 'ZPL2_PW (Print Width)'}
          if Pos(ZPL2_PW, sMatchedText) = 1 then
          begin
            ParsePWCommand(sMatchedText);
            continue;
          end;
          {$ENDREGION}

          if Pos(ZPL2_XA, sMatchedText) = 1 then
            continue;

          {$REGION 'ZPL2_XB (Suppress Backfeed)'}
          if Pos(ZPL2_XB, sMatchedText) = 1 then
          begin
            FZPL2Label.SuppressBackfeed := true;
            continue;
          end;
          {$ENDREGION}

          if Pos(ZPL2_XZ, sMatchedText) = 1 then
            continue;
        end;
      end
      else
        raise EParserError.Create('Invalid ZPL2 file');
    finally
      Free;
    end;
  end;
end;

procedure TZPL2Parser.ParseACommand(const A_Command: string; ZPL2TextField: TZPL2TextField);
const
  INVALID_DATA = 'Invalid font data';
begin
  with TPerlRegEx.Create do
  begin
    try
      RegEx := '\' + ZPL2_A + '[A-Z0-9][NRIB],\d{1,5},\d{1,5}';
      Subject := UTF8String(A_Command);

      if Match then
      begin
        try
          ZPL2TextField.Font := TZPL2Font(Ord(MatchedText[3]));
        except
          raise EParserError.Create(INVALID_DATA + ' (font character): ' + MatchedText[3]);
        end;

        ParseRotation(Char(MatchedText[4]), ZPL2TextField);

        RegEx := '\b\d{1,5}\b';
        Subject := UTF8String(A_Command);

        if Match then
        begin
          try
            ZPL2TextField.Height := StrToInt(string(MatchedText));
          except
            raise EParserError.Create(INVALID_DATA + ' (font height value): ' + string(MatchedText));
          end;

          if MatchAgain then
          begin
            try
              ZPL2TextField.Width := StrToInt(string(MatchedText));
            except
              raise EParserError.Create(INVALID_DATA + ' (font width value): ' + string(MatchedText));
            end;
          end;
        end
        else
          raise EParserError.Create(INVALID_DATA + ' (font width and/or height value): ' + A_Command);
      end
      else
        raise EParserError.Create(INVALID_DATA + ': ' + A_Command);
    finally
      Free;
    end;
  end;
end;

procedure TZPL2Parser.ParseB3Command(const B3_Command: string; ZPL2BarcodeCode39: TZPL2BarcodeCode39);
const
  INVALID_DATA = 'Invalid Code39 data';
begin
  with TPerlRegEx.Create do
  begin
    try
      RegEx := '\' + ZPL2_B3 + '[NRIB],[YN],\d{1,5},[YN],[YN]';
      Subject := UTF8String(B3_Command);

      if Match then
      begin
        ParseRotation(Char(MatchedText[4]), ZPL2BarcodeCode39);

        RegEx := '\b\w+\b';
        Subject := UTF8String(Copy(B3_Command, 6, Length(B3_Command) - 5));

        if Match then
        begin
          try
            case MatchedText[1] of
              'Y': ZPL2BarcodeCode39.Mod43CheckDigit := true;
            else
              ZPL2BarcodeCode39.Mod43CheckDigit := false;
            end;
          except
            raise EParserError.Create(INVALID_DATA + ' ( Mod 43 check digit value): ' + string(MatchedText));
          end;

          if MatchAgain then
            begin
            try
              ZPL2BarcodeCode39.Height := StrToInt(string(MatchedText));
            except
              raise EParserError.Create(INVALID_DATA + ' (barcode height value): ' + string(MatchedText));
            end;
          end;

          if MatchAgain then
          begin
            try
              case MatchedText[1] of
                'Y': ZPL2BarcodeCode39.PrintInterpretationLine := true;
              else
                ZPL2BarcodeCode39.PrintInterpretationLine := false;
              end;
            except
              raise EParserError.Create(INVALID_DATA + ' (print interpretation line value): ' + string(MatchedText));
            end;
          end;

          if MatchAgain then
          begin
            try
              case MatchedText[1] of
                'Y': ZPL2BarcodeCode39.PrintInterpretationLineAboveCode := true;
              else
                ZPL2BarcodeCode39.PrintInterpretationLineAboveCode := false;
              end;
            except
              raise EParserError.Create(INVALID_DATA + ' (print interpretation line above code value): ' + string(MatchedText));
            end;
          end;
        end;
      end
      else
        raise EParserError.Create(INVALID_DATA + ': ' + B3_Command);
    finally
      Free;
    end;
  end;
end;

procedure TZPL2Parser.ParseBarcode128(const BC_Command, BY_Command, FO_Command, FD_Command: string);
var
  ZPL2BarcodeCode128: TZPL2BarcodeCode128;
begin
  ZPL2BarcodeCode128 := TZPL2BarcodeCode128.Create(nil);

  try
    ParseFOCommand(FO_Command, ZPL2BarcodeCode128);
    ParseBYCommand(BY_Command, ZPL2BarcodeCode128);
    ParseBCCommand(BC_Command, ZPL2BarcodeCode128);
    ParseFDCommand(FD_Command, ZPL2BarcodeCode128);
    FZPL2Label.Items.Add(ZPL2BarcodeCode128);
  except
    ZPL2BarcodeCode128.Free;
    raise;
  end;
end;

procedure TZPL2Parser.ParseBarcode39(const B3_Command, BY_Command, FO_Command, FD_Command: string);
var
  ZPL2BarcodeCode39: TZPL2BarcodeCode39;
begin
  ZPL2BarcodeCode39 := TZPL2BarcodeCode39.Create(nil);

  try
    ParseFOCommand(FO_Command, ZPL2BarcodeCode39);
    ParseBYCommand(BY_Command, ZPL2BarcodeCode39);
    ParseB3Command(B3_Command, ZPL2BarcodeCode39);
    ParseFDCommand(FD_Command, ZPL2BarcodeCode39);
    FZPL2Label.Items.Add(ZPL2BarcodeCode39);
  except
    ZPL2BarcodeCode39.Free;
    raise;
  end;
end;

procedure TZPL2Parser.ParseBCCommand(const BC_Command: string; ZPL2BarcodeCode128: TZPL2BarcodeCode128);
const
  INVALID_DATA = 'Invalid Code128 data';
var
  PerlRegEx: TPerlRegEx;
begin
  PerlRegEx := TPerlRegEx.Create;

  try
    PerlRegEx.RegEx := '\' + ZPL2_BC + '[NRIB],(\d{1,5})?,([YN])?,([YN])?(,([YN])?(,([NUAD])?)?)?';
    PerlRegEx.Subject := UTF8String(BC_Command);

    if PerlRegEx.Match then
    begin
      ParseRotation(Char(PerlRegEx.MatchedText[4]), ZPL2BarcodeCode128);

      PerlRegEx.RegEx := '\b\w+\b';
      PerlRegEx.Subject := UTF8String(Copy(BC_Command, Length(ZPL2_BC) + 3, Length(BC_Command) - Length(ZPL2_BC) - 1));

      if PerlRegEx.Match then
      begin
        if PerlRegEx.MatchedText <> '' then
        begin
          try
            ZPL2BarcodeCode128.Height := StrToInt(string(PerlRegEx.MatchedText));
          except
            raise EParserError.Create(INVALID_DATA + ' (barcode height value): ' + string(PerlRegEx.MatchedText));
          end;
        end;

        if PerlRegEx.MatchAgain then
        begin
          if PerlRegEx.MatchedText <> '' then
          begin
            try
              case PerlRegEx.MatchedText[1] of
                'Y': ZPL2BarcodeCode128.PrintInterpretationLine := true;
              else
                ZPL2BarcodeCode128.PrintInterpretationLine := false;
              end;
            except
              raise EParserError.Create(INVALID_DATA + ' (print interpretation line value): ' + string(PerlRegEx.MatchedText));
            end;
          end
          else
            ZPL2BarcodeCode128.PrintInterpretationLine := true;
        end;

        if PerlRegEx.MatchAgain then
        begin
          if PerlRegEx.MatchedText <> '' then
          begin
            try
              case PerlRegEx.MatchedText[1] of
                'Y': ZPL2BarcodeCode128.PrintInterpretationLineAboveCode := true;
              else
                ZPL2BarcodeCode128.PrintInterpretationLineAboveCode := false;
              end;
            except
              raise EParserError.Create(INVALID_DATA + ' (print interpretation line above code value): ' + string(PerlRegEx.MatchedText));
            end;
          end
          else
            ZPL2BarcodeCode128.PrintInterpretationLineAboveCode := false;
        end;
      end;
    end
    else
      raise EParserError.Create(INVALID_DATA + ': ' + BC_Command);
  finally
    PerlRegEx.Free;
  end;
end;

procedure TZPL2Parser.ParseBQCommand(const BQ_Command: string; ZPL2BarcodeQR: TZPL2BarcodeQR);
const
  INVALID_DATA = 'Invalid QR code data';
begin
  with TPerlRegEx.Create do
  begin
    try
      RegEx := '\' + ZPL2_BQ + '[N],(1|2),(\d|10)';
      Subject := UTF8String(BQ_Command);

      if Match then
      begin
        ParseRotation('N', ZPL2BarcodeQR);

        RegEx := '\b\d{1,2}\b';
        Subject := UTF8String(BQ_Command);

        if Match then
        begin
          // ignore QR model, use always model 2
          if MatchAgain then
          begin
            try
              ZPL2BarcodeQR.MagnificationFactor := StrToInt(string(MatchedText));
            except
              raise EParserError.Create(INVALID_DATA + ' (magnification factor value): ' + string(MatchedText));
            end;
          end;
        end
        else
          raise EParserError.Create(INVALID_DATA + ' (model and/or magnification factor value): ' + BQ_Command);
      end
      else
        raise EParserError.Create(INVALID_DATA + ': ' + BQ_Command);
    finally
      Free;
    end;
  end;
end;

procedure TZPL2Parser.ParseBXCommand(const BX_Command: string; ZPL2BarcodeDatamatrix: TZPL2BarcodeDatamatrix);
const
  INVALID_DATA = 'Invalid datamatrix data';
begin
  with TPerlRegEx.Create do
  begin
    try
      RegEx := '\' + ZPL2_BX + '[NRIB],\d{1,4},(5|8|10|14|20)?0,(\d{1,2})?,(\d{1,2})?,([1-6])?,([\S])?';
      Subject := UTF8String(BX_Command);

      if Match then
      begin
        ParseRotation(Char(MatchedText[4]), ZPL2BarcodeDatamatrix);

        RegEx := '\b\d{1,5}\b';
        Subject := UTF8String(BX_Command);

        if Match then
        begin
          try
            ZPL2BarcodeDatamatrix.Modulsize := StrToInt(string(MatchedText));
          except
            raise EParserError.Create(INVALID_DATA + ' (modul size value): ' + string(MatchedText));
          end;

          if MatchAgain then
          begin
            try
              case StrToInt(string(MatchedText)) of
                0: ZPL2BarcodeDatamatrix.QualityLevel := ql_0;
                50: ZPL2BarcodeDatamatrix.QualityLevel := ql_50;
                80: ZPL2BarcodeDatamatrix.QualityLevel := ql_80;
                100: ZPL2BarcodeDatamatrix.QualityLevel := ql_100;
                140: ZPL2BarcodeDatamatrix.QualityLevel := ql_140;
                200: ZPL2BarcodeDatamatrix.QualityLevel := ql_200;
              end;
            except
              raise EParserError.Create(INVALID_DATA + ' (quality level value): ' + string(MatchedText));
            end;
          end;
        end
        else
          raise EParserError.Create(INVALID_DATA + ' (modul size and/or quality level value): ' + BX_Command);
      end
      else
        raise EParserError.Create(INVALID_DATA + ': ' + BX_Command);
    finally
      Free;
    end;
  end;
end;

procedure TZPL2Parser.ParseBYCommand(const BY_Command: string; ZPL2Barcode1D: TZPL2Barcode1D);
const
  INVALID_DATA = 'Invalid Barcode data';
begin
  with TPerlRegEx.Create do
  begin
    try
      RegEx := '\' + ZPL2_BY + '(\d|10)(,[23]\.\d)?';
      Subject := UTF8String(BY_Command);

      if Match then
      begin
        RegEx := '\b\w+\b';
        Subject := UTF8String(Copy(BY_Command, 4, Length(BY_Command) - 4));

        if Match then
        begin
          try
            ZPL2Barcode1D.Linewidth := StrToInt(string(MatchedText));
          except
            raise EParserError.Create(INVALID_DATA + ' (' + ZPL2_BY + ' command): ' + BY_Command);
          end;
        end;

        if MatchAgain then
        begin
          // wide bar to narrow bar width ratio is not used
        end;

        if MatchAgain then
        begin
          try
            ZPL2Barcode1D.Height := StrToInt(string(MatchedText));
          except
            raise EParserError.Create(INVALID_DATA + ' (' + ZPL2_BY + ' command): ' + BY_Command);
          end;
        end;
      end;
    finally
      Free;
    end;
  end;
end;

procedure TZPL2Parser.ParseCFCommand(const CF_Command: string);
const
  INVALID_DATA = 'Invalid change default font data';
var
//  s: string;
  h, w: string;
  ZPL2CFItem: TZPL2CFItem;
begin
  h := '';
  w := '';
  ZPL2CFItem := TZPL2CFItem.Create(nil);

  try
    with TPerlRegEx.Create do
    begin
      try
        RegEx := '\' + ZPL2_CF + '[A-Z0-9](,(\d{1,5})?)?(,\d{1,5})?';
        Subject := UTF8String(CF_Command);

        if Match then
        begin
          //s := string(MatchedText);

          RegEx := '\b\w*\b';
          Subject := UTF8String(Copy(CF_Command, Length(ZPL2_CF) + 1, Length(CF_Command) - Length(ZPL2_CF)));

          if Match then
          begin
            if Length(MatchedText) = 1 then
              ZPL2CFItem.Font := TZPL2Font(Ord(MatchedText[1]))
            else
              raise EParserError.Create(INVALID_DATA + ' (font value must contain 1 character): ' + MatchedText);
          end
          else
            raise EParserError.Create(INVALID_DATA + ' (value): ' + CF_Command);

          if MatchAgain then
            h := MatchedText;

          if MatchAgain then
            w := MatchedText;

          if (h = '') and (w = '') then
            exit;

          if h = '' then
          begin
            ZPL2CFItem.Height_Empty := true;
            h := w;
          end;

          if w = '' then
          begin
            ZPL2CFItem.Width_Empty := true;
            w := h;
          end;

          try
            ZPL2CFItem.Height := StrToIntDef(h, FZPL2Label.CF.Height);
            ZPL2CFItem.Width:= StrToIntDef(w, FZPL2Label.CF.Width);
          except
            raise EParserError.Create(INVALID_DATA + '(width and/or height out of allowed range): ' + CF_Command);
          end;

          FZPL2Label.Items.Add(ZPL2CFItem);
        end
        else
          raise EParserError.Create(INVALID_DATA + ': ' + CF_Command);
      finally
        Free;
      end;
    end;
  except
    ZPL2CFItem.Free;
    raise;
  end;
end;

procedure TZPL2Parser.ParseCICommand(const CI_Command: string);
const
  INVALID_DATA = 'Invalid change international font data';
var
  s: string;
begin
  with TPerlRegEx.Create do
  begin
    try
      RegEx := '\' + ZPL2_CI + '([12])?\d((,\d{1,3},\d{1,3}){1,256})?';
      Subject := UTF8String(CI_Command);

      if Match then
      begin
        s := string(MatchedText);
        Delete(s, 1, 3);
        Delete(s, Pos(',', s), Length(s) - Pos(',', s) + 1);

        try
          FZPL2Label.InternationalFont := TZPL2InternationalFont(StrToInt(s));
        except
          raise EParserError.Create(INVALID_DATA + ' (value): ' + s);
        end;
      end
      else
        raise EParserError.Create(INVALID_DATA + ': ' + CI_Command);
    finally
      Free;
    end;
  end;
end;

procedure TZPL2Parser.ParseComment(const FX_Command: string);
var
  ZPL2CommentField: TZPL2CommentField;
begin
  ZPL2CommentField := TZPL2CommentField.Create(nil);

  try
    ParseFXCommand(FX_Command, ZPL2CommentField);
    FZPL2Label.Items.Add(ZPL2CommentField);
  except
    ZPL2CommentField.Free;
    raise;
  end;
end;

procedure TZPL2Parser.ParseDatamatrix(const BX_Command, FO_Command, FD_Command: string);
var
  ZPL2BarcodeDatamatrix: TZPL2BarcodeDatamatrix;
begin
  ZPL2BarcodeDatamatrix := TZPL2BarcodeDatamatrix.Create(nil);

  try
    ParseFOCommand(FO_Command, ZPL2BarcodeDatamatrix);
    ParseBXCommand(BX_Command, ZPL2BarcodeDatamatrix);
    ParseFDCommand(FD_Command, ZPL2BarcodeDatamatrix);
    FZPL2Label.Items.Add(ZPL2BarcodeDatamatrix);
  except
    ZPL2BarcodeDatamatrix.Free;
    raise;
  end;
end;

procedure TZPL2Parser.ParseFDCommand(const FD_Command: string; ZPL2TextLabelItem: TZPL2TextLabelItem; FH: boolean; FH_Inidicator: char);
var
  s: string;
begin
  with TPerlRegEx.Create do
  begin
    try
      RegEx := '\' + ZPL2_FD + '[\S *]{1,3072}';
      Subject := UTF8String(FD_Command);

      if Match then
      begin
        // convert hex characters
        if FH then
        begin
          if FH_Inidicator = #0 then
            FH_Inidicator := '_';

          RegEx := UTF8String(FH_Inidicator) + '[0-9A-Fa-f]{2}';
          Subject := UTF8String(Copy(FD_Command, 4, Length(FD_Command) - 3));

          if Match then
          begin
            s := string(AnsiChar(StrToInt('$' + Copy(string(MatchedText), 2, 2))));
            AsciiToAnsi(s);
            Replacement := UTF8String(s);
            Replace;

            while MatchAgain do
            begin
              s := string(AnsiChar(StrToInt('$' + Copy(string(MatchedText), 2, 2))));
              AsciiToAnsi(s);
              Replacement := UTF8String(s);
              Replace;
            end;
          end;

          ZPL2TextLabelItem.Text := string(Subject);
        end
        else
          ZPL2TextLabelItem.Text := Copy(FD_Command, 4, Length(FD_Command) - 3);
      end
      else
        raise EParserError.Create('Invalid field data: ' + FD_Command);
    finally
      Free;
    end;
  end;
end;

procedure TZPL2Parser.ParseFOCommand(const FO_Command: string; ZPL2LabelItem: TZPL2LabelItem);
var
  s: UTF8String;
begin
  with TPerlRegEx.Create do
  begin
    try
      RegEx := '\' + ZPL2_FO + '(\d{1,5})?,(\d{1,5})?';
      Subject := UTF8String(FO_Command);

      if Match then
      begin
        s := MatchedText;
        RegEx := '\d{1,5}(?=,)';
        Subject := s;

        if Match then
        begin
          try
            ZPL2LabelItem.X := StrToInt(string(MatchedText));
          except
            raise EParserError.Create('Invalid field origin data (x coordinate value): ' + MatchedText);
          end;
        end
        else
          ZPL2LabelItem.X := 0;

        RegEx := '(?<=,)\d{1,5}';

        if Match then
        begin
          try
            ZPL2LabelItem.Y := StrToInt(string(MatchedText));
          except
            raise EParserError.Create('Invalid field origin data (y coordinate value): ' + MatchedText);
          end;
        end
        else
          ZPL2LabelItem.Y := 0;
      end
      else
        raise EParserError.Create('Invalid field origin data: ' + MatchedText);
    finally
      Free;
    end;
  end;
end;

procedure TZPL2Parser.ParseFXCommand(const FX_Command: string; ZPL2CommentField: TZPL2CommentField);
begin
  with TPerlRegEx.Create do
  begin
    try
      RegEx := '\' + ZPL2_FX + '[\S *]+';
      Subject := UTF8String(FX_Command);

      if Match then
        ZPL2CommentField.Text := Copy(FX_Command, 4, Length(FX_Command) - 3)
      else
        raise EParserError.Create('Invalid comment field data: ' + FX_Command);
    finally
      Free;
    end;
  end;
end;

procedure TZPL2Parser.ParseGBCommand(const GB_Command: string; ZPL2GraphicBox: TZPL2GraphicBox);
const
  INVALID_DATA = 'Invalid graphic box data';
var
  s: UTF8String;
begin
  with TPerlRegEx.Create do
  begin
    try
      RegEx := '\' + ZPL2_GB + '(\d{1,5})?(,(\d{1,5})?){2}([BW])?(,[0-8])?';
      Subject := UTF8String(GB_Command);

      if Match then
      begin
        s := MatchedText;
        Delete(s, 1, 3);
        RegEx := '[^,]*';
        Subject := s;

        if Match then
        begin
          if MatchedText <> '' then
          begin
            try
              if StrToInt(string(MatchedText)) > 0 then
                ZPL2GraphicBox.Width := StrToInt(string(MatchedText))
              else
                ZPL2GraphicBox.Width := 1;
            except
              raise EParserError.Create(INVALID_DATA + ' (width value): ' + string(MatchedText));
            end;
          end
          else
            ZPL2GraphicBox.Width := 1;

          if MatchAgain then
          begin
            if MatchedText <> '' then
            begin
              try
                if StrToInt(string(MatchedText)) > 0 then
                  ZPL2GraphicBox.Height := StrToInt(string(MatchedText))
                else
                  ZPL2GraphicBox.Height := 1;
              except
                raise EParserError.Create(INVALID_DATA + ' (height value): ' + string(MatchedText));
              end;
            end
            else
              ZPL2GraphicBox.Height := 1;
          end;

          if MatchAgain then
          begin
            if MatchedText <> '' then
            begin
              try
                if StrToInt(string(MatchedText)) > 0 then
                  ZPL2GraphicBox.Border := StrToInt(string(MatchedText))
                else
                  ZPL2GraphicBox.Border := 1;
              except
                raise EParserError.Create(INVALID_DATA + ' (border thickness value): ' + string(MatchedText));
              end;
            end
            else
              ZPL2GraphicBox.Border := 1;
          end;

          if MatchAgain then
          begin
            if MatchedText <> '' then
            begin
              try
                case MatchedText[1] of
                  'B': ZPL2GraphicBox.LineColor := lcBlack;
                  'W': ZPL2GraphicBox.LineColor := lcWhite;
                else
                  ZPL2GraphicBox.LineColor := lcBlack;
                end;
              except
                raise EParserError.Create(INVALID_DATA + ' (line color value): ' + string(MatchedText));
              end;
            end
            else
              ZPL2GraphicBox.LineColor := lcBlack;
          end;

          if MatchAgain then
          begin
            if MatchedText <> '' then
            begin
              try
                ZPL2GraphicBox.CornerRounding := StrToInt(string(MatchedText));
              except
                raise EParserError.Create(INVALID_DATA + ' (corner roundness value): ' + string(MatchedText));
              end;
            end
            else
              ZPL2GraphicBox.CornerRounding := 0;
          end;
        end;
      end
      else
        raise EParserError.Create(INVALID_DATA + ': ' + GB_Command);
    finally
      Free;
    end;
  end;
end;

procedure TZPL2Parser.ParseGCCommand(const GC_Command: string; ZPL2GraphicCircle: TZPL2GraphicCircle);
const
  INVALID_DATA = 'Invalid graphic circle data';
var
  s: UTF8String;
begin
  with TPerlRegEx.Create do
  begin
    try
      RegEx := '\' + ZPL2_GC + '(\d{1,4},){2}[BW]';
      Subject := UTF8String(GC_Command);

      if Match then
      begin
        s := MatchedText;
        Delete(s, 1, 3);
        RegEx := '\b\w+\b';
        Subject := s;

        if Match then
        begin
          try
            ZPL2GraphicCircle.Diameter := StrToInt(string(MatchedText));
          except
            raise EParserError.Create(INVALID_DATA + ' (diameter value): ' + string(MatchedText));
          end;

          if MatchAgain then
          begin
            try
              ZPL2GraphicCircle.Border := StrToInt(string(MatchedText));
            except
              raise EParserError.Create(INVALID_DATA + ' (border thickness value): ' + string(MatchedText));
            end;
          end;

          if MatchAgain then
          begin
            try
              case MatchedText[1] of
                'B': ZPL2GraphicCircle.LineColor := lcBlack;
                'W': ZPL2GraphicCircle.LineColor := lcWhite;
              else
                ZPL2GraphicCircle.LineColor := lcBlack;
              end;
            except
              raise EParserError.Create(INVALID_DATA + ' (line color value): ' + string(MatchedText));
            end;
          end;
        end;
      end
      else
        raise EParserError.Create(INVALID_DATA + ': ' + GC_Command);
    finally
      Free;
    end;
  end;
end;

procedure TZPL2Parser.ParseGDCommand(const GD_Command: string; ZPL2GraphicDiagonalLine: TZPL2GraphicDiagonalLine);
const
  INVALID_DATA = 'Invalid graphic diagonal line data';
var
  s: UTF8String;
begin
  with TPerlRegEx.Create do
  begin
    try
      RegEx := '\' + ZPL2_GD + '(\d{1,4},){3}[BW],[LR/\\]';
      Subject := UTF8String(GD_Command);

      if Match then
      begin
        s := MatchedText;
        Delete(s, 1, 3);
        RegEx := '\b\w+\b';
        Subject := s;

        if Match then
        begin
          try
            ZPL2GraphicDiagonalLine.Width := StrToInt(string(MatchedText));
          except
            raise EParserError.Create(INVALID_DATA + ' (width value): ' + string(MatchedText));
          end;

          if MatchAgain then
          begin
            try
              ZPL2GraphicDiagonalLine.Height := StrToInt(string(MatchedText));
            except
              raise EParserError.Create(INVALID_DATA + ' (height value): ' + string(MatchedText));
            end;
          end;

          if MatchAgain then
          begin
            try
              ZPL2GraphicDiagonalLine.Border := StrToInt(string(MatchedText));
            except
              raise EParserError.Create(INVALID_DATA + ' (border thickness value): ' + string(MatchedText));
            end;
          end;

          if MatchAgain then
          begin
            try
              case MatchedText[1] of
                'B': ZPL2GraphicDiagonalLine.LineColor := lcBlack;
                'W': ZPL2GraphicDiagonalLine.LineColor := lcWhite;
              else
                ZPL2GraphicDiagonalLine.LineColor := lcBlack;
              end;
            except
              raise EParserError.Create(INVALID_DATA + ' (line color value): ' + string(MatchedText));
            end;
          end;

          if MatchAgain then
          begin
            case MatchedText[1] of
              'R', '/': ZPL2GraphicDiagonalLine.Orientation := loRightLeaning;
              'L', '\': ZPL2GraphicDiagonalLine.Orientation := loLeftLeaning;
            else
              raise EParserError.Create(INVALID_DATA + ' (line orientation value): ' + string(MatchedText));
            end;
          end;
        end;
      end
      else
        raise EParserError.Create(INVALID_DATA + ': ' + GD_Command);
    finally
      Free;
    end;
  end;
end;

procedure TZPL2Parser.ParseGECommand(const GE_Command: string; ZPL2GraphicEllipse: TZPL2GraphicEllipse);
const
  INVALID_DATA = 'Invalid graphic ellipse data';
var
  s: UTF8String;
begin
  with TPerlRegEx.Create do
  begin
    try
      RegEx := '\' + ZPL2_GE + '(\d{1,4},){3}[BW]';
      Subject := UTF8String(GE_Command);

      if Match then
      begin
        s := MatchedText;
        Delete(s, 1, 3);
        RegEx := '\b\w+\b';
        Subject := s;

        if Match then
        begin
          try
            ZPL2GraphicEllipse.Width := StrToInt(string(MatchedText));
          except
            raise EParserError.Create(INVALID_DATA + ' (width value): ' + string(MatchedText));
          end;

          if MatchAgain then
          begin
            try
              ZPL2GraphicEllipse.Height := StrToInt(string(MatchedText));
            except
              raise EParserError.Create(INVALID_DATA + ' (height value): ' + string(MatchedText));
            end;
          end;

          if MatchAgain then
          begin
            try
              ZPL2GraphicEllipse.Border := StrToInt(string(MatchedText));
            except
              raise EParserError.Create(INVALID_DATA + ' (border thickness value): ' + string(MatchedText));
            end;
          end;

          if MatchAgain then
          begin
            try
              case MatchedText[1] of
                'B': ZPL2GraphicEllipse.LineColor := lcBlack;
                'W': ZPL2GraphicEllipse.LineColor := lcWhite;
              else
                ZPL2GraphicEllipse.LineColor := lcBlack;
              end;
            except
              raise EParserError.Create(INVALID_DATA + ' (line color value): ' + string(MatchedText));
            end;
          end;
        end;
      end
      else
        raise EParserError.Create(INVALID_DATA + ': ' + GE_Command);
    finally
      Free;
    end;
  end;
end;

procedure TZPL2Parser.ParseGFCommand(GF_Command: string; ZPL2GraphicField: TZPL2GraphicField);
const
  INVALID_DATA = 'Invalid graphic field data';
var
  i, j: integer;
  Bytes,
  BytesPerRow,
  Max_Len: word;
  s: UTF8String;
  s1,
  Data: string;
  Rows: TStrings;
begin
  Bytes := 0;
  BytesPerRow := 0;

  with TPerlRegEx.Create do
  begin
    try
      RegEx := '\' + ZPL2_GF + 'A,(\d{1,5},){3}';
      Subject := UTF8String(GF_Command);

      if Match then
      begin
        s := MatchedText;
        RegEx := '\d{1,5}';
        Subject := s;

        if Match then
        begin
          // The first match can be ignored, it is identical to the second one
          if MatchAgain then
          begin
            try
              Bytes := StrToInt(string(MatchedText));
            except
              raise EParserError.Create(INVALID_DATA + ' (byte count value):' + string(MatchedText));
            end;
          end;

          if MatchAgain then
          begin
            try
              BytesPerRow := StrToInt(string(MatchedText));
            except
              raise EParserError.Create(INVALID_DATA + ' (bytes per row value): ' + string(MatchedText));
            end;
          end;
        end;

        RegEx := '\' + ZPL2_GF + 'A,(\d{1,5},){3}';
        Subject := UTF8String(GF_Command);

        // Delete first row
        if Match then
        begin
          Replace;
          GF_Command := Trim(string(Subject));
        end;
      end
      else
        raise EParserError.Create(INVALID_DATA + ': ' + GF_Command);
    finally
      Free;
    end;
  end;

  Max_Len := BytesPerRow * 2;

  // Delete all line breaks to get a continuous string
  Data := StringReplace(GF_Command, sLineBreak, '', [rfReplaceAll]);
  Data := Trim(StringReplace(Data, ',', sLineBreak, [rfReplaceAll]));

  i := 0;
  Rows := TStringList.Create;

  try
    Rows.Text := Data;

    while i < Rows.Count do
    begin
      j := 1;
      s1 := Rows[i];

      // if the row contains more data than specified, move the excess to new rows
      if Length(s1) > Max_Len then
      begin
        Rows[i] := Copy(s1, 1, Max_Len);
        Delete(s1, 1, Max_Len);

        while Length(s1) > Max_Len do
        begin
          Rows.Insert(i + j, Copy(s1, 1, Max_Len));
          Delete(s1, 1, Max_Len);
          Inc(j);
        end;

        Rows.Insert(i + j, s1);
        Inc(j);
      end;

      Inc(i, j);
    end;

    Data := Rows.Text;

    if Bytes <> Rows.Count * BytesPerRow then
      Bytes := Rows.Count * BytesPerRow;

    ZPL2GraphicField.SetGraphic(Bytes, BytesPerRow, Data);
  finally
    Rows.Free;
  end;
end;

procedure TZPL2Parser.ParseGraphicBox(const GB_Command, FO_Command: string);
var
  ZPL2GraphicBox: TZPL2GraphicBox;
begin
  ZPL2GraphicBox := TZPL2GraphicBox.Create(nil);

  try
    ParseFOCommand(FO_Command, ZPL2GraphicBox);
    ParseGBCommand(GB_Command, ZPL2GraphicBox);
    FZPL2Label.Items.Add(ZPL2GraphicBox);

    if FZPL2Label.LabelReversePrint and (FZPL2Label.Items.Count = 1) then
      FZPL2Label.LabelHeight := TZPL2GraphicBox(FZPL2Label.Items[0]).Height;
  except
    ZPL2GraphicBox.Free;
    raise;
  end;
end;

procedure TZPL2Parser.ParseGraphicCircle(const GC_Command, FO_Command: string);
var
  ZPL2GraphicCircle: TZPL2GraphicCircle;
begin
  ZPL2GraphicCircle := TZPL2GraphicCircle.Create(nil);

  try
    ParseFOCommand(FO_Command, ZPL2GraphicCircle);
    ParseGCCommand(GC_Command, ZPL2GraphicCircle);
    FZPL2Label.Items.Add(ZPL2GraphicCircle);
  except
    ZPL2GraphicCircle.Free;
    raise;
  end;
end;

procedure TZPL2Parser.ParseGraphicDiagonalLine(const GD_Command, FO_Command: string);
var
  ZPL2GraphicDiagonalLine: TZPL2GraphicDiagonalLine;
begin
  ZPL2GraphicDiagonalLine := TZPL2GraphicDiagonalLine.Create(nil);

  try
    ParseFOCommand(FO_Command, ZPL2GraphicDiagonalLine);
    ParseGDCommand(GD_Command, ZPL2GraphicDiagonalLine);
    FZPL2Label.Items.Add(ZPL2GraphicDiagonalLine);
  except
    ZPL2GraphicDiagonalLine.Free;
    raise;
  end;
end;

procedure TZPL2Parser.ParseGraphicEllipse(const GE_Command, FO_Command: string);
var
  ZPL2GraphicEllipse: TZPL2GraphicEllipse;
begin
  ZPL2GraphicEllipse := TZPL2GraphicEllipse.Create(nil);

  try
    ParseFOCommand(FO_Command, ZPL2GraphicEllipse);
    ParseGECommand(GE_Command, ZPL2GraphicEllipse);
    FZPL2Label.Items.Add(ZPL2GraphicEllipse);
  except
    ZPL2GraphicEllipse.Free;
    raise;
  end;
end;

procedure TZPL2Parser.ParseGraphicField(const GF_Command, FO_Command: string);
var
  ZPL2GraphicField: TZPL2GraphicField;
begin
  ZPL2GraphicField := TZPL2GraphicField.Create(nil);

  try
    ParseFOCommand(FO_Command, ZPL2GraphicField);
    ParseGFCommand(GF_Command, ZPL2GraphicField);
    FZPL2Label.Items.Add(ZPL2GraphicField);
  except
    ZPL2GraphicField.Free;
    raise;
  end;
end;

procedure TZPL2Parser.ParseLHCommand(const LH_Command: string);
const
  INVALID_DATA = 'Invalid label home data';
var
  s: UTF8String;
begin
  with TPerlRegEx.Create do
  begin
    try
      RegEx := '\' + ZPL2_LH + '\d{1,5},\d{1,5}';
      Subject := UTF8String(LH_Command);

      if Match then
      begin
        s := MatchedText;
        Delete(s, 1, 3);
        RegEx := '\b\w+\b';
        Subject := s;

        if Match then
        begin
          try
            FZPL2Label.LabelHome_X := StrToInt(string(MatchedText));
          except
            raise EParserError.Create(INVALID_DATA + ' (x coordinate value): ' + string(MatchedText));
          end;

          if MatchAgain then
          begin
            try
              FZPL2Label.LabelHome_Y := StrToInt(string(MatchedText));
            except
              raise EParserError.Create(INVALID_DATA + ' (y coordinate value): ' + string(MatchedText));
            end;
          end;
        end;
      end
      else
        raise EParserError.Create(INVALID_DATA + ': ' + LH_Command);
    finally
      Free;
    end;
  end;
end;

procedure TZPL2Parser.ParseMDCommand(const MD_Command: string);
const
  INVALID_DATA = 'Invalid media darkness data';
var
  s: string;
begin
  with TPerlRegEx.Create do
  begin
    try
      RegEx := '\' + ZPL2_MD + '(-)?(([0-2])?\d(\.\d)?|30(\.0)?)$';
      Subject := UTF8String(MD_Command);

      if Match then
      begin
        s := string(MatchedText);
        Delete(s, 1, 3);

        try
          FZPL2Label.MediaDarkness := StrToFloat(s, GetLocaleFormatSettingsWithDotDecimalSeparator);
        except
          raise EParserError.Create(INVALID_DATA + ' (value): ' + s);
        end;
      end
      else
        raise EParserError.Create(INVALID_DATA + ': ' + MD_Command);
    finally
      Free;
    end;
  end;
end;

procedure TZPL2Parser.ParsePQCommand(const PQ_Command: string);
const
  INVALID_DATA = 'Invalid print quantitiy data';
var
  s: UTF8String;
begin
  with TPerlRegEx.Create do
  begin
    try
      RegEx := '\' + ZPL2_PQ + '(\d{1,8},){3}[YN]';
      Subject := UTF8String(PQ_Command);

      if Match then
      begin
        s := MatchedText;
        Delete(s, 1, 3);
        RegEx := '\b\w+\b';
        Subject := s;

        if Match then
        begin
          try
            FZPL2Label.PrintQuantity := StrToInt(string(MatchedText));
          except
            raise EParserError.Create(INVALID_DATA + ' (quantitiy count value): ' + string(MatchedText));
          end;

          if MatchAgain then
          begin
            try
              FZPL2Label.PrintQuantityTillPauseAndCut := StrToInt(string(MatchedText));
            except
              raise EParserError.Create(INVALID_DATA + ' (print quantity till pause and cut value): ' + string(MatchedText));
            end;
          end;

          if MatchAgain then
          begin
            try
              FZPL2Label.ReplicatesCount := StrToInt(string(MatchedText));
            except
              raise EParserError.Create(INVALID_DATA + ' (replicates count value): ' + string(MatchedText));
            end;
          end;

          if MatchAgain then
          begin
            try
              case MatchedText[1] of
                'Y': FZPL2Label.OverridePauseCount := true;
              else
                FZPL2Label.OverridePauseCount := false;
              end;
            except
              raise EParserError.Create(INVALID_DATA + ' (override pause count value): ' + string(MatchedText));
            end;
          end;
        end;
      end
      else
        raise EParserError.Create(INVALID_DATA + ': ' + PQ_Command);
    finally
      Free;
    end;
  end;
end;

procedure TZPL2Parser.ParsePRCommand(const PR_Command: string);
const
  INVALID_DATA = 'Invalid print rate data';
var
  s: UTF8String;
begin
  with TPerlRegEx.Create do
  begin
    try
      // The second and third parameter of the PR command are currently not used!
      // Add the comment part of the next line to the regular expression if you are going to use them aswell.
      RegEx := '\' + ZPL2_PR + '([2345689ABCDE]|10|11|12)'; // (,[2345689ABCDE]|10|11|12){0,2}'
      Subject := UTF8String(PR_Command);

      if Match then
      begin
        s := MatchedText;
        Delete(s, 1, 3);
        RegEx := '\b\w+\b';
        Subject := s;

        if Match then
        begin
          try
            case MatchedText[1] of
              '2', 'A': FZPL2Label.PrintSpeed := sp50_8mm;
              '3', 'B': FZPL2Label.PrintSpeed := sp76_2mm;
              '4', 'C': FZPL2Label.PrintSpeed := sp101_6mm;
              '5':      FZPL2Label.PrintSpeed := sp127mm;
              '6', 'D': FZPL2Label.PrintSpeed := sp152_4mm;
              '8', 'E': FZPL2Label.PrintSpeed := sp203_2mm;
              '9':      FZPL2Label.PrintSpeed := sp220_5mm;
              '1':
              begin
                case MatchedText[2] of
                  '0': FZPL2Label.PrintSpeed := sp245mm;
                  '1': FZPL2Label.PrintSpeed := sp269_5mm;
                  '2': FZPL2Label.PrintSpeed := sp304_8mm;
                else
                  raise EParserError.Create(INVALID_DATA + ' (print speed value): ' + string(MatchedText));
                end;
              end;
            else
              raise EParserError.Create(INVALID_DATA + ' (print speed value): ' + string(MatchedText));
            end;
          except
            raise EParserError.Create(INVALID_DATA + ' (print speed value): ' + string(MatchedText));
          end;
        end;
      end
      else
        raise EParserError.Create(INVALID_DATA + ': ' + PR_Command);
    finally
      Free;
    end;
  end;
end;

procedure TZPL2Parser.ParsePWCommand(const PW_Command: string);
const
  INVALID_DATA = 'Invalid print width data';
var
  s: UTF8String;
begin
  with TPerlRegEx.Create do
  begin
    try
      RegEx := '\' + ZPL2_PW + '([2-9]$|[1-9][\d]{1,5}$)';
      Subject := UTF8String(PW_Command);

      if Match then
      begin
        s := MatchedText;
        Delete(s, 1, 3);

        try
          FZPL2Label.PrintWidth := StrToInt(string(s));
        except
          raise EParserError.Create(INVALID_DATA + ' (width value): ' + string(s));
        end;
      end
      else
        raise EParserError.Create(INVALID_DATA + ': ' + PW_Command);
    finally
      Free;
    end;
  end;
end;

procedure TZPL2Parser.ParseQRCode(const BQ_Command, FO_Command, FD_Command: string);
  procedure ParseFDCommand(const FD_Command: string; ZPL2BarcodeQR: TZPL2BarcodeQR);
  const
    INVALID_DATA = 'Invalid QR code data';
  var
    s: string;
    posComma,
    posFD: integer;
  begin
    posComma := Pos(',', FD_Command);

    if posComma > 0 then
    begin
      if (posComma > 1)
        and (Uppercase(FD_Command[posComma - 1]) = 'M')
      then
        Inc(posComma); // to fetch the character after the comma

      posFD := Pos(ZPL2_FD, FD_Command);

      if posFD > 0 then
      begin
        Inc(posFD, Length(ZPL2_FD));
        Dec(posComma, Length(ZPL2_FD));
        s := Copy(FD_Command, posFD, posComma);

        Self.ParseFDCommand(ZPL2_FD + Copy(FD_Command, posComma + Length(ZPL2_FD) + 1, Length(FD_Command) - posComma - Length(ZPL2_FD)), ZPL2BarcodeQR);
      end;
    end
    else
    begin
      s := '';
      ZPL2BarcodeQR.ErrorCorrectionLevel := eclHighReliabilityLevel; // default, if not specified
    end;

    with TPerlRegEx.Create do
    begin
      try
        if s <> '' then
        begin
          RegEx := '[\S](A,|M,[N|A|B|K])';
          Subject := UTF8String(s);

          if Match then
          begin
            try
              case MatchedText[1] of
                'H': ZPL2BarcodeQR.ErrorCorrectionLevel := eclUltraHighReliabilityLevel;
                'Q': ZPL2BarcodeQR.ErrorCorrectionLevel := eclHighReliabilityLevel;
                'M': ZPL2BarcodeQR.ErrorCorrectionLevel := eclStandardLevel;
                'L': ZPL2BarcodeQR.ErrorCorrectionLevel := eclHighDensityLevel;
              else
                ZPL2BarcodeQR.ErrorCorrectionLevel := eclStandardLevel;
              end;
            except
              raise EParserError.Create(INVALID_DATA + ' (error correction level value): ' + string(MatchedText));
            end;
          end
          else
            raise EParserError.Create(INVALID_DATA + ' (QR switches in FD command): ' + s);
        end;
      finally
        Free;
      end;
    end;
  end;

var
  ZPL2BarcodeQR: TZPL2BarcodeQR;
begin
  ZPL2BarcodeQR := TZPL2BarcodeQR.Create(nil);

  try
    ParseFOCommand(FO_Command, ZPL2BarcodeQR);
    ParseBQCommand(BQ_Command, ZPL2BarcodeQR);
    ParseFDCommand(FD_Command, ZPL2BarcodeQR);
    FZPL2Label.Items.Add(ZPL2BarcodeQR);
  except
    ZPL2BarcodeQR.Free;
    raise;
  end;
end;

procedure TZPL2Parser.ParseRotation(const Rotation: char; ZPL2RotationLabelItem: TZPL2RotationLabelItem);
begin
  case Rotation of
    'N': ZPL2RotationLabelItem.Rotation := zrNO_ROTATION;
    'B': ZPL2RotationLabelItem.Rotation := zrROTATE_90_DEGREES;
    'I': ZPL2RotationLabelItem.Rotation := zrROTATE_180_DEGREES;
    'R': ZPL2RotationLabelItem.Rotation := zrROTATE_270_DEGREES;
  else
    raise EParserError.Create('Invalid rotation char: ' + Rotation);
  end;
end;

procedure TZPL2Parser.ParseTextField(const A_Command, FO_Command, FD_Command: string; const FH: boolean = false; const FH_Inidicator: char = #0);
var
  ZPL2TextField: TZPL2TextField;
begin
  ZPL2TextField := TZPL2TextField.Create(nil);

  try
    ParseFOCommand(FO_Command, ZPL2TextField);

    if A_Command <> '' then
      ParseACommand(A_Command, ZPL2TextField)
    else
    begin
      ZPL2TextField.Font := FZPL2Label.CF.Font;
      ZPL2TextField.Height := FZPL2Label.CF.Height;
      ZPL2TextField.Width := FZPL2Label.CF.Width;
      ZPL2TextField.Rotation := zrNO_ROTATION;
    end;

    ParseFDCommand(FD_Command, ZPL2TextField, FH, FH_Inidicator);
    FZPL2Label.Items.Add(ZPL2TextField);
  except
    ZPL2TextField.Free;
    raise;
  end;
end;

{$endregion}

end.
