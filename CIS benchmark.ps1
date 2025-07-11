# Perma link
# https://github.com/palpau/Repository/blob/780df33052b0d95358eb91be37d5c62cbd149566/CIS%20benchmark.txt

# Define the path to the exported config file
$TempPath = $env:TEMP
$CfgPath = Join-Path $TempPath "secpol.cfg"

# Export current security settings
secedit /export /cfg $CfgPath

# Define settings to update
$SettingsToUpdate = @{
    "PasswordHistorySize"   = "24"
    "MaximumPasswordAge"    = "90"
    "MinimumPasswordAge"    = "1"
    "MinimumPasswordLength" = "14"
    "PasswordComplexity" = "1"
    "ClearTextPassword" = "0"
    "RequireLogonToChangePassword" = "0"
    "LockoutBadCount" = "5"
    "AllowAdministratorLockout" = "1"
    "LockoutDuration" = "15"

}

# Read and update the file line-by-line
$UpdatedLines = Get-Content $CfgPath | ForEach-Object {
    $line = $_
    foreach ($key in $SettingsToUpdate.Keys) {
        if ($line -match "^$key\s*=") {
            $line = "$key = $($SettingsToUpdate[$key])"
            break
        }
    }
    $line
}

# Append CIS 2.2.2 setting to the config file
Add-Content $CfgPath "`n[Privilege Rights]"
Add-Content $CfgPath "SeNetworkLogonRight = *S-1-5-32-544, *S-1-5-32-555"
Add-Content $CfgPath "SeTcbPrivilege ="
Add-Content $CfgPath "SeIncreaseQuotaPrivilege = *S-1-5-19, *S-1-5-20, *S-1-5-32-544"
Add-Content $CfgPath "SeInteractiveLogonRight = *S-1-5-32-544, *S-1-5-32-545"
Add-Content $CfgPath "SeRemoteInteractiveLogonRight = *S-1-5-32-544, *S-1-5-32-555"
Add-Content $CfgPath "SeBackupPrivilege = *S-1-5-32-544"


# Write the updated content back to the file
$UpdatedLines | Set-Content $CfgPath

# Apply the updated settings
secedit /configure /db secedit.sdb /cfg $CfgPath /areas SECURITYPOLICY

# Clean up
Remove-Item $CfgPath
