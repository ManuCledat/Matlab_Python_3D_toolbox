%% M_TO_RODRIGES Lie-Logarithm helper function
%   [u, phi] = M_TO_RODRIGES(R) fulfills expm(cross_ten( lie_log(R) )) = R

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

function [u,phi] = M_to_rodriges(R)
    [V, D] = eig(R);
    theta  = max(angle(diag(D)));
    [~, k] = min(abs(diag(D) - 1));
    v1 = theta * V(:, k);
    v2 = -theta * V(:, k);
    R1 = expm(cross_ten(v1));
    R2 = expm(cross_ten(v2));
    if max(angle(eig(R * R2'))) > max(angle(eig(R * R1')))
        phi = norm(v1);
        u = v1 / phi;
    else
        phi = norm(v2);
        u = v2 / phi;
    end
    if phi < 1e-10
        u = zeros(3, 1);
    end
end
