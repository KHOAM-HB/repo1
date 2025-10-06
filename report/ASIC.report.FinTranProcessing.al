report 50005 "ASIC Fin. Trans. Process."
{
    ApplicationArea = All;
    Caption = 'ASIC Fin. Transactions Processing';
    ProcessingOnly = true;
    UsageCategory = Administration;
    UseRequestPage = true;

    dataset
    {
        dataitem(Loop1;
        "Fin. Transactions Buffer")
        {
            trigger OnPreDataItem()
            var
            begin

            end;

            trigger OnAfterGetRecord()
            var
                itemReference: Record "Item Reference";
            begin
                Evaluate(Date, DateTxt);
                if Instrument = '' then
                    Instrument := IProcessingMgt.GetInstrumentFromDesc(Description, "Description 2");
                if Item.Get(Instrument) then begin
                    "Instrument Exists" := true;
                    Validate(Instrument, Instrument);
                    Loop1.Validate(Country, Item."Country/Region of Origin Code");
                end else begin
                    "Instrument Exists" := false;
                    //Check item references
                    itemReference.SetRange(itemReference."Reference Type", itemReference."Reference Type"::Vendor);
                    itemReference.SetRange(itemReference."Reference No.", Instrument);
                    if itemReference.FindFirst() then begin
                        "Instrument Exists" := true;
                        Validate(Instrument, itemReference."Item No.");
                        Item.get(itemReference."Item No.");
                        Loop1.Validate(Country, Item."Country/Region of Origin Code");
                    end

                end;
                "Transaction No." := IProcessingMgt.GetTransactionNoFromDesc(Description, "Description 2");
                Evaluate(Amount, AmountTxt);
                "Entry Type" := IProcessingMgt.GetEntryTypeFromDesc(Description, "Description 2", "Transaction No.", "Entry No.");
                If Country <> '' then
                    Validate(Country, Country);

                Modify(true);

            end;
        }
        dataitem(Loop2; "Fin. Transactions Buffer")
        {
            trigger OnPreDataItem()
            var
            begin
                case Institution of
                    Institution::Alior:
                        begin
                            //Assign provision financial lines to stock lines
                            SetFilter("Entry Type", '%1|%2', "Entry Type"::Prov_Buy, "Entry Type"::Prov_Sell);

                        end;
                    Institution::BOS:
                        begin
                            //Assign financial lines to stock lines (where provision data are)
                            SetFilter("Entry Type", '%1|%2', "Entry Type"::Buy, "Entry Type"::Sell);
                        end;
                end;
            end;

            trigger OnAfterGetRecord()
            var
                StockBufferLine: Record "Stock Transactions Buffer";
            begin
                case Institution of
                    Institution::Alior:
                        begin
                            Instrument := IProcessingMgt.FindInstrumentForProvision(Loop2);
                            if Item.Get(Instrument) then begin
                                "Instrument Exists" := true;
                                Loop2.Validate(Country, Item."Country/Region of Origin Code");
                            end else
                                "Instrument Exists" := false;
                            Modify(true);
                        end;
                    Institution::BOS:
                        begin
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
        TextMgt: Codeunit "Text Mgt.";
        Institution: Enum Institution;
        IProcessingMgt: Interface IProcessingMgt;

    trigger OnPreReport()
    var
    begin
    end;
}