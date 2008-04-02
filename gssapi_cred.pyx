cdef class Cred:
    cdef gss_cred_id_t cred

    cdef readonly OM_uint32 maj_stat, min_stat

    def __init__(self):
        self.cred = GSS_C_NO_CREDENTIAL
        self.maj_stat = GSS_S_COMPLETE
        self.min_stat = 0

    def __dealloc__(self):
        cdef OM_uint32 maj_stat, min_stat
        if self.cred != GSS_C_NO_CREDENTIAL:
            maj_stat = gss_release_cred(&min_stat, &self.cred)
            if GSS_ERROR(maj_stat):
                raise GSSError(None, maj_stat, min_stat)

    def add_cred(self,
            Name desired_name not None,
            OID desired_mech not None,
            gss_cred_usage_t cred_usage,
            OM_uint32 initiator_time_req,
            OM_uint32 acceptor_time_req
            ):
        '''
            add_cred(desired_name, desired_mech, cred_usage,
                initiator_time_req, acceptor_time_req)

            returns (actual_mechs, initiator_time_rec, acceptor_time_rec)
        '''
        cdef OM_uint32 maj_stat, min_stat

        # init arguments
        if desired_mech.oid == GSS_C_NO_OID:
            raise TypeError("desired_mech cannot be GSS_C_NO_OID")
        cdef OIDSet actual_mechs
        actual_mechs = OIDSet()
        cdef OM_uint32 initiator_time_rec, acceptor_time_rec
        cdef gss_cred_id_t *output_cred
        if self.cred == GSS_C_NO_CREDENTIAL:
            output_cred = &self.cred
        else:
            output_cred = NULL

        # call gss_add_cred
        self.maj_stat = gss_add_cred(&self.min_stat, self.cred,
            desired_name.name, desired_mech.oid, cred_usage,
            initiator_time_req, acceptor_time_req, output_cred,
            &actual_mechs.oid_set, &initiator_time_rec, &acceptor_time_rec)
        if GSS_ERROR(self.maj_stat):
            raise GSSError(self, self.maj_stat, self.min_stat)

        return (actual_mechs, initiator_time_rec, acceptor_time_rec)

    def inquire_cred(self):
        '''
            inquire_cred()

            returns (name, lifetime, cred_usage, mechanisms)
        '''
        cdef OM_uint32 maj_stat, min_stat, _min_stat
        cdef Name name
        name = Name()
        cdef OM_uint32 lifetime
        cdef gss_cred_usage_t cred_usage
        cdef OIDSet mechanisms
        mechanisms = OIDSet()

        # call gss_inquire_cred
        self.maj_stat = gss_inquire_cred(&self.min_stat, self.cred,
            &name.name, &lifetime, &cred_usage, &mechanisms.oid_set)
        if GSS_ERROR(self.maj_stat):
            raise GSSError(self, self.maj_stat, self.min_stat)

        return (name, lifetime, cred_usage, mechanisms)

    def inquire_cred_by_mech(self,
            OID mech_type not None
            ):
        '''
            inquire_cred_by_mech(mech_type)

            returns (name, initiator_lifetime, acceptor_lifetime, cred_usage)
        '''
        cdef OM_uint32 maj_stat, min_stat, _min_stat
        cdef Name name
        name = Name()
        cdef OM_uint32 initiator_lifetime, acceptor_lifetime
        cdef gss_cred_usage_t cred_usage

        # call gss_inquire_cred_by_mech
        self.maj_stat = gss_inquire_cred_by_mech(&self.min_stat, self.cred,
            mech_type.oid, &name.name, &initiator_lifetime,
            &acceptor_lifetime, &cred_usage)
        if GSS_ERROR(self.maj_stat):
            raise GSSError(self, self.maj_stat, self.min_stat)

        return (name, initiator_lifetime, acceptor_lifetime, cred_usage)

def acquire_cred(
        Name desired_name not None,
        OM_uint32 time_req,
        OIDSet desired_mechs,
        gss_cred_usage_t cred_usage
        ):
    '''
        acquire_cred(desired_name, time_req, desired_mechs, cred_usage)

        returns (output_cred, actual_mechs, time_rec)
    '''
    cdef OM_uint32 maj_stat, min_stat
    if desired_mechs == None: desired_mechs = OIDSet()

    # call gss_acquire_cred
    cdef Cred output_cred
    output_cred = Cred()
    cdef OIDSet actual_mechs
    actual_mechs = OIDSet()
    cdef OM_uint32 time_rec
    output_cred.maj_stat = gss_acquire_cred(&output_cred.min_stat,
        desired_name.name, time_req, desired_mechs.oid_set, cred_usage,
        &output_cred.cred, &actual_mechs.oid_set, &time_rec)
    if GSS_ERROR(output_cred.maj_stat):
        raise GSSError(output_cred, output_cred.maj_stat, output_cred.min_stat)

    return (output_cred, actual_mechs, time_rec)
