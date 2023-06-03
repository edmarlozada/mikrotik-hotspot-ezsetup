# mikrotik-hotspot-autoconfig
Mikrotik Script Automate Setup/Config your Mikrotik with just simple commands for Beginners.
- ":import init" (Initializing Mikrotik)
- "$install mikrotik_basic"    (Miktrotik Config Basic)
- "$install mikrotik_advance"  (Miktrotik Config Advance)
- "$install hotspot_interface" (Miktrotik Config HotSpot Interface)
- "$install hotspot_advance"   (Miktrotik Config HotSpot Advance)
- "$install hotspot_server"    (Miktrotik Config HotSpot Server)

IMPORTANT NOTE!!!
- Port 1 => WAN
- Port 2 => PC/Laptop Winbox

How to install:
- Open file "start_here.txt"
- Provide the information needed
- Save this file after editing
- Drag and Drop all files to winbox terminal
- Execute the ff. on winbox terminal individually:
  - import init
  - $install mikrotik_basic
  - $install mikrotik_advance
  - $install hotspot_interface
  - $install hotspot_advance
  - $install hotspot_server

Needed Variable:
- ISPName    -> Internet Service Provider [Globe/Smart/PLDT/Starlink/etc].
- IPSubNet   -> IP subnet of LAN "192.168.x.0" & Hotspot "10.0.x.0".
- HSFolder   -> hotspot folder path: hex="flash/hotspot" haplite="hotspot".
- isTelegram -> enable telegram. 1 if you want to enable telegram.
- TGBotToken -> Bot API Token Telebot.
- TGrpChatID -> Group Chat ID Login.

Author:
- Chloe Renae & Edmar Lozada
- Gcash (0909-3887889)

Facebook Contact:
- https://www.facebook.com/chloe.renae.9
