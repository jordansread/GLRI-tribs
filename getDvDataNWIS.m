function [dates, vals, pCode] = getDvDataNWIS(siteID, pCode, startDT)

% this code is really bad and should be fixed.
% instantaneous data retrieval
% --- variables
baseURL= 'http://waterservices.usgs.gov/nwis/dv/';
reader = '%s %f %s %s %s';
delim = '\t';
numHead = 24;
paramSt = 16;
dI    = 3;
wtrI  = 4;
% --- variables

if lt(nargin,5)
    statCd = '00003';
end

if eq(nargin,2)
    startDT = '2010-10-01';
    endDT = datestr(now,'yyyy-mm-dd');
end

if eq(nargin,0)
    siteID = '04010500';
    pCode = {'00060'};
    startDT = '2010-10-01';
    endDT = datestr(now,'yyyy-mm-dd');
end



URL = [baseURL '?sites=' siteID];

useI = 5;
if iscell(pCode)
    URL = [URL '&parametercd=' pCode{1}];
    reader = [reader ' %s %s'];
    for i = 2:length(pCode)
        URL = [URL ',' pCode{i}];
        reader = [reader ' %s %s'];
        useI =[useI 5+(i-1)*2];
    end
    numHead = numHead+length(pCode);
    numCodes = length(pCode);
else
    URL = [URL '&parameterCd=' pCode];
    numCodes = 1;
    pCode = {pCode};
end
URL = [URL '&format=rdb,&startDT=' startDT];


urlString = urlread(URL);


data = textscan(urlString,reader,'Delimiter',delim,'HeaderLines',numHead+2);
dates = datenum(data{dI},'yyyy-mm-dd');
vals = NaN(length(dates),1);
for j = 1:length(dates);
    for i = 1:numCodes
        vals(j) = str2double(data{wtrI}(j));
    end
end


end

