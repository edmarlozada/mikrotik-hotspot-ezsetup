# ==============================
# Miktrotik Config HotSpot Server
# by: Chloe Renae & Edmar Lozada
# ==============================
/{put "(HotSpot) Miktrotik Config HotSpot Server"
local cfg [[parse [/system script get "cfg-hotspot" source]]]

# --- [ HotSpot ] --- #
local iBrName  ($cfg->"BridgeHS")


# ==============================
# Hotspot Profile
# ------------------------------
local HSUPName  ("hsProfile".($cfg->"IPSubNet"))
local HSGateway ("10.0.$($cfg->"IPSubNet").1")
if ([/ip hotspot profile find name=$HSUPName]="") do={
     /ip hotspot profile  add name=$HSUPName}
/ip hotspot profile set [find name=$HSUPName] \
    hotspot-address=$HSGateway \
    login-by=http-chap,cookie \
    http-cookie-lifetime=31d
put "(HS Profile) /ip hotspot profile => name=[$HSUPName] hotspot-address=[$HSGateway]"

# ==============================
# Hotspot Server
# ------------------------------
local LoginTimeout 5m
local IdleTimeout none
local KeepAliveTimeout none
local HSServer ("hsServer".($cfg->"IPSubNet"))
if ([/ip hotspot find interface=$iBrName]="") do={
     /ip hotspot  add interface=$iBrName name=$HSServer }
/ip hotspot set [find interface=$iBrName] \
    name=$HSServer \
    profile=$HSUPName \
    addresses-per-mac=1 \
    idle-timeout=$IdleTimeout \
    login-timeout=$LoginTimeout \
    keepalive-timeout=$KeepAliveTimeout \
    disabled=no
put "(HS Server) /ip hotspot => name=[$HSServer] interface=[$iBrName] profile=[$HSUPName]"

# ==============================
# Queue SFQ
# ------------------------------
local iQueueType ($cfg->"QueueType")
if ([/queue type find name=$iQueueType]="") do={
     /queue type  add name=$iQueueType  kind=sfq sfq-perturb=($cfg->"QueueTurb")}
/queue type set [find name=$iQueueType] kind=sfq sfq-perturb=($cfg->"QueueTurb")
put "(Queue Type) /queue type => name=[$iQueueType] kind=[sfq] sfq-perturb=[$($cfg->"QueueTurb")]"

# ==============================
# Queue Simple hotspot-default
# ------------------------------
local iQueue  ("q_$iBrName")
if ([/queue simple find name=$iQueue]="") do={
     /queue simple  add name=$iQueue  target=$iBrName queue="$iQueueType/$iQueueType" }
/queue simple set [find name=$iQueue] target=$iBrName \
  queue="$iQueueType/$iQueueType" \
  disabled=no
  # max-limit=50M/50M \
/queue simple move [find name=$iQueue] 0
put "(HS Queue Simple) /queue simple => name=[$iQueue] target=[$iBrName] queue-type=[$iQueueType]"

# ==============================
# Hotspot User Profile (default)
# ------------------------------
local HSUPRate "512k/512k"
/ip hotspot user profile set [find default=yes] \
    !idle-timeout \
    !keepalive-timeout \
    rate-limit=$HSUPRate \
    shared-users=1 \
    parent-queue=$iQueue \
    queue-type=hotspot-default \
    mac-cookie-timeout=1d
/ip hotspot user profile set [find default=yes] add-mac-cookie=no
/ip hotspot user profile set [find default=yes] on-login="# hsup_login (hsup-Default) #\r\nlog info (\"(hsup-Default) onLogin [ \$user ] [ \$\"mac-address\" ] [ \$address ]\")\r\n"
/ip hotspot user profile set [find default=yes] on-logout="# hsup_login (hsup-Default) #\r\nlog info (\"(hsup-Default) onLogout [ \$user ] [ \$\"mac-address\" ] [ \$address ]\")\r\n"
put "(HS User Profile) /ip hotspot user profile => name=[default] rate-limit=[$HSUPRate] parent-queue=[$iQueue]"

# ------------------------------
put "(5_hotspot_server.rsc) end..."
}
