%% RUBY_CREATE Opens and initializes ruby file, returning file structure
%   FILE = RUBY_CREATE() Creates file in local folder with name
%   script_ruby_3d.rb. Returns file structure containing id, path and name.
%
%   FILE = RUBY_CREATE(REL_PATH_NAME) Uses REL_PATH_NAME as path and name
%   relative to the local folder. .rb is appended. Returns file structure
%   containing id, path and name. 
%
%   FILE = RUBY_CREATE(ABS_PATH, NAME) Uses ABS_PATH as absolute path,
%   appending NAME and .rb. Returns file structure containing id, path and
%   name.
%
%   THE FILE MUST BE CLOSED BY RUBY_CLOSE!
%
%   Examples:
%       file = ruby_create()                        % script_ruby_3d.rb
%       ruby_close(file)                            % Close created file
%
%       file = ruby_create('my_model')              % my_model.rb
%       ruby_close(file)                            % Close created file
%
%       file = ruby_create('C:\Users','my_model')   % C:\Users\my_model.rb
%       ruby_close(file)                            % Close created file
%
%   See also RUBY_CLOSE.

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

function file = ruby_create(name_or_path,name)
%% load constants
    ruby_params;

    switch nargin
        case 0
            folder_path = pwd;
            file_name   = 'script_ruby_3d';
        case 1
            folder_path = pwd;
            file_name = name_or_path;
        case 2
            folder_path = name_or_path;
            file_name = name;
        otherwise
            error('Too many inputs');
    end

    id = fopen([folder_path, '\', file_name, '.rb'], 'w');

    fwrite(id, 'model = Sketchup.active_model');
    ruby_newline(id);
    ruby_newline(id);
    ruby_newline(id);

    fwrite(id, 'sph0 = Sketchup.active_model.entities.add_group');
    ruby_newline(id);

    fwrite(id, ['c1 = sph0.entities.add_circle(ORIGIN,Z_AXIS,',...
        num2str(SCALE_FACTOR), ',24)']);
    ruby_newline(id);

    fwrite(id, 'c2 = sph0.entities.add_circle(ORIGIN,X_AXIS,50,24)');
    ruby_newline(id);

    fwrite(id, 'f  = sph0.entities.add_face(c1)');
    ruby_newline(id);

    fwrite(id, 'f.followme(c2)');
    ruby_newline(id);

    fwrite(id, 'c2.each {|edge| edge.erase!}');
    ruby_newline(id);
    ruby_newline(id);

    fwrite(id, 'arr0 = Sketchup.active_model.entities.add_group');
    ruby_newline(id);

    arrow_shape = [0    0   ;...
                   0.05 0   ;...
                   0.05 0.8 ;...
                   0.1  0.8 ;...
                   0    1   ];
    ruby_newline(id);

    fwrite(id,'pts=[[');
    for i = 1:(size(arrow_shape, 1) - 1)
        fwrite(id, [...
            num2str(SCALE_FACTOR * arrow_shape(i,  1)), ',0,',...
            num2str(SCALE_FACTOR * arrow_shape(i,  2)), '],[']);
    end
    fwrite(id, [...
        num2str(SCALE_FACTOR * arrow_shape(end,  1)), ',0,',...
        num2str(SCALE_FACTOR * arrow_shape(end,  2)), ']]']);
    ruby_newline(id);

    fwrite(id, 'f = arr0.entities.add_face(pts)');
    ruby_newline(id);

    fwrite(id, 'c1 = arr0.entities.add_circle(ORIGIN,Z_AXIS,39.3701,24)');
    ruby_newline(id);

    fwrite(id, 'f.followme(c1)');
    ruby_newline(id);

    fwrite(id, 'c1.each {|edge| edge.erase!}');
    ruby_newline(id);

    file.id = id;
    file.path = folder_path;
    file.name = file_name;
end
