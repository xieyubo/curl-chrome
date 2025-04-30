cmake_minimum_required(VERSION 3.28)

project(curl-chrome)

function(make_avaliable name)
    set(src_dir ${CMAKE_CURRENT_SOURCE_DIR}/src/${name})
    set(bin_dir ${CMAKE_CURRENT_BINARY_DIR}/${name})
    set(installed_dir ${CMAKE_CURRENT_BINARY_DIR}/${name}/installed)
    set(${name}_SRC_DIR ${src_dir} PARENT_SCOPE)
    set(${name}_BIN_DIR ${bin_dir} PARENT_SCOPE)
    set(${name}_INSTALLED_DIR ${installed_dir} PARENT_SCOPE)
    set(multiValueArgs OPTIONS DEPENDS)
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "" "${multiValueArgs}")

    make_directory(${bin_dir})
    add_custom_target(${name}
        COMMAND cmake -GNinja ${src_dir} -DCMAKE_INSTALL_PREFIX=${installed_dir} ${arg_OPTIONS}
        COMMAND ninja
        COMMAND ninja install 
        DEPENDS ${arg_DEPENDS}
        WORKING_DIRECTORY ${bin_dir}
        USES_TERMINAL
    )
endfunction()

execute_process(
    COMMAND git describe --always --dirty
    OUTPUT_VARIABLE GIT_SHA1
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

make_avaliable(boringssl)
make_avaliable(brotli
    OPTIONS -DBUILD_SHARED_LIBS=OFF
)
make_avaliable(nghttp2
    OPTIONS -DBUILD_STATIC_LIBS=ON
            -DBUILD_SHARED_LIBS=OFF
            -DBUILD_TESTING=OFF
)
make_avaliable(zlib)
make_avaliable(zstd)
make_avaliable(curl
    OPTIONS -DBUILD_SHARED_LIBS=OFF
            -DCURL_USE_OPENSSL=ON -DOpenSSL_ROOT=${boringssl_INSTALLED_DIR}
            -DCURL_BROTLI=ON -DBrotli_ROOT=${brotli_INSTALLED_DIR}
            -DUSE_NGHTTP2=ON -DNGHTTP2_ROOT=${nghttp2_INSTALLED_DIR}
            -DCURL_ZLIB=ON -DZLIB_ROOT=${zlib_INSTALLED_DIR}
            -DCURL_ZSTD=ON -DZstd_ROOT=${zstd_INSTALLED_DIR}
            -DBUILD_LIBCURL_DOCS=OFF -DBUILD_MISC_DOCS=OFF -DENABLE_CURL_MANUAL=OFF
            -DCURL_STATIC_EXE=ON
            -DUSE_HTTPSRR=ON
            -DUSE_ECH=ON -DHAVE_ECH=ON
            -DCURL_USE_LIBPSL=OFF
            -DCURL_USE_PKGCONFIG=OFF
            -DCMAKE_C_FLAGS="-DCURL_CUSTOM_NAME=curl-chrome;-DCURL_COMMIT_ID=${GIT_SHA1}"
    DEPENDS boringssl brotli nghttp2 zlib zstd
)

add_custom_target(default ALL
    DEPENDS curl
)