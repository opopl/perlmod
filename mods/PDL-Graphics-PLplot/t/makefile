
source:=$(wildcard *.c)
progs:=$(patsubst %.c,%,$(source))

libs:=$(shell pkg-config plplotd --libs)
flags:=$(shell pkg-config plplotd --cflags)
cc:=gcc -pipe 
rpath:=-Wl,-rpath -Wl,/home/op/lib:/usr/lib/i386-linux-gnu

all: $(progs)

clean:
	rm -f $(progs)

$(progs): 
	$(cc) $@.c -o $@ $(flags) $(libs) $(rpath)
