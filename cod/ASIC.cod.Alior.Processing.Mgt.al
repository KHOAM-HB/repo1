codeunit 50000 "Alior Processing Mgt." implements IProcessingMgt
{
    trigger OnRun()
    begin
    end;

    procedure GetVendorInvoiceNo(var pLine: record "Stock Transactions Buffer"): Code[35]
    var
    begin
        Exit(FORMAT(pLine."Transaction No."));
    end;

    procedure GetExtDocNo(var pLine: record "Stock Transactions Buffer"): Code[35]
    var
    begin
        Exit(FORMAT(pLine."Transaction No."));
    end;

    procedure GetInstrumentFromDesc(pDesc: Text[250]; pDesc2: Text[250]): Text[20]
    var
        TextMgt: Codeunit "Text Mgt.";
    begin
        if StrPos(pDesc, '(') > 1 then begin
            exit(TextMgt.GetTextFromBetween(pDesc, '(', ')'));
        end;
        if StrPos(pDesc, 'kupna') > 1 then begin
            exit(TextMgt.GetDetailFromTransDesc(pDesc, 'kupna', 'nr'))
        end;
        if StrPos(pDesc, 'sprzed') > 1 then begin
            exit(TextMgt.GetDetailFromTransDesc(pDesc, 'sprzedaży', 'nr'))
        end;
    end;

    procedure GetTransactionNoFromDesc(pDesc: Text[250]; pDesc2: Text[250]): Integer;
    var
        TextMgt: Codeunit "Text Mgt.";
        tempTransactionNo: integer;
    begin
        if StrPos(pDesc, 'nr zlecenia') > 1 then begin
            Evaluate(tempTransactionNo, CopyStr(pDesc, StrPos(pDesc, 'nr zlecenia') + StrLen('nr zlecenia') + 1));
            exit(tempTransactionNo);
        end;
        if StrPos(pDesc, 'dla transakcji') > 1 then begin
            Evaluate(tempTransactionNo, CopyStr(pDesc, StrPos(pDesc, 'dla transakcji') + StrLen('dla transakcji') + 1));
            exit(tempTransactionNo);
        end;
        if StrPos(pDesc, 'ZLC:') > 1 then begin
            Evaluate(tempTransactionNo, TextMgt.GetDetailFromTransDesc(pDesc, 'ZLC:', 'PW:'));
            exit(tempTransactionNo);
        end;
    end;

    procedure GetEntryTypeFromDesc(pDesc: Text[250]; pDesc2: Text[250]; pTransactionNo: Integer; pEntryNo: Integer): enum "Entry Type";
    var
        FinTrans: record "Fin. Transactions Buffer";
        EntryType: enum "Entry Type";
        MasterEntryType: enum "Entry Type";
        TransactionNoTxt: Text;
    begin

        if StrPos(pDesc, 'kupna') > 1 then begin
            exit(EntryType::Buy);
        end;
        if StrPos(pDesc, 'sprzeda') > 1 then begin
            exit(EntryType::Sell);
        end;
        if StrPos(pDesc, 'Wykup') > 0 then begin
            exit(EntryType::Sell);
        end;
        if (StrPos(pDesc, 'Prowizja') > 0) or (StrPos(pDesc, 'ZLC:') > 0) then begin
            MasterEntryType := MasterEntryType::None;
            if pTransactionNo <> 0 then begin
                TransactionNoTxt := 'Transakcja*' + FORMAT(pTransactionNo);
                FinTrans.SetFilter(Description, '%1', TransactionNoTxt);
                FinTrans.SetFilter("Entry No.", '<>%1', pEntryNo);
                //error('%1', FinTrans.GetFilters);
                if FinTrans.FindFirst then begin
                    MasterEntryType := GetEntryTypeFromDesc(FinTrans.Description, FinTrans."Description 2", 0, 0);
                    case MasterEntryType of
                        MasterEntryType::Buy:
                            exit(EntryType::Prov_Buy);
                        MasterEntryType::Sell:
                            exit(EntryType::Prov_Sell);
                    end
                end;
            end;
        end;
        if StrPos(pDesc, 'Podatek') > 0 then begin
            exit(EntryType::Tax);
        end;
        if StrPos(pDesc, 'Dywidenda') > 0 then begin
            exit(EntryType::Dividend);
        end;
        if StrPos(pDesc, 'z pw emit') > 1 then begin
            exit(EntryType::Dividend);
        end;
        if StrPos(pDesc, 'Odsetki') > 0 then begin
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
        if pAmountTxt = 'null' then
            exit(EntryType::None);
        if StrPos(pOperation, 'Kupno') > 0 then begin
            exit(EntryType::Buy);
        end;
        if StrPos(pOperation, 'Sprzeda') > 0 then begin
            exit(EntryType::Sell);
        end;
    end;

    procedure GetPriceAndProvision(pDesc: Text[250]; pDesc2: Text[250]; var pPrice: Decimal; var pProvision: Decimal)
    var
        TextMgt: Codeunit "Text Mgt.";
        TempTxt: Text[25];
    begin
        pPrice := 0;
        pProvision := 0;

        if StrPos(pDesc, 'Cena:') > 0 then begin
            TempTxt := TextMgt.GetNumberFromTransDesc(pDesc, ':', 'PLN');
            IF TempTxt <> '' then
                Evaluate(pPrice, TempTxt);
        end;
        if StrPos(pDesc, 'Prowizja:') > 0 then begin
            TempTxt := TextMgt.GetNumberFromTransDesc(pDesc, 'Prowizja:', '');
            IF TempTxt <> '' then
                Evaluate(pProvision, TempTxt);
        end;
    end;

    procedure CreateDescriptionFromStockBufferLine(buffer: Record "Stock Transactions Buffer"): Text
    var
    begin
    end;

    procedure CreatePOLine(var POLine: Record "Purchase Line"; var StockLine: Record "Stock Transactions Buffer")
    var
    begin
    end;

    procedure SetLocation(var Line: Record "Purchase Line");
    var
    begin
        Line.Validate("Location Code", 'ALIOR-5439');
    end;

    procedure SetLocation(var Header: Record "Purchase Header");
    var
    begin
        Header.Validate("Location Code", 'ALIOR-5439');
    end;

    procedure SetLocation(var Line: Record "Sales Line");
    var
    begin
        Line.Validate("Location Code", 'ALIOR-5439');
    end;

    procedure SetLocation(var POHeader: Record "Sales Header");
    var
    begin
        POHeader.Validate("Location Code", 'ALIOR-5439');
    end;
}