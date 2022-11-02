AHK_PATH ?= C:\Program Files\AutoHotkey
AHK_TYPE ?= U
AHK_SIZE ?= 64
CC = ${AHK_PATH}\AutoHotkey${AHK_TYPE}${AHK_SIZE}.exe
FILE ?= test_1

all:
	${CC} tests\${FILE}.ahk
