%% demo8 : Reverse XDir and YDir

rng(1)
setMat = rand([500, 5]) > 0.85;

USP = UpSetPlot(setMat);
USP.calc();    
USP.draw(2^5);    

pause(1)
USP.reverseXDir()
USP.reverseYDir()