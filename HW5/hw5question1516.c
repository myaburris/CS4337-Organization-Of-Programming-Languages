#include <stdio.h>
void f(void *x) {
*((int*)x) = 0;
}
int main(int argc, const char **argv) {
int y = 0;
int *z = &y;
f((void *)&z);
printf("%d", *z);
return 0;
}
