function [dates, vals, errCd, rcdNo] = glriFileOpen(fileN)

delim = '\t';
headerL = 1;
reader  = '%s %f %s %f';
dateForm = 'yyyy-mm-dd HH:MM:SS';
% opens and parses glri data
fID = fileopen(fileN);
dat = textscan(fID,reader,'Delimiter',delim,'HeaderLines',headerL);

dates = datestr(dat{1},dateForm);
vals  = dat{2};
errCd = dat{3};
rcdNo = dat{4};



end

