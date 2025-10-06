//TODO przeniesc tworzenie wierszy do osobnych funkcji zaleznie od institution

report 50004 "ASIC Create Purch. Orders"
{
    UsageCategory = Administration;
    ApplicationArea = All;

    dataset
    {
        dataitem(StockLine; "Stock Transactions Buffer")
        {
            DataItemTableView = sorting(Date, Instrument, "Entry Type");

            //Create unique list of transactions no.
            trigger OnPreDataItem()
            var
            begin
                clear(tempDate);
                clear(tempInstrument);
                clear(tempOperation);

                if Institution = Institution::BOS then begin
                    begin
                        if StockLine.Findset(true, false) then
                            repeat
                                if (tempDate <> StockLine.DateTxt)
                                or (tempInstrument <> StockLine.Instrument)
                                or (tempOperation <> StockLine.Operation) then begin
                                    TempUniqueTransNo.Init;
                                    TempUniqueTransNo."Transaction No." := "Entry No.";
                                    IF TempUniqueTransNo.INSERT THEN;
                                end;
                                tempDate := StockLine.DateTxt;
                                tempInstrument := StockLine.Instrument;
                                tempOperation := StockLine.Operation;

                                StockLine."Transaction No." := TempUniqueTransNo."Transaction No.";
                                StockLine.Modify();
                            until StockLine.Next() = 0;
                    end;
                end;

                SetFilter("Transaction No.", '<>0');
                if Institution = Institution::BOS then
                    SetRange("Entry Type", "Entry Type"::Buy);
            end;

            trigger OnAfterGetRecord()
            var
            begin
                case true of
                    Institution = Institution::Alior:
                        begin
                            TempUniqueTransNo.Init;
                            TempUniqueTransNo."Transaction No." := "Transaction No.";
                            IF TempUniqueTransNo.INSERT THEN;
                        end;
                    Institution = Institution::BOS:
                        begin
                            if (tempDate <> StockLine.DateTxt)
                            or (tempInstrument <> StockLine.Instrument)
                            or (tempOperation <> StockLine.Operation) then begin
                                TempUniqueTransNo.Init;
                                TempUniqueTransNo."Transaction No." := "Entry No.";
                                IF TempUniqueTransNo.INSERT THEN;
                            end;
                            tempDate := StockLine.DateTxt;
                            tempInstrument := StockLine.Instrument;
                            tempOperation := StockLine.Operation;

                            StockLine."Transaction No." := TempUniqueTransNo."Transaction No.";
                            StockLine.Modify();
                        end;
                end;
            end;
        }

        dataitem(BuyTransLoop; Integer)
        {
            DataItemTableView = SORTING(Number);
            //MaxIteration = 1;


            trigger OnPreDataItem()
            var
                PHdr: Record "Purchase Header";
            begin
                if TempUniqueTransNo.Count = 0 then
                    Error('Fin./Stock Buffer has no transactions');

                If PHdr.Findset then
                    if confirm('Delete unposted purchase orders?', false) then
                        PHdr.DeleteAll(true);

                if not confirm('Create purchase orders from fin. trans. buffer?', false) then
                    CurrReport.Break();

                SetRange(Number, 1, TempUniqueTransNo.Count);
                TempUniqueTransNo.RESET;
            end;

            trigger OnAfterGetRecord()
            var
                StockLine: record "Stock Transactions Buffer";
                PHdr: Record "Purchase Header";
                PHdr2: Record "Purchase Header";
                PLine: Record "Purchase Line";
                Item: Record Item;
                TotalStockProv: Decimal;
                TotalStockAmt: Decimal;
                TotalFinProv: Decimal;
                TotalFinAmt: Decimal;
            begin
                if Number = 1 then
                    TempUniqueTransNo.FindFirst()
                else
                    TempUniqueTransNo.Next();

                OrderLineNo := 0;

                //Select stock lines with the same transaction no.
                StockLine.SetCurrentKey("Date", "Instrument");
                StockLine.SetRange("Transaction No.", TempUniqueTransNo."Transaction No.");
                StockLine.SetRange("Entry Type", StockLine."Entry Type"::Buy);
                StockLine.SetRange("Create Order", true);
                if StockLine.Findset(false, false) then begin
                    repeat
                        //SD1 - Equity
                        //SD2 - EQ Company
                        //SD3 - Country
                        //SD4 - FIN TYPE
                        //SD5 - MARKET

                        //Check if header with given details exists
                        PHdr.SetRange("Document Type", PHdr2."Document Type"::Order);
                        //PHdr.SetRange("Posting Date", StockLine.Date);
                        PHdr.SetRange("Vendor Invoice No.", IProcessingMgt.GetVendorInvoiceNo(StockLine));
                        If not PHdr.FindFirst() then begin
                            //Create header
                            WorkDate(StockLine.Date);
                            Item.Get(StockLine.Instrument);
                            PHdr2.Init;
                            PHdr2."Document Type" := PHdr."Document Type"::Order;
                            case true of
                                Institution = Institution::Alior:
                                    PHdr2.Validate("Buy-from Vendor No.", 'DMALIOR');
                                Institution = Institution::BOS:
                                    PHdr2.Validate("Buy-from Vendor No.", 'DMBOS');
                            end;
                            PHdr2.Validate("Vendor Invoice No.", IProcessingMgt.GetVendorInvoiceNo(StockLine));
                            PHdr2.Insert(true);
                            PHdr2.Validate("Document Date", StockLine.Date);
                            PHdr2.Validate("Posting Date", StockLine.Date);
                            PHdr2.ValidateShortcutDimCode(1, EquityStock);
                            PHdr2.Validate("Due Date", StockLine.Date);
                            PHdr2.Validate("Order Date", StockLine.Date);
                            PHdr2.Validate("Expected Receipt Date", StockLine.Date);
                            IProcessingMgt.SetLocation(PHdr2);
                            PHdr2.Validate("Shortcut Dimension 1 Code", Item."Global Dimension 1 Code");
                            PHdr2.Validate("Shortcut Dimension 2 Code", Item."Global Dimension 2 Code");
                            PHdr2.ValidateShortcutDimCode(3, Item."Country/Region of Origin Code");
                            PHdr2.ValidateShortcutDimCode(4, FinTypeBuy);
                            PHdr2.ValidateShortcutDimCode(5, MarketGPW);
                            PHdr2.ValidateShortcutDimCode(6, PHdr2."Buy-from Vendor No.");
                            PHdr2.Modify(true);
                            Phdr := PHdr2;
                        end else begin
                            PHdr.Validate("Posting Date", StockLine.Date);
                            PHdr.Modify();
                        end;
                        //Add item lines
                        case Institution of
                            Institution::Alior:
                                begin
                                    TotalStockAmt += StockLine.Amount;
                                    TotalStockProv += StockLine."Provision Amount";
                                end;
                            Institution::BOS:
                                begin
                                    TotalStockAmt += StockLine."Amount w/o Provision";
                                    TotalStockProv += StockLine."Provision Amount";
                                end;
                        end;

                        OrderLineNo += 10000;
                        PLine.Init;
                        PLine."Document Type" := PLine."Document Type"::Order;
                        PLine."Document No." := PHdr."No.";
                        PLine."Line No." := OrderLineNo;
                        PLine.Validate(Type, PLine.Type::Item);
                        PLine.Validate("No.", StockLine.Instrument);
                        PLine.Description := 'Transakcja kupna ' + StockLine.Instrument + ' nr zlecenia ' + format(StockLine."Transaction No.");
                        IProcessingMgt.SetLocation(PLine);
                        PLine.Validate(Quantity, StockLine.Quantity);
                        PLine.Validate("Direct Unit Cost", StockLine.Price);
                        PLine.Validate("Promised Receipt Date", StockLine.Date);
                        PLine.Validate("Requested Receipt Date", StockLine.Date);
                        PLine.ValidateShortcutDimCode(4, FinTypeBuy);
                        PLine.ValidateShortcutDimCode(5, MarketGPW);
                        PLine.ValidateShortcutDimCode(6, PHdr2."Buy-from Vendor No.");
                        PLine.Insert();
                    until StockLine.Next() = 0;
                end;

                Case Institution of
                    Institution::Alior:
                        begin
                            CreateProvisionLinesFromFinLines(PHdr, TotalStockProv);
                        end;
                    Institution::BOS:
                        begin
                            CreateProvisionLinesFromStockLine(PHdr, PLine);
                        end;
                end;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(Institution; Institution)
                    {
                        ApplicationArea = All;
                        Caption = 'Institution';
                        ToolTip = 'Specifies the institution data will be processed from. This field must be filled in.';
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    var
        TempUniqueTransNo: Record "Unique Trans. No." temporary;
        AliorProcessingMgt: Codeunit "Alior Processing Mgt.";
        BOSProcessingMgt: Codeunit "BOS Processing Mgt.";
        TextMgt: Codeunit "Text Mgt.";
        EquityBond, EquityStock, FinTypeDiv, FinTypeInt, FinTypeBuy, FinTypeProvBuy, FinTypeTax, MarketGPW, DMBOS, DMALIOR : Code[20];
        Institution: Enum Institution;
        LastLineNo: Integer;
        OrderLineNo: Integer;
        IProcessingMgt: Interface IProcessingMgt;
        tempDate: Text;
        tempInstrument: Text;
        tempOperation: Text;

    trigger OnPreReport()
    var
    begin
        EquityStock := 'STOCK';
        EquityBond := 'BOND';
        FinTypeDiv := 'DIV';
        FinTypeInt := 'INT-BONDS';
        FinTypeTax := 'TAX';
        FinTypeProvBuy := 'PROV-BUY';
        FinTypeBuy := 'BUY';
        MarketGPW := 'GPW';
        DMALIOR := 'DMALIOR';
        DMBOS := 'DMBOS';

        case true of
            Institution = Institution::Alior:
                IProcessingMgt := AliorProcessingMgt;
            Institution = Institution::BOS:
                IProcessingMgt := BOSProcessingMgt;
        end;
    end;

    procedure CreateProvisionLinesFromFinLines(PHdr: Record "Purchase Header"; TotalStockProv: decimal)
    var
        FinLine: Record "Fin. Transactions Buffer";
        PLine: Record "Purchase Line";
    begin
        FinLine.SetCurrentKey("Date", "Instrument");
        FinLine.SetRange("Transaction No.", TempUniqueTransNo."Transaction No.");
        FinLine.SetFilter("Entry Type", '%1|%2', FinLine."Entry Type"::Buy, FinLine."Entry Type"::Prov_Buy);
        FinLine.SetRange("Create Posting", true);
        if FinLine.Findset(true, false) then begin
            OrderLineNo += 10000;
            repeat
                If FinLine."Entry Type" = FinLine."Entry Type"::Prov_Buy then begin
                    //  key(Key1;"Document Type", "Document No.", "Line No.")
                    PLine.Init;
                    PLine."Document Type" := PLine."Document Type"::Order;
                    PLine."Document No." := PHdr."No.";
                    PLine."Line No." := OrderLineNo;
                    PLine.Validate(Type, PLine.Type::"Charge (Item)");
                    PLine.Validate("No.", 'PROV-BUY');
                    PLine.Description := 'Prowizja dla transakcji ' + format(TempUniqueTransNo."Transaction No.");
                    PLine.Validate(Quantity, 1);
                    PLine.Validate("Unit of Measure Code", 'PCS');
                    PLine.Validate("Direct Unit Cost", TotalStockProv);
                    PLine.ValidateShortcutDimCode(1, EquityStock);
                    PLine.ValidateShortcutDimCode(4, FinTypeProvBuy);
                    PLine.ValidateShortcutDimCode(5, MarketGPW);
                    case true of
                        Institution = Institution::Alior:
                            PLine.ValidateShortcutDimCode(6, DMALIOR);
                        Institution = Institution::BOS:
                            PLine.ValidateShortcutDimCode(6, DMBOS);
                    end;
                    IF not PLine.Insert() then;
                end;
                FinLine.Paired := true;
                FinLine.Modify(false);
            until FinLine.Next() = 0;
        end;
    end;

    procedure CreateProvisionLinesFromStockLine(PHdr: Record "Purchase Header"; PLine: Record "Purchase Line")
    var
        StockLine: Record "Stock Transactions Buffer";
        Instrument: Record Item;
    begin
        StockLine.SetCurrentKey("Date", Instrument);
        StockLine.SetRange("Transaction No.", TempUniqueTransNo."Transaction No.");
        StockLine.SetRange(Instrument, PLine."No.");
        StockLine.SetRange(Date, PHdr."Posting Date");
        StockLine.SetRange("Entry Type", StockLine."Entry Type"::Buy);
        if StockLine.Findset(true, false) then begin
            repeat
                OrderLineNo += 10000;
                //SD1 - Equity
                //SD2 - EQ Company
                //SD3 - Country
                //SD4 - FIN TYPE
                //SD5 - MARKET
                //  key(Key1;"Document Type", "Document No.", "Line No.")
                Instrument.Get(StockLine.Instrument);
                PLine.Init;
                PLine."Document Type" := PLine."Document Type"::Order;
                PLine."Document No." := PHdr."No.";
                PLine."Line No." := OrderLineNo;
                PLine.Validate(Type, PLine.Type::"Charge (Item)");
                PLine.Validate("No.", 'PROV-BUY');
                PLine.Description := 'Prowizja dla transakcji ' + format(StockLine."Transaction No.") + ' (' + format(StockLine.Quantity) + ' x ' + format(StockLine.Price) + ')';
                PLine.Validate(Quantity, 1);
                PLine.Validate("Unit of Measure Code", 'PCS');
                PLine.Validate("Direct Unit Cost", StockLine."Provision Amount");
                PLine.ValidateShortcutDimCode(1, EquityStock);
                PLine.ValidateShortcutDimCode(2, Instrument."Global Dimension 2 Code");
                PLine.ValidateShortcutDimCode(3, Instrument."Country/Region of Origin Code");
                PLine.ValidateShortcutDimCode(4, FinTypeProvBuy);
                PLine.ValidateShortcutDimCode(5, MarketGPW);
                case true of
                    Institution = Institution::Alior:
                        PLine.ValidateShortcutDimCode(6, DMALIOR);
                    Institution = Institution::BOS:
                        PLine.ValidateShortcutDimCode(6, DMBOS);
                end;
                IF not PLine.Insert() then;
            until StockLine.Next() = 0;
        end;
    end;
}