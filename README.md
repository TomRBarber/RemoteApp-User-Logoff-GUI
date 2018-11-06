# RemoteApp-User-Logoff-GUI
Powershell GUI for logging user sessions off of remoteapp server.  Let's IT staff log users off of stuck remoteapp sessions, but they don't have to log into the server directly to do it

I wrote a script with a Powershell GUI that will allow IT staff to log users off of a remoteapp session(if it's locked up or whatever). it's fairly easy to do from powershell itself with get-rdusersession and invoke-rduserlogoff, but this gives it a nice little GUI that IT staff that are not so great at the commandline can use, and figure maybe some of you can use it.

Few things, they have to have the Remote Server Admin Tools from microsoft installed, and they have to be a local admin user on your RDBroker and RD Session Host servers(I believe. That's the only way I got it to work). I also used ps2exe-gui to convert it to an EXE file

The variable of $rdbroker has to be changed to your rdbroker server, and $domain to your domain name(so it will only show the session host server names and not the FQDN)


![Alt text](Remoteapp1.png?raw=true "Title")

![Alt text](Remoteapp2.png?raw=true "Title")
