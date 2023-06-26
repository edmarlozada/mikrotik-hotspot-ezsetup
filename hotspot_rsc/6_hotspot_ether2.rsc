# ==============================
# Miktrotik HotSpot Router (ether2)
# by: Chloe Renae & Edmar Lozada
# ==============================
/{put "(Config LAN) Miktrotik HotSpot Router (ether2)"
local cfg [[parse [/system script get "cfg-hotspot" source]]]

local iBrName  ($cfg->"BridgeHS")
local iBrNote  "bridge ( Hotspot )"
local iEthNote "ether2 ( HotSpot-2 )"


# ==============================
# Interface / Bridge Port (ether2)
# ------------------------------
if ([/interface find default-name=ether2]!="") do={
  local ethName [/interface get [find default-name=ether2] name]
  /interface set [find name=$ethName] comment=$iEthNote disabled=no
  put "(Config LAN) /interface => name=[$ethName] comment=[$iEthNote]"
  if ([/interface bridge port find interface=$ethName]="") do={
       /interface bridge port  add interface=$ethName  bridge=$iBrName
       put "(Config LAN) /interface bridge port add => name=[$ethName] bridge=[$iBrName] comment=[$iEthNote]" }
  /interface bridge port set [find interface=$ethName] bridge=$iBrName comment=$iEthNote
  put "(Config LAN) /interface bridge port => name=[$ethName] bridge=[$iBrName] comment=[$iEthNote]"
}


# ------------------------------
put "(6_hotspot_ether2.rsc) end..."
put "Finishing Up. Wait..."
delay 10s
}
