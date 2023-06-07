# ==============================
# Miktrotik Config WAN
# by: Chloe Renae & Edmar Lozada
# ==============================
/{:put "Miktrotik Config WAN";

:local cfg [[:parse [/system script get "cfg-hotspot" source]]];

# ==============================
# Queue SFQ
# ------------------------------
:if ([/queue type find name=($cfg->"QueueType")]="") do={ /queue type add name=($cfg->"QueueType") kind=sfq sfq-perturb=8 }
/queue type set [find name=($cfg->"QueueType")] kind=sfq sfq-perturb=($cfg->"QueueTurb")
:put "(Config) /queue type => name:[$($cfg->"QueueType")] kind:[sfq] sfq-perturb:[$($cfg->"QueueTurb")]"

# ==============================
# WAN
# ------------------------------
:local BridgeWAN     ($cfg->"BridgeWAN")
:local BridgeWANNote ("bridge ( WAN )")
:local eth1ISPName   ("ether1 ( WAN-$($cfg->"ISPName") )")

:if ([/interface bridge find name=$BridgeWAN]="") do={
      /interface bridge  add name=$BridgeWAN }
/interface bridge  set [find name=$BridgeWAN] comment=$BridgeWANNote disabled=no
:put "(Config WAN) /interface bridge => name:[$BridgeWAN]"

:if ([/interface list find name=WAN]="") do={
      /interface list  add name=WAN }
:put "(Config WAN) /interface list => (WAN)"

:if ([/interface list member find interface=$BridgeWAN]="") do={
      /interface list member  add interface=$BridgeWAN  list=WAN }
/interface list member  set [find interface=$BridgeWAN] list=WAN comment=$BridgeWANNote
:put "(Config PC) /interface list member => list:[WAN] interface:[$BridgeWAN]"

:if ([/interface find default-name=ether1]!="") do={
      /interface set [find default-name=ether1] name=ether1 comment=$eth1ISPName disabled=no
  :put "(Config WAN) /interface => name:[ether1] comment:[$eth1ISPName]"
  :if ([/interface bridge port find interface=[/interface get [find default-name=ether1] name]]="") do={
        /interface bridge port  add interface=[/interface get [find default-name=ether1] name] bridge=$BridgeWAN }
  /interface bridge port  set [find interface=[/interface get [find default-name=ether1] name]] bridge=$BridgeWAN comment=$eth1ISPName
  :put "(Config WAN) /interface bridge port => name:[ether1] bridge:[$BridgeWAN]"
}

:if ([/ip dhcp-client find interface=$BridgeWAN]="") do={
      /ip dhcp-client  add interface=$BridgeWAN }
/ip dhcp-client  set [find interface=$BridgeWAN] comment=$BridgeWANNote disabled=no
:put "(Config WAN) /ip dhcp-client => interface:[$BridgeWAN] comment:[$BridgeWANNote]"

:if ([/ip firewall nat find chain=srcnat action=masquerade out-interface=$BridgeWAN]="") do={
      /ip firewall nat  add chain=srcnat action=masquerade out-interface=$BridgeWAN ipsec-policy=out,none comment=$eth1ISPName }
/ip firewall nat  set [find chain=srcnat action=masquerade out-interface=$BridgeWAN] ipsec-policy=out,none comment=$eth1ISPName
:put "(Config WAN) /ip firewall nat => chain:[srcnat] action:[masquerade] out-interface:[$BridgeWAN]"

foreach x in=[/queue simple find target=$BridgeWAN] do={ /queue simple remove $x }
/queue simple add name="queue_$BridgeWAN" target=$BridgeWAN queue="$($cfg->"QueueType")/$($cfg->"QueueType")"
:put "(Config WAN) /queue simple => name:[queue_$BridgeWAN] target:[$BridgeWAN] queue-type:[$($cfg->"QueueType")]"

# ------------------------------
:put "(1_config_wan.rsc) end...";
}
