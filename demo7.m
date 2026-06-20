%% demo 7 : Markers

rng(1)
setMat = rand([200, 5]) > 0.85;

% Create UpSet plot object.
USP = UpSetPlot(setMat, 'SetName',setName);
USP.calc();    
USP.draw();


set(USP.olineHdl(6), 'Marker','p', 'MarkerSize',15)


% Customize the UpSet plot by adding custom markers.
for i = 1:5
    plot(USP.axI, i, USP.barHdlI.YEndPoints(i), 'Marker','p', 'MarkerSize',15, ...
        'MarkerFaceColor',[.3,.3,.3], 'Color',[.3,.3,.3])
    set(USP.txtHdlI(i), 'Visible','off')
end

for i = 6:13
    plot(USP.axI, i, USP.barHdlI.YEndPoints(i), 'Marker','^', 'MarkerSize',15, ...
        'MarkerFaceColor',[253,143,82]./255, 'Color',[253,143,82]./255)
    set(USP.txtHdlI(i), 'Visible','off')
end

for i = 14:18
    plot(USP.axI, i, USP.barHdlI.YEndPoints(i), 'Marker','o', 'MarkerSize',15, ...
        'MarkerFaceColor',[79,148,204]./255, 'Color',[79,148,204]./255)
    set(USP.txtHdlI(i), 'Visible','off')
end