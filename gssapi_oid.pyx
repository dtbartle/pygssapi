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

cdef class OID:
    cdef gss_OID oid
    cdef gss_OID_desc oid_desc
    cdef object _data

    cdef readonly OM_uint32 maj_stat, min_stat

    def __init__(self, object data = None):
        if data == None:
            self.oid = GSS_C_NO_OID
        else:
            self.oid = &self.oid_desc
            self._data = data # save a reference
            self.oid_desc.length = len(data)
            self.oid.elements = PyString_AsString(data)

    def __len__(self):
        if self.oid == GSS_C_NO_OID:
            return 0
        else:
            return self.oid.length

    def __getitem__(self, int x):
        if self.oid == GSS_C_NO_OID:
            raise IndexError
        if x < 0 or x >= self.oid.length:
            raise IndexError
        cdef char *_elements
        _elements = <char*>self.oid.elements
        return _elements[x]

    def __str__(self):
        if self.oid == GSS_C_NO_OID:
            return ""
        cdef unsigned char *_elements
        _elements = <unsigned char*>self.oid.elements
        ret = ""
        for i from 0 <= i < self.oid.length:
            ret = ret + "\\x" + chr(_elements[i]).encode('hex')
        return ret

    def inquire_names_for_mech(self):
        '''
            inquire_names_for_mech()

            returns name_types
        '''
        cdef OIDSet name_types
        name_types = OIDSet()
        self.maj_stat = gss_inquire_names_for_mech(&self.min_stat,
            self.oid, &name_types.oid_set)
        if GSS_ERROR(self.maj_stat):
            raise GSSError(self, self.maj_stat, self.min_stat)

cdef class OIDSet:
    cdef gss_OID_set oid_set

    cdef readonly OM_uint32 maj_stat, min_stat

    def __init__(self):
        self.oid_set = GSS_C_NO_OID_SET
        self.maj_stat = GSS_S_COMPLETE
        self.min_stat = 0

    def __dealloc__(self):
        cdef OM_uint32 maj_stat, min_stat
        if self.oid_set != GSS_C_NO_OID_SET:
            self.maj_stat = maj_stat
            self.min_stat = min_stat
            maj_stat = gss_release_oid_set(&min_stat, &self.oid_set)
            if GSS_ERROR(maj_stat):
                raise GSSError(None, self.maj_stat, self.min_stat)

    def __len__(self):
        if self.oid_set != NULL:
            return oid_set.count
        else:
            return 0

    def __getitem__(self,
            int x
            ):
        cdef OID oid
        if self.oid_set != NULL:
            if x >= 0 and x < self.oid_set.count:
                oid = OID()
                oid.oid = &self.oid_set.elements[x]
                return oid
            else:
                raise IndexError
        else:
            raise IndexError

    def __contains__(self,
            OID member_oid not None
            ):
        cdef int present
        self.maj_stat = gss_test_oid_set_member(&self.min_stat,
            member_oid.oid, self.oid_set, &present)
        if GSS_ERROR(self.maj_stat):
            raise GSSError(self, self.maj_stat, self.min_stat)
        return present

    def append(self,
            OID member_oid not None
            ):
        if self.oid_set == NULL:
            self.maj_stat = gss_create_empty_oid_set(
                &self.min_stat, &self.oid_set)
            if GSS_ERROR(self.maj_stat):
                raise GSSError(self, self.maj_stat, self.min_stat)
        self.maj_stat = gss_add_oid_set_member(&self.min_stat,
            member_oid.oid, &self.oid_set)
        if GSS_ERROR(self.maj_stat):
            raise GSSError(self, self.maj_stat, self.min_stat)

def indicate_mechs():
    '''
        indicate_mechs()

        returns mech_set
    '''
    cdef gss_OID_set _mech_set

    cdef OIDSet mech_set
    mech_set = OIDSet()
    mech_set.maj_stat = gss_indicate_mechs(&mech_set.min_stat, &_mech_set)
    if GSS_ERROR(mech_set.maj_stat):
        raise GSSError(mech_Set, mech_set.maj_stat, mech_set.min_stat)

    return mech_set

GSS_C_NT_USER_NAME =            OID("\x2a\x86\x48\x86\xf7\x12\x01\x02\x01\x01")
GSS_C_NT_MACHINE_UID_NAME =     OID("\x2a\x86\x48\x86\xf7\x12\x01\x02\x01\x02")
GSS_C_NT_STRING_UID_NAME =      OID("\x2a\x86\x48\x86\xf7\x12\x01\x02\x01\x03")
GSS_C_NT_HOSTBASED_SERVICE_X =  OID("\x2b\x06\x01\x05\x06\x02")
GSS_C_NT_HOSTBASED_SERVICE =    OID("\x2a\x86\x48\x86\xf7\x12\x01\x02\x01\x04")
GSS_C_NT_ANONYMOUS =            OID("\x2b\x06\01\x05\x06\x03")
GSS_C_NT_EXPORT_NAME =          OID("\x2b\x06\x01\x05\x06\x04")
GSS_KRB5_MECHANISM =            OID("\x2a\x86\x48\x86\xf7\x12\x01\x02\x02")
GSS_KRB5_NT_PRINCIPAL_NAME =    OID("\x2a\x86\x48\x86\xf7\x12\x01\x02\x02\x01")
