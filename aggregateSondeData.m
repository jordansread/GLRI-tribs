function aggregateSondeData

rootDir = 'D:\GRLI\';
dataFldr= 'Oracle_Data_new\';
resultDir = '\\IGSARMEWFSAPB\Projects\QW Monitoring Team\GLRI toxics\Data Analysis\Data\Site Data\';
delim = '\t';
treatAsEmpty = {'na','NA','#VALUE!','#NAME?','None'};
availFiles = dir(fullfile([rootDir dataFldr '*.txt']));
params = {'00060','00010','63680','00095','00300','00400'};
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
for k = length(unSites)-15:-1:1
    try   [dates, vals, pCode] = getDataNWIS(unSites{k}, params);
        
        
        %% file write for station
        if gt(length(dates),1)
            fID = fopen([resultDir unSites{k} '_sonde.txt'],'w');
            fprintf(fID,'STAID\tDATES\tTIMES');
            for i = 1:length(pCode)
                fprintf(fID,['\tP' pCode{i}]);
            end
            fprintf(fID,'\r\n');
            
            
            for j = 1:length(dates)
                try dt = datenum(dates{j});
                    fprintf(fID,[unSites{k} '\t' datestr(dt,'yyyymmdd') ...
                        '\t' datestr(dt,'HHMM')]);
                    for i = 1:length(pCode)
                        fprintf(fID,['\t' char(vals{j,i})]);
                    end
                    fprintf(fID,'\r\n');
                catch issue
                    
                    
                end
            end
            fclose all;
        end
    catch
    end
    
    disp(['done with ' resultDir unSites{k} '_sonde.txt']);
end


end

