function [siteName] = getSiteName(siteNumber)

% site number must be a string
rootDir   = 'D:\GRLI\';
keyFileN  = 'Sitekey.txt';
delim     = '\t';
numCol    = 1;
nmeCol    = 2;
f_boolean = @(x) ~isempty(x);

% grab data key
fID = fopen([rootDir 'OWCs\' keyFileN]);
dat = textscan(fID,'%s %s','Delimiter',delim);

fclose all;

useI   = strfind(dat{numCol},siteNumber);

useI   = cellfun(f_boolean,useI);
names = dat{nmeCol};
siteName = names{useI};
end