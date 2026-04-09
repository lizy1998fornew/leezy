//Micromag Large Scale System (LSS) Rotor side code for 4-coil "pyramid" configuration
//BLE is set to actively fetch and connect with a preset service
//LSS Rotor provides attitute control for microrobot, while Mover provides position control
//Configs are applied for different rotation patterns
//Note that because of the inclusion of CV, Y axis direction is inverted and now points downwards

#include <BasicLinearAlgebra.h>
#include <ElementStorage.h>
#include <Adafruit_MCP4728.h>
#include <Wire.h>
#include <HardwareSerial.h>
// #include <BLEDevice.h>

using namespace BLA;

#if ARDUINO_USB_CDC_ON_BOOT
#define UART0 Serial0
#else
#define UART0 Serial
#endif

Adafruit_MCP4728 mcp;

int C1Dir = 4;
int C2Dir = 5;
int C3Dir = 6;
int C4Dir = 7;
int OUTEN = 10;

//UART key variables
String uart_buffer = "";     
const uint32_t communicationTimeout_ms = 10;
SemaphoreHandle_t uart_buffer_Mutex = NULL;

// //BLE functional definitions
// uint8_t ble_buffer[4];
// static BLEUUID serviceUUID("0000FFF0-0000-1000-8000-00805F9B34FB");//Taret device UUID
// static BLEUUID charUUID("0000FFF1-0000-1000-8000-00805F9B34FB");//Target characteristic UUID
// static boolean doConnect = false;
// static boolean connected = false;
// static boolean doScan = false;
// static BLERemoteCharacteristic *pRemoteCharacteristic;
// static BLEAdvertisedDevice *myDevice;

//X and Y axis planar velocity input
float Vx = 0;
float Vy = 0;

//Spherical coordinate input
float AlignPolar = 0;
float AlignAzimuth = 0;
float SwingAngleDeg = 30.0;

//Movement control key variables
float StepTracker = 0;
int PauseFlicker = 0;
float StepLength = 0;

float CurrentPos_XYZ[3] = {0,0,1};

int AlignTriggered = 0;
int AlignCounter = 0;
int OpMode = 0; //Nav Mode: tumbling, spiral 45, spiral 90, spiral 135, swing
int SpeedMode = 0; //Speed Mode: MaxStepLength = (SpeedMode+1 = 1~16) * MaxStepModif deg

//Matrix solver key variables
BLA::Matrix<3,3,float> I = {1,0,0, //Identity matrix
                            0,1,0,
                            0,0,1};

BLA::Matrix<3,1,float> SPos; //Starting position
BLA::Matrix<3,1,float> RA;   //Rotational axis
BLA::Matrix<3,3,float> R;    //R matrix of RRF 
BLA::Matrix<3,3,float> k1;   //k^ matrix of RRF
BLA::Matrix<1,3,float> kt;   //Transposition of k as required by RRF
BLA::Matrix<3,1,float> VRot; //Result after turn
BLA::Matrix<4,3,float> TM = {-sqrt(3)/4,-sqrt(3)/4, sqrt(3)/4, //Transfer matrix Vector->Coil
                              sqrt(3)/4,-sqrt(3)/4, sqrt(3)/4, //It should be noted that LSS coil definition is different
                              sqrt(3)/4, sqrt(3)/4, sqrt(3)/4, //in that Coil #1 in LSS is equivalent of Coil #3 in 8-pointed
                             -sqrt(3)/4, sqrt(3)/4, sqrt(3)/4};//small system configuration
BLA::Matrix<3,1,float> OVector = {0, 0, 0};
BLA::Matrix<4,1,float> OCoil = {0, 0, 0, 0};

//Temp variables for calculation
float CartOutput[3] = {0,0,0};

//System Configuration Parameters
float MaxStepModif = 1.08; //MaxStepLength = (SpeedMode+1 = 1~16) * MaxStepModif deg
                           //1.08 is calibrated so that 1 SpeedMode = 0.5 rps real speed

float VxDir[] = {-1,-1,-1,-1,-1}; //Determines how Vx and Vy is introduced into the RRF calculator
float VyDir[] = {-1, 1, 1, 1, 1};

int AlignCount = 10; //Determines how many steps should be full power after each manual att command

//LSS does not require on-board AMP overheat safety
// float AMPSafetyLimit = 1.5;

//UART0 RX interrupt callback
void UART0_RX_CB()
{
  // take the mutex, waits forever until loop() finishes its processing
  if (xSemaphoreTake(uart_buffer_Mutex, portMAX_DELAY)) {
    uint32_t now = millis();  // tracks timeout
    while ((millis() - now) < communicationTimeout_ms) {
      if (UART0.available()) {
        uart_buffer += (char)UART0.read();
        now = millis();  // reset the timer
      }
    }
    // releases the mutex for data processing
    xSemaphoreGive(uart_buffer_Mutex);
  }
  //Input data dealer is set to process the data immediately
  if (uart_buffer.length() > 0) {
    // signals that the onReceive function shall not change uart_buffer while processing
    if (xSemaphoreTake(uart_buffer_Mutex, portMAX_DELAY)) {
      //Process data in buffer
      //Data from upper contains 2*16bit Vx and Vy
      // UART0.println(uart_buffer);
      while(uart_buffer.length() >= 4)
      {
        uint8_t U_VxD1 = static_cast<uint8_t>(uart_buffer[0]);
        uint8_t U_VxD2 = static_cast<uint8_t>(uart_buffer[1]);
        uint8_t U_VyD1 = static_cast<uint8_t>(uart_buffer[2]);
        uint8_t U_VyD2 = static_cast<uint8_t>(uart_buffer[3]);
        uart_buffer.remove(0,4);

        int U_Type1 = (U_VxD1 & 0xF0)>>4;
        int U_Type2 = (U_VyD1 & 0xF0)>>4;

        int U_VxD = ((U_VxD1 & 0x0F)<<8) + U_VxD2;
        int U_VyD = ((U_VyD1 & 0x0F)<<8) + U_VyD2;
        
        //ExxxExxx: swing-angle configuration packet
        if(U_Type1 == 14 && U_Type2 == 14)
        {
            SwingAngleDeg = (U_VxD/4095.0)*90.0;
        }
        //FxxxFxxx: 3D manual attitude control
        //D1 & D2 sets polar angle, D3 & D4 sets azimuth angle
        else if(U_Type1 == 15 && U_Type2 == 15)
        {
            AlignPolar = (U_VxD/4095.0)*180.0;
            AlignAzimuth = (U_VyD/4095.0)*360.0;
            Sph2Cart(AlignPolar, AlignAzimuth);
            CurrentPos_XYZ[0] = CartOutput[0];
            CurrentPos_XYZ[1] = CartOutput[1];
            CurrentPos_XYZ[2] = CartOutput[2];
            AlignTriggered = 1;
            AlignCounter = 0;
        }
      
        //Other: different modes of auto control, Type1 sets mode
        //D1 & D2 sets Vx, D3&D4 sets Vy
        else
        {          
          OpMode = U_Type1;
          SpeedMode = U_Type2;
          Vx = (U_VxD-2047)/2047.0;
          Vy = (U_VyD-2047)/2047.0;
        }
      }
      uart_buffer = "";
      xSemaphoreGive(uart_buffer_Mutex);
    }
  }

}

// //BLE notify callback = RX callback  
// static void notifyCallback(BLERemoteCharacteristic *pBLERemoteCharacteristic, uint8_t *pData, size_t blelength, bool isNotify)
// {  
//   // if(blelength == 4)
//   // {
//     memcpy(ble_buffer,pData,blelength);
//     int B_VxD1 = ble_buffer[0];
//     int B_VxD2 = ble_buffer[1];
//     int B_VyD1 = ble_buffer[2];
//     int B_VyD2 = ble_buffer[3];

//     int B_Type1 = (B_VxD1 & 0xF0)>>4;
//     int B_Type2 = (B_VyD1 & 0xF0)>>4;

//     B_VxD1 = (B_VxD1 & 0xF)<<8;
//     B_VyD1 = (B_VyD1 & 0xF)<<8;
//     int B_VxD = B_VxD1+B_VxD2;
//     int B_VyD = B_VyD1+B_VyD2;

//     //FxxxFxxx: 3D manual attitute control
//     //D1 & D2 sets polar angle, D3 & D4 sets azimuth angle
//     if(B_Type1 == 15 && B_Type2 == 15)
//     {
//         AlignPolar = (B_VxD/4095)*180;
//         AlignAzimuth = (B_VyD/4095)*360;
//         Sph2Cart(AlignPolar, AlignAzimuth);
//         CurrentPos_XYZ[0] = CartOutput[0];
//         CurrentPos_XYZ[1] = CartOutput[1];
//         CurrentPos_XYZ[2] = CartOutput[2];
//         AlignTriggered = 1;
//     }
    
//     //Other: different modes of auto control, Type1 sets mode
//     //D1 & D2 sets Vx, D3 & D4 sets Vy
//     else
//     {
//       OpMode = B_Type1;
//       Vx = B_VxD-2047;
//       Vy = B_VyD-2047;
//       Vx = Vx/2047;
//       Vy = Vy/2047;
//     }    
//     // UART0.println(B_VxD1+B_VxD2);
//     // UART0.println(B_VyD1+B_VyD2);
//     // UART0.println(Vx);
//     // UART0.println(Vy);
//     // UART0.println(NextStimAmp);
//     // UART0.println(NextStimTime);
//   // }      
//   ble_buffer[0] = 0;
//   ble_buffer[1] = 0;
//   ble_buffer[2] = 0;
//   ble_buffer[3] = 0;
// }

// //Other BLE functions
// class MyClientCallback : public BLEClientCallbacks 
// {
//   void onConnect(BLEClient *pclient) {}

//   void onDisconnect(BLEClient *pclient) {
//     connected = false;
//     UART0.println("!Disconnected");
//     ESP.restart();//Reboot on BLE disconnection in attempt to reconnect
//   }
// };

// bool connectToServer()
// {
//   UART0.print("Target server: ");
//   UART0.println(myDevice->getAddress().toString().c_str());

//   BLEClient *pClient = BLEDevice::createClient();
//   UART0.println("BLE Client created");

//   pClient->setClientCallbacks(new MyClientCallback());

//   // Connect to the remove BLE Server
//   pClient->connect(myDevice);  // if you pass BLEAdvertisedDevice instead of address, it will be recognized type of peer device address (public or private)
//   UART0.println("Connected to server");
//   pClient->setMTU(517);  //set client to request maximum MTU from server (default is 23 otherwise)

//   // Obtain a reference to the service we are after in the remote BLE server.
//   BLERemoteService *pRemoteService = pClient->getService(serviceUUID);
//   if (pRemoteService == nullptr) 
//   {
//     UART0.print("Failed to find service UUID: ");
//     UART0.println(serviceUUID.toString().c_str());
//     pClient->disconnect();
//     return false;
//   }
//   UART0.println("Target service found");

//   // Obtain a reference to the characteristic in the service of the remote BLE server.
//   pRemoteCharacteristic = pRemoteService->getCharacteristic(charUUID);
//   if (pRemoteCharacteristic == nullptr) 
//   {
//     UART0.print("Failed to find characteristic UUID: ");
//     UART0.println(charUUID.toString().c_str());
//     pClient->disconnect();
//     return false;
//   }
//   UART0.println("Target characteristic found");

//   if (pRemoteCharacteristic->canNotify()) 
//   {
//     pRemoteCharacteristic->registerForNotify(notifyCallback);
//   }

//   connected = true;
//   return true;
// }
// //Scan for BLE servers and find the first one that advertises the target service
// class MyAdvertisedDeviceCallbacks : public BLEAdvertisedDeviceCallbacks 
// {
//   //This is called for each advertising BLE server
//   void onResult(BLEAdvertisedDevice advertisedDevice) 
//   {
//     UART0.print("BLE Advertised Device found: ");
//     UART0.println(advertisedDevice.toString().c_str());

//     // Check if found device contains the target service
//     if (advertisedDevice.haveServiceUUID() && advertisedDevice.isAdvertisingService(serviceUUID)) {

//       BLEDevice::getScan()->stop();
//       myDevice = new BLEAdvertisedDevice(advertisedDevice);
//       doConnect = true;
//       doScan = true;

//     } 
//   }
// };
// //End of BLE-related functions

//Other operational functions

void setup() {  
    //Initialize UART0 for serial interrupt
  UART0.begin(115200);
  uart_buffer_Mutex = xSemaphoreCreateMutex();// creates a mutex object to control access to uart_buffer
  if (uart_buffer_Mutex == NULL) {
    log_e("Error creating Mutex. Sketch will fail.");
    while (true) {
      UART0.println("Mutex error (NULL). Program halted.");
      ESP.restart();//Attempt to fix init failure by rebooting  
    }
  }
  UART0.onReceive(UART0_RX_CB);  // sets the callback function
    
  // //Initialize BLE and connect to server
  // UART0.println("Starting BLE Client");
  // BLEDevice::init("");

  // // Retrieve a Scanner and set the callback we want to use to be informed when we
  // // have detected a new device.  Specify that we want active scanning and start the
  // // scan to run for 5 seconds.
  // BLEScan *pBLEScan = BLEDevice::getScan();
  // pBLEScan->setAdvertisedDeviceCallbacks(new MyAdvertisedDeviceCallbacks());
  // pBLEScan->setInterval(1349);
  // pBLEScan->setWindow(449);
  // pBLEScan->setActiveScan(true);
  // pBLEScan->start(5, false);

  // if (doConnect == true) {
  //   if (connectToServer()) {
  //     UART0.println("Establish connection SUCCESS");
  //   } else {
  //     UART0.println("Establish connection FAILED");
  //   }
  //   doConnect = false;
  // }
  
  //Initialize variables
  OVector.Fill(0);
  OCoil.Fill(0);

  //Initialize hardwares
  Wire.begin(18,19);
  mcp.begin();

  pinMode(C1Dir, OUTPUT);//FSA2276 Switch: High = P->N ; Low = N->P
  pinMode(C2Dir, OUTPUT);
  pinMode(C3Dir, OUTPUT);
  pinMode(C4Dir, OUTPUT);
  pinMode(OUTEN, OUTPUT);//FSA2276 Mute: High = Output OFF  

  mcp.setChannelValue(MCP4728_CHANNEL_A, 0);//0 = 0V, 2482 = +2V
  mcp.setChannelValue(MCP4728_CHANNEL_B, 0);
  mcp.setChannelValue(MCP4728_CHANNEL_C, 0);
  mcp.setChannelValue(MCP4728_CHANNEL_D, 0);

  rgbLedWrite(RGB_BUILTIN, 32, 0, 0);

  UART0.println(TM);

}

void loop() {

  if(Vx==0 && Vy==0)//When output velocity is 0, device enters low output position maintain mode
    {
      if(AlignTriggered == 1) //Manual attitute align
      {
        rgbLedWrite(RGB_BUILTIN, 0, 32, 0);
        if(AlignCounter < AlignCount)
        {
          Align2Pos(CurrentPos_XYZ[0],CurrentPos_XYZ[1],CurrentPos_XYZ[2],1.0);
          AlignCounter = AlignCounter+1;
        }
        else
        {
          AlignTriggered = 0;
          AlignCounter = 0;
        }
      }
      else //Low power standby
      {
        rgbLedWrite(RGB_BUILTIN, 32, 0, 0);
        Align2Pos(CurrentPos_XYZ[0],CurrentPos_XYZ[1],CurrentPos_XYZ[2],0.15);
      }      
    }
  else //Auto control
    {
      rgbLedWrite(RGB_BUILTIN, 0, 32, 0);
      PauseFlicker = 0;
      StepLength = sqrt(Vx*Vx+Vy*Vy)*MaxStepModif*(SpeedMode+1);
      
      StepTracker = StepTracker+StepLength;
      if(StepTracker>=360)
      {
        StepTracker = StepTracker-360;
      }
      float NormalizeFactor = sqrt(Vx*Vx+Vy*Vy);
      float Vx_N = (Vx/NormalizeFactor)*VxDir[OpMode];
      float Vy_N = (Vy/NormalizeFactor)*VyDir[OpMode];

      if(OpMode == 0) //Mode 0: Tumbling
      {
        RRF(0,0,1,Vy_N,Vx_N,0,StepTracker);
      }
      else if(OpMode == 1) //Mode 1: Spiral 45
      {
        float SPx = Vx_N/sqrt(2);
        float SPy = Vy_N/sqrt(2);
        float SPz = 1/sqrt(2);
        RRF(SPx,SPy,SPz,Vx_N,Vy_N,0,StepTracker);
      }
      else if(OpMode == 2) //Mode 2: Spiral 90
      {
        RRF(0,0,1,Vx_N,Vy_N,0,StepTracker);
      }
      else if(OpMode == 3) //Mode 3: Spiral 135
      {
        float SPx = -Vx_N/sqrt(2);
        float SPy = -Vy_N/sqrt(2);
        float SPz = 1/sqrt(2);
        RRF(SPx,SPy,SPz,Vx_N,Vy_N,0,StepTracker);
      }
      else //Mode 4: Swing
      {
        float SwingPhase = sin(Deg2Rad(StepTracker));
        float SwingRad = Deg2Rad(SwingAngleDeg*SwingPhase);
        VRot(0) = sin(SwingRad)*Vx_N;
        VRot(1) = sin(SwingRad)*Vy_N;
        VRot(2) = cos(SwingRad);
      }
        
      Align2Pos(VRot(0),VRot(1),VRot(2),1);
      CurrentPos_XYZ[0] = VRot(0);
      CurrentPos_XYZ[1] = VRot(1);
      CurrentPos_XYZ[2] = VRot(2);

      // UART0.println("CP");
      // UART0.println(CurrentPos_XYZ[0]);
      // UART0.println(CurrentPos_XYZ[1]);
      // UART0.println(CurrentPos_XYZ[2]);
      // UART0.println("END CP");

    }
  delay(5);
  
}

//Sph2Cart:convert spherical coordinate to cartesian unit vector
void Sph2Cart(float SphPolar, float SphAzimuth)
{
  CartOutput[0] = 0;
  CartOutput[1] = 0;
  CartOutput[2] = 0;
  float PolarRad = 1*Deg2Rad(SphPolar);
  float AzimuthRad = 1*Deg2Rad(SphAzimuth);
  //Polar angle starts from Z+, Azimuth angle starts from X+
  CartOutput[0] = 1*sin(PolarRad)*cos(AzimuthRad);
  CartOutput[1] = 1*sin(PolarRad)*sin(AzimuthRad);
  CartOutput[2] = 1*cos(PolarRad);
}

//Deg2Rad:rad=(deg/360)*2pi
float Deg2Rad(float deg)
{
  float rad;
  rad = deg*PI/180;
  return rad;
}

//Get Biggest: takes 4 numbers and returns the biggest among them 
float GetBiggest(float N1, float N2, float N3, float N4)
{
  float numbers[] = {N1, N2, N3, N4};
  int index = 0;
  for(int i=1; i<4; i++) 
  {
    if(numbers[i] > numbers[index]) 
    {
      index = i;
    }
  }
  return numbers[index];
}

//Rodrigues' Rotation Formula
void RRF(float X1,float Y1,float Z1, float X2,float Y2,float Z2,float theta)
{
  //Reset variables
  SPos.Fill(0); //Starting position
  RA.Fill(0);   //Rotational axis
  R.Fill(0);    //R matrix of RRF 
  k1.Fill(0);   //k^ matrix of RRF
  kt.Fill(0);   //Transposition of k as required by RRF
  VRot.Fill(0); //Result after turn

  //Set input vectors
  SPos(0) = X1;
  SPos(1) = Y1;
  SPos(2) = Z1;
  RA(0) = X2;
  RA(1) = Y2;
  RA(2) = Z2;
  theta = Deg2Rad(theta);

  //Run calculation  
  kt = ~RA;    
  k1(1,0) = RA(2);    //Create k^ matrix:   0 -a3  a2
  k1(2,0) = -1*RA(1); //                   a3   0 -a1
  k1(0,1) = -1*RA(2); //                  -a2  a1   0 
  k1(2,1) = RA(0);
  k1(0,2) = RA(1);
  k1(1,2) = -1*RA(0);    
  R = cos(theta)*I + (1-cos(theta))*RA*kt + sin(theta)*k1;    
  VRot = R*SPos;
}

//Align to Position: align rotor to target vector
void Align2Pos(float OV0,float OV1,float OV2,float PowerFactor)
{
  //Generate output voltage
  
  OVector(0) = OV0;
  OVector(1) = OV1;
  OVector(2) = OV2;
  OCoil = TM*OVector;

  // Output rectifying is not needed as onboard amps no longer do current output
  // float RectifyFactor;
  // RectifyFactor = 1/(abs(OCoil(0))+abs(OCoil(1))+abs(OCoil(2))+abs(OCoil(3)));
  // OCoil *= RectifyFactor;//Rectify factor prevents overloading of op-amp by total output exceeding 250mA

  OCoil *= PowerFactor;//Power factor scales DAC output to overdrive or save energy, cannot exceed 1.25

  //Conditional output limiting: limit board output <=2V, prevent ext-amp overheat shutdown
  float OBig = GetBiggest(abs(OCoil(0)), abs(OCoil(1)), abs(OCoil(2)), abs(OCoil(3)));
  if(OBig > 2)
  {
    float RF = 2/OBig;
    OCoil *= RF;
  }
  
  //Start voltage output  
  digitalWrite(OUTEN, LOW);
  if(OCoil(0)<0) { digitalWrite(C1Dir, HIGH); }//Output polarity
  else           { digitalWrite(C1Dir, LOW) ; }
  if(OCoil(1)<0) { digitalWrite(C2Dir, HIGH); }
  else           { digitalWrite(C2Dir, LOW) ; }
  if(OCoil(2)<0) { digitalWrite(C3Dir, HIGH); }
  else           { digitalWrite(C3Dir, LOW) ; }
  if(OCoil(3)<0) { digitalWrite(C4Dir, HIGH); }
  else           { digitalWrite(C4Dir, LOW) ; }
  mcp.setChannelValue(MCP4728_CHANNEL_A, round(abs(OCoil(0)*2042)));
  mcp.setChannelValue(MCP4728_CHANNEL_B, round(abs(OCoil(1)*2042)));
  mcp.setChannelValue(MCP4728_CHANNEL_C, round(abs(OCoil(2)*2042)));
  mcp.setChannelValue(MCP4728_CHANNEL_D, round(abs(OCoil(3)*2042)));
  // UART0.println("OCOIL");
  // UART0.println(OCoil);
}

//OutputShutdown cuts off output power
void OutputShutdown()
{
  digitalWrite(OUTEN, HIGH);
  mcp.setChannelValue(MCP4728_CHANNEL_A, 0);
  mcp.setChannelValue(MCP4728_CHANNEL_B, 0);
  mcp.setChannelValue(MCP4728_CHANNEL_C, 0);
  mcp.setChannelValue(MCP4728_CHANNEL_D, 0);
  // UART0.println("OSD");
}




