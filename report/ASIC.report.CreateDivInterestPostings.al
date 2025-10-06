report 50003 "ASIC Create Div.&Int. Postings"
{
    UsageCategory = Administration;
    ApplicationArea = All;

    dataset
    {
        dataitem(FinTran;
        "Fin. Transactions Buffer")
        {
            trigger OnPreDataItem()
            var
                GenJnlLine: Record "Gen. Journal Line";
            begin
                SetRange("Create Posting", true);
                SetFilter("Entry Type", '%1|%2|%3', "Entry Type"::Dividend, "Entry Type"::Interest, "Entry Type"::Tax);
                if findset then begin
                    if not confirm('Create jnl. lines for dividends, interests and taxes from fin. trans. buffer?', false) then
                        CurrReport.Quit();
                end;

                LastLineNo := 0;
                GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
                GenJnlLine.SetRange("Journal Batch Name", 'DEFAULT');
                if GenJnlLine.FindLast() then
                    LastLineNo := GenJnlLine."Line No.";
            end;

            trigger OnAfterGetRecord()
            var
                GenJnlLine: Record "Gen. Journal Line";
                Item: Record Item;
                TempDimValue: Code[20];
            begin
                //SD1 - Equity
                //SD2 - EQ Company
                //SD3 - Country
                //SD4 - FIN TYPE
                //SD5 - MARKET
                case "Entry Type" of
                    "Entry Type"::Dividend:
                        begin
                            Item.GET(Instrument);

                            GenJnlLine.INIT;
                            GenJnlLine."Journal Batch Name" := 'DEFAULT';
                            GenJnlLine."Journal Template Name" := 'GENERAL';
                            GenJnlline."Line No." := GenJnlLine.GetNewLineNo('GENERAL', 'DEFAULT');
                            GenJnlLine.Validate("Posting Date", Date);
                            GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
                            GenJnlLine.Validate("Account No.", '9115');
                            GenJnlLine.Description := Description;
                            GenJnlLine.Validate(Amount, Amount);
                            GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"G/L Account");
                            GenJnlLine.Validate("Bal. Account No.", '5910');
                            GenJnlLine.ValidateShortcutDimCode(1, Item."Inventory Posting Group");
                            GenJnlLine.ValidateShortcutDimCode(2, Item."Global Dimension 2 Code");
                            GenJnlLine.ValidateShortcutDimCode(3, Item."Country/Region of Origin Code");
                            GenJnlLine.ValidateShortcutDimCode(4, FinTypeDiv);
                            GenJnlLine.Insert();

                            GenJnlLine.INIT;
                            GenJnlLine."Journal Batch Name" := 'DEFAULT';
                            GenJnlLine."Journal Template Name" := 'GENERAL';
                            GenJnlline."Line No." := GenJnlLine.GetNewLineNo('GENERAL', 'DEFAULT');
                            GenJnlLine.Validate("Posting Date", Date);
                            GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Payment);
                            GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
                            GenJnlLine.Validate("Account No.", '5910');
                            GenJnlLine.Description := Description;
                            GenJnlLine.Validate(Amount, -Amount);
                            GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"G/L Account");
                            GenJnlLine.Validate("Bal. Account No.", '2921');
                            GenJnlLine.ValidateShortcutDimCode(1, Item."Inventory Posting Group");
                            GenJnlLine.ValidateShortcutDimCode(2, Item."Global Dimension 2 Code");
                            GenJnlLine.ValidateShortcutDimCode(3, Item."Country/Region of Origin Code");
                            GenJnlLine.ValidateShortcutDimCode(4, FinTypeDiv);
                            GenJnlLine.Insert();
                        end;
                    "Entry Type"::Interest:
                        begin
                            Item.GET(Instrument);

                            GenJnlLine.INIT;
                            GenJnlLine."Journal Batch Name" := 'DEFAULT';
                            GenJnlLine."Journal Template Name" := 'GENERAL';
                            GenJnlline."Line No." := GenJnlLine.GetNewLineNo('GENERAL', 'DEFAULT');
                            GenJnlLine.Validate("Posting Date", Date);
                            GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
                            GenJnlLine.Validate("Account No.", '9114');
                            GenJnlLine.Description := Description;
                            GenJnlLine.Validate(Amount, Amount);
                            GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"G/L Account");
                            GenJnlLine.Validate("Bal. Account No.", '5911');
                            GenJnlLine.ValidateShortcutDimCode(1, Item."Inventory Posting Group");
                            GenJnlLine.ValidateShortcutDimCode(2, Item."Global Dimension 2 Code");
                            GenJnlLine.ValidateShortcutDimCode(3, Item."Country/Region of Origin Code");
                            GenJnlLine.ValidateShortcutDimCode(4, FinTypeInt);
                            GenJnlLine.Insert();

                            GenJnlLine.INIT;
                            GenJnlLine."Journal Batch Name" := 'DEFAULT';
                            GenJnlLine."Journal Template Name" := 'GENERAL';
                            GenJnlline."Line No." := GenJnlLine.GetNewLineNo('GENERAL', 'DEFAULT');
                            GenJnlLine.Validate("Posting Date", Date);
                            GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Payment);
                            GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
                            GenJnlLine.Validate("Account No.", '5911');
                            GenJnlLine.Description := Description;
                            GenJnlLine.Validate(Amount, -Amount);
                            GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"G/L Account");
                            GenJnlLine.Validate("Bal. Account No.", '2921');
                            GenJnlLine.ValidateShortcutDimCode(1, Item."Inventory Posting Group");
                            GenJnlLine.ValidateShortcutDimCode(2, Item."Global Dimension 2 Code");
                            GenJnlLine.ValidateShortcutDimCode(3, Item."Country/Region of Origin Code");
                            GenJnlLine.ValidateShortcutDimCode(4, FinTypeInt);
                            GenJnlLine.Insert();
                        end;
                    "Entry Type"::Tax:
                        begin
                            Item.GET(Instrument);

                            GenJnlLine.INIT;
                            GenJnlLine."Journal Batch Name" := 'DEFAULT';
                            GenJnlLine."Journal Template Name" := 'GENERAL';
                            GenJnlline."Line No." := GenJnlLine.GetNewLineNo('GENERAL', 'DEFAULT');
                            GenJnlLine.Validate("Posting Date", Date);
                            GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
                            GenJnlLine.Validate("Account No.", '9510');
                            GenJnlLine.Description := Description;
                            GenJnlLine.Validate(Amount, Amount);
                            GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"G/L Account");
                            GenJnlLine.Validate("Bal. Account No.", '5920');
                            GenJnlLine.ValidateShortcutDimCode(1, Item."Inventory Posting Group");
                            GenJnlLine.ValidateShortcutDimCode(2, Item."Global Dimension 2 Code");
                            GenJnlLine.ValidateShortcutDimCode(4, FinTypeTax);
                            GenJnlLine.Insert();

                            GenJnlLine.INIT;
                            GenJnlLine."Journal Batch Name" := 'DEFAULT';
                            GenJnlLine."Journal Template Name" := 'GENERAL';
                            GenJnlline."Line No." := GenJnlLine.GetNewLineNo('GENERAL', 'DEFAULT');
                            GenJnlLine.Validate("Posting Date", Date);
                            GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Payment);
                            GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
                            GenJnlLine.Validate("Account No.", '5920');
                            GenJnlLine.Description := Description;
                            GenJnlLine.Validate(Amount, -Amount);
                            GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"G/L Account");
                            GenJnlLine.Validate("Bal. Account No.", '2921');
                            GenJnlLine.ValidateShortcutDimCode(1, Item."Inventory Posting Group");
                            GenJnlLine.ValidateShortcutDimCode(2, Item."Global Dimension 2 Code");
                            GenJnlLine.ValidateShortcutDimCode(4, FinTypeTax);
                            GenJnlLine.Insert();
                        end;
                end;
            end;

            trigger OnPostDataItem()
            var
            begin
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
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
        LastLineNo: Integer;
        FinTypeDiv, FinTypeInt, FinTypeTax, MarketGPW : Code[20];

    trigger OnPreReport()
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        FinTypeDiv := 'DIV';
        FinTypeInt := 'INT-BONDS';
        FinTypeTax := 'TAX';
        MarketGPW := 'GPW';

        GenJnlLine.SetRange("Journal Batch Name", 'DEFAULT');
        GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
        if GenJnlLine.findset then
            if confirm('Journal is not empty. Are you sure to remove all existing lines?', false) then
                GenJnlLine.DeleteAll();

    end;

}