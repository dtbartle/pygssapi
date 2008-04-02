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
