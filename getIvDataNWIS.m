function [dates, vals, pCode] = getIvDataNWIS(siteID, pCode, startDT)

% instantaneous data retrieval
% --- variables
baseURL= 'http://waterservices.usgs.gov/nwis/iv/';
% agency siteID dateTime timezone value code
reader = '%s %f %s %s';
delim = '\t';
numHead = 25;
paramSt = 16;
dI    = 3;
% --- variables

if eq(nargin,2)
    startDT = '2010-10-01';
end

if eq(nargin,0)
    siteID = '04010500';
    pCode = {'00060'};
    startDT = '2010-10-01';
end


%% build call URL
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
    reader = [reader ' %s %s'];
end
URL = [URL '&format=rdb,&startDT=' startDT];


urlString = urlread(URL);

% get pCodes for headers
pLines = textscan(urlString,'%s',numCodes,...
    'Delimiter',delim,'HeaderLines',paramSt);
for i = 1:numCodes
    txt = pLines{1}{i};
    if lt(length(txt),15)
        numCodes = i-1;
        pCode = pCode(1:i-1);
        reader = reader(1:end-5);
        numHead = numHead-1;
        break
    end
    pCode{i} = txt(11:15);
end
data = textscan(urlString,reader,'Delimiter',delim,'HeaderLines',numHead+1);
time = data{dI};
vals = NaN(length(time),numCodes);
dates = datenum(time);
for j = 1:length(time);
    for i = 1:numCodes
        vals(j,i) = str2double(data{useI(i)}(j));
    end
    
end


end

