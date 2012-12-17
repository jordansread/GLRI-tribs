function plotQvsPcode(pCode)

%- need quick scatterplots for Q x 631, 62855, 665, and 671
%- time series for any of the above that do not show a good relationship with Q

if eq(nargin,0)
    pCode = '00671'; 
end
codes = struct('P00631_n','Nitrate plus nitrite','P00631_u','mg L^{-1}',...
    'P62855_n','Total nitrogen','P62855_u','mg L^{-1}',...
    'P00665_n','Phosphorus','P00665_u','mg L^{-1}',...
    'P00671_n','Orthophosphate','P00671_u','mg L^{-1}');


plotGen = 2;
axLw = 1.25;
mF = [.7 .85 .85];
mS = 4;
LW = 1.25;
xL = [datenum('2010-10-01') datenum('2013-1-01')];
xTck = [datenum(2010,1:12,1) datenum(2011,1:12,1) datenum(2012,1:12,1) ...
    datenum(2013,1:12,1)];
xLab = cell(length(xTck),1);
for i = 1:length(xLab)
    if eq(rem(i+5,6),0)
        xLab{i} = datestr(xTck(i),'yyyy-mmm');
    else
        xLab{i} = ' ';
    end
end
fontS = 9;
fontN = 'Times New Roman';

figW = 8;
figH = 6;
lM   = 0.75;
rM   = 0.75;
tM   = 0.5;
bM   = 0.5;
wSpc = 0.75; % width space
hSpc = 1;  % vertical space

W    = (figW-lM-rM-wSpc)/2;
H    = (figH-tM-bM-hSpc)/2;


    
% ** pCode is a string
if ~ischar(pCode)
    error('pCode input must be string');
end
distPcode = '00060';
yScale = 'linear';
figDir = 'I:\GLRI Tribs\Figures\';
rootDir = 'I:\GLRI Tribs\';
dataFldr= 'Oracle_Data\';
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
        ax_h = zeros(plotGen,3);
        ax_h(2,1) = axes('Parent',fig_h,'Position',[lM/figW bM/figH W/figW H/figH],...
            'LineWidth',axLw,'YScale',yScale,'Xscale','linear','TickDir','out',...
            'fontName',fontN,'FontSize',fontS,'Box','on','Color','none');
        hold on;
        ylabel([codes.(['P' pCode '_n']) ' (' codes.(['P' pCode '_u']) ')'],...
            'FontSize',fontS,'FontName',fontN)
        xlabel('Discharge (ft^{3} s^{-1})','FontSize',fontS,'FontName',fontN)
        ax_h(2,3) = copyobj(ax_h(2,1),fig_h);
        set(ax_h(2,3),'Position',[(lM+wSpc+W)/figW bM/figH W/figW H/figH],...
            'XLim',xL,'Box','off','YAxisLocation','right','XAxisLocation','top',...
            'XTick',xTck,'XTickLabel','')
        ax_h(2,2) = copyobj(ax_h(2,1),fig_h);
        set(ax_h(2,2),'Position',[(lM+wSpc+W)/figW bM/figH W/figW H/figH],...
            'XLim',xL,'XTick',xTck,'XTickLabel',xLab,'Box','off')
        
        
        ax_h(1,1) = copyobj(ax_h(2,1),fig_h);
        set(ax_h(1,1),'Position',[lM/figW (bM+hSpc+H)/figH W/figW H/figH])
        ax_h(1,3) = copyobj(ax_h(2,1),fig_h);
        set(ax_h(1,3),'Position',[(lM+wSpc+W)/figW (bM+hSpc+H)/figH W/figW H/figH],...
            'XLim',xL,'Box','off','YAxisLocation','right','XAxisLocation','top',...
            'XTick',xTck,'XTickLabel','')
        ax_h(1,2) = copyobj(ax_h(2,1),fig_h);
        set(ax_h(1,2),'Position',[(lM+wSpc+W)/figW (bM+hSpc+H)/figH W/figW H/figH],...
            'XLim',xL,'XTick',xTck,'XTickLabel',xLab,'Box','off')
        
        
    end
    
    plotCnt = plotCnt+1;
    % -- measurement times for parameter --
    fileN = [siteIDs{k} '_' pCode '.txt'];
    fID = fopen([rootDir dataFldr fileN]);
    dat   = textscan(fID,'%s %f %s','Delimiter',delim,...
        'treatAsEmpty',treatAsEmpty,'HeaderLines',1);
    fclose all;
    pDates = datenum(dat{1},'yyyy-mm-dd');
    params  = dat{2};
    [pDates,unI] = unique(pDates);
    params  = params(unI);
    fileN = [siteIDs{k} '_' distPcode '.txt'];
    fID = fopen([rootDir dataFldr fileN]);
    if le(fID,0)
        disp([rootDir dataFldr fileN ' NOT FOUND'])
        Q = NaN;
        qDates = NaN;
    else
        dat   = textscan(fID,'%s %f %s','Delimiter',delim,...
            'treatAsEmpty',treatAsEmpty,'HeaderLines',1);
        fclose all;
        qDates = datenum(dat{1},'yyyy-mm-dd');
        Q  = dat{2};
        [qDates,unI] = unique(qDates);
        Q  = Q(unI);
    end
    % -- NWIS add
    try [qDatesN, QN] = getIvDataNWIS(siteIDs{k}, distPcode);
        [QN,qDatesN] = downsample_interval(QN,qDatesN,86400);
        qDates = [qDatesN; qDates];
        Q = [QN; Q];
    catch
    end
    [qDates,unI] = unique(qDates);
    Q  = Q(unI);
    
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
            paramsC  = dat{2};
            fclose all;
            pDatesC = datenum(dat{1},'yyyy-mm-dd');
            [pDatesC,unI] = unique(pDatesC);
            paramsC = paramsC(unI);
            pDates = [pDatesC; pDates];
            params  = [paramsC; params];
            [pDates,unI] = unique(pDates);
            params  = params(unI);
            disp([siteIDs{k} ' combined with ' comSID{1}])
        end
        % -- discharge
        fileN = [comSID{1} '_' distPcode '.txt'];
        fID = fopen([rootDir dataFldr fileN]);
        
        if le(fID,0)
            disp([rootDir dataFldr fileN ' not found']);
        else
            dat   = textscan(fID,'%s %f %s','Delimiter',delim,...
                'treatAsEmpty',treatAsEmpty,'HeaderLines',1);
            QC  = dat{2};
            fclose all;
            qDatesC = datenum(dat{1},'yyyy-mm-dd');
            [qDatesC,unI] = unique(qDatesC);
            QC = QC(unI);
            qDates = [qDatesC; qDates];
            Q  = [QC; Q];
            [qDates,unI] = unique(qDates);
            Q  = params(unI);
            disp([siteIDs{k} ' combined with ' comSID{1}])
        end
    end
    % -- discharge aggregation --
    

    % now...find the sampling locations
    
    [~,qI] = ismember(pDates,qDates);
    rmvI = eq(qI,0);
    qI = qI(~rmvI);
    [~,pI] = ismember(qDates,pDates);
    rmvI = eq(pI,0);
    pI = pI(~rmvI);
    plot(Q(qI),params(pI),'ro',...
        'MarkerSize',mS,'MarkerFaceColor',mF,...
        'Parent',ax_h(plotCnt,1),'LineWidth',.75)
    N = length(pI);
    if cmb
        title(['(' siteIDs{k} ' & ' char(comSID) ...
            '; ' 'N=' num2str(N) ...
            ')'],...
            'Parent',ax_h(plotCnt,1));
        title(['(' siteIDs{k} ' & ' char(comSID) ...
            ')'],...
            'Parent',ax_h(plotCnt,2));
    else
        
        title(['(' siteIDs{k} '; N=' num2str(N) ...
            ')'],...
            'Parent',ax_h(plotCnt,1));
        title(['(' siteIDs{k} ')'],...
            'Parent',ax_h(plotCnt,2));
    end
    % -- now plot time series
    plot(qDates,Q,'ko',...
        'MarkerSize',2,'MarkerFaceColor','k',...
        'Parent',ax_h(plotCnt,3),'LineWidth',.25)
    plot(pDates,params,'bd',...
        'MarkerSize',mS+1,'MarkerFaceColor',mF,...
        'Parent',ax_h(plotCnt,2),'LineWidth',1.25)
    set(get(ax_h(plotCnt,3),'Ylabel'),'String','Discharge (ft^{3} s^{-1})')
    set(get(ax_h(plotCnt,2),'Xlabel'),'String','')
    set(get(ax_h(plotCnt,3),'Xlabel'),'String','')
    if eq(plotCnt,plotGen) || eq (k,numSites)
        for pl = plotCnt+1:plotGen
            delete(ax_h(pl));
        end
        figTitle = [figDir 'Scatter_0' num2str(ceil(k/plotGen)) '_P' pCode];
        disp(figTitle)
        export_fig(figTitle,'-png','-m1','-nocrop')
        plotCnt = 0;
    end
    pause(.5)
end

end

