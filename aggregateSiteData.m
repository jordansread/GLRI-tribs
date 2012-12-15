function aggregateSiteData

rootDir = 'D:\GRLI\';
dataFldr= 'Oracle_Data_new\';
resultDir = '\\IGSARMEWFSAPB\Projects\QW Monitoring Team\GLRI toxics\Data Analysis\Data\Site Data\';
delim = '\t';
treatAsEmpty = {'na','NA','#VALUE!','#NAME?','None'};
availFiles = dir(fullfile([rootDir dataFldr '*.txt']));
params = {'00940','00530','00665','50468','31616',...
    '00608','00613','00631','00671','62855','80154'};
params = sort(params);

% now loop through files and store unique file names

fileN = regexp([availFiles.name],'.txt','split');
fileN = fileN(1:length(availFiles)); % truncate off end

% now split into sites and param numbers
sites = regexp(fileN,'_','split');
siteN = cell(length(sites),1);
for j = 1:length(sites)
    siteN{j} = sites{j}{1};
end
% unique site names
unSites = unique(siteN);


%% now, for each site, loop through list of parameters, and print to file
for k = 1:length(unSites)
    dates = [];
    useP = true(length(params),1);
    for p = 1:length(params)
        pCd = params{p};
        fileN = [unSites{k} '_' pCd '.txt'];
        % try/catch?
        fID = fopen([rootDir dataFldr fileN]);
        if gt(fID,0)
            dat   = textscan(fID,'%s %f %s %f','Delimiter',delim,...
                'treatAsEmpty',treatAsEmpty,'HeaderLines',1);
            fclose all;
            dates = [dates; datenum(dat{1},'yyyy-mm-dd HH:MM')];
        else
            useP(p) = false;
        end
        
    end
    % now we have a list of total dates
    unDates = unique(dates);
    valMatrix = cell(length(unDates),length(useP));
    rmkMatrix = cell(length(unDates),length(useP));
    records   = NaN(length(unDates),1);
    
    for p = 1:length(params)
        if useP(p)
            pCd = params{p};
            fileN = [unSites{k} '_' pCd '.txt'];
            % try/catch?
            fID = fopen([rootDir dataFldr fileN]);
            dat   = textscan(fID,'%s %f %s %f','Delimiter',delim,...
                'treatAsEmpty',treatAsEmpty,'HeaderLines',1);
            fclose all;
            dates = datenum(dat{1},'yyyy-mm-dd HH:MM');
            vals = dat{2};
            rmk  = dat{3};
            record = dat{4};
            for i = 1:length(vals)
                useI = eq(unDates,dates(i));
                valMatrix{useI,p} = vals(i);
                rmkMatrix{useI,p} = rmk{i};
                if ~isnan(records(useI)) && ne(records(useI),record(i))
                    disp(['record does not match expected'])
                end
                records(useI) = record(i);
            end
            % need to remove p values that are not used.
        end
    end
    %% file write for station
    paramsWrite = params(useP);
    valMatrix = valMatrix(:,useP);
    rmkMatrix = rmkMatrix(:,useP);
    fID = fopen([resultDir unSites{k} '_samples.txt'],'w');
    fprintf(fID,'STAID\tDATES\tTIMES\tSAMPL');
    for i = 1:length(paramsWrite)
        fprintf(fID,['\tR' paramsWrite{i} '\tP' paramsWrite{i}]);
    end
    fprintf(fID,'\r\n');
    
    
    for j = 1:length(dates)
        fprintf(fID,[unSites{k} '\t' datestr(dates(j),'yyyymmdd') ...
            '\t' datestr(dates(j),'HHMM') ...
            '\t' num2str(record(j))]);
        for i = 1:length(paramsWrite)
            rmk = rmkMatrix{j,i};
            val = sprintf('%5.5g',valMatrix{j,i});
            if strcmp(rmk,'NaN')
                rmk = [];
            end
            fprintf(fID,['\t' rmk '\t' val]);
        end
        fprintf(fID,'\r\n');
    end
    fclose all;
end


end

