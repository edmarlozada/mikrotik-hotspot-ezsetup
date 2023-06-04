# ==============================
# Miktrotik Config Basic
# by: Chloe Renae & Edmar Lozada
# ==============================
:put "Miktrotik Config Basic";

/{:local cfg [[:parse [/system script get "config" source]]];

# --- [ LAN Subnet ] --- #
:local PCIPNET ("192.168");
:local PCIPSUB ($cfg->"IPSubNet");
:local PCIPBEG ("50");
:local PCIPEND ("70");

# --- [ Bridge ] --- #
:local BridgePC     ($cfg->"BridgePC");
:local BridgePCNote ("bridge ( PC )");

# --- [ Address PC ] --- #
:local PCNetwork ($PCIPNET.".".$PCIPSUB.".0");
:local PCAddress ($PCIPNET.".".$PCIPSUB.".1");
:local PCGateway ($PCIPNET.".".$PCIPSUB.".1");

# --- [ DHCP PC ] --- #
:local PCDHCPServ ("dhcp-pc");
:local PCPoolName ("dhcp_pool_pc_".$PCIPSUB.".".$PCIPBEG);
:local PCPoolAddr ($PCIPNET.".".$PCIPSUB.".".$PCIPBEG."-".$PCIPNET.".".$PCIPSUB.".".$PCIPEND);


# ==============================
# Interface Bridge
# ------------------------------
:if ([/interface bridge find name=$BridgePC]="") do={
      /interface bridge  add name=$BridgePC }
/interface bridge  set [find name=$BridgePC] comment=$BridgePCNote disabled=no
:put "(Config PC) /interface bridge => name:[$BridgePC]"

# ==============================
# Interface List
# ------------------------------
:if ([/interface list find name=LAN]="") do={
      /interface list  add name=LAN }
:put "(Config PC) /interface list (LAN)"

:if ([/interface list member find interface=$BridgePC]="") do={
      /interface list member  add interface=$BridgePC  list=LAN }
/interface list member  set [find interface=$BridgePC] list=LAN comment=$BridgePCNote
:put "(Config PC) /interface list member => list:[LAN] interface:[$BridgePC]"

# ==============================
# BRIDGE PC IP-Addresses
# ------------------------------
:if ([/ip address find interface=$BridgePC]="") do={
      /ip address  add interface=$BridgePC address=($PCAddress."/24") }
/ip address  set [find interface=$BridgePC] \
    address=($PCAddress."/24") \
    network=$PCNetwork \
    comment=$BridgePCNote
:put "(Config PC) /ip address => address:[$PCAddress] network:[$PCNetwork] interface:[$BridgePC]"

# ==============================
# DHCP Server
# ------------------------------
:if ([/ip pool find name=$PCPoolName]="") do={
      /ip pool  add name=$PCPoolName  ranges=$PCPoolAddr }
/ip pool  set [find name=$PCPoolName] ranges=$PCPoolAddr comment="$PCPoolName $PCPoolAddr"
:put "(Config PC) /ip pool => name:[$PCPoolName] ranges:[$PCPoolAddr]"

:if ([/ip dhcp-server find interface=$BridgePC]="") do={
      /ip dhcp-server  add interface=$BridgePC name=$PCDHCPServ }
/ip dhcp-server  set [find interface=$BridgePC] \
    name=$PCDHCPServ \
    address-pool=$PCPoolName \
    insert-queue-before=bottom \
    lease-time=1d \
    disabled=no
:put "(Config PC) /ip dhcp-server => name:[$PCDHCPServ] interface:[$BridgePC] pool:[$PCPoolName]"

:if ([/ip dhcp-server network find address=($PCNetwork."/24")]="") do={
      /ip dhcp-server network  add address=($PCNetwork."/24") }
/ip dhcp-server network  set [find address=($PCNetwork."/24")] \
    gateway=$PCGateway \
    dns-server=$PCGateway \
    comment="$PCDHCPServ (Address & Gateway)"
:put "(Config PC) /ip dhcp-server network => address:[$PCNetwork] gateway:[$PCGateway] dns-server:[$PCGateway]"

# ==============================
# DNS Settings
# ------------------------------
/ip dns set allow-remote-requests=yes
:put "(Config) /ip dns => allow-remote-requests:[yes]"

# ==============================
# User => Name and Password
# ------------------------------
local WinboxUser ($cfg->"WinboxUser")
local WinboxPass ($cfg->"WinboxPass")
:if ([/user find name=$WinboxUser]="") do={
      /user  add name=$WinboxUser  password=$WinboxPass group=full }
/user  set [find name=$WinboxUser] password=$WinboxPass group=full comment="Winbox User (Admins)" disabled=no
:put "(Config) /user => name:[$WinboxUser]"

# Admin User
/user set [find name=($cfg->"AdminUser")] password=($cfg->"AdminPass")
/user set [find name="admin"] disabled=($cfg->"AdminOff")
:put "(Config) /user => name:[admin] disabled:[$($cfg->"AdminOff")]"

# ==============================
# Mikrotik Clock (Date & Time)
# primary-ntp   = 121.58.193.100 ( dost.gov.ph )
# secondary-ntp = 45.86.70.11 ( 0.asia.pool.ntp.org )
# ------------------------------
/system clock set time-zone-autodetect=no time-zone-name=Asia/Manila
:put "(Config) /system clock => time-zone-autodetect:[no] time-zone-name:[Asia/Manila]"

/ip cloud set update-time=no
/system ntp client set enabled=yes \
   primary-ntp=121.58.193.100 \
   secondary-ntp=45.86.70.11 \
   server-dns-names=asia.pool.ntp.org
:put "(Config) /system ntp client => primary-ntp:[121.58.193.100] secondary-ntp:[45.86.70.11]"

/system package update set channel=long-term

# ==============================
# Set Systems Logging
# ------------------------------
/system logging action set memory memory-lines=1
/system logging action set memory memory-lines=1000
/system logging set [find topics="info"] disabled=yes
:if ([/system logging find topics="script"]="")       do={/system logging add topics="script"}
/system logging set [find topics="script"] disabled=no
:if ([/system logging find topics="hotspot"]="")       do={/system logging add topics="hotspot"}
/system logging set [find topics="hotspot"] disabled=yes
:if ([/system logging find topics="hotspot;info"]="") do={/system logging add topics="hotspot,info"}
/system logging set [find topics="hotspot;info"] disabled=no
:put "(Config) /system logging => topics:[script] topics:[hotspot] topics:[hotspot;info]"

# ==============================
# Queue SFQ
# ------------------------------
:if ([/queue type find name=($cfg->"QueueType")]="") do={ /queue type add name=($cfg->"QueueType") kind=sfq sfq-perturb=8 }
/queue type set [find name=($cfg->"QueueType")] kind=sfq sfq-perturb=8 
:put "(Config) /queue type => name:[$($cfg->"QueueType")] kind:[sfq] sfq-perturb:[8]"


# ==============================
# WAN
# ------------------------------
:local BridgeWAN     ($cfg->"BridgeWAN")
:local BridgeWANNote ("bridge ( WAN )")
:local eth1Note      ("ether1 ( WAN-$($cfg->"ISPName") )")
:if ([/interface list find name=WAN]="") do={
      /interface list  add name=WAN }
:put "(Config WAN) /interface list => (WAN)"

:if ([/interface bridge find name=$BridgeWAN]="") do={
      /interface bridge  add name=$BridgeWAN }
/interface bridge  set [find name=$BridgeWAN] comment=$BridgeWANNote disabled=no
:put "(Config WAN) /interface bridge => name:[$BridgeWAN]"

:if ([/interface list member find interface=$BridgeWAN]="") do={
      /interface list member  add interface=$BridgeWAN  list=WAN }
/interface list member  set [find interface=$BridgeWAN] list=WAN comment=$BridgeWANNote
:put "(Config WAN) /interface list member => list:[WAN] interface:[$BridgeWAN]"

:if ([/interface find default-name=ether1]!="") do={
      /interface set [find default-name=ether1] name=ether1 comment=$eth1Note disabled=no
  :put "(Config WAN) /interface => name:[ether1] comment:[$eth1Note]"
  :if ([/interface bridge port find interface=[/interface get [find default-name=ether1] name]]="") do={
        /interface bridge port  add interface=[/interface get [find default-name=ether1] name] bridge=$BridgeWAN }
  /interface bridge port  set [find interface=[/interface get [find default-name=ether1] name]] bridge=$BridgeWAN comment=$eth1Note
  :put "(Config WAN) /interface bridge port => name:[ether1] bridge:[$BridgeWAN]"
}

:if ([/ip dhcp-client find interface=$BridgeWAN]="") do={
      /ip dhcp-client  add interface=$BridgeWAN }
/ip dhcp-client  set [find interface=$BridgeWAN] comment=$BridgeWANNote disabled=no
:put "(Config WAN) /ip dhcp-client => interface:[$BridgeWAN] comment:[$BridgeWANNote]"

:if ([/ip firewall nat find chain=srcnat action=masquerade out-interface=$BridgeWAN]="") do={
      /ip firewall nat  add chain=srcnat action=masquerade out-interface=$BridgeWAN ipsec-policy=out,none comment=$eth1Note }
/ip firewall nat  set [find chain=srcnat action=masquerade out-interface=$BridgeWAN] ipsec-policy=out,none comment=$eth1Note
:put "(Config WAN) /ip firewall nat => chain:[srcnat] action:[masquerade] out-interface:[$BridgeWAN]"

foreach x in=[/queue simple find target=$BridgeWAN] do={ /queue simple remove $x }
/queue simple add name="queue_$BridgeWAN" target=$BridgeWAN queue="$($cfg->"QueueType")/$($cfg->"QueueType")"
:put "(Config WAN) /queue simple => name:[queue_$BridgeWAN] target:[$BridgeWAN] queue-type:[$($cfg->"QueueType")]"


# ==============================
# Wireless Profiles
# ------------------------------
:if ([/interface wireless find default-name=wlan1]!="") do={
  /interface wireless reset-configuration [find default-name=wlan1]
  /interface wireless set [find default-name=wlan1] \
    mode=ap-bridge \
    wps-mode=disabled \
    wireless-protocol=802.11 \
    band=2ghz-b/g/n \
    channel-width=20/40mhz-eC \
    frequency=auto \
    disabled=no
  /interface wireless set [find default-name=wlan1] \
    ssid=($cfg->"WiFiSSID")
  /interface wireless set [find default-name=wlan1] \
    comment=$wifiNote

  # default settings
  /interface wireless set [find default-name=wlan1] \
    frequency-mode=regulatory-domain \
    tx-power-mode=default \
    country=philippines
  :put "(Config PC) /interface wireless => name:[wlan1] ssid:[$($cfg->"WiFiSSID")]"
}

# ==============================
# Interface / Bridge Port
# ------------------------------
:local eActive;
:foreach iRec in=[/interface ethernet find] do={
  :if ($iRec!="*1") do={
    :local iCtr  [pick $iRec 1 [:len $iRec]];
    :local ether [/interface ethernet get $iRec default-name];
    :local iNote ("$ether ( LAN-PC-$iCtr )");
    :local iFree ([/interface ethernet get $iRec value-name=rx-bytes]=0);
    :if ($iFree) do={
      /interface set $iRec name=$ether comment=$iNote disabled=no;
      :put "(Config PC) /interface => name=[$ether] comment=[$iNote]";
      :if ([/interface bridge port find interface=$ether]="") do={
            /interface bridge port  add interface=$ether  bridge=$BridgePC };
      /interface bridge  port set [find interface=$ether] bridge=$BridgePC comment=$iNote;
      :put "(Config PC) /interface bridge port => name=[$ether] bridge=[$BridgePC] comment=[$iNote]";
    } else={ set eActive $iRec; }
  }
}
:if ([/interface wireless find default-name=wlan1]!="") do={
  :local wifiNote ("ether9 ( LAN-PC-WiFi )");
  /interface wireless set [find default-name=wlan1] name=ether9 comment=$wifiNote;
  :put "(Config PC) /interface wireless => name=[wlan1] comment=[$wifiNote]";
  :if ([/interface bridge port find interface=[/interface get [find default-name=wlan1] name]]="") do={
        /interface bridge port  add interface=[/interface get [find default-name=wlan1] name]  bridge=$BridgePC };
  /interface bridge  port set [find interface=[/interface get [find default-name=wlan1] name]] bridge=$BridgePC comment=$wifiNote;
  :put "(Config PC) /interface bridge port => name=[wlan1] bridge=[$BridgePC] comment=[$wifiNote]";
}
:local iRec $eActive;
:local iCtr  [pick $iRec 1 [:len $iRec]];
:local ether [/interface ethernet get $iRec default-name];
:local iNote ("$ether ( LAN-PC-$iCtr )");
/interface set $iRec name=$ether comment=$iNote disabled=no;
:put "(Config PC) /interface => name=[$ether] comment=[$iNote]";
:if ([/interface bridge port find interface=$ether]="") do={
      /interface bridge port  add interface=$ether  bridge=$BridgePC };
/interface bridge  port set [find interface=$ether] bridge=$BridgePC comment=$iNote;
:put "(Config PC) /interface bridge port => name=[$ether] bridge=[$BridgePC] comment=[$iNote]";


# ------------------------------
:console clear }
:put "Finishing Up. Wait..."
:delay 15s
/system reboot
