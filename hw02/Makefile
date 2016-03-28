CC=gcc
SRC=$(wildcard *.c)
OBJ=$(SRC:%.c=%.o)

all : objs
	@$(foreach obj, $(OBJ), $(CC) -o $(obj:%.o=%) $(obj);)

objs : $(SRC)
	@$(foreach src, $(SRC), $(CC) -c $(src);)

clean:
	@rm $(OBJ)
	@rm $(SRC:%.c=%)
