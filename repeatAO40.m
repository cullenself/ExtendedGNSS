clear; close all; clc;

addpath('./code');
addpath('./code/helpers');
addpath('./config');

rx.RXNoise = -4.5; % dB-Hz
rx.r = [60000,0,0]' * 1000; % m
rx.u = -rx.r/norm(rx.r); % unit vector representing rx antenna orientation
rx.Tsys = 190; % Kelvin ***double check this number
rx.RXGain = 4; % dB
gpsWeek = 1920;
gpsSec = 345680+5000;
thresh = 42;

satdata = retrieveNavigationData(gpsWeek,gpsSec,0,'./NavFiles');

[ tracked, neededGain ] = observe( rx , gpsWeek , gpsSec , satdata , thresh ); 