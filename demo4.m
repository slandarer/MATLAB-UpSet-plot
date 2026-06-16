%% demo 4 : Large dataset (100 million samples, 7 sets)
rng(5)

% Generate large sparse binary matrix (100M samples, 7 sets).
setMat = rand([1e8, 7]) > 0.9;

USP = UpSetPlot(setMat);
USP.calc(); 

% Display only top 28 largest intersections to reduce clutter.
USP.draw(28);

% Extend X-axis limit by 40% to accommodate set-size labels.
USP.axS.XLim = USP.axS.XLim.*1.4;

% Rotate intersection-size labels to 50° to reduce label overlap.
for i = 1:length(USP.txtHdlI)
    set(USP.txtHdlI(i), 'Rotation', 50, 'HorizontalAlignment','left')
end