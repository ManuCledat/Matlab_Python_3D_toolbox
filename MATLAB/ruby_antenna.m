%% RUBY_ANTENNA Writes an antenna symbol to the given file.
%   RUBY_ANTENNA(file, XYZ) takes a 'file' opened with RUBY_CREATE and an array
%   XYZ = [ X1 Y1 Z1;
%           X2 Y2 Z2;
%           ........
%           Xn Yn Zn; ]
%   and adds the antennas at [ X1 Y1 Z1] , [ X2 Y2 Z2] ... to the file
%
%   RUBY_ANTENNA(..., 'color', COLOR) changes the default color (red) to
%   COLOR. COLOR is either a char ('n' none-default, 'w' white, 'r' red,
%   'o' orange, 'y' yellow, 'g' green, 'b' blue, 'p' pink, 'k' black) or a
%   tripple set of rgb values [r, g, b] beteen 0 and 255
%
%   RUBY_ANTENNA(..., 'name', NAME) NAME is a string or a list of strings
%   with the name(s) for all or each antenna.
%
%
%   Examples:
%       file = ruby_create()                    % Open and prepare file
%       ruby_antenna(file, [2, 2, 2])           % Create antenna at 2,2,2
%       ruby_antenna(file, [2, 2, 2],...
%                    'color', 'g')              % Green antenna
%       ruby_antenna(file, [2, 2, 2],...
%                    'color', [0, 0, 255])      % Blue antenna
%       ruby_antenna(file, [2, 2, 2],...
%                    'name', string('Ant1'))    % Add antenna name
%       ruby_close(file);                       % Close file (mandatory)

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

function ruby_antenna(file, XYZ, varargin)
%% load constants
    ruby_params;

%% extract parameters
    parser = inputParser;

    checkXYZ = @(x) (isnumeric(x) && size(x, 1) >= 1 && size(x, 2) == 3);

    checkNames = @(x) (isstring(x) || ischar(x)) && size(x, 2) == 1 &&...
        (size(x, 1) == 1 || size(x, 1) == size(P, 1));

    % Override default color in ruby_params
    defaultColor = 'r';

    addRequired(parser, 'file');
    addRequired(parser, 'XYZ', checkXYZ);
    addParameter(parser, 'color', defaultColor, checkColor);
    addParameter(parser, 'name', defaultName, checkNames);

    parse(parser, file, XYZ, varargin{:});

    file_id = parser.Results.file.id;
    XYZ = parser.Results.XYZ;
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

    ruby_newline(file_id);
    fwrite(file_id,'antenna = Sketchup.active_model.entities.add_group');
    ruby_newline(file_id);

    width = 0.2;
    height = 2;

    for i = 1 : size(XYZ, 1)
        xi = XYZ(i, 1);
        yi = XYZ(i, 2);
        zi = XYZ(i, 3);
        ruby_newline(file_id);
        fwrite(file_id,'points=[[');

        fwrite(file_id,[                         ...
        num2str(SCALE_FACTOR * (xi - width * 0.5)),',',...
        num2str(SCALE_FACTOR * (yi)),',',...
        num2str(SCALE_FACTOR * (zi)), '],[']  );

        fwrite(file_id,[                         ...
        num2str(SCALE_FACTOR * (xi + width * 0.5)),',',...
        num2str(SCALE_FACTOR * (yi)),',',...
        num2str(SCALE_FACTOR * (zi)), '],[']  );

        fwrite(file_id,[                         ...
        num2str(SCALE_FACTOR * (xi + width * 0.5)),',',...
        num2str(SCALE_FACTOR * (yi)),',',...
        num2str(SCALE_FACTOR * (zi + height)), '],[']  );

        fwrite(file_id,[                         ...
        num2str(SCALE_FACTOR * (xi - width * 0.5)),',',...
        num2str(SCALE_FACTOR * (yi)),',',...
        num2str(SCALE_FACTOR * (zi + height)), ']]']  );

        ruby_newline(file_id);
        fwrite(file_id,'f2 = antenna.entities.add_face(points)');
        ruby_newline(file_id);
        fwrite(file_id,['c2 = antenna.entities.add_circle([', ...
          num2str(SCALE_FACTOR * xi), ',', ...
          num2str(SCALE_FACTOR * yi), ',', ...
          num2str(SCALE_FACTOR * zi), ...
          '],Z_AXIS,39.3701* 0.01,24)']);
        ruby_newline(file_id);
        fwrite(file_id,'f2.followme(c2)');
        ruby_newline(file_id);

        if(color ~= 'n')
            fwrite(file_id,['antenna.material = ', ruby_rgb_color(color)]);
            ruby_newline(file_id);
        end

        if(strlength(name_vector(i, 1)) ~= 0)
            fwrite(file_id,['antenna.name =', char(39), char(name_vector(i, 1)), char(39)]);
            ruby_newline(file_id);
        end
    end
end
