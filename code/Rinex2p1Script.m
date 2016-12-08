% Authors: Isaac Miller and Todd Humphreys

%read the ionosphere alpha parameters
noIonoParamsFlag = 0; % flag to denote whether iono info is available in the rinex file
iiPattern = [];
while(isempty(iiPattern))
  data = fgets(fid);
  iiPattern = strfind(data,'ION ALPHA');
  if ~isempty(strfind(data,'END OF HEADER'));
    noIonoParamsFlag = 1;
    break
  end
end

if ~noIonoParamsFlag
  alpha0 = str2num(data(3:14));
alpha1 = str2num(data(15:26));
alpha2 = str2num(data(27:38));
alpha3 = str2num(data(39:50));

%read the ionosphere beta parameters
iiPattern = [];
while(isempty(iiPattern))
  data = fgets(fid);
  iiPattern = strfind(data,'ION BETA');
end

beta0 = str2num(data(3:14));
beta1 = str2num(data(15:26));
beta2 = str2num(data(27:38));
beta3 = str2num(data(39:50));

%go to end of header
iiPattern = [];
while(isempty(iiPattern))
  data = fgets(fid);
  iiPattern = strfind(data,'END OF HEADER');
end
else
  alpha0 = [];
alpha1 = [];
alpha2 = [];
alpha3 = [];
beta0 = [];
beta1 = [];
beta2 = [];
beta3 = [];
end
%calculate the desired HMS time of ephemerides
eph_hr = floor(ephtime / 3600);
ephtime = mod(ephtime, 3600);
eph_min = floor(ephtime / 60);
ephtime = mod(ephtime, 60);
eph_sec = ephtime;


% Cycle through the ephemeris data.  Rinex 2.1 organizes data first by PRN and
% then by time.
sats = [];
recordsFoundFlag = 0;

while(1)
  %read ephem data until the first time-matched ephemeris data is found
  while (~feof(fid))
    data = fgetl(fid);
    cdata = zeros(10, 1);
    cdata(1) = str2num(data(1:2));
    cdata(2) = str2num(data(3:5));
    cdata(3) = str2num(data(6:8));
    cdata(4) = str2num(data(9:11));
    cdata(5) = str2num(data(12:14));
    cdata(6) = str2num(data(15:17));
    cdata(7) = str2num(data(18:22));
    cdata(8) = str2num(data(23:41));
    cdata(9) = str2num(data(42:60));
    cdata(10) = str2num(data(61:end));

    %Search for month roll-over case, where GPS day of ephemeris epoch has rolled over into
    %the first day of the next month, but current GPS time (ephday) is still at the previous month
    if (ephday) >= 28 && (ephday) <= 31 && cdata(4) == 1
        ephdayTemp = cdata(4) - 1;
    else
        ephdayTemp = ephday;
    end
    if (abs((cdata(4)*3600*24 + cdata(5)*3600 + cdata(6)*60 + cdata(7))-...
        (ephdayTemp*3600*24 + eph_hr*3600 + eph_min*60 + eph_sec)) <= promptWindow)
      %found a good record
      recordsFoundFlag = 1;
      break;
    end
    %didn't find a good record, read more lines
    for i = 1:7
      data = fgetl(fid);
    end
  end
  if (feof(fid))
    if(~recordsFoundFlag)
      %ran out of records
      error('Could not find matching ephemeris data.');
    else
      break; % break out of while(1) loop
    end
  end

  %found a good record if code gets here: create satellite structure
  sdata.SVID = cdata(1);
  sdata.af0 = cdata(8);
  sdata.af1 = cdata(9);
  sdata.af2 = cdata(10);
  
  %convert time of clock to GPS week and sec.
  yr = cdata(2);
  if (yr < 50)
    yr = yr + 2000;
  elseif (yr < 100)
    yr = yr + 1900;
  end
  mo = cdata(3);
  da = cdata(4);
  % rinex2p1 epoch time, equivalent to Toc or Time of Clock, is expressed in GPS
  % time for navigation files containing only GPS data.
  nTocGps = datenum(yr,mo,da,cdata(5),cdata(6),cdata(7));
  nref = datenum(1980,1,6,0,0,0);
  dn = nTocGps - nref;
  sdata.wc = floor(dn/7);
  sdata.tc = (dn - sdata.wc*7)*86400;
  
  %BROADCAST ORBIT - 1
  data = fgetl(fid);
  cdata = zeros(4, 1);
  cdata(1) = str2num(data(4:22));
  cdata(2) = str2num(data(23:41));
  cdata(3) = str2num(data(42:60));
  cdata(4) = str2num(data(61:end));
  sdata.Crs = cdata(2);
  sdata.dn = cdata(3);
  sdata.M0 = cdata(4);

  %BROADCAST ORBIT - 2
  data = fgetl(fid);
  cdata = zeros(4, 1);
  cdata(1) = str2num(data(4:22));
  cdata(2) = str2num(data(23:41));
  cdata(3) = str2num(data(42:60));
  cdata(4) = str2num(data(61:end));
  sdata.Cuc = cdata(1);
  sdata.e = cdata(2);
  sdata.Cus = cdata(3);
  sdata.sqrta = cdata(4);

  %BROADCAST ORBIT - 3
  data = fgetl(fid);
  cdata = zeros(4, 1);
  cdata(1) = str2num(data(4:22));
  cdata(2) = str2num(data(23:41));
  cdata(3) = str2num(data(42:60));
  cdata(4) = str2num(data(61:end));
  sdata.te = cdata(1);
  sdata.Cic = cdata(2);
  sdata.L0 = cdata(3);
  sdata.Cis = cdata(4);

  %BROADCAST ORBIT - 4
  data = fgetl(fid);
  cdata = zeros(4, 1);
  cdata(1) = str2num(data(4:22));
  cdata(2) = str2num(data(23:41));
  cdata(3) = str2num(data(42:60));
  cdata(4) = str2num(data(61:end));
  sdata.i0 = cdata(1);
  sdata.Crc = cdata(2);
  sdata.omega0 = cdata(3);
  sdata.dOdt = cdata(4);

  %BROADCAST ORBIT - 5
  data = fgetl(fid);
  cdata = zeros(4, 1);
  cdata(1) = str2num(data(4:22));
  cdata(2) = str2num(data(23:41));
  cdata(3) = str2num(data(42:60));
  cdata(4) = str2num(data(61:end));
  sdata.didt = cdata(1);
  sdata.we = cdata(3);

  %BROADCAST ORBIT - 6
  data = fgetl(fid);
  cdata = zeros(4, 1);
  cdata(1) = str2num(data(4:22));
  cdata(2) = str2num(data(23:41));
  cdata(3) = str2num(data(42:60));
  cdata(4) = str2num(data(61:end));
  sdata.health = cdata(2);
  sdata.TGD = cdata(3);

  %BROADCAST ORBIT - 7
  data = fgetl(fid);
  
  % NOTE: do not replace existing data if latest data is more than
  % 2*promptWindow from a valid data set.  This condition indicates a full day
  % wrap of the hour.
  if(sum(sats == sdata.SVID))
    dtime = (sdata.we - satdata(sdata.SVID).we)*7*86400 ... 
            + (sdata.te - satdata(sdata.SVID).te);
    if(dtime < 2*promptWindow)
      satdata(sdata.SVID) = sdata;
    end
  else
    %a new satellite
    sats = [sats; sdata.SVID];
    satdata(sdata.SVID) = sdata;
  end
  
end

forder = {'SVID','health', 'we', 'te', 'wc', 'tc', 'e', 'sqrta', 'omega0', ...
          'M0', 'L0', 'i0', 'dOdt', 'dn', 'didt', 'Cuc', 'Cus', 'Crc', 'Crs', ...
          'Cic', 'Cis', 'af0', 'af1', 'af2', 'TGD'};
satdata = orderfields(satdata, forder)';

ionodata = struct('alpha0', alpha0, 'alpha1', alpha1, ...
                  'alpha2', alpha2, 'alpha3', alpha3, 'beta0', beta0, ...
                  'beta1', beta1, 'beta2', beta2, 'beta3', beta3);
fclose(fid);