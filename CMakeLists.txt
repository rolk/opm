# -*- mode: cmake; tab-width: 2; indent-tabs-mode: t; truncate-lines: t; compile-command: "cmake -Wdev" -*-
# vim: set filetype=cmake autoindent tabstop=2 shiftwidth=2 noexpandtab softtabstop=2 nowrap:

# Copyright (C) 2013 Uni Research AS
# This file is licensed under the GNU General Public License v3.0

cmake_minimum_required(VERSION 2.8)
project (opm NONE)
include (ExternalProject)

# read the list of sub-directories from the external file
list (APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR})
include (CMakeLists_files)

# create variables that holds the directory information for each
# sub-project
foreach (proj IN LISTS PROJECTS)
  set (${proj}_SOURCE_DIR ${PROJECT_SOURCE_DIR}/${proj})
  set (${proj}_DIR ${PROJECT_BINARY_DIR}/${proj})
endforeach (proj)

# setup list of dependencies
foreach (proj IN LISTS PROJECTS)
  # get the dependencies from dune.module
  file (STRINGS ${${proj}_SOURCE_DIR}/dune.module ${proj}_ALL_DEPS
	REGEX "[\ \t]*Depends:[\ \t]*"
	)
  # filter out trailer and version information
  string (REGEX REPLACE "[\ \t]*Depends:[\ \t]*" "" ${proj}_ALL_DEPS "${${proj}_ALL_DEPS}")
  string (REGEX REPLACE "\\(.*\\)" "" ${proj}_ALL_DEPS "${${proj}_ALL_DEPS}")
  # convert whitespace separated string to CMake list
  separate_arguments (${proj}_ALL_DEPS UNIX_COMMAND "${${proj}_ALL_DEPS}")
  # external dependencies are those which aren't amongst our projects
  set (${proj}_EXT_DEPS "${${proj}_ALL_DEPS}")
  list (REMOVE_ITEM ${proj}_EXT_DEPS ${PROJECTS})
  # internal dependencies are the rest
  set (${proj}_DEPS "${${proj}_ALL_DEPS}")
  if (${proj}_EXT_DEPS)
	list (REMOVE_ITEM ${proj}_DEPS ${${proj}_EXT_DEPS})
  endif (${proj}_EXT_DEPS)
endforeach (proj)

# get the variable that were specified on a command-line to us
# they are stored in the cache and recreated on the next
# invocation, even if they are not specified then!
get_cmake_property(cache CACHE_VARIABLES)

# variables that are local to this parent project and that should
# not be propagated. also remove variables that are never used
# in any sub-project
set (local_vars
  CMAKE_PROJECT_NAME
  CMAKE_HOME_DIRECTORY
  ${PROJECT_NAME}_SOURCE_DIR
  ${PROJECT_NAME}_BINARY_DIR
  CMAKE_CPACK_COMMAND
  )
list (REMOVE_ITEM cache ${local_vars})

# recreate a command-line to set this cache in sub-projects;
# the alternative would be to specify a script that loaded our
# cache as the pre-load script for each project, but that would
# only work if we are building from scratch. specifying them
# manually enables us to reconfigure later.
set (vars)
foreach (var IN LISTS cache)
  list (APPEND vars "-D${var}=${${var}}")
endforeach (var)

# setup external projects with sub-dir. as name
foreach (proj IN LISTS PROJECTS)
  # all projects need the "global" options
  set (${proj}_ARGS ${vars})

  # add directory information on the command-line too, so that the
  # sub-projects can use config-mode to get eachother instead of probing
  foreach (dep IN LISTS ${proj}_DEPS)
	list (APPEND ${proj}_ARGS "-D${dep}_DIR=${${dep}_DIR}")
  endforeach (dep)

  # use blank install command so they don't get installed automatically
  # don't specify dependencies yet, since all projects haven't been
  # defined necessarily
  externalproject_add (${proj}
	PREFIX ${proj}
	SOURCE_DIR ${${proj}_SOURCE_DIR}
	BINARY_DIR ${${proj}_DIR}
	STAMP_DIR ${${proj}_DIR}
	TMP_DIR ${${proj}_DIR}
	CMAKE_ARGS ${${proj}_ARGS}
	INSTALL_COMMAND ""
#	DEPENDS ${${proj}_DEPS}
	)
endforeach (proj)

# add dependencies later when we have all the projects
foreach (proj IN LISTS PROJECTS)
  if (${proj}_DEPS)
	add_dependencies (${proj} ${${proj}_DEPS})
  endif (${proj}_DEPS)
endforeach (proj)
