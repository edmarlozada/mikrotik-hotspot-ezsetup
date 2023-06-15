# ==============================
# Miktrotik Config WAN
# by: Chloe Renae & Edmar Lozada
# ==============================
/{:put "(HotSpot) Miktrotik Config WAN";

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
:local eth1Name [/interface get [find default-name=ether1] name]
:local eth1Note ("ether1 ( WAN )")
:local eth1ISPN ("ether1 ( WAN-$($cfg->"ISPName") )")

:if ([/interface list find name=WAN]="") do={
      /interface list  add name=WAN }
:put "(Config WAN) /interface list => (WAN)"

:if ([/interface list member find interface=$eth1Name]="") do={
      /interface list member  add interface=$eth1Name  list=WAN }
/interface list member  set [find interface=$eth1Name] list=WAN comment=$eth1Note
:put "(Config WAN) /interface list member => list:[WAN] interface:[$eth1Name]"

:if ([/interface find default-name=ether1]!="") do={
      /interface set [find default-name=ether1] name=ether1 comment=$eth1ISPN disabled=no
  :put "(Config WAN) /interface => name:[ether1] comment:[$eth1ISPN]"
}

:if ([/ip dhcp-client find interface=$eth1Name]="") do={
      /ip dhcp-client  add interface=$eth1Name }
/ip dhcp-client  set [find interface=$eth1Name] comment=$eth1Note disabled=no
:put "(Config WAN) /ip dhcp-client => interface:[$eth1Name] comment:[$eth1Note]"

:if ([/ip firewall nat find chain=srcnat action=masquerade out-interface=$eth1Name]="") do={
      /ip firewall nat  add chain=srcnat action=masquerade out-interface=$eth1Name ipsec-policy=out,none comment=$eth1ISPN }
/ip firewall nat  set [find chain=srcnat action=masquerade out-interface=$eth1Name] ipsec-policy=out,none comment=$eth1ISPN
:put "(Config WAN) /ip firewall nat => chain:[srcnat] action:[masquerade] out-interface:[$eth1Name]"

# ------------------------------
:put "(1_config_wan.rsc) end...";
}
