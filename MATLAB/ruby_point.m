%% RUBY_POINT Constructs isolated points in the given file.
%   RUBY_POINT(file, XYZ) takes a 'file' opened with RUBY_CREATE and an array
%   XYZ = [ X1 Y1 Z1;
%           X2 Y2 Z2;
%           ........
%           Xn Yn Zn; ]
%   and adds the points [ X1 Y1 Z1] , [ X2 Y2 Z2] ... to the file
% 
%   RUBY_POINT(..., v) uses the additional argument v to assign a symbol to
%   the point (1) or not (0, default). v can be a single number or a column
%   vector the same length as XYZ.
%
%   RUBY_POINT(..., v, 'symbol', SYMBOL) represents the symbol points with a
%   cross. SYMBOL can be 'triangle' (default), 'cross', 'circle', 'square'.
%
%   RUBY_POINT(..., v, 'color', COLOR) fills the symbol with color.
%   COLOR is either a char ('n' none-default, 'w' white, 'r' red, 'o' orange,
%   'y' yellow, 'g' green, 'b' blue, 'p' pink, 'k' black) or a tripple set
%   of rgb values [r, g, b] beteen 0 and 255.
% 
%   RUBY_POINT(..., v, 'name', NAME) NAME is a string or a list of strings
%   with the name(s) for all or each point.
%
%   Examples:
%       file = ruby_create()                    % Open and prepare file
%       ruby_point(file, [2, 2, 2; 3, 3, 3])    % Create 2 points
%       ruby_point(file, [2, 2, 2; 3, 3, 3], 1) % With symbols
%       ruby_point(file, [2, 2, 2; 3, 3, 3],...
%                  [1; 0])                      % Only first with symbol
%       ruby_point(file, [2, 2, 2], 1,...
%                  'symbol', 'cross')           % Cross instead of triangle
%       ruby_point(file, [2, 2, 2], 1,...
%                  'symbol', 'circle',...
%                  'color', 'r')                % Red circle
%       ruby_point(file, [2, 2, 2], 1,...
%                  'symbol', 'circle',...
%                  'color', [0, 0, 255])        % Blue circle
%       ruby_point(file, [2, 2, 2; 3, 3, 3], 1,...
%                  'name', string('Pts'))       % Name all points 'Pts'
%       ruby_point(file, [2, 2, 2; 3, 3, 3], 1,...
%                  'name', [string('pt1');...
%                           string('pt2')])     % Name all pts differently
%       ruby_close(file);                       % Close file (mandatory)
%
%   See also RUBY_CREATE, RUBY_CLOSE.

%Copyright 2019 TOPO EPFL
%
%Permission is hereby granted, free of charge, to any person obtaining a 
%copy of this software and associated documentation files (the "Software"),
%to deal in the Software without restriction, including without limitation
%the rights to use, copy, modify, merge, publish, distribute, sublicense,
%and/or sell copies of the Software, and to permit persons to whom the
%Software is furnished to do so, subject to the following conditions:
%
%The above copyright notice and this permission notice shall be included in
%all copies or substantial portions of the Software.
%
%THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
%THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
%FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
%DEALINGS IN THE SOFTWARE.

function [] = ruby_point(file, XYZ, varargin)
%% load constants
    ruby_params;

%% parse arguments
    parser = inputParser;

    checkXYZ = @(x) (isnumeric(x) && size(x, 2) == 3); % 3 deep array?

    defaultIsSymbolic = 0;
    checkIsSymbolic = @(x) (isnumeric(x) && all(mod(x, 1) == 0) ...
        && sum(sum(abs(x) > 1)) == 0 && size(x, 2) == 1 ...
        && (size(x, 1) == 1 || size(x, 1) == size(XYZ, 1)));
        % single or points long array of 0 and 1

    checkNames = @(x) (isstring(x) || ischar(x)) && size(x, 2) == 1 &&...
        (size(x, 1) == 1 || size(x, 1) == size(XYZ, 1));

    defaultSymbol = 'triangle';
    validSymbols = {'triangle', 'cross', 'circle', 'square'};
    checkSymbol = @(x) any(validatestring(x, validSymbols));

    addRequired(parser, 'file');
    addRequired(parser, 'XYZ', checkXYZ);
    addOptional(parser, 'issymbolic', defaultIsSymbolic, checkIsSymbolic);
    addParameter(parser, 'symbol', defaultSymbol, checkSymbol);
    addParameter(parser, 'color', defaultColor, checkColor);
    addParameter(parser, 'name', defaultName, checkNames);

    parse(parser, file, XYZ, varargin{:})

    file_id = parser.Results.file.id;

    XYZ = [parser.Results.XYZ, ones(size(parser.Results.XYZ,1), 1) .* parser.Results.issymbolic];
    color = parser.Results.color;
    
    if(size(parser.Results.name, 1) == 1)
        name_vector = string(zeros(size(XYZ, 1), 1));
        name_vector(:) = parser.Results.name;
    elseif(size(parser.Results.name, 1) == 0)
        name_vector = string(zeros(size(XYZ, 1), 1));
        name_vector(:) = '';
    else
        name_vector = parser.Results.name;
    end

%% Start writing points
    count = 0;
    for P = XYZ'

        count = count + 1;

        switch P(4)
            case 0
                fwrite(file_id, ['model.entities.add_cpoint Geom::Point3d.new(',...
                    num2str(SCALE_FACTOR * P(1)), ',',...
                    num2str(SCALE_FACTOR * P(2)), ',',...
                    num2str(SCALE_FACTOR * P(3)), ')']);
                ruby_newline(file_id);

            case 1
                fwrite(file_id, 'group = Sketchup.active_model.entities.add_group');
                ruby_newline(file_id);

                fwrite(file_id, ['group.entities.add_cpoint Geom::Point3d.new(',...
                    num2str(SCALE_FACTOR * P(1)), ',',...
                    num2str(SCALE_FACTOR * P(2)), ',',...
                    num2str(SCALE_FACTOR * P(3)), ')']);
                ruby_newline(file_id);

            switch parser.Results.symbol
                case 'triangle'
                    fwrite(file_id, ['f=group.entities.add_circle([',...
                        num2str(SCALE_FACTOR * P(1)), ',',...
                        num2str(SCALE_FACTOR * P(2)), ',',...
                        num2str(SCALE_FACTOR * P(3)), '],Z_AXIS,20,3)']);
                    ruby_newline(file_id);

                    fwrite(file_id, 'group.entities.add_face(f)');
                    ruby_newline(file_id);

                case 'circle'
                    fwrite(file_id, ['f=group.entities.add_circle([',...
                        num2str(SCALE_FACTOR * P(1)), ',',...
                        num2str(SCALE_FACTOR * P(2)), ',',...
                        num2str(SCALE_FACTOR * P(3)), '],Z_AXIS,20)']);
                    ruby_newline(file_id);

                    fwrite(file_id, 'group.entities.add_face(f)');
                    ruby_newline(file_id);

                case 'cross'
                    fwrite(file_id, ['group.entities.add_line([',...
                        num2str(SCALE_FACTOR * P(1) - 10), ',',...
                        num2str(SCALE_FACTOR * P(2) - 10), ',',...
                        num2str(SCALE_FACTOR * P(3)), '],[',...
                        num2str(SCALE_FACTOR * P(1) + 10), ',',...
                        num2str(SCALE_FACTOR * P(2) + 10), ',',...
                        num2str(SCALE_FACTOR * P(3)), '])']);
                    ruby_newline(file_id);

                    fwrite(file_id, ['group.entities.add_line([',...
                    num2str(SCALE_FACTOR * P(1) - 10), ',',...
                    num2str(SCALE_FACTOR * P(2) + 10), ',',...
                    num2str(SCALE_FACTOR * P(3)), '],[',...
                    num2str(SCALE_FACTOR * P(1) + 10), ',',...
                    num2str(SCALE_FACTOR * P(2) - 10), ',',...
                    num2str(SCALE_FACTOR * P(3)), '])']);
                    ruby_newline(file_id);

                case 'square'
                    fwrite(file_id, ['f=group.entities.add_circle([',...
                        num2str(SCALE_FACTOR * P(1)), ',',...
                        num2str(SCALE_FACTOR * P(2)), ',',...
                        num2str(SCALE_FACTOR * P(3)), '],Z_AXIS,20,4)']);
                    ruby_newline(file_id);

                    fwrite(file_id, 'group.entities.add_face(f)');
                    ruby_newline(file_id);
            end
            
            if(color ~= 'n')
                fwrite(file_id,['group.material = ', ruby_rgb_color(color)]);
                ruby_newline(file_id);
            end
            
            if(strlength(name_vector(count, 1)) ~= 0)
                fwrite(file_id,['group.name =', char(39), char(name_vector(count, 1)), char(39)]);
                ruby_newline(file_id);
            end

        end
        ruby_newline(file_id);
        ruby_newline(file_id);
    end
