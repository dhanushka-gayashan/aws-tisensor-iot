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
if (msg.topic === "sensorTag/pressure") {
    return { 
        payload: {
            timestamp: new Date(),
            type: "pressure",
            data: msg.payload
        }
    };
} else if (msg.topic === "sensorTag/accelerometer"){
    return {
        payload: {
            timestamp: new Date(),
            type: "accelerometer",
            data: msg.payload
        }
    };
} else if (msg.topic === "sensorTag/gyroscope") {
    return {
        payload: {
            timestamp: new Date(),
            type: "gyroscope",
            data: msg.payload
        }
    };
} else if (msg.topic === "sensorTag/magnetometer") {
    return {
        payload: {
            timestamp: new Date(),
            type: "magnetometer",
            data: msg.payload
        }
    };
} else if (msg.topic === "fsensorTag/humidity") {
    return {
        payload: {
            timestamp: new Date(),
            type: "humidity",
            data: msg.payload
        }
    };
};
```

### Configure `mqttOut` Node
- Configure `Add new mqtt-broker`

![MQTT](./pics/05-01-mqttout.png)

- Configure `AWS IOT Core` details

![MQTT](./pics/05-02-mqttout.png)

- Configure `Certificates` (Generated via Terraform)

![MQTT](./pics/05-03-mqttout.png)

### **DEPLOY** and **TEST** 
- Click on **Deploy** Button
<br><br>

- `TEST`: Enable ***Debug* Node and check on **Debug Console**
  <br><br>

- `AWS TEST`
  1. Click on **MQTT test client**
  2. **Subscribe** to the **MQTT TOPIC**
  
  ![TEST](./pics/06-01-test.png)  

  ![TEST](./pics/06-02-test.png) 

    


