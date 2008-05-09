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

GSS_C_DELEG_FLAG        = 0x00000001
GSS_C_MUTUAL_FLAG       = 0x00000002
GSS_C_REPLAY_FLAG       = 0x00000004
GSS_C_SEQUENCE_FLAG     = 0x00000008
GSS_C_CONF_FLAG         = 0x00000010
GSS_C_INTEG_FLAG        = 0x00000020
GSS_C_ANON_FLAG         = 0x00000040
GSS_C_PROT_READY_FLAG   = 0x00000080
GSS_C_TRANS_FLAG        = 0x00000100

GSS_S_COMPLETE          = 0x00000000
GSS_S_CONTINUE_NEEDED   = 0x00000001
GSS_S_DUPLICATE_TOKEN   = 0x00000002
GSS_S_OLD_TOKEN         = 0x00000004
GSS_S_UNSEQ_TOKEN       = 0x00000008
GSS_S_GAP_TOKEN         = 0x00000010

GSS_S_CALL_INACCESSIBLE_READ    = 0x01000000
GSS_S_CALL_INACCESSIBLE_WRITE   = 0x02000000
GSS_S_CALL_BAD_STRUCTURE        = 0x03000000

GSS_S_BAD_MECH              = 0x00010000
GSS_S_BAD_NAME              = 0x00020000
GSS_S_BAD_BINDINGS          = 0x00030000
GSS_S_BAD_STATUS            = 0x00040000
GSS_S_BAD_SIG               = 0x00050000
GSS_S_BAD_CRED              = 0x00060000
GSS_S_NO_CONTEXT            = 0x00070000
GSS_S_DEFECTIVE_TOKEN       = 0x00080000
GSS_S_DEFECTIVE_CREDENTIAL  = 0x00090000
GSS_S_CREDENTIALS_EXPIRED   = 0x000a0000
GSS_S_CONTEXT_EXPIRED       = 0x000b0000
GSS_S_FAILURE               = 0x000c0000
GSS_S_BAD_QOP               = 0x000d0000
GSS_S_UNAUTHORIZED          = 0x000e0000
GSS_S_UNAVAILABLE           = 0x000f0000
GSS_S_UNAVAILABLE           = 0x00100000
GSS_S_DUPLICATE_ELEMENT     = 0x00110000
GSS_S_NAME_NOT_MN           = 0x00120000

GSS_C_BOTH      = 0
GSS_C_INITIATE  = 1
GSS_C_ACCEPT    = 2

GSS_C_GSS_CODE  = 1
GSS_C_MECH_CODE = 2

GSS_C_AF_UNSPEC     = 0
GSS_C_AF_LOCAL      = 1
GSS_C_AF_INET       = 2
GSS_C_AF_IMPLINK    = 3
GSS_C_AF_PUP        = 4
GSS_C_AF_CHAOS      = 5
GSS_C_AF_NS         = 6
GSS_C_AF_NBS        = 7
GSS_C_AF_ECMA       = 8
GSS_C_AF_DATAKIT    = 9
GSS_C_AF_CCITT      = 10
GSS_C_AF_SNA        = 11
GSS_C_AF_DECnet     = 12
GSS_C_AF_DLI        = 13
GSS_C_AF_LAT        = 14
GSS_C_AF_HYLINK     = 15
GSS_C_AF_APPLETALK  = 16
GSS_C_AF_BSC        = 17
GSS_C_AF_DSS        = 18
GSS_C_AF_OSI        = 19
GSS_C_AF_X25        = 21
GSS_C_AF_NULLADDR   = 255

GSS_C_QOP_DEFAULT   = 0
GSS_C_INDEFINITE    = 0xffffffff

def display_status(
        OM_uint32 status_value,
        int status_type,
        OID mech_type,
        OM_uint32 message_context
        ):
    '''
        display_status(status_value, status_type, mech_type, message_context)

        returns (message_context, status_string)
    '''
    cdef OM_uint32 maj_stat, min_stat
    if mech_type == None: mech_type = OID()

    # call gss_display_status
    cdef OM_uint32 _message_context
    _message_context = message_context
    cdef gss_buffer_desc _status_string
    maj_stat = gss_display_status(&min_stat, status_value, status_type,
        mech_type.oid, &_message_context, &_status_string)
    if GSS_ERROR(maj_stat):
        raise GSSError(None, maj_stat, min_stat)

    # cleanup arguments (_status_string)
    status_string = _gss_buffer_t_to_str(&_status_string)
    maj_stat = gss_release_buffer(&min_stat, &_status_string)
    if GSS_ERROR(maj_stat):
        raise GSSError(None, maj_stat, min_stat)
    message_context = _message_context

    return (message_context, status_string)
