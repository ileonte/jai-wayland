#!/bin/sh

gcc wayland-util.c scanner.c -lxml2 -lexpat -o wayland-scanner
