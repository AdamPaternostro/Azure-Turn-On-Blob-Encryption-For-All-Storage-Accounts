# Finds any ARM storage accounts that have blob encrypted turned off and enables it
# https://docs.microsoft.com/en-us/azure/storage/storage-service-encryption

Login-AzureRmAccount

$subscriptionList = Get-AzureRmSubscription

foreach ($s in $subscriptionList)
{
    # Note: we can write this to loop through all subscriptions
    Select-AzureRmSubscription -SubscriptionId $s.SubscriptionId

    # Gets all Azure resources
    $Resources = Get-AzureRmResource

    foreach ($r in $Resources)
    {
       $item = New-Object -TypeName PSObject -Property @{
                    Name = $r.Name
                    ResourceType = $r.ResourceType
                    ResourceGroupName = $r.ResourceGroupName
                    } | Select-Object Name,  ResourceType, ResourceGroupName

        # Do for ARM
        if ($item.ResourceType -eq "Microsoft.Storage/storageAccounts")
          {
              $string = "Processing ARM storage account: " + $item.Name
              Write-Output $string
              $Ctx  = Get-AzureRmStorageAccount –StorageAccountName $item.Name -ResourceGroupName $item.ResourceGroupName

              $turnOnEncryption = $false;
              if (!$Ctx.Encryption)
              {
                 $string = "Ctx.Encryption: null"
                 Write-Output $string
                 $turnOnEncryption = $true;
              }
              else
              {
                 if ($Ctx.Encryption.Services.Blob.Enabled -eq $false)
                 {
                    $string = "Ctx.Encryption.Services.Blob.Enabled.Value: false"
                    Write-Output $string
                    $turnOnEncryption = $true;
                 }
                 else
                 {
                    $string = "Ctx.Encryption.Services.Blob.Enabled: " + $Ctx.Encryption.Services.Blob.Enabled
                    Write-Output $string
                 }
              }

              if ($turnOnEncryption -eq $true)
              {
                  $string = "Turning on encryption for storage account: " + $item.Name
                  Write-Output $string
                  Set-AzureRmStorageAccount -ResourceGroupName $item.ResourceGroupName -AccountName $item.Name -EnableEncryptionService "Blob"
              }

          }

        # Classic does not support SSE

    } # ($r in $Resources)

    Write-Output ""

} #foreach ($s in $subscriptionList)

