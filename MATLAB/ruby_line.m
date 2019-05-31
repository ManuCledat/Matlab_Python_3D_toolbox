%% RUBY_LINE adds a polyline to the given file
%   RUBY_LINE(file, XYZ) takes a 'file' opened with RUBY_CREATE and an array
%   XYZ = [ X1 Y1 Z1;
%           X2 Y2 Z2;
%           ........
%           Xn Yn Zn; ]
%   writing a polyline through the points [ X1 Y1 Z1] , [ X2 Y2 Z2] ...
%   to the file.
%
%   RUBY_LINE(..., 'name', NAME) NAME is a string label of the line.
%
%   Examples:
%       file = ruby_create()                    % Open and prepare file
%       ruby_line(file, [0, 0, 5;...
%                        5, 0, 5])              % Draws a simple line
%       ruby_line(file, [0, 0, 0;...
%                        1, 0, 0;...
%                        1, 1, 0;...
%                        0, 1, 0;...
%                        0, 1, 1;...
%                        0, 0, 1;...
%                        1, 0, 1])              % Draws the edges of a cube
%       ruby_line(file, [0, 0, 5;...
%                        5, 0, 5]
%                        'name',...
%                        string('Line1'))       % With label
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

function [] = ruby_line(file, XYZ, varargin)
%% load constants
    ruby_params;
    
%% extract parameters
    parser = inputParser;

    checkXYZ = @(x) (isnumeric(x) && size(x, 2) == 3 && size(x, 1) > 1);

    addRequired(parser, 'file');
    addRequired(parser, 'XYZ', checkXYZ);
    addParameter(parser, 'name', defaultName, checkName);

    parse(parser, file, XYZ, varargin{:})

    file_id = parser.Results.file.id;
    XYZ = parser.Results.XYZ;
    name = parser.Results.name;
    
%% write to file
    fwrite(file_id, 'group = Sketchup.active_model.entities.add_group');
    ruby_newline(file_id);

    for i = 1 : (size(XYZ, 1) - 1)
          fwrite(file_id, ['group.entities.add_line([',...
              num2str(SCALE_FACTOR * XYZ(i,  1)), ',',...
              num2str(SCALE_FACTOR * XYZ(i,  2)), ',',...
              num2str(SCALE_FACTOR * XYZ(i,  3)), '],[',...
              num2str(SCALE_FACTOR * XYZ(i + 1, 1)), ',',...
              num2str(SCALE_FACTOR * XYZ(i + 1, 2)), ',',...
              num2str(SCALE_FACTOR * XYZ(i + 1, 3)), '])']);
          ruby_newline(file_id);
    end
    
    if(strlength(name) ~= 0)
        fwrite(file_id,['group.name =', char(39), char(name), char(39)]);
        ruby_newline(file_id);
    end

    ruby_newline(file_id);
    ruby_newline(file_id);
end
