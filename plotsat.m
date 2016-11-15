function [ ] = plotsat(plotMat,gpsWeek,elMaskRad)
% plotsat : Plot the calculated satellite positions or trajectories on an
%           elevation-azimuth plot.
%
%
% INPUTS
%
% plotMat ----- N-by-4 matrix arranged as follows:
%
%               [svID gpsSec elRad azRad;
%                svID gpsSec elRad azRad;
%		 ...
%                svID gpsSec elRad azRad]
% 
%               svId is the SV identification number, gpsSec is GPS time in
%               seconds of week, elRad and azRad are the SVs elevation and
%               azimuth angles, in radians.  
%
%
%               For positional plot make all gpsSec entries identical.  For
%               trajectory plot, format plotMat in batches with equivalent
%               number of SVs, each batch having a constant gpsSec.
%
% gpsWeek ----- GPS week number corresponding to the first row in plotMat.
%
% elMaskRad --- Elevation mask angle, in radians.  
%
%+------------------------------------------------------------------------------+
% References:
%
%
% Author: Todd Humphreys and an anonymous Cornell graduate student
%+==============================================================================+

% define physical constants
navConstants;

% find out from 'plotMat' if plotting satellite locations or trajectories in
% addition determine how many satellites are being tracked and how many
% samples for each satellite (# samples / satellite must always be equal)
gpsTime = plotMat(1,2);
i = 1;
t = gpsTime;
while ((i ~= size(plotMat,1)) & (t == gpsTime))
  i = i + 1;
  t = plotMat(i,2);
end
if (t == gpsTime)
  sats = i;
else
  sats = i - 1;
end;
Nsamples = size(plotMat,1) / sats;
SVs = plotMat(1:sats,1);
elevation = plotMat(:,3);
azimuth = plotMat(:,4);
% initialize polar - plotting area
figure;clf;
axis([-1.4 1.4 -1.1 1.1]);
axis('off');
axis(axis);
hold on;
% plot circular axis and labels
th = 0:pi/50:2*pi;
x = [ cos(th) .67.*cos(th) .33.*cos(th) ];
y = [ sin(th) .67.*sin(th) .33.*sin(th) ];
plot(x,y,'color','k');
text(1.1,0,'90','horizontalalignment','center');
text(0,1.1,'0','horizontalalignment','center');
text(-1.1,0,'270','horizontalalignment','center');
text(0,-1.1,'180','horizontalalignment','center'); 
% plot spoke axis and labels
th = (1:6)*2*pi/12;
x = [ -cos(th); cos(th) ];
y = [ -sin(th); sin(th) ];
plot(x,y,'color','k');
text(-.46,.93,'0','horizontalalignment','center');
text(-.30,.66,'30','horizontalalignment','center');
text(-.13,.36,'60','horizontalalignment','center');
text(.04,.07,'90','horizontalalignment','center');
% plot titles
if (Nsamples == 1)
  title('Satellite Position Plot');
  subtitle = sprintf('GPS time : %4d weeks, %.2f secs',gpsWeek,plotMat(1,2));
else
  title('Satellite Trajectory Plot');
  subtitle = sprintf('GPS time range : %.2f secs to %.2f secs', ...
                     plotMat(1,2),plotMat(size(plotMat,1),2));
  text(-1.6,1,'SVID/Last Position','color','r');
  text(-1.6,.9,'Above Mask Angle','color','k');
  text(-1.6,.8,'Below Mask Angle','color','b');
end
text(0,-1.3,subtitle,'horizontalalignment','center');
% plot trajectories (or positions) and label the last postion with the
% satellite SV id; in addition, last postions are in red, otherwise position
% elevations are yellow and negative elavations are blue
%
% loop through Nsamples
for s = 1:Nsamples		
  % plot each satellite location for that sample
  for sv = 1:sats
    % check if above or below mask
    if (elevation((s - 1) * sats + sv) < elMaskRad)
      elBelow = 1;
    else
      elBelow = 0;
    end
    % convert to plottable cartesian coordinates
    el = elevation((s - 1) * sats + sv);
    az = azimuth((s - 1) * sats + sv);
    x = (pi/2-abs(el))/(pi/2).*cos(az-pi/2);
    y = -1*(pi/2-abs(el))/(pi/2).*sin(az-pi/2);
    % check for final sample
    if (s == Nsamples)
      plot(x,y,'r*');
      text(x,y+.05,int2str(SVs(sv)), ...
           'horizontalalignment', ...
           'center','color','r');
    else
      % check for elevation above or below mask
      if (elBelow == 0)
        plot(x,y,'k.');
      else
        plot(x,y,'b.','markersize',.05);
      end
    end
  end
end

axis equal;
