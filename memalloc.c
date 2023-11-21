#include "memalloc.h"
#include <unistd.h>

void *brk_inicial = 0;
void *brk_atual = 0;

void setup_brk()
{
  brk_inicial = sbrk(0);
  brk_atual = sbrk(0);
}

void *memory_alloc(unsigned long int bytes)
{

  void *pointer = brk_inicial;        // r13
  void *biggest_pointer = 0;          // rcx
  unsigned long int biggest_size = 0; // r8
  unsigned long int size = 0;         // r15

  while (pointer != brk_atual)
  {
    size = *((unsigned long int *)(pointer + 8));
    if (*((unsigned long int *)pointer) == 0 && size >= bytes && size > biggest_size)
    {
      biggest_pointer = pointer;
      biggest_size = size;
    }
    pointer += size + 16;
  }

  if (biggest_pointer == 0)
  {
    pointer = sbrk(bytes + 16);
    *((unsigned long int *)pointer) = 1;
    *((unsigned long int *)(pointer + 8)) = bytes;
    brk_atual = pointer + bytes + 16;
    return pointer + 16;
  }
  else
  {
    if (biggest_size - bytes >= 17)
    {
      *((unsigned long int *)biggest_pointer) = 1;
      *((unsigned long int *)(biggest_pointer + 8)) = bytes;
      *((unsigned long int *)(biggest_pointer + bytes + 16)) = 0;
      *((unsigned long int *)(biggest_pointer + bytes + 24)) = biggest_size - bytes - 16;
      return biggest_pointer + 16;
    }
    else
    {
      *((unsigned long int *)biggest_pointer) = 1;
      return biggest_pointer + 16;
    }
  }
};

int memory_free(void *pointer)
{
  // just set the pointer to free
  if (pointer == 0)
  {
    return 0;
  }

  void *max_pointer_val = brk_atual - 16;

  if (pointer < brk_inicial || pointer > max_pointer_val)
  {
    return 0;
  }

  pointer -= 16;
  *(unsigned long int *)pointer = 0;

  return 0;
};

void dismiss_brk()
{
  sbrk(brk_inicial - brk_atual);
}