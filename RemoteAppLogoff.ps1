<# 
Remoteapp session logoff
Users that use this script need to be part of the administrators group on the RD Broker server, and I believe any of your session hosts
Also need to have remote server administration tools installed
https://www.microsoft.com/en-us/download/details.aspx?id=45520
Torbar 8-17-18
Thanks to https://poshgui.com for the powershell gui builder
#>

#full FQDN of your rdbroker server
$rdbroker="rdbroker.contoso.com"

#your domain, so in the sessionhost server column it doesn't show the full FQDN, just the server name
$domain=".contoso.com"


Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()


#Check to make sure remotedesktop powershell module is installed.  If it is, continue, if not say it needs RSAT and gives you option to download it
if (Get-Module -ListAvailable -Name remotedesktop) {
#all good, go on            
} else {
    
     $msgBoxInput = [System.Windows.Forms.MessageBox]::Show('Remote Desktop module not installed
Download and install Remote Server Administration tools from Microsoft
launch download page?
', 'Remote desktop', 'YesNo', 'Error')
     switch ($msgBoxInput) {

                'Yes' {Start-Process -file iexplore -arg 'https://www.microsoft.com/en-us/download/details.aspx?id=45520' -PassThru }

                'No' {
                    #Do nothing
                }
            }

exit

}




#create GUI

$Form = New-Object system.Windows.Forms.Form
$Form.ClientSize = '520,438'
$Form.text = "RemoteDesktop Logoff"
$Form.TopMost = $false

$ListView1 = New-Object system.Windows.Forms.ListView
$ListView1.text = "listView"
$ListView1.width = 475
$ListView1.height = 236
$ListView1.location = New-Object System.Drawing.Point(23, 64)
$ListView1.View = [System.Windows.Forms.View]::Details
$ListView1.Columns.Add("Session ID", 100) | Out-Null
$ListView1.Columns.Add("Collection", 100) | Out-Null
$ListView1.Columns.Add("User", 150) | Out-Null
$ListView1.Columns.Add("Server", -2) | Out-Null

$UsernameLabel = New-Object system.Windows.Forms.Label
$UsernameLabel.text = "Username"
$UsernameLabel.AutoSize = $true
$UsernameLabel.width = 25
$UsernameLabel.height = 10
$UsernameLabel.location = New-Object System.Drawing.Point(26, 23)
$UsernameLabel.Font = 'Microsoft Sans Serif,10'

$UsernameTextBox = New-Object system.Windows.Forms.TextBox
$UsernameTextBox.multiline = $false
$UsernameTextBox.width = 100
$UsernameTextBox.height = 20
$UsernameTextBox.location = New-Object System.Drawing.Point(94, 23)
$UsernameTextBox.Font = 'Microsoft Sans Serif,10'
$UsernameTextBox.Text = "*"

$SearchButton = New-Object system.Windows.Forms.Button
$SearchButton.text = "Search"
$SearchButton.width = 60
$SearchButton.height = 30
$SearchButton.location = New-Object System.Drawing.Point(209, 17)
$SearchButton.Font = 'Microsoft Sans Serif,10'

$EndSessionButton = New-Object system.Windows.Forms.Button
$EndSessionButton.text = "End Session"
$EndSessionButton.width = 111
$EndSessionButton.height = 30
$EndSessionButton.location = New-Object System.Drawing.Point(48, 366)
$EndSessionButton.Font = 'Microsoft Sans Serif,10'

$Form.controls.AddRange(@($ListView1, $UsernameLabel, $UsernameTextBox, $SearchButton, $EndSessionButton))


#logic here
$SearchButton.Add_Click( {  
        $ListView1.Items.Clear()
               
        if ($UsernameTextBox.Text.Length -lt 1) {$UsernameTextBox.Text = '*'}
        $Usersessions = Get-RDUserSession -ConnectionBroker $rdbroker | Sort-Object -Property UserName| where {$_.UserName -like "*" + $UsernameTextBox.text + "*"}

        foreach ($UserSession in $Usersessions) {
            $Hostserver = $UserSession.HostServer.Replace("$domain", "")
            $ListViewItem = New-Object System.Windows.Forms.ListViewItem($Usersession.UnifiedSessionID)
            $ListViewItem.Subitems.Add($Usersession.CollectionName)
            $ListViewItem.Subitems.Add($Usersession.Username)
            $ListViewItem.Subitems.Add($Hostserver)
            $ListView1.Items.Add($ListViewItem)
        }
    })
$EndSessionButton.Add_Click( {  

        foreach ($item in $ListView1.SelectedItems) { 
            $sessionID = $item.SubItems[0].text
            $collectionname = $item.SubItems[1].text
            $username = $item.SubItems[2].text
            $servername = $item.SubItems[3].text
            Write-Host "Session" $sessionID
            Write-Host "Collection" $collectionname
            Write-Host "username" $username
            Write-Host "server" $servername

            $msgBoxInput = [System.Windows.Forms.MessageBox]::Show('Log ' + $username + ' off of ' + $servername + '?', 'Error', 'YesNo', 'Error')

            switch ($msgBoxInput) {

                'Yes' {Invoke-RDUserLogoff -HostServer $servername -UnifiedSessionID $sessionID -Force}

                'No' {
                    #Do nothing
                }
            }
          }
        })
    [void]$Form.ShowDialog()
