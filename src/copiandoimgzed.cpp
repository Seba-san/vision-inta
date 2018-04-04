#include <opencv2/opencv.hpp>
#include <iostream>
#include "sl/Camera.hpp" // si pones "" lo busca primero en el proyecto y luego en PATH
#include <string>     // std::string, std::to_string
#include <sstream>
// ############## Declaracion de funciones

cv::Mat slMat2cvMat(sl::Mat& input);




int main(int argc, char **argv) {

	// Create a ZED Camera object
	sl::Camera zed;
	// Set configuration parameters for the ZED
	sl::InitParameters initParameters;
	initParameters.camera_resolution = sl::RESOLUTION_HD720;
	initParameters.camera_fps = 30 ;
	initParameters.depth_mode = sl::DEPTH_MODE_PERFORMANCE; // Use PERFORMANCE dept$
	initParameters.coordinate_units = sl::UNIT_MILLIMETER; // Use millimeter units $
	initParameters.depth_minimum_distance = 300 ;
	// Open the camera
	sl::ERROR_CODE err = zed.open(initParameters);
	if (err !=  sl::SUCCESS) {
		std::cout << errorCode2str(err) << std::endl;
		zed.close();
		return 1; // Quit if an error occurred
	}

	// ############### Declaracion de variables

	sl::Mat zed_image;
	cv::Mat image_ocv ;
	sl::Mat depth_image_zed;
	cv::Mat depth_image_ocv;
	std::string ext (".jpg");
	std::string nombre;
	std::stringstream nombre_stram;
	std::vector<int> compression_params;
	compression_params.push_back(cv::IMWRITE_JPEG_QUALITY  ); // Parametros para guardar imagen
	compression_params.push_back(100);


	char key = ' ';
	unsigned long long timestamp,timestamp2,rest;
	double t=0,t2=0,t3=1;


	int aux=0;

	while (aux==0) {
		//key = cv::waitKey(1);
		if (zed.grab() == sl::SUCCESS) {
			//t = ((double)cv::getTickCount() - t)/cv::getTickFrequency();
			//std::cout << "Tiempo entre frames " << t << std::endl;
			//if (t<t3){t3=t;}
			//std::cout << "Tiempo minimo entre frames " << t3 << std::endl;
			//t = (double)cv::getTickCount(); // mido el tiempo que tarda
			// Retrieve left image
			zed.retrieveImage(zed_image, sl::VIEW_LEFT); // la guarda en la varible zed_image
			timestamp = zed.getCameraTimestamp(); // Get the timestamp of the image
			nombre_stram << timestamp ;
			nombre=nombre_stram.str(); // Convierto a string el tiempo en que fue sacada la imagen asi luego lo guardo con ese nombre.
			image_ocv= slMat2cvMat(zed_image);
			cv::imwrite( "./imagenes/" + nombre + "i"+ ext, image_ocv,compression_params);

			zed.retrieveImage(zed_image, sl::VIEW_RIGHT); // la guarda en la varible zed_image
			image_ocv= slMat2cvMat(zed_image);
			cv::imwrite( "./imagenes/" + nombre +"d" + ext, image_ocv,compression_params);

			zed.retrieveMeasure(depth_image_zed, sl::MEASURE_DEPTH);//VIEW_DEPTH
			depth_image_ocv = slMat2cvMat(depth_image_zed); // OJO hay que pasarlo a 8bit, ver en registros del 01/03

			cv::imwrite( "./imagenes/" + nombre + ".exr", depth_image_ocv);



			printf("Image resolution: %d x %d  || Image timestamp: %llu\n", zed_image.getWidth(), zed_image.getHeight(), timestamp);


//			t = ((double)cv::getTickCount() - t)/cv::getTickFrequency();
//			if (t>t2){t2=t;}
//			std::cout << "tiempo de computo " << t << std::endl;
//			std::cout << "tiempo maximo de computo" << t2 <<std::endl;
			aux=0; // Para que no salga del while y ver si graba piola;


		}

		//timestamp2=timestamp;
		//t2=t;
		//t = (double)cv::getTickCount(); // mido el tiempo que tarda




	}

	zed.disableRecording();
	// Exit
	zed.close();
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

/**
 * bool saved = sl::saveDepthAs(zed, Depth_format, filename.c_str(), scale_factor);
			    if (saved)
			        std::cout << "Done" << endl;
			    else
			        std::cout << "Failed... Please check that you have permissions to write on disk" << endl;

			sl::DEPTH_FORMAT Depth_format;
			cv::imwrite("~/imgOut.bmp",  cv::Mat(512, 512, CV_32FC1, gray));

 */
