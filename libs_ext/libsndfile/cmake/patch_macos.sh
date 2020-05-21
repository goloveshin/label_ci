#!/bin/bash

gsed -i "s@\$(CFLAGS) -MT@\$(CFLAGS) \$(AM_CPPFLAGS) -MT@g" src/Makefile
