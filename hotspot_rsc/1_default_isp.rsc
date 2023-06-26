# ==============================
# Miktrotik Internet Provider
# by: Chloe Renae & Edmar Lozada
# ==============================
/{put "(Config WAN) Miktrotik Internet Provider"
local cfg [[parse [/system script get "cfg-hotspot" source]]]

local iBrName  "bridge-isp1"
local iBrNote  "bridge ( ISP1 )"
local iEthNote "ether1 ( ISP1 )"


# ==============================
# Interface Bridge (ISP)
# ------------------------------
if ([/interface bridge find name=$iBrName]="") do={
     /interface bridge  add name=$iBrName}
/interface bridge set [find name=$iBrName] comment=$iBrNote disabled=no
put "(Config WAN) /interface bridge => name=[$iBrName] comment=[$iBrNote]"

# ==============================
# Interface List (ISP)
# ------------------------------
if ([/interface list find name=WAN]="") do={
     /interface list  add name=WAN
     put "(Config WAN) /interface list => (WAN)" }

if ([/interface list member find interface=$iBrName]="") do={
     /interface list member  add interface=$iBrName  list=WAN }
/interface list member set [find interface=$iBrName] list=WAN comment=$iBrNote
put "(Config WAN) /interface list member => list=[WAN] interface=[$iBrName] comment=[$iBrNote]"

if ([/interface list member find interface=ether1]="") do={
     /interface list member  add interface=ether1  list=WAN }
/interface list member set [find interface=ether1] list=WAN comment=$iEthNote
put "(Config WAN) /interface list member => list=[WAN] interface=[ether1] comment=[$iEthNote]"

# ==============================
# Interface / Bridge Port (ISP)
# ------------------------------
if ([/interface find default-name=ether1]!="") do={
  local ethName [/interface get [find default-name=ether1] name]
  /interface set [find name=$ethName] comment=$iEthNote disabled=no
  put "(Config WAN) /interface => name=[$ethName] comment=[$iEthNote]"
  if ([/interface bridge port find interface=$ethName]="") do={
       /interface bridge port  add interface=$ethName  bridge=$iBrName
       put "(Config WAN) /interface bridge port add => name=[$ethName] bridge=[$iBrName]" }
  /interface bridge port set [find interface=$ethName] bridge=$iBrName comment=$iEthNote
  put "(Config WAN) /interface bridge port => name=[$ethName] bridge=[$iBrName] comment=[$iEthNote]"
}

# ==============================
# DHCP Client (ISP)
# ------------------------------
if ([/ip dhcp-client find interface=$iBrName]="") do={
     /ip dhcp-client  add interface=$iBrName}
/ip dhcp-client set [find interface=$iBrName] dhcp-options="" comment=$iBrNote disabled=no
put "(Config WAN) /ip dhcp-client => interface=[$iBrName] comment=[$iBrNote]"

# ==============================
# Firewall NAT (ISP)
# ------------------------------
if ([/ip firewall nat find chain=srcnat action=masquerade out-interface-list="WAN"]="") do={
     /ip firewall nat  add chain=srcnat action=masquerade out-interface-list="WAN"  ipsec-policy=out,none comment=$iEthNote }
/ip firewall nat set [find chain=srcnat action=masquerade out-interface-list="WAN"] ipsec-policy=out,none comment=$iEthNote
put "(Config WAN) /ip firewall nat => chain=[srcnat] action=[masquerade] out-interface-list=[WAN]"

# ------------------------------
put "(1_default_isp.rsc) end..."
}
