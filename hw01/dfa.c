#include <stdio.h>
#include <stdlib.h>

#define NO_ALPHABET 3
#define NO_STATES 2

#define ACCEPT 1
#define REJECT 0

int alphabet[NO_ALPHABET] = { 'a', 'b', 'c' };
int starting_state = 0;

int accepting_states[NO_STATES] = { 1, 0 };

int transition_function[NO_STATES][NO_ALPHABET] = {
    { 1, 0, 0 },
    { 0, 1, 1 },
};

int symbol_index(int c){
    int i = 0;

    for (i = 0; i < NO_ALPHABET; i++)
    {
        if ( c == alphabet[i])
        {
            return i;
        }
    }
    return -1;
}

int dfa (char input_string[]) 
{
    char c;
    int i = 0, state=starting_state;

    for (;;)
    {
        c = input_string[i++];
        if ( c == '\0' )
        {
            if (accepting_states[state] == 1 ) return ACCEPT;
            else return REJECT;
        }
        else 
        {
            state = transition_function [state][symbol_index(c)];
        }
    }
}

int main (int argc, char** argv)
{
    int len = 1;
    char c;
    char* str;
    char* temp;
    
    str = (char*) malloc (sizeof(char));
    *str = '\0';

    while( (c = getc(stdin)) != EOF)
    {
        len++;
        temp = (char*) malloc (sizeof(char) * len);
        sprintf(temp, "%s%c", str, c);

        if ( c == '\n' )
        {
            if (dfa(str)) 
            { 
                printf("accept: %s\n", str);
            }
            else
            {           
                printf("reject: %s\n", str);
            }

            len = 1;
            free(str);
            str = (char*) malloc (sizeof(char));
            *str = '\0';
        } 
        else 
        {
            str = (char*) realloc (str, sizeof(char) * len);
            sprintf(str, "%s", temp);
        }

        free(temp);
    }
    return 0;
}

