function writeDataNWIS

writeDir  = '/Users/jread/Documents/R/Metabolism-R/Data/';
startDT = '2011-03-01';
endDT   = '2011-11-01';
pCodes = {'00010','00300'};
siteID = '04165500';

%[dates, vals, pCode] = getIvDataNWIS(siteID, pCodes, startDT, endDT);


%% now pull in Ameriflux data
fID = fopen(['/Users/jread/Documents/R/Metabolism-R/Data/'...
    'Ameriflux_Ohio_Oak.csv']);

vals = textscan(fID,'%f %f %f','Delimiter',',','HeaderLines',1);
fclose all;

yyyy = vals{1};
DoY  = vals{2};
PAR  = vals{3};

rmvI = lt(PAR,0);
yyyy = yyyy(~rmvI);
DoY  = DoY(~rmvI);
AFdates = datenum(yyyy,0,0,1,0,0)+DoY;
PAR  = PAR(~rmvI);

%% now NWIS
[dates, vals] = getIvDataNWIS(siteID, pCodes, startDT, endDT);

rmvI = any(isnan(vals)')';
dates = dates(~rmvI);
snsrDO= vals(~rmvI,2);
snsrTemp = vals(~rmvI,1);

PAR = interp1(AFdates,PAR,dates);

dVec= datevec(dates);
yyyy = dVec(:,1);
DoY  = dates-datenum(yyyy,0,0);


dataFormat = '%1.0f,%2.4f,%2.2f,%2.2f,%2.5f,%2.1f\n';


fileName = [writeDir 'siteID_' siteID '.csv'];
fid = fopen(fileName,'w');
headers = 'Year,DoY,snsrDO,snsrTemp,PAR,Zmix\n';
fprintf(fid,headers);

zMix = 2;

for j = 1:length(yyyy)
    wrt = [yyyy(j),DoY(j),snsrDO(j),...
        snsrTemp(j),PAR(j),zMix];
    fprintf(fid,dataFormat,wrt);
end

fclose all;



end

