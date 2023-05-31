## Configure VNC Server on Raspberry Pi Device
Run the following commands on Raspberry Pi Device to install and configure VNC Server

1. **install** `vncserver`
```bash
sudo apt-get install realvnc-vnc-server
```

2. enable the VNC server to **start at boot**
```bash
sudo systemctl enable vncserver-x11-serviced.service
```

3. **disable the automatic start** of the VNC server
```bash
sudo systemctl disable vncserver-x11-serviced.service
```

4. **stop the currently running** VNC server
```bash
sudo systemctl stop vncserver-x11-serviced.service
```

5. **start** the VNC server
```bash
sudo systemctl start vncserver-x11-serviced.service
```

6. Connect with Raspberry Pi OS Desktop
   1. **Install** and **Open** `VNC VIEWER` application on your computer
   2. Use `dhanuiot:5900` to connect