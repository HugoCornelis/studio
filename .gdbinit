# set env NEUROSPACES_NMC_MODELS = /local_home/local_home/hugo/neurospaces_project/model-container/source/snapshots/0/library
# set env NEUROSPACES_NMC_PROJECT_MODELS = /local_home/local_home/hugo/EM/models
set args bin/neurospaces cells/purkinje/edsjb1994.ndf --gui
set args bin/neurospaces /tmp/traub91.ndf --gui

file /usr/bin/perl
# break parsererror
echo .gdbinit: Done .gdbinit\n

