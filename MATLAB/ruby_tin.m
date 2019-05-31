%% RUBY_TIN draws DEM (Digital Elevation Model) having TIN structure
%   (Triangular Irregular Network)
%   RUBY_TIN(file, XYZ, triangles) takes a 'file' opened with
%   RUBY_CREATE, a set of points XYZ and the corresponding triangles. Triangles
%   can be obtained using the delaunay function. The data structure of
%   triangles is presented in delaunay function help
%
%   RUBY_TIN(..., 'texture', TEXTURE) Path to an image file with extension
%   .png .jpg or .jpeg
%
%   RUBY_TIN(..., 'color', COLOR) fills the DEM with color.
%   COLOR is either a char ('n' none-default, 'w' white, 'r' red, 'o' orange,
%   'y' yellow, 'g' green, 'b' blue, 'p' pink, 'k' black) or a tripple set
%   of rgb values [r, g, b] beteen 0 and 255.
%
%   RUBY_TIN(..., 'name', NAME) NAME is a string label of the DEM.
%
%   Examples:
%       file = ruby_create()                   % Open and prepare file
%       points = [10 * rand(100, 1) + 10,...
%                 10 * rand(100, 1),...
%                 randn(100, 1)];              % Create points
%       triangles = delaunay(points(:, 1:2));  % Delaunay triangles
%       ruby_tin(file, XYZ, triangles)         % Write DEM to file
%       ruby_tin(file, XYZ, triangles,...
%           'color', 'r')                      % Red DEM
%       ruby_tin(file, XYZ, triangles,...
%           'color', [0, 0, 255])              % Blue DEM
%       ruby_tin(file, XYZ, triangles,...
%           'texture', '/images/rainbow.jpeg') % DEM with texture
%       ruby_tin(file, XYZ, triangles,...
%           'name', string('Elevation'))       % Set label to 'Elevation'
%       ruby_close(file);                      % Close file (mandatory)
%
%   See also RUBY_CREATE, RUBY_CLOSE, DELAUNAY.

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

function [] = ruby_tin(file, XYZ, triangles, varargin)
%% Load constants
    ruby_params;

%% Read arguments
    parser = inputParser;

    checkXYZ = @(x) (isnumeric(x) && size(x, 1) >= 1 && size(x, 2) == 3);

    checkTriangles = @(x) (isnumeric(x) && size(x, 1) >= 1 && size(x, 2) == 3);

    defaultTexture = 0;
    checkTexture = @(x) (isstring(x) || ischar(x));

    addRequired(parser, 'file');
    addRequired(parser, 'XYZ', checkXYZ);
    addRequired(parser, 'triangles', checkTriangles);
    addParameter(parser, 'color', defaultColor, checkColor);
    addParameter(parser, 'texture', defaultTexture, checkTexture);
    addParameter(parser, 'name', defaultName, checkName);

    parse(parser, file, XYZ, triangles, varargin{:});

    file_id = parser.Results.file.id;
    XYZ = parser.Results.XYZ;
    triangles = parser.Results.triangles;
    name = parser.Results.name;
    color = parser.Results.color;
    texture = parser.Results.texture;

    if(sum(sum(triangles < 0))) ~= 0
        error('error in ruby_tin. Triangle does not match with any point');
    end

    if(sum(sum(triangles > size(XYZ, 1)))) ~= 0
        error('error in ruby_tin. Triangle does not match with any point');
    end

%% Write file
    ruby_newline(file_id);
    fwrite(file_id,'group = Sketchup.active_model.entities.add_group');
    ruby_newline(file_id);

    % Creation of points
    for i = 1 : size(XYZ, 1)
        fwrite(file_id, ['p', num2str(i), ' = [',...
            num2str(SCALE_FACTOR * XYZ(i,1)), ',',...
            num2str(SCALE_FACTOR * XYZ(i,2)), ',',...
            num2str(SCALE_FACTOR * XYZ(i,3)), ']']);
        ruby_newline(file_id);
    end
    ruby_newline(file_id);

    % Creation of surface
    for i = 1 : size(triangles, 1)
        fwrite(file_id,['group.entities.add_face(p', num2str(triangles(i, 1)),...
                                               ',p', num2str(triangles(i, 2)),...
                                               ',p', num2str(triangles(i, 3)), ')']);
        ruby_newline(file_id);
    end
    ruby_newline(file_id);

    if(color ~= 'n')
        fwrite(file_id,['group.material = ', ruby_rgb_color(color)]);
        ruby_newline(file_id);
    end

    if(strlength(name) ~= 0)
        fwrite(file_id,['group.name =', char(39), char(name), char(39)]);
        ruby_newline(file_id);
    end

%% Texture
    max_x = max(XYZ(:, 1));
    max_y = max(XYZ(:, 2));
    max_z = max(XYZ(:, 3));

    min_x = min(XYZ(:, 1));
    min_y = min(XYZ(:, 2));
    min_z = min(XYZ(:, 3));

    if(texture ~= 0)
        ruby_plane(file, [min_x, min_y, max_z + 3;...
                          min_x, max_y, max_z + 3;...
                          max_x, max_y, max_z + 3;...
                          max_x, min_y, max_z + 3], 'texture', texture);
        ruby_newline(file_id);

        fwrite(file_id, 'faces = group.entities.grep( Sketchup::Face ).each{|f| f.material = plane_face.material }');
        ruby_newline(file_id);

        fwrite(file_id, 'faces = group.entities.grep( Sketchup::Face ).each{|f| f.set_texture_projection(plane_face.normal, true) }');
        ruby_newline(file_id);

        fwrite(file_id, 'faces = group.entities.grep( Sketchup::Face ).each{|f| f.back_material = plane_face.material }');
        ruby_newline(file_id);

        fwrite(file_id, 'faces = group.entities.grep( Sketchup::Face ).each{|f| f.set_texture_projection(plane_face.normal, false) }');
        ruby_newline(file_id);

        fwrite(file_id, 'plane.each{|p| ');
        ruby_newline(file_id);

        fwrite(file_id, 'if p.is_a?(Sketchup::Edge )');
        ruby_newline(file_id);

        fwrite(file_id, 'p.erase!');
        ruby_newline(file_id);

        fwrite(file_id, 'end}');
        ruby_newline(file_id);
    end
end
