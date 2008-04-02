all: gssapi.so

PYTHON=python2.4
LDFLAGS=$(shell krb5-config --libs gssapi)
CFLAGS=-I/usr/include/$(PYTHON) -fPIC
CC=gcc
PYX_FILES=gssapi.pyx gssapi.pxi gssapi_help.pyx gssapi_name.pyx \
	gssapi_excpt.pyx gssapi_cb.pyx gssapi_oid.pyx gssapi_cred.pyx \
	gssapi_misc.pyx gssapi_ctx.pyx

gssapi.c: $(PYX_FILES)
	pyrexc gssapi.pyx || (rm gssapi.c; exit 1)

gssapi.so: gssapi.o
	$(CC) -shared gssapi.o $(CFLAGS) $(LDFLAGS) -o gssapi.so

clean:
	rm -f gssapi.c gssapi.so gssapi.o

test: gssapi.so
	$(PYTHON) test.py

help: gssapi.so
	$(PYTHON) -c 'import gssapi; help(gssapi)'

.PHONEY: gssapi.pyx
