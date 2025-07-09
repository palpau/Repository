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

# Write the updated content back to the file
$UpdatedLines | Set-Content $CfgPath

# Apply the updated settings
secedit /configure /db secedit.sdb /cfg $CfgPath /areas SECURITYPOLICY

# Clean up
Remove-Item $CfgPath
