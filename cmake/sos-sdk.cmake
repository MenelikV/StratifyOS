
if( ${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Windows" )
	set(CMAKE_MAKE_PROGRAM "C:/StratifyLabs-SDK/Tools/gcc/bin/make.exe" CACHE INTERNAL "Mingw generator" FORCE)
	set(CMAKE_SOS_SDK_GENERATOR "MinGW Makefiles" CACHE INTERNAL "Mingw generator" FORCE)
endif()

if( ${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Darwin" )
	set(SOS_SDK_EXEC_SUFFIX "")
	set(SOS_SDK_GENERATOR "")
	set(SOS_SDK_PATH_TO_QMAKE /Users/tgil/Qt/5.9.3/clang_64/bin)
	set(SOS_SDK_QMAKE_ARGS -spec macx-clang CONFIG+=x86_64 CONFIG+=qtquickcompiler)
elseif( ${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Windows" )
	set(SOS_SDK_PATH_TO_QMAKE "C:/Qt-5.9/5.9.3/mingw53_32/bin")
	set(SOS_SDK_PATH_TO_MAKE "C:/StratifyLabs-SDK/Tools/gcc/bin")
	set(SOS_SDK_EXEC_SUFFIX ".exe")
	set(SOS_SDK_GENERATOR -G "MinGW Makefiles")
	set(SOS_SDK_QMAKE_ARGS -spec win32-g++ "CONFIG+=qtquickcompiler")
endif()

if( SOS_SDK_PATH_TO_CMAKE )
	set(SOS_SDK_CMAKE_EXEC ${SOS_SDK_PATH_TO_CMAKE}/cmake${SOS_SDK_EXEC_SUFFIX})
else()
	set(SOS_SDK_CMAKE_EXEC cmake${SOS_SDK_EXEC_SUFFIX})
endif()

if( SOS_SDK_PATH_TO_MAKE )
	set(SOS_SDK_MAKE_EXEC ${SOS_SDK_PATH_TO_MAKE}/make${SOS_SDK_EXEC_SUFFIX})
else()
	set(SOS_SDK_MAKE_EXEC make${SOS_SDK_EXEC_SUFFIX})
endif()

if( PATH_TO_QMAKE )
	set(SOS_SDK_QMAKE_EXEC ${PATH_TO_QMAKE}/qmake${SOS_SDK_EXEC_SUFFIX})
else()
	if( SOS_SDK_PATH_TO_QMAKE )
		set(SOS_SDK_QMAKE_EXEC ${SOS_SDK_PATH_TO_QMAKE}/qmake${SOS_SDK_EXEC_SUFFIX})
	else()
		set(SOS_SDK_QMAKE_EXEC qmake${SOS_SDK_EXEC_SUFFIX})
	endif()
endif()

if( SOS_SDK_PATH_TO_GIT )
	set(SOS_SDK_GIT_EXEC ${SOS_SDK_PATH_TO_GIT}/git${SOS_SDK_EXEC_SUFFIX})
else()
	set(SOS_SDK_GIT_EXEC git${SOS_SDK_EXEC_SUFFIX})
endif()

function(sos_sdk_pull PROJECT_PATH)
	execute_process(COMMAND ${SOS_SDK_GIT_EXEC} pull WORKING_DIRECTORY ${PROJECT_PATH} OUTPUT_VARIABLE OUTPUT RESULT_VARIABLE RESULT)
	message(STATUS "git pull " ${PROJECT_PATH} "\n" ${OUTPUT})
	if(RESULT)
		message(FATAL_ERROR " Failed to pull " ${PROJECT_PATH})
	endif()
endfunction()


function(sos_sdk_git_status PROJECT_PATH)
	message(STATUS "GIT STATUS OF " ${PROJECT_PATH})
	execute_process(COMMAND ${SOS_SDK_GIT_EXEC} status WORKING_DIRECTORY ${PROJECT_PATH} RESULT_VARIABLE RESULT)
endfunction()

function(sos_sdk_clone REPO_URL WORKSPACE_PATH)
	execute_process(COMMAND ${SOS_SDK_GIT_EXEC} clone ${REPO_URL} WORKING_DIRECTORY ${WORKSPACE_PATH} OUTPUT_VARIABLE OUTPUT RESULT_VARIABLE RESULT)
	message(STATUS "git clone " ${REPO_URL} to ${WORKSPACE_PATH} "\n" ${OUTPUT})
	if(RESULT)
		message(FATAL_ERROR " Failed to clone " ${PROJECT_PATH})
	endif()
endfunction()

function(sos_sdk_clone_or_pull PROJECT_PATH REPO_URL WORKSPACE_PATH)
	#if ${PROJECT_PATH} directory doesn't exist -- clone from the URL
	if(EXISTS ${PROJECT_PATH}/.git)
		message(STATUS ${PROJECT_PATH} " already exists: pulling")
		sos_sdk_pull(${PROJECT_PATH})
	else()
		file(REMOVE_RECURSE ${PROJECT_PATH})
		message(STATUS ${PROJECT_PATH} " does not exist: cloning")
		sos_sdk_clone(${REPO_URL} ${WORKSPACE_PATH})
	endif()

endfunction()

function(sos_sdk_build_app PROJECT_PATH)
	set(BUILD_PATH ${PROJECT_PATH}/cmake_arm)
	file(MAKE_DIRECTORY ${BUILD_PATH})
	execute_process(COMMAND ${SOS_SDK_CMAKE_EXEC} ${SOS_SDK_GENERATOR} .. WORKING_DIRECTORY ${BUILD_PATH})
	if(RESULT)
		message(FATAL_ERROR " Failed to generate using " ${SOS_SDK_CMAKE_EXEC} ".. " ${SOS_SDK_GENERATOR} "	in " ${BUILD_PATH})
	endif()
	if(SOS_SDK_CLEAN_ALL)
		execute_process(COMMAND ${SOS_SDK_CMAKE_EXEC} --build . --target clean WORKING_DIRECTORY ${BUILD_PATH})
		if(RESULT)
			message(FATAL_ERROR " Failed to clean using " ${SOS_SDK_CMAKE_EXEC} "--build . --target clean on " ${PROJECT_PATH})
		endif()
	endif()
	execute_process(COMMAND ${SOS_SDK_CMAKE_EXEC} --build . --target all -- -j 10 WORKING_DIRECTORY ${BUILD_PATH})
	if(RESULT)
		message(FATAL_ERROR " Failed to build all using " ${SOS_SDK_CMAKE_EXEC} "--build . --target all -- -j 10 on " ${PROJECT_PATH})
	endif()
endfunction()

function(sos_sdk_build_bsp PROJECT_PATH)
	set(BUILD_PATH ${PROJECT}/cmake_arm)
	file(MAKE_DIRECTORY ${BUILD_PATH})
	execute_process(COMMAND ${SOS_SDK_CMAKE_EXEC} ${SOS_SDK_GENERATOR} .. WORKING_DIRECTORY ${BUILD_PATH} RESULT_VARIABLE RESULT)
	if(RESULT)
		message(FATAL_ERROR " Failed to generate using " ${SOS_SDK_CMAKE_EXEC} ".. " ${SOS_SDK_GENERATOR} "	in " ${BUILD_PATH})
	endif()
	if(RESULT)
		message(FATAL ${SOS_SDK_CMAKE_EXEC} "Failed")
	endif()
	if(SOS_SDK_CLEAN_ALL)
		execute_process(COMMAND ${SOS_SDK_CMAKE_EXEC} --build . --target clean WORKING_DIRECTORY ${BUILD_PATH} RESULT_VARIABLE RESULT)
		if(RESULT)
			message(FATAL_ERROR " Failed to clean using " ${SOS_SDK_CMAKE_EXEC} "--build . --target clean on " ${PROJECT_PATH})
		endif()
	endif()
	execute_process(COMMAND ${SOS_SDK_CMAKE_EXEC} --build . --target all -- -j 10 WORKING_DIRECTORY ${BUILD_PATH} RESULT_VARIABLE RESULT)
	if(RESULT)
		message(FATAL_ERROR " Failed to build all using " ${SOS_SDK_CMAKE_EXEC} "--build . --target all -- -j 10 on " ${PROJECT_PATH})
	endif()
endfunction()

function(sos_sdk_build_lib PROJECT_PATH IS_INSTALL CONFIG)
	set(BUILD_PATH ${PROJECT_PATH}/cmake_${CONFIG})
	file(MAKE_DIRECTORY ${PROJECT_PATH}/cmake_${CONFIG})

	if(IS_INSTALL)
		set(TARGET install)
	elseif()
		set(TARGET all)
	endif()


	execute_process(COMMAND ${SOS_SDK_CMAKE_EXEC} ${SOS_SDK_GENERATOR} .. WORKING_DIRECTORY ${BUILD_PATH} RESULT_VARIABLE RESULT)
	if(RESULT)
		message(FATAL_ERROR " Failed to generate using " ${SOS_SDK_CMAKE_EXEC} " .. " ${SOS_SDK_GENERATOR} "	in " ${BUILD_PATH})
	endif()
	if(CONFIG STREQUAL "link")
		#Sometimes there is a problem building if cmake is only run once
		execute_process(COMMAND ${SOS_SDK_CMAKE_EXEC} ${SOS_SDK_GENERATOR} .. WORKING_DIRECTORY ${BUILD_PATH} RESULT_VARIABLE RESULT)
	endif()
	if(SOS_SDK_CLEAN_ALL)
		execute_process(COMMAND ${SOS_SDK_CMAKE_EXEC} --build . --target clean WORKING_DIRECTORY ${BUILD_PATH} RESULT_VARIABLE RESULT)
		if(RESULT)
			message(FATAL_ERROR " Failed to clean using " ${SOS_SDK_CMAKE_EXEC} "--build . --target clean on " ${PROJECT_PATH})
		endif()
	endif()
	execute_process(COMMAND ${SOS_SDK_CMAKE_EXEC} --build . --target ${TARGET} -- -j 10 WORKING_DIRECTORY ${BUILD_PATH} RESULT_VARIABLE RESULT)
	if(RESULT)
		message(FATAL_ERROR " Failed to build all using " ${SOS_SDK_CMAKE_EXEC} "--build . --target all -- -j 10 on " ${PROJECT_PATH})
	endif()
endfunction()

function(sos_sdk_build_qt_lib PATH PROJECT CONFIG)
	message(STATUS "QMAKE: " ${SOS_SDK_QMAKE_EXEC})
	message(STATUS "PROJECT PATH: " ${PATH}/${PROJECT}/${PROJECT}.pro)
	file(MAKE_DIRECTORY ${PATH}/build_${CONFIG})
	execute_process(COMMAND ${SOS_SDK_QMAKE_EXEC} ${PATH}/${PROJECT}/${PROJECT}.pro	${SOS_SDK_QMAKE_ARGS} WORKING_DIRECTORY ${PATH}/build_${CONFIG} RESULT_VARIABLE RESULT)
	if(RESULT)
		message(FATAL_ERROR " Failed to run QMAKE: ${SOS_SDK_QMAKE_EXEC} ${PATH}/${PROJECT}/${PROJECT}.pro " ${SOS_SDK_QMAKE_ARGS} " in " ${PATH}/build_${CONFIG})
	endif()
	if(SOS_SDK_CLEAN_ALL)
		message(STATUS "Clean: " ${PROJECT})
		execute_process(COMMAND ${SOS_SDK_MAKE_EXEC} clean WORKING_DIRECTORY ${PATH}/build_${CONFIG} RESULT_VARIABLE RESULT)
		if(RESULT)
			message(FATAL_ERROR " Failed to run make clean: " ${SOS_SDK_MAKE_EXEC} clean)
		endif()
	endif()
	execute_process(COMMAND ${SOS_SDK_MAKE_EXEC} install WORKING_DIRECTORY ${PATH}/build_${CONFIG} RESULT_VARIABLE RESULT)
	if(RESULT)
		message(FATAL_ERROR " Failed to run make install: " ${SOS_SDK_MAKE_EXEC} install)
	endif()
endfunction()

