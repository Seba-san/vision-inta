#include <opencv2/opencv.hpp>
#include <iostream>




        int main(int argc, char **argv){



			cv::Mat	depth = cv::imread(argv[1],CV_LOAD_IMAGE_ANYDEPTH );
        	cv::Mat dst,dst2;
        	        cv::normalize(depth, dst, 0, 1, cv::NORM_MINMAX);
        	        //cv::applyColorMap(dst,dst2,0); // hay que ver como cambiar el formato para que lo lea bien

        	        cv::imshow("test", dst);
        	        cv::waitKey(0);


        }
        //setMouseCallback("test", CallBackFunc, NULL);
        //cv::applyColorMap(dst,dst2,0);
