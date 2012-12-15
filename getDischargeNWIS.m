function [dates, Q] = getDischargeNWIS(siteID, pCode, startDT, endDT, statCd)

% --- variables
baseURL= 'http://waterservices.usgs.gov/usa/nwis/dv';
dateForm = 'yyyy-mm-dd';
reader = '%s %f %s %s %s';
delim = '\t';
numHead = 26;
dI    = 3;
qI    = 4;
% --- variables

if lt(nargin,5)
    statCd = '00003';
end

if eq(nargin,1)
    pCode = '00060';
    startDT = '2010-10-01';
    endDT = datestr(now,'yyyy-mm-dd');
end

if eq(nargin,0)
    siteID = '04010500';
    pCode = '00060';
    startDT = '2010-10-01';
    endDT = datestr(now,'yyyy-mm-dd');
end



URL = [baseURL '?site_no=' siteID '&ParameterCd=' pCode ...
    '&StatCd=' statCd '&format=rdb,1.0,' '&startDT=' startDT '&endDT=' endDT];


urlString = urlread(URL);

data = textscan(urlString,reader,'Delimiter',delim,'HeaderLines',numHead);

dates = datenum(data{dI},dateForm);
Q     = str2double(data{qI});


end

