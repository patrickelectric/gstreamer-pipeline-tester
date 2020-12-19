include(FindPackageHandleStandardArgs)

message(potato)

set(GRAPHVIZ_SEARCH_PATHS
  /usr
  /usr/local
  /opt/local
)

find_path(GRAPHVIZ_INCLUDE_DIR
    NAMES graphviz/gvc.h
    PATHS
      ${GRAPHVIZ_SEARCH_PATHS}
    PATH_SUFFIXES
      include
)

find_package_handle_standard_args(GraphViz DEFAULT_MSG GRAPHVIZ_INCLUDE_DIR)

mark_as_advanced(GRAPHVIZ_INCLUDE_DIR)
