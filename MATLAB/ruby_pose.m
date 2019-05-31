%% RUBY_POSE Writes a pose to the given file
%   RUBY_POSE(file, P, R) takes a 'file' opened with RUBY_CREATE. P is the
%   center of the projection and R is the 3-by-3 orienation matrix.
%   The photo is taken in the -Z direction
% 
%   RUBY_POSE(..., 'focal', F) uses F as focal length (default 0.2).
%
%   RUBY_POSE(..., 'width', W, 'height', H) uses W and H as scenery width
%   and height (default 0.1 both).
%
%   RUBY_POSE(..., 'color', COLOR) fills the pose with color.
%   COLOR is either a char ('n' none-default, 'w' white, 'r' red, 'o' orange,
%   'y' yellow, 'g' green, 'b' blue, 'p' pink, 'k' black) or a tripple set
%   of rgb values [r, g, b] beteen 0 and 255.
% 
%   RUBY_POSE(..., 'name', NAME) NAME is a string label of the pose.
%
%   Examples:
%       file = ruby_create()                    % Open and prepare file
%       R = [1,  0,      0;...
%            0,  cos(1), sin(1);...
%            0, -sin(1), cos(1)]                % Create orientation matrix
%       ruby_pose(file, [2, 2, 2], R)           % Write pose to file
%       ruby_pose(file, [3, 3, 3], R, 'focal', 0.2,...
%                 'height', 0.4, 'width', 0.6)  % Change parameters of pose
%       ruby_pose(file, [2, 2, 2], R,...
%                 'color', 'r')                 % Red pose
%       ruby_pose(file, [2, 2, 2], R,...
%                  'color', [0, 0, 255])        % Blue pose
%       ruby_pose(file, [2, 2, 2], R,...
%                  'name', string('Pose3'))     % Labeled pose
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

function [] = ruby_pose(file, P, R, varargin)
    %% load constants
    ruby_params;

    %% read arguments
    parser = inputParser;

    checkP = @(x) (isnumeric(x) && size(x, 1) == 1 && size(x, 2) == 3);

    checkR = @(x) (isnumeric(x) && size(x, 1) == 3 && size(x, 2) == 3 && all(all(round(x'*x) == round(x*x'))));

    defaultFocalLength = 0.2;
    checkFocalLength = @(x) (isnumeric(x));

    defaultWidth = 0.1;
    checkWidth = @(x) (isnumeric(x));

    defaultHeight = 0.1;
    checkHeight = @(x) (isnumeric(x));

    addRequired(parser, 'file');
    addRequired(parser, 'P', checkP);
    addRequired(parser, 'R', checkR);
    addParameter(parser, 'focal', defaultFocalLength, checkFocalLength);
    addParameter(parser, 'width', defaultWidth, checkWidth);
    addParameter(parser, 'height', defaultHeight, checkHeight);
    addParameter(parser, 'color', defaultColor, checkColor);
    addParameter(parser, 'name', defaultName, checkName);

    parse(parser, file, P, R, varargin{:});

    file_id = parser.Results.file.id;
    P = parser.Results.P;
    R = parser.Results.R;
    f = parser.Results.focal;
    s1 = parser.Results.width;
    s2 = parser.Results.height;
    color = parser.Results.color;
    name = parser.Results.name;
    

    %% prepare arguments
    P = P' * SCALE_FACTOR;
    R = R  * SCALE_FACTOR;

    ex = R(:, 1);
    ey = R(:, 2);
    ez = R(:, 3);

    a = P + s1 * ex + s2 * ey - f * ez;
    b = P - s1 * ex + s2 * ey - f * ez;
    c = P - s1 * ex - s2 * ey - f * ez;
    d = P + s1 * ex - s2 * ey - f * ez;

    fwrite(file_id, 'group = Sketchup.active_model.entities.add_group');
    ruby_newline(file_id);

    fwrite(file_id, ['group.entities.add_line([',...
        num2str(P(1)),',',...
        num2str(P(2)),',',...
        num2str(P(3)),'],[',...
        num2str(a(1)),',',...
        num2str(a(2)),',',...
        num2str(a(3)),'])']);
    ruby_newline(file_id);

    fwrite(file_id, ['group.entities.add_line([',...
        num2str(P(1)), ',',...
        num2str(P(2)), ',',...
        num2str(P(3)), '],[',...
        num2str(b(1)), ',',...
        num2str(b(2)), ',',...
        num2str(b(3)), '])']);
    ruby_newline(file_id);

    fwrite(file_id, ['group.entities.add_line([',...
        num2str(P(1)), ',',...
        num2str(P(2)), ',',...
        num2str(P(3)), '],[',...
        num2str(c(1)), ',',...
        num2str(c(2)), ',',...
        num2str(c(3)), '])']);
    ruby_newline(file_id);

    fwrite(file_id, ['group.entities.add_line([',...
        num2str(P(1)), ',',...
        num2str(P(2)), ',',...
        num2str(P(3)), '],[',...
        num2str(d(1)), ',',...
        num2str(d(2)), ',',...
        num2str(d(3)), '])']);
    ruby_newline(file_id);

    fwrite(file_id, ['f = group.entities.add_face([',...
        num2str(a(1)), ',',...
        num2str(a(2)), ',',...
        num2str(a(3)), '],[',...
        num2str(b(1)), ',',...
        num2str(b(2)), ',',...
        num2str(b(3)), '],[',...
        num2str(c(1)), ',',...
        num2str(c(2)), ',',...
        num2str(c(3)), '],[',...
        num2str(d(1)), ',',...
        num2str(d(2)), ',',...
        num2str(d(3)), '])']);
    ruby_newline(file_id);
    
    fwrite(file_id, 'f.material = [255,10,1]');
    ruby_newline(file_id);

    fwrite(file_id, 'f.material.alpha = 0.5');
    ruby_newline(file_id);
    
    if(color ~= 'n')
        fwrite(file_id,['group.material = ', ruby_rgb_color(color)]);
        ruby_newline(file_id);
    end

    if(strlength(name) ~= 0)
        fwrite(file_id,['group.name =', char(39), char(name), char(39)]);
        ruby_newline(file_id);
    end
    
    ruby_newline(file_id);
    ruby_newline(file_id);
end
