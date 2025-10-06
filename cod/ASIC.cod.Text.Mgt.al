codeunit 50001 "Text Mgt."
{
    var
    trigger OnRun()
    begin

    end;

    procedure GetDetailFromTransDesc(pDesc: Text; pFirstText: Text[10]; pSecondText: Text[10]): Text[250]
    begin
        if StrPos(pDesc, pFirstText) > 0 then begin
            exit(CopyStr(pDesc, StrPos(pDesc, pFirstText) + StrLen(pFirstText) + 1, StrPos(pDesc, pSecondText) - StrPos(pDesc, pFirstText) - StrLen(pFirstText) - 2));
        end;
    end;

    procedure GetFirstDigitPosition(pText: Text): Integer
    begin
        if pText = '' then
            exit(0);

        exit(pText.IndexOfAny('0123456789'));
    end;

    procedure GetNumberFromTransDesc(pDesc: Text[250]; pFirstText: Text[10]; pSecondText: Text[10]): Text[250]
    var
        FirstTextPos, SecondTextPos : integer;
        TempTxt: Text[25];
    begin
        FirstTextPos := StrPos(pDesc, pFirstText);
        if pSecondText <> '' then
            SecondTextPos := StrPos(pDesc, pSecondText)
        else
            SecondTextPos := StrLen(pDesc);
        if (FirstTextPos <> 0) and (SecondTextPos <> 0) then begin
            TempTxt := CopyStr(pDesc, FirstTextPos + StrLen(pFirstText), SecondTextPos - FirstTextPos - 1);
            TempTxt := DelChr(TempTxt, '=', ' ');
            TempTxt := ConvertStr(TempTxt, '.', ',');
            Exit(TempTxt);
        end;
        exit('0');
    end;

    procedure GetTextFromBetween(pDesc: Text[250]; pBeginChar: Text[1]; pEndChar: Text[1]): Text[250]
    begin
        if StrPos(pDesc, pBeginChar) > 1 then begin
            exit(CopyStr(pDesc, StrPos(pDesc, pBeginChar) + 1, StrPos(pDesc, pEndChar) - StrPos(pDesc, pBeginChar) - 1));
        end;
    end;

    procedure GetTextFromBetween(pDesc: Text[250]; pBeginChar: Text[1]; pEndChar: Integer): Text[250]
    begin
        if StrPos(pDesc, pBeginChar) > 1 then begin
            exit(CopyStr(pDesc, StrPos(pDesc, pBeginChar) + 1, pEndChar - StrPos(pDesc, pBeginChar) - 1));
        end;
    end;

    procedure GetTextFromBetween(pDesc: Text[250]; pBeginChar: Integer; pEndChar: Integer): Text[250]
    begin
        if pEndChar > pBeginChar then
            exit(CopyStr(pDesc, pBeginChar + 1, pEndChar - pBeginChar - 1));
    end;
}