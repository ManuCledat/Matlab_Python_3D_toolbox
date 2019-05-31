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


from ruby_lib import *
import math
from scipy.spatial import Delaunay


# CREATE

# Creates a ruby file
file = ruby_create()

# POINT

# Draws a single point
ruby_point(file, np.array([[-5, 2, 2]]))

# Draws 2 points with default symbol(triangle) and default color(white)
ruby_point(file, np.array([[-4, 2, 2], [-3, 2, 2]]), issymbolic = 1)

# Draws 2 points with default symbol(triangle) and color black
ruby_point(file, np.array([[-2, 2, 2], [-1, 2, 2]]), issymbolic = 1,
    color = 'k')

# Draws 2 points with color red
# One with symbol(square) and other without symbols
# Both share the same name ('points')
ruby_point(file, np.array([[2, 2, 2], [3, 2, 2]]),
    issymbolic = np.array([[1], [0]]), symbol = 'square', color = 'r',
    name = "points")

# Draws 2 points with color green
# One without symbols and other with symbol(circle)
# They are named 'point1' and 'point2' respectively
ruby_point(file, np.array([[4, 2, 2], [5, 2, 2]]),
    issymbolic = np.array([[0], [1]]), symbol = 'circle', color = 'g',
    name = np.array([["point1"], ["point2"]]))


# LINE

# Draws 3 connected lines
ruby_line(file, np.array([[0, 3, 2], [0, 3, 4], [0, 5, 4], [0, 5, 2]]))

# Draws 2 connected lines with the same name ('lines')
ruby_line(file, np.array([[0, 3, 4], [2, 3, 4], [2, 3, 2]]), name = "lines")

# Draws 2 connected lines with different names ('line1', 'line2')
ruby_line(file, np.array([[0, 5, 4], [2, 5, 4], [2, 5, 2]]),
    name = np.array([["line1"], ["line2"]]))


# AXIS

# Orthogonal Matrix
R = np.array([[1, 0, 0],
    [0,  np.cos(1), np.sin(1)],
    [0, -np.sin(1), np.cos(1)]])

# Draws an axis with name ('reference_axis')
ruby_axis(file, np.array([[4, 4, 4]]), R, name = "reference_axis")


# ELLIPSOID

# Orthogonal Matrix
K = np.array([[ 1.666 ,  -0.424  ,  0.244],
              [-0.424  ,  2.961 ,  -0.558],
              [0.244   ,-0.558 ,   4.121]])


# Draws an ellipsoid with color(red) given orthogonal matrix R
ruby_ellipsoid(file, np.array([[0, 0, 10]]), K, color = 'r')

# Draws an ellipsoid with texture given orthogonal matrix R
ruby_ellipsoid(file, np.array([[0, 0, 20]]), K, texture = '/images/color.jpg')

# Draws an ellipsoid with color(yellow) and name('error ellipsoid') given orthogonal matrix R
ruby_ellipsoid(file, np.array([[0, 0, 30]]), K, color = 'y', name = "error ellipsoid")

# Draws an ellipsoid with color(green) and name('error ellipsoid') given orthogonal matrix R
ruby_ellipsoid(file, np.array([[0, 0, 40]]), K, color = 'g',
    name = "error ellipsoid")

# Draws an ellipsoid with color(blue) given orthogonal matrix R
ruby_ellipsoid(file, np.array([[0, 0, 50]]), K, color = 'b')

# Draws an ellipsoid with color(pink) given orthogonal matrix R
ruby_ellipsoid(file, np.array([[0, 0, 60]]), K, color = 'p')

# Draws an ellipsoid with color(black) given orthogonal matrix R
ruby_ellipsoid(file, np.array([[0, 0, 70]]), K, color = 'k')


# POSE
# Orthogonal Matrix
R = np.array([[1, 0, 0],
    [0,  np.cos(1), np.sin(1)],
    [0, -np.sin(1), np.cos(1)]])

# Draws a pose with default focal length (0.2), width (0.1), height (0.1) and color (weight) options
ruby_pose(file, np.array([[5, 5, 5]]), R)

# Draws a pose with a name('pose1') and focal length (0.1)
ruby_pose(file, np.array([[6, 5, 5]]), R,  focal = 0.1, name = "pose1")

# Draws a pose with the given focal length (0.6) and color (orange)
ruby_pose(file, np.array([[7, 5, 5]]), R,  focal = 0.6, color = 'o')

# Draws a pose with the given focal length (0.8) and width (0.3)
ruby_pose(file, np.array([[8, 5, 5]]), R, focal = 0.8, width = 0.3, color = 'p')

# Draws a pose with the given focal length (1), width (0.3), height (0.2)
# and color (red)
ruby_pose(file, np.array([[9, 5, 5]]), R, focal = 1, width = 0.3, height = 0.2,
    color = 'r')


# PLANE

# Draws a blue plane with the label 'myplane'
ruby_plane(file, np.array([[0, 1, 3], [0, 1, 5], [1, 2, 5], [1, 2, 3]]),
    color = 'b', name = 'myplane')

# Draws an inclined polygone
ruby_plane(file, np.array([[5, 0, 0], \
                           [5, 2, 2], \
                           [6, 2, 2], \
                           [6, 1, 1], \
                           [7, 1, 1], \
                           [7, 2, 2], \
                           [8, 1, 1], \
                           [8, 0, 0]]))

# RESECTION

# Draws a resection with 3 antennas
ruby_resection(file, np.array([[0, -5, 0]]),
    np.array([[0, -10, 0], [0, -2, 0], [-3, 0, 0]]))


# RUBY TIN

p1 = 10 * np.random.rand(100, 1) + 10
p2 = 10 * np.random.rand(100, 1)
p3 = np.random.rand(100, 1)

points = np.concatenate((p1, p2), axis = 1)
points = np.concatenate((points, p3), axis = 1)

triangles = Delaunay(points[:, 0:2])

ruby_tin(file, points, triangles.simplices.copy(),
    texture = '/images/rainbow.jpeg')

# QUIVER PLOT

# Draws an arrow at 5,5,5, pointing along x axis
ruby_arrow(file, np.array([[5], [5], [5]]), np.array([[1], [0], [0]]))

# Draws a red arrow
ruby_arrow(file, np.array([[5], [5], [5]]), np.array([[0], [1], [0]]), \
    color = 'r')

# Draws a green arrow with label
ruby_arrow(file, np.array([[5], [5], [5]]), np.array([[0], [0], [1]]), \
    color = 'g', name = "arrow3")

# CLOSE

# Closes a ruby file
ruby_close(file)
