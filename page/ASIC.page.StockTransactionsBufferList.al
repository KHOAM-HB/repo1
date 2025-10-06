page 50002 "ASIC Stock Trans. Buffer List"
{
    Caption = 'Stock Transactions Buffer List';
    PageType = List;
    SourceTable = "Stock Transactions Buffer";
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

                field("Operation"; Rec."Operation")
                {
                    ApplicationArea = All;
                    //Caption = 'Operation';
                    Tooltip = 'Specifies the Operation.';
                }

                field("Instrument"; Rec."Instrument")
                {
                    ApplicationArea = All;
                    //Caption = 'Instrument';
                    Tooltip = 'Specifies the Instrument.';
                    Style = Attention;
                    StyleExpr = NeedAttention;
                }

                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    //Caption = 'Description';
                    Tooltip = 'Specifies the Description.';
                }

                field("QuantityTxt"; Rec."QuantityTxt")
                {
                    ApplicationArea = All;
                    //Caption = 'QuantityTxt';
                    Tooltip = 'Specifies the QuantityTxt.';
                }

                field("AmountTxt"; Rec."AmountTxt")
                {
                    ApplicationArea = All;
                    //Caption = 'AmountTxt';
                    Tooltip = 'Specifies the AmountTxt.';
                }
                field("Instrument Exists"; Rec."Instrument Exists")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Date"; Rec."Date")
                {
                    ApplicationArea = All;
                    //Caption = 'Date';
                    Tooltip = 'Specifies the Date.';
                }

                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = All;
                    //Caption = 'Quantity';
                    Tooltip = 'Specifies the Quantity.';
                }
                field(Location; Rec.Location)
                {
                    ApplicationArea = All;
                    //Caption = 'Quantity';
                    Tooltip = 'Specifies the broker house.';

                }
                field("Amount w/o Provision"; Rec."Amount w/o Provision")
                {
                    ApplicationArea = All;
                    //Caption = 'Amt. w/o Provision';
                    Tooltip = 'Specifies the Amount without Provision.';

                }
                field("Provision Amount"; Rec."Provision Amount")
                {
                    ApplicationArea = All;
                    //Caption = 'Provision Amount';
                    Tooltip = 'Specifies the Provision Amount.';
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

                field("Price"; Rec."Price")
                {
                    ApplicationArea = All;
                    //Caption = 'Price';
                    Tooltip = 'Specifies the Price.';
                }

                field("Transaction No."; Rec."Transaction No.")
                {

                }
                field("Fin. Transaction No."; Rec."Fin. Transaction No.")
                {

                }
                field("Create Order"; Rec."Create Order")
                {
                    ApplicationArea = All;
                    //Caption = 'Create Order';
                    Tooltip = 'Specifies the Create Order.';
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
                    CaptionML = ENU = 'Stock Processing';
                    RunObject = report "ASIC Stock Trans. Processing";
                    Image = Process;
                    Promoted = true;
                    PromotedIsBig = true;
                }
            }
            group(OrdersGroup)
            {
                CaptionML = ENU = 'Orders';
                action("CreatePurchaseOrders")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Create Purch. Orders';
                    RunObject = report "ASIC Create Purch. Orders";
                    Image = Process;
                    Promoted = true;
                    PromotedIsBig = true;
                }
                action("CreateSalesOrders")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Create Sales Orders';
                    RunObject = report "ASIC Create Sales Orders";
                    Image = Process;
                    Promoted = true;
                    PromotedIsBig = true;
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