classdef UpSetPlot < handle
% UpSetPlot: Visualization of set intersections.
%   Supports both 'distinct' (mutually exclusive) and 'intersect' (overlapping) modes.
% =========================================================================
% Basic usage
% -------------------------------------------------------------------------
% setMat = rand([200, 5]) > 0.85;
% 
% USP = UpSetPlot(setMat);
% USP.calc();
% USP.draw();
% =========================================================================
% ## fileexchange
% Zhaoxu Liu / slandarer (2026). UpSet plot 
% (https://www.mathworks.com/matlabcentral/fileexchange/123695-upset-plot), 
% MATLAB Central File Exchange. Retrieved April 27, 2026.
% ## gitee
% https://gitee.com/slandarer/matlab-up-set-plot

    properties
        arginList = {'SetName', 'Mode', 'BarColorI', 'BarColorS', 'LineColor'}
        fig = []     % Figure handle
        axI          % Axes for Intersection size bar chart.
        axS          % Axes for Set size horizontal bar chart.
        axC          % Axes for Connection matrix chart.


        SetNum  = 0
        SetName = {}
        SetMat       % Binary set matrix (samples × sets)
                     % ---------------------------------
                     %  A  B  C  sets
                     % [1  0  0] sample-1
                     % [0  1  0] sample-2
                     % [... ...] ... ...
                     % [0  0  1] sample-n
                     % ---------------------------------
                     %     -> 1 = sample belongs to set.
                     %     -> 0 = sample does not belong.

        Mode = 'distinct' % UpSet mode: 'distinct'(default) / 'intersect'
        % =================================================================
        BarColorI = [ 66,182,195]./255;
        BarColorS = [253,255,228; 164,218,183;  68,181,197;  44,126,185;  35, 51,154]./255;
        LineColor = [ 61, 58, 61]./255;
        % try:
        % BarColorI = [ 61, 58, 61]./255;
        % BarColorS = [ 61, 58, 61]./255;
        % LineColor = [ 61, 58, 61]./255;
        %
        % BarColorI = [  0,  0,245; 245,  0,  0]./255;
        % BarColorS = cool;
        % LineColor = [ 61, 58, 61]./255;

        PatchColor  = [248,246,249; 255,254,255]./255;
        BkgDotColor = [233,233,233]./255;
        % =================================================================
        sortSetSize, sortSetIndex,
        nzCount, nzIndex, nzNum, binCount, 
        fulBool, decList, decCode, SetSize,
        barHdlI, barHdlS, txtHdlI, txtHdlS, nameHdl
    end

    methods
        function obj = UpSetPlot(varargin)
            if isa(varargin{1}, 'matlab.ui.Figure')
                obj.fig = varargin{1}; varargin(1) = [];
            end

            obj.SetMat = varargin{1}; 
            obj.SetNum = size(obj.SetMat, 2);
            varargin(1) = [];

            % Parse name-value input arguments.
            for i = 1:2:(length(varargin) - 1)
                tIndex = ismember(lower(obj.arginList), lower(varargin{i}));
                if any(tIndex)
                    obj.(obj.arginList{tIndex}) = varargin{i + 1};
                end
            end

            if isempty(obj.SetName) || (length(obj.SetName) < obj.SetNum)
                obj.SetName = compose('Set-%d', 1:obj.SetNum);
            end
        end

        function obj = calc(obj)
            % Binarize and remove all-zero rows
            obj.SetMat = obj.SetMat > 0;
            obj.SetMat = obj.SetMat(any(obj.SetMat, 2), :);

            obj.SetSize = sum(obj.SetMat, 1);

            % Generate all non-empty set combinations (2^n - 1)
            obj.fulBool = dec2bin(1:(2^obj.SetNum - 1)) - '0';

            % Convert each sample row to decimal code
            obj.decList = 2.^((obj.SetNum - 1) : -1 : 0).';
            obj.decCode = sort(obj.SetMat*obj.decList);

            % Count occurrences of each combination (distinct mode)
            obj.binCount = zeros(2^obj.SetNum - 1, 1);
            obj.binCount(unique(obj.decCode)) = diff([0; find([diff(obj.decCode); 1])]);

            % Convert to intersect mode if requested
            if strcmpi(obj.Mode, 'intersect')
                inclusion = (obj.fulBool * obj.fulBool.') == repmat(sum(obj.fulBool, 2), [1, 2^obj.SetNum - 1]);
                obj.binCount = inclusion * obj.binCount;
            end

            obj.nzIndex = 1:length(obj.binCount);
            obj.nzIndex = obj.nzIndex(obj.binCount > 0);
            obj.nzCount = obj.binCount(obj.binCount > 0);
            [obj.nzCount, tInd] = sort(obj.nzCount, 'descend');
            obj.nzIndex = obj.nzIndex(tInd);
            obj.nzNum = length(obj.nzIndex);

            obj.sortSetIndex = 1:obj.SetNum;
            [obj.sortSetSize, obj.sortSetIndex] = sort(obj.SetSize, 'descend');
        end

        function obj = draw(obj, MaxBars)
            if nargin < 2
                MaxBars = 25;
            end

            if isempty(obj.fig)
                obj.fig = figure('Units','normalized', 'Position',[.3, .2, .5, .63], 'Color',[1,1,1]);
            end

            % Axes for Intersection size bar chart.
            obj.axI = axes('Parent',obj.fig, 'NextPlot','add', 'Position',[.33, .35, .655, .59], ...
                'LineWidth',1.2, 'Box','off', 'TickDir','out', 'FontName','Times New Roman', ...
                'FontSize',12, 'XTick',[], 'XLim',[0, min(MaxBars, obj.nzNum) + 1]);
            obj.axI.YLabel.String = 'Intersection Size';
            obj.axI.YLabel.FontSize = 16;
            % Axes for Set size horizontal bar chart.
            obj.axS = axes('Parent',obj.fig, 'NextPlot','add', 'Position',[.04, .08, .215, .26], ...
                'LineWidth',1.2, 'Box','off', 'TickDir','out', 'FontName','Times New Roman', ...
                'FontSize',12, 'YColor','none', 'YLim',[.5, obj.SetNum + .5], ...
                'YAxisLocation','right', 'XDir','reverse', 'YTick',[]);
            obj.axS.XLabel.String = 'Set Size';
            obj.axS.XLabel.FontSize = 16;
            % Axes for Connection matrix chart.
            obj.axC = axes('Parent',obj.fig, 'NextPlot','add', 'Position',[.33, .08, .655, .26], ...
                'YColor','none', 'YLim',[.5, obj.SetNum + .5], ...
                'XColor','none', 'XLim',obj.axI.XLim);


            % ==== Plot intersection size bar chart =======================
            obj.barHdlI = bar(obj.axI, obj.nzCount(1:min(MaxBars, obj.nzNum)));
            obj.barHdlI.EdgeColor = 'none';
            % Apply color mapping to bars.
            if size(obj.BarColorI, 1) == 1
                obj.BarColorI = obj.BarColorI([1, 1], :); 
            end
            tX = linspace(0, 1, size(obj.BarColorI, 1))';
            pX = linspace(0, 1, min(MaxBars, obj.nzNum));
            tC = interp1(tX, obj.BarColorI, pX);
            obj.barHdlI.FaceColor = 'flat';
            obj.barHdlI.CData = tC;
            % Add value labels above bars.
            obj.txtHdlI = text(obj.axI, 1:min(MaxBars, obj.nzNum), obj.nzCount(1:min(MaxBars, obj.nzNum)), ...
                string(obj.nzCount(1:min(MaxBars, obj.nzNum))), 'HorizontalAlignment','center', ...
                'VerticalAlignment','bottom', 'FontName','Times New Roman', 'FontSize',12, 'Color','k');


            % ==== Plot set size horizontal bar chart =====================
            obj.barHdlS = barh(obj.axS, obj.sortSetSize, 'BarWidth', .6);
            obj.barHdlS.EdgeColor = 'none';
            obj.barHdlS.BaseLine.Color = 'none';
            % Apply color mapping to horizontal bars.
            if size(obj.BarColorS, 1) == 1
                obj.BarColorS = obj.BarColorS([1, 1], :); 
            end
            tX = linspace(0, 1, size(obj.BarColorS, 1))';
            pX = linspace(0, 1, obj.SetNum);
            tC = interp1(tX, obj.BarColorS, pX);
            obj.barHdlS.FaceColor = 'flat';
            obj.barHdlS.CData = tC;
            % Add set names as annotations.
            for i = 1:obj.SetNum
                obj.nameHdl(i) = annotation('textbox', [(obj.axS.Position(1) + obj.axS.Position(3) + obj.axI.Position(1))/2 - .02, ...
                     obj.axS.Position(2) + obj.axS.Position(4)./obj.SetNum.*(i - .5) - .02, .04, .04], ...
                    'String', obj.SetName{obj.sortSetIndex(i)}, 'HorizontalAlignment','center', 'VerticalAlignment','middle', ...
                    'FitBoxToText','on', 'LineStyle','none', 'FontName','Times New Roman', 'FontSize',13);
            end
            % Add value labels to the left of bars.
            obj.txtHdlS = text(obj.axS, obj.sortSetSize, 1:obj.SetNum, compose('%d ', obj.sortSetSize), 'HorizontalAlignment','right', ...
                'VerticalAlignment','middle', 'FontName','Times New Roman', 'FontSize',12, 'Color','k');


            % ==== Plot connection matrix chart ===========================
            % Background stripes for alternating rows.
            for i = 1:obj.SetNum
                fill(obj.axC, obj.axI.XLim([1,2,2,1]), [-.5, -.5, .5, .5] + i, ...
                    obj.PatchColor(mod(i+1, 2)+1, :), 'EdgeColor', 'none');
            end
            % Empty dots.
            [tX, tY] = meshgrid(1:min(MaxBars, obj.nzNum), 1:obj.SetNum);
            plot(obj.axC, tX(:), tY(:), 'o', 'Color',obj.BkgDotColor(1, :), ...
                'MarkerFaceColor',obj.BkgDotColor(1, :), 'MarkerSize',10);
            % Draw connection lines and filled dots for active combinations.
            for i = 1:min(MaxBars, obj.nzNum)
                tY = find(obj.fulBool(obj.nzIndex(i), obj.sortSetIndex));
                tX = tY.*0 + i;
                plot(obj.axC, tX, tY, '-o', 'Color',obj.LineColor(1, :), ...
                    'MarkerEdgeColor','none', 'MarkerFaceColor',obj.LineColor(1, :), ...
                    'MarkerSize',10, 'LineWidth',2);
            end

        end
    end
end