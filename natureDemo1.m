%% Reproduction of a Nature figure example
% Reproduct from Fig. 1b
% Mayassi, T., Li, C., Segerstolpe, Å. et al. 
% Spatially restricted immune and microbiota-driven adaptation of the gut. 
% Nature 636, 447–456 (2024). https://doi.org/10.1038/s41586-024-08216-z

% Read data (数据导入)
geneData = readtable('natureDemo1Gene.csv');
setMat = geneData.Variables;          
setName = geneData.Properties.VariableNames;

% Create figure and initialize UpSet plot object (创建图窗并初始化 UpSet 图对象)
fig = figure('Units','normalized', 'Position',[.05,.1,.88,.75], 'Color','w');
USP = UpSetPlot(fig, setMat, 'SetName');
USP.SetName = setName;

% Set basic colors (设置基本颜色)
USP.BarColorI = [0,0,0];                % Intersection bar color (交集条形颜色)
USP.BarColorS = [0,0,0];                % Set bar color (集合条形颜色)
USP.LineColor = [0,0,0];                % Connection line color (连接线颜色)
USP.BkgDotColor = [201,203,203]./255;   % Background dot color (背景点颜色)
USP.BkgPatchColor = [230,  75,  53;     % Patch background colors (填充背景色)
       77, 187, 213;   0, 160, 135;  60,  84, 136; 
      132, 145, 180; 145, 209, 194; 176, 156, 133]./255;  

% Set sorting and layout parameters (设置排序与布局参数)
USP.SortS = 'none';                     % Set sorting: none (集合排序：无)
USP.SortI = 'degbit';                   % Intersection sorting: degree then bit (交集排序：按 degree 再按 bit)
USP.HRatio = [1, .8];                   % Height ratio of bars vs matrix (条形与矩阵的高度比)
USP.WRatio = [8, 1, .15];               % Width ratio: matrix, set bars, name labels (宽度比：矩阵、集合条、标签)
USP.Padding = [.04, .08, .02, .28];     % Figure padding [left, right, bottom, top] (图窗边距)
USP.Layout = 3;                         % Layout style (布局样式)

% Compute and draw the UpSet plot (计算并绘制UpSet图)
USP.calc();   
% Draw the first 128 intersection bars (绘制前128个交集柱子)
USP.draw(2^7);                   

% Reverse axes (翻转坐标轴)
USP.reverseXDir()
USP.reverseYDir()

% Adjust labels and decorations (调整标签与装饰)
set(USP.nameHdl, 'HorizontalAlignment','right')
set(USP.txtHdlI, 'Rotation',90, 'HorizontalAlignment','left', 'VerticalAlignment','middle') 
set(USP.bkgPatchHdl, 'FaceAlpha',.5)             
USP.axI.XColor = 'none';           
USP.axI.YLabel.String = 'Shared genes'; 
USP.barHdlI.BaseLine.Color = 'none'; 
