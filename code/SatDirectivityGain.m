function [ gain ] = SatDirectivityGain( gainMat, offbore, phi  )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
% dirGain(i,j) = bore(-90+2(i-1)) , phi(10*(j-1))

lowoff = rem(2*floor(offbore/2),90);
highoff = rem(2*ceil(offbore/2),90);
lowphi = rem(10*floor(phi/10),360);
highphi = rem(10*ceil(phi/10),360);

lowi = (lowoff + 90)/2 + 1;
highi = (highoff + 90)/2 + 1;
lowj = lowphi/10 + 1;
highj = highphi/10 + 1;

if (lowi == highi)
    if (lowj == highj)
        gain = gainMat(lowi,lowj);
    else
        gain = (phi-highphi)*gainMat(lowi,lowj)/10 + (phi-lowphi)*gainMat(lowi,highj)/10;
    end
elseif (lowj == highj)
    gain = abs(offbore-highoff)*gainMat(lowi,lowj)/2 + abs(offbore-lowoff)*gainMat(highi,lowj)/2;
else

    b = inv([1 lowoff lowphi lowoff*lowphi; 1 lowoff highphi lowoff*highphi; 1 highoff lowphi highoff*lowphi; 1 highoff highphi highoff*highphi])' ... 
    * [1;offbore;phi;offbore*phi];

    gain = b(1)*gainMat(lowi,lowj) + b(2)*gainMat(lowi,highj) + b(3)*gainMat(highi,lowj) + b(4)*gainMat(highi,highj);
end
end