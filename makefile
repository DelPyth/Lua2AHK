AHK_PATH ?= C:/Program Files/AutoHotkey
CC = ${AHK_PATH}/v2/AutoHotkey.exe
TEST ?= test01

.PHONEY: all

all:
	${CC} ./tests/${TEST}.ahk2

