function [fig_h, ax_h] = createPanelPlot(numX,numY,figW,figH)

if eq(nargin,2)
    figW = 8;
    figH = 6;
end

% -- variables --
lM = .75;
rM = .25;
bM = .25;
tM = .25;
xSpc = .5;
ySpc = 0.5;

W  = (figW-(numX-1)*xSpc-lM-rM)/numX;
H  = (figH-(numY-1)*ySpc-tM-bM)/numY;


ax_h = ones(numY*numX,1);

fig_h = figure('Color','w','Units','inches',...
    'PaperPosition',[0 0 figW figH],...
    'Position',[0 0 figW figH]);
movegui(fig_h,'center');
cnt = 1;
for j = numY:-1:1
    for i = 1:numX
        pos = [(lM+(i-1)*(W+xSpc))/figW (bM+(j-1)*(H+ySpc))/figH ...
            W/figW H/figH];
        ax_h(cnt) = axes('Parent',fig_h,'Position',pos,'box','on',...
            'XTick',[],'FontSize',6,'FontName','Times New Roman',...
            'LineWidth',.9);
        hold on;
        cnt = cnt+1;
    end
end



end

