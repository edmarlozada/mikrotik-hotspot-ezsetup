# ==============================
# Miktrotik Config Advance
# by: Chloe Renae & Edmar Lozada
# ==============================
/{:put "Miktrotik Config Advance";

:local cfg [[:parse [/system script get "cfg-hotspot" source]]];

# ==============================
# Wireless Security Profiles
# ------------------------------
:if ([/interface wireless find default-name=wlan1]!="") do={
  local WiFiProf "wsp_wp2_aes"
  :if ([/interface wireless security-profiles find name=$WiFiProf]="") do={
       /interface wireless security-profiles add  name=$WiFiProf }
  /interface wireless security-profiles set [find name=$WiFiProf] \
    mode=dynamic-keys \
    group-ciphers=aes-ccm \
    unicast-ciphers=aes-ccm \
    authentication-types=wpa2-psk \
    wpa-pre-shared-key=($cfg->"WiFiPass") \
    wpa2-pre-shared-key=($cfg->"WiFiPass")

  /interface wireless set [find default-name=wlan1] \
    security-profile=$WiFiProf

  # Use Users Access List
  /interface wireless set [find default-name=wlan1] default-authentication=yes
  :put "(Config PC) /interface wireless security-profiles => security-profiles:[$WiFiProf] [aes-ccm] [wpa2-psk]"
}

# ==============================
# Mikrotik Security
# ------------------------------
# /ip neighbor discovery-settings set discover-interface-list=LAN
# /tool mac-server set allowed-interface-list=LAN
# /tool mac-server mac-winbox set allowed-interface-list=LAN
# /ip service set www port=81
# /ip service set www disabled=yes
/ip service set telnet disabled=yes
:put "(Config PC) /ip service => telnet:[disabled]"

# ==============================
# Mikrotik Identity
# ------------------------------
/system identity set name=("Mikrotik".($cfg->"IPSubNet"));

# ------------------------------
:put "(2_config_advance.rsc) end...";
}
