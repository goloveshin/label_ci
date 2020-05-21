#!/bin/bash

sed -i "s@\$(CFLAGS) -MT@\$(CFLAGS) \$(AM_CPPFLAGS) -MT@g" src/Makefile
