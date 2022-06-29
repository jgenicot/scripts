# to do replace AfwIp/CpcgIp with IP address of AFW and CPCG and perform a sectionalized test run
$AfwIp = @()
$CpcgIp = @()

$ListOfSubscriptionIDs = @()


Write-Output -InputObject "Enumerating all subscriptions ..."
$ListOfSubscriptionIDs = (Get-AzureRmSubscription).SubscriptionId
Write-Output -InputObject $ListOfSubscriptionIDs


foreach ($SubscriptionID in $ListOfSubscriptionIDs){
    Set-AzureRmContext -SubscriptionId $SubscriptionID
    $RTable = @()
    $TagValue = cpmigration
    $Res = Find-AzureRmResource -TagName udrautomate -TagValue $TagValue

    foreach ($RTable in $Res)
    {
      $Table = Get-AzureRmRouteTable -ResourceGroupName $RTable.ResourceGroupName -Name $RTable.Name
      
      foreach ($RouteName in $Table.Routes)
      {
        Write-Output -InputObject "Updating route table..."
        Write-Output -InputObject $RTable.Name

        for ($i = 0; $i -lt $AfwIp.count; $i++)
        {
          if($RouteName.NextHopIpAddress -eq $CpcgIp[$i])
          {
            Write-Output -InputObject 'Check Point is already active' 
            
          }
          elseif($RouteName.NextHopIpAddress -eq $AfwIp[$i])
          {
            Set-AzureRmRouteConfig -Name $RouteName.Name  -NextHopType VirtualAppliance -RouteTable $Table -AddressPrefix $RouteName.AddressPrefix -NextHopIpAddress $CpcgIp[$i] 
          }
        }

      }
  
      $UpdateTable = [scriptblock]{param($Table) Set-AzureRmRouteTable -RouteTable $Table}
      &$UpdateTable $Table

    }
