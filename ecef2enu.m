function [R] = ecef2enu(lat,lon)
% ecef2enu : Generate the rotation matrix used to express a vector written in
% ECEF coordinates as a vector written in local east, north, up
% (ENU) coordinates at the position defined by geodetic latitude
% and longitude.
%
% INPUTS
%
% lat ----- geodetic latitude in radians
%
% lon ----- longitude in radians
%
%
% OUTPUTS
%
% R ------- 3-by-3 rotation matrix that maps a vector v_ecef expressed in the
% ECEF reference frame to a vector v_enu expressed in the local
% east, north, up (vertical) reference frame as follows: v_enu =
% R*v_ecef.
%
%+--------------------------------------------------------------------+
% References: Misra & Enge 4.A.2
%
%
% Author: Matthew Self
%+====================================================================+
assert(abs(lat) <= pi/2,'Latitude must range from -pi/2 to pi/2!');
assert(abs(lon) <= pi,'Longitude must range from -pi to pi!');

R = r1(-lat)*r2(lon)*[[0 1 0];[0 0 1];[1 0 0]];
end
function [Q] = r1(x) % rotational matrices
Q = [[1,0,0];[0,cos(x),sin(x)];[0,-sin(x),cos(x)]];
end
function [Q] = r2(x)
Q = [[cos(x),0,-sin(x)];[0,1,0];[sin(x),0,cos(x)]];
end
function [Q] = r3(x)
Q = [[cos(x),sin(x),0];[-sin(x),cos(x),0];[0,0,1]];
end