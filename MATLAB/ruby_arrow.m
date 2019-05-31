%% RUBY_ARROW quiver plot to the given file
%   RUBY_ARROW(file, P, v) takes a 'file' opened with RUBY_CREATE.
%   P is the position vector (3-by-1 matrix), v is the direction vector.
%
%   RUBY_ARROW(..., 'color', COLOR) defines the color of the arrow. COLOR
%   is either a char ('n' none-default, 'w' white, 'r' red, 'o' orange,
%   'y' yellow, 'g' green, 'b' blue, 'p' pink, 'k' black) or a tripple set
%   of rgb values [r, g, b] beteen 0 and 255.
%
%   RUBY_ARROW(..., 'name', NAME) NAME is a string label.
%
%   Examples:
%       file = ruby_create()                      % Open and prepare file
%       ruby_arrow(file, [5; 5; 5], [1; 0; 0])    % Draw arrow at 5,5,5
%       ruby_arrow(file, [5; 5; 5], [0; 1; 0],...
%                  'color', 'r'))                 % In red
%       ruby_arrow(file, [5; 5; 5], [0; 0; 1],...
%                  'color', [0, 0, 255])          % In blue
%       ruby_arrow(file, [8; 8; 8], [1; 0; 0],...
%                  'name', string('Arrow1'))      % With label
%       ruby_close(file);                         % Close file (mandatory)
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

function [] = ruby_arrow(file, P, v, varargin)
%% load constants
    ruby_params;

%% Parse parameters
    parser = inputParser;

    checkP = @(x) (isnumeric(x) && size(x, 1) == 3 && size(x, 2) == 1);

    checkV = @(x) (isnumeric(x) && size(x, 1) == 3 && size(x, 2) == 1);

    addRequired(parser, 'file');
    addRequired(parser, 'P', checkP);
    addRequired(parser, 'v', checkV);
    addParameter(parser, 'color', defaultColor, checkColor);
    addParameter(parser, 'name', defaultName, checkName);

    parse(parser, file, P, v, varargin{:});

    file_id = parser.Results.file.id;
    P = SCALE_FACTOR * parser.Results.P;
    v = parser.Results.v;
    name = parser.Results.name;
    color = parser.Results.color;

    % Cross product with unity vector as rotation axis
    V = [-v(2); v(1); 0];
    % Angle around that axis
    t = atan2(norm(V), v(3));
    % Min rotation angle used to avoid issue with 0 and pi rotation
    tol_angle = 0.001 * pi / 180;

%% Write to file
    fwrite(file_id, 'arr1 = arr0.copy');
    ruby_newline(file_id);

    fwrite(file_id, ['s = Geom::Transformation.scaling(',...
        num2str(norm(v)), ',', num2str(norm(v)), ',', num2str(norm(v)), ')']);
    ruby_newline(file_id);

    if abs(t) >  tol_angle
        if abs(abs(t) - pi) > tol_angle
            V = V / norm(V);
            fwrite(file_id, ['r = Geom::Transformation.rotation([0,0,0],[',...
                num2str(V(1)), ',', num2str(V(2)), ',', num2str(V(3)), '],',...
                num2str(t), ')']);
            ruby_newline(file_id);
        else
            fwrite(file_id, ['r = Geom::Transformation.rotation([0,0,0],',...
                '[1,0,0],', num2str(pi), ')']);
            ruby_newline(file_id);
        end
    end

    fwrite(file_id, ['t = Geom::Transformation.new([',...
        num2str(P(1)), ',', num2str(P(2)), ',', num2str(P(3)), '])']);
    ruby_newline(file_id);

    fwrite(file_id, 'arr1.entities.transform_entities(s,arr1)');
    ruby_newline(file_id);

    if abs(t) >  tol_angle
        fwrite(file_id, 'arr1.entities.transform_entities(r,arr1)');
        ruby_newline(file_id);
    end

    fwrite(file_id, 'arr1.entities.transform_entities(t,arr1)');
    ruby_newline(file_id);

    if(color ~= 'n')
        fwrite(file_id,['arr1.material = ', ruby_rgb_color(color)]);
        ruby_newline(file_id);
    end

    if(strlength(name) ~= 0)
        fwrite(file_id,['arr1.name =', char(39), char(name), char(39)]);
        ruby_newline(file_id);
    end

    ruby_newline(file_id);
    ruby_newline(file_id);
end
