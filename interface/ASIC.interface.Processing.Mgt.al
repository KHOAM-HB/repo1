interface IProcessingMgt
{
    procedure CreateDescriptionFromStockBufferLine(buffer: Record "Stock Transactions Buffer"): Text
    procedure CreatePOLine(var POLine: Record "Purchase Line"; var StockLine: Record "Stock Transactions Buffer");
    procedure FindInstrumentForProvision(FinBufferLine: record "Fin. Transactions Buffer"): Text[25]
    procedure GetEntryTypeFromDesc(Description: Text[250]; Description2: Text[250]; TransactionNo: Integer; EntryNo: Integer): enum "Entry Type";
    procedure GetEntryTypeFromOperation(Operation: text[10]; AmountTxt: text[20]): enum "Entry Type"
    procedure GetInstrumentFromDesc(Descripton: Text[250]; Description2: Text[250]): Text[20];
    procedure GetPriceAndProvision(Description: Text[250]; Description2: Text[250]; var Price: Decimal; var Provision: Decimal)
    procedure GetTransactionNoFromDesc(Description: Text[250]; Description2: Text[250]): Integer;
    procedure SetLocation(var Line: Record "Purchase Line");
    procedure SetLocation(var Header: Record "Purchase Header");
    procedure SetLocation(var Line: Record "Sales Line");
    procedure SetLocation(var Header: Record "Sales Header");
    procedure GetVendorInvoiceNo(var Line: record "Stock Transactions Buffer"): Code[35]
    procedure GetExtDocNo(var Line: record "Stock Transactions Buffer"): Code[35]
}