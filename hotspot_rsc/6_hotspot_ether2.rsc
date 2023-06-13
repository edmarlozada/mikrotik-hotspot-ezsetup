# ==============================
# Miktrotik HotSpot Router (ether2)
# by: Chloe Renae & Edmar Lozada
# ==============================
/{:put "(HotSpot) Miktrotik HotSpot Router (ether2)";

:local cfg [[:parse [/system script get "cfg-hotspot" source]]]

:local BridgeHS ($cfg->"BridgeHS");
:local ether ether2;
:local iNote ("$ether ( LAN-HS-2 )");
/interface set [find default-name=$ether] name=$ether comment=$iNote disabled=no;
:put "(Config HS) /interface => name=[$ether] comment=[$iNote]";
:if ([/interface bridge port find interface=$ether]="") do={
      /interface bridge port  add interface=$ether  bridge=$BridgeHS };
/interface bridge  port set [find interface=$ether] bridge=$BridgeHS comment=$iNote;
:put "(Config HS) /interface bridge port => name=[$ether] bridge=[$BridgeHS] comment=[$iNote]";

# ------------------------------
:put "(6_hotspot_ether2.rsc) end...";
:put "Finishing Up. Wait..."
:delay 10s
}
