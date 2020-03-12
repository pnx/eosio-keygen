
# --------------------------------
#  Functions
# --------------------------------

function(_set_default VAR_NAME DEFAULT_VALUE)

	if(NOT ${VAR_NAME})
		set( ${VAR_NAME} ${DEFAULT_VALUE} PARENT_SCOPE)
	endif()
endfunction()

function(_set_fallback VAR_NAME)

	set(var_list ${ARGN})

	if(NOT ${VAR_NAME})
		foreach (var IN LISTS var_list)
			if (${var})
				set( ${VAR_NAME} ${${var}} PARENT_SCOPE)
				break()
			endif()
		endforeach()
	endif()
endfunction()

function(add_package TARGET)

	set(DEPENDANCIES ${ARGN})

	add_dependencies(package ${TARGET})
	if (DEPENDANCIES)
		add_dependencies(${TARGET} ${DEPENDANCIES})
	endif(DEPENDANCIES)
endfunction()

# --------------------------------
#  Environment variables
# --------------------------------

# Define PACKAGE_ARCHITECTURE
set( PACKAGE_ARCHITECTURE "x86" )
if (CMAKE_SIZEOF_VOID_P EQUAL 8)
	set( PACKAGE_ARCHITECTURE "${PACKAGE_ARCHITECTURE}_64" )
endif()

# Define PACKAGE_SYSTEM_NAME and PACKAGE_SYSTEM_VERSION
if (UNIX)

	# Try ubuntu.
	execute_process(
		COMMAND lsb_release -is
		OUTPUT_VARIABLE PACKAGE_SYSTEM_NAME
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)
	string(TOLOWER "${PACKAGE_SYSTEM_NAME}" PACKAGE_SYSTEM_NAME )

	if (PACKAGE_SYSTEM_NAME STREQUAL "ubuntu")

		execute_process(
			COMMAND lsb_release -rs
			OUTPUT_VARIABLE PACKAGE_SYSTEM_VERSION
			OUTPUT_STRIP_TRAILING_WHITESPACE
		)

		# Debian uses different names for 32 and 64 bit.
		if (PACKAGE_ARCHITECTURE EQUAL "x86")
			set( PACKAGE_DEB_ARCHITECTURE "i386" )
		else()
			set( PACKAGE_DEB_ARCHITECTURE "amd64" )
		endif()
	endif()
elseif (WIN32)
	set(PACKAGE_SYSTEM_NAME "windows")
endif()

# --------------------------------
#  Options
# --------------------------------

option(PKG_TYPE "Type of package to build (zip, deb)" "zip")

# --------------------------------
#  Package definition
# --------------------------------

set( PACKAGE_OUTPUT_DIR ${CMAKE_BINARY_DIR} )

get_filename_component(_PACKAGE_TEMPLATE_DIR ${CMAKE_CURRENT_LIST_FILE} DIRECTORY)

# Add dummy target for all packages.
add_custom_target( package )

# Define a package.
function(package)

	set( DEPENDANCIES ${ARGN} )

	# --------------------------------
	#  Info
	# --------------------------------
	set( PACKAGE_${PROJECT_NAME}_NAME ${PROJECT_NAME} )
	_set_fallback( PACKAGE_${PROJECT_NAME}_DESCRIPTION PROJECT_DESCRIPTION CMAKE_PROJECT_DESCRIPTION )
	_set_fallback( PACKAGE_${PROJECT_NAME}_VERSION PROJECT_VERSION CMAKE_PROJECT_VERSION )
	_set_fallback( PACKAGE_${PROJECT_NAME}_HOMEPAGE_URL PROJECT_HOMEPAGE_URL CMAKE_PROJECT_HOMEPAGE_URL )
	set( PACKAGE_${PROJECT_NAME}_MAINTAINER ${PROJECT_MAINTAINER})
	_set_default( PACKAGE_${PROJECT_NAME}_ARCHITECTURE ${PACKAGE_ARCHITECTURE} )

	_set_default( PACKAGE_${PROJECT_NAME}_FILENAME ${PACKAGE_${PROJECT_NAME}_NAME}_${PACKAGE_${PROJECT_NAME}_VERSION}-${PACKAGE_SYSTEM_NAME}-${PACKAGE_SYSTEM_VERSION}_${PACKAGE_${PROJECT_NAME}_ARCHITECTURE})


	# --------------------------------
	#  Debian
	# --------------------------------
	if (PKG_TYPE STREQUAL "deb")

		if (NOT UNIX)
			message(FATAL_ERROR "Can't build deb packages on this system")
		endif()

		include(${_PACKAGE_TEMPLATE_DIR}/package_deb.cmake)
		add_package(${_PACKAGE_TARGET} ${DEPENDANCIES})
	endif()

	# --------------------------------
	#  ZIP
	# --------------------------------
	if (PKG_TYPE STREQUAL "zip")
		include(${_PACKAGE_TEMPLATE_DIR}/package_zip.cmake)
		add_package(${_PACKAGE_TARGET} ${DEPENDANCIES})
	endif()

endfunction()
