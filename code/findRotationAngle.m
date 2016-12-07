function [phiDeg] = findRotationAngle( sat, gpsWeek, gpsSec )
% findRotationAngle - write this header

% convert time to days since solstice
dnum = gps2utc( gpsWeek, gpsSec );
theta = daysSinceEquinox(dnum) * 2 * pi / 365.25; % elevation of sun above equator, in radians
% find elevation of sun above orbital plane
beta = 23.4*sin(theta) - sat.i;
% find midnight position
u_midnight_eci = -rotate(theta, 3) * [1; 0; 0];
u_midnight_ecef = eci2ecef(u_midnight_eci,dnum);
% find angle from midnight
mu = acos(dot(u_midnight_ecef,sat.r)/(norm(u_midnight_ecef) * norm(sat.r))); % radians
% find yaw angle, igs
yaw_igs = atan2(-tan(beta),sin(mu));
Q_rtn_bf = rotate(yaw_igs,3);
Q_rtn_ecef = [ sat.r/norm(sat.r) ; cross(cross(sat.r,sat.v)/norm(cross(sat.r,sat.v)),sat.r/norm(sat.r)) ; cross(sat.r,sat.v)/norm(cross(sat.r,sat.v)) ];
% turn yaw angle to pointing angle
x_sv_ecef = Q_rtn_ecef' * Q_rtn_bf' * [-1; 0; 0];
% change pointing angle to phi
phiDeg = acosd(dot(x_sv_ecef,sat.rel)/(norm(x_sv_ecef) * norm(sat.rel))); % **Disambiguate**
end
