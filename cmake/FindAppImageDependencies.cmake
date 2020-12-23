include(FindPackageHandleStandardArgs)

set(DLL_SEARCH_PATHS
    /usr/lib
    /usr/lib/x86_64-linux-gnu
)

find_path(GST_DLL_DIR
    NAMES libgstcoreelements.so{.*}
    PATHS
        ${DLL_SEARCH_PATHS}
    PATH_SUFFIXES
        gstreamer-1.0
)

find_path(GRAPHVIZ_DLL_DIR
    NAMES libgvplugin_core.so{.*}
    PATHS
        ${DLL_SEARCH_PATHS}
    PATH_SUFFIXES
        graphviz
)

find_package_handle_standard_args(AppImageDependencies DEFAULT_MSG GST_DLL_DIR GRAPHVIZ_DLL_DIR)

mark_as_advanced(GST_DLL_DIR GRAPHVIZ_DLL_DIR)
