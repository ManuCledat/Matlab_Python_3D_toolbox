#!/usr/bin/env python
# coding: utf-8
#
# Copyright 2019 TOPO EPFL
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

import numpy as np
from scipy.linalg import expm

def ruby_newline(file):
    file.write('\n')

def ruby_rgb_color(color):
    if color == 'w':
        color_code = '[255,255,255]'
    elif color =='r':
        color_code = '[255,0,0]'
    elif color =='o':
        color_code = '[255,155,0]'
    elif color == 'y':
        color_code = '[255,255,0]'
    elif color == 'g':
        color_code = '[0,255,0]'
    elif color == 'b':
        color_code = '[0,0,255]'
    elif color == 'p':
        color_code = '[255,0,255]'
    elif color == 'k':
        color_code = '[0,0,0]'
    else:
        ValueError('Unknown color')
    return color_code

def cross_ten(x):
    X = x[0]
    Y = x[1]
    Z = x[2]
    return np.array([[ 0, -Z,  Y], \
                     [ Z,  0, -X], \
                     [-Y,  X,  0]])

def M_to_rodriges(R):
    D, V = np.linalg.eig(R)
    print(R)
    print(D)
    print(V)
    theta = max(np.angle(D))
    k = np.argmin(np.abs(D - 1))
    v1 = theta * V[:, k]
    v2 = -theta * V[:, k]
    R1 = expm(cross_ten(v1))
    R2 = expm(cross_ten(v2))

    w1, temp = np.linalg.eig(np.matmul(R, np.transpose(R1)))
    w2, temp = np.linalg.eig(np.matmul(R, np.transpose(R2)))

    if(max(np.angle(w2)) > max(np.angle(w1))):
        phi = np.linalg.norm(v1)
        if(phi > 1e-10):
            u = v1 / phi;
        else:
            u = np.zeros((3, 1))
    else:
        phi = np.linalg.norm(v2)
        if(phi > 1e-10):
            u = v2 / phi;
        else:
            u = np.zeros((3, 1))
    return u, phi
