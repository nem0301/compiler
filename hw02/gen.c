#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NO_SYMBOL 2

char alphabet[NO_SYMBOL] = { '0', '1'};

void rec(char* str, int n){
  int i;
  int len = strlen(str);
  char* temp = (char*) malloc (sizeof(char) * (len + 1));
  
  if ( n == 0) {
    putchar('\n');
  } else {
    for (i = 0; i < NO_SYMBOL; i++){
      sprintf(temp, "%s%c", str, alphabet[i]);
      if ( n == 1) {
          printf("%s", temp);
      }
      rec(temp, n-1);      
    }    
  }
  free(temp);
}

int main(int argc, char** argv){
  int n, i;
  
  if (argc < 2){
    printf ("no input\n");
    exit(1);
  }
  
  n = atoi( argv[1] );

  for (i = 0; i <=n; i++){
    rec("", i);
  }
   
  return 0;
}

