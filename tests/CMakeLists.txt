cmake_minimum_required (VERSION 3.12)
project(lapack95demo C Fortran)
enable_testing()

cmake_policy(SET CMP0074 NEW)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/Modules/)

if(DEFINED ENV{MKLROOT} OR CMAKE_Fortran_COMPILER_ID STREQUAL Intel)
  set(USEMKL 1)
else()
  set(USEMKL 0)
endif()

if(UNIX AND CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "~/.local" CACHE PATH "..." FORCE)
endif()

if(NOT CMAKE_Fortran_COMPILER_ID STREQUAL Intel)
  set(LAPACK95_ROOT ${CMAKE_INSTALL_PREFIX})
endif()

find_package(LAPACK95)

if(NOT LAPACK95_FOUND)
  # try a local non-installed build
  set(LAPACK95_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/../LAPACK95)
  find_package(LAPACK95 REQUIRED)
endif()

add_executable(lp95 DemoLapack95.F90 assert.f90)
target_link_libraries(lp95 PRIVATE ${LAPACK95_LIBRARIES})
target_include_directories(lp95 PRIVATE ${LAPACK95_INCLUDE_DIRS})
target_compile_definitions(lp95 PRIVATE USEMKL=${USEMKL})
add_test(NAME Lapack95 COMMAND lp95)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../LAPACK95/EXAMPLES1/ ${CMAKE_CURRENT_BINARY_DIR}/ex1)


