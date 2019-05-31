%% RUBY_RGB_COLOR Helper function, creates RGB-string for given color
%   RUBY_RGB_COLOR(CHAR) CHAR = 'w' white, 'r' red,
%   'o' orange, 'y' yellow, 'g' green, 'b' blue, 'p' pink, 'k' black
%
%   RUBY_RGB_COLOR([R, G, B]) R,G,B are the intensities of red, green and
%   blue beteen 0 and 255

%   An error is thrown if unknown color is chosen
%
%   Examples:
%       ruby_rgb_color('o')             % returns '[255,155,0]'
%       ruby_rgb_color([255,155,0])     % returns '[255,155,0]'

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

function color_code = ruby_rgb_color(color)
    if isequal(color, 'w')
        color_code = '[255,255,255]';
    elseif isequal(color,'r')
        color_code = '[255,0,0]';
    elseif isequal(color,'o')
        color_code = '[255,155,0]';
    elseif isequal(color,'y')
        color_code = '[255,255,0]';
    elseif isequal(color,'g')
        color_code = '[0,255,0]';
    elseif isequal(color,'b')
        color_code = '[0,0,255]';
    elseif isequal(color,'p')
        color_code = '[255,0,255]';
    elseif isequal(color,'k')
        color_code = '[0,0,0]';
    elseif length(color)==3
        color_code = ['[',num2str(color(1)),',',num2str(color(2)),',',num2str(color(3)),']'];
    else
        error('Unknown color')
    end
end