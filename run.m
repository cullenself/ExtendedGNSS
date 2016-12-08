clear; close all; clc;

addpath('./code');
addpath('./code/helpers');
addpath('./config');

rx.RXNoise = -4.5; % dB-Hz
rx.r = [3578600000,0,0]'; % m
rx.u = -rx.r/norm(rx.r); % unit vector representing rx antenna orientation
rx.Tsys = 190; % Kelvin ***double check this number
rx.RXGain = 5; % dB
gpsWeek = 1920;
gpsSec = 345680;

[ tracked, neededGain ] = observe( rx , gpsWeek , gpsSec );