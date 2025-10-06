page 50003 "ILE editable"
{

    ApplicationArea = All;
    Caption = 'ILE editable';
    PageType = List;
    SourceTable = "Item Ledger Entry";
    UsageCategory = Administration;
    Editable = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the value of the Posting Date field.';
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the value of the Location Code field.';
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                    ApplicationArea = All;
                }
                field("Item Reference No."; Rec."Item Reference No.")
                {
                    ToolTip = 'Specifies the value of the Item Reference No. field.';
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.';
                    ApplicationArea = All;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ToolTip = 'Specifies the value of the Entry Type field.';
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.';
                    ApplicationArea = All;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the value of the Document Type field.';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = All;
                }
                field("Sales Amount (Expected)"; Rec."Sales Amount (Expected)")
                {
                    ToolTip = 'Specifies the value of the Sales Amount (Expected) field.';
                    ApplicationArea = All;
                }
                field("Sales Amount (Actual)"; Rec."Sales Amount (Actual)")
                {
                    ToolTip = 'Specifies the value of the Sales Amount (Actual) field.';
                    ApplicationArea = All;
                }

                field("Cost Amount (Actual)"; Rec."Cost Amount (Actual)")
                {
                    ToolTip = 'Specifies the value of the Cost Amount (Actual) field.';
                    ApplicationArea = All;
                }
                field("Cost Amount (Actual) (ACY)"; Rec."Cost Amount (Actual) (ACY)")
                {
                    ToolTip = 'Specifies the value of the Cost Amount (Actual) (ACY) field.';
                    ApplicationArea = All;
                }
                field("Cost Amount (Expected)"; Rec."Cost Amount (Expected)")
                {
                    ToolTip = 'Specifies the value of the Cost Amount (Expected) field.';
                    ApplicationArea = All;
                }
                field("Cost Amount (Expected) (ACY)"; Rec."Cost Amount (Expected) (ACY)")
                {
                    ToolTip = 'Specifies the value of the Cost Amount (Expected) (ACY) field.';
                    ApplicationArea = All;
                }
                field("Cost Amount (Non-Invtbl.)"; Rec."Cost Amount (Non-Invtbl.)")
                {
                    ToolTip = 'Specifies the value of the Cost Amount (Non-Invtbl.) field.';
                    ApplicationArea = All;
                }
                field("Cost Amount (Non-Invtbl.)(ACY)"; Rec."Cost Amount (Non-Invtbl.)(ACY)")
                {
                    ToolTip = 'Specifies the value of the Cost Amount (Non-Invtbl.)(ACY) field.';
                    ApplicationArea = All;
                }
            }
        }
    }
}