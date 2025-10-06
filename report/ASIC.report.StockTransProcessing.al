report 50001 "ASIC Stock Trans. Processing"
{
    UsageCategory = Administration;
    Caption = 'ASIC Stock Transactions Processing';
    ApplicationArea = All;
    UseRequestPage = true;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Loop1; "Stock Transactions Buffer")
        {
            trigger OnPreDataItem()
            var
            begin
                if not confirm('Process stock buffer table?', false) then
                    CurrReport.break;
            end;

            trigger OnAfterGetRecord()
            var
            begin
                Evaluate(Date, DateTxt);
                "Entry Type" := IProcessingMgt.GetEntryTypeFromOperation(Operation, AmountTxt);
                case Institution of
                    Institution::Alior:
                        begin
                            if Location = '' then
                                Validate(Location, 'ALIOR-5439');

                        end;
                    Institution::BOS:
                        begin
                            if Location = '' then
                                Validate(Location, 'BOS-151713');
                        end;
                end;
                Evaluate(Quantity, QuantityTxt);
                if (AmountTxt <> 'null') and (AmountTxt <> '') then
                    Evaluate(Amount, AmountTxt);
                if Amount = 0 then
                    Amount := Quantity * Price;
                if Item.Get(Instrument) then begin
                    "Instrument Exists" := true;
                end else
                    "Instrument Exists" := false;
                IProcessingMgt.GetPriceAndProvision(Description, '', Price, "Provision Amount");
                if (Description = '') or (Description = 'Transakcja') then
                    Description := IProcessingMgt.CreateDescriptionFromStockBufferLine(Loop1);
                Modify(true);
            end;
        }

        //link fin & stock transactions
        dataitem(Loop2; "Stock Transactions Buffer")
        {
            trigger OnPreDataItem()
            var
            begin
                SetRange("Create Order", true);
            end;

            trigger OnAfterGetRecord()
            var
                FinTrans: record "Fin. Transactions Buffer";
                FinTrans2: Record "Fin. Transactions Buffer";
            begin
                case Institution of
                    Institution::Alior:
                        begin
                            FinTrans.SetRange(Date, Date);
                            FinTrans.SetRange(Instrument, Instrument);
                            FinTrans.SetRange("Entry Type", "Entry Type");
                            if FinTrans.FindFirst() then begin
                                "Fin. Transaction No." := FinTrans."Entry No.";
                                "Transaction No." := FinTrans."Transaction No.";
                                Modify();
                            end;
                        end;
                    Institution::BOS:
                        begin
                            FinTrans.SetRange(Date, Date);
                            FinTrans.SetRange(Instrument, Instrument);
                            FinTrans.SetRange("Entry Type", "Entry Type");
                            case "Entry Type" of
                                "Entry Type"::Buy:
                                    FinTrans.SetRange(Amount, -Amount);
                                "Entry Type"::Sell:
                                    FinTrans.SetRange(Amount, Amount);
                            end;
                            if FinTrans.FindSet(true, false) then begin
                                FinTrans2 := FinTrans;
                                FinTrans2."Opertation Entry No." := Loop2."Entry No.";
                                FinTrans2.Modify();
                                "Fin. Transaction No." := FinTrans."Entry No.";
                                "Transaction No." := FinTrans."Transaction No.";
                                Modify();
                            end;
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
        Country: Record "Country/Region";
        Item: Record Item;
        AliorProcessingMgt: Codeunit "Alior Processing Mgt.";
        BOSProcessingMgt: Codeunit "BOS Processing Mgt.";
        Institution: Enum Institution;
        IProcessingMgt: Interface IProcessingMgt;

}