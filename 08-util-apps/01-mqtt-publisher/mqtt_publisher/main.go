package main

import (
	"crypto/tls"
	"crypto/x509"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"math/rand"
	"os"
	"os/signal"
	"syscall"
	"time"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

type SensorData struct {
	Timestamp     string             `json:"timestamp"`
	DeviceLabel   string             `json:"device_label"`
	Location      string             `json:"location"`
	Pressure      int32              `json:"pressure"`
	Accelerometer map[string]float32 `json:"accelerometer"`
	Gyroscope     map[string]float32 `json:"gyroscope"`
	Magnetometer  map[string]float32 `json:"magnetometer"`
	Temperature   float32            `json:"temperature"`
	Humidity      float32            `json:"humidity"`
}

var source = rand.NewSource(time.Now().UnixNano())

func generatePressure(client mqtt.Client, dataCh chan<- SensorData) {
	for {
		//time.Sleep(500 * time.Millisecond)

		random := rand.New(source)
		min := int32(900)
		max := int32(1200)

		sensorData := SensorData{
			Timestamp:     time.Now().UTC().Format(time.RFC3339),
			DeviceLabel:   "tisensor",
			Location:      "office",
			Pressure:      random.Int31n(max-min+1) + min,
			Accelerometer: make(map[string]float32),
			Gyroscope:     make(map[string]float32),
			Magnetometer:  make(map[string]float32),
		}
		dataCh <- sensorData

		dataJSON, err := json.Marshal(sensorData)
		if err != nil {
			fmt.Println("Error in marshalling data: ", err)
			continue
		}

		token := client.Publish("aws/sensorTag", 0, false, dataJSON)
		token.Wait()
	}
}

func generateAccelerometer(client mqtt.Client, dataCh chan<- SensorData) {
	for {
		//time.Sleep(500 * time.Millisecond)

		random := rand.New(source)
		min := float32(-1)
		max := float32(5)

		accelerometerData := map[string]float32{
			"x": random.Float32()*(max-min) + min, // generates a random x value between -1 and 5
			"y": random.Float32()*(max-min) + min, // generates a random y value between -1 and 5
			"z": random.Float32()*(max-min) + min, // generates a random z value between -1 and 5
		}

		sensorData := SensorData{
			Timestamp:     time.Now().UTC().Format(time.RFC3339),
			DeviceLabel:   "tisensor",
			Location:      "office",
			Accelerometer: accelerometerData,
			Gyroscope:     make(map[string]float32),
			Magnetometer:  make(map[string]float32),
		}
		dataCh <- sensorData

		dataJSON, err := json.Marshal(sensorData)
		if err != nil {
			fmt.Println("Error in marshalling data: ", err)
			continue
		}

		token := client.Publish("aws/sensorTag", 0, false, dataJSON)
		token.Wait()
	}
}

func generateGyroscope(client mqtt.Client, dataCh chan<- SensorData) {
	for {
		//time.Sleep(500 * time.Millisecond)

		random := rand.New(source)
		min := float32(-1)
		max := float32(2)

		gyroscopeData := map[string]float32{
			"x": random.Float32()*(max-min) + min, // generates a random x value between -1 and 2
			"y": random.Float32()*(max-min) + min, // generates a random y value between -1 and 2
			"z": random.Float32()*(max-min) + min, // generates a random z value between -1 and 2
		}

		sensorData := SensorData{
			Timestamp:     time.Now().UTC().Format(time.RFC3339),
			DeviceLabel:   "tisensor",
			Location:      "office",
			Accelerometer: make(map[string]float32),
			Gyroscope:     gyroscopeData,
			Magnetometer:  make(map[string]float32),
		}
		dataCh <- sensorData

		dataJSON, err := json.Marshal(sensorData)
		if err != nil {
			fmt.Println("Error in marshalling data: ", err)
			continue
		}

		token := client.Publish("aws/sensorTag", 0, false, dataJSON)
		token.Wait()
	}
}

func generateMagnetometer(client mqtt.Client, dataCh chan<- SensorData) {
	for {
		//time.Sleep(500 * time.Millisecond)

		random := rand.New(source)
		min := float32(-200)
		max := float32(250)

		magnetometerData := map[string]float32{
			"x": random.Float32()*(max-min) + min, // generates a random x value between -200 and 250
			"y": random.Float32()*(max-min) + min, // generates a random y value between -200 and 250
			"z": random.Float32()*(max-min) + min, // generates a random z value between -200 and 250
		}

		sensorData := SensorData{
			Timestamp:     time.Now().UTC().Format(time.RFC3339),
			DeviceLabel:   "tisensor",
			Location:      "office",
			Accelerometer: make(map[string]float32),
			Gyroscope:     make(map[string]float32),
			Magnetometer:  magnetometerData,
		}
		dataCh <- sensorData

		dataJSON, err := json.Marshal(sensorData)
		if err != nil {
			fmt.Println("Error in marshalling data: ", err)
			continue
		}

		token := client.Publish("aws/sensorTag", 0, false, dataJSON)
		token.Wait()
	}
}

func generateTemperatureAndHumidity(client mqtt.Client, dataCh chan<- SensorData) {
	for {
		//time.Sleep(500 * time.Millisecond)

		randomTemp := rand.New(source)
		minTemp := float32(15)
		maxTemp := float32(30)

		randomHume := rand.New(source)
		minHume := float32(30)
		maxHume := float32(100)

		sensorData := SensorData{
			Timestamp:     time.Now().UTC().Format(time.RFC3339),
			DeviceLabel:   "tisensor",
			Location:      "office",
			Accelerometer: make(map[string]float32),
			Gyroscope:     make(map[string]float32),
			Magnetometer:  make(map[string]float32),
			Temperature:   randomTemp.Float32()*(maxTemp-minTemp) + minTemp, // generates a random temperature between 15 and 30
			Humidity:      randomHume.Float32()*(maxHume-minHume) + minHume, // generates a random humidity between 0 and 100

		}
		dataCh <- sensorData

		dataJSON, err := json.Marshal(sensorData)
		if err != nil {
			fmt.Println("Error in marshalling data: ", err)
			continue
		}

		token := client.Publish("aws/sensorTag", 0, false, dataJSON)
		token.Wait()
	}
}

func main() {
	certpool := x509.NewCertPool()
	pemCerts, err := ioutil.ReadFile("certs/AmazonRootCA1.pem")
	if err == nil {
		certpool.AppendCertsFromPEM(pemCerts)
	}

	cert, err := tls.LoadX509KeyPair("certs/certificate.pem.crt", "certs/private.pem.key")
	if err != nil {
		log.Fatalf("Error loading key pair: %v", err)
	}

	tlsConfig := &tls.Config{
		RootCAs:            certpool,
		ClientAuth:         tls.NoClientCert,
		Certificates:       []tls.Certificate{cert},
		InsecureSkipVerify: true,
	}

	opts := mqtt.NewClientOptions()
	opts.AddBroker("ssl://a1qtjfotey6b2s-ats.iot.us-east-1.amazonaws.com:8883")
	opts.SetClientID("sensor_publisher")
	opts.SetTLSConfig(tlsConfig)

	client := mqtt.NewClient(opts)
	if token := client.Connect(); token.Wait() && token.Error() != nil {
		panic(token.Error())
	}

	dataCh := make(chan SensorData)
	go func() {
		for data := range dataCh {
			fmt.Printf("%+v\n", data)
		}
	}()

	go generatePressure(client, dataCh)
	go generateAccelerometer(client, dataCh)
	go generateGyroscope(client, dataCh)
	go generateMagnetometer(client, dataCh)
	go generateTemperatureAndHumidity(client, dataCh)

	// Keep the program running until interrupted
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGTERM)
	<-sigCh
}
