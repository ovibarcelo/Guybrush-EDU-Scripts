# Import the module MSAL.PS
try {
    Import-Module MSAL.PS -ErrorAction Stop
    Write-Host "The module MSAL.PS is already installed."
} catch {
    # If the module is not installed, install it from the PowerShell Gallery
    Write-Host "The module MSAL.PS is not installed. Installing it from the PowerShell Gallery..."
    Install-Module MSAL.PS -Scope CurrentUser -Force
    Write-Host "The module MSAL.PS is installed successfully."
}
 


#Provide your Office 365 Tenant Domain Name or Tenant Id
$TenantId = Write-Host "Please enter your tenant name. Remember it must end with .onmicrosoft.com"

$TenantId = Read-Host
$TenantId = $TenantId
#$TenantId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   
#Used the Microsoft Graph PowerShell app id. You can create and use your own Azure AD App id if needed.
$AppClientId="14d82eec-204b-4c2f-b7e8-296a70dab67e"  
   
$MsalParams = @{
   ClientId = $AppClientId
   TenantId = $TenantId
   Scopes   = "https://graph.microsoft.com/User.Read.All","https://graph.microsoft.com/AuditLog.Read.All"
}
  
$MsalResponse = Get-MsalToken @MsalParams
$AccessToken  = $MsalResponse.AccessToken


#Form request headers with the acquired $AccessToken
$headers = @{"Content-Type"="application/json";"Authorization"="Bearer $AccessToken"}
 
#This request get users list with signInActivity.
$ApiUrl = "https://graph.microsoft.com/beta/users?`$select=displayName,userPrincipalName,signInActivity,userType,assignedLicenses"
# Set default days inactive
$DaysInactive = 30

# Prompt the user for a number of days
Write-Host "Enter the number of days a user is inactive:"



# Check if the input is valid
if ($DaysInactive -gt 0) {
    # Display the value of DaysInactive
    Write-Host "The default value of DaysInactive now is $DaysInactive . Please enter the number of inactivity days. Result with the inactive users will be stored in your Downloads folder"
} else {
    # Display an error message
    Write-Host "This is an invalid input. Input must be a positive integer."
}



$Result = @()
While ($ApiUrl -ne $Null) #Perform pagination if next page link (odata.nextlink) returned.
{
$Response =  Invoke-RestMethod -Method GET -Uri $ApiUrl -ContentType "application/json" -Headers $headers
if($Response.value)
{
$Users = $Response.value
ForEach($User in $Users)
{



$Result += New-Object PSObject -property $([ordered]@{ 
DisplayName = $User.displayName
UserPrincipalName = $User.userPrincipalName
LastSignInDateTime = if($User.signInActivity.lastSignInDateTime) { [DateTime]$User.signInActivity.lastSignInDateTime } Else {$null}
LastNonInteractiveSignInDateTime = if($User.signInActivity.lastNonInteractiveSignInDateTime) { [DateTime]$User.signInActivity.lastNonInteractiveSignInDateTime } Else { $null }
IsLicensed  = if ($User.assignedLicenses.Count -ne 0) { $true } else { $false }
IsGuestUser  = if ($User.userType -eq 'Guest') { $true } else { $false }
})
}
 
}
$ApiUrl=$Response.'@odata.nextlink'
}
# Read the user input and convert it to an integer
$DaysInactive = Read-Host
$DaysInactive = [int]$DaysInactive


$dateTime = (Get-Date).Adddays(-($DaysInactive))
$Result | Where-Object { $_.LastSignInDateTime -eq $Null -OR $_.LastSignInDateTime -le $dateTime } | Export-CSV $env:USERPROFILE\Downloads\LastLoginDateReport.CSV -NoTypeInformation -Encoding UTF8
