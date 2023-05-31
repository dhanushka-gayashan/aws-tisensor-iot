## Configure Ti Sensor to work with Node-Red
Base resource are
- [Node-Red-Node-Sensortag Documentation](https://flows.nodered.org/node/@ppatierno/node-red-node-sensortag).


1. Set-up the Ti Sensor
   1. Insert a battery into the Sensor
   2. You can see the green light is starting blinking
<br><br>

2. Check the Ti Sensor
   1. Install **TI Sensor Tag App** on your iPhone
   2. Select the `CC2650 Sensor` Tag Device from the **Available bluetooth device** list
   3. Connect and Check the Data
<br><br>

3. Install Sensor Node in Node-Red
   1. Install Bluetooth Driver
   ```shell
    sudo apt-get install libbluetooth-dev libudev-dev pi-bluetooth
    sudo setcap cap_net_raw+eip $(eval readlink -f `which node`)
   ```
   2. Install Node-Red Sensortag Node
   ```shell
    cd ~/.node-red/
    npm install @ppatierno/node-red-node-sensortag
   ```

4. Test the Sensor Data
   1. Add `sensorTag` node into **Flow**
   2. Add `debug` node into **Flow**
   3. Connect both nodes
   4. Check on the `Debug Console`
<br><br>

