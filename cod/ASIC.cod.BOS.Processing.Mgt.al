codeunit 50004 "BOS Processing Mgt." implements IProcessingMgt
{
    trigger OnRun()
    begin

    end;

    procedure GetVendorInvoiceNo(var pLine: record "Stock Transactions Buffer"): Code[35]
    var
    begin
        Exit('BOS-' + FORMAT(pLine.Date) + '-' + FORMAT(pLine."Transaction No."));
    end;

    procedure GetExtDocNo(var pLine: record "Stock Transactions Buffer"): Code[35]
    var
    begin
        Exit('BOS-' + FORMAT(pLine.Date) + '-' + FORMAT(pLine."Transaction No."));
    end;

    procedure GetInstrumentFromDesc(pDesc: Text[250]; pDesc2: Text[250]): Text[20]
    var
        TextMgt: Codeunit "Text Mgt.";
        TempDesc: Text;
    begin
        //if pDesc2 = '' then
        //  exit(''); dla operacji fin (div/tax) w BOS Desc2 jest puste

        TempDesc := pDesc + ' ' + pDesc2;

        if StrPos(TempDesc, ':') > 0 then begin
            exit(TextMgt.GetTextFromBetween(TempDesc, ':', TextMgt.GetFirstDigitPosition(TempDesc)));
        end;

        if StrPos(TempDesc, 'dywidendy') > 1 then begin
            exit(TextMgt.GetTextFromBetween(TempDesc, TempDesc.LastIndexOf('dywidendy') + 8, StrLen(TempDesc)));
        end;
        if StrPos(TempDesc, 'obligacji') > 1 then begin
            exit(TextMgt.GetTextFromBetween(TempDesc, TempDesc.LastIndexOf('obligacji') + 8, StrLen(TempDesc)));
        end;

    end;

    procedure GetTransactionNoFromDesc(pDesc: Text[250]; pDesc2: Text[250]): Integer;
    var
        TextMgt: Codeunit "Text Mgt.";
        tempTransactionNo: integer;
        TempDesc: Text;
    begin
        if pDesc2 = '' then
            exit(0);

        TempDesc := pDesc + ' ' + pDesc2;

        if StrPos(TempDesc, 'nr') > 1 then begin
            Evaluate(tempTransactionNo, CopyStr(TempDesc, StrPos(TempDesc, 'nr') + StrLen('nr') + 1));
            exit(tempTransactionNo);
        end;
    end;

    procedure GetEntryTypeFromDesc(pDesc: Text[250]; pDesc2: Text[250]; pTransactionNo: Integer; pEntryNo: Integer): enum "Entry Type";
    var
        FinTrans: record "Fin. Transactions Buffer";
        EntryType: enum "Entry Type";
        MasterEntryType: enum "Entry Type";
        TransactionNoTxt: Text;
        TempDesc: Text;
    begin
        TempDesc := pDesc + ' ' + pDesc2;

        if StrPos(pDesc, 'sprzedaży:') > 1 then begin
            exit(EntryType::Sell);
        end;
        if StrPos(pDesc, 'kupna:') > 1 then begin
            exit(EntryType::Buy);
        end;

        if StrPos(pDesc, 'Podatek') > 0 then begin
            exit(EntryType::Tax);
        end;
        if StrPos(pDesc, 'Wypłata dywidendy') > 0 then begin
            exit(EntryType::Dividend);
        end;

        if StrPos(pDesc, 'Wypłata odsetek') > 0 then begin
            exit(EntryType::Interest);
        end;
    end;

    procedure FindInstrumentForProvision(pRec: record "Fin. Transactions Buffer"): Text[25]
    var
        FinTrans: record "Fin. Transactions Buffer";
    begin
        if pRec."Transaction No." <> 0 then begin
            FinTrans.SetRange("Transaction No.", pRec."Transaction No.");
            FinTrans.SetFilter("Entry Type", '%1|%2', FinTrans."Entry Type"::Buy, FinTrans."Entry Type"::Sell);
            FinTrans.SetRange(Date, pRec.Date);
            if FinTrans.FindFirst then begin
                exit(FinTrans.Instrument);
            end;
        end;
    end;

    procedure GetEntryTypeFromOperation(pOperation: text[10]; pAmountTxt: text[20]): enum "Entry Type"
    var
        EntryType: enum "Entry Type";
    begin
        if StrPos(pOperation, 'K') > 0 then begin
            exit(EntryType::Buy);
        end;
        if StrPos(pOperation, 'S') > 0 then begin
            exit(EntryType::Sell);
        end;
    end;

    procedure GetPriceAndProvision(pDesc: Text[250]; pDesc2: Text[250]; var pPrice: Decimal; var pProvision: Decimal)
    var
    begin
    end;

    procedure CreateDescriptionFromStockBufferLine(buffer: Record "Stock Transactions Buffer"): Text
    var
        Description: Text[250];
    begin
        Description := 'Transakcja ';
        case buffer."Entry Type" of
            buffer."Entry Type"::Buy:
                begin
                    Description += 'kupna';
                end;
            buffer."Entry Type"::Sell:
                begin
                    Description += 'sprzedaży';
                end;
        end;
        exit(Description);
    end;

    procedure CreatePOLine(var POLine: Record "Purchase Line"; var StockLine: Record "Stock Transactions Buffer")
    var
    begin
    end;

    procedure SetLocation(var Line: Record "Purchase Line");
    var
    begin
        Line.Validate("Location Code", 'BOS-151713');
    end;

    procedure SetLocation(var Header: Record "Purchase Header");
    var
    begin
        Header.Validate("Location Code", 'BOS-151713');
    end;

    procedure SetLocation(var Line: Record "Sales Line");
    var
    begin
        Line.Validate("Location Code", 'BOS-151713');
    end;

    procedure SetLocation(var Header: Record "Sales Header");
    var
    begin
        Header.Validate("Location Code", 'BOS-151713');
    end;
}