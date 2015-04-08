fs=14;
lw=1.5;

lineobj = findobj('type', 'line');
set(lineobj, 'linewidth', lw);
set(gca,'linewidth',lw);

textobj = findobj('type', 'text');
set(textobj, 'fontunits', 'points');
set(textobj, 'fontsize', fs);
set(gca,'fontsize',fs);
set(get(gca,'XLabel'),'fontunits','points');
set(get(gca,'XLabel'),'fontsize',fs);
set(get(gca,'YLabel'),'fontunits','points');
set(get(gca,'YLabel'),'fontsize',fs);
set(get(gca,'ZLabel'),'fontunits','points');
set(get(gca,'ZLabel'),'fontsize',fs);
set(get(gca,'Title'),'fontunits','points');
set(get(gca,'Title'),'fontsize',fs);
