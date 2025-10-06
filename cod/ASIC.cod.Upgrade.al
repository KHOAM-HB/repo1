codeunit 50003 "ASIC Upgrade Item Ref."
{
    Subtype = Upgrade;

    trigger OnCheckPreconditionsPerDatabase()
    var
    begin
        //check if ok to upgrade

    end;

    trigger OnCheckPreconditionsPerCompany()
    var
        appInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(appInfo);
        if appInfo.DataVersion < Version.Create(1, 0, 1, 0) then
            error('The upgrade is not compatibile');
        //check if ok to upgrade
    end;

    trigger OnUpgradePerDatabase()
    begin
        //upgrade
    end;

    trigger OnUpgradePerCompany()
    begin
        //upgrade
        UpgradeItemReferences();
    end;

    trigger OnValidateUpgradePerDatabase()
    begin
        //post upgrade checks
    end;

    trigger OnValidateUpgradePerCompany()
    begin
        //post upgrade checks
    end;

    local procedure UpgradeItemReferences()
    var
        //itemCF: record "Item Cross Reference";
        itemRef: record "Item Reference";
    begin
        // itemCF.Reset();
        // if itemCF.FindSet(false, false) then begin
        //     repeat
        //         //key(Key1; "Item No.", "Variant Code", "Unit of Measure", "Reference Type", "Reference Type No.", "Reference No.")
        //         itemRef.Init();
        //         itemRef."Item No." := itemCF."Item No.";
        //         itemRef."Variant Code" := itemCF."Variant Code";
        //         itemRef."Unit of Measure" := itemCF."Unit of Measure";
        //         case itemCF."Cross-Reference Type" of
        //             itemCF."Cross-Reference Type"::" ":
        //                 itemRef."Reference Type" := itemRef."Reference Type"::" ";
        //             itemCF."Cross-Reference Type"::"Bar Code":
        //                 itemRef."Reference Type" := itemRef."Reference Type"::"Bar Code";
        //             itemCF."Cross-Reference Type"::Customer:
        //                 itemRef."Reference Type" := itemRef."Reference Type"::Customer;
        //             itemCF."Cross-Reference Type"::Vendor:
        //                 itemRef."Reference Type" := itemRef."Reference Type"::Vendor;
        //         end;
        //         itemRef."Reference Type No." := itemCF."Cross-Reference Type No.";
        //         itemRef."Reference No." := itemCF."Cross-Reference No.";
        //         if itemRef.Insert(true) then;
        //     until itemCF.Next() = 0;
        //end;
    end;
}
