table 50003 "Unique Trans. No."
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Transaction No."; Integer)
        {
            DataClassification = CustomerContent;

        }
    }

    keys
    {
        key(PK; "Transaction No.")
        {
            Clustered = true;
        }
    }


    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}