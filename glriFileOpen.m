function [dates, vals, errCd, rcdNo] = glriFileOpen(fileN)

delim = '\t';
headerL = 1;
reader  = '%s %f %s %f';
dateForm = 'yyyy-mm-dd HH:MM:SS';
% opens and parses glri data
fID = fopen(fileN);
dat = textscan(fID,reader,'Delimiter',delim,'HeaderLines',headerL);

dates = datenum(dat{1},dateForm);
vals  = dat{2};
errCdS= dat{3};
Esti  = strcmp(errCdS,'E');
Deti  = strcmp(errCdS,'<');
errCd = NaN(length(vals),1);
errCd(Esti) = 1;    % error code for estimate
errCd(Deti) = 0;    % error code for detection limit

rcdNo = dat{4};

fclose all;
end

