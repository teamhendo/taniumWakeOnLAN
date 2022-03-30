#######################################################
##
## Adapted further by Brent Henderson
## Adapted by Ammaar Limbada (see: https://gist.github.com/alimbada/4949168)
## Original Author: Matthijs ten Seldam, Microsoft (see: http://blogs.technet.com/matthts)
##
#######################################################

<#
.SYNOPSIS
Starts a list of physical machines by using Wake On LAN.

.DESCRIPTION
Wake sends a Wake On LAN magic packet to a given machine's MAC address.

.PARAMETER MacAddress
MacAddress of target machine to wake.

.EXAMPLE
Wake A0DEF169BE02

.INPUTS
None

.OUTPUTS
None

.NOTES
Make sure the MAC addresses supplied don't contain "-" or ".".
#>

function Send-Packet([string]$MacAddress)
{
<#
.SYNOPSIS
Sends a number of magic packets using UDP broadcast.

.DESCRIPTION
Send-Packet sends a specified number of magic packets to a MAC address in order to wake up the machine.  

.PARAMETER MacAddress
The MAC address of the machine to wake up.
#>

     try
     {
          if ($MacAddress -like "*:*") {
               $MacAddress = $MacAddress.Replace(':','')
          }

          if ($MacAddress -like "*-*") {
               $MacAddress = $MacAddress.Replace('-','')
          }

          $Broadcast = ([System.Net.IPAddress]::Broadcast)

          ## Create UDP client instance
          $UdpClient = New-Object Net.Sockets.UdpClient

          ## Create IP endpoints for each port
          $IPEndPoint = New-Object Net.IPEndPoint $Broadcast, 9

          ## Construct physical address instance for the MAC address of the machine (string to byte array)
          $MAC = [Net.NetworkInformation.PhysicalAddress]::Parse($MacAddress.ToUpper())

          ## Construct the Magic Packet frame
          $Packet =  [Byte[]](,0xFF*6)+($MAC.GetAddressBytes()*16)

          ## Broadcast UDP packets to the IP endpoint of the machine
          $UdpClient.Send($Packet, $Packet.Length, $IPEndPoint) | Out-Null
          $UdpClient.Close()
     }
     catch
     {
          $UdpClient.Dispose()
          $Error | Write-Error;
     }
}