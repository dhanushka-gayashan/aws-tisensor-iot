## Configure Node-Red Server on Raspberry Pi Device
Base resource is [Node-Red Documentation](https://nodered.org/docs/getting-started/raspberrypi).

Run the following commands on Raspberry Pi Device to install and configure Node-Red Server

1. **install** `Node-Red Server`
```shell
bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered)
```

2. Run As a **Linux Service**
   1**enable** the `Node-Red Server` to **start at boot**
   ```shell
   sudo systemctl enable nodered.service
   ```

   2**disable the automatic start** of the `Node-Red Server`
   ```shell
   sudo systemctl disable nodered.service
   ```

   3**stop the currently running** `Node-Red Server`
   ```shell
   sudo systemctl stop nodered.service
   ```

   4**start** the `Node-Red Server`
   ```shell
   sudo systemctl start nodered.service
   ```
   
3. Run manually (Debug Purpose)
   1. **Start** Service
   ```shell
   node-red-start
   ```

   2. **Stop** Service
   ```shell
   node-red-stop
   ```
   
   3. **Restart** Service
   ```shell
   node-red-restart
   ```
   
   4. **Display Logs** of the Service
   ```shell
   node-red-log
   ```

4. Connect with Node-Red UI
    1. Open Browser on the Laptop
    2. Navigate to `http://dhanuiot:1880`