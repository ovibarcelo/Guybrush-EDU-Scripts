Connect-ExchangeOnline
#Get the retention policy applied to a user
##Get-Mailbox -Identity user@yourschool.com | Select-Object DisplayName, RetentionPolicy

#Get the archive mailbox status for a user
##Get-Mailbox -Identity user@yourschool.com | Select ArchiveStatus, ArchiveDatabase

#Get the Archive status for all
##Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox | Select DisplayName, ArchiveStatus, ArchiveDatabase, RetentionPolcicy

#Get the policy aplied to all
##Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox | Select-Object DisplayName, RetentionPolcicy



# Get the mailboxes that belong to the group "Students"
$mailboxes = Get-Recipient -Filter {Title -eq "Student"}


# Get the retention policy named "My policy"
$policy = Get-RetentionPolicy -Identity "Mypolicy"

# Apply the retention policy to the mailboxes
$mailboxes | ForEach-Object {Set-Mailbox -Identity $_.Identity -RetentionPolicy $policy.Name}

# Verify the policy assignment and export the output to a CSV file
$mailboxes | ForEach-Object {Get-Mailbox -Identity $_.Identity | Select-Object DisplayName, RetentionPolicy} | Export-CSV "C:\PolicyAssignment.csv"
