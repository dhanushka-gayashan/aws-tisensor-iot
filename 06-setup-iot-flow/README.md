## Configure the IOT Flow on Node-Red 

### Component Diagram

![Component Diagram](./pics/01-Component-Diagram.png)


### Configure `sensorTag` Node
![Sensor Tag](./pics/02-sensorTag.png)


### Configure `debug` Node
![Debug](./pics/03-debug.png)


### Configure `function` Node
![Function](./pics/04-function.png)

```js
var data = {
  timestamp: new Date(),
  location: "office",
  device_label: "tisensor",
  pressure: 0,
  accelerometer: {},
  gyroscope: {},
  magnetometer: {},
  temperature: 0.0,
  humidity: 0.0
}

if (msg.topic === "sensorTag/pressure") {
  data.pressure = msg.payload.pressure
} else if (msg.topic === "sensorTag/accelerometer"){
  data.accelerometer = msg.payload
} else if (msg.topic === "sensorTag/gyroscope") {
  data.gyroscope = msg.payload
} else if (msg.topic === "sensorTag/magnetometer") {
  data.magnetometer = msg.payload
} else if (msg.topic === "sensorTag/humidity") {
  data.temperature = msg.payload.temperature
  data.humidity = msg.payload.humidity
};

return { payload: data };
```

### Configure `mqttOut` Node
- Configure `Add new mqtt-broker`

![MQTT](./pics/05-01-mqttout.png)

- Configure `AWS IOT Core` details (AWS IOT Core Broker URL is available at terraform output)

![MQTT](./pics/05-02-mqttout.png)

- Configure `Certificates` (Generated via Terraform and available at 05-setup-aws/certs)

![MQTT](./pics/05-03-mqttout.png)

### ***DEPLOY*** and ***TEST***
- Click on ***Deploy*** Button
<br><br>

- `TEST`: Enable ***Debug*** Node and check on ***Debug Console***
  <br><br>

- `AWS TEST`
  1. Click on ***MQTT test client***
  2. ***Subscribe*** to the ***MQTT TOPIC***
  
  ![TEST](./pics/06-01-test.png)  

  ![TEST](./pics/06-02-test.png) 

    


