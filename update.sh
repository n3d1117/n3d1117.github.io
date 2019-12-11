#!/bin/bash

rm Packages Packages.bz2
dpkg-scanpackages -m ./debs > Packages
bzip2 -fks Packages