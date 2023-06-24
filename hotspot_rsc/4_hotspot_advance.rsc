# ==============================
# Miktrotik Config HotSpot Advance
# by: Chloe Renae & Edmar Lozada
# ==============================
/{put "(HotSpot) Miktrotik Config HotSpot Advance";
local cfg [[parse [/system script get "cfg-hotspot" source]]];

# --- [ HotSpot ] --- #
local iBrName ($cfg->"BridgeHS");


# ==============================
# Mikrotik Security
# ------------------------------
# /ip neighbor discovery-settings set discover-interface-list=LAN
# /tool mac-server set allowed-interface-list=LAN
# /tool mac-server mac-winbox set allowed-interface-list=LAN
# /ip service set www port=81
# /ip service set www disabled=yes
/ip service set telnet disabled=yes
put "(Config) /ip service => telnet=[disabled]"

# ==============================
# Mikrotik Identity
# ------------------------------
local iName ("Mikrotik".($cfg->"IPSubNet"))
/system identity set name=$iName;
put "(Config) /system identity set => name=[$iName]"

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
# /ip firewall mangle add chain=postrouting action=change-ttl new-ttl=set:1 out-interface=$iBrName passthrough=no;
# put "(HS Advance) Anti Tethering";

# ------------------------------
put "(4_hotspot_advance.rsc) end...";
}
