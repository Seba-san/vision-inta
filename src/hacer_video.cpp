/*

Este programa genera un video y un registro de time_stamp por cada frame grabado. La idea es que todos los programas
usen el mismo time_stamp. Resta Modificarlo para que le ponga un nombre al registro y al video automaticamente.
*/

#include <opencv2/opencv.hpp>
#include <iostream>
#include <fstream> // Para guardar el txt
#include "sl/Camera.hpp" // si pones "" lo busca primero en el proyecto y luego en PATH
#include <string>     // std::string, std::to_string
#include <sstream>
#include <sys/time.h> // para generar un timestamp autonomo (que no dependa ni de la camara ni de OpenCv)

// ############## Declaracion de funciones

cv::Mat slMat2cvMat(sl::Mat& input);
void saveDepth(sl::Camera& zed, std::string filename);


int main(int argc, char **argv) {


	std::string direccion ("/home/nvidia/discoaye");//("/media/nvidia/GIVSI/Datasets");//("/home/nvidia/discoaye");/media/nvidia/GIVSI/Datasets/Prueba180314
	std::string direccion_video = direccion + "/video/estereo.avi";
	unsigned int segundos=120;
//	long int vara = std::strtol(,,10);
//	long int vara = std::atoi(argv[2]);


	if (argc<2){
	    		std::cout << "Debe ingresar la cantidad de segundos que desea grabar" << std::endl;
	    		std::cout << "y de forma optativa ingresar la direccion en donde se grabaran" << std::endl;
	    		std::cout << "con el siguiente formato: [cantidad_seg] [opt: direccion]" << std::endl;
	    		std::cout << "por defecto sera: " << direccion_video << std::endl;
	    		return 0;
	    	}
	    if (argc==3){
	    	direccion_video = argv[3];

	    }
	    if (argc==2){
	    	std::cout << "el video se guardara en la siguiente direccion: " << std::endl;
	    	std::cout <<  direccion_video << std::endl;
	    	std::cout <<  "Ademas se guardaran " << segundos *15 <<" frames"<< std::endl;
	    	//return 0;

	        }



	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Inicializacion
	// Create a ZED Camera object
	sl::Camera zed;
	// Set configuration parameters for the ZED
	sl::InitParameters initParameters;
	initParameters.camera_resolution = sl::RESOLUTION_HD720;
	initParameters.camera_fps = 15 ;
	initParameters.depth_mode = sl::DEPTH_MODE_PERFORMANCE; // Use PERFORMANCE dept$
	initParameters.coordinate_units = sl::UNIT_MILLIMETER; // Use millimeter units $
	initParameters.depth_minimum_distance = 300 ;

//	sl::DEPTH_FORMAT Depth_format;
//	Depth_format = static_cast<sl::DEPTH_FORMAT> (0 % 3); // el 0 es para poner png y los otros son otros formatos.
//	// Open the camera
	sl::ERROR_CODE err = zed.open(initParameters);
	if (err !=  sl::SUCCESS) {
		std::cout << errorCode2str(err) << std::endl;
		zed.close();
		return 1; // Quit if an error occurred
	}

	// ############### Declaracion de variables

	sl::Mat zed_image (zed.getResolution(),sl::MAT_TYPE_8U_C3);
	sl::Mat zed_image2 (zed.getResolution(),sl::MAT_TYPE_8U_C3);
	cv::Mat image_ocvd, image_ocvi,image_ocvt,image_ocvt2;
//	cv::Mat depth_image (zed.getResolution(),CV_8UC1);
	sl::Mat depth_image_zed (zed.getResolution(),sl::MAT_TYPE_8U_C1);//sl::MAT_TYPE_8U_C1);//sl::MAT_TYPE_32F_C1);
	cv::Mat depth_image_ocv;
	cv::Mat depth_image_reducida;//(zed.getResolution(),cv::CV_32UC1);
	std::string ext (".jpg"); // .jpg,JPEG2000
		std::string nombre;
	std::stringstream nombre_stram;
	std::vector<int> compression_params;
	compression_params.push_back(1);//CV_IMWRITE_PXM_BINARY = 32;    (cv::IMWRITE_JPEG_QUALITY =1 ); // Parametros para guardar imagen
	compression_params.push_back(100);
//	std::vector<int> compression_params_depth;

// VIDEOOOOOOOOOOOOOOOOOOOOOOOOOOOOOoo
    int frames_per_second =15;
    cv::Size frame_size2(1280*2, 720);
    cv::Size frame_size(1280, 720);
    int codec = cv::VideoWriter::fourcc('M', 'J', 'P', 'G');

//    std::string direccion_video2 = direccion + "/video/Profundidad.avi";




//    // PROBANDO CON VIDEOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO

//   	cv::VideoWriter oVideoWriteri(direccion + "/video/Pruebai.avi", cv::VideoWriter::fourcc('M', 'J', 'P', 'G'), frames_per_second, frame_size, true);
//    if (oVideoWriteri.isOpened() == false){
//    std::cout << "Cannot save the video to a file" << std::endl;
//    //        cin.get(); //wait for any key press
//    					        return -1;
//    	   }
//
//    cv::VideoWriter oVideoWriterd(direccion + "/video/Pruebad.avi", cv::VideoWriter::fourcc('M', 'J', 'P', 'G'), frames_per_second, frame_size, true);
//        if (oVideoWriterd.isOpened() == false){
//        std::cout << "Cannot save the video to a file" << std::endl;
//        //        cin.get(); //wait for any key press
//        					        return -1;
//        	   }

	cv::VideoWriter VideoStereo(direccion_video, codec , frames_per_second, frame_size2, true);//false
			if (VideoStereo.isOpened() == false){
			std::cout << "Cannot save the video to a file" << std::endl;
			//        cin.get(); //wait for any key press
										return -1;
				   }

			// Medicion de tiempo
			    	struct timeval t_inicial, t_parcial ;
			    	unsigned long long tiempo;
			// Generar Registro
			std::string direccion_archivo = direccion + "/video/registro.txt";
			std::ofstream archivo;
			archivo.open (direccion_archivo);


//			cv::VideoWriter profundidad(direccion_video2, codec , frames_per_second, frame_size, true);//false
//						if (oVideoWritert.isOpened() == false){
//						std::cout << "Cannot save the video to a file" << std::endl;
//						//        cin.get(); //wait for any key press
//													return -1;
//							   }

			// Variables de programa
	char key = ' ';
	unsigned long long timestamp,timestamp2,rest;
	unsigned long long tiempopromedio=0;
	double t=0,t2=0,t3=1,num=0;
	double frames_max=15 * segundos; // en segundos



	gettimeofday (&t_inicial, NULL); // tomo el valor de tiempo actual
	int aux=0;
	while (aux==0) {
		//key = cv::waitKey(1);
		if (zed.grab() == sl::SUCCESS) {
			gettimeofday (&t_parcial, NULL); // tomo el tiempo de carga
			tiempo=t_parcial.tv_sec*1000000 + t_parcial.tv_usec ;
//			tiempo=(t_parcial.tv_sec - t_inicial.tv_sec)*1000000 ;
//			tiempo+=t_parcial.tv_usec - t_inicial.tv_usec;
			archivo << tiempo << "\n";
			// Guardo imagen izquierda
			zed.retrieveImage(zed_image, sl::VIEW_LEFT); // la guarda en la varible zed_image
			image_ocvi= slMat2cvMat(zed_image);

			// Guardo imagen derecha
			zed.retrieveImage(zed_image2, sl::VIEW_RIGHT); // la guarda en la varible zed_image
			image_ocvd= slMat2cvMat(zed_image2);

			cv::hconcat(image_ocvi,image_ocvd,image_ocvt); // Pongo las 2 imagenes en una sola
//			cv::cvtColor(image_ocvt, image_ocvt2, CV_RGB2BGR);
//			t2=(double)cv::getTickCount();
			VideoStereo.write(image_ocvt); // Guardo un nuevo frame


			// Guardo disparidad $ REVISAR ESTO
//			t2=(double)cv::getTickCount();
//			zed.retrieveMeasure(depth_image_zed, sl::MEASURE_DEPTH); // Get the left image
//			 // Retrieve the depth measure (32-bit)
////			zed.retrieveMeasure(depth_image_zed, sl::MEASURE_DEPTH);//MEASURE_DEPTH; VIEW_DEPTH; Con Measure_DEPTH devuelve una matriz de 32 bits, con view_depth, es de 8 bits. Para fines ilustrativos, usar el view
//			depth_image_ocv = ta	(depth_image_zed); // OJO hay que pasarlo a 8bit, ver en registros del 01/03
////			depth_image_ocv.convertTo(image_ocvt2,CV_8UC1);
//			profundidad.write(depth_image_ocv);
//			t2 = ((double)cv::getTickCount() - t2);
//			std::cout << "profundidad  " << t2*1000/(cv::getTickFrequency())<< " ms." << std::endl;


//			saveDepth(zed,direccion + "/imagenes/"+ nombre + ext);
			//			t2=(double)cv::getTickCount();
//			cv::imwrite( direccion + "/imagenes/" + nombre + ".exr", depth_image_ocv);
//			t2 = ((double)cv::getTickCount() - t2);

			num=num+1;
			}
//			tiempopromedio = tiempopromedio +t ;
//			std::cout << "tiempo de computo " << t*1000/(cv::getTickFrequency())<< " ms." << std::endl;
//
//			nombre_stram.str(""); // limpio la variable stringstream, sino se acomula indefinidamente y colapsa el programa
//			aux=0; // Para que no salga del while y ver si graba piola;
//

					if (num>frames_max){aux=1;
					gettimeofday (&t_parcial, NULL);
					tiempo=(t_parcial.tv_sec - t_inicial.tv_sec)*1000000 ;
					tiempo+=t_parcial.tv_usec - t_inicial.tv_usec;
					std::cout << "Se grabaron "<< num - 1 << " frames " << std::endl;
					std::cout << "en un tiempo de "<< tiempo << " us " << std::endl;
//					std::cout << "Se completaron la cantidad de frames especuladas"<< std::endl;
//					std::cout << "Tiempo promedio "<< tiempopromedio*1000/(num*cv::getTickFrequency()) << std::endl;
//					std::cout << "Tiempo maximo "<< t3*1000/(cv::getTickFrequency()) << std::endl;
					}

		}



	zed.disableRecording();
	// Exit
	zed.close();
//	 oVideoWriteri.release();
	 VideoStereo.release();
	 archivo.close();
//	 profundidad.release();
	return 0;

}


/**
 * Conversion function between sl::Mat and cv::Mat
 **/
cv::Mat slMat2cvMat(sl::Mat& input) {
	// Mapping between MAT_TYPE and CV_TYPE
	int cv_type = -1;
	switch (input.getDataType()) {
	case sl::MAT_TYPE_32F_C1: cv_type = CV_32FC1; break;
	case sl::MAT_TYPE_32F_C2: cv_type = CV_32FC2; break;
	case sl::MAT_TYPE_32F_C3: cv_type = CV_32FC3; break;
	case sl::MAT_TYPE_32F_C4: cv_type = CV_32FC4; break;
	case sl::MAT_TYPE_8U_C1: cv_type = CV_8UC1; break;
	case sl::MAT_TYPE_8U_C2: cv_type = CV_8UC2; break;
	case sl::MAT_TYPE_8U_C3: cv_type = CV_8UC3; break;
	case sl::MAT_TYPE_8U_C4: cv_type = CV_8UC4; break;
	default: break;
	}
	// Since cv::Mat data requires a uchar* pointer, we get the uchar1 pointer from sl::Mat (getPtr<T>())
	// cv::Mat and sl::Mat will share a single memory structure
	return cv::Mat(input.getHeight(), input.getWidth(), cv_type, input.getPtr<sl::uchar1>(sl::MEM_CPU));
}


/**
 * Mostrar el imshow el depth
 * // Create an RGBA sl::Mat object
sl::Mat image_depth_zed(zed.getResolution(), MAT_TYPE_8U_C4);
// Create an OpenCV Mat that shares sl::Mat data
cv::Mat image_depth_ocv= slMat2cvMat(image_depth_zed);

if (zed.grab() == SUCCESS) {
    // Retrieve the normalized depth image
    zed.retrieveImage(image_depth_zed, VIEW_DEPTH);
    // Display the depth view from the cv::Mat object
    cv::imshow("Image", image_depth_ocv);
}
//isValidMeasure()
**/

/**
 * Read:

Mat matrix = imread("filename.exr", IMREAD_ANYCOLOR | IMREAD_ANYDEPTH);
and Write:

imwrite("filename.exr", matrix);
**/


//  bool saved = sl::saveDepthAs(zed, Depth_format, filename.c_str(), scale_factor);
//			    if (saved)
//			        std::cout << "Done" << endl;
//			    else
//			        std::cout << "Failed... Please check that you have permissions to write on disk" << endl;
//
//			sl::DEPTH_FORMAT Depth_format;
//			cv::imwrite("~/imgOut.bmp",  cv::Mat(512, 512, CV_32FC1, gray));
void saveDepth(sl::Camera& zed, std::string filename) {
//float max_value = std::numeric_limits<unsigned short int>::max();
//float scale_factor = max_value / zed.getDepthMaxRangeValue();
sl::DEPTH_FORMAT Depth_format;
Depth_format = static_cast<sl::DEPTH_FORMAT> (2 % 3); // el 0 es para que lo guarde en png y 2 pgm


//std::cout << "Saving Depth Map... " << flush;
bool saved = sl::saveDepthAs(zed, Depth_format, filename.c_str(), 1);
//if (saved){}
//   // std::cout << "Done" << endl;
//else{
//    std::cout << "Failed... Please check that you have permissions to write on disk" << std::endl;
//}
}


