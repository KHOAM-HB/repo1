report 50002 "ASIC Create Sales Orders"
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

                if Institution = Institution::BOS then
                    if StockLine.Findset(true) then
                        repeat
                            if (tempDate <> StockLine.DateTxt)
                            or (tempInstrument <> StockLine.Instrument)
                            or (tempOperation <> StockLine.Operation) then begin
                                TempUniqueTransNo.Init();
                                TempUniqueTransNo."Transaction No." := "Entry No.";
                                IF TempUniqueTransNo.Insert() THEN;
                            end;
                            tempDate := StockLine.DateTxt;
                            tempInstrument := StockLine.Instrument;
                            tempOperation := StockLine.Operation;

                            StockLine."Transaction No." := TempUniqueTransNo."Transaction No.";
                            StockLine.Modify();
                        until StockLine.Next() = 0;


                SetFilter("Transaction No.", '<>0');
                if Institution = Institution::BOS then
                    SetRange("Entry Type", "Entry Type"::Sell);
            end;

            trigger OnAfterGetRecord()
            var
            begin
                case true of
                    Institution = Institution::Alior:
                        begin
                            TempUniqueTransNo.Init();
                            TempUniqueTransNo."Transaction No." := "Transaction No.";
                            IF TempUniqueTransNo.Insert() THEN;
                        end;
                    Institution = Institution::BOS:
                        begin
                            if (tempDate <> StockLine.DateTxt)
                            or (tempInstrument <> StockLine.Instrument)
                            or (tempOperation <> StockLine.Operation) then begin
                                TempUniqueTransNo.Init();
                                TempUniqueTransNo."Transaction No." := "Entry No.";
                                IF TempUniqueTransNo.Insert() THEN;
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

        dataitem(SellTransLoop; Integer)
        {
            DataItemTableView = SORTING(Number);

            //MaxIteration = 1;

            trigger OnPreDataItem()
            var
                SHdr: Record "Sales Header";
            begin
                if TempUniqueTransNo.Count = 0 then
                    Error('Fin./Stock Buffer has no transactions');

                If SHdr.Findset() then
                    if confirm('Delete unposted sales orders?', false) then
                        SHdr.DeleteAll(true);

                if not confirm('Create sales orders from fin. trans. buffer?', false) then
                    CurrReport.Break();

                SetRange(Number, 1, TempUniqueTransNo.Count);
                TempUniqueTransNo.RESET;
            end;

            trigger OnAfterGetRecord()
            var
                StockLine: record "Stock Transactions Buffer";
                SHdr: Record "Sales Header";
                SHdr2: Record "Sales Header";
                SLine: Record "Sales Line";
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
                StockLine.SetRange("Entry Type", StockLine."Entry Type"::Sell);
                StockLine.SetRange("Create Order", true);
                if StockLine.Findset(false, false) then begin
                    repeat
                        //SD1 - Equity
                        //SD2 - EQ Company
                        //SD3 - Country
                        //SD4 - FIN TYPE
                        //SD5 - MARKET

                        //Check if header with given details exists
                        Shdr.SetRange("Document Type", Shdr2."Document Type"::Order);
                        Shdr.SetRange("Posting Date", StockLine.Date);
                        Shdr.SetRange("External Document No.", IProcessingMgt.GetExtDocNo(StockLine));
                        If not SHdr.FindFirst() then begin
                            //Create header
                            WorkDate(StockLine.Date);
                            Item.Get(StockLine.Instrument);
                            SHdr2.Init;
                            SHdr2."Document Type" := SHdr."Document Type"::Order;
                            case true of
                                Institution = Institution::Alior:
                                    SHdr2.Validate("Sell-To Customer No.", 'DMALIOR');
                                Institution = Institution::BOS:
                                    SHdr2.Validate("Sell-To Customer No.", 'DMBOS');
                            end;
                            SHdr2.Validate("External Document No.", IProcessingMgt.GetExtDocNo(StockLine));
                            SHdr2.Insert(true);
                            IProcessingMgt.SetLocation(SHdr2);
                            SHdr2.Validate("Document Date", StockLine.Date);
                            SHdr2.Validate("Posting Date", StockLine.Date);
                            SHdr2.Validate("Due Date", StockLine.Date);
                            SHdr2.Validate("Order Date", StockLine.Date);
                            SHdr2.Validate("Requested Delivery Date", StockLine.Date);
                            SHdr2.Validate("Shortcut Dimension 1 Code", item."Global Dimension 1 Code");
                            SHdr2.Validate("Shortcut Dimension 2 Code", Item."Global Dimension 2 Code");
                            SHdr2.ValidateShortcutDimCode(3, Item."Country/Region of Origin Code");
                            SHdr2.ValidateShortcutDimCode(4, FinTypeSell);
                            SHdr2.ValidateShortcutDimCode(5, MarketGPW);
                            SHdr2.ValidateShortcutDimCode(6, SHdr2."Sell-To Customer No.");

                            SHdr2.Modify(true);
                            Shdr := SHdr2;
                        end;
                        //Add item lines
                        TotalStockAmt += StockLine.Amount;
                        TotalStockProv += StockLine."Provision Amount";

                        OrderLineNo += 10000;
                        SLine.Init;
                        SLine."Document Type" := SLine."Document Type"::Order;
                        SLine."Document No." := SHdr."No.";
                        SLine."Line No." := OrderLineNo;
                        SLine.Validate(Type, SLine.Type::Item);
                        SLine.Validate("No.", StockLine.Instrument);
                        SLine.Description := 'Transakcja sprzedaży ' + StockLine.Instrument + ' nr zlecenia ' + format(StockLine."Transaction No.");
                        IProcessingMgt.SetLocation(SLine);
                        case Institution of
                            Institution::Alior:
                                SLine.Validate(Quantity, -StockLine.Quantity);

                            Institution::BOS:
                                SLine.Validate(Quantity, StockLine.Quantity);

                        end;
                        SLine.Validate("Unit Price", StockLine.Price);
                        SLine.ValidateShortcutDimCode(4, FinTypeSell);
                        SLine.ValidateShortcutDimCode(6, SHdr2."Sell-To Customer No.");

                        SLine.Insert();
                    until StockLine.Next() = 0;
                end;
                Case Institution of
                    Institution::Alior:
                        begin
                            CreateProvisionLinesFromFinLines(SHdr, TotalStockProv);
                        end;
                    Institution::BOS:
                        begin
                            CreateProvisionLinesFromStockLine(SHdr, SLine);
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

                        trigger OnValidate()
                        var
                        begin
                            case true of
                                Institution = Institution::Alior:
                                    IProcessingMgt := AliorProcessingMgt;
                                Institution = Institution::BOS:
                                    IProcessingMgt := BOSProcessingMgt;
                            end;
                        end;
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
        EquityStock, EquityBond, FinTypeDiv, FinTypeInt, FinTypeTax, FinTypeSell, FinTypeProvSell, MarketGPW, DMALIOR, DMBOS : Code[20];
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
        FinTypeProvSell := 'PROV-SELL';
        FinTypeSell := 'SELL';
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

    procedure CreateProvisionLinesFromFinLines(SHdr: Record "Sales Header"; TotalStockProv: decimal)
    var
        FinLine: Record "Fin. Transactions Buffer";
        SLine: Record "Sales Line";
        StockLine2: Record "Stock Transactions Buffer";
    begin
        //Select fin. lines with the same transaction no.
        FinLine.SetCurrentKey("Date", "Instrument");
        FinLine.SetRange("Transaction No.", TempUniqueTransNo."Transaction No.");
        FinLine.SetFilter("Entry Type", '%1|%2', FinLine."Entry Type"::Sell, FinLine."Entry Type"::Prov_Sell);
        FinLine.SetRange("Create Posting", true);
        if FinLine.Findset(true, false) then begin
            OrderLineNo += 10000;
            repeat
                If FinLine."Entry Type" = FinLine."Entry Type"::Prov_Sell then begin
                    //  key(Key1;"Document Type", "Document No.", "Line No.")
                    SLine.Init;
                    SLine."Document Type" := SLine."Document Type"::Order;
                    SLine."Document No." := SHdr."No.";
                    SLine."Line No." := OrderLineNo;
                    SLine.Validate(Type, SLine.Type::"Charge (Item)");
                    SLine.Validate("No.", 'PROV-SELL');
                    SLine.Description := 'Prowizja dla transakcji ' + format(TempUniqueTransNo."Transaction No.");
                    IProcessingMgt.SetLocation(SLine);
                    SLine.Validate(Quantity, 1);
                    SLine.Validate("Unit of Measure Code", 'PCS');
                    SLine.Validate("Unit Price", -TotalStockProv);
                    SLine.ValidateShortcutDimCode(4, FinTypeProvSell);
                    SLine.ValidateShortcutDimCode(5, MarketGPW);
                    case true of
                        Institution = Institution::Alior:
                            SLine.ValidateShortcutDimCode(6, DMALIOR);
                        Institution = Institution::BOS:
                            SLine.ValidateShortcutDimCode(6, DMBOS);
                    end;

                    IF not SLine.Insert() then;
                end;
                FinLine.Paired := true;
                FinLine.Modify(false);
            until FinLine.Next() = 0;

        end;
    end;

    procedure CreateProvisionLinesFromStockLine(SHdr: Record "Sales Header"; SLine: Record "Sales Line")
    var
        StockLine: Record "Stock Transactions Buffer";
        Instrument: Record Item;
    begin
        StockLine.SetCurrentKey("Date", Instrument);
        StockLine.SetRange("Transaction No.", TempUniqueTransNo."Transaction No.");
        StockLine.SetRange(Instrument, SLine."No.");
        StockLine.SetRange(Date, SHdr."Posting Date");
        StockLine.SetRange("Entry Type", StockLine."Entry Type"::Sell);
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
                SLine.Init;
                SLine."Document Type" := SLine."Document Type"::Order;
                SLine."Document No." := SHdr."No.";
                SLine."Line No." := OrderLineNo;
                SLine.Validate(Type, SLine.Type::"Charge (Item)");
                SLine.Validate("No.", 'PROV-SELL');
                SLine.Description := 'Prowizja dla transakcji ' + format(StockLine."Transaction No.") + ' (' + format(StockLine.Quantity) + ' x ' + format(StockLine.Price) + ')';
                SLine.Validate(Quantity, 1);
                SLine.Validate("Unit of Measure Code", 'PCS');
                SLine.Validate("Unit Price", -StockLine."Provision Amount");
                SLine.ValidateShortcutDimCode(1, EquityStock);
                SLine.ValidateShortcutDimCode(2, Instrument."Global Dimension 2 Code");
                SLine.ValidateShortcutDimCode(3, Instrument."Country/Region of Origin Code");
                SLine.ValidateShortcutDimCode(4, FinTypeProvSell);
                SLine.ValidateShortcutDimCode(5, MarketGPW);
                case true of
                    Institution = Institution::Alior:
                        SLine.ValidateShortcutDimCode(6, DMALIOR);
                    Institution = Institution::BOS:
                        SLine.ValidateShortcutDimCode(6, DMBOS);
                end;

                IF not SLine.Insert() then;
            until StockLine.Next() = 0;
        end;

    end;
}