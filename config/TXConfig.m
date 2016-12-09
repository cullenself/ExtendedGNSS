% TXConfig - contains all the necessary satellite transmitter information
% used to calculate the specific power output of each individual satellite
validSVIDs = [2,5,7,11,12,13,14,15,16,17,18,19,20,21,22,23,28,29,31];

assumedPowerOut = 30; %dBW - Results from GPS AMSAT OSCAR-40

SatPowerOut(13) = assumedPowerOut; % SVN 43
SatGainCF(13) = -0.9; % dB

SatPowerOut(11) = assumedPowerOut; % SVN 46
SatGainCF(11) = -1; % dB

SatPowerOut(20) = assumedPowerOut; % SVN 51
SatGainCF(20) = -0.7; % dB

SatPowerOut(28) = assumedPowerOut; % SVN 44
SatGainCF(28) = -1.1; % dB

SatPowerOut(14) = assumedPowerOut; % SVN 41
SatGainCF(14) = -0.9; % dB

SatPowerOut(18) = assumedPowerOut; % SVN 54
SatGainCF(18) = -0.8; % dB

SatPowerOut(16) = assumedPowerOut; % SVN 56
SatGainCF(16) = -0.7; % dB

SatPowerOut(21) = assumedPowerOut; % SVN 45
SatGainCF(21) = -1.1; % dB

SatPowerOut(22) = assumedPowerOut; % SVN 47
SatGainCF(22) = -1.3; % dB

SatPowerOut(19) = assumedPowerOut; % SVN 59
SatGainCF(19) = -1.3; % dB

SatPowerOut(23) = assumedPowerOut; % SVN 60
SatGainCF(23) = -1.3; % dB

SatPowerOut(2) = assumedPowerOut; % SVN 61
SatGainCF(2) = -1.2; % dB

SatPowerOut(17) = assumedPowerOut; % SVN 53
SatGainCF(17) = -1.4; % dB

SatPowerOut(31) = assumedPowerOut; % SVN 52
SatGainCF(31) = -1.2; % dB

SatPowerOut(12) = assumedPowerOut; % SVN 58
SatGainCF(12) = -1.3; % dB

SatPowerOut(15) = assumedPowerOut; % SVN 55
SatGainCF(15) = -1.3; % dB

SatPowerOut(29) = assumedPowerOut; % SVN 57
SatGainCF(29) = -1.3; % dB

SatPowerOut(7) = assumedPowerOut; % SVN 48
SatGainCF(7) = -1.4; % dB

SatPowerOut(5) = assumedPowerOut; % SVN 50
SatGainCF(5) = -1.3; % dB

load('../Antenna Data/test'); % imports dirGain matrix ***eventually make 3d with k for svid
% dirGain(i,j) = bore(-90+2(i-1)) , phi(10*(j-1))