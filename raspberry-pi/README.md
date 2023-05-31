## Configure Raspberry Pi
1. Install Raspberry Pi Manager
   1. Go to [Raspberrypi Software Page](https://www.raspberrypi.com/software/)
   2. Download and install Raspberry Pi Manager
<br><br>
   
2. Get SD Card
   1. Remove SD Card from device
   2. Insert into Card Reader
   3. Plugin Card Reader into the computer
<br><br>
   
3. Install Raspberry Pi OS into SD Card
   1. Open Raspberry Pi Manager
   2. Select **Operating System**
      1. Click on **CHOOSE OS** button under *Operating System*
      2. Click on **Raspberry Pi OS (Other)**
      3. Click on **Raspberry Pi OS Full (32-bit)**
   3. Select **Storage**
      1. Click on **CHOOSE STORAGE** button under *Storage*
      2. Select your SD Card (Check for Card Reader Name)
   4. Advance Settings
      1. Click on **Cogwheel** button to open *Advance Settings* window
      2. Configure settings as follows
         1. Image customization options: `for this session only`
         2. Set hostname: `dhanuiot.local`
         3. Enable SSH: `Use password authentication`
         4. Set username and password: `username: admin | password: admin123`
         5. Configure wireless LAN: `SSID: <router_name> | password: <router_password> | Wireless LAN country: NZ`
         6. Set locale settings: `Time zone: Pacific/Auckland | Keyboard layout: us`
         7. Check all settings user **Persistent settings**
      3. Click on **SAVE** button
   5. Click on **WRITE** button
<br><br>

4. Remove the SD Card from Card-Reader and Insert into Raspberry Pi Device
<br><br>

5. Plug the Raspberry Pi Device into electricity. You can use **Ubiquiti WiFiman** iPhone App to get the IP of the Raspberry Pi Device
<br><br>

6. Login to Raspberry Pi Device
   1. Open the Terminal on your computer
   2. Execute the following command to `SSH` into Raspberry Pi Device
      ```shell
      ssh dhanu@dhanuiot
      ```  
         