function plotCompareSamples


rootDir = '/Volumes/projects/QW Monitoring Team/GLRI toxics/Data Analysis/';
sampleKeyFldr = 'OWCs/OWCs from autosamplers vs EWIs/';
dataFldr= 'Oracle_Data/';
figFldr = 'Figures/';
yNum = 4;


%% get parameters for analysis
fID = fopen([rootDir sampleKeyFldr 'compareParamList.txt']);
dat = textscan(fID,'%s');
params = regexprep(dat{1},'P','');

%% get sites and times
fID = fopen([rootDir sampleKeyFldr 'EWIvsAutoInfo.txt']);
dat = textscan(fID,'%s %s %s','Delimiter','\t','HeaderLines',1);
siteID = dat{1};    % need to add 0 to front
autoDt = datenum(dat{2},'yyyy-mm-dd HH:MM:SS');     % autosampler date
EWI_Dt = datenum(dat{3},'yyyy-mm-dd HH:MM:SS');     % autosampler date
fclose all;

% for each site, create plot
unSites = unique(siteID);
for k = 1:length(unSites)
    useSi = strcmp(siteID,unSites{k});  % these are the site indexes to use
    numSmpl = sum(useSi);   % number of overlapping dates to compare
    rmkCode = NaN(numSmpl, length(params), 2);      % one for auto, one EWI
    valArray = NaN(numSmpl, length(params), 2);
    % -- now look for the values in the files --
    site = ['0' unSites{k}];
    toss = false(length(params),1);
    for p = 1:length(params)
        fileN = [rootDir dataFldr site '_' params{p} '.txt'];
        fID = fopen(fileN);
        
        if gt(fID,0)
            [dates, vals, errCd] = glriFileOpen(fileN);
            useAuto = autoDt(useSi);
            use_EWI = EWI_Dt(useSi);
            for d = 1:numSmpl
                d1 = useAuto(d);
                d2 = use_EWI(d);
                useI = eq(dates,d1);
                if any(useI)
                    rmkCode(d,p,1) = errCd(useI);
                    valArray(d,p,1) = vals(useI);
                end
                
                useI = eq(dates,d2);
                if any (useI)
                    rmkCode(d,p,2) = errCd(useI);
                    valArray(d,p,2) = vals(useI);
                end
            end 
            if all(isnan(valArray(:,p,2)))
                toss(p) = true;
            end
        else
            toss(p) = true;
        end
    end
    % for each site, write figure
    % get final list of parameters for plot (sort by (.,.,2))
    rmvI = toss;
    totlP = sum(eq(rmvI,false));
    numX = ceil(totlP/yNum);
    close all;
    [fig_h,ax_h] = createPanelPlot(numX,yNum, 15, 6);
    cnt = 0;
    for i = 1:length(rmvI)
        if ~rmvI(i)
            cnt = cnt+1;
            useI = ~isnan(valArray(:,i,2));
            set(ax_h(cnt),'XLim',[0 sum(useI)]);
            ylabel(['P' params{i}],'Parent',ax_h(cnt))
            for d = 1:numSmpl
                if useI(d)
                    pl = plot(d-.5-.15,valArray(d,i,1),'bo','Parent',ax_h(cnt));
                    if eq(rmkCode(d,i,1),1) || eq(rmkCode(d,i,1),0)
                        set(pl,'MarkerEdgeColor',[.6 .6 .6]);
                    end
                    pl = plot(d-.5+.15,valArray(d,i,2),'rd','Parent',ax_h(cnt));
                    if eq(rmkCode(d,i,2),1) || eq(rmkCode(d,i,2),0)
                        set(pl,'MarkerEdgeColor',[.6 .6 .6]);
                    end
                end
            end
            
        end
    end
    
    numGen = numX*yNum;
    for i = numGen:-1:totlP+1
        delete(ax_h(i));
    end
    if ne(cnt,0)
        print([rootDir figFldr site '_EWIvsAuto'], '-dpng','-r400')
    end
end
end

