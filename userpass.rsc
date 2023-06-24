if ([/user find name=winbox_admin]="") do={
     /user  add name=winbox_admin  password=admin group=full }
/user set [find name=winbox_admin] password=admin group=full comment="Winbox User (Admins)" disabled=no
put "(Config) /user => name=[winbox_admin]"

/user set [find name=admin] password=admin
/user set [find name=admin] disabled=no
put "(Config) /user => name=[admin] disabled=[no]"
