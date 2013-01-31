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
distPcode = '00060';
startDT = '2010-10-01';
yScale = 'log';
figDir = 'I:\GLRI Tribs\Figures\';
rootDir = ['/Volumes/projects/QW Monitoring Team/GLRI toxics/'...
    'Data Analysis/'];
%sondFldr= 'Data\Site Data\'; 
dataFldr= 'Oracle_data/';
delim = '\t';
treatAsEmpty = {'na','NA','#VALUE!','#NAME?','None'};
combineSID = {'04157000' '04157005'; '04193500' '04193490'};

siteIDs = {'04024000' '04027000' '04040000' '04067500' '04059500' ...
    '040851385' '04085427' '04087170' '04092750' '04095090' '04101500' ...
    '04108660' '04119400' '04121970' '04137500' '04142000' '04157000' ...
    '04165500' '04166500' '04174500' '04176500' '04193500' '04195500' ...
    '04200500' '04199500' '04208000' '04213500' '04231600' '04249000' ...
    '04269000'};
   
numSites = length(siteIDs);
plotCnt = 0;
for k = 1:numSites
    cmb = false;
    if eq(plotCnt,0)
        % create figure
        close all
        fig_h = figure('Color','w','Units','inches','Position',[0 0 figW figH],...
            'PaperPosition',[0 0 figW figH]);
        movegui(fig_h,'center')
        ax_h = zeros(plotGen,1);
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
    % if combine...
    % -- measurement times for parameter --
    fileN = [siteIDs{k} '_' pCode '.txt'];
    fID = fopen([rootDir dataFldr fileN]);
    dat   = textscan(fID,'%s %f %s %f','Delimiter',delim,...
        'treatAsEmpty',treatAsEmpty,'HeaderLines',1);
    fclose all;
    dates = datenum(dat{1},'yyyy-mm-dd');
    dates = unique(dates);
    if any(strcmp(siteIDs{k},combineSID(:,1)))
        cmb = true;
        comI = strcmp(siteIDs{k},combineSID(:,1));
        comSID = combineSID(comI,2);
        fileN = [comSID{1} '_' pCode '.txt'];
        fID = fopen([rootDir dataFldr fileN]);
        
        if le(fID,0)
            disp([rootDir dataFldr fileN ' not found']);
        else
            dat   = textscan(fID,'%s %f %s','Delimiter',delim,...
                'treatAsEmpty',treatAsEmpty,'HeaderLines',1);
            fclose all;
            datesC = datenum(dat{1},'yyyy-mm-dd');
            dates = unique([datesC; dates]);
            disp([siteIDs{k} ' combined with ' comSID{1}])
        end
    end
    % -- discharge aggregation --
    try
        [Qdates, Qdaily] = getDvDataNWIS(siteIDs{k}, distPcode, startDT);
        %[Qdaily,Qdates] = downsample_interval(Q,Qdates,86400);
        
        gage = false;
    catch
        disp(['site ' siteIDs{k} ' switched to gage'])
        [Qdates, Qdaily] = getDvDataNWIS(siteIDs{k}, '00065', startDT);        
        gage = true;
    end
    nanI = isnan(Qdaily);
    Qdates = Qdates(~nanI);
    Qdaily = Qdaily(~nanI);
    [srtQ,srtI] = sort(-Qdaily); % reverse sort
    srtQ = -srtQ;
    Qdates = Qdates(srtI);
    xNumz = linspace(0,100,length(srtQ));
    plot(xNumz,srtQ,'Parent',ax_h(plotCnt),'LineWidth',LW)
    % now...find the sampling locations
    
    N = 0;
    for j = 1:length(dates)
        plotI = eq(dates(j),Qdates);
        plot(xNumz(plotI),srtQ(plotI),'ro',...
            'MarkerSize',mS,'MarkerFaceColor',mF,...
            'Parent',ax_h(plotCnt),'LineWidth',.75)
        N = N + sum(plotI);
        
    end
    P = length(dates);
    try siteName = getSiteName(siteIDs{k});
    catch issue
        disp(['site name ' siteIDs{k} ' not found']);
        siteName = '';
    end
    if gage
        set(get(ax_h(plotCnt),'YLabel'),'String','Gage height (ft)')
        set(ax_h(plotCnt),'YScale','linear')
    end
    if cmb
        if ne(P,N)
            title([siteName ' (' siteIDs{k} ' & ' char(comSID) ...
                '; ' 'N=' num2str(N) ...
                '; {\color{red}total=' num2str(P) '})'],...
                'Parent',ax_h(plotCnt));
        else
            title([siteName ' (' siteIDs{k} ' & ' char(comSID) ...
                '; ' 'N=' num2str(N) ...
                ')'],...
                'Parent',ax_h(plotCnt));
        end
        
    else
        if ne(P,N)
            title([siteName ' (' siteIDs{k} '; N=' num2str(N) ...
                '; {\color{red}total=' num2str(P) '})'],...
                'Parent',ax_h(plotCnt));
        else
            title([siteName ' (' siteIDs{k} '; N=' num2str(N) ...
                ')'],...
                'Parent',ax_h(plotCnt));
        end
    end
    if eq(plotCnt,plotGen) || eq (k,numSites)
        for pl = plotCnt+1:plotGen
            delete(ax_h(pl));
        end
        figTitle = [figDir 'FlowDur_0' num2str(ceil(k/plotGen))];
        disp(figTitle)
        export_fig(figTitle,'-png','-m1','-nocrop')
        plotCnt = 0;
    end
    pause(.5)
end

end

