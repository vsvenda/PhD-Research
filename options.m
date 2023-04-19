% options
% Options for Load Flow (LF), State Estimation (SE) and Extended Kalman
% Filter (EKF) software
% Authors: Vanja Svenda, Alex Stankovic and Andrija Saric

basemva=100;         % Base power
accuracy_PF=1e-3;    % Accuracy for Power Flow (PF)
accel=1.8;           % for PF
maxiter_PF=100;      % Max number of iterations for PF
accuracy_SE=1e-6;    % Accuracy for State Estimation (SE)
maxiter_SE=50;       % Max number of iterations for SE

% observed network
in_file1='IEEE_14_bus_test_system'; opt0=1;  % Milano's book

% in_file1='IEEE_14_bus_test_system_Abur'; opt0=1;  % Abur's divergence example

% in_file1='IEEE_118_bus_test_system';

% in_file1='IEEE_300_bus_test_system'; opt0=2;

% in_file1='Serbia_test_system_1'; basemva=1;

%start_time=7350;    % Start time, in [sec]
%start_time=15350;    % Start time, in [sec]
start_time=1;    % Start time, in [sec]

% IEEE 14-bus
t_step_allign=1;   % Time step for state alligning, in [sec]
t_step_scada=5;   % Time step for SCADA, in [sec]
t_step_se=2;      % Time step for State Estimation (SE), in [sec]
number_of_steps=3600;  % Number of time steps

% IEEE 300-bus
% t_step_allign=10;   % Time step for state alligning, in [sec]
% t_step_scada=50;   % Time step for SCADA, in [sec]
% t_step_se=500;      % Time step for State Estimation (SE), in [sec]
% number_of_steps=8640;  % Number of time steps

sr_vr=0.25; % mean value for random measurement latency           %  Only for normal
st_dev=0.2; % standard deviation for random measurement latency   %  distribution
opt1=0;     % 0 or 1: No or print line flow solutions, respectively
opt2=2;     % 1 or 2: Uniformly distribution (rand), or Normal distribution (randn), respectively
opt3=2;     % 1 or 2: Daily profile with 24 point or much more points (obtained by daily_curves_to_more_points), respectively
opt4=2;     % Power Flow: 1. Flat Start, or 2. Solution from busdata
opt5=2;     % State estimation: 1. V,Theta,Pi,Qi,Pflow,Qflow,  or  2. V,Theta,Pi,Qi
opt6=0;     % 0 or 1: Reference bus does not or does exist, respectively.
% Measurement variances
measVariance(1)=1e-6;  % Voltage magnitude measurements
measVariance(2)=1e-3;  % Active power injection measurements
measVariance(3)=1e-3;  % Reactive power injection measurements
measVariance(4)=1e-3;  % Active power flow measurements
measVariance(5)=1e-3;  % Reactive power flow measurements
measVariance(6)=1e-6;  % Voltage angle measurements
measVariance(7)=1e-3;  % Current flow measurements

% Aburs' divergence example
% measVariance(1)=1e-6;  % Voltage magnitude measurements
% measVariance(2)=1e-6;  % Active power injection measurements
% measVariance(3)=1e-6;  % Reactive power injection measurements
% measVariance(4)=1e-6;  % Active power flow measurements
% measVariance(5)=1e-6;  % Reactive power flow measurements
% measVariance(6)=1e-6;  % Voltage angle measurements
% measVariance(7)=1e-6;  % Current flow measurements

