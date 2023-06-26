# ==============================
# Miktrotik Config HotSpot Advance
# by: Chloe Renae & Edmar Lozada
# ==============================
/{put "(HotSpot) Miktrotik Config HotSpot Advance"
local cfg [[parse [/system script get "cfg-hotspot" source]]]

# --- [ HotSpot ] --- #
local iBrName ($cfg->"BridgeHS")


# ==============================
# Disable changing IP address of clients
# ------------------------------
# if ([/ip dhcp-server find interface=$iBrName]!="") do={
#     [/ip dhcp-server set [find interface=$iBrName] add-arp=yes] }
# if ([/interface bridge find name=$iBrName]!="")    do={
#     [/interface bridge set [find name=$iBrName] arp=reply-only] }
# put "(HS Advance) Disable changing IP address of clients"

# ==============================
# Anti Tethering
# ------------------------------
# /ip firewall mangle add chain=postrouting action=change-ttl new-ttl=set:1 out-interface=$iBrName passthrough=no
# put "(HS Advance) Anti Tethering"

# ------------------------------
put "(4_hotspot_advance.rsc) end..."
}
