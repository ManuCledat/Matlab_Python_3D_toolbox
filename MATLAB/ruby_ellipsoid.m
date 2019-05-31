%% RUBY_ELLIPSOID adds an error ellipsoid to the given file
%   RUBY_ELLIPSOID(file, P, K) takes a 'file' opened with RUBY_CREATE.
%   P is a 1-by-3 matrix with the position, K is a 3-by-3 variance-covariance
%   matrix
%
%   RUBY_ELLIPSOID(..., 'color', COLOR) defines the color of the ellipsoid.
%   COLOR is either a char ('n' none-default, 'w' white, 'r' red, 'o' orange,
%   'y' yellow, 'g' green, 'b' blue, 'p' pink, 'k' black) or a tripple set
%   of rgb values [r, g, b] beteen 0 and 255.
%
%   RUBY_ELLIPSOID(..., 'name', NAME) NAME is a string label.
%
%   Examples:
%       file = ruby_create()                   % Open and prepare file
%       K = [ 1.666   -0.424    0.244;...
%             -0.424   2.961   -0.558;...
%             0.244   -0.558    4.121];        % Create error matrix
%       ruby_ellipsoid(file, [0, 0, 5], K)     % Create Ellispoid
%       ruby_ellipsoid(file, [0, 0, 5], K,...
%                      'color', 'r')           % Make it red
%       ruby_ellipsoid(file, [0, 0, 5], K,...
%                      'color', [0, 0, 255])   % Make it blue
%       ruby_ellipsoid(file, [0, 0, 5], K,...
%                      'name', string('Pos1')) % With label
%       ruby_close(file);                      % Close file (mandatory)
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

function [] = ruby_ellipsoid(file, P, K, varargin)
%% load constants
    ruby_params;

%% Parse parameters
    parser = inputParser;

    checkP = @(x) (isnumeric(x) && size(x, 1) == 1 && size(x, 2) == 3);

    checkK = @(x) (isnumeric(x) && size(x, 1) == 3 && size(x, 2) == 3 && all(all(round(x'*x) == round(x*x'))));

    %default_texture = 0;
    %checkTexture = @(x) (isstring(x) || ischar(x));

    addRequired(parser, 'file');
    addRequired(parser, 'P', checkP);
    addRequired(parser, 'K', checkK);
    addParameter(parser, 'color', defaultColor, checkColor);
    %addParameter(parser, 'texture', default_texture, checkTexture);
    addParameter(parser, 'name', defaultName, checkName);

    parse(parser, file, P, K, varargin{:});

    file_id = parser.Results.file.id;
    name = parser.Results.name;
    color = parser.Results.color;
    %texture = parser.Results.texture;

%% Prepare ellipsoid

    P = SCALE_FACTOR * parser.Results.P;

    K_inv = inv(parser.Results.K);

    [V, D] = eigs(K_inv);
    r = 1 ./ sqrt(diag(D));

%% Decomposition of rotational matrix
    if det(V) < 0
        V = -V;
    end

    [v, t] = M_to_rodriges(V);

    if any(imag(v))
        error('The input matrix is not a covariance matrix')
    end

    if any(imag(r))
         error('The input matrix is not a covariance matrix')
    end

%% Write to file
    fwrite(file_id,'sph1 = sph0.copy');
    ruby_newline(file_id);

    fwrite(file_id,['s = Geom::Transformation.scaling(',num2str(r(1)),',', ...
        num2str(r(2)),',',num2str(r(3)),')']);
    ruby_newline(file_id);

    fwrite(file_id,['r = Geom::Transformation.rotation([0,0,0],[', ...
        num2str(v(1)),',',num2str(v(2)),',',num2str(v(3)),'],',num2str(t),')']);
    ruby_newline(file_id);

    fwrite(file_id,['t = Geom::Transformation.new([' ,num2str(P(1)), ',', ...
        num2str(P(2)), ',' ,num2str(P(3)), '])']);
    ruby_newline(file_id);

    fwrite(file_id,'sph1.entities.transform_entities(s,sph1)');
    ruby_newline(file_id);

    fwrite(file_id,'sph1.entities.transform_entities(r,sph1)');
    ruby_newline(file_id);

    fwrite(file_id,'sph1.entities.transform_entities(t,sph1)');
    ruby_newline(file_id);

    if(color ~= 'n')
        fwrite(file_id,['sph1.material = ', ruby_rgb_color(color)]);
        ruby_newline(file_id);
    end

    if(strlength(name) ~= 0)
        fwrite(file_id,['sph1.name =', char(39), char(name), char(39)]);
        ruby_newline(file_id);
    end

%	fwrite(file_id,['sph1.name =',char(39),'Point ',int2str(list_name(i_gp)),char(39)]);
%	ruby_newline(file_id);

% if(texture ~= 0)
%     fwrite(file_id, ['texture_path =  "#{File.dirname(__FILE__)}', texture, '"']);
%     ruby_newline(file_id);
%     fwrite(file_id, 'materials=Sketchup.active_model.materials');
%     ruby_newline(file_id);
%     fwrite(file_id, 'ellips = materials.add "ellipsoid texture"')
%     ruby_newline(file_id);
%     fwrite(file_id, 'ellips.texture = texture_path');
%     ruby_newline(file_id);
%     % texture size is missing
%     ruby_newline(file_id);
%     fwrite(file_id,'group.material = ellips');
%     ruby_newline(file_id);
% end

    ruby_newline(file_id);
    ruby_newline(file_id);
end
