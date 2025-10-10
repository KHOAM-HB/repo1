table 50001 "Fin. Transactions Buffer"
{
    DataClassification = CustomerContent;
    Caption = 'ASIC Fin. Trans. Buffer';
    LookupPageId = "ASIC Fin. Trans. Buffer List";

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

        field(30; Description; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = true;

        }
        field(31; "Description 2"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = true;
        }
        field(40; AmountTxt; Text[15])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; Country; Code[2])
        {
            TableRelation = "Country/Region".Code;

        }
        field(100; Date; Date)
        {
            DataClassification = CustomerContent;
        }
        field(110; Instrument; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Item."No.";

            trigger OnValidate()
            var
                Item: record Item;
            begin
                //Check item
                if Item.Get(Instrument) then begin
                    "Instrument Exists" := true;
                    Country := Item."Country/Region of Origin Code";
                end else begin
                    "Instrument Exists" := false;
                end;

            end;
        }
        field(111; "Instrument Exists"; Boolean)
        {
            Editable = false;
        }
        field(120; "Transaction No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(140; Amount; Decimal)
        {
            DataClassification = CustomerContent;
        }

        field(160; "Entry Type"; enum "Entry Type")
        {
            DataClassification = CustomerContent;
        }
        field(170; "Opertation Entry No."; Integer)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup("Stock Transactions Buffer"."Entry No." where("Fin. Transaction No." = field("Entry No.")));

        }
        field(1000; "Create Posting"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(1010; Paired; Boolean)
        {

        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin
        ValidateCreatePosting();
    end;

    trigger OnModify()
    begin
        ValidateCreatePosting();
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    procedure ValidateCreatePosting();
    begin
        if (Date <> 0D) and
           (Instrument <> '') and
           ("Instrument Exists" = true) and
           (Amount <> 0) and
           ("Entry Type" <> "Entry Type"::None) then
            "Create Posting" := true
        else
            "Create Posting" := false;
    end;


}
