set(SRCS
    main.cpp
    helper.cpp
)

qt5_add_resources(RESOURCES ../resources.qrc)

find_package(GraphViz REQUIRED)
include_directories(
    ${GRAPHVIZ_INCLUDE_DIR}
)

add_executable(${CMAKE_PROJECT_NAME} ${SRCS} ${RESOURCES})
target_link_libraries(
    ${CMAKE_PROJECT_NAME}
    Qt5::Core
    Qt5::Qml
    Qt5::Svg
    Qt5::Widgets
    cgraph
    gvc
)
