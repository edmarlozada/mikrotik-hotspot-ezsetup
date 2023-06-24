# mikrotik-hotspot-ezsetup v6.0
Beginners easy Hotspot setup/config script for your mikrotik with just simple commands. From mikrotik basic config to hospot setup.

Before you begin:
- Port 1 ( WAN )
- Port 2 ( PC/Laptop Winbox )
- reset mikrotik w/o default config

How to install:
1. Edit file "config.txt".
2. Provide the needed information.
3. Save this file after editing.
4. Drag and Drop all files to winbox.
5. Execute each command on winbox terminal:
   - :import installer
   - $install default_isp
   - $install default_advance
   - $install hotspot_router
   - $install hotspot_advance
   - $install hotspot_server
   - $install hotspot_ether2
   - $install end
   or Install all in 3 command:
   - :import installer
   - $install hotspot
   - $install end
6. Reset Mikrotik no config: (optional)
   name: admin / password: admin
   - :import installer
   - $reset config
7. Reboot mikrotik!

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
