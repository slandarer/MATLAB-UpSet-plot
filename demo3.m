% demo 3 : Change colors

rng(5)
setMat = rand([200, 5]) > 0.85;

USP = UpSetPlot(setMat);

% Grayscale color scheme
USP.BarColorI = [ 61, 58, 61]./255;
USP.BarColorS = [ 61, 58, 61]./255;
USP.LineColor = [ 61, 58, 61]./255;

% % Alternative color scheme
% USP.BarColorI = [  0,  0,245; 245,  0,  0]./255;
% USP.BarColorS = cool;
% USP.LineColor = [ 61, 58, 61]./255;

USP.calc(); 
USP.draw();