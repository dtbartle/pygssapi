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

cdef class Context

#cdef extern from "pyerrors.h":
#    ctypedef class exceptions.Exception [object PyBaseExceptionObject]:
#        pass

#cdef class GSSError(Exception):
class GSSError(Exception):

    #cdef readonly OM_uint32 major_status, minor_status
    #cdef readonly status_text

    def __init__(self,
            object obj,
            OM_uint32 maj_stat,
            OM_uint32 min_stat
            ):

        self.maj_stat = maj_stat
        self.min_stat = min_stat

        # loop for all status codes (major and minor)
        cdef OM_uint32 _min_stat, _maj_stat, msg_ctx
        cdef gss_buffer_desc _text
        _min_stat = min_stat
        self.status_text = []
        sc = [ (maj_stat, GSS_C_GSS_CODE), (min_stat, GSS_C_MECH_CODE) ]
        for (status, code) in sc:
            msg_ctx = 0
            while True:

                # call gss_display_status
                _maj_stat = gss_display_status(&_min_stat, status,
                    code, GSS_C_NO_OID, &msg_ctx, &_text)
                if GSS_ERROR(_maj_stat):
                    break

                # cleanup arguments (_text) and append text
                text = _gss_buffer_t_to_str(&_text)
                self.status_text.append(text)
                gss_release_buffer(&_min_stat, &_text)
                if msg_ctx == 0:
                    break

        self.message = ". ".join(self.status_text) + "."
        self.args = [obj]

    def __str__(self):
        return self.message
