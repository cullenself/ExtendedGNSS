function [satdata, ionodata] = ...
      retrieveNavigationData(gpsWeek,gpsSec,ephemHourOffset,navDirectory)
% retrieveNavigationData : Retrieve from the NOAA CORS data repository the GPS
%                          navigation data (i.e., ephemeris data) that apply
%                          at the specified time.
%
%
% INPUTS
%
% gpsWeek ------------- GPS week number.
%
% gpsSec -------------- GPS second of week.  
%
% ephemHourOffset ----- Offset to the input ephemeris epoch, in hours.  The
%                       target ephemeris epoch will be tTarget = tInput +
%                       ephemHourOffset, where tInput is the time specified by
%                       the inputs gpsWeek and gpsSec, in hours.  The
%                       ephemeris retrieval code will select the most recent
%                       ephemeris whose epoch is within 2 hours of tTarget.
%                       Typically, one simply sets ephemHourOffset = 0.
%
% navDirectory -------- Path to directory where the RINEX navigation file 
%                       retrieved from the CORS directory will be stored.
%                       Leave blank to store in navsol/navFiles (if on
%                       path) or in working directory (otherwise).
%
%
% OUTPUTS
% 
% satdata ---- Ephemeris structure array with the following fields:
%
%       SVID - satellite number
%       health - satellite health flag (0 = healthy; otherwise unhealthy)
%       we - week of ephemeris epoch (GPS week, unambiguous)
%       te - time of ephemeris epoch (GPS seconds of week)
%       wc - week of clock epoch (GPS week)
%       tc - time of clock epoch (GPS seconds of week)
%       e - eccentricity (unitless)
%       sqrta - sqrt of orbit semi-major axis (m^1/2)
%       omega0 - argument of perigee (rad.)
%       M0 - mean anomaly at epoch (rad.)
%       L0 - longitude of ascending node at beginning of week (rad.)
%       i0 - inclination angle at epoch (rad.)
%       dOdt - longitude rate (rad / sec.)
%       dn - mean motion difference (rad / sec.)
%       didt - inclination rate (rad / sec.)
%       Cuc - cosine correction to argument of perigee (rad.)
%       Cus - sine correction to argument of perigee (rad.)
%       Crc - cosine correction to orbital radius (m)
%       Crs - sine correction to orbital radius (m)
%       Cic - cosine correction to inclination (rad.)
%       Cis - sine correction to inclination (rad.)
%       af0 - 0th order satellite clock correction (s)
%       af1 - 1st order satellite clock correction (s / s)
%       af2 - 2nd order satellite clock correction (s / s^2)
%       TGD - group delay time for the satellite (s)
%
% ionodata -- Ionospheric data structure array with the following fields:
%
%       alpha0, alpha1, alpha2, alpha3 - power series expansion coefficients
%           for amplitude of ionospheric TEC
%
%       beta0, beta1, beta2, beta3 - power series expansion coefficients for
%            period of ionospheric plasma density cycle
%
%+------------------------------------------------------------------------------+
% References: 
%
%
% Author: Todd Humphreys
%+==============================================================================+
  
% Choose default navDirectory if none specified
if(nargin == 3)
  % If './navFiles' exists or if navsol is in path and navsol/navFiles exists,
  % then the default navDirectory is 'navsol/navFiles'; otherwise, use current
  % directory.
  if(exist('./navFiles'))
    navDirectory = './navFiles';
  else
    navDirectory = '.';
    p = strsplit(path,pathsep);
    for ii = 1:length(p)
      if(~isempty(strfind(p{ii},'navsol')))
        navDirectory = fullfile(p{ii},'navFiles');
        if(~exist(navDirectory))
          navDirectory = '.'
        end
        break;
      end
    end
  end
end

% Get UTC time corresponding to gpsWeek and gpsSec.
tFps = gps2utc(gpsWeek,gpsSec(1)) + ephemHourOffset/24;
dv = datevec(tFps);
tFpsYear = dv(1); tFpsHour = dv(4); tFpsMin = dv(5);
t0Year = datenum(tFpsYear,1,1,0,0,0);
doy = floor(tFps - t0Year) + 1;
fn = sprintf('brdc%03d0.%02dn',doy,mod(tFpsYear,100));
s = sprintf('ftp://www.ngs.noaa.gov/cors/rinex/%4d/%03d/',tFpsYear,doy); 
s = [s fn];
% Download the file if not already present
fid = fopen([navDirectory '/' fn]);
if(fid == -1)
  try
    disp(['Retrieving RINEX broadcast ephemeris file ' fn ' from NGS ftp site ...']);
    fnn = [navDirectory '/' fn '.gz'];
    syscmd = sprintf('cd %s && wget %s.gz', navDirectory, s);
    system(syscmd);
    gunzip(fnn);
    delete(fnn);
    disp('Navigation file successfully retrieved.');
  catch mException
    try
      urlwrite([s '.gz'],fnn);
      gunzip(fnn);
      delete(fnn);
      disp('Navigation file successfully retrieved.');
    catch mException
      disp('');
      disp('Failed to retrieve navigation file.');
      disp(['Error description: ' mException.identifier]);
      disp('You may wish to download the file manually; it can be found at:');
      disp([s '.gz']);
      disp(['After downloading, unzip the file using the Matlab gunzip command, ' ...
            'then place in the directory ' navDirectory ' and run your code again.']);
      error(mException.message);
    end
  end
else
  fclose(fid);
end
fname = [navDirectory '/' fn];
% Find the nearest past 2-hour ephemeris epoch
ephemHour = floor(tFpsHour/2)*2;
ephemDay = dv(3);
[satdata, ionodata] = getephem(fname,ephemDay,ephemHour*3600);