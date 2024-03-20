# Connect to Microsoft 365. MOdify "my tenant" with your information

Connect-SPOService -Url https://mytenant-admin.sharepoint.com/
Connect-AzureAD
# Get all AzureAD Users
$AzureADUsers = Get-AzureADUser | ForEach-Object { $_.UserPrincipalName }


# Get all personal sites.
$Sites = Get-SPOSite -Template "SPSPERS" -Limit ALL -IncludePersonalSite $True

# Filters out sites where the owner is not an AzureAD user
$FilteredSites = $Sites | Where-Object { $_.Owner -notin $AzureADUsers }

# Select only the Url and Owner properties.
$FilteredSites = $FilteredSites | Select-Object Url, Owner

# Displays filtered sites
$FilteredSites

# Ask the user for their choice
$UserChoice = Read-Host "Choose an option: `n1. Delete all in bulk `n2. Delete individually `n3. Export to CSV"



switch ($UserChoice) {
    '1' {
        foreach ($Site in $FilteredSites) {
            Remove-SPOSite -Identity $Site.Url -Confirm:$false
            Write-Output "Site $($Site.Url) has been removed."
        }
    }
    '2' {
        foreach ($Site in $FilteredSites) {
            Write-Output "Site URL: $($Site.Url)"
            $UserInput = Read-Host "This site does not have an active user, do you want to delete it (y/n)?"
            if ($UserInput -eq 'y') {
                Remove-SPOSite -Identity $Site.Url -Confirm:$false
                Write-Output "Site $($Site.Url) has been removed."
            }
        }
    }
    '3' {
        $FilteredSites | Export-Csv -Path "C:\Temp\FilteredSites.csv" -NoTypeInformation
        Write-Output "Filtered sites have been exported to C:\Temp\FilteredSites.csv"
    }
    default {
        Write-Output "Invalid option. Please enter 1, 2, or 3."
    }
}