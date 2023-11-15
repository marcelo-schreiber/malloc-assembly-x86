#include <unistd.h>

// NULL
void setup_brk();   // Obtém o endereço de brk
void dismiss_brk(); // Restaura o endereço de brk
void *memory_alloc(unsigned long int bytes);
// 1. Procura bloco livre com tamanho igual ou maior que a
// 2. Se encontrar, marca ocupação, utiliza os bytes
// 3. Se não encontrar, abre espaço para um novo bloco
int memory_free(void *pointer); // Marca um bloco ocupado como