cdef class Context

cdef _init_sec_context(
        Context context,
        Cred claimant_cred,
        Name target_name,
        OID mech_type,
        int req_flags,
        int time_req,
        ChannelBindings chan_bindings,
        object input_token
        ):
    cdef OM_uint32 maj_stat, min_stat, _min_stat

    # set defaults
    if claimant_cred == None: claimant_cred = Cred()
    if mech_type == None: mech_type = OID()
    # chan_bindings is set later
    if input_token == None: input_token = ''

    # init arguments
    cdef OID actual_mech_type
    actual_mech_type = OID()
    cdef gss_buffer_desc _output_token
    cdef OM_uint32 ret_flags, time_rec
    cdef gss_channel_bindings_t _chan_bindings
    if chan_bindings == None:
        _chan_bindings = GSS_C_NO_CHANNEL_BINDINGS
    else:
        _chan_bindings = chan_bindings.make()
    cdef gss_buffer_desc _input_token
    _str_to_gss_buffer_t(input_token, &_input_token)

    # call gss_init_sec_context
    context.maj_stat = gss_init_sec_context(&context.min_stat,
        claimant_cred.cred, &context.ctx, target_name.name, mech_type.oid,
        req_flags, time_req, _chan_bindings, &_input_token,
        &actual_mech_type.oid, &_output_token, &ret_flags, &time_rec)
    if GSS_ERROR(context.maj_stat):
        raise GSSError(context, context.maj_stat, context.min_stat)

    # cleanup args (_output_token)
    output_token = _gss_buffer_t_to_str(&_output_token)
    maj_stat = gss_release_buffer(&min_stat, &_output_token)
    if GSS_ERROR(maj_stat):
        raise GSSError(context, maj_stat, min_stat)

    return (actual_mech_type, output_token, ret_flags, time_rec)

cdef _accept_sec_context(
        Context context,
        Cred acceptor_cred,
        object input_token,
        ChannelBindings chan_bindings
        ):
    cdef OM_uint32 maj_stat, min_stat, _min_stat

    # set defaults
    if acceptor_cred == None: acceptor_cred = Cred()
    if input_token == None: input_token = ''
    # chan_bindings is set later

    # init arguments
    cdef gss_buffer_desc _input_token
    _str_to_gss_buffer_t(input_token, &_input_token)
    cdef gss_channel_bindings_t _chan_bindings
    if chan_bindings == None:
        _chan_bindings = GSS_C_NO_CHANNEL_BINDINGS
    else:
        _chan_bindings = chan_bindings.make()
    cdef Name src_name
    src_name = Name()
    cdef OID mech_type
    mech_type = OID()
    cdef gss_buffer_desc _output_token
    cdef OM_uint32 ret_flags, time_rec
    cdef Cred delegated_cred
    delegated_cred = Cred()

    # call gss_accept_sec_context
    context.maj_stat = gss_accept_sec_context(&context.min_stat, &context.ctx,
        acceptor_cred.cred, &_input_token, _chan_bindings, &src_name.name,
        &mech_type.oid, &_output_token, &ret_flags, &time_rec,
        &delegated_cred.cred)
    if GSS_ERROR(context.maj_stat):
        raise GSSError(context, context.maj_stat, context.min_stat)

    # cleanup args (_output_token)
    output_token = _gss_buffer_t_to_str(&_output_token)
    maj_stat = gss_release_buffer(&min_stat, &_output_token)
    if GSS_ERROR(maj_stat):
        raise GSSError(context, maj_stat, min_stat)

    return (src_name, mech_type, output_token,
        ret_flags, time_rec, delegated_cred)

cdef class Context:
    cdef gss_ctx_id_t ctx

    cdef readonly OM_uint32 maj_stat, min_stat

    def __init__(self):
        self.ctx = GSS_C_NO_CONTEXT
        self.maj_stat = GSS_S_COMPLETE
        self.min_stat = 0

    def __dealloc__(self):
        cdef OM_uint32 maj_stat, min_stat
        if self.ctx != GSS_C_NO_CONTEXT:
            maj_stat = gss_delete_sec_context(&min_stat,
                &self.ctx, GSS_C_NO_BUFFER)
            if GSS_ERROR(maj_stat):
                raise GSSError(None, maj_stat, min_stat)

    def init_sec_context(self,
            Cred claimant_cred,
            Name target_name not None,
            OID mech_type,
            int req_flags,
            int time_req,
            ChannelBindings chan_bindings,
            object input_token
            ):
        '''
            init_sec_context(claimant_cred, targ_name, mech_type,
                req_flags, time_req, chan_bindings, input_token)

            returns (actual_mech_type, output_token, ret_flags, time_rec)
        '''
        return _init_sec_context(self, claimant_cred, target_name,
            mech_type, req_flags, time_req, chan_bindings, input_token)

    def accept_sec_context(self,
            Cred acceptor_cred,
            object input_token,
            ChannelBindings chan_bindings
            ):
        '''
            accept_sec_context(acceptor_cred, input_token, chan_bindings)

            returns (src_name, mech_type, output_token, ret_flags,
                time_rec, delegated_cred)
        '''
        return _accept_sec_context(self, acceptor_cred,
            input_token, chan_bindings)

    def delete_sec_context(self):
        '''
            delete_sec_context()
        '''
        self.maj_stat = gss_delete_sec_context(&self.min_stat,
            &self.ctx, GSS_C_NO_BUFFER)
        if GSS_ERROR(self.maj_stat):
            raise GSSError(self, self.maj_stat, self.min_stat)

    def process_context_token(self,
            object token
            ):
        '''
            process_context_token(token)
        '''
        cdef OM_uint32 maj_stat, min_stat

        # call gss_process_context_token
        cdef gss_buffer_desc _token
        _str_to_gss_buffer_t(token, &_token)
        self.maj_stat = gss_process_context_token(&self.min_stat,
            self.ctx, &_token)
        if GSS_ERROR(self.maj_stat):
            raise GSSError(self, self.maj_stat, self.min_stat)

    def context_time(self):
        '''
            context_time()

            returns time_rec
        '''
        cdef OM_uint32 time_rec
        self.maj_stat = gss_context_time(&self.min_stat, self.ctx, &time_rec)
        if GSS_ERROR(self.maj_stat):
            raise GSSError(self, self.maj_stat, self.min_stat)
        return time_rec

    def inquire_context(self):
        '''
            inquire_context()

            returns (src_name, targ_name, lifetime_rec, mech_type, ctx_flags,
                locally_initiated, open)
        '''
        cdef OM_uint32 maj_stat, min_stat, _min_stat, lifetime_rec, ctx_flags

        # call gss_inquire_context
        cdef OID mech_type
        mech_type = OID()
        cdef Name src_name, targ_name
        src_name = Name()
        targ_name = Name()
        cdef int locally_initiated, open
        self.maj_stat = gss_inquire_context(&self.min_stat, self.ctx,
            &src_name.name, &targ_name.name, &lifetime_rec, &mech_type.oid,
            &ctx_flags, &locally_initiated, &open)
        if GSS_ERROR(self.maj_stat):
            raise GSSError(self, self.maj_stat, self.min_stat)

        return (src_name, targ_name, lifetime_rec, mech_type, ctx_flags,
            locally_initiated, open)

    def wrap_size_limit(self,
            int conf_req_flag,
            gss_qop_t qop_req,
            OM_uint32 req_output_size
            ):
        '''
            wrap_size_limit(conf_req_flag, qop_req, req_output_size)

            returns max_input_size
        '''
        cdef OM_uint32 max_input_size
        self.maj_stat = gss_wrap_size_limit(&self.min_stat, self.ctx,
            conf_req_flag, qop_req, req_output_size, &max_input_size)
        if GSS_ERROR(self.maj_stat):
            raise GSSError(self, self.maj_stat, self.min_stat)

        return max_input_size

    def export_sec_context(self):
        '''
            export_sec_context()

            returns interprocess_token
        '''
        cdef OM_uint32 maj_stat, min_stat

        # call gss_export_sec_context
        cdef gss_buffer_desc _interprocess_token
        self.maj_stat = gss_export_sec_context(&self.min_stat, &self.ctx,
            &_interprocess_token)
        if GSS_ERROR(self.maj_stat):
            raise GSSError(self, self.maj_stat, self.min_stat)

        # cleanup arguments (_interprocess_token)
        interprocess_token = _gss_buffer_t_to_str(&_interprocess_token)
        maj_stat = gss_release_buffer(&min_stat, &_interprocess_token)
        if GSS_ERROR(maj_stat):
            self.maj_stat = maj_stat
            self.min_stat = min_stat
            raise GSSError(self, self.maj_stat, self.min_stat)

        return interprocess_token

    def get_mic(self,
            gss_qop_t qop_req,
            object message_buffer
            ):
        '''
            get_mic(qop_req, message_buffer)

            returns message_token
        '''
        cdef OM_uint32 maj_stat, min_stat

        # call gss_get_mic
        cdef gss_buffer_desc _message_buffer, _message_token
        _str_to_gss_buffer_t(message_buffer, &_message_buffer)
        self.maj_stat = gss_get_mic(&self.min_stat, self.ctx, qop_req,
            &_message_buffer, &_message_token)
        if GSS_ERROR(self.maj_stat):
            raise GSSError(self, self.maj_stat, self.min_stat)

        # cleanup arguments (_message_token)
        message_token = _gss_buffer_t_to_str(&_message_token)
        maj_stat = gss_release_buffer(&min_stat, &_message_token)
        if GSS_ERROR(maj_stat):
            self.maj_stat = maj_stat
            self.min_stat = min_stat
            raise GSSError(self, self.maj_stat, self.min_stat)

        return message_token

    def verify_mic(self,
            object message_buffer,
            object token_buffer
            ):
        '''
            verify_mic(message_buffer, token_buffer)

            returns qop_state
        '''
        cdef gss_qop_t qop_state
        cdef gss_buffer_desc _message_buffer, _token_buffer
        _str_to_gss_buffer_t(message_buffer, &_message_buffer)
        _str_to_gss_buffer_t(token_buffer, &_token_buffer)
        self.maj_stat = gss_verify_mic(&self.min_stat, self.ctx,
            &_message_buffer, &_token_buffer, &qop_state)
        if GSS_ERROR(self.maj_stat):
            raise GSSError(self, self.maj_stat, self.min_stat)

        return qop_state

    def wrap(self,
            int conf_req_flag,
            gss_qop_t qop_req,
            object input_message
            ):
        '''
            wrap(conf_req_flag, qop_req, input_message)

            returns (conf_state, output_message)
        '''
        cdef OM_uint32 maj_stat, min_stat

        # call gss_wrap
        cdef gss_buffer_desc _input_message, _output_message
        cdef int conf_state
        _str_to_gss_buffer_t(input_message, &_input_message)
        self.maj_stat = gss_wrap(&self.min_stat, self.ctx, conf_req_flag, qop_req,
            &_input_message, &conf_state, &_output_message)
        if GSS_ERROR(self.maj_stat):
            raise GSSError(self, self.maj_stat, self.min_stat)

        # cleanup arguments (_output_message)
        output_message = _gss_buffer_t_to_str(&_output_message)
        maj_stat = gss_release_buffer(&min_stat, &_output_message);
        if GSS_ERROR(maj_stat):
            self.maj_stat = maj_stat
            self.min_stat = min_stat
            raise GSSError(self, self.maj_stat, self.min_stat)

        return (conf_state, output_message)

    def unwrap(self,
            object input_message
            ):
        '''
            unwrap(input_message)

            returns (output_message, conf_state, qop_state)
        '''
        cdef OM_uint32 maj_stat, min_stat

        # call gss_unwrap
        cdef gss_buffer_desc _input_message, _output_message
        cdef int conf_state
        cdef gss_qop_t qop_state
        _str_to_gss_buffer_t(input_message, &_input_message)
        self.maj_stat = gss_unwrap(&self.min_stat, self.ctx, &_input_message,
            &_output_message, &conf_state, &qop_state)
        if GSS_ERROR(self.maj_stat):
            raise GSSError(self, self.maj_stat, self.min_stat)

        # cleanup arguments (_output_message)
        output_message = _gss_buffer_t_to_str(&_output_message)
        maj_stat = gss_release_buffer(&min_stat, &_output_message);
        if GSS_ERROR(maj_stat):
            self.maj_stat = maj_stat
            self.min_stat = min_stat
            raise GSSError(self, self.maj_stat, self.min_stat)

        return (output_message, conf_state, qop_state)

def init_sec_context(
        Cred claimant_cred,
        object targ_name,
        OID mech_type,
        int req_flags,
        int time_req,
        ChannelBindings chan_bindings
        ):
    '''
        init_sec_context(claimant_cred, targ_name, mech_type,
            req_flags, time_req, chan_bindings)

        returns (context, actual_mech_type, output_token, ret_flags, time_rec)
    '''

    cdef Context context
    context = Context()
    ret = list(_init_sec_context(context, claimant_cred, targ_name,
        mech_type, req_flags, time_req, chan_bindings, None))
    ret.insert(0, context)

    return tuple(ret)

def accept_sec_context(
        Cred acceptor_cred,
        object input_token,
        ChannelBindings chan_bindings
        ):
    '''
        accept_sec_context(acceptor_cred, input_token, chan_bindings)

        returns (context, src_name, mech_type, output_token,
            ret_flags, time_rec, delegated_cred)
    '''

    cdef Context context
    context = Context()
    ret = list(_accept_sec_context(context, acceptor_cred,
        input_token, chan_bindings))
    ret.insert(0, context)

    return tuple(ret)

def import_sec_context(
        object interprocess_token
        ):
    '''
        import_sec_context(interprocess_token)

        returns context
    '''
    cdef Context context
    context = Context()
    cdef gss_buffer_desc _interprocess_token
    _str_to_gss_buffer_t(interprocess_token, &_interprocess_token)
    context.maj_stat = gss_import_sec_context(&context.min_stat,
        &_interprocess_token, &context.ctx)
    if GSS_ERROR(context.maj_stat):
        raise GSSError(context, context.maj_stat, context.min_stat)

    return context
