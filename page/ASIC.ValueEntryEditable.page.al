page 50004 "VE Editable"
{

    ApplicationArea = All;
    Caption = 'VE Editable';
    PageType = List;
    SourceTable = "Value Entry";
    UsageCategory = Administration;
    Editable = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    ApplicationArea = All;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ToolTip = 'Specifies the value of the Entry Type field.';
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the value of the Location Code field.';
                    ApplicationArea = All;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ToolTip = 'Specifies the value of the Document Date field.';
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
                field("Exp. Cost Posted to G/L (ACY)"; Rec."Exp. Cost Posted to G/L (ACY)")
                {
                    ToolTip = 'Specifies the value of the Exp. Cost Posted to G/L (ACY) field.';
                    ApplicationArea = All;
                }
                field("Expected Cost"; Rec."Expected Cost")
                {
                    ToolTip = 'Specifies the value of the Expected Cost field.';
                    ApplicationArea = All;
                }
                field("Expected Cost Posted to G/L"; Rec."Expected Cost Posted to G/L")
                {
                    ToolTip = 'Specifies the value of the Expected Cost Posted to G/L field.';
                    ApplicationArea = All;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ToolTip = 'Specifies the value of the External Document No. field.';
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                    ApplicationArea = All;
                }

                field("Sales Amount (Actual)"; Rec."Sales Amount (Actual)")
                {
                    ToolTip = 'Specifies the value of the Sales Amount (Actual) field.';
                    ApplicationArea = All;
                }
                field("Sales Amount (Expected)"; Rec."Sales Amount (Expected)")
                {
                    ToolTip = 'Specifies the value of the Sales Amount (Expected) field.';
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
