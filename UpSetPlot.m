classdef UpSetPlot < handle
% UpSetPlot Create UpSet plot to visualize set intersections (创建 UpSet 图以可视化集合交集)
%   USP = UpSetPlot(setMat); creates an UpSet plot object from a boolean matrix
%   where rows represent samples and columns represent sets.
%   从布尔(逻辑) 矩阵创建 UpSet 图对象，行代表样本，列代表集合。
%
%   USP = UpSetPlot(fig, setMat); creates the plot in the specified figure.
%   在指定图窗中创建绘图。
%
%   USP = UpSetPlot(___, propName, propVal); specifies property name-value pairs
%   when creating the UpSet plot object.
%   创建 UpSet 图对象时指定属性名-属性值对。
%
%   USP.propName = propVal; sets properties for the UpSet plot object
%   after creation, before calling calc() and draw().
%   创建 UpSet 图对象后、调用 calc() 和 draw() 前设置其属性。
%
%   USP.calc(); computes the intersection matrix and sizes 
%   计算交集矩阵及大小
%
%   USP.draw(); renders the UpSet plot, limited to a default maximum of 25 bars 
%   渲染 UpSet 图，默认最多显示 25 个柱子
%
%   USP.draw(N); renders only the first N intersection bars 
%   仅绘制前 N 个交集柱子
%
% Note:
%   UpSetPlot supports two visualization modes:
%     - 'distinct' (default): intersections are mutually exclusive (each element
%       belongs to exactly one intersection based on its membership pattern).
%       (默认模式，各交集互斥，每个元素仅归属一个交集)
%     - 'intersect' : intersections can overlap, showing all possible combinations.
%       (交集可重叠，显示所有可能的组合)
%
% Basic usage:
%   setMat = rand([200, 5]) > 0.85;
% 
%   USP = UpSetPlot(setMat);
%   USP.calc();
%   USP.draw(2^5);


% =========================================================================
% fileexchange:
%   Zhaoxu Liu / slandarer (2026). UpSet plot 
%   (https://www.mathworks.com/matlabcentral/fileexchange/123695-upset-plot), 
%   MATLAB Central File Exchange. Retrieved April 27, 2026.
%
% gitee:
%   https://gitee.com/slandarer/matlab-up-set-plot
%
% github:
%   https://github.com/slandarer/MATLAB-UpSet-plot
% =========================================================================
    properties
        fig = []     % Figure handle
        axI          % Axes for Intersection size bar chart.
        axS          % Axes for Set size horizontal bar chart.
        axC          % Axes for Connection matrix chart.
        arginList = {'SetName', 'Mode', 'SortI', 'SortS', 'BarColorI', 'BarColorS', 'LineColor'}

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

        SortI = 'descend'   % 'descend'   - Sort by sample count descending (按样本数降序)
                            % 'degree'    - Sort by number of sets ascending, then by sample count descending
                            %               (按集合个数升序，再按样本数降序)
                            % 'bit'       - Sort by the integer value of the membership pattern (按位编码升序)
                            %               Example: [0,0,1] -> 1, [0,1,0] -> 2, [0,1,1] -> 3
                            % 'revbit'    - Sort by the integer value after reversing the bit pattern (翻转位编码后升序)
                            %               Example: [0,0,1] -> reversed [1,0,0] -> 4,
                            %                        [0,1,0] -> reversed [0,1,0] -> 2
                            % 'degbit'    - Sort by degree ascending, then by bit encoding ascending within same degree
                            %               (先按degree升序，相同degree内按位编码升序)
                            % 'degrevbit' - Sort by degree ascending, then by reversed bit encoding ascending within same degree
                            %               (先按degree升序，相同degree内按翻转位编码升序)
                            % 'pri'       - Sort intersections by priority of set membership.
                            %               Intersections containing the first priority set are sorted
                            %               by size descending, followed by intersections containing
                            %               the second priority set (but not the first), and so on.
                            %               (按集合优先级排序：包含第一个优先集的交集按样本量降序排列，
                            %                然后是不含第一个但含第二个优先集的交集，依此类推)
                            % 'revpri'    - Reverse of 'pri': intersections containing the last priority set
                            %               are listed first, sorted by size descending, then those containing
                            %               the second-to-last (but not the last), and so on.
                            %               (与'pri'相反：包含最后一个优先集合的交集排在前面，按样本量降序排列，
                            %                然后是不含最后一个但含倒数第二个优先集合的交集，依此类推)


        SortS = 'descend'   % 'descend'/'none'

        Mode = 'distinct'   % UpSet mode: 'distinct'(default) / 'intersect'
        % =================================================================
        Layout = 1
        % % Layout : 1        % Layout : 2        % Layout : 3
        % ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
        % │          ┌─────┐│ │       ┌─────┐   │ │   ┌─────┐       │
        % │          │ axI ││ │       │ axI │   │ │   │ axI │       │
        % │          └─────┘│ │       └─────┘   │ │   └─────┘       │
        % │┌─────┐ t ┌─────┐│ │┌─────┐┌─────┐ t │ │ t ┌─────┐┌─────┐│
        % ││ axS │ x │ axC ││ ││ axS ││ axC │ x │ │ x │ axC ││ axS ││
        % │└─────┘ t └─────┘│ │└─────┘└─────┘ t │ │ t └─────┘└─────┘│
        % └─────────────────┘ └─────────────────┘ └─────────────────┘

        Padding = [.04, .08, .015, .06];   % [left(l), bottom(b), right(r), top(t)]
        Spacing = [.01, .01];              % [width(w), height(h)]
        WRatio  = [.655, .215, .055];      % [axC(wc), axS(ws), txt(wt)]
        HRatio  = [.26, .59];              % [axC(hc), axI(hi), ]
        % ┌───────────────────────────────────────┐
        % |                             ↑         |
        % |                             t         |
        % |                             ↓         |    
        % │                          ┌──────┐     |
        % |                          │  ↑   │     |
        % |                          │  hi  │← r →|
        % |                          │  ↓   │     |
        % |                          └──────┘     |
        % |                             ↑         |
        % |                             h         |
        % |                             ↓         |
        % │     ┌──────┐     ┌─┐     ┌──────┐     |
        % |     │      │     │t│     │      │ ↑   |
        % |← l →│← ws →│← w →│x│← w →│← wc →│ hc  |
        % |     │      │     │t│     │      │ ↓   |
        % |     └──────┘     └─┘     └──────┘     |
        % |        ↑                              |
        % |        b                              |
        % |        ↓                              |
        % └───────────────────────────────────────┘

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

        BkgPatchColor  = [248,246,249; 255,254,255]./255;
        BkgDotColor = [233,233,233]./255;
        % =================================================================
        sortSetSize, sortSetIndex,
        nzCount, nzIndex, oriIndex  
        barHdlI, barHdlS, txtHdlI, txtHdlS, nameHdl, 
        bkgDotHdl
        bkgEdgeHdl, 
        bkgPatchHdl
        olineHdl
    end

    properties (Hidden)
        nzNum, nzBool, binCount, namePos
        fulBool, revBool, decList, decCode, SetSize
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
            obj.revBool = obj.fulBool(:, end:-1:1);

            % Convert each sample row to decimal code
            obj.decList = 2.^((obj.SetNum - 1) : -1 : 0).';
            obj.oriIndex = obj.SetMat*obj.decList;
            obj.decCode = sort(obj.oriIndex);

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
            obj.nzBool = obj.fulBool(obj.binCount > 0, :);
            obj.revBool = obj.revBool(obj.binCount > 0, :);
            obj.nzNum = length(obj.nzIndex);

            switch obj.SortI
                case 'descend'
                    [obj.nzCount, tInd] = sort(obj.nzCount, 'descend');
                    obj.nzIndex = obj.nzIndex(tInd);
                case 'degree'
                    [~, tInd] = sortrows([sum(obj.nzBool, 2), - obj.nzCount(:)]);
                    obj.nzIndex = obj.nzIndex(tInd);
                    obj.nzCount = obj.nzCount(tInd);
                case 'bit'
                case 'revbit'
                    [~, tInd] = sort(obj.revBool*obj.decList);
                    obj.nzIndex = obj.nzIndex(tInd);
                    obj.nzCount = obj.nzCount(tInd);
                case 'degbit'
                    [~, tInd] = sortrows([sum(obj.nzBool, 2), obj.nzIndex(:)]);
                    obj.nzIndex = obj.nzIndex(tInd);
                    obj.nzCount = obj.nzCount(tInd);
                case 'degrevbit'
                    [~, tInd] = sortrows([sum(obj.nzBool, 2), obj.revBool*obj.decList]);
                    obj.nzIndex = obj.nzIndex(tInd);
                    obj.nzCount = obj.nzCount(tInd);
                case 'pri'
                    minSet = obj.nzBool.*(1:obj.SetNum);
                    minSet(minSet == 0) = obj.SetNum + 1;
                    [~, tInd] = sortrows([min(minSet,[],2), -obj.nzCount(:)]);
                    obj.nzIndex = obj.nzIndex(tInd);
                    obj.nzCount = obj.nzCount(tInd);
                case 'revpri'
                    [~, tInd] = sortrows([-max(obj.nzBool.*(1:obj.SetNum),[],2), -obj.nzCount(:)]);
                    obj.nzIndex = obj.nzIndex(tInd);
                    obj.nzCount = obj.nzCount(tInd);
            end

            obj.nzIndex = obj.nzIndex(:).';
            obj.nzCount = obj.nzCount(:).';

            obj.sortSetIndex = 1:obj.SetNum;
            switch obj.SortS 
                case 'descend'
                    [obj.sortSetSize, obj.sortSetIndex] = sort(obj.SetSize, 'descend');
                case 'none'
                    obj.sortSetSize = obj.SetSize;
            end
        end

        function obj = draw(obj, MaxBars)
            if nargin < 2
                MaxBars = 25;
            end

            if isempty(obj.fig)
                obj.fig = figure('Units','normalized', 'Position',[.3, .2, .5, .63], 'Color',[1,1,1]);
            end

            obj.Padding = abs(obj.Padding);  
            obj.Spacing = abs(obj.Spacing);

            tW = 2*obj.Spacing(1) + obj.Padding(1) + obj.Padding(3);
            tH = obj.Spacing(2) + obj.Padding(2) + obj.Padding(4);

            if tW > .5
                obj.Spacing(1) = obj.Spacing(1)./tW.*.5;
                obj.Padding(1) = obj.Padding(1)./tW.*.5;
                obj.Padding(3) = obj.Padding(3)./tW.*.5;
                tW = .5;
            end
            if tH > .5
                obj.Spacing(2) = obj.Spacing(2)./tH.*.5;
                obj.Padding(2) = obj.Padding(2)./tH.*.5;
                obj.Padding(4) = obj.Padding(4)./tH.*.5;
                tH = .5;
            end

            obj.WRatio = abs(obj.WRatio); obj.WRatio = obj.WRatio./sum(obj.WRatio).*(1 - tW);
            obj.HRatio = abs(obj.HRatio); obj.HRatio = obj.HRatio./sum(obj.HRatio).*(1 - tH);

            

            switch obj.Layout
                case 1
                    posS = [obj.Padding(1), obj.Padding(2), obj.WRatio(2), obj.HRatio(1)];
                    posC = [1 - obj.WRatio(1) - obj.Padding(3), obj.Padding(2), obj.WRatio(1), obj.HRatio(1)];
                    posI = [1 - obj.WRatio(1) - obj.Padding(3), ...
                           obj.Padding(2) + obj.HRatio(1) + obj.Spacing(2), ...
                           obj.WRatio(1), obj.HRatio(2)];
                    posT = [obj.Padding(1) + obj.WRatio(2) + obj.Spacing(1), obj.WRatio(3)];
                case 2
                    posS = [obj.Padding(1), obj.Padding(2), obj.WRatio(2), obj.HRatio(1)];
                    posC = [obj.Padding(1) + obj.WRatio(2) + obj.Spacing(1), obj.Padding(2), ...
                            obj.WRatio(1), obj.HRatio(1)];
                    posI = [obj.Padding(1) + obj.WRatio(2) + obj.Spacing(1), ...
                            obj.Padding(2) + obj.HRatio(1) + obj.Spacing(2), ...
                            obj.WRatio(1), obj.HRatio(2)];
                    posT = [1 - obj.Padding(3) - obj.WRatio(3), obj.WRatio(3)];
                case 3
                    posS = [1 - obj.WRatio(2) - obj.Padding(3), ...
                            obj.Padding(2), obj.WRatio(2), obj.HRatio(1)];
                    posC = [obj.Padding(1) + obj.WRatio(3) + obj.Spacing(1), ...
                            obj.Padding(2), obj.WRatio(1), obj.HRatio(1)];
                    posI = [obj.Padding(1) + obj.WRatio(3) + obj.Spacing(1), ...
                            obj.Padding(2) + obj.HRatio(1) + obj.Spacing(2), ...
                            obj.WRatio(1), obj.HRatio(2)];
                    posT = [obj.Padding(1), obj.WRatio(3)];
            end

            % Axes for Intersection size bar chart.
            obj.axI = axes('Parent',obj.fig, 'NextPlot','add', 'Position',posI, ...
                'LineWidth',1.2, 'Box','off', 'TickDir','out', 'FontName','Times New Roman', ...
                'FontSize',12, 'XTick',[], 'XLim',[0, min(MaxBars, obj.nzNum) + 1]);
            obj.axI.YLabel.String = 'Intersection Size';
            obj.axI.YLabel.FontSize = 16;
            % Axes for Set size horizontal bar chart.
            obj.axS = axes('Parent',obj.fig, 'NextPlot','add', 'Position',posS, ...
                'LineWidth',1.2, 'Box','off', 'TickDir','out', 'FontName','Times New Roman', ...
                'FontSize',12, 'YColor','none', 'YLim',[.5, obj.SetNum + .5], ...
                'YAxisLocation','right', 'XDir','reverse', 'YTick',[]);
            obj.axS.XLabel.String = 'Set Size';
            obj.axS.XLabel.FontSize = 16;
            % Axes for Connection matrix chart.
            obj.axC = axes('Parent',obj.fig, 'NextPlot','add', 'Position',posC, ...
                'YColor','none', 'YLim',[.5, obj.SetNum + .5], ...
                'XColor','none', 'XLim',obj.axI.XLim);

            % Add set names as annotations.
            obj.nameHdl = gobjects(1, obj.SetNum);
            obj.namePos = zeros(obj.SetNum, 4);
            for i = 1:obj.SetNum
                obj.namePos(i, :) = [posT(1), obj.axS.Position(2) + obj.axS.Position(4)./obj.SetNum.*(i - .5) - .02, posT(2), .04];
                obj.nameHdl(i) = annotation('textbox', obj.namePos(i, :), ...
                    'String', obj.SetName{obj.sortSetIndex(i)}, 'HorizontalAlignment','center', 'VerticalAlignment','middle', ...
                    'FitBoxToText','off', 'LineStyle','none', 'FontName','Times New Roman', 'FontSize',13);
            end

            if obj.Layout == 3
                obj.axS.XDir = 'normal';
            end

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
                compose(' %d ', obj.nzCount(1:min(MaxBars, obj.nzNum))), 'HorizontalAlignment','center', ...
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
            % Add value labels to the left of bars.
            if obj.Layout == 3
                obj.txtHdlS = text(obj.axS, obj.sortSetSize, 1:obj.SetNum, compose(' %d ', obj.sortSetSize), 'HorizontalAlignment','left', ...
                    'VerticalAlignment','middle', 'FontName','Times New Roman', 'FontSize',12, 'Color','k');
            else
                obj.txtHdlS = text(obj.axS, obj.sortSetSize, 1:obj.SetNum, compose(' %d ', obj.sortSetSize), 'HorizontalAlignment','right', ...
                    'VerticalAlignment','middle', 'FontName','Times New Roman', 'FontSize',12, 'Color','k');
            end


            % ==== Plot connection matrix chart ===========================
            % Background stripes for alternating rows.
            obj.bkgPatchHdl = gobjects(1, obj.SetNum);
            for i = 1:obj.SetNum
                obj.bkgPatchHdl(i) = fill(obj.axC, obj.axI.XLim([1,2,2,1]), [-.5, -.5, .5, .5] + i, ...
                    obj.BkgPatchColor(mod(i - 1, size(obj.BkgPatchColor, 1)) + 1, :), 'EdgeColor', 'none');
            end
            obj.bkgEdgeHdl =  gobjects(1, obj.SetNum);
            for i = 1:obj.SetNum
                obj.bkgEdgeHdl(i) = plot(obj.axC, obj.axI.XLim([1,2,2,1,1]), [-.5, -.5, .5, .5,-.5] + i, ...
                    'Color','none', 'LineWidth',2);
            end
            % Empty dots.
            [tX, tY] = meshgrid(1:min(MaxBars, obj.nzNum), 1:obj.SetNum);
            obj.bkgDotHdl = plot(obj.axC, tX(:), tY(:), 'o', 'Color',obj.BkgDotColor(1, :), ...
                'MarkerFaceColor',obj.BkgDotColor(1, :), 'MarkerSize',10);
            % Draw connection lines and filled dots for active combinations.
            obj.olineHdl = gobjects(1, min(MaxBars, obj.nzNum));
            for i = 1:min(MaxBars, obj.nzNum)
                tY = find(obj.fulBool(obj.nzIndex(i), obj.sortSetIndex));
                tX = tY.*0 + i;
                obj.olineHdl(i) = plot(obj.axC, tX, tY, '-o', 'Color',obj.LineColor(1, :), ...
                    'MarkerEdgeColor','none', 'MarkerFaceColor',obj.LineColor(1, :), ...
                    'MarkerSize',10, 'LineWidth',2);
            end

        end

        function highlightI(obj, n, Color)
            if nargin < 3
                Color = [.8, 0, 0];
            end
            obj.barHdlI.CData(n, :) = Color;
            set(obj.olineHdl(n), 'Color',Color, 'MarkerFaceColor',Color);
            set(obj.txtHdlI(n), 'Color',Color);
        end

        function highlightS(obj, n, Color)
            if nargin < 3
                Color = [.8, 0, 0];
            end
            obj.barHdlS.CData(n, :) = Color;
            set(obj.txtHdlS(n), 'Color',Color);
            set(obj.nameHdl(n), 'Color',Color);
            set(obj.bkgEdgeHdl(n), 'Color',Color);
        end

        function reverseXDir(obj)
            obj.axC.XDir = 'reverse';
            obj.axI.XDir = 'reverse';
        end
        function reverseYDir(obj)
            obj.axC.YDir = 'reverse';
            obj.axS.YDir = 'reverse';
            for i = 1:obj.SetNum
                obj.nameHdl(i).Position = obj.namePos(obj.SetNum + 1 - i, :);
            end
        end
    end
end