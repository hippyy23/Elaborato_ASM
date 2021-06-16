#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <stdint.h>
#include <sys/time.h>
#include <sys/stat.h>

/* Nome funzione Assembly dichiarata con extern */
extern int postfix(char* input,char* output); 
/* ************************************* */


char* retrieve_input(char* filename);               // funzione di supporto che prende in input il nome del file
                                                    // e restituisce la stringa da passare come parametro alla funzione assembly
void  write_output(char* filename,char* output);    // Scrive il risultato su un file di output

int main(int argc, char *argv[]) {

char* input;
char output[10];
    
    //**********************************
    // Recupera input dal file
    //**********************************
    
    input = retrieve_input(argv[1]);
    

    //**********************************
    // Chiamata assembly
    //**********************************
    postfix(input,output);
    //printf("%s\n",output);          // printf di controllo  

    //**********************************
    // Scrivi output della funzione sul file
    //**********************************

    write_output(argv[2],output);

    return 0;
}


void write_output(char* filename, char* output){

FILE *outputFile = fopen (filename, "w");               // apre il file da scrivere. Se non esiste lo crea. Se esiste lo resetta

    fprintf (outputFile, "%s", output);                 // scrive sul file
    fclose (outputFile);                                // chiude il file

}

char* retrieve_input(char* filename){

    FILE *inputFile = fopen(filename, "r");    
    char* input_string;                                 // stringa di input
    struct stat st;                                     // struttura speciale per recuperare info sui file 
    size_t size;                                        // st_size, parte della struttura st, contiene la dimensione del file in byte.

        
        if (inputFile == 0)
        {
            fprintf(stderr, "failed to open the input file. Syntax ./test <input_file> <output_file>\n");
            exit(1);
        } 
    
    
    stat(filename, &st);                                        // funzione per recuperare info del file e salvarle in struttura st
    size = st.st_size+1;                                        // st_size, parte della struttura st, contiene la dimensione del file 
    char* parameter = malloc(sizeof(char)*(size));              // alloco la stringa in base alla dimesione. +1 per tappo fine stringa
    
    fgets(parameter, (sizeof(char)*(size)), inputFile);         // copio dal file alla stringa, parametro della funzione assembly
    parameter[strlen(parameter)]='\0';                          // tappo!
    
    fclose(inputFile);
return parameter;

}