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

cdef class OID
cdef class OIDSet

cdef class Name:
    cdef gss_name_t name

    cdef readonly OM_uint32 maj_stat, min_stat

    def __init__(self):
        self.name = GSS_C_NO_NAME
        self.maj_stat = GSS_S_COMPLETE
        self.min_stat = 0

    def __dealloc__(self):
        cdef OM_uint32 maj_stat, min_stat
        if self.name != GSS_C_NO_NAME:
            maj_stat = gss_release_name(&min_stat, &self.name)
            if GSS_ERROR(maj_stat):
                raise GSSError(None, maj_stat, min_stat)

    def __str__(self):
        return self.display_name()[0]

    def display_name(self):
        '''
            display_name()

            returns (output_name, output_name_type)
        '''
        cdef OM_uint32 min_stat, maj_stat

        # call gss_display_name
        cdef gss_buffer_desc _output_name
        cdef OID output_name_type
        output_name_type = OID()
        self.maj_stat = gss_display_name(&self.min_stat, self.name,
            &_output_name, &output_name_type.oid)
        if GSS_ERROR(self.maj_stat):
            raise GSSError(self, self.maj_stat, self.min_stat)

        # cleanup arguments (_output_name)
        output_name = _gss_buffer_t_to_str(&_output_name)
        maj_stat = gss_release_buffer(&min_stat, &_output_name)
        if GSS_ERROR(maj_stat):
            self.maj_stat = maj_stat
            self.min_stat = min_stat
            raise GSSError(self, self.maj_stat, self.min_stat)

        return (output_name, output_name_type)

    def compare_name(self,
            Name name2 not None
            ):
        '''
            compare_name(name2)

            returns name_equal
        '''
        cdef int name_equal
        self.maj_stat = gss_compare_name(&self.min_stat, self.name,
            name2.name, &name_equal)
        if GSS_ERROR(self.maj_stat):
            raise GSSError(self, self.maj_stat, self.min_stat)

        return name_equal

    # TODO: gss_inquire_mechs_for_name is not defined in libgssapi.so
    #def inquire_mechs_for_name(self):
    #    '''
    #        inquire_mechs_for_name()
    #
    #        returns mech_types
    #    '''
    #    cdef OIDSet mech_types
    #    mech_types = OIDSet()
    #    self.maj_stat = gss_inquire_mechs_for_name(&self.min_stat,
    #        self.name, &mech_types.oid_set)
    #    if GSS_ERROR(self.maj_stat):
    #        raise GSSError(self, self.maj_stat, self.min_stat)
    #
    #    return mech_types

    def canonicalize_name(self,
            OID mech_type not None
            ):
        '''
            canonicalize_name(mech_type)

            returns output_name
        '''
        cdef Name output_name
        output_name = Name()
        self.maj_stat = gss_canonicalize_name(&self.min_stat,
            self.name, mech_type.oid, &output_name.name)
        if GSS_ERROR(self.maj_stat):
            raise GSSError(self, self.maj_stat, self.min_stat)

        return output_name

    def export_name(self):
        '''
            explort_name()

            returns exported_name
        '''
        cdef OM_uint32 min_stat, maj_stat

        # call gss_export_name
        cdef gss_buffer_desc _exported_name
        self.maj_stat = gss_export_name(&self.min_stat,
            self.name, &_exported_name)
        if GSS_ERROR(self.maj_stat):
            raise GSSError(self, self.maj_stat, self.min_stat)

        # cleanup arguments (gss_export_name)
        exported_name = _gss_buffer_t_to_str(&_exported_name)
        maj_stat = gss_release_buffer(&min_stat, &_exported_name)
        if GSS_ERROR(maj_stat):
            self.maj_stat = maj_stat
            self.min_stat = min_stat
            raise GSSError(self, self.maj_stat, self.min_stat)

        return exported_name

def import_name(
        object input_name,
        OID input_name_type
        ):
    '''
        import_name(input_name, input_name_type)

        returns output_name
    '''
    cdef gss_buffer_desc _input_name
    _str_to_gss_buffer_t(input_name, &_input_name)
    cdef Name output_name
    output_name = Name()
    output_name.maj_stat = gss_import_name(&output_name.min_stat,
        &_input_name, input_name_type.oid, &output_name.name)
    if GSS_ERROR(output_name.maj_stat):
        raise GSSError(output_name.maj_stat, output_name.min_stat)

    return output_name
