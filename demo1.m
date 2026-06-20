%% demo 1 : Basic uasge | UpSet mode: 'distinct'(default)

rng(1)
% Define set names (5 categories).
setName = {'RB1','PIK3R1','EGFR','TP53','PTEN'};
% Generate random binary membership matrix (200 samples, 5 sets).
setMat = rand([200, 5]) > 0.85;

% Create UpSet plot object.
USP = UpSetPlot(setMat, 'SetName',setName);
USP.calc();    % Calculate intersection sizes.  
USP.draw();    % Render the UpSet plot.

USP