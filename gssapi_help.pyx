cdef extern from "Python.h":
    char *PyString_AsString(
        object string
    )
    object Py_BuildValue(
        char *format,
        ...
    )

# this function should never cause an exception
# if it does, it's almost certainly very serious and fatal
cdef object _gss_buffer_t_to_str(
        gss_buffer_t buffer
    ):

    return PyString_FromStringAndSize(<char*>buffer.value, buffer.length)

# buffer will be valid until obj is free'd
# this function will raise an exception if obj is not a string
cdef int _str_to_gss_buffer_t(
        object obj,
        gss_buffer_t buffer
    ) except -1:

    buffer.value = PyString_AsString(obj)
    if buffer.value == NULL:
        return -1
    else:
        buffer.length = len(obj)
        return 0
