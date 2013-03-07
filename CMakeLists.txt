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