antenna.r = [35786000,0,0];
antenna.u = -antenna.r/norm(antenna.r);

% Read in a certain day
satdata = getephem
% break out into positions and pointing angles
for i in satdata
    trans(i).r = satloc(satdata(i));
    trans(i).u = -trans(i).r/norm(trans(i).r);
end

% relative position
trans(i).rel = 
% off bore angle
trans(i).offbore = arccosd(dot(trans(i).rel,trans(i).u)/(norm(trans(i).rel)*trans(i).u)); % in degrees

if (trans(i).offbore < earthcutoff)
    trans(i).blocked = 1;
end

% trim the list
% calc power
% calc c/no