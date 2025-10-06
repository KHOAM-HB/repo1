codeunit 50002 "ASICI Install"
{
    Subtype = Install;
    trigger OnInstallAppPerCompany()
    var
        appInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(appInfo);
        if appInfo.DataVersion = Version.Create(0, 0, 0, 0) then
            HandleFreshInstall
        else
            HandleReinstall;
    end;

    trigger OnInstallAppPerDatabase()
    begin

    end;

    local procedure HandleFreshInstall()
    begin

    end;

    local procedure HandleReinstall()
    begin

    end;
}
