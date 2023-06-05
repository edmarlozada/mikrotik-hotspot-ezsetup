# ==============================
# Miktrotik Config HotSpot Advance
# by: Chloe Renae & Edmar Lozada
# ==============================
:put "Miktrotik Config HotSpot Advance";

/{:local cfg [[:parse [/system script get "config" source]]];

:local bridgeH1 ($cfg->"BridgeHS");

# ==============================
# Disable changing IP address of clients
# ------------------------------
# :if ([/ip dhcp-server find interface=$bridgeH1]!="") do={
#     [/ip dhcp-server set [find interface=$bridgeH1] add-arp=yes] }
# :if ([/interface bridge find name=$bridgeH1]!="")    do={
#     [/interface bridge set [find name=$bridgeH1] arp=reply-only] }
# :put "(HS Advance) Disable changing IP address of clients"

# ==============================
# Anti Tethering
# ------------------------------
/ip firewall mangle add chain=postrouting action=change-ttl new-ttl=set:1 out-interface=$bridgeH1 passthrough=no;
:put "(HS Advance) Anti Tethering";


# ------------------------------
:console clear }
