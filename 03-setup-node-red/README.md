## Configure Node-Red Server on Raspberry Pi Device
Base resource is [Node-Red Documentation](https://nodered.org/docs/getting-started/raspberrypi).

Run the following commands on Raspberry Pi Device to install and configure Node-Red Server

1. **install** `Node-Red Server`
```bash
bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered)
```

2. **enable** the `Node-Red Server` to **start at boot**
```bash
sudo systemctl enable nodered.service
```

3. **disable the automatic start** of the `Node-Red Server`
```bash
sudo systemctl disable nodered.service
```

4. **stop the currently running** `Node-Red Server`
```bash
sudo systemctl stop nodered.service
```

5. **start** the `Node-Red Server`
```bash
sudo systemctl start nodered.service
```

6. Connect with Node-Red
    1. Open Browser on the Laptop
    2. Navigate to `http://dhanuiot:1880`