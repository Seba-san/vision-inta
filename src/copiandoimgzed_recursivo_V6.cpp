/* En este programa experimento distintas estrategias para guardar  imagenes en disco.
 Cosas que se cambiaron en esta vercion: Se corrigio la funcion para medir el tiempo con
 los compandos de opencv. Ademas solo se muestra el nuevo tiempo mas largo.

 Se va a utilizar la memoria de la GPU para guardar las imagenes. NO LO HICE

en la V4 voy a ver los tiempos grabando un video

En la V5, voy a ver si puedo pegar las 2 imagenes y guardarla como si fuera una sola (para disminuir mas los tiempos)
ademas quiero ver si puedo convertir la imagen de profundidad en una imagen standart para poder usar los algoritmos de comprecion


*/

#include <opencv2/opencv.hpp>
#include <iostream>
#include "sl/Camera.hpp" // si pones "" lo busca primero en el proyecto y luego en PATH
#include <string>     // std::string, std::to_string
#include <sstream>
// ############## Declaracion de funciones

cv::Mat slMat2cvMat(sl::Mat& input);
void saveDepth(sl::Camera& zed, std::string filename);


int main(int argc, char **argv) {

	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Inicializacion
	// Create a ZED Camera object
	sl::Camera zed;
	// Set configuration parameters for the ZED
	sl::InitParameters initParameters;
	initParameters.camera_resolution = sl::RESOLUTION_HD720;
	initParameters.camera_fps = 60 ;
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
	std::string direccion ("/home/nvidia/discoaye");//("/media/nvidia/GIVSI/Datasets");//("/home/nvidia/discoaye");/media/nvidia/GIVSI/Datasets/Prueba180314
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
    std::string direccion_video = direccion + "/video/estereo.avi";
    std::string direccion_video2 = direccion + "/video/Profundidad.avi";

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

//	cv::VideoWriter oVideoWritert(direccion_video, codec , frames_per_second, frame_size2, true);//false
//			if (oVideoWritert.isOpened() == false){
//			std::cout << "Cannot save the video to a file" << std::endl;
//			//        cin.get(); //wait for any key press
//										return -1;
//				   }
//			cv::VideoWriter profundidad(direccion_video2, codec , frames_per_second, frame_size, true);//false
//						if (oVideoWritert.isOpened() == false){
//						std::cout << "Cannot save the video to a file" << std::endl;
//						//        cin.get(); //wait for any key press
//													return -1;
//							   }

	char key = ' ';
	unsigned long long timestamp,timestamp2,rest;
	unsigned long long tiempopromedio=0;
	double t=0,t2=0,t3=1,num=0;


	int aux=0;

	while (aux==0) {
		//key = cv::waitKey(1);
		if (zed.grab() == sl::SUCCESS) {
			t=(double)cv::getTickCount();

			timestamp = zed.getCameraTimestamp(); // Get the timestamp of the image
			nombre_stram << timestamp ;
			nombre=nombre_stram.str(); // Convierto a string el tiempo en que fue sacada la imagen asi luego lo guardo con ese nombre.


			// Guardo imagen izquierda
			zed.retrieveImage(zed_image, sl::VIEW_LEFT); // la guarda en la varible zed_image
			image_ocvi= slMat2cvMat(zed_image);

			// Guardo imagen derecha
			zed.retrieveImage(zed_image2, sl::VIEW_RIGHT); // la guarda en la varible zed_image
			image_ocvd= slMat2cvMat(zed_image2);cd


			cv::hconcat(image_ocvi,image_ocvd,image_ocvt);
//			cv::cvtColor(image_ocvt, image_ocvt2, CV_RGB2BGR);
			t2=(double)cv::getTickCount();
//			oVideoWritert.write(image_ocvt);
			cv::imwrite( direccion +"/imagenes/" + nombre + ext, image_ocvt,compression_params);

			t2 = ((double)cv::getTickCount() - t2);
			std::cout << "imagenes  " << t2*1000/(cv::getTickFrequency())<< " ms." << std::endl;


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
//			std::cout << "viejo depth " << t2*1000/(cv::getTickFrequency())<< " ms." << std::endl;

			//printf("Image resolution: %d x %d  || Image timestamp: %llu\n", zed_image.getWidth(), zed_image.getHeight(), timestamp);


			t = ((double)cv::getTickCount() - t);
			if (t>t3){
				t3=t;
			std::cout << "tiempo maximo de computo " << t3*1000/(cv::getTickFrequency()) << " ms." << std::endl;

			}
			tiempopromedio = tiempopromedio +t ;
			std::cout << "tiempo de computo " << t*1000/(cv::getTickFrequency())<< " ms." << std::endl;

			nombre_stram.str(""); // limpio la variable stringstream, sino se acomula indefinidamente y colapsa el programa
			aux=0; // Para que no salga del while y ver si graba piola;

			num=num+1;
					if (num>500){aux=1;
					std::cout << "Se completaron la cantidad de frames especuladas"<< std::endl;
					std::cout << "Tiempo promedio "<< tiempopromedio*1000/(num*cv::getTickFrequency()) << std::endl;
					std::cout << "Tiempo maximo "<< t3*1000/(cv::getTickFrequency()) << std::endl;
					}

		}

	}

	zed.disableRecording();
	// Exit
	zed.close();
//	 oVideoWriteri.release();
//	 oVideoWritert.release();
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


