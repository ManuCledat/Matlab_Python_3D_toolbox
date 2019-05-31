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
from helpers import *
import os
import cmath
import numbers

SCALE_FACTOR = 39.3700787402
TOL_COPLANARITY = 1e-5
TOL_CROSS_PRODUCT = 1e-7

# Opens ruby script file for output, returns file descriptor
# Mandatory
def ruby_create(name_or_path = 'script_ruby_sketchup.rb'):
    """
    Opens output file for generated ruby script.
    Raises exceptions if file connot be opened.

    Parameters
    ----------
    name_or_path : string (optional)
        File name of output file. .rb file extension is mandatory.

    Returns
    -------
    file object
        File descriptor of opened file

    """
    if not isinstance(name_or_path, str):
        raise ValueError('Error in ruby_create. ',
                         'Not a valid type for file name. Expects a string')

    if '.rb' not in name_or_path:
        raise ValueError('Error in ruby_create. ',
                         'Not a valid file name. File extension .rb is missing')

    if '/' not in name_or_path:
        name_or_path = os.getcwd()+ '/' + name_or_path

    try:
        file = open(name_or_path, 'w')
    except OSError:
        raise OSError('Error in ruby_create. ',
                      'Not a valid type for file name.')

    file.write('model = Sketchup.active_model')
    ruby_newline(file)
    ruby_newline(file)

    file.write('sph0 = Sketchup.active_model.entities.add_group')
    ruby_newline(file)

    file.write('c1 = sph0.entities.add_circle(ORIGIN,Z_AXIS,' \
        + str(SCALE_FACTOR) + ',24)')
    ruby_newline(file)

    file.write('c2 = sph0.entities.add_circle(ORIGIN,X_AXIS,50,24)')
    ruby_newline(file)

    file.write('f  = sph0.entities.add_face(c1)')
    ruby_newline(file)

    file.write('f.followme(c2)')
    ruby_newline(file)

    file.write('c2.each {|edge| edge.erase!}')
    ruby_newline(file)
    ruby_newline(file)

    file.write('arr0 = Sketchup.active_model.entities.add_group')
    ruby_newline(file)

    arrow_shape = np.array([[0,    0],\
                            [0.05, 0],\
                            [0.05, 0.8],\
                            [0.1,  0.8],\
                            [0,    1]])

    file.write('pts=[[')
    for i in range(arrow_shape.shape[0] - 1):
        file.write(str(SCALE_FACTOR * arrow_shape[i,  0]) + ',0,' \
                 + str(SCALE_FACTOR * arrow_shape[i,  1]) + '],[')
    file.write(str(SCALE_FACTOR * arrow_shape[arrow_shape.shape[0] - 1,  0]) + ',0,' \
             + str(SCALE_FACTOR * arrow_shape[arrow_shape.shape[0] - 1,  1]) + ']]')
    ruby_newline(file)

    file.write('f = arr0.entities.add_face(pts)')
    ruby_newline(file)

    file.write('c1 = arr0.entities.add_circle(ORIGIN,Z_AXIS,39.3701,24)')
    ruby_newline(file)

    file.write('f.followme(c1)')
    ruby_newline(file)

    file.write('c1.each {|edge| edge.erase!}')
    ruby_newline(file)
    ruby_newline(file)

    return file

def ruby_close(file):
    """
    Closes file, printing the required ruby console command for file import.

    Parameters
    ----------
    file : file object
        Open ruby script file descriptor

    """

    ruby_newline(file)
    file.write('sph0.entities.clear!')
    ruby_newline(file)
    file.write('arr0.entities.clear!')

    print('Open a ruby console in sketchup, and copy/paste:')
    print('require \'' + file.name + '\'')
    file.close()

def ruby_point(file, XYZ, issymbolic = 0, symbol = 'triangle', color = 'n', name = ''):
    """
    Writes the array of points XYZ to the given file. Symbol, color and name of
    the point can be given.

    Parameters
    ----------
    file : file object
        Open ruby script file descriptor
    XYZ : np.ndarray, np.array
        N-by-3 array of point coordinates
    issymbolic : np.ndarray, np.array, int (optional)
        List or single value defining whether or not specific or all points
        have a symbol (1) or not (0, default)
    symbol : str (optional)
        Symbol of the list 'triangle' (default), 'cross', 'circle', 'square'
    color : str (optional)
        One of the following colors:
        'n' (default), 'w', 'r', 'o', 'y', 'g', 'b', 'p', 'k'
    name : np.ndarray, np.array, str (optional)
        Global name for all points or list of individual names

    Examples
    --------
    Draws a single point.
    >>>ruby_point(file, np.array([[-5, 2, 2]]))

    Draws 2 points with default symbol(triangle) and no color.
    >>>ruby_point(file, np.array([[-4, 2, 2], [-3, 2, 2]]), issymbolic = 1)

    Draws 2 points with default symbol(triangle) and color black.
    >>>ruby_point(file, np.array([[-2, 2, 2], [-1, 2, 2]]), issymbolic = 1,
    >>>    color = 'k')

    Draws 2 points with color red, one with a square and one without a symbol.
    Both share the same name ('points').
    >>>ruby_point(file, np.array([[2, 2, 2], [3, 2, 2]]),
    >>>    issymbolic = np.array([[1], [0]]), symbol = 'square', color = 'r',
    >>>    name = "points")

    Draws 2 green points one without a symbol, the other with a circle.
    They are named 'point1' and 'point2' respectively.
    >>>ruby_point(file, np.array([[4, 2, 2], [5, 2, 2]]),
    >>>    issymbolic = np.array([[0], [1]]), symbol = 'circle', color = 'g',
    >>>    name = np.array([["point1"], ["point2"]]))

    """

    valid_symbols = ['triangle', 'cross', 'circle', 'square']
    valid_colors = ['n', 'w', 'r', 'o', 'y', 'g', 'b', 'p', 'k']

    if type(XYZ) is not np.ndarray and type(XYZ) is not np.array:
        raise TypeError('Error in ruby_point. XYZ should be a numpy.array.')

    if not(XYZ.shape[1] == 3):
        raise ValueError('Error in ruby_point. Dimension of XYZ is invalid.')

    for elt in XYZ:
        if not(isinstance(elt[0], numbers.Real) \
           and isinstance(elt[1], numbers.Real) \
           and isinstance(elt[2], numbers.Real)):
            raise TypeError('Error in ruby_point. ',
                            ' XYZ should consist of only numeric values.')

    if symbol not in valid_symbols or not isinstance(symbol, str):
        raise TypeError('Error in ruby_point. Not a valid symbol.')

    if color not in valid_colors or not isinstance(color, str):
        raise TypeError('Error in ruby_point. Not a valid color.')
    if type(issymbolic) is not np.ndarray \
        and type(issymbolic) is not np.array \
        and not isinstance(issymbolic, numbers.Real):
        raise TypeError('Error in ruby_point. Not a valid type for issymbolic. ',
                        'issymbolic must be either an numpy.array or a list.')

    if not isinstance(issymbolic, int):
        if not (issymbolic.shape[0] == XYZ.shape[0]) \
            or not (issymbolic.shape[1] == 1):
            raise ValueError('Error in ruby_point. ',
                             'Dimension of issymbolic is invalid.')

    if not isinstance(issymbolic, int):
        for elt in issymbolic:
            if not isinstance(elt[0], numbers.Real):
                raise TypeError('Error in ruby_point. ',
                                'Not a valid type for issymbolic. ',
                                'Expects an integer')
            if not( elt[0] == 0 or elt[0] == 1):
                raise ValueError('Error in ruby_point. ',
                                 'Not a valid value for issymbolic. ',
                                 'Expects 0 or 1')

    if type(name) is not np.ndarray and type(name) is not np.array \
        and not isinstance(name, str):
        raise TypeError('Error in ruby_point. ',
                        'Not a valid type for name. ',
                        'name must be either a str or a numpy.ndarray.')

    if not isinstance(name, str):
        if not (name.shape[0] == XYZ.shape[0]) or not (name.shape[1] == 1):
            raise ValueError('Error in ruby_point. Dimension of name is invalid.')

    if isinstance(issymbolic, int):
        issymbolic = np.full((XYZ.shape[0], 1), issymbolic)

    XYZ = np.concatenate((XYZ, issymbolic), axis = 1)

    if isinstance(name, str):
        name = np.full((XYZ.shape[0], 1), name)

    file.write('group = Sketchup.active_model.entities.add_group')
    index = 0
    for P in XYZ:
        if P[3] == 0:
            ruby_newline(file)
            file.write('group.entities.add_cpoint Geom::Point3d.new(' + \
                       str(SCALE_FACTOR * P[0]) + ',' + \
                       str(SCALE_FACTOR * P[1]) + ',' + \
                       str(SCALE_FACTOR * P[2]) + ')' \
                      )
            ruby_newline(file)
        elif P[3] == 1:
            ruby_newline(file)
            file.write('group = Sketchup.active_model.entities.add_group')
            ruby_newline(file)
            file.write('group.entities.add_cpoint Geom::Point3d.new(' + \
                       str(SCALE_FACTOR * P[0]) + ',' + \
                       str(SCALE_FACTOR * P[1]) + ',' + \
                       str(SCALE_FACTOR * P[2]) + ')' \
                      )
            ruby_newline(file)
            if symbol == 'triangle':
                ruby_newline(file)
                file.write('f=group.entities.add_circle([' + \
                           str(SCALE_FACTOR * P[0]) + ',' + \
                           str(SCALE_FACTOR * P[1]) + ',' + \
                           str(SCALE_FACTOR * P[2]) + '],Z_AXIS,20,3)' \
                          )
                ruby_newline(file)
                file.write('group.entities.add_face(f)')
                ruby_newline(file)
                if not (color == 'n'):
                    file.write('group.material = ' + ruby_rgb_color(color))
                    ruby_newline(file)
            elif symbol == 'circle':
                ruby_newline(file)
                file.write('f=group.entities.add_circle([' + \
                           str(SCALE_FACTOR * P[0]) + ',' + \
                           str(SCALE_FACTOR * P[1]) + ',' + \
                           str(SCALE_FACTOR * P[2]) + '],Z_AXIS,20)' \
                          )
                ruby_newline(file)
                file.write('group.entities.add_face(f)')
                ruby_newline(file)
                if not (color == 'n'):
                    file.write('group.material = ' + ruby_rgb_color(color))
                    ruby_newline(file)
            elif symbol == 'cross':
                ruby_newline(file)
                file.write('group.entities.add_line([' + \
                           str(SCALE_FACTOR * P[0] - 10) + ',' + \
                           str(SCALE_FACTOR * P[1] - 10) + ',' + \
                           str(SCALE_FACTOR * P[2]) + '],[' + \
                           str(SCALE_FACTOR * P[0] + 10) + ',' + \
                           str(SCALE_FACTOR * P[1] + 10) + ',' + \
                           str(SCALE_FACTOR * P[2]) + '])' \
                          )
                ruby_newline(file)
                file.write('group.entities.add_line([' + \
                           str(SCALE_FACTOR * P[0] - 10) + ',' + \
                           str(SCALE_FACTOR * P[1] + 10) + ',' + \
                           str(SCALE_FACTOR * P[2]) + '],[' + \
                           str(SCALE_FACTOR * P[0] + 10) + ',' + \
                           str(SCALE_FACTOR * P[1] - 10) + ',' + \
                           str(SCALE_FACTOR * P[2]) + '])' \
                          )
                ruby_newline(file)
            elif symbol == 'square':
                ruby_newline(file)
                file.write('f=group.entities.add_circle([' + \
                           str(SCALE_FACTOR * P[0]) + ',' + \
                           str(SCALE_FACTOR * P[1]) + ',' + \
                           str(SCALE_FACTOR * P[2]) + '],Z_AXIS,20,4)' \
                          )
                ruby_newline(file)
                file.write('group.entities.add_face(f)')
                ruby_newline(file)
                if not (color == 'n'):
                    file.write('group.material = ' + ruby_rgb_color(color))
                    ruby_newline(file)
        ruby_newline(file)
        if not (name[index, 0] == ''):
            file.write('group.name =\'' + name[index, 0] + '\'')
            ruby_newline(file)
        index = index + 1

def ruby_line(file, XYZ, name = ''):
    """
    Draws a line along the array of points XYZ. If required a name can be given.

    Parameters
    ----------
    file : file object
        Open ruby script file descriptor
    XYZ : np.ndarray
        N-by-3 array of line coordinates
    name : np.ndarray, str (optional)
        Global line name or list of names for each segment

    Examples
    --------
    Draws 3 connected lines
    >>>ruby_line(file, np.array([[0, 3, 2], [0, 3, 4], [0, 5, 4], [0, 5, 2]]))

    Draws 2 connected lines with the same name ('lines')
    >>>ruby_line(file, np.array([[0, 3, 4], [2, 3, 4], [2, 3, 2]]),
    >>>    name = "lines")

    Draws 2 connected lines with different names ('line1', 'line2')
    >>>ruby_line(file, np.array([[0, 5, 4], [2, 5, 4], [2, 5, 2]]),
    >>>    name = np.array([["line1"], ["line2"]]))

    """
    if type(XYZ) is not np.ndarray:
        raise TypeError('Error in ruby_line. XYZ should be a numpy.array.')

    if not(XYZ.shape[1] == 3):
        raise ValueError('Error in ruby_line. Dimension of XYZ is invalid.')

    for elt in XYZ:
        if not(isinstance(elt[0], numbers.Real) \
            and isinstance(elt[1], numbers.Real) \
            and isinstance(elt[2], numbers.Real)):
            raise TypeError('Error in ruby_line. ',
                'XYZ should consist of only numeric values.')

    if type(name) is not np.ndarray and not isinstance(name, str):
        raise TypeError('Error in ruby_line. Not a valid type for name. ',
            'name must be either a str or a numpy.ndarray.')

    if not isinstance(name, str):
        if not (name.shape[0] == XYZ.shape[0] - 1) or not (name.shape[1] == 1):
            raise ValueError('Error in ruby_line. Dimension of name is invalid.')

    if isinstance(name, str):
        name = np.full((XYZ.shape[0], 1), name)

    for index in range(XYZ.shape[0] - 1):
        ruby_newline(file)
        file.write('group = Sketchup.active_model.entities.add_group')
        ruby_newline(file)
        file.write('group.entities.add_line([' + \
                   str(SCALE_FACTOR * XYZ[index, 0]) + ',' + \
                   str(SCALE_FACTOR * XYZ[index, 1]) + ',' + \
                   str(SCALE_FACTOR * XYZ[index, 2]) + '], [' + \
                   str(SCALE_FACTOR * XYZ[index + 1, 0]) + ',' + \
                   str(SCALE_FACTOR * XYZ[index + 1, 1]) + ',' + \
                   str(SCALE_FACTOR * XYZ[index + 1, 2]) + '])' \
                  )
        ruby_newline(file)
        if not (name[index, 0] == ''):
            file.write('group.name =\'' + name[index, 0] + '\'')
            ruby_newline(file)

def ruby_axis(file, P, R, name = ''):
    """
    Draws a 3 axis coordinate system at the position P and orientation R.

    Parameters
    ----------
    file : file object
        Open ruby script file descriptor
    P : np.ndarray
        1-by-3 array of coordinates
    R : np.ndarray
        3-by-3 orthogonal matrix (orientation)
    name : str (optional)
        Name of the set of axis

    Examples
    --------
    Draws named axis
    >>>ruby_axis(file, np.array([[4, 4, 4]]), np.array([[1, 0, 0],
    >>>                                [0,  np.cos(1), np.sin(1)],
    >>>                                [0, -np.sin(1), np.cos(1)]]),
    >>>                                name = "reference_axis")

    """
    if type(P) is not np.ndarray:
        TypeError('Error in ruby_axis. Type of P is not valid. ',
            'Expects an numpy.ndarray')

    if not(P.shape[0] == 1 and P.shape[1] == 3):
        ValueError('Error in ruby_axis. Dimension of P is not valid')

    if type(R) is not np.ndarray:
        TypeError('Error in ruby_axis. Type of R is not valid. ',
            'Expects an numpy.ndarray')

    if not(R.shape[0] == 3 and R.shape[1] == 3):
        ValueError('Error in ruby_axis. Dimension of R is not valid')

    for elt in P[0]:
        if not isinstance(elt, numbers.Real):
            raise TypeError('Error in ruby_axis. ',
                'P should consist of only numeric values.')

    for elt in R:
        if not(isinstance(elt[0], numbers.Real) \
            and isinstance(elt[1], numbers.Real) \
            and isinstance(elt[2], numbers.Real)):
            raise TypeError('Error in ruby_axis. ',
                'R should consist of only numeric values.')

    if not((np.matmul(R, np.transpose(R)) == np.matmul(np.transpose(R), R)).all()):
        raise ValueError('Error in ruby_axis. R should be an orthogonal matrix')

    if not isinstance(name, str):
        TypeError('Error in ruby_axis. Type of name is not valid. Expects str')

    P = P * SCALE_FACTOR
    P = P[0]
    R = R * SCALE_FACTOR

    ex = R[:, 0]
    ey = R[:, 1]
    ez = R[:, 2]

    ruby_newline(file)
    file.write('group.entities.add_line([' + \
               str(P[0]) + ',' + \
               str(P[1]) + ',' + \
               str(P[2]) + '], [' + \
               str(P[0] + ex[0]) + ',' + \
               str(P[1] + ex[1]) + ',' + \
               str(P[2] + ex[2]) + '])' \
              )
    ruby_newline(file)

    file.write('group.entities.add_line([' + \
               str(P[0]) + ',' + \
               str(P[1]) + ',' + \
               str(P[2]) + '], [' + \
               str(P[0] + ey[0]) + ',' + \
               str(P[1] + ey[1]) + ',' + \
               str(P[2] + ey[2]) + '])' \
              )
    ruby_newline(file)

    file.write('group.entities.add_line([' + \
               str(P[0]) + ',' + \
               str(P[1]) + ',' + \
               str(P[2]) + '], [' + \
               str(P[0] + ez[0]) + ',' + \
               str(P[1] + ez[1]) + ',' + \
               str(P[2] + ez[2]) + '])' \
              )
    ruby_newline(file)

    file.write('group.entities.add_line([' + \
               str(P[0] + 0.9 * ez[0] + 0.1 * ex[0]) + ',' + \
               str(P[1] + 0.9 * ez[1] + 0.1 * ex[1]) + ',' + \
               str(P[2] + 0.9 * ez[2] + 0.1 * ex[2]) + '], [' + \
               str(P[0] + ez[0]) + ',' + \
               str(P[1] + ez[1]) + ',' + \
               str(P[2] + ez[2]) + '])' \
              )
    ruby_newline(file)

    file.write('group.entities.add_line([' + \
               str(P[0] + 0.9 * ez[0] - 0.1 * ex[0]) + ',' + \
               str(P[1] + 0.9 * ez[1] - 0.1 * ex[1]) + ',' + \
               str(P[2] + 0.9 * ez[2] - 0.1 * ex[2]) + '], [' + \
               str(P[0] + ez[0]) + ',' + \
               str(P[1] + ez[1]) + ',' + \
               str(P[2] + ez[2]) + '])' \
              )
    ruby_newline(file)

    file.write('group.entities.add_line([' + \
               str(P[0] + 0.9 * ey[0] + 0.1 * ex[0]) + ',' + \
               str(P[1] + 0.9 * ey[1] + 0.1 * ex[1]) + ',' + \
               str(P[2] + 0.9 * ey[2] + 0.1 * ex[2]) + '], [' + \
               str(P[0] + ey[0]) + ',' + \
               str(P[1] + ey[1]) + ',' + \
               str(P[2] + ey[2]) + '])' \
              )
    ruby_newline(file)

    file.write('group.entities.add_line([' + \
               str(P[0] + 0.9 * ey[0] - 0.1 * ex[0]) + ',' + \
               str(P[1] + 0.9 * ey[1] - 0.1 * ex[1]) + ',' + \
               str(P[2] + 0.9 * ey[2] - 0.1 * ex[2]) + '], [' + \
               str(P[0] + ey[0]) + ',' + \
               str(P[1] + ey[1]) + ',' + \
               str(P[2] + ey[2]) + '])' \
              )
    ruby_newline(file)

    file.write('group.entities.add_line([' + \
               str(P[0] + 0.9 * ex[0] - 0.1 * ey[0]) + ',' + \
               str(P[1] + 0.9 * ex[1] - 0.1 * ey[1]) + ',' + \
               str(P[2] + 0.9 * ex[2] - 0.1 * ey[2]) + '], [' + \
               str(P[0] + ex[0]) + ',' + \
               str(P[1] + ex[1]) + ',' + \
               str(P[2] + ex[2]) + '])' \
              )
    ruby_newline(file)

    file.write('group.entities.add_line([' + \
               str(P[0] + 0.9 * ex[0] - 0.1 * ez[0]) + ',' + \
               str(P[1] + 0.9 * ex[1] - 0.1 * ez[1]) + ',' + \
               str(P[2] + 0.9 * ex[2] - 0.1 * ez[2]) + '], [' + \
               str(P[0] + ex[0]) + ',' + \
               str(P[1] + ex[1]) + ',' + \
               str(P[2] + ex[2]) + '])' \
              )
    ruby_newline(file)

    if not (name == ''):
        file.write('group.name =\'' + name + '\'')
        ruby_newline(file)

    file.write('group.entities.add_text("x", [' + \
               str(P[0] + ex[0]) + ',' + \
               str(P[1] + ex[1]) + ',' + \
               str(P[2] + ex[2]) + '], [0, 0, 0])' \
              )
    ruby_newline(file)

    file.write('group.entities.add_text("y", [' + \
               str(P[0] + ey[0]) + ',' + \
               str(P[1] + ey[1]) + ',' + \
               str(P[2] + ey[2]) + '], [0, 0, 0])' \
              )
    ruby_newline(file)

    file.write('group.entities.add_text("z", [' + \
               str(P[0] + ez[0]) + ',' + \
               str(P[1] + ez[1]) + ',' + \
               str(P[2] + ez[2]) + '], [0, 0, 0])' \
              )
    ruby_newline(file)

def ruby_ellipsoid(file, P, K, color='n', name='', texture=''):
    """
    Draws error ellipsoid with coordinates P and variance-covariance Matrix K.
    If required, name and color or texture can be added as well.

    Parameters
    ----------
    file : file object
        Open ruby script file descriptor
    P : np.ndarray
        1-by-3 array of coordinates
    K : np.ndarray
        3-by-3 covariance error matrix
    color : str (optional)
        One of the following colors:
        'n' (default), 'w', 'r', 'o', 'y', 'g', 'b', 'p', 'k'
    name : str (optional)
        Name of the ellipsoid
    texture : str (optional)
        Path to an image file with extension .png .jpg or .jpeg

    Examples
    --------

    Orthogonal Matrix
    >>>K = np.array([[1, 0, 0],
    >>>    [0,  np.cos(1), np.sin(1)],
    >>>    [0, -np.sin(1), np.cos(1)]])

    >>>K = np.matmul(np.linalg.inv(R), np.matmul(np.array([[1, 0, 0], [0, 4, 0], [0, 0, 9]]), K))

    Draws a red ellipsoid given orthogonal matrix K
    >>>ruby_ellipsoid(file, np.array([[0, 0, 10]]), R, color = 'r')

    Draws an ellipsoid with texture given orthogonal matrix K
    >>>ruby_ellipsoid(file, np.array([[0, 0, 20]]), K,
    >>>    texture = '/images/color.jpg')

    Draws a yellow ellipsoid called 'ellipsoid' given orthogonal matrix K
    >>>ruby_ellipsoid(file, np.array([[0, 0, 30]]), K, color = 'y',
    >>>    name = "ellipsoid")

    Draws a green ellipsoid called 'error ellipsoid' given orthogonal matrix K
    >>>ruby_ellipsoid(file, np.array([[0, 0, 40]]), K, color = 'g',
    >>>    name = "error ellipsoid")

    Draws a blue ellipsoid given orthogonal matrix K
    >>>ruby_ellipsoid(file, np.array([[0, 0, 50]]), K, color = 'b')

    Draws a pink ellipsoid given orthogonal matrix K
    >>>ruby_ellipsoid(file, np.array([[0, 0, 60]]), K, color = 'p')

    Draws a black ellipsoid given orthogonal matrix K
    >>>ruby_ellipsoid(file, np.array([[0, 0, 70]]), K, color = 'k')

    """

    print(K)

    if type(P) is not np.ndarray:
        TypeError('Error in ruby_ellipsoid. Type of P is not valid. ',
            'Expects an numpy.ndarray')

    if not(P.shape[0] == 1 and P.shape[1] == 3):
        ValueError('Error in ruby_ellipsoid. Dimension of P is not valid')

    if type(K) is not np.ndarray:
        TypeError('Error in ruby_ellipsoid. Type of K is not valid. ',
            'Expects an numpy.ndarray')

    if not(K.shape[0] == 3 and K.shape[1] == 3):
        ValueError('Error in ruby_ellipsoid. Dimension of K is not valid')

    for elt in P[0]:
        if not isinstance(elt, numbers.Real):
            raise TypeError('Error in ruby_ellipsoid. ',
                'P should consist of only numeric values.')

    for elt in K:
        if not(isinstance(elt[0], numbers.Real) \
            and isinstance(elt[1], numbers.Real) \
            and isinstance(elt[2], numbers.Real)):
            raise TypeError('Error in ruby_ellipsoid. ',
                'R should consist of only numeric values.')

    if not((np.matmul(K, np.transpose(K)) == np.matmul(np.transpose(K), K)).all()):
        raise ValueError('Error in ruby_ellipsoid. ',
            'R should be an orthogonal matrix')

    if not isinstance(name, str):
        TypeError('Error in ruby_ellipsoid. ',
            'Type of name is not valid. Expects str')

    valid_colors = ['n', 'w', 'r', 'o', 'y', 'g', 'b', 'p', 'k']

    if color not in valid_colors or not isinstance(color, str):
        raise TypeError('Error in ruby_ellipsoid. Not a valid color.')

    if not texture == '':
        if not isinstance(texture, str):
            raise TypeError('Error in ruby_ellipsoid. Expects a string path')

    tol_angle = 0.1 * np.pi / 180

    P = P * SCALE_FACTOR
    P = P[0]

    K_inv = np.linalg.inv(K)

    D, V = np.linalg.eig(K_inv)

    r = 1 / np.sqrt(D)

    if np.linalg.det(V) < 0:
        V = -V

    v, t = M_to_rodriges(V)

    if np.any(np.iscomplex(v)):
        raise TypeError('Error in ruby_ellipsoid. Complex number encountered')

    if np.any(np.iscomplex(r)):
        raise TypeError('Error in ruby_ellipsoid. Complex number encountered')

#    rotation_vector = ruby_M_to_Rodriges(V)
#    if not(np.linalg.norm(rotation_vector) == 0):
#        V = -rotation_vector / np.linalg.norm(rotation_vector)
#    t = np.linalg.norm(rotation_vector)

#    if(not np.isreal(r).all()):
#        raise ValueError('Error in ruby_ellipsoid. Complex number encountered')

    ruby_newline(file)
    file.write('sph1 = sph0.copy')
    ruby_newline(file)
    file.write('s = Geom::Transformation.scaling(' + str(r[0]) + ',' \
                                                   + str(r[1]) + ',' \
                                                   + str(r[2]) + ')')

    if abs(t) >  tol_angle:
        ruby_newline(file)
        file.write('r = Geom::Transformation.rotation([0,0,0],[' \
            + str(np.real(v[0])) + ',' \
            + str(np.real(v[1])) + ',' \
            + str(np.real(v[2])) + '],' \
            + str(np.real(t)) + ')')

    ruby_newline(file)
    file.write('t = Geom::Transformation.new([' + str(P[0]) + ',' \
                                                + str(P[1]) + ',' \
                                                + str(P[2]) + '])')
    ruby_newline(file)
    file.write('sph1.entities.transform_entities(s,sph1)')
#    if abs(t) >  tol_angle:

    if abs(t) >  tol_angle:
        ruby_newline(file)
        file.write('sph1.entities.transform_entities(r,sph1)')

    ruby_newline(file)
    file.write('sph1.entities.transform_entities(t,sph1)')
    ruby_newline(file)
    if not (color == 'n'):
        file.write('sph1.material = ' + ruby_rgb_color(color))
        ruby_newline(file)
    if not (name == ''):
        file.write('sph1.name =\'' + name + '\'')
        ruby_newline(file)

    if not (texture == ''):
        file.write('texture_path = "#{File.dirname(__FILE__)}' + texture + '"')
        ruby_newline(file)
        file.write('materials=Sketchup.active_model.materials')
        ruby_newline(file)
        file.write('ellips = materials.add "ellipsoid texture"')
        ruby_newline(file)
        file.write('ellips.texture = texture_path')
        ruby_newline(file)
        file.write('sph1.material = ellips')
        ruby_newline(file)

def ruby_pose(file, P, R, focal = 0.2, width = 0.1, height = 0.1, color = 'n', name = ''):
    """
    Draws a pose with position P in the center of the projection and
    orientation R. The photo is taken in the -Z direction.
    Focal distance, width, height, color and name can be defined if required.

    Parameters
    ----------
    file : file object
        Open ruby script file descriptor
    P : np.ndarray
        1-by-3 array of coordinates
    R : np.ndarray
        3-by-3 covariance error matrix
    focal : int, float (optional)
        Focal distance (0.2 default)
    width : int, float (optional)
        Image width (0.1 default)
    height : int, float (optional)
        Image height (0.1 default)
    color : str (optional)
        One of the following colors:
        'n' (default), 'w', 'r', 'o', 'y', 'g', 'b', 'p', 'k'
    name : str (optional)
        Name of the pose

    Examples
    --------
    Orthogonal Matrix
    >>>R = np.array([[1, 0, 0],
    >>>    [0,  np.cos(1), np.sin(1)],
    >>>    [0, -np.sin(1), np.cos(1)]])

    Draws a pose with default focal length (0.2), width (0.1), height (0.1) and
    color (none) options
    >>>ruby_pose(file, np.array([[5, 5, 5]]), R)

    Draws a pose with a name('pose1') and focal length (0.1)
    >>>ruby_pose(file, np.array([[6, 5, 5]]), R,  focal = 0.1, name = "pose1")

    Draws a pose with the given focal length (0.6) and color (orange)
    >>>ruby_pose(file, np.array([[7, 5, 5]]), R,  focal = 0.6, color = 'o')

    Draws a pose with the given focal length (0.8), width (0.3) and color (pink)
    >>>ruby_pose(file, np.array([[8, 5, 5]]), R, focal = 0.8, width = 0.3,
    >>>    color = 'p')

    Draws a pose with the given focal length (1), width (0.3), height (0.2)
    and color (red)
    >>>ruby_pose(file, np.array([[9, 5, 5]]), R, focal = 1, width = 0.3,
    >>>    height = 0.2, color = 'r')

    """
    if type(P) is not np.ndarray:
        TypeError('Error in ruby_pose. Type of P is not valid. ',
            'Expects an numpy.ndarray')

    if not(P.shape[0] == 1 and P.shape[1] == 3):
        ValueError('Error in ruby_pose. Dimension of P is not valid')

    if type(R) is not np.ndarray:
        TypeError('Error in ruby_pose. Type of R is not valid. ',
            'Expects an numpy.ndarray')

    if not(R.shape[0] == 3 and R.shape[1] == 3):
        ValueError('Error in ruby_pose. Dimension of R is not valid')

    for elt in P[0]:
        if not isinstance(elt, numbers.Real):
            raise TypeError('Error in ruby_pose. ',
                'P should consist of only numeric values.')

    for elt in R:
        if not(isinstance(elt[0], numbers.Real) \
            and isinstance(elt[1], numbers.Real) \
            and isinstance(elt[2], numbers.Real)):
            raise TypeError('Error in ruby_pose. ',
                'R should consist of only numeric values.')

    if not((np.matmul(R, np.transpose(R)) == np.matmul(np.transpose(R), R)).all()):
        raise ValueError('Error in ruby_pose. R should be an orthogonal matrix')

    if not isinstance(name, str):
        TypeError('Error in ruby_pose. Type of name is not valid. Expects str')

    valid_colors = ['n', 'w', 'r', 'o', 'y', 'g', 'b', 'p', 'k']

    if color not in valid_colors or not isinstance(color, str):
        raise TypeError('Error in ruby_pose. Not a valid color.')

    if not(isinstance(focal, (int, float))):
        raise TypeError('Error in ruby_pose. Not a valid type for focal. ',
            'Expects a numeric type')

    if not(isinstance(width, (int, float))):
        raise TypeError('Error in ruby_pose. Not a valid type for width. ',
            'Expects a numeric type')

    if not(isinstance(height, (int, float))):
        raise TypeError('Error in ruby_pose. Not a valid type for height. ',
            'Expects a numeric type')

    P = P * SCALE_FACTOR
    P = P[0]

    R = R * SCALE_FACTOR

    ex = R[:, 0]
    ey = R[:, 1]
    ez = R[:, 2]

    a = P + width * ex + height * ey - focal * ez
    b = P - width * ex + height * ey - focal * ez
    c = P - width * ex - height * ey - focal * ez
    d = P + width * ex - height * ey - focal * ez

    ruby_newline(file)
    file.write('group = Sketchup.active_model.entities.add_group')
    ruby_newline(file)

    file.write('group.entities.add_line([' + \
               str(P[0]) + ',' + \
               str(P[1]) + ',' + \
               str(P[2]) + '], [' + \
               str(a[0]) + ',' + \
               str(a[1]) + ',' + \
               str(a[2]) + '])' \
              )
    ruby_newline(file)

    file.write('group.entities.add_line([' + \
               str(P[0]) + ',' + \
               str(P[1]) + ',' + \
               str(P[2]) + '], [' + \
               str(b[0]) + ',' + \
               str(b[1]) + ',' + \
               str(b[2]) + '])' \
              )
    ruby_newline(file)

    file.write('group.entities.add_line([' + \
               str(P[0]) + ',' + \
               str(P[1]) + ',' + \
               str(P[2]) + '], [' + \
               str(c[0]) + ',' + \
               str(c[1]) + ',' + \
               str(c[2]) + '])' \
              )
    ruby_newline(file)

    file.write('group.entities.add_line([' + \
               str(P[0]) + ',' + \
               str(P[1]) + ',' + \
               str(P[2]) + '], [' + \
               str(d[0]) + ',' + \
               str(d[1]) + ',' + \
               str(d[2]) + '])' \
              )
    ruby_newline(file)

    file.write('f = group.entities.add_face([' + \
               str(a[0]) + ',' + \
               str(a[1]) + ',' + \
               str(a[2]) + '], [' + \
               str(b[0]) + ',' + \
               str(b[1]) + ',' + \
               str(b[2]) + '], [' + \
               str(c[0]) + ',' + \
               str(c[1]) + ',' + \
               str(c[2]) + '], [' + \
               str(d[0]) + ',' + \
               str(d[1]) + ',' + \
               str(d[2]) + '])' \
              )
    ruby_newline(file)

    # Strange why specific fixed material here
    file.write('f.material = [255,10,1]')
    ruby_newline(file)

    file.write('f.material.alpha = 0.5')
    ruby_newline(file)

    if not (color == 'n'):
        file.write('group.material = ' + ruby_rgb_color(color))
        ruby_newline(file)

    if not (name == ''):
        file.write('group.name =\'' + name + '\'')
        ruby_newline(file)

def ruby_plane(file, XYZ, color = 'n', texture = '', name = ''):
    """
    Draws the polygon given the coordinates in XYZ. If required, a name and
    color or texture can be specified.

    Parameters
    ----------
    file : file object
        Open ruby script file descriptor
    XYZ : np.ndarray
        N-by-3 array of point coordinates
    color : str (optional)
        One of the following colors:
        'n' (default), 'w', 'r', 'o', 'y', 'g', 'b', 'p', 'k'
    name : str (optional)
        Label
    texture : str (optional)
        Path to an image file with extension .png .jpg or .jpeg

    Examples
    --------
    Draws a minimalistic transparent plane
    >>>ruby_plane(file, np.array([[0, 5, 5], [0, 5, 7], [0, 7, 5]]))

    Draws a plane with color(blue) and name(myplane)
    >>>ruby_plane(file, np.array([[0, 1, 3], [0, 1, 5], [1, 2, 5], [1, 2, 3]]),
    >>>    color = 'b', name = 'myplane')

    """
    if type(XYZ) is not np.ndarray:
        raise TypeError('Error in ruby_plane. XYZ should be a numpy.array.')

    if not(XYZ.shape[1] == 3):
        raise ValueError('Error in ruby_plane. Dimension of XYZ is invalid.')

    if XYZ.shape[0] < 3:
        raise ValueError('Error in ruby_plane. Dimension of XYZ is invalid.')

    for elt in XYZ:
        if not(isinstance(elt[0], numbers.Real) \
        and isinstance(elt[1], numbers.Real) \
        and isinstance(elt[2], numbers.Real)):
            raise TypeError('Error in ruby_plane. ',
                'XYZ should consist of only numeric values.')

    if not isinstance(name, str):
        TypeError('Error in ruby_plane. Type of name is not valid. Expects str')

    valid_colors = ['n', 'w', 'r', 'o', 'y', 'g', 'b', 'p', 'k']

    if color not in valid_colors or not isinstance(color, str):
        raise TypeError('Error in ruby_plane. Not a valid color.')

    if not texture == '':
        if not isinstance(texture, str):
            raise TypeError('Error in ruby_ellipsoid. Expects a string path')

    iscolinear = True
    for index in range(XYZ.shape[0] - 3):
        A = np.array([[XYZ[index, 0], XYZ[index, 1], XYZ[index, 2]]])
        B = np.array([[XYZ[index + 1, 0], XYZ[index + 1, 1], XYZ[index + 1, 2]]])
        C = np.array([[XYZ[index + 2, 0], XYZ[index + 2, 1], XYZ[index + 2, 2]]])
        cross_product = np.cross(B - A, C - A)
        if ((np.abs(cross_product) > TOL_CROSS_PRODUCT).any()):
            iscolinear = False

    if(iscolinear):
        raise ValueError('Error in ruby_plane. The points are colinear.')


    if not XYZ.shape[0] == 3:
        for index in range(XYZ.shape[0] - 4):
            volume = np.array([[XYZ[index, 0], XYZ[index, 1], XYZ[index, 2], 1], \
                               [XYZ[index + 1, 0], XYZ[index + 1, 1], XYZ[index + 1, 2], 1], \
                               [XYZ[index + 2, 0], XYZ[index + 2, 1], XYZ[index + 2, 2], 1], \
                               [XYZ[index + 3, 0], XYZ[index + 3, 1], XYZ[index + 3, 2], 1]] \
                             )
            if not (np.linalg.det(volume) < TOL_COPLANARITY):
                raise ValueError('Error in ruby_plane. The points are not coplanar')

    ruby_newline(file)
    file.write('plane = Sketchup.active_model.entities.add_group')

    ruby_newline(file)
    file.write('plane_entities = plane.entities')

    ruby_newline(file)
    file.write('pts=[[')

    for index in range(XYZ.shape[0] - 1):
        file.write(str(SCALE_FACTOR * XYZ[index, 0]) + ',' + \
                   str(SCALE_FACTOR * XYZ[index, 1]) + ',' + \
                   str(SCALE_FACTOR * XYZ[index, 2]) + '],[' \
                  )
    file.write(str(SCALE_FACTOR * XYZ[XYZ.shape[0] - 1, 0]) + ',' + \
                   str(SCALE_FACTOR * XYZ[XYZ.shape[0] - 1, 1]) + ',' + \
                   str(SCALE_FACTOR * XYZ[XYZ.shape[0] - 1, 2]) + ']]' \
                  )

    ruby_newline(file)
    file.write('face = plane_entities.add_face(pts)')

    if not (color == 'n'):
        ruby_newline(file)
        file.write('plane.material = ' + ruby_rgb_color(color))

    if not (name == ''):
        ruby_newline(file)
        file.write('plane.name =\'' + name +'\'')

    max_x = max(XYZ[:, 0])
    max_y = max(XYZ[:, 1])
    max_z = max(XYZ[:, 2])

    min_x = min(XYZ[:, 0])
    min_y = min(XYZ[:, 1])
    min_z = min(XYZ[:, 2])

    abs_x = abs(max_x - min_x)
    abs_y = abs(max_y - min_y)
    abs_z = abs(max_z - min_z)

    plane_size = max(max(abs_x, abs_y), abs_z)

    if not(texture == ''):
        ruby_newline(file)
        file.write('texture_path = "#{File.dirname(__FILE__)}' + texture + '"')

        ruby_newline(file)
        file.write('materials=Sketchup.active_model.materials')

        ruby_newline(file)
        file.write('plane_t = materials.add "plane texture"')

        ruby_newline(file)
        file.write('plane_t.texture = texture_path')

        ruby_newline(file)
        file.write('plane_t.texture.size = ' + str(plane_size * SCALE_FACTOR))

        ruby_newline(file)
        file.write('plane.material = plane_t')

    ruby_newline(file)
    file.write('plane = plane.explode')
    ruby_newline(file)
    file.write('plane_face = nil')
    ruby_newline(file)
    ruby_newline(file)
    file.write('plane.each{|p| ')
    ruby_newline(file)
    file.write('if p.is_a?(Sketchup::Face )')
    ruby_newline(file)
    file.write('plane_face=p')
    ruby_newline(file)
    file.write('end}')
    ruby_newline(file)

def ruby_theodolite(file, P, name = ''):
    """
    Places a theodolite at the coordinates P. If required, a name can be
    specified.

    Parameters
    ----------
    file : file object
        Open ruby script file descriptor
    P : np.ndarray
        1-by-3 array of coordinates
    name : str (optional)
        Label

    """

    if type(P) is not np.ndarray:
        raise TypeError('Error in ruby_theodolite. P should be a numpy.array.')

    if not(P.shape[1] == 3):
        raise ValueError('Error in ruby_theodolite. Dimension of P is invalid.')

    if not(P.shape[0] == 1):
        raise ValueError('Error in ruby_theodolite. Dimension of P is invalid.')

    for elt in P:
        if not(isinstance(elt[0], numbers.Real) \
            and isinstance(elt[1], numbers.Real) \
            and isinstance(elt[2], numbers.Real)):
            raise TypeError('Error in ruby_theodolite. ',
                'P should consist of only numeric values.')

    if not isinstance(name, str):
        TypeError('Error in ruby_theodolite. ',
            'Type of name is not valid. Expects str')

    ruby_newline(file)
    file.write('theodolite = Sketchup.active_model.entities.add_group')

    x = P[0, 0]
    y = P[0, 1]
    z = P[0, 2]

    r = 0.33
    l = 0.15

    ruby_line(file, np.array([[x, y, z + 1],
        [x - r * np.sqrt(3) * 0.5, y - 0.5 * r, z]]))
    ruby_line(file, np.array([[x, y, z + 1],
        [x, y + r, z]]))
    ruby_line(file, np.array([[x, y, z + 1],
        [x + r * np.sqrt(3) * 0.5, y - 0.5 * r, z]]))

    ruby_newline(file)

    file.write('face1=[[')
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x + l)) + ',' + \
               str(SCALE_FACTOR * (y - l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1)) + '],['
              )
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x + l)) + ',' + \
               str(SCALE_FACTOR * (y + l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1)) + '],['
              )
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x - l)) + ',' + \
               str(SCALE_FACTOR * (y + l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1)) + '],['
              )
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x - l)) + ',' + \
               str(SCALE_FACTOR * (y - l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1)) + ']]'
              )
    ruby_newline(file)

    file.write('face2=[[')
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x - l)) + ',' + \
               str(SCALE_FACTOR * (y - l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1 + l)) + '],['
              )
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x - l)) + ',' + \
               str(SCALE_FACTOR * (y + l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1 + l)) + '],['
              )
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x + l)) + ',' + \
               str(SCALE_FACTOR * (y + l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1 + l)) + '],['
              )
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x + l)) + ',' + \
               str(SCALE_FACTOR * (y - l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1 + l)) + ']]'
              )
    ruby_newline(file)

    file.write('face3=[[')
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x + l)) + ',' + \
               str(SCALE_FACTOR * (y - l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1)) + '],['
              )
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x - l)) + ',' + \
               str(SCALE_FACTOR * (y - l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1)) + '],['
              )
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x - l)) + ',' + \
               str(SCALE_FACTOR * (y - l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1 + l)) + '],['
              )
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x + l)) + ',' + \
               str(SCALE_FACTOR * (y - l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1 + l)) + ']]'
              )
    ruby_newline(file)

    file.write('face4=[[')
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x - l)) + ',' + \
               str(SCALE_FACTOR * (y - l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1)) + '],['
              )
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x - l)) + ',' + \
               str(SCALE_FACTOR * (y + l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1)) + '],['
              )
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x - l)) + ',' + \
               str(SCALE_FACTOR * (y + l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1 + l)) + '],['
              )
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x - l)) + ',' + \
               str(SCALE_FACTOR * (y - l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1 + l)) + ']]'
              )
    ruby_newline(file)

    file.write('face5=[[')
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x + l)) + ',' + \
               str(SCALE_FACTOR * (y + l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1)) + '],['
              )
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x - l)) + ',' + \
               str(SCALE_FACTOR * (y + l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1)) + '],['
              )
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x - l)) + ',' + \
               str(SCALE_FACTOR * (y + l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1 + l)) + '],['
              )
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x + l)) + ',' + \
               str(SCALE_FACTOR * (y + l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1 + l)) + ']]'
              )
    ruby_newline(file)

    file.write('face6=[[')
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x + l)) + ',' + \
               str(SCALE_FACTOR * (y - l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1)) + '],['
              )
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x + l)) + ',' + \
               str(SCALE_FACTOR * (y + l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1)) + '],['
              )
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x + l)) + ',' + \
               str(SCALE_FACTOR * (y + l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1 + l)) + '],['
              )
    ruby_newline(file)

    file.write(str(SCALE_FACTOR * (x + l)) + ',' + \
               str(SCALE_FACTOR * (y - l * 0.5)) + ',' + \
               str(SCALE_FACTOR * (z + 1 + l)) + ']]'
              )
    ruby_newline(file)

    file.write('f = theodolite.entities.add_face(face1)')
    ruby_newline(file)

    file.write('f = theodolite.entities.add_face(face2)')
    ruby_newline(file)

    file.write('f = theodolite.entities.add_face(face3)')
    ruby_newline(file)

    file.write('f = theodolite.entities.add_face(face4)')
    ruby_newline(file)

    file.write('f = theodolite.entities.add_face(face5)')
    ruby_newline(file)

    file.write('f = theodolite.entities.add_face(face6)')
    ruby_newline(file)

    file.write('circle1 = theodolite.entities.add_circle([' +  \
               str(SCALE_FACTOR * (x+l)) + ',' + \
               str(SCALE_FACTOR * y) + ',' + \
               str(SCALE_FACTOR * (z + (1 +l * 0.5))) +
               '],X_AXIS,39.3701 * 0.03,24)' \
              )
    ruby_newline(file)

    if not (name == ''):
        file.write('theodolite.name =\'' + name +'\'')
        ruby_newline(file)

def ruby_antenna(file, XYZ, name):
    """
    Places antennas at the coordinates XYZ. If required, a name can be
    specified.

    Parameters
    ----------
    file : file object
        Open ruby script file descriptor
    XYZ : np.ndarray
        N-by-3 array of antenna coordinates
    name : str (optional)
        Label

    """
    if type(XYZ) is not np.ndarray:
        raise TypeError('Error in ruby_antenna. P should be a numpy.array.')

    if not(XYZ.shape[1] == 3):
        raise ValueError('Error in ruby_antenna. Dimension of P is invalid.')

    if not(XYZ.shape[0] >= 1):
        raise ValueError('Error in ruby_antenna. Dimension of P is invalid.')

    for elt in XYZ:
        if not(isinstance(elt[0], numbers.Real) \
            and isinstance(elt[1], numbers.Real) \
            and isinstance(elt[2], numbers.Real)):
            raise TypeError('Error in ruby_antenna. ',
                'XYZ should consist of only numeric values.')

    if not isinstance(name, str):
        TypeError('Error in ruby_antenna. ',
            'Type of name is not valid. Expects str')

    ruby_newline(file)
    file.write('antenna = Sketchup.active_model.entities.add_group')

    width = 0.2
    height = 2

    for p in XYZ:
        xi = p[0]
        yi = p[1]
        zi = p[2]
        ruby_newline(file)
        file.write('points=[[')

        file.write(str(SCALE_FACTOR * (xi - width * 0.5)) + ',' + \
                   str(SCALE_FACTOR * (yi)) + ',' + \
                   str(SCALE_FACTOR * (zi)) + '],[' \
                  )

        file.write(str(SCALE_FACTOR * (xi + width * 0.5)) + ',' + \
                   str(SCALE_FACTOR * (yi)) + ',' + \
                   str(SCALE_FACTOR * (zi)) + '],[' \
                  )

        file.write(str(SCALE_FACTOR * (xi + width * 0.5)) + ',' + \
                   str(SCALE_FACTOR * (yi)) + ',' + \
                   str(SCALE_FACTOR * (zi + height)) + '],['
                  )

        file.write(str(SCALE_FACTOR * (xi - width * 0.5)) + ',' + \
                   str(SCALE_FACTOR * (yi)) + ',' + \
                   str(SCALE_FACTOR * (zi + height)) + ']]' \
                  )

        ruby_newline(file)
        file.write('f2 = antenna.entities.add_face(points)')

        ruby_newline(file)
        file.write('c2 = antenna.entities.add_circle([' + \
                    str(SCALE_FACTOR * xi) +  ',' + \
                    str(SCALE_FACTOR * yi) + ',' + \
                    str(SCALE_FACTOR * (zi)) + '],Z_AXIS,39.3701* 0.01,24)' \
                  )

        ruby_newline(file)
        file.write('f2.followme(c2)')

        ruby_newline(file)
        file.write('antenna.material = ' +  ruby_rgb_color('r'))

        if not (name == ''):
            ruby_newline(file)
            file.write('antenna.name =\'' + name +'\'')

        ruby_newline(file)

def ruby_resection(file, P_theodolite, XYZ_antenna, name = ''):
    """
    Draws a resetcion. If required, a name can be
    specified.

    Parameters
    ----------
    file : file object
        Open ruby script file descriptor
    P_theodolite : np.ndarray
        1-by-3 array of coordinates
    XYZ_antenna : np.ndarray
        N-by-3 list of antenna positions, min 2 entries required
    name : str (optional)
        Label

    Examples
    --------
    Draws a resection with 3 antennas
    >>>ruby_resection(file, np.array([[0, -5, 0]]),
    >>>    np.array([[0, -10, 0], [0, -2, 0], [-3, 0, 0]]))

    """
    if type(P_theodolite) is not np.ndarray:
        raise TypeError('Error in ruby_resection. ' \
            + 'P_theodolite should be a numpy.array.')

    if not(P_theodolite.shape[1] == 3):
        raise ValueError('Error in ruby_resection. ' \
            + 'Dimension of P_theodolite is invalid.')

    if not(P_theodolite.shape[0] == 1):
        raise ValueError('Error in ruby_resection. ' \
            + 'Dimension of P_theodolite is invalid.')

    for elt in P_theodolite:
        if not(isinstance(elt[0], numbers.Real) \
            and isinstance(elt[1], numbers.Real) \
            and isinstance(elt[2], numbers.Real)):
            raise TypeError('Error in ruby_resection. ',
                'P_theodolite should consist of only numeric values.')

    if not(XYZ_antenna.shape[1] == 3):
        raise ValueError('Error in ruby_resection. ',
            'Dimension of XYZ_antenna is invalid.')

    if not(XYZ_antenna.shape[0] >= 1):
        raise ValueError('Error in ruby_resection. ',
            'Dimension of XYZ_antenna is invalid.')

    if type(XYZ_antenna) is not np.ndarray:
        raise TypeError('Error in ruby_resection. '
            'XYZ_antenna should be a numpy.array.')

    for elt in XYZ_antenna:
        if not(isinstance(elt[0], numbers.Real) \
            and isinstance(elt[1], numbers.Real) \
            and isinstance(elt[2], numbers.Real)):
            raise TypeError('Error in ruby_resection. ',
                'XYZ_antenna should consist of only numeric values.')

    if not isinstance(name, str):
        TypeError('Error in ruby_resection. ',
            'Type of name is not valid. Expects str')

    ruby_newline(file)
    file.write('resection = Sketchup.active_model.entities.add_group')

    ruby_newline(file)

    x = P_theodolite[0, 0]
    y = P_theodolite[0, 1]
    z = P_theodolite[0, 2]

    ruby_theodolite(file, P_theodolite, name = name)

    for elt in XYZ_antenna:
        xi = elt[0]
        yi = elt[1]
        zi = elt[2]

        ruby_antenna(file, np.array([[xi, yi, zi]]), name = name)

        ruby_line(file, np.array([[xi, yi, zi + 1.5], [x, y, z + 1.07]]))
        ruby_newline(file)

def ruby_tin(file, XYZ, triangles, color = 'n', texture = '', name = ''):
    """
    Draws DEM (Digital Elevation Model) having TIN structure (Triangular
    Irregular Network). Triangles can be obtained from the points using the
    delaunay function.

    Parameters
    ----------
    file : file object
        Open ruby script file descriptor
    XYZ : np.ndarray
        N-by-3 array of coordinates
    triangles : np.ndarray
        N-by-3 array of triangles, as returned by delaunay.simplices
    color : str (optional)
        One of the following colors:
        'n' (default), 'w', 'r', 'o', 'y', 'g', 'b', 'p', 'k'
    texture : str (optional)
        Path to an image file with extension .png .jpg or .jpeg
    name : str (optional)
        Label of the DEM

    Example
    --------
    Prepare points array
    >>>p1 = 10 * np.random.rand(100, 1) + 10
    >>>p2 = 10 * np.random.rand(100, 1)
    >>>p3 = np.random.rand(100, 1)
    >>>XYZ = np.concatenate((p1, p2), axis = 1)
    >>>XYZ = np.concatenate((XYZ, p3), axis = 1)

    Get triangles
    >>>triangles = Delaunay(XYZ[:, 0:2])

    Create DEM with texture and no label
    >>>ruby_tin(file, XYZ, triangles.simplices.copy(),
    texture = '/images/rainbow.jpeg')

    """
    if type(XYZ) is not np.ndarray:
        raise TypeError('Error in ruby_tin. XYZ should be a numpy.array.')

    if not(XYZ.shape[1] == 3):
        raise ValueError('Error in ruby_tin. Dimension of XYZ is invalid.')

    if not(XYZ.shape[0] >= 1):
        raise ValueError('Error in ruby_tin. Dimension of XYZ is invalid.')

    for elt in XYZ:
        if not(isinstance(elt[0], numbers.Real) \
            and isinstance(elt[1], numbers.Real) \
            and isinstance(elt[2], numbers.Real)):
            raise TypeError('Error in ruby_tin. ',
                'XYZ should consist of only numeric values.')

    if type(triangles) is not np.ndarray:
        raise TypeError('Error in ruby_tin. triangles should be a numpy.array.')

    if not(triangles.shape[1] == 3):
        raise ValueError('Error in ruby_tin. Dimension of triangles is invalid.')

    if not(triangles.shape[0] >= 1):
        raise ValueError('Error in ruby_tin. Dimension of triangles is invalid.')

    for elt in triangles:
        if not(isinstance(elt[0], numbers.Real)) \
            and not(isinstance(elt[1], numbers.Real)) \
            and not(isinstance(elt[2], numbers.Real)):
            raise TypeError('Error in ruby_tin. ',
                'triangles should consist of only numeric values.')

    if not isinstance(name, str):
        TypeError('Error in ruby_tin. Type of name is not valid. Expects str')

    if not texture == '':
        if not isinstance(texture, str):
            raise TypeError('Error in ruby_tin. ',
                'Not a valid texture, expects a file path')
        elif not(texture.endswith('.jpeg') \
            or texture.endswith('jpg') \
            or texture.endswith('.png')):
            raise TypeError('Error in ruby_tin. Not a valid texture, ',
                'expects file extension to be one of these: .png, .jpg, .jpeg')


    if (triangles < 0).any():
        raise ValueError('error in ruby_tin. ',
            'triangles does not match with any point')

    if (triangles > XYZ.shape[0]).any():
        raise ValueError('error in ruby_tin. ',
            'triangles does not match with any point')

    ruby_newline(file)
    file.write('group = Sketchup.active_model.entities.add_group')
    ruby_newline(file)
    count = 0
    for point in XYZ:
        file.write('p' + str(count) + ' = [' + \
                   str(SCALE_FACTOR * point[0]) + ',' + \
                   str(SCALE_FACTOR * point[1]) + ',' + \
                   str(SCALE_FACTOR * point[2]) + ']' \
                  )
        ruby_newline(file)
        count = count + 1

    ruby_newline(file)

    for t in triangles:
        file.write('group.entities.add_face(p' + str(t[0]) + ',p' + str(t[1]) + \
                   ',p' + str(t[2]) + ')' \
                  )
        ruby_newline(file)

    if not (color == 'n'):
        ruby_newline(file)
        file.write('group.material = ' + ruby_rgb_color(color))

    if not (name == ''):
        ruby_newline(file)
        file.write('group.name =\'' + name +'\'')

    max_x = max(XYZ[:, 0])
    max_y = max(XYZ[:, 1])
    max_z = max(XYZ[:, 2])

    min_x = min(XYZ[:, 0])
    min_y = min(XYZ[:, 1])
    min_z = min(XYZ[:, 2])

    abs_x = abs(max_x - min_x)
    abs_y = abs(max_y - min_y)
    abs_z = abs(max_z - min_z)

    plane_size = max(max(abs_x, abs_y), abs_z)

    if not(texture == ''):
        ruby_plane(file, np.array([ [min_x, min_y, max_z + 3], \
                                    [min_x, max_y, max_z + 3], \
                                    [max_x, max_y, max_z + 3], \
                                    [max_x, min_y, max_z + 3]]), \
                                  texture = texture \
                                 )
        ruby_newline(file)
        file.write('faces = group.entities.grep( Sketchup::Face ).each{|f| ' \
            + 'f.material = plane_face.material }')
        ruby_newline(file)
        file.write('faces = group.entities.grep( Sketchup::Face ).each{|f| ' \
            + 'f.set_texture_projection(plane_face.normal, true) }')
        ruby_newline(file)
        file.write('faces = group.entities.grep( Sketchup::Face ).each{|f| ' \
            + 'f.back_material = plane_face.material }')
        ruby_newline(file)
        file.write('faces = group.entities.grep( Sketchup::Face ).each{|f| ' \
            + 'f.set_texture_projection(plane_face.normal, false) }')
        ruby_newline(file)
        file.write('plane.each{|p| ')
        ruby_newline(file)
        file.write('if p.is_a?(Sketchup::Edge )')
        ruby_newline(file)
        file.write('p.erase!')
        ruby_newline(file)
        file.write('end}')
        ruby_newline(file)

def ruby_arrow(file, P, v, color = 'n', name = ''):
    """
    Draws quiver plot with position P and direction v. Color and name can be
    defined if required.

    Parameters
    ----------
    file : file object
        Open ruby script file descriptor
    P : np.ndarray
        3-by-1 coordinate vector
    v : np.ndarray
        3-by-1 direction vector
    color : str (optional)
        One of the following colors:
        'n' (default), 'w', 'r', 'o', 'y', 'g', 'b', 'p', 'k'
    name : str (optional)
        Name of the arrow

    Examples
    --------
    Draws an arrow at 5,5,5, pointing along x axis
    >>>ruby_arrow(file, np.array([[5], [5], [5]]), np.array([[1], [0], [0]]))

    Draws a red arrow
    >>>ruby_arrow(file, np.array([[5], [5], [5]]), np.array([[0], [1], [0]]), \
    >>>    color = 'r')

    Draws a green arrow with label
    >>>ruby_arrow(file, np.array([[5], [5], [5]]), np.array([[0], [0], [1]]), \
    >>>    color = 'g', name = "arrow3")

    """
    if type(P) is not np.ndarray:
        TypeError('Error in ruby_arrow. Type of P is not valid. ',
            'Expects an numpy.ndarray')

    if not(P.shape[0] == 3 and P.shape[1] == 1):
        ValueError('Error in ruby_arrow. Dimension of P is not valid')

    if type(v) is not np.ndarray:
        TypeError('Error in ruby_arrow. Type of v is not valid. ',
            'Expects an numpy.ndarray')

    if not(v.shape[0] == 3 and v.shape[1] == 1):
        ValueError('Error in ruby_arrow. Dimension of v is not valid')

    for elt in P:
        if not isinstance(elt[0], numbers.Real):
            raise TypeError('Error in ruby_arrow. ',
                'P should consist of only numeric values.')

    for elt in v:
        if not(isinstance(elt[0], numbers.Real)):
            raise TypeError('Error in ruby_arrow. ',
                'v should consist of only numeric values.')

    if not isinstance(name, str):
        TypeError('Error in ruby_arrow. Type of name is not valid. Expects str')

    valid_colors = ['n', 'w', 'r', 'o', 'y', 'g', 'b', 'p', 'k']

    if not isinstance(color, str) or color not in valid_colors:
        raise TypeError('Error in ruby_arrow. Not a valid color.')

    # Cross product with unity vector as rotation axis
    V = np.array([[-v[1, 0]], [v[0, 0]], [0]])
    # Angle around that axis
    t = np.arctan2(np.linalg.norm(V), v[2, 0])
    # Min rotation angle used to avoid issue with 0 and pi rotation (norm(V)==0)
    tol_angle = 0.001 * np.pi / 180

    file.write('arr1 = arr0.copy')
    ruby_newline(file)

    file.write('s = Geom::Transformation.scaling(' \
        + str(np.linalg.norm(v)) + ',' \
        + str(np.linalg.norm(v)) + ',' \
        + str(np.linalg.norm(v)) + ')')
    ruby_newline(file)

    if np.absolute(t) > tol_angle :
        if np.absolute(np.absolute(t) - np.pi) > tol_angle:
            V = np.divide(V, np.linalg.norm(V))
            file.write('r = Geom::Transformation.rotation([0,0,0],[' \
                + str(V[0, 0]) + ',' + str(V[1, 0]) + ',' + str(V[2, 0]) + '],' \
                + str(t) + ')')
            ruby_newline(file)
        else:
            file.write('r = Geom::Transformation.rotation([0,0,0],[1,0,0],' \
                + str(np.pi) + ')')
            ruby_newline(file)

    file.write('t = Geom::Transformation.new([' \
        + str(P[0, 0]) + ',' + str(P[1, 0]) + ',' + str(P[2, 0]) + '])')
    ruby_newline(file)

    file.write('arr1.entities.transform_entities(s,arr1)')
    ruby_newline(file)

    if np.absolute(t) > tol_angle :
        file.write('arr1.entities.transform_entities(r,arr1)')
        ruby_newline(file)

    file.write('arr1.entities.transform_entities(t,arr1)')
    ruby_newline(file)

    if not (color == 'n'):
        ruby_newline(file)
        file.write('arr1.material = ' + ruby_rgb_color(color))

    if not (name == ''):
        ruby_newline(file)
        file.write('arr1.name =\'' + name +'\'')

    ruby_newline(file)
    ruby_newline(file)
