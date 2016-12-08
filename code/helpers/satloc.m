function [rSvEcef, vSvEcef] = satloc(gpsWeek, gpsSec, sd)
% satloc : Return satellite location and velocity expressed in and relative to
% the ECEF reference frame.
%
%
% INPUTS
%
% gpsWeek ---- Week of true time at which SV location and velocity are
% desired.
%
% gpsSec ----- Seconds of week of true time at which SV location and velocity
% are desired.
%
% sd --------- Ephemeris structure array for a single SV. Let ii be the
% numerical identifier (PRN identifier) for the SV whose location
% is sought. Then sd = satdata(ii). sd has the following
% fields:
%
% SVID - satellite number
% health - satellite health flag (0 = healthy; otherwise unhealthy)
% we - week of ephemeris epoch (GPS week, unambiguous)
% te - time of ephemeris epoch (GPS seconds of week)
% wc - week of clock epoch (GPS week)
% tc - time of clock epoch (GPS seconds of week)
% e - eccentricity (unitless)
% sqrta - sqrt of orbit semi-major axis (m^1/2)
% omega0 - argument of perigee (rad.)
% M0 - mean anomaly at epoch (rad.)
% L0 - longitude of ascending node at beginning of week (rad.)
% i0 - inclination angle at epoch (rad.)
% dOdt - longitude rate (rad / sec.)
% dn - mean motion difference (rad / sec.)
% didt - inclination rate (rad / sec.)
% Cuc - cosine correction to argument of perigee (rad.)
% Cus - sine correction to argument of perigee (rad.)
% Crc - cosine correction to orbital radius (m)
% Crs - sine correction to orbital radius (m)
% Cic - cosine correction to inclination (rad.)
% Cis - sine correction to inclination (rad.)
% af0 - 0th order satellite clock correction (s)
% af1 - 1st order satellite clock correction (s / s)
% af2 - 2nd order satellite clock correction (s / s^2)
% TGD - group delay time for the satellite (s)
%
%
% OUTPUTS
%
% rSvEcef ---- Location of SV at desired time expressed in the ECEF reference
% frame (m).
%
% vSvEcef ---- Velocity of SV at desired time relative to the ECEF reference
% frame and expressed in the ECEF reference frame (m/s). NOTE:
% vSvEcef is NOT inertial velocity, e.g., for geostationary SVs
% vSvEcef = 0.
%
%+-----------------------------------------------------------------------+
% References: Remondi, Benjamin W., “Computing satellite 
%      velocity using the broadcast ephemeris,” GPS Solutions,
%      vol. 8 no. 3, 2004.
%   GPS Interface Specification IS-GPS-200
%
% Author: Matthew Self - mcs3779
%+=======================================================================+

%%% Basic Variables
GM = 3.986005e14;
OmegaE = 7.2921151467e-5;
sec_in_week = 604800;
%navConstants % load Navigational constants, specifically GM, OmegaE, and sec_in_week
%   The satloc fcn is run about 87000 times for a 10 minute
%   set of data, and navConstants takes an inordinate amount of time to
%   load a large set of variables when only a few are needed, so the
%   relevant variables have been declared as constants in this function. A
%   better solution could be to pass around a navConstant structure.
a = sd.sqrta^2; % find semimajor axis for convenience

%%% Find time from ephemeris update
dtime = [gpsSec gpsWeek] - [sd.te sd.we]; % subtract time in vector form
t_elapsed = dtime(1) + dtime(2)*sec_in_week; % change from vector to second count

%%% Mean, Eccentric, and True Anomalies
mean_motion = sqrt(GM/(a^3)) + sd.dn; % find corrected mean motion
anom_mean = sd.M0 + t_elapsed*(mean_motion); % find mean anomaly

anom_ecc = findEccentric(anom_mean, sd.e, 1e-14); % eccentric anomaly, use inlined function
anom_ecc_dot = mean_motion / ( 1 - sd.e*cos(anom_ecc)); % rate of eccentric anomaly change

anom_true = atan2(sqrt(1-sd.e^2) * sin(anom_ecc), cos(anom_ecc) - sd.e); % true anomaly
anom_true_dot = sin(anom_ecc)*anom_ecc_dot* (1 + sd.e*cos(anom_true)) / ((1-cos(anom_ecc)*sd.e) * sin(anom_true)); % rate of true anomaly change

%%% Argument of Latitude
arg_lat = sd.omega0 + anom_true; % argument of latitude first guess
arg_lat = sd.omega0 + sd.Cuc*cos(2*arg_lat) + sd.Cus*sin(2*arg_lat) + anom_true; % update using sin and cos correction factors
arg_lat_dot = anom_true_dot; % first guess of rate of change for argument of latitude

%%% Correction Factors
del_r = sd.Crc*cos(2*arg_lat) + sd.Crs*sin(2*arg_lat); % correction for orbital radius
del_i = sd.Cic*cos(2*arg_lat) + sd.Cis*sin(2*arg_lat); % correction for orbital inclination
del_r_dot = 2 *(sd.Crs*cos(2*arg_lat) - sd.Crc*sin(2*arg_lat)) *arg_lat_dot; % correction for rate of change for radius
del_i_dot = 2 *(sd.Cis*cos(2*arg_lat) - sd.Cic*sin(2*arg_lat)) *arg_lat_dot; % correction for rate of change for inclination
del_lat_dot = 2 *(sd.Cus*cos(2*arg_lat) - sd.Cuc*sin(2*arg_lat)) *arg_lat_dot; % correction for rate of change for argument of latitude

%%% Find and Correct Orbital Elements
r = a*(1-sd.e*cos(anom_ecc)) + del_r; % orbital radius plus correction
i = sd.i0 + sd.didt*t_elapsed + del_i; % orbital inclination plus change in inclination plus correction
arg_lat_dot = arg_lat_dot + del_lat_dot; % corrected argument of latitude
r_dot = a*sd.e*sin(anom_ecc)*anom_ecc_dot + del_r_dot; % rate of change for orbital radius
i_dot = sd.didt + del_i_dot; % rate of change for inclination
raan = sd.L0 + (sd.dOdt - OmegaE) * t_elapsed - OmegaE * sd.te; % Right Ascension of the Ascending Node
raan_dot = sd.dOdt - OmegaE; % rate of change for RAAN

%%% Find Position and Velocity in Orbital Plane
x_plane = r*cos(arg_lat); % position in the orbital plane
y_plane = r*sin(arg_lat);
x_dot_plane = r_dot*cos(arg_lat) - y_plane*arg_lat_dot; % velocity in the orbital plane
y_dot_plane = r_dot*sin(arg_lat) + x_plane*arg_lat_dot;

%%% Position into ECEF
x = x_plane*cos(raan) - y_plane*cos(i)*sin(raan); % transform planar position to ECEF position
y = x_plane*sin(raan) + y_plane*cos(i)*cos(raan);
z = y_plane*sin(i);
rSvEcef = [x y z]'; % output into column vector

%%% Velocity into ECEF
x_dot = x_dot_plane*cos(raan) - y_dot_plane*cos(i)*sin(raan) + y_plane*sin(i)*sin(raan)*i_dot - y*raan_dot; % transform planar velocity to ECEF velocity
y_dot = x_dot_plane*sin(raan) + y_dot_plane*cos(i)*cos(raan) - y_plane*sin(i)*cos(raan)*i_dot + x*raan_dot;
z_dot = y_dot_plane*sin(i) + y_plane*cos(i)*i_dot;
vSvEcef = [x_dot y_dot z_dot]'; % output into column vector

end
function [ecc_anom] = findEccentric(mean, e, tol)
% findEccentric : Return eccentric anomaly calculated from mean anomaly and 
%           eccentricty of orbit.
%
% INPUTS
%
% mean ---- Mean anomaly of SV (rad)
%
% e ----- Eccentricity of SV orbit (unitless)
%
% tol ---- Absolute tolerance of iteration to find eccentric anomaly; when
%           difference between values is less than this, the loop
%           terminates.
%
% OUTPUTS
%
% ecc_anom ---- Eccentric anomaly of SV (rad)
%
%
%+------------------------------------------------------------------------+
% References: GPS Interface Specification IS-GPS-200 
%
%
% Author: Matthew Self - mcs3779
%+========================================================================+
ecc_anom = mean + e*sin(mean);
ecc_guess = mean;
while (abs(ecc_anom - ecc_guess) > tol)
    ecc_guess = ecc_anom;
    ecc_anom = mean + e*sin(ecc_guess);
end
end