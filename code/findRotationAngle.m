function [phiDeg, offboreDeg] = findRotationAngle( sat, gpsWeek, gpsSec )
% findRotationAngle - write this header
e_h = cross(sat.r,sat.v)/(norm(cross(sat.r,sat.v)));
% convert time to days since solstice
dnum = gps2utc( gpsWeek, gpsSec );
r_sun_ecef = findSun(dnum);
e_sun_ecef = r_sun_ecef/norm(r_sun_ecef);
% find elevation of sun above orbital plane
beta = acos(dot(e_sun_ecef,e_h)); % radians
% find midnight position
u_midnight_ecef = -e_sun_ecef - (dot(-e_sun_ecef,e_h)*e_h);
% find angle from midnight
mu = acos(dot(u_midnight_ecef,sat.r)/(norm(u_midnight_ecef) * norm(sat.r))); % radians
% find yaw angle, igs
yaw_igs = atan2(-tan(beta),sin(mu)); % radians
Q_rtn_bf = rotate(yaw_igs,3);
Q_rtn_ecef = [ (sat.r/norm(sat.r))' ; (cross(e_h,sat.r/norm(sat.r)))' ; e_h' ];
% turn yaw angle to pointing angle
x_sv_ecef = Q_rtn_ecef' * Q_rtn_bf' * [-1; 0; 0];
y_sv_ecef = Q_rtn_ecef' * Q_rtn_bf' * [0; -1; 0];
z_sv_ecef = Q_rtn_ecef' * Q_rtn_bf' * [0; 0; 1];
% change pointing angle to phi
rel_xy = sat.rel - dot(sat.rel,z_sv_ecef)*z_sv_ecef/(norm(z_sv_ecef)^2);
phiDeg = acosd(dot(x_sv_ecef,rel_xy)/(norm(x_sv_ecef) * norm(rel_xy))); % **Disambiguate**
if dot(y_sv_ecef,rel_xy) < 0 % based on how Lockheed defines angles
    phiDeg = 360-phiDeg;
end
rel_zy = sat.rel - dot(sat.rel,x_sv_ecef)*x_sv_ecef/(norm(x_sv_ecef)^2);
offboreDeg = acosd(dot(z_sv_ecef,rel_zy)/(norm(z_sv_ecef) * norm(rel_zy)));
if dot(y_sv_ecef,rel_zy) > 0 % based on how Lockheed defines angles
    offboreDeg = -offboreDeg;
end
end
