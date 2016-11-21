function [elRad, azRad] = satelaz(rSvEcef,rRxEcef)
% satelaz : Compute satellite elevation and azimuth angles in radians with
% respect to receiver location.
%
%
% INPUTS
%
% rSvEcef ---- 3-by-1 satellite location in ECEF coordinates, in meters.
%
% rRxEcef ---- 3-by-1 receiver location in ECEF coordinates, in meters.
%
%
% OUTPUTS
%
% elRad ------ Satellite elevation angle (the angle between the WGS-84 
% local ENU tangent plane and the receiver-to-satellite vector),
% in radians.
%
% azRad ------ Satellite azimuth angle (the angle in the ENU tangent plane
% between North and the receiver-to-satellite vector projection,
% measured positive clockwise), in radians.
%
%+------------------------------------------------------------------------+
% References:
%
%
% Author: Matthew Self - mcs3779
%+========================================================================+
[rRx_lat, rRx_lon, ~] = ecef2lla(rRxEcef); % Find the reciever WGS-84 position
Q = ecef2enu(rRx_lat, rRx_lon); % Get the local transformation matrix
rSv_enu = Q*(rSvEcef-rRxEcef); % The relative position vector, turned into ENU space
elRad = asin(rSv_enu(3)/norm(rSv_enu)); % Up component gives elevation
azRad = atan2(rSv_enu(1),rSv_enu(2)); % East and North provide azimuth
end