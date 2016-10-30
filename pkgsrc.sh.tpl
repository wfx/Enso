pkg_url=""        # full archive or git resource url (url/name.extension)
pkg_ext=""        # archive compressing type (extension) or git
pkg_rel=""        # optional git release (branch) for enso_pkg_ext[n]=git
src_build=""      # build for c, python(3) code or "" to use build.sh
src_prefix=""     # optional install prefix (/usr/local)
src_cflags=""     # optional cflags
src_cxxflags=""   # optional cxxflags
src_configure=""  # optional configure options (you dont need to add a prefix is src_prefix set)
