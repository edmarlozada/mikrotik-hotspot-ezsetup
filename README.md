# mikrotik-hotspot-ezsetup v2.0
Beginners easy Hotspot setup/config script for your mikrotik with just simple commands. From mikrotik basic config to hospot setup.

Before you begin:
- Port 1 ( WAN )
- Port 2 ( PC/Laptop Winbox )
- reset mikrotik w/o default config

How to install:
- Edit file "0_start_here.rsc".
- Provide the needed information.
- Save this file after editing.
- Drag and Drop all files to winbox terminal.
- Execute each command on winbox terminal:
  - :import installer
  - $install config_wan
  - $install config_advance
  - $install hotspot_router
  - $install hotspot_advance
  - $install hotspot_server
  - $install hotspot_ether2
  - $install end
- or Install all in 3 command:
  - :import installer
  - $install hotspot
  - $install end

Provide the needed information:
- ISPName    [Globe/Smart/PLDT/Starlink/etc]
- IPSubNet   (IP subnet of LAN "192.168.x.0" & Hotspot "10.0.x.0")
- WinboxUser (winbox username)
- WinboxPass (winbox password)
- AdminUser  (admin username)
- AdminPass  (admin password)
- AdminOff   ["no"/"yes"]
- WiFiSSID   (mikrotik wifi SSID if available)
- WiFiPass   (mikrotik wifi password if available)

Author:
- Chloe Renae & Edmar Lozada
- Gcash (0909-3887889)

Facebook Contact:
- https://www.facebook.com/chloe.renae.9

Facebook JuanFi Group:
- https://www.facebook.com/groups/1172413279934139
