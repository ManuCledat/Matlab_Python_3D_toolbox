%% RUBY_PLANE adds a plane to the given file
%   RUBY_PLANE(file, XYZ) takes a 'file' opened with RUBY_CREATE and a
%   3-by-N (N >= 3) matrix of coplanar points XYZ. The points define and
%   limit the plane.
%
%   RUBY_PLANE(..., 'texture', TEXTURE) Path to an image file with extension
%   .png .jpg or .jpeg
%
%   RUBY_PLANE(..., 'color', COLOR) fills the plane with color.
%   COLOR is either a char ('n' none-default, 'w' white, 'r' red, 'o' orange,
%   'y' yellow, 'g' green, 'b' blue, 'p' pink, 'k' black) or a tripple set
%   of rgb values [r, g, b] beteen 0 and 255.
%
%   RUBY_PLANE(..., 'name', NAME) NAME is a string label of the plane.
%
%   Examples:
%       file = ruby_create()                      % Open and prepare file
%       ruby_plane(file, [0, 0, 3;...
%                         0, 3, 0;...
%                         3, 0, 0])               % Create triangle
%       ruby_plane(file, [0, 1, 3;...
%                         0, 1, 5;...
%                         1, 2, 5;...
%                         1, 2, 3])               % Create rectangle
%       ruby_plane(file, [3, 3, 6;...
%                         0, 3, 0;...
%                         3, 0, 0],...
%                         'color', 'r')           % Create red triangle
%       ruby_plane(file, [6, 6, 9;...
%                         0, 3, 0;...
%                         3, 0, 0],...
%                         'color', [0, 0, 255])   % Create blue triangle
%       ruby_plane(file, [9, 9, 12;...
%                         0, 3, 0;...
%                         3, 0, 0],...
%                         'texture',...
%                         '/images/rainbow.jpeg') % Add texture
%       ruby_plane(file, [12, 12, 15;...
%                         0,  3,  0;...
%                         2,  0,  0],...
%                         'name',...
%                         string('Triangle'))     % With label
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

function [] = ruby_plane(file, XYZ, varargin)
%% load constants
    ruby_params;

    parser = inputParser;

    checkXYZ = @(x) (isnumeric(x) && size(x, 2) == 3 && size(x, 1) > 2);

    defaultColor = 'w';

    default_texture = 'none';
    checkTexture = @(x) (isstring(x) || ischar(x));

    addRequired(parser, 'file');
    addRequired(parser, 'XYZ', checkXYZ);
    addParameter(parser, 'color', defaultColor, checkColor);
    addParameter(parser, 'texture', default_texture, checkTexture);
    addParameter(parser, 'name', defaultName, checkName);

    parse(parser, file, XYZ, varargin{:});

    file_id = parser.Results.file.id;
    XYZ = parser.Results.XYZ;
    color = parser.Results.color;
    name = parser.Results.name;
    texture = parser.Results.texture;

    isColinear = true;
    % check if the points form a line
    for i = 1 : size(XYZ, 1) - 2
        A = [XYZ(i    , 1), XYZ(i,     2), XYZ(i,     3)];
        B = [XYZ(i + 1, 1), XYZ(i + 1, 2), XYZ(i + 1, 3)];
        C = [XYZ(i + 2, 1), XYZ(i + 2, 2), XYZ(i + 2, 3)];
        cross_product  = cross(B - A, C - A);

        if norm(cross_product) > TOL_CROSS_PRODUCT
            isColinear = false;
        end
    end

    if(isColinear)
        error('error in ruby_plane. The points are colinear.')
    end

    if(size(XYZ, 1) ~= 3)
        % check if the points are coplanar
        for i = 1 : size(XYZ, 1) - 3
            volume = [XYZ(i    , 1), XYZ(i,     2), XYZ(i,     3), 1; ...
                      XYZ(i + 1, 1), XYZ(i + 1, 2), XYZ(i + 1, 3), 1; ...
                      XYZ(i + 2, 1), XYZ(i + 2, 2), XYZ(i + 2, 3), 1; ...
                      XYZ(i + 3, 1), XYZ(i + 3, 2), XYZ(i + 3, 3), 1; ...
                      ];
            if abs(det(volume)) > TOL_COPLANARITY
                error('error in ruby_plane. Points are not coplanar.')
            end
        end
    end

    fwrite(file_id, 'plane = Sketchup.active_model.entities.add_group');
    ruby_newline(file_id);

    fwrite(file_id, 'plane_entities = plane.entities');
    ruby_newline(file_id);

    fwrite(file_id, 'pts=[[');
    for i = 1 : (size(XYZ, 1) - 1)
          fwrite(file_id,[                         ...
              num2str(SCALE_FACTOR * XYZ(i,  1)),',',...
              num2str(SCALE_FACTOR * XYZ(i,  2)),',',...
              num2str(SCALE_FACTOR * XYZ(i,  3)), '],[']  );
    end
          fwrite(file_id,[                         ...
              num2str(SCALE_FACTOR * XYZ(end,  1)),',',...
              num2str(SCALE_FACTOR * XYZ(end,  2)),',',...
              num2str(SCALE_FACTOR * XYZ(end,  3)), ']]' ]  );
          ruby_newline(file_id);

    fwrite(file_id,'face = plane_entities.add_face(pts)');
    ruby_newline(file_id);

    if(color ~= 'n')
        fwrite(file_id,['plane.material = ', ruby_rgb_color(color)]);
        ruby_newline(file_id);
    end

    if(strlength(name) ~= 0)
        fwrite(file_id,['plane.name =', char(39), char(name), char(39)]);
        ruby_newline(file_id);
    end

    max_x = max(XYZ(:, 1));
    max_y = max(XYZ(:, 2));
    max_z = max(XYZ(:, 3));

    min_x = min(XYZ(:, 1));
    min_y = min(XYZ(:, 2));
    min_z = min(XYZ(:, 3));

    abs_x = abs(max_x - min_x);
    abs_y = abs(max_y - min_y);
    abs_z = abs(max_z - min_z);

    plane_size = max(max(abs_x, abs_y), abs_z);

    if(~isequal(texture, 'none'))
        fwrite(file_id, ['texture_path = "', '#{File.dirname(__FILE__)}', texture '"']);
        ruby_newline(file_id);

        fwrite(file_id, 'materials=Sketchup.active_model.materials');
        ruby_newline(file_id);

        fwrite(file_id, 'plane_t = materials.add "plane texture"');
        ruby_newline(file_id);

        fwrite(file_id, 'plane_t.texture = texture_path');
        ruby_newline(file_id);

        fwrite(file_id, ['plane_t.texture.size = ',...
            num2str(plane_size * SCALE_FACTOR)]);
        ruby_newline(file_id);

        fwrite(file_id, 'plane.material = plane_t');
        ruby_newline(file_id);
    end
    ruby_newline(file_id);

    fwrite(file_id, 'plane = plane.explode');
    ruby_newline(file_id);

    fwrite(file_id, 'plane_face = nil');
    ruby_newline(file_id);

    fwrite(file_id, 'plane.each{|p| ');
    ruby_newline(file_id);

    fwrite(file_id, 'if p.is_a?(Sketchup::Face )');
    ruby_newline(file_id);

    fwrite(file_id, 'plane_face=p');
    ruby_newline(file_id);

    fwrite(file_id, 'end}');
    ruby_newline(file_id);
end
