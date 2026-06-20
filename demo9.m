%% demo9 : SortS and SortI

rng(1)
setMat = rand([500, 5]) > [.4, .6, .7, .5, .8];

fig = figure('Units','normalized', 'Position',[.1, .2, .62, .63], 'Color','w');
USP = UpSetPlot(fig, setMat);
USP.WRatio = [5, 1, .2];
USP.SortS = 'none';
USP.SortI = 'degree';

USP.calc();      
USP.draw(2^5);    
