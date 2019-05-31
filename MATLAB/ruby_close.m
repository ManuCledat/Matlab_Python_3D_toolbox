%% RUBY_CLOSE Closes and finalizes ruby file, displaying file info
%   RUBY_CLOSE(FILE) Takes id from FILE to close the file and display the
%   full path and name to copy to Sketchup.
%
%   The generated file is to be used as follows:
%
%       open Sketchup,
%       A Welcome windows will open, click 'Start using SketchUp'
%       Click Windows > Ruby Console
%       Copy the required command from MATLAB Command Window
%       Paste it in the ruby console and press enter
%       If the file is big, it might take time
%   
%   Example:
%       file = ruby_create()                % Create file
%       ruby_point(file, [2, 2, 2])         % Write point to file
%       ruby_close(file)                    % my_model.rb
%
%   See also RUBY_CREATE.

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

function [] = ruby_close(file)
%% load constants
    ruby_params;

    ruby_newline(file.id);
    ruby_newline(file.id);
    ruby_newline(file.id);
    fwrite(file.id,'sph0.entities.clear!');
    ruby_newline(file.id);
    fwrite(file.id,'arr0.entities.clear!');

    fclose(file.id);

    disp('Open a ruby console in sketchup, and copy/paste:')
    disp(['require ',char(39),file.path,'\',file.name,char(39)])

end
