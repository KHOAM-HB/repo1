page 50001 "ASIC Fin. Trans. Buffer List"
{
    Caption = 'Fin. Transactions Buffer List';
    PageType = List;
    SourceTable = "Fin. Transactions Buffer";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {

        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    //Caption = 'Entry No.';
                    Tooltip = 'Specifies the Entry No..';
                }

                field("DateTxt"; Rec."DateTxt")
                {
                    ApplicationArea = All;
                    //Caption = 'DateTxt';
                    Tooltip = 'Specifies the DateTxt.';
                }

                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    //Caption = 'Description';
                    Tooltip = 'Specifies the Description.';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    Caption = 'Description 2';
                    ToolTip = 'Specifies another description field, i.e. details.';
                }

                field("AmountTxt"; Rec."AmountTxt")
                {
                    ApplicationArea = All;
                    //Caption = 'AmountTxt';
                    Tooltip = 'Specifies the AmountTxt.';
                }
                field("Country"; Rec."Country")
                {
                    ApplicationArea = All;
                }
                field("Date"; Rec."Date")
                {
                    ApplicationArea = All;
                    //Caption = 'Date';
                    Tooltip = 'Specifies the Date.';
                }

                field("Instrument"; Rec."Instrument")
                {
                    ApplicationArea = All;
                    //Caption = 'Instrument';
                    Tooltip = 'Specifies the Instrument.';
                    Style = Attention;
                    StyleExpr = NeedAttention;
                }
                field("Instrument Exists"; Rec."Instrument Exists")
                {
                    ApplicationArea = All;
                }

                field("Transaction No."; Rec."Transaction No.")
                {
                    ApplicationArea = All;
                    //Caption = 'Transaction No.';
                    Tooltip = 'Specifies the Transaction No..';
                    Editable = true;
                }

                field("Amount"; Rec."Amount")
                {
                    ApplicationArea = All;
                    //Caption = 'Amount';
                    Tooltip = 'Specifies the Amount.';
                }

                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                    //Caption = 'Entry Type';
                    Tooltip = 'Specifies the Entry Type.';
                }

                field("Opertation Entry No."; Rec."Opertation Entry No.")
                {
                    ApplicationArea = All;
                    //Caption = 'Opertation Entry No.';
                    Tooltip = 'Specifies the Opertation Entry No..';
                }

                field("Create Posting"; Rec."Create Posting")
                {
                    ApplicationArea = All;
                    //Caption = 'Create Posting';
                    Tooltip = 'Specifies the Create Posting.';
                }
                field(Paired; Rec.Paired)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(ProcessingGroup)
            {
                CaptionML = ENU = 'Processing';
                action(ProcessingAction)
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Fin. Processing';
                    RunObject = report "ASIC Fin. Trans. Process.";
                    Image = Process;
                }
                action(DivAndInterests)
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Create Div. & Int. Jnl. Lines';
                    RunObject = report "ASIC Create Div.&Int. Postings";
                    Image = Process;
                }
            }
        }
    }

    var
        NeedAttention: boolean;

    trigger OnAfterGetRecord()
    var
    begin
        if (Rec.Instrument <> '') and (Rec."Instrument Exists" = false) then
            NeedAttention := true
        else
            NeedAttention := false;

    end;
}