function plotFlowDur(pCode)


% plots flow duration curves with indicators for samples of X (X denoted by
% parameter coded [pCode])

figSize = 'large';
figRes  = struct('large','-r500','medium','-r200','small','-r100');
plotGen = 4;
axLw = 1.25;
mF = [.7 .85 .85];
mS = 4;
LW = 1.25;
fontS = 9;
fontN = 'Times New Roman';

figW = 8;
figH = 6;
lM   = 0.75;
rM   = 0.25;
tM   = 0.5;
bM   = 0.5;
wSpc = 0.75; % width space
hSpc = 1;  % vertical space

W    = (figW-lM-rM-wSpc)/2;
H    = (figH-tM-bM-hSpc)/2;


if eq(nargin,0)
    pCode = '00665';
end
% ** pCode is a string
if ~ischar(pCode)
    error('pCode input must be string');
end
yScale = 'log';
figDir  = 'D:\GRLI\Figures\';
figDir2 = 'M:\QW Monitoring Team\GLRI toxics\Data Analysis\Figures\';
rootDir = 'D:\GRLI\';
dataFldr= 'Oracle_Data\';
delim = '\t';
treatAsEmpty = {'na','NA','#VALUE!','#NAME?','None'};


availFiles = dir(fullfile([rootDir dataFldr '*' pCode '.txt']));

plotCnt = 0;
for k = 1:length(availFiles)
    
    if eq(plotCnt,0)
        % create figure
        close all
        fig_h = figure('Color','w','Units','inches','Position',[0 0 figW figH],...
            'PaperPosition',[0 0 figW figH]);
        movegui(fig_h,'center')
        ax_h = zeros(plotGen,1);
        ax_f = zeros(plotGen,1);
        ax_f(3) = axes('Parent',fig_h,'Position',[lM/figW bM/figH W/figW H/figH],...
            'LineWidth',axLw,'YTick',[],'XTick',[],'YLim',[0 1],'XLim',[0 1]); hold on;
        ax_h(3) = axes('Parent',fig_h,'Position',[lM/figW bM/figH W/figW H/figH],...
            'LineWidth',axLw,'YScale',yScale,'TickDir','out',...
            'fontName',fontN,'FontSize',fontS,'Box','on');
        hold on;
        ylabel('Discharge (ft^{3} s^{-1})','FontSize',fontS,'FontName',fontN)
        xlabel('Frequency of exceedance (%)','FontSize',fontS,'FontName',fontN)
        ax_h(4) = copyobj(ax_h(3),fig_h);
        set(ax_h(4),'Position',[(lM+wSpc+W)/figW bM/figH W/figW H/figH])
        ax_h(1) = copyobj(ax_h(3),fig_h);
        set(ax_h(1),'Position',[lM/figW (bM+hSpc+H)/figH W/figW H/figH])
        ax_h(2) = copyobj(ax_h(3),fig_h);
        set(ax_h(2),'Position',[(lM+wSpc+W)/figW (bM+hSpc+H)/figH W/figW H/figH])
        
    end
    
    plotCnt = plotCnt+1;
    fileN = availFiles(k).name;
    fID = fopen([rootDir dataFldr fileN]);
    dat   = textscan(fID,'%s %f %s','Delimiter',delim,...
        'treatAsEmpty',treatAsEmpty,'HeaderLines',1);
    fclose all;
    dates = datenum(dat{1},'yyyy-mm-dd');
    values= dat{2};
    [dates,unI] = unique(dates);
    values = values(unI);
    samplingInfo = regexp(fileN,'_','split');
    siteID = samplingInfo{1};
    disp(siteID)
    try    [datesQ, Q] = getDischargeNWIS(siteID);
    catch issue
        datesQ = NaN;
        Q = NaN;
        disp([num2str(siteID) ' is potentially bad news'])
    end
    nanI = isnan(Q) | lt(Q,0);
    datesQ = datesQ(~nanI);
    Q = Q(~nanI);
    [srtQ,srtI] = sort(Q);
    srtQ = wrev(srtQ);
    datesQ = datesQ(srtI);
    datesQ = wrev(datesQ);
    xNumz = linspace(0,100,length(srtQ));
    plot(xNumz,srtQ,'Parent',ax_h(plotCnt),'LineWidth',LW)
    % now...find the sampling locations
    
    N = 0;
    for j = 1:length(dates)
        plotI = eq(dates(j),datesQ);
        plot(xNumz(plotI),srtQ(plotI),'ro',...
            'MarkerSize',mS,'MarkerFaceColor',mF,...
            'Parent',ax_h(plotCnt),'LineWidth',.75)
       N = N + sum(plotI);
        
    end
    try siteName = GLRI_getSiteName(siteID);
    catch issue
        disp(['site name' siteID ' not found']);
        siteName = '';
    end
    title([siteName ' (' siteID '; ' 'N=' num2str(N) ')'],'Parent',ax_h(plotCnt));
    
    if eq(plotCnt,plotGen)
        plotCnt = 0;
        figTitle = [figDir 'FlowDur_0' num2str(ceil(k/plotGen))];
        disp(figTitle)
        print(figTitle,'-dpng',figRes.(figSize))
        copyfile([figTitle '.png'],figDir2)
    end
    
end

end

