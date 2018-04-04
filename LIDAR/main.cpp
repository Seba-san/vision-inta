#define _POSIX_SOURCE 1 /* POSIX compliant source */
#include <stdio.h>      // standard input / output functions
#include <stdlib.h>
#include <string.h>     // string function definitions
#include <unistd.h>     // UNIX standard function definitions
#include <fcntl.h>      // File control definitions
#include <errno.h>      // Error number definitions
#include <termios.h>    // POSIX terminal control definitions
#include <fstream>

#include <sys/time.h>
#include <iostream>
#include <sys/types.h>
#include <sys/stat.h>
#include <pthread.h>

using namespace std;

//Definition of parameters
int freq=25;    //Opciones: 25 o 50 (Hz)
int angRes=25;  //Opciones: 25 o 50 (centésimas de ángulo)

//Definition of commands
int StartMeasurement[18]={0x02,0x73,0x4D,0x4E,0x20,0x4C,0x4D,0x43,0x73,0x74,0x61,0x72,0x74,0x6D,0x65,0x61,0x73,0x03};
int StopMeasurement[17]={0x02,0x73,0x4D,0x4E,0x20,0x4C,0x4D,0x43,0x73,0x74,0x6F,0x70,0x6D,0x65,0x61,0x73,0x03};
int ReadSingleMeasurement[17]={0x02,0x73,0x52,0x4E,0x20,0x4C,0x4D,0x44,0x73,0x63,0x61,0x6E,0x64,0x61,0x74,0x61,0x03};
int ReadContinuousMeasurementStart[19]={0x02,0x73,0x45,0x4E,0x20,0x4C,0x4D,0x44,0x73,0x63,0x61,0x6E,0x64,0x61,0x74,0x61,0x20,0x31,0x03};
int ReadContinuousMeasurementStop[19]={0x02,0x73,0x45,0x4E,0x20,0x4C,0x4D,0x44,0x73,0x63,0x61,0x6E,0x64,0x61,0x74,0x61,0x20,0x30,0x03};
int config25Hz25angRes[52]={0x02,0x73,0x4D,0x4E,0x20,0x6D,0x4C,0x4D,0x50,0x73,0x65,0x74,0x73,0x63,0x61,0x6E,0x63,0x66,0x67,0x20,0x2B,
                          0x32,0x35,0x30,0x30,0x20,0x2B,0x31,0x20,0x2B,0x32,0x35,0x30,0x30,0x20,0x2D,0x34,0x35,0x30,0x30,0x30,0x30,
                          0x20,0x2B,0x32,0x32,0x35,0x30,0x30,0x30,0x30,0x03};//<sMN mLMPsetscancfg +2500 +1 +2500 -450000 +2250000
int config50Hz25angRes[52]={0x02,0x73,0x4D,0x4E,0x20,0x6D,0x4C,0x4D,0x50,0x73,0x65,0x74,0x73,0x63,0x61,0x6E,0x63,0x66,0x67,0x20,0x2B,
                          0x35,0x30,0x30,0x30,0x20,0x2B,0x31,0x20,0x2B,0x32,0x35,0x30,0x30,0x20,0x2D,0x34,0x35,0x30,0x30,0x30,0x30,
                          0x20,0x2B,0x32,0x32,0x35,0x30,0x30,0x30,0x30,0x03};//<sMN mLMPsetscancfg +2500 +1 +2500 -450000 +2250000
int config25Hz50angRes[52]={0x02,0x73,0x4D,0x4E,0x20,0x6D,0x4C,0x4D,0x50,0x73,0x65,0x74,0x73,0x63,0x61,0x6E,0x63,0x66,0x67,0x20,0x2B,
                          0x32,0x35,0x30,0x30,0x20,0x2B,0x31,0x20,0x2B,0x35,0x30,0x30,0x30,0x20,0x2D,0x34,0x35,0x30,0x30,0x30,0x30,
                          0x20,0x2B,0x32,0x32,0x35,0x30,0x30,0x30,0x30,0x03};//<sMN mLMPsetscancfg +2500 +1 +2500 -450000 +2250000
int config50Hz50angRes[52]={0x02,0x73,0x4D,0x4E,0x20,0x6D,0x4C,0x4D,0x50,0x73,0x65,0x74,0x73,0x63,0x61,0x6E,0x63,0x66,0x67,0x20,0x2B,
                          0x35,0x30,0x30,0x30,0x20,0x2B,0x31,0x20,0x2B,0x35,0x30,0x30,0x30,0x20,0x2D,0x34,0x35,0x30,0x30,0x30,0x30,
                          0x20,0x2B,0x32,0x32,0x35,0x30,0x30,0x30,0x30,0x03};//<sMN mLMPsetscancfg +2500 +1 +2500 -450000 +2250000
int QueryStatus[11]={0x02,0x73,0x52,0x4E,0x20,0x53,0x54,0x6C,0x6D,0x73,0x03};//sRN STlms
int SelectUserLevel[31]={0x02,0x73,0x4D,0x4E,0x20,0x53,0x65,0x74,0x41,0x63,0x63,0x65,0x73,0x73,0x4D,0x6F,0x64,0x65,
                       0x20,0x30,0x33,0x20,0x46,0x34,0x37,0x32,0x34,0x37,0x34,0x34,0x03};//sMN SetAccessMode 03 F4724744 (authorised client)
//int ConfigureDataOutput[]={};//Por Defecto
int RestartDevice[9]={0x02,0x73,0x4D,0x4E,0x20,0x52,0x75,0x6E,0x03};//sMN Run


int Inic1[18]={0x02,0x73,0x45,0x4e,0x20,0x4c,0x49,0x44,0x68,0x77,0x69,0x6e,0x6e,0x75,0x6d,0x20,0x31,0x03};//sEN LIDhwinnum 1
int Inic2[16]={0x02,0x73,0x52,0x4e,0x20,0x4c,0x49,0x44,0x68,0x77,0x69,0x6e,0x6e,0x75,0x6d,0x03};//sRN LIDhwinnum
int Inic3[20]={0x02,0x73,0x45,0x4e,0x20,0x4c,0x4d,0x50,0x61,0x70,0x70,0x6c,0x52,0x61,0x6e,0x67,0x65,0x20,0x31,0x03};//sEN LMPapplRange 1
int Inic4[16]={0x02,0x73,0x45,0x4e,0x20,0x66,0x69,0x65,0x6c,0x64,0x30,0x30,0x30,0x20,0x31,0x03};//sEN field000 1
int Inic5[18]={0x02,0x73,0x52,0x4e,0x20,0x4c,0x4d,0x50,0x61,0x70,0x70,0x6c,0x52,0x61,0x6e,0x67,0x65,0x03};//sRN LMPapplRange
int Inic6[16]={0x02,0x73,0x45,0x4e,0x20,0x66,0x69,0x65,0x6c,0x64,0x30,0x30,0x31,0x20,0x31,0x03};//sEN field001 1
int Inic7[14]={0x02,0x73,0x52,0x4e,0x20,0x66,0x69,0x65,0x6c,0x64,0x30,0x30,0x30,0x03};//sRN field000
int Inic8[16]={0x02,0x73,0x45,0x4e,0x20,0x66,0x69,0x65,0x6c,0x64,0x30,0x30,0x32,0x20,0x31,0x03};//sEN field002 1
int Inic9[14]={0x02,0x73,0x52,0x4e,0x20,0x66,0x69,0x65,0x6c,0x64,0x30,0x30,0x31,0x03};//sRN field001
int Inic10[16]={0x02,0x73,0x45,0x4e,0x20,0x66,0x69,0x65,0x6c,0x64,0x30,0x30,0x33,0x20,0x31,0x03};//sEN field003 1
int Inic11[14]={0x02,0x73,0x52,0x4e,0x20,0x66,0x69,0x65,0x6c,0x64,0x30,0x30,0x32,0x03};//sRN field002
int Inic12[16]={0x02,0x73,0x45,0x4e,0x20,0x66,0x69,0x65,0x6c,0x64,0x30,0x30,0x34,0x20,0x31,0x03};//sEN field004 1
int Inic13[14]={0x02,0x73,0x52,0x4e,0x20,0x66,0x69,0x65,0x6c,0x64,0x30,0x30,0x33,0x03};//sRN field003
int Inic14[16]={0x02,0x73,0x45,0x4e,0x20,0x66,0x69,0x65,0x6c,0x64,0x30,0x30,0x35,0x20,0x31,0x03};//sEN field005 1
int Inic15[14]={0x02,0x73,0x52,0x4e,0x20,0x66,0x69,0x65,0x6c,0x64,0x30,0x30,0x34,0x03};//sRN field004
int Inic16[16]={0x02,0x73,0x45,0x4e,0x20,0x66,0x69,0x65,0x6c,0x64,0x30,0x30,0x36,0x20,0x31,0x03};//sEN field006 1
int Inic17[14]={0x02,0x73,0x52,0x4e,0x20,0x66,0x69,0x65,0x6c,0x64,0x30,0x30,0x35,0x03};//sRN field005
int Inic18[16]={0x02,0x73,0x45,0x4e,0x20,0x66,0x69,0x65,0x6c,0x64,0x30,0x30,0x37,0x20,0x31,0x03};//sEN field007 1
int Inic19[14]={0x02,0x73,0x52,0x4e,0x20,0x66,0x69,0x65,0x6c,0x64,0x30,0x30,0x36,0x03};//sRN field006
int Inic20[16]={0x02,0x73,0x45,0x4e,0x20,0x66,0x69,0x65,0x6c,0x64,0x30,0x30,0x38,0x20,0x31,0x03};//sEN field008 1
int Inic21[14]={0x02,0x73,0x52,0x4e,0x20,0x66,0x69,0x65,0x6c,0x64,0x30,0x30,0x37,0x03};//sRN field007
int Inic22[16]={0x02,0x73,0x45,0x4e,0x20,0x66,0x69,0x65,0x6c,0x64,0x30,0x30,0x39,0x20,0x31,0x03};//sEN field009 1
int Inic23[14]={0x02,0x73,0x52,0x4e,0x20,0x66,0x69,0x65,0x6c,0x64,0x30,0x30,0x38,0x03};//sRN field008
int Inic24[21]={0x02,0x73,0x45,0x4e,0x20,0x4c,0x49,0x44,0x69,0x6e,0x70,0x75,0x74,0x73,0x74,0x61,0x74,0x65,0x20,0x31,0x03};//sEN LIDinputstate 1
int Inic25[14]={0x02,0x73,0x52,0x4e,0x20,0x66,0x69,0x65,0x6c,0x64,0x30,0x30,0x39,0x03};//sRN field009
int Inic26[22]={0x02,0x73,0x45,0x4e,0x20,0x4c,0x49,0x44,0x6f,0x75,0x74,0x70,0x75,0x74,0x73,0x74,0x61,0x74,0x65,0x20,0x31,0x03};//sEN LIDoutputstate 1
int Inic27[19]={0x02,0x73,0x52,0x4e,0x20,0x4c,0x49,0x44,0x69,0x6e,0x70,0x75,0x74,0x73,0x74,0x61,0x74,0x65,0x03};//sRN LIDinputstate
int Inic28[21]={0x02,0x73,0x45,0x4e,0x20,0x4c,0x49,0x44,0x70,0x61,0x6e,0x65,0x6c,0x73,0x74,0x61,0x74,0x65,0x20,0x31,0x03};//sEN LIDpanelstate 1
int Inic29[20]={0x02,0x73,0x52,0x4e,0x20,0x4c,0x49,0x44,0x6f,0x75,0x74,0x70,0x75,0x74,0x73,0x74,0x61,0x74,0x65,0x03};//sRN LIDoutputstate
int Inic30[14]={0x02,0x73,0x45,0x4e,0x20,0x4c,0x46,0x45,0x72,0x65,0x63,0x20,0x31,0x03};//sEN LFErec 1
int Inic31[19]={0x02,0x73,0x52,0x4e,0x20,0x4c,0x49,0x44,0x70,0x61,0x6e,0x65,0x6c,0x73,0x74,0x61,0x74,0x65,0x03};//sRN LIDpanelstate
int Inic32[12]={0x02,0x73,0x52,0x4e,0x20,0x4c,0x46,0x45,0x72,0x65,0x63,0x03};//sRN LFErec
int Inic33[22]={0x02,0x73,0x45,0x4e,0x20,0x4c,0x4d,0x44,0x73,0x63,0x61,0x6e,0x64,0x61,0x74,0x61,0x6d,0x6f,0x6e,0x20,0x31,0x03};//sEN LMDscandatamon 1
int Inic34[20]={0x02,0x73,0x52,0x4e,0x20,0x4c,0x4d,0x44,0x73,0x63,0x61,0x6e,0x64,0x61,0x74,0x61,0x6d,0x6f,0x6e,0x03};//sRN LMDscandatamon

ofstream file; //Creamos la clase para que quede "global", accesible desde todas las funciones.
static volatile bool keep_running = true;
struct timeval tv[500000];
int i = 0; //Cuenta de tramas

//Function declaration
void inicialization(int serial_USB);
void Configuration(int serial_USB);
int serial_open(char *serial_name, speed_t baud);
void serial_close(int fd);
void serial_send(int serial_USB, int *code, int size);
int serial_read(int serial_fd, char *data, int size, int timeout_usec,int save);

static void* userInput_thread(void*)
   {
       while(keep_running) {
           if (std::cin.get() == 'k') { keep_running = false; } ////! Si se presiona 'k' deja de correr
       }
   }


int main(void)
{
    pthread_t tId;
    (void) pthread_create(&tId, 0, userInput_thread, 0); //Para que corra hasta presionar 'k'

    int serial_USB;

    char data[5000];

//Open TTY port
    serial_USB = serial_open("/dev/ttyUSB0", B57600);
    if (serial_USB == -1) {
        printf ("Error opening the serial device");
        perror("OPEN PORT");
        exit(0);
    }


    file.open ("/home/francho/Documentos/Facultad/Proyecto/Codes/Lidar/DatosLeidos.txt");

    //inicialization(serial_USB);
    Configuration(serial_USB);

    gettimeofday (&tv[0], NULL);//tiempo al comienzo de la lectura
    cout << "Comienzo de la lectura" << endl << "Tiempo Actual" << endl;
    printf ("%2d: secs = %d, usecs = %6d", 0, tv[0].tv_sec, tv[0].tv_usec);

    //Leemos los datos
    do {

        serial_send(serial_USB, ReadSingleMeasurement, sizeof(ReadSingleMeasurement));serial_read(serial_USB,data,5000,100000,1);//puts(data);

    } while( keep_running );

    (void) pthread_join(tId, NULL);

    file.close();

    serial_close(serial_USB);
    cout << "Puerto cerrado" << endl;

    return 0;
}

 //Funciones-----------------------------------------------------------------------------------------

int serial_open(char *serial_name, speed_t baud)
    {
        struct termios tty;
        int USB = open( serial_name, O_RDWR | O_NOCTTY);// | O_NDELAY );
//        memset (&tty, 0, sizeof tty);
        cfsetospeed (&tty, baud); //set Baud rate (output)
        cfsetispeed (&tty, baud); //set Baud rate (input)

        tty.c_cflag  &=  ~PARENB; // Make 8n1
        tty.c_cflag  &=  ~CSTOPB;
        tty.c_cflag  |=  CS8;
        cfmakeraw(&tty);
        if ( tcsetattr ( USB, TCSANOW, &tty ) != 0) {
           fprintf(stderr, "Error %d from tcgetattr: %s\n", errno, strerror(errno));
        }
//        tcsetattr(USB, TCSANOW, &tty);    // apply the settings to the port
        return USB;

    }

void serial_close(int USB)
    {
       close(USB);
    }


//ESCRITURA
void serial_send(int serial_USB, int *code, int size)
    {
      char message[size + 2];
      for(int i=0;i<=size;i++) {
          message[i]=code[i];
      }
      int n_written = write(serial_USB, message, size);
      printf ("Mensaje enviado------> %s\n",message);
      if (n_written < 0)
      cerr << "Write error" << endl;
    }


//LECTURA
int serial_read(int serial_USB, char *data, int size, int timeout_usec,int save)
    {
          fd_set fds;
          struct timeval timeout;
          int count=0;
          int ret;
          int n;
          do {
            FD_ZERO(&fds);
            FD_SET (serial_USB, &fds);
            timeout.tv_sec = 0;
            timeout.tv_usec = timeout_usec;
            ret=select (FD_SETSIZE,&fds, NULL, NULL,&timeout);
            if (ret==1) {
//              n=read (serial_USB, &data[count], size-count);
              n=read (serial_USB, &data[count], size);
              count+=n;
              data[count]=0;
            }
//          } while (count<size && ret==1);
          } while (count<(10*size) && ret==1);
          printf ("Mensaje recibido-----> %s\n",data);
          if (save == 1)
          {
              i++;
              gettimeofday (&tv[i], NULL);
              printf ("%2d: secs = %d, usecs = %6d\n", i, tv[i].tv_sec, tv[i].tv_usec);
              file << endl << i << ": " << (tv[i].tv_sec) << "." << (tv[i].tv_usec) << endl;  //For timestamp
              file << endl << data << endl;
          }
     return count;
    }


//Rutina de inicializacion
void inicialization(int serial_USB)
{
    printf("Inicializamos el Dispositivo:");
    int n;char data[5000];
    serial_send(serial_USB, Inic1, sizeof(Inic1));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic2, sizeof(Inic2));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic3, sizeof(Inic3));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic4, sizeof(Inic4));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic5, sizeof(Inic5));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic6, sizeof(Inic6));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic7, sizeof(Inic7));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic8, sizeof(Inic8));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic9, sizeof(Inic9));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic10, sizeof(Inic10));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic11, sizeof(Inic11));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic12, sizeof(Inic12));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic13, sizeof(Inic13));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic14, sizeof(Inic14));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic15, sizeof(Inic15));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic16, sizeof(Inic16));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic17, sizeof(Inic17));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic18, sizeof(Inic18));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic19, sizeof(Inic19));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic20, sizeof(Inic20));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic21, sizeof(Inic21));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic22, sizeof(Inic22));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic23, sizeof(Inic23));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic24, sizeof(Inic24));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic25, sizeof(Inic25));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic26, sizeof(Inic26));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic27, sizeof(Inic27));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic28, sizeof(Inic28));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic29, sizeof(Inic29));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic30, sizeof(Inic30));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    serial_send(serial_USB, Inic31, sizeof(Inic31));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    //serial_send(serial_USB, Inic32, sizeof(Inic32));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    //serial_send(serial_USB, Inic33, sizeof(Inic33));n=serial_read(serial_USB,data,5000,100000,0);puts(data);
    //serial_send(serial_USB, Inic34, sizeof(Inic34));n=serial_read(serial_USB,data,5000,100000,0);puts(data);
    printf("Inicialización terminada");
    }

//Rutina de configuracion
void Configuration(int serial_USB)
{
    printf("Configuramos el Dispositivo:");
    int n;char data[5000];
    serial_send(serial_USB, StartMeasurement, sizeof(StartMeasurement));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    while(data[11]!='7') {
    serial_send(serial_USB, QueryStatus, sizeof(QueryStatus));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
        }
    serial_send(serial_USB, SelectUserLevel, sizeof(SelectUserLevel));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
//    serial_send(serial_USB, ConfigureDataOutput, sizeof(ConfigureDataOutput));n=serial_read(serial_USB,data,5000,100000,0);puts(data);
    if(freq==25 && angRes==25) {
        serial_send(serial_USB, config25Hz25angRes, sizeof(config25Hz25angRes));n=serial_read(serial_USB,data,5000,100000,0);}//puts(data);}
    else if(freq==25 && angRes==50) {
        serial_send(serial_USB, config25Hz50angRes, sizeof(config25Hz50angRes));n=serial_read(serial_USB,data,5000,100000,0);}//puts(data);}
    else if(freq==50 && angRes==25) {
        serial_send(serial_USB, config50Hz25angRes, sizeof(config50Hz25angRes));n=serial_read(serial_USB,data,5000,100000,0);}//puts(data);}
    else {
        serial_send(serial_USB, config50Hz50angRes, sizeof(config50Hz50angRes));n=serial_read(serial_USB,data,5000,100000,0);}//puts(data);}
    while(data[11]!='7') {
    serial_send(serial_USB, QueryStatus, sizeof(QueryStatus));n=serial_read(serial_USB,data,5000,100000,0);}//puts(data);}
    serial_send(serial_USB, RestartDevice, sizeof(RestartDevice));n=serial_read(serial_USB,data,5000,100000,0);//puts(data);
    printf("Configuración terminada");
}
