cmake_minimum_required(VERSION 3.4)

# Project name and version
project(eosio-keygen-extras
	VERSION 0.1.0
	DESCRIPTION "extra files for eosio-keygen"
)

# --------------------------------
#  Install target
# --------------------------------
install(
	DIRECTORY dict
	DESTINATION ${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME}
	COMPONENT ${PROJECT_NAME}
)

# --------------------------------
#  Package
# --------------------------------

set(PACKAGE_${PROJECT_NAME}_ARCHITECTURE "any")
package()
