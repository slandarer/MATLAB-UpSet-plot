%% demo 6 : Highlight for bar chart


rng(1)
% Define set names (5 categories).
setMat = rand([200, 5]) > 0.85;

% Create UpSet plot object.
USP = UpSetPlot(setMat);

% Grayscale color scheme
USP.BarColorI = [.3, .3, .3];
USP.BarColorS = [.3, .3, .3];
USP.LineColor = [.3, .3, .3];

USP.calc();
USP.draw();


% Highlight for intersection size bar chart
USP.highlightI(7, [79,148,204]./255)
USP.highlightI(5, [253,143,82]./255)

% Highlight for Set size bar chart
USP.highlightS(2, [132,158,119]./255)




% USP.barHdlI.CData(7, :) = [79,148,204]./255;
% set(USP.olineHdl(7), 'Color',[79,148,204]./255, 'MarkerFaceColor',[79,148,204]./255);
% set(USP.txtHdlI(7), 'Color',[79,148,204]./255);
