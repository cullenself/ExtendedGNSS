function [ gain ] = SatDirectivityGain( gainMat, offbore, phi  )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
% dirGain(i,j) = bore(-90+2(i-1)) , phi(10*(j-1))

lowoff = 2*floor(offbore/2);
highoff = 2*ceil(offbore/2);
lowphi = 10*floor(phi/10);
highphi = mod(10*ceil(phi/10),360);

lowi = (lowoff + 90)/2 + 1;
highi = (highoff + 90)/2 + 1;
lowj = lowphi/10 + 1;
highj = highphi/10 + 1;

b = inv([1 lowoff lowphi lowoff*lowphi; 1 lowoff highphi lowoff*highphi; 1 highoff lowphi highoff*lowphi; 1 highoff highphi highoff*highphi])' ... 
    * [1;offbore;phi;offbore*phi];

gain = b(1)*gainMat(lowi,lowj) + b(2)*gainMat(lowi,highj) + b(3)*gainMat(highi,lowj) + b(4)*gainMat(highi,highj);
end