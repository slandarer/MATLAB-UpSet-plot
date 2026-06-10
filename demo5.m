% demo 5 : Stacked bar chart visualization of additional information (distinct mode only).


rng(1)
% Define set names (5 categories).
setName = {'setS','setL','setA','setN','setD'};
% Generate random binary membership matrix (200 samples, 5 sets).
setMat = rand([200, 5]) > 0.85;
% Remove samples that do not belong to any set.
setMat = setMat(any(setMat, 2), :);

% Define property-related parameters.
propNum = 4;                                       % Number of property categories.
porpName = {'porpA','porpB','porpC','porpD'};      % Names of property categories.
propList = randi([1, 4], [size(setMat, 1), 1]);    % Random property assignment for each sample (1-4).
propCList = [.99, .85, .54; .55, .68, .34;         % Color List for stacked bar segments (RGB).
             .32, .38, .22; .30, .64, .69;
             .35, .55, .57; .22, .36, .37];

% Create UpSet plot object.
USP = UpSetPlot(setMat, 'SetName',setName);
USP.BarColorS = [.3, .3, .3];
USP.calc();    % Calculate intersection sizes.  
USP.draw();    % Render the UpSet plot.

%% Stacked bar chart visualization of additional information
propMat = zeros([USP.nzNum, propNum]);
for i = 1:USP.nzNum
    for j = 1:propNum
        propMat(i, j) = sum(propList(USP.nzIndex(i) == USP.oriIndex) == j);
    end
end
delete(USP.barHdlI)
% Create stacked bar chart to show property composition within each intersection.
barHdl = bar(USP.axI, propMat, 'stacked', 'EdgeColor','none');
for i = 1:length(barHdl)
    barHdl(i).FaceColor = propCList(i, :);
end
legend(USP.axI, porpName, 'FontSize',13, 'FontName','Times New Roman', 'Direction','normal')