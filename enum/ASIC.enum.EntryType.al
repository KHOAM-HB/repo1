enum 50000 "Entry Type"
{
    Extensible = true;

    value(0; None) { }
    value(1; Prov_Buy)
    {
        Caption = 'Provision-Buy';
    }
    value(2; Prov_Sell)
    {
        Caption = 'Provision-Sell';
    }
    value(3; Buy)
    {
        Caption = 'Buy';
    }

    value(4; Sell)
    {
        Caption = 'Sell';
    }

    value(5; Tax)
    {
        Caption = 'Tax';
    }

    value(6; Dividend)
    {
        Caption = 'Dividend';
    }

    value(7; Interest)
    {
        Caption = 'Interests';
    }
}