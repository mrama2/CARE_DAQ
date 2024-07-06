#include <WiFi.h>
#include <WiFiMulti.h>

#define MAX_CHANNELS  (6)
#define ADC_12_CH     (2)
#define ADC_10_CH     (4)
#define ADC_7_CH      (35)
#define ADC_6_CH      (34)
#define ADC_0_CH      (36)
#define ADC_3_CH      (39)


const char *ssid = "oneplus";  // Update with your WiFi credentials
const char *password = "MRama@eff1234";
const uint16_t serverPort = 8080;
uint8_t channel;
volatile uint8_t adc_sample_start =0;
uint8_t packet[750];
uint8_t client_connected=0;
uint16_t analogValue;
WiFiMulti WiFiMulti;
WiFiServer server(serverPort);
hw_timer_t * timer = NULL;
uint32_t adc_bytes =0;

volatile uint32_t isrCounter = 0;
volatile uint32_t lastIsrAt = 0;

void ARDUINO_ISR_ATTR onTimer(){
  if(client_connected == 1)
  {
    adc_sample_start =1;
  }
}



void setup() {
       Serial.begin(115200);
       //set the resolution to 12 bits (0-4096)
       analogReadResolution(12);
    WiFiMulti.addAP(ssid, password);
    while (WiFiMulti.run() != WL_CONNECTED) {
        delay(1000);
    }

    server.begin();
    Serial.println("Server started");
    Serial.println(WiFi.localIP());


    //Timer
    // Use 1st timer of 4 (counted from zero).
  // Set 80 divider for prescaler (see ESP32 Technical Reference Manual for more
  // info).
  timer = timerBegin(0, 80, true);

  // Attach onTimer function to our timer.
  timerAttachInterrupt(timer, &onTimer, true);

  // Set alarm to call onTimer function every millsecond (value in microseconds).
  // Repeat the alarm (third parameter)
  timerAlarmWrite(timer, 5000, true);

  // Start an alarm
  timerAlarmEnable(timer);

}

void loop() 
{
  WiFiClient client = server.available();
  if (client) 
  {
    Serial.println("New client connected");
    client.println("Hello from TCP Server");
    while (client.connected()) 
    {
      client_connected = 1;
      // Frame the packet
      if(adc_sample_start == 1)
      {
        adc_sample_start = 0;
        // Serial.println(adc_bytes);
         // Serial.println(( adc_bytes < 600));
        if( adc_bytes < 600)
        {
          analogValue = analogRead(ADC_12_CH);
          packet[adc_bytes] = analogValue & 0xFF;
          packet[adc_bytes+1] = (analogValue >> 8) & 0xFF;
          analogValue = analogRead(ADC_10_CH);
          packet[adc_bytes+2] = analogValue & 0xFF;
          packet[adc_bytes+3] = (analogValue >> 8) & 0xFF;
          analogValue = analogRead(ADC_7_CH);
          packet[adc_bytes+4] = analogValue & 0xFF;
          packet[adc_bytes+5] = (analogValue >> 8) & 0xFF;
          analogValue = analogRead(ADC_6_CH);
          packet[adc_bytes+6] = analogValue & 0xFF;
          packet[adc_bytes+7] = (analogValue >> 8) & 0xFF;
          analogValue = analogRead(ADC_0_CH);
          packet[adc_bytes+8] = analogValue & 0xFF;
          packet[adc_bytes+9] = (analogValue >> 8) & 0xFF;
          analogValue = analogRead(ADC_3_CH);
          packet[adc_bytes+10] = analogValue & 0xFF;
          packet[adc_bytes+11] = (analogValue >> 8) & 0xFF;
          adc_bytes=adc_bytes+12;
        }
        if( adc_bytes == 600)
        {
          client.write(packet, 600);
          client.flush();
          adc_bytes=0;
          Serial.println("Client.write");
          Serial.println(adc_bytes);
          
        }
      }
      if (client.available()) 
      {
        String request = client.readStringUntil('\r');
        Serial.println(request);
        // Process client request here and send response
        client.println("HTTP/1.1 200 OK");
        client.println("Content-Type: text/plain");
        client.println();
        client.println("Response from TCP Server");
        break;  // Exit the loop after handling one request
      }
    }
    client.stop();
    client_connected = 0;
    adc_bytes =0;
    adc_sample_start = 0;
    Serial.println("Client disconnected");
  }
}
