% EXEMPLE Example script for the ruby3d library

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

%% Clean
clear
clc

%% Mandatory initialisation

% Creates file in local folder with name 'script_ruby_3d.rb'.
% Returns file structure containing id, path and name.
file = ruby_create();

% Alternative specifying name or rel. path. .rb is appended 'my_model.rb'.
% file = ruby_create('my_model');

% Alternative specifying full path. .rb is appended 'C:\Users\my_model.rb'.
%file = ruby_create('C:\Users','my_model');


%% Point construction

% Construct some points (Here [2,2,2] and [3,3,3])
ruby_point(file, [2, 2, 2; 3, 2, 3]);

% To represent all points with a symbol, set the third argument to 1
ruby_point(file, [2, 3, 2; 3, 3, 3], 1);

% Symbol representation can be activated point by point
ruby_point(file, [2, 4, 2; 3, 4, 3], [1; 0]);

% The symbol is selected with a name-value pair. All points have the same
% symbol
ruby_point(file, [2, 5, 2; 3, 5, 3], 1, 'symbol', 'cross');

% Colors can be defined with a char ('n' none-default, 'w' white, 'r' red,
% 'o' orange, 'y' yellow, 'g' green, 'b' blue, 'p' pink, 'k' black) or a
% tripple set of rgb values [r, g, b] beteen 0 and 255.
ruby_point(file, [2, 6, 2; 3, 6, 3], 1, 'symbol', 'circle', 'color', 'r');
ruby_point(file, [2, 7, 2; 3, 7, 3], 1, 'symbol', 'square',...
    'color', [0, 0, 255]);

% Points can be named globally or individually using a single string or an
% array of strings.
ruby_point(file, [2, 2, 2; 3, 3, 3], 1, 'name', string('Pts'));
ruby_point(file, [2, 2, 2; 3, 3, 3], 1, 'name',...
    [string('pt1'); string('pt2')]);

%% Line construction

% A line is defined by a set of at least two points.
% The first point will be connected with the second, and so on
my_cube = [0 0 0;...
           1 0 0;...
           1 1 0;...
           0 1 0;...
           0 1 1;...
           0 0 1;...
           1 0 1;...
           1 1 1];

ruby_line(file, my_cube);

% If required it is possible to name the drawn line.
ruby_line(file, [0, 0, 5; 5, 0, 5], 'name', string('Line1'));


%% Axis construction

% Constructs a set of three axis
% The position is given by a 3-by-1 matrix while the orientation of the
% three axis is given by the orthogonal matrix R (R * R' = R' * R = eye(3))
% There is no verification step

R = [1,  0,      0;...
     0,  cos(1), sin(1);...
     0, -sin(1), cos(1)];

ruby_axis(file, [4, 4, 4], R);

% If required, a name can be passed as argument
ruby_axis(file, [4, 5, 4], R, 'name', string('Origin2'));

%% Pose construction

% Permits to visualize a pose.
% The position is given by a 3-by-1 matrix, the orientation by the
% orthogonal matrix R (R * R' = R' * R = eye(3)). There is no verification.
% The photo is taken in the -Z direction
ruby_pose(file, [5,5,5], R);

% If required, name-value pairs can be used to set different parameters:
% Focal distance
ruby_pose(file, [6,5,5], R, 'focal', 0.1);

% The width and the height
ruby_pose(file, [7,5,5], R, 'focal', 0.1, 'width', 0.3, 'height', 0.2);

% Name
ruby_pose(file, [8,5,5], R, 'focal', 0.1, 'width', 0.3, 'height', 0.2, 'name', string('f0.1w0.3h0.2'));

% color
ruby_pose(file, [9,5,5], R, 'focal', 0.1, 'width', 0.3, 'height', 0.2, 'color', 'b');

% rgb-color
ruby_pose(file, [10,5,5], R, 'focal', 0.1, 'width', 0.3, 'height', 0.2, 'color', [255, 0, 63]);


%% Ellipsoid construction

%Permits to visualize an error ellipsoid
%Takes the center of the ellipsoid, and the variance-covariance matrix
Kxx = [ 1.666   -0.424    0.244;...
       -0.424    2.961   -0.558;...
        0.244   -0.558    4.121];
ruby_ellipsoid(file, [0,0,5], Kxx);

% Colors can be defined with a char ('n' none-default, 'w' white, 'r' red,
% 'o' orange, 'y' yellow, 'g' green, 'b' blue, 'p' pink, 'k' black) or a
% tripple set of rgb values [r, g, b] beteen 0 and 255.
ruby_ellipsoid(file, [0,0,10], Kxx, 'color', 'r');
ruby_ellipsoid(file, [0,0,15], Kxx, 'color', 'o');
ruby_ellipsoid(file, [0,0,20], Kxx, 'color', 'y');
ruby_ellipsoid(file, [0,0,25], Kxx, 'color', 'g');
ruby_ellipsoid(file, [0,0,30], Kxx, 'color', 'b');
ruby_ellipsoid(file, [0,0,35], Kxx, 'color', 'p');
ruby_ellipsoid(file, [0,0,40], Kxx, 'color', 'k');
ruby_ellipsoid(file, [0,0,45], Kxx, 'color', [248,123,156]);

% If required, a label can be given as well
ruby_ellipsoid(file, [0,0, 5], Kxx, 'name', string('Pos1'))


%% Plane construction

% Permits to draw a polygone. Takes a 3-by-N (N >= 3) matrix of coplanar
% points XYZ. The points define and limit the plane. If required, a name
% can be set. The polygone can be filled either with a texture or a color
% using the name-value pairs. Available colors are 'n' none-default,
% 'w' white, 'r' red, 'o' orange, 'y' yellow, 'g' green, 'b' blue,
% 'p' pink, 'k' black) or a tripple set of rgb values [r, g, b] beteen
% 0 and 255.

% triangle with texture and name
ruby_plane(file, [0, 0, 3; 0, 3, 0; 2, 0, 0],...
    'texture', '/images/rainbow.jpeg', 'name', string('myplane'));

% rectangle with red color
ruby_plane(file, [0, 1, 3; 0, 1, 5; 1, 2, 5; 1, 2, 3], 'color', 'r');

% triangle with blue color
ruby_plane(file, [0, 4, 3; 0, 7, 0; 2, 4, 0], 'color', [0, 0, 255]);

% inclined polygone
ruby_plane(file, [5, 0, 0;...
                  5, 2, 2;...
                  6, 2, 2;...
                  6, 1, 1;...
                  7, 1, 1;...
                  7, 2, 2;...
                  8, 1, 1;...
                  8, 0, 0]);

%% DEM TIN creation

% Draws DEM (Digital Elevation Model) having TIN (Triangular Irregular
% Network)structure, taking a set of points and the corresponding
% triangles. Triangles can be obtained using the delaunay function. The
% data structure of the triangles is presented in delaunay function help.

% Optional arguments are texture, name and color and can be given in
% name-value pairs.

Points = [ 10 * rand(100,1) + 10 , 10*rand(100,1) ,  randn(100,1) ];

triangles = delaunay(Points(:, 1:2));

ruby_tin(file, Points, triangles, 'texture', '/images/rainbow.jpeg',...
    'name', string('Elevation'))

%% Arrows, or Quiver plot

% Permits to draw a single arrow, taking the position (3-by-1 matrix) and
% direction vector. If required, name and color can be defined using
% name-value pairs. Colors are either a char ('n' none-default, 'w' white,
% 'r' red, 'o' orange, 'y' yellow, 'g' green, 'b' blue, 'p' pink, 'k' black
% or a tripple set of rgb values [r, g, b] beteen 0 and 255.

% Draw arrow at 5,5,5
ruby_arrow(file, [5;5;5], [1;2;3]);
% In red
ruby_arrow(file, [7;5;5], [1;2;3], 'color', 'r');
% In blue with label
ruby_arrow(file, [9;5;5], [1;2;3], 'color', [0, 0, 255],...
    'name', string('Blue Arrow'));

%% Antenna

% Creates an antenna symbol based on 1-by-3 array of coordinates. If
% required, name and color can be defined using name-value pairs. Colors
% are either a char ('r' red-default, 'w' white, 'n' none, 'o' orange,
% 'y' yellow, 'g' green, 'b' blue, 'p' pink, 'k' black or a tripple set of
% rgb values [r, g, b] beteen 0 and 255.

% Create default antenna at 2,2,2
ruby_antenna(file, [2, 2, 2]);
% Green antenna
ruby_antenna(file, [4, 2, 2], 'color', 'g')
% Blue antenna with label
ruby_antenna(file, [6, 2, 2], 'color', [0, 0, 255], 'name', string('Ant1'));

%% Mandatory closing

ruby_close(file);
