navDirectory = 'NavFiles';
EarthCutoff = ceil(atan2d(6371+500,20200+6371)); % deg
TXConfig;

cLight = 299792458;
% Fundamental GPS frequency, Hz
f0_fundamentalGPS = 10.23e6;
% GPS L1 frequency, Hz
fL1GPS = 154 * f0_fundamentalGPS;	
% GPS L1 wavelength, meters
lambdaGPSL1 = cLight / fL1GPS;	