%% RUBY_CHECK_COLOR Helper function, returns true for valid color argument
%   RUBY_CHECK_COLOR(CHAR) CHAR = 'n' none, 'w' white, 'r' red,
%   'o' orange, 'y' yellow, 'g' green, 'b' blue, 'p' pink, 'k' black
%
%   RUBY_CHECK_COLOR([R, G, B]) R,G,B are the intensities of red, green and
%   blue beteen 0 and 255
%
%   Examples:
%       ruby_check_color('n')             % returns true
%       ruby_check_color([255,155,0])     % returns true
%       ruby_check_color('i')             % returns false
%       ruby_check_color([-3,155,0])      % returns false

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

function good_color = ruby_check_color(color)
    if ischar(color)
        valid_colors = {'n', 'w', 'r', 'o', 'y', 'g', 'b', 'p', 'k'};
        good_color = any(validatestring(color, valid_colors));
    elseif isnumeric(color)
        if length(color) == 3
            good_color = all(color <= 255) && all(color >= 0);
        else
            good_color = false;
        end
    else
        good_color = false;
    end
end
