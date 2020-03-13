
# Write deb file
function(_deb_write_control CONTROL)

	set(fields
		Package
		Version
		Architecture
		Description
		Maintainer
		Homepage
		Priority
		Section
		Depends
	)

	# Write control file
	file(WRITE ${CONTROL} "")
	foreach(item IN LISTS fields)
		string(TOUPPER "${item}" key )

		if (PACKAGE_${PROJECT_NAME}_DEB_${key})
			file(APPEND ${CONTROL} "${item}: ${PACKAGE_${PROJECT_NAME}_DEB_${key}}\n")
		endif()

	endforeach()

endfunction()


_set_default( PACKAGE_${PROJECT_NAME}_DEB_PACKAGE ${PACKAGE_${PROJECT_NAME}_NAME} )
_set_default( PACKAGE_${PROJECT_NAME}_DEB_ARCHITECTURE ${PACKAGE_DEB_ARCHITECTURE} )
_set_default( PACKAGE_${PROJECT_NAME}_DEB_DESCRIPTION ${PACKAGE_${PROJECT_NAME}_DESCRIPTION} )
_set_default( PACKAGE_${PROJECT_NAME}_DEB_MAINTAINER ${PACKAGE_${PROJECT_NAME}_MAINTAINER} )
_set_default( PACKAGE_${PROJECT_NAME}_DEB_HOMEPAGE ${PACKAGE_${PROJECT_NAME}_HOMEPAGE_URL} )
_set_default( PACKAGE_${PROJECT_NAME}_DEB_PRIORITY "optional" )
set( PACKAGE_${PROJECT_NAME}_DEB_RELEASE 1 CACHE STRING "Debian package release number")
_set_default( PACKAGE_${PROJECT_NAME}_DEB_VERSION ${PACKAGE_${PROJECT_NAME}_VERSION}-${PACKAGE_${PROJECT_NAME}_DEB_RELEASE} )
_set_default( PACKAGE_${PROJECT_NAME}_DEB_FILENAME ${PROJECT_NAME}_${PACKAGE_${PROJECT_NAME}_DEB_VERSION}-${PACKAGE_SYSTEM_NAME}-${PACKAGE_SYSTEM_VERSION}_${PACKAGE_${PROJECT_NAME}_DEB_ARCHITECTURE}.deb )
_set_default( PACKAGE_${PROJECT_NAME}_DEB_ROOT "${PACKAGE_OUTPUT_DIR}/pack/deb/${PROJECT_NAME}/debroot" )

# Write control file
_deb_write_control( ${PACKAGE_${PROJECT_NAME}_DEB_ROOT}/DEBIAN/control )

set(_PACKAGE_TARGET package_${PROJECT_NAME}_deb)

# Add target
add_custom_target(${_PACKAGE_TARGET}
	COMMENT "Creating deb package: ${PACKAGE_${PROJECT_NAME}_DEB_FILENAME}"
	COMMAND ${CMAKE_COMMAND} --install . --component ${PROJECT_NAME} --prefix "${PACKAGE_${PROJECT_NAME}_DEB_ROOT}${CMAKE_INSTALL_PREFIX}"
	COMMAND fakeroot dpkg-deb --build ${PACKAGE_${PROJECT_NAME}_DEB_ROOT} ${PACKAGE_${PROJECT_NAME}_DEB_FILENAME} > /dev/null
	WORKING_DIRECTORY ${PACKAGE_OUTPUT_DIR}
)
