#
# pygssapi - Python bindings for GSSAPI.
# Copyright 2008 David Bartley
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or 
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

cdef extern from "Python.h":
    char *PyString_AsString(
        object string
    )
    object Py_BuildValue(
        char *format,
        ...
    )

# this function should never cause an exception
# if it does, it's almost certainly very serious and fatal
cdef object _gss_buffer_t_to_str(
        gss_buffer_t buffer
    ):

    return PyString_FromStringAndSize(<char*>buffer.value, buffer.length)

# buffer will be valid until obj is free'd
# this function will raise an exception if obj is not a string
cdef int _str_to_gss_buffer_t(
        object obj,
        gss_buffer_t buffer
    ) except -1:

    buffer.value = PyString_AsString(obj)
    if buffer.value == NULL:
        return -1
    else:
        buffer.length = len(obj)
        return 0
