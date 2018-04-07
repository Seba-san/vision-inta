% Experiment setup file for the CAS Robot Navigation Toolbox
% Date: 21.12.03
% Author: Kai Arras, CAS-KTH
% Description: The atrium data set has been recorded by Patric Jensfelt
% in the KTH main building, Stockholm. The robot is a Nomad Scout with
% a forward looking SICK LMS200. Scan frequency is quite high, greater
% than the frequency of the encoder measurements. The data set is
% challenging as the environment is highly dynamic.
% In this experiment, the scans are downsampled by a factor of five
% for accelerating purposes.


% ----- Robot Model ----- %
% robot name
params.robot.name = 'Marce';
% robot class name
params.robot.class = 'robotdd';
% robot form type (see help drawrobot)
params.robot.formtype = 4; % El dibujo del robot -.-
% robot kinematics
params.robot.b  = 1;      % robot wheelbase in [m]
params.robot.rl = 1;%36e-3;%48e-3;      % left wheel radius in [m]
params.robot.rr = 1;%36e-3;%48e-3;      % right wheel radius in [m]
% initial robot start pose and pose covariance
% params.sensor1.kl = 0.1;     % error growth factor for left wheel in [1/m]
% params.sensor1.kr = 0.1;     % error growth factor for right wheel in [1/m]

params.robot.x = zeros(3,1);
params.robot.C =0.01*eye(3);

% ----- Map File for Localization ----- %
% define a priori map file, '' for slam experiments
params.mapfile = '';

% Parametros obligatorios:
%name, class,formtype [0 a 5], x, C ; The fields params.robot.x and params.robot.C are a 3 × 1 vector and a 3 × 3
% matrix, respectively. They denote the initial pose and pose covariance from
% which the robot will start in an experiment. The pose vector x has elements
% x, y, ? in units [m], [m], [rad]. Note that C is a covariance matrix and must not
% be a negative definite matrix.


% ----- Sensor 1 Model and File Settings ----- %
% sensor name
params.sensor1.name = 'Wheel encoders';
% full file name and label to look for
params.sensor1.datafile = 'C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab\Registros_corridas\ENC1.txt';
params.sensor1.label = 'E';
% params.sensor1.tdownsample = 20; % opcional
% params.sensor1.sdownsample =1;% opcional
% is information in file relative 0: no, 1: yes
params.sensor1.isrelative = 1;
% index string
params.sensor1.indexstr = '1,2,4,3';
% non-systematic odometry error model
params.sensor1.kl = 1e-20;     % error growth factor for left wheel in [1/m]
params.sensor1.kr = 1e-20;     % error growth factor for right wheel in [1/m]






% ----- Sensor 1 Model and File Settings ----- %
% sensor name
params.sensor2.name = 'ZED camera HD';
% full file name and label to look for
params.sensor2.datafile ='C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab\Registros_corridas\Data.txt';%'Data1.txt';%'C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab\Registros_corridas\Data.txt'; % poner la direccion de los datos
params.sensor2.label = 'T'; % La inicial de los datos
% temporal and spatial downsampling factor
% params.sensor2.tdownsample = 1; % opcional
% params.sensor2.sdownsample =20;% opcional
% is information in file relative 0: no, 1: yes
% params.sensor1.isrelative = 1;
% index string
params.sensor2.indexstr = '1,2,3,4:2:end,5:2:end'; % poner la primera en la primera, la 2da en la 2da, 3era en 3era, hacer un vector con los datos de la 4 de 2 en 2 hasta el final, hacer otro vector de las variables de la 5ta posicion leidos de 2 en dos hasta el final.
% maximal perception radius of sensor in [m]
% params.sensor2.rs = 20.0;
% angular resolution in [rad]
% params.sensor2.anglereso = 1e-3;
% constant range uncertainty in [m]
% params.sensor2.stdrho = 0.1;
% robot-to-sensor transform expressed in the
% robot frame with units [m] [m] [rad]
params.sensor2.xs = [0;0;-pi/2];
params.sensor2.extractionfnc ='extractbeacons';%'extractbeacons' 'extractlines'

 %----- Master Sensor Setting ----- %
% define master sensor
params.mastersensid = 2;


% ----- Feature Extraction ----- %
% jump distance for beacon segmentation
params.beaconthreshdist =0.7; % in [m] % con 0.7 anda bastante bien
% beacons which are farer away than rs-ignoredist are ignored
params.ignoredist = 0.6; % in [m]
% minimal nof raw points on reflector in order to be valid
params.minnpoints = 1;
% constant beacon covariance matrix
params.Cb =[0.026 0;0 0.026];%[0.05 0;0 0.001];%0.026*eye(2); % Esta matriz de covariancia, no tendria que tener ambos coeficientes iguales, ya que en "y" tiene menos incerteza que en "x"
% ----- Data Association ----- %
% significance level for NNSF matching
params.alpha = 0.999;




% % ----- Feature Extraction ----- %
% % size of sliding window
% params.windowsize = 3; % in number of points
% % threshold on model fidelity
% params.threshfidel = 0.2;
% % significance level for line fusion
% params.fusealpha = 0.9999; % between 0 and 1
% % minimal length a segment must have to be accepted
% params.minlength = 0.75; % in [m]
% % heuristic compensation factors for raw data correlations
% params.compensa = 1*pi/180; % in [rad]
% params.compensr = 0.01; % in [m]
% % are the scans cyclic?
% params.cyclic = 0; % 0: non-cyclic or 1: cyclic
% % ----- Data Association ----- %
% % significance level for NNSF matching
% params.alpha = 0.999;
% % ----- Slam ----- %
% % optional axis vector for global map figure. Useful with infinite lines
% % params.axisvec = [-14 24 -19 13];
%v=[.30 .30]'
%v'*inv(2*0.026*eye(2))*v;

%C=[0.05 0;0 0.0001]
