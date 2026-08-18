cmake_minimum_required(VERSION 3.16)

project(GLCDByteArrayGenerator VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appGLCDByteArrayGenerator
    main.cpp
)

qt_add_qml_module(appGLCDByteArrayGenerator
    URI GLCDByteArrayGenerator
    VERSION 1.0
    QML_FILES
        Main.qml
        qml/GridSizeControl.qml
        qml/GLCDGlyphDrawer.qml
        qml/GlyphDelegate.qml
    SOURCES
        src/glyphdata.h src/glyphdata.cpp
        QML_FILES qml/GlyphSaveDialog.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appGLCDByteArrayGenerator PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appGLCDByteArrayGenerator
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_include_directories(appGLCDByteArrayGenerator PRIVATE ./src)

target_link_libraries(appGLCDByteArrayGenerator
    PRIVATE Qt6::Core
    PRIVATE Qt6::Gui
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Qml
)

include(GNUInstallDirs)
install(TARGETS appGLCDByteArrayGenerator
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
