#include "brk.h"

void *initial_brk = 0;
void *current_brk = 0;

void setup_brk()
{
    initial_brk = sbrk(0);
    current_brk = sbrk(0);
}

void *memory_alloc(unsigned long int bytes)
{
    void *current = initial_brk;
    void *previous = initial_brk;

    while (current < current_brk)
    {
        if (*(unsigned long int *)current == 0 && *(unsigned long int *)(current + 8) >= bytes)
        {
            if (*(unsigned long int *)(current + 8) - bytes >= 16 + 1)
            {
                void *new_block = current + 16 + bytes;
                *(unsigned long int *)new_block = 0;
                *(unsigned long int *)(new_block + 8) = *(unsigned long int *)(current + 8) - bytes - 16;
                *(unsigned long int *)current = 1;
                *(unsigned long int *)(current + 8) = bytes;
                return current + 16;
            }
            else
            {
                *(unsigned long int *)current = 1;
                return current + 16;
            }
        }
        previous = current;
        current += *(unsigned long int *)(current + 8) + 16;
    }
    if (current == current_brk)
    {
        sbrk(bytes + 16);
        *(unsigned long int *)current = 1;
        *(unsigned long int *)(current + 8) = bytes;
        current_brk += bytes + 16;
        return current + 16;
    }
    return 0;
};

int memory_free(void *pointer)
{
    // just set the pointer to free
    if (pointer == 0)
    {
        return 0;
    }

    void *max_pointer_val = current_brk - 16;

    if (pointer < initial_brk || pointer > max_pointer_val)
    {
        return 0;
    }

    pointer -= 16;
    *(unsigned long int *)pointer = 0;

    return 0;
};

void dismiss_brk()
{
    sbrk(initial_brk - current_brk);
}