%% demo 2 : UpSet mode: 'intersect'

rng(1)
setName = {'RB1','PIK3R1','EGFR','TP53','PTEN'};
setMat = rand([200, 5]) > 0.85;

% Create UpSet plot object with 'intersect' mode.
USP = UpSetPlot(setMat, 'SetName',setName, 'Mode','intersect');
USP.calc(); 
USP.draw();