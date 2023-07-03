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
5. Execute each commands on winbox terminal
6. To reset mikrotik no config: (optional)
   - :import installer
   - $reset config
7. To setup mikrotik as hotspot:
   - :import installer
   - $install default_isp
   - $install default_advance
   - $install hotspot_router
   - $install hotspot_advance
   - $install hotspot_server
   - $install hotspot_ether2
   - $install end
8. or Execute all in 3 commands:
   - :import installer
   - $install hotspot
   - $install end
9. Reboot mikrotik!

Provide the needed information:
- ISPName    = ISP Name [Globe/Smart/PLDT/Starlink/etc]
- IPSubNet   = IP subnet of LAN (192.168.?.0" & Hotspot "10.0.?.0)
- WinboxUser = winbox username (default "winbox_admin")
- WinboxPass = winbox password (default "admin")
- AdminUser  = admin username (default "admin")
- AdminPass  = admin password (default "admin")
- AdminOff   = disable admin ["NO"/"yes"]
- WiFiSSID   = mikrotik wifi SSID if available (default "SecureWiFi")
- WiFiPass   = mikrotik wifi password if available (default "securewifi"

NOTE:
  1. name: winbox_admin / password: admin
  2. name: admin / password: admin 

Author:
- Chloe Renae & Edmar Lozada
- Gcash (0909-3887889)

Facebook Contact:
- https://www.facebook.com/chloe.renae.9

Facebook JuanFi Group:
- https://www.facebook.com/groups/1172413279934139
