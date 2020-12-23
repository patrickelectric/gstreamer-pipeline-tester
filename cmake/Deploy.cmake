if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
	set(TOOLS_FOLDER ${CMAKE_SOURCE_DIR}/tools)

	function(download_tool tool url)
		set(file_path "${TOOLS_FOLDER}/${tool}")
		if(NOT EXISTS "${file_path}")
			message("Downloading and configuration tool: ${tool}")
			file(
				DOWNLOAD ${url} ${file_path}
				SHOW_PROGRESS
			)
			file(
				CHMOD ${file_path}
				PERMISSIONS WORLD_EXECUTE OWNER_EXECUTE OWNER_WRITE OWNER_READ
			)
		else()
			message("Tool already exist: ${tool}")
		endif()
	endfunction()

	download_tool(linuxdeploy-x86_64.AppImage https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage)
	download_tool(linuxdeploy-plugin-qt-x86_64.AppImage https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage)
	download_tool(linuxdeploy-plugin-gstreamer.sh https://raw.githubusercontent.com/patrickelectric/linuxdeploy-plugin-gstreamer/fix_no_exist/linuxdeploy-plugin-gstreamer.sh)
	find_program(LINUXDEPLOY_EXECUTABLE ${TOOLS_FOLDER}/linuxdeploy-x86_64.AppImage)
	find_program(LINUXDEPLOY_PLUGIN_QT_EXECUTABLE ${TOOLS_FOLDER}/linuxdeploy-plugin-qt-x86_64.AppImage)
	find_program(LINUXDEPLOY_PLUGIN_GSTREAMER_EXECUTABLE ${TOOLS_FOLDER}/linuxdeploy-plugin-gstreamer.sh)

	file(WRITE ${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}.desktop
		"[Desktop Entry]\n"
		"Type=Application\n"
		"Name=${CMAKE_PROJECT_NAME}\n"
		"GenericName=${CMAKE_PROJECT_NAME}\n"
		"Comment=${CMAKE_PROJECT_NAME}\n"
		"Icon=${CMAKE_PROJECT_NAME}\n"
		"Exec=${CMAKE_PROJECT_NAME}\n"
		"Terminal=false\n"
		"Categories=Utility;\n"
		"Keywords=computer;\n"
	)

	add_custom_target(deploy DEPENDS ${CMAKE_PROJECT_NAME})
	add_custom_command(
		TARGET deploy
		COMMAND ${CMAKE_COMMAND} -E echo "Running linux deployment"
		COMMAND ${CMAKE_COMMAND} -E make_directory deploy
		# The first step creates populates de ploy folder with the necessary Qt dependencies
		 COMMAND ${CMAKE_COMMAND} -E env GSTREAMER_PLUGINS_DIR=/usr/lib/gstreamer-1.0
			${LINUXDEPLOY_EXECUTABLE}
				--desktop-file=${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}.desktop
				--appdir=${CMAKE_BINARY_DIR}/deploy
				--executable=${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}
				--icon-file=${CMAKE_SOURCE_DIR}/qml/images/${CMAKE_PROJECT_NAME}.png
				--plugin gstreamer
		COMMAND ${CMAKE_COMMAND} -E env QML_SOURCES_PATHS=${CMAKE_SOURCE_DIR}/qml
			${LINUXDEPLOY_PLUGIN_QT_EXECUTABLE}
				--appdir=${CMAKE_BINARY_DIR}/deploy
				--extra-plugin=multimedia
		COMMAND ${CMAKE_COMMAND} -E copy_directory /usr/lib/graphviz ${CMAKE_BINARY_DIR}/deploy/usr/lib/graphviz
		COMMAND ${CMAKE_COMMAND} -E rm -Rf ${CMAKE_BINARY_DIR}/deploy/usr/lib/graphviz/{lua,ocaml,perl,python3,R,sharp,tcl}
		COMMAND ${LINUXDEPLOY_EXECUTABLE}
			--appdir=${CMAKE_BINARY_DIR}/deploy
			--output appimage
	)
endif()