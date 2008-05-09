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

cdef class ChannelBindings:

    cdef public OM_uint32 initiator_addrtype
    cdef public object initiator_address
    cdef public OM_uint32 acceptor_addrtype
    cdef public object acceptor_address
    cdef public object application_data

    cdef gss_channel_bindings_struct _cb

    def __init__(self,
            OM_uint32 initiator_addrtype,
            object initiator_address,
            OM_uint32 acceptor_addrtype,
            object acceptor_address,
            object application_data
            ):
        self.initiator_addrtype = initiator_addrtype
        self.initiator_address = initiator_address
        self.acceptor_addrtype = acceptor_addrtype
        self.acceptor_address = acceptor_address
        self.application_data = application_data

    cdef gss_channel_bindings_t make(self):
        self._cb.initiator_addrtype = self.initiator_address
        _str_to_gss_buffer_t(self.initiator_address, &self._cb.initiator_address)
        self._cb.acceptor_addrtype = self.acceptor_addrtype
        _str_to_gss_buffer_t(self.acceptor_address, &self._cb.acceptor_address)
        _str_to_gss_buffer_t(self.application_data, &self._cb.application_data)

        return &self._cb
