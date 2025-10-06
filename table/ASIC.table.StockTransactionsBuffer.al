table 50002 "Stock Transactions Buffer"
{
    DataClassification = CustomerContent;
    Caption = 'ASIC Stock Transactions Buffer';
    LookupPageId = "ASIC Stock Trans. Buffer List";

    fields
    {
        field(10; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;

        }
        field(20; DateTxt; Text[10])
        {
            DataClassification = CustomerContent;
        }

        field(30; Operation; Text[20])
        {
            DataClassification = CustomerContent;
            Editable = false;

        }
        field(40; Instrument; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Item."No.";

            trigger OnValidate()
            var
                Item: record Item;
                ItemReference: record "Item Reference";
            begin
                if Item.Get(Instrument) then begin
                    "Instrument Exists" := true;
                end else begin
                    "Instrument Exists" := false;
                    //Check cross-references
                    ItemReference.SetRange(ItemReference."Reference Type", ItemReference."Reference Type"::Vendor);
                    ItemReference.SetRange(ItemReference."Reference No.", Instrument);
                    if ItemReference.FindFirst() then begin
                        //Item.get(itemCF."Item No.");
                        Validate(Instrument, ItemReference."Item No.");
                    end;
                end;
            end;

        }

        field(111; "Instrument Exists"; Boolean)
        {
            Editable = false;
        }

        field(50; Description; Text[250])
        {
            DataClassification = CustomerContent;

        }
        field(60; QuantityTxt; Text[20])
        {
            DataClassification = CustomerContent;
            Editable = false;

        }
        field(70; "AmountTxt"; Text[20])
        {
            DataClassification = CustomerContent;
            Editable = false;

        }
        field(100; Date; Date)
        {
            DataClassification = CustomerContent;
        }
        field(110; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(120; Amount; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(121; "Amount w/o Provision"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(128; "Transaction No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(129; "Fin. Transaction No."; Integer)
        {
            DataClassification = CustomerContent;
            TableRelation = "Fin. Transactions Buffer"."Entry No.";
        }

        field(130; "Entry Type"; enum "Entry Type")
        {
            DataClassification = CustomerContent;
        }
        field(140; Price; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(150; "Provision Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(160; Location; Code[10])
        {
            TableRelation = Location.Code;
            DataClassification = CustomerContent;
        }
        field(1000; "Create Order"; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Order; "Date", "Instrument", "Entry Type", "Transaction No.")
        {

        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin
        ValidateCreateOrder();
    end;

    trigger OnModify()
    begin
        ValidateCreateOrder();
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    procedure ValidateCreateOrder();
    begin
        if (Date <> 0D) and
           (Instrument <> '') and
           ("Instrument Exists" = true) and
           (Amount <> 0) and
           (Quantity <> 0) and
           ("Entry Type" <> "Entry Type"::None) then
            "Create Order" := true
        else
            "Create Order" := false;
    end;


}