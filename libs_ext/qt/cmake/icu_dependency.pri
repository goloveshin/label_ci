win32 {
    CONFIG(static, static|shared) {
        CONFIG(debug, debug|release) {
            LIBS_PRIVATE += -lsicuind -lsicuucd -lsicudtd
        } else {
            LIBS_PRIVATE += -lsicuin -lsicuuc -lsicudt
        }
    } else {
        CONFIG(debug, debug|release) {
            LIBS_PRIVATE += -licuind -licuucd -licudt
        } else {
            LIBS_PRIVATE += -licuin -licuuc -licudt
        }
    }
} else {
    LIBS_PRIVATE += -licui18n -licuuc -licudata
}
