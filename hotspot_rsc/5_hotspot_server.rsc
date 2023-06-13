# ==============================
# Miktrotik Config HotSpot Server
# by: Chloe Renae & Edmar Lozada
# ==============================
/{:put "(HotSpot) Miktrotik Config HotSpot Server";

:local cfg [[:parse [/system script get "cfg-hotspot" source]]];

# --- [ HotSpot ] --- #
:local HSUPName  ($cfg->"HSUPName");
:local BridgeHS  ($cfg->"BridgeHS");
:local HSGateway ([pic [/ip address get [find interface=$BridgeHS] address] 0 [find [/ip address get [find interface=$BridgeHS] address] "/"]]);
:local HPoolName ([/ip dhcp-server get [find interface=$BridgeHS] address-pool]);

# --- [ TIME ] --- #
:local LoginTimeout 5m;
:local IdleTimeout none;
:local KeepAliveTimeout none;

# ==============================
# Hotspot Profile
# ------------------------------
:if ([/ip hotspot profile find name=default]!="") do={
     /ip hotspot profile set [find name=default] name=$HSUPName }
/ip hotspot profile set [find name=$HSUPName] \
    name=$HSUPName \
    hotspot-address=$HSGateway \
    login-by=http-chap,cookie \
    http-cookie-lifetime=31d
:put "(HS Profile) /ip hotspot profile => name:[$HSUPName] hotspot-address:[$HSGateway]"

# ==============================
# Hotspot Server
# ------------------------------
local HSServer ($cfg->"HSServer")
:if ([/ip hotspot find interface=$BridgeHS]="") do={
     /ip hotspot add interface=$BridgeHS name=$HSServer }
/ip hotspot set [find interface=$BridgeHS] \
    name=$HSServer \
    profile=$HSUPName \
    addresses-per-mac=1 \
    idle-timeout=$IdleTimeout \
    login-timeout=$LoginTimeout \
    keepalive-timeout=$KeepAliveTimeout \
    disabled=no
:put "(HS Server) /ip hotspot => name:[$HSServer] interface:[$BridgeHS] profile:[$HSUPName]"

# ==============================
# Queue Simple hotspot-default (sfq)
# ------------------------------
:local HSQueue  ($cfg->"HSQueue")
:local BridgeHS ($cfg->"BridgeHS")
:foreach x in=[/queue simple find target=$BridgeHS] do={ /queue simple remove $x }
/queue simple add name=$HSQueue target=$BridgeHS queue="$($cfg->"QueueType")/$($cfg->"QueueType")"
/queue simple move [find name=$HSQueue] 0
/queue simple set [ find name=$HSQueue ] target=$BridgeHS \
  queue="$($cfg->"QueueType")/$($cfg->"QueueType")" \
  disabled=no
  # max-limit=50M/50M \
:put "(HS Queue Simple) /queue simple => name:[$HSQueue] target:[$BridgeHS] queue-type:[$($cfg->"QueueType")]"

# ==============================
# Hotspot User Profile (default)
# ------------------------------
:local HSUPRate "512k/512k"
/ip hotspot user profile set [find default=yes] \
    !idle-timeout \
    !keepalive-timeout \
    rate-limit=$HSUPRate \
    shared-users=1 \
    parent-queue=($cfg->"HSQueue") \
    queue-type=hotspot-default \
    mac-cookie-timeout=1d
/ip hotspot user profile set [find default=yes] add-mac-cookie=no
/ip hotspot user profile set [find default=yes] on-login="# hsup_login (hsup-Default) #\r\nlog info (\"(hsup-Default) onLogin [ \$user ] [ \$\"mac-address\" ] [ \$address ]\")\r\n"
/ip hotspot user profile set [find default=yes] on-logout="# hsup_login (hsup-Default) #\r\nlog info (\"(hsup-Default) onLogout [ \$user ] [ \$\"mac-address\" ] [ \$address ]\")\r\n"
:put "(HS User Profile) /ip hotspot user profile => name:[default] [$HSUPRate] [$($cfg->"HSQueue")]"

# ------------------------------
:put "(5_hotspot_server.rsc) end...";
}
