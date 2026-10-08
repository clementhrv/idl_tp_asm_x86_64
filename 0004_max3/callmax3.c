#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include <stdlib.h>

int64_t max3(int64_t, int64_t, int64_t);

int main(int argc, char **argv)
{
    if (argc != 4) {
        fprintf(stderr, "Usage : %s x y z\n", argv[0]);
        return 1;
    }

    int64_t x = strtoll(argv[1], NULL, 10);
    int64_t y = strtoll(argv[2], NULL, 10);
    int64_t z = strtoll(argv[3], NULL, 10);

    printf("%" PRId64 "\n", max3(x, y, z));

    return 0;
}