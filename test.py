import sys, os, gssapi

try:
    print 'gssapi.import_name'
    target_name = gssapi.import_name("magic@acesulfame-potassium.csclub.uwaterloo.ca",
        gssapi.GSS_C_NT_HOSTBASED_SERVICE)
    print target_name
except gssapi.GSSError, e:
    print e
    sys.exit(1)
print ''

try:
    print 'gssapi.init_sec_context'
    client_ctx, actual_mech_type, output_token, ret_flags, time_rec = \
        gssapi.init_sec_context(None, target_name, None,
        gssapi.GSS_C_MUTUAL_FLAG | gssapi.GSS_C_REPLAY_FLAG |
        gssapi.GSS_C_CONF_FLAG | gssapi.GSS_C_INTEG_FLAG, 0, None)
    print 'actual_mech_type: %s' % actual_mech_type
    print 'output_token: %s' % output_token
    print 'ret_flags: %d' % ret_flags
    print 'time_rec: %d' % time_rec
    print 'maj_stat: %d' % client_ctx.maj_stat
except gssapi.GSSError, e:
    print e
    sys.exit(1)
print ''
client_done = (client_ctx.maj_stat == gssapi.GSS_S_COMPLETE)

try:
    os.putenv("KRB5_KTNAME", "test.keytab")
    print 'acquire_cred'
    output_cred, actual_mechs, time_rec = gssapi.acquire_cred(target_name,
        0, None, gssapi.GSS_C_ACCEPT)
    print 'output_cred: %s' % output_cred
    print 'actual_mechs: %s' % actual_mechs
    print 'time_rec: %d' % time_rec
    print 'maj_stat: %d' % output_cred.maj_stat
except gssapi.GSSError, e:
    print e
print ''

try:
    print 'gssapi.accept_sec_context'
    server_ctx, src_name, mech_type, output_token, ret_flags, time_rec, \
        delegated_cred = gssapi.accept_sec_context(output_cred, output_token, None)
    print 'mech_type: %s' % mech_type
    print 'output_token: %s' % output_token
    print 'ret_flags: %d' % ret_flags
    print 'time_rec: %d' % time_rec
    print 'delegated_cred: %s' % delegated_cred
    print 'maj_stat: %d' % server_ctx.maj_stat
except gssapi.GSSError, e:
    print e
    sys.exit(1)
print ''

try:
    print 'delegated_cred.inquire_cred'
    name, lifetime, cred_usage, mechanisms = delegated_cred.inquire_cred()
    print 'name: %s' % name
    print 'lifetime: %d' % lifetime
    print 'cred_usage: %d' % cred_usage
    print 'mechanisms: %s' % mechanisms
except gssapi.GSSError, e:
    print e
    sys.exit(1)
print ''

try:
    print 'delegated_cred.inquire_cred_by_mech'
    name, initiator_lifetime, acceptor_lifetime, cred_usage = \
        delegated_cred.inquire_cred_by_mech(gssapi.OID())
    print 'name: %s' % name
    print 'initiator_lifetime: %d' % initiator_lifetime
    print 'acceptor_lifetime: %d' % acceptor_lifetime
    print 'cred_usage: %d' % cred_usage
except gssapi.GSSError, e:
    print e
    sys.exit(1)
print ''

server_done = (client_ctx.maj_stat == gssapi.GSS_S_COMPLETE)
while (not client_done) or (not server_done):
    try:
        print 'client_ctx.init_sec_context'
        actual_mech_type, output_token, ret_flags, time_rec = \
            client_ctx.init_sec_context(None, target_name, None,
            gssapi.GSS_C_MUTUAL_FLAG | gssapi.GSS_C_REPLAY_FLAG |
            gssapi.GSS_C_CONF_FLAG | gssapi.GSS_C_INTEG_FLAG, 0, None,
            output_token)
        print 'actual_mech_type: %s' % actual_mech_type
        print 'output_token: %s' % output_token
        print 'ret_flags: %d' % ret_flags
        print 'time_rec: %d' % time_rec
        print 'maj_stat: %d' % client_ctx.maj_stat
    except gssapi.GSSError, e:
        print e
        sys.exit(1)
    print ''

    if len(output_token):
        try:
            print 'server_ctx.accept_sec_context'
            src_name, mech_type, output_token, ret_flags, time_rec, \
                delegated_cred = gssapi.accept_sec_context(output_cred,
                output_token, None, output_token)
            print 'mech_type: %s' % mech_type
            print 'output_token: %s' % output_token
            print 'ret_flags: %d' % ret_flags
            print 'time_rec: %d' % time_rec
            print 'delegated_cred: %s' % delegated_cred
            print 'maj_stat: %d' % server_ctx.maj_stat
        except gssapi.GSSError, e:
            print e
            sys.exit(1)
        print ''

    client_done = (client_ctx.maj_stat == gssapi.GSS_S_COMPLETE)
    server_done = (server_ctx.maj_stat == gssapi.GSS_S_COMPLETE)

try:
    print 'client_ctx.context_time'
    time_rec = client_ctx.context_time()
    print 'time_rec: %d' % time_rec
    print 'maj_stat: %d' % client_ctx.maj_stat
except gssapi.GSSError, e:
    print e
    sys.exit(1)
print ''

try:
    print 'client_ctx.inquire_context'
    src_name, targ_name, lifetime_rec, mech_type, ctx_flags, \
        locally_initiated, open = client_ctx.inquire_context()
    print 'src_name: %s' % src_name
    print 'targ_name: %s' % targ_name
    print 'lifetime_rec: %d' % lifetime_rec
    print 'mech_type: %s' % mech_type
    print 'ctx_flags: %d' % ctx_flags
    print 'locally_initiated: %d' % locally_initiated
    print 'open: %d' % open
    print 'maj_stat: %d' % client_ctx.maj_stat
except gssapi.GSSError, e:
    print e
    sys.exit(1)
print ''

try:
    print 'server_ctx.export_sec_context'
    interprocess_token = server_ctx.export_sec_context()
    print 'interprocess_token: %s' % interprocess_token
except gssapi.GSSError, e:
    print e
    sys.exit(1)
print ''

try:
    print 'gssapi.import_sec_context'
    server_ctx = gssapi.import_sec_context(interprocess_token)
    print 'server_ctx: %s' % server_ctx
except gssapi.GSSError, e:
    print e
    sys.exit(1)

try:
    print 'server_ctx.wrap_size_limit'
    max_input_size = server_ctx.wrap_size_limit(1,
        gssapi.GSS_C_QOP_DEFAULT, 1000)
    print 'max_input_size: %d' % max_input_size
except gssapi.GSSError, e:
    print e
    sys.exit(1)
print ''

try:
    print 'server_ctx.context_time'
    time_rec = server_ctx.context_time()
    print 'time_rec: %d' % time_rec
    print 'maj_stat: %d' % server_ctx.maj_stat
except gssapi.GSSError, e:
    print e
    sys.exit(1)
print ''

try:
    print 'server_ctx.inquire_context'
    src_name, targ_name, lifetime_rec, mech_type, ctx_flags, \
        locally_initiated, open = server_ctx.inquire_context()
    print 'src_name: %s' % src_name
    print 'targ_name: %s' % targ_name
    print 'lifetime_rec: %d' % lifetime_rec
    print 'mech_type: %s' % mech_type
    print 'ctx_flags: %d' % ctx_flags
    print 'locally_initiated: %d' % locally_initiated
    print 'open: %d' % open
    print 'maj_stat: %d' % server_ctx.maj_stat
except gssapi.GSSError, e:
    print e
    sys.exit(1)
print ''

message_buffer = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

try:
    print 'client_ctx.get_mic'
    message_token = client_ctx.get_mic(0, message_buffer)
    print 'message_token: %s' % message_token
except gssapi.GSSError, e:
    print e
    sys.exit(1)
print ''

try:
    print 'server_ctx.verify_mic'
    qop_state = server_ctx.verify_mic(message_buffer, message_token)
    print 'qop_state: %d' % qop_state
except gssapi.GSSError, e:
    print e
    sys.exit(1)
print ''

try:
    print 'server_ctx.verify_mic [tampering['
    qop_state = server_ctx.verify_mic(message_buffer + "bad", message_token)
    sys.exit(1)
except gssapi.GSSError, e:
    print e
print ''

input_message = "abcdefghijklmnopqrstuvwxyz"

try:
    print 'server_ctx.wrap'
    conf_state, output_message = server_ctx.wrap(1,
        gssapi.GSS_C_QOP_DEFAULT, input_message)
    print 'conf_state: %d' % conf_state
    print 'output_message: %s' % output_message
except gssapi.GSSError, e:
    print e
    sys.exit(1)
print ''

try:
    print 'client_ctx.un_wrap'
    output_message, conf_state, qop_state = client_ctx.unwrap(output_message)
    print 'output_message: %s' % output_message
    print 'conf_state: %d' % conf_state
    print 'qop_state: %d' % qop_state
except gssapi.GSSError, e:
    print e
    sys.exit(1)
print ''

try:
    print 'client_ctx.un_wrap [tampering]'
    output_message, conf_state, qop_state = client_ctx.unwrap(
        output_message + 'junk')
    sys.exit(1)
except gssapi.GSSError, e:
    print e
print ''
