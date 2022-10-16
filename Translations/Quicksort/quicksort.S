//quicksort.S

.global main
//NO LIBRARIES NEEDED
//#include <stdio.h>
//#include <stdlib.h>

.data
bad_input: .string "bad input"
good_input: .string "%ld\n"
input: .string "%ld"
output: .string "%ld "
indent: .string "\n"

.text

//////////////////////////////////////////////////////////////////////////////////////////////////////

//void
//swap(long* xs, long ii, long jj) {
/* Variable Mapping:
- xs in rdi
- ii in rsi 
- jj in rdx
- tmp in r12
 */
swap:
	push %r12
	enter $8, $0 

//    if (ii != jj) {
	cmp %rdx, %rsi 
	je swap_done

//        long tmp = xs[ii];
	mov (%rdi, %rsi, 8), %r12 // tmp is in r12

//        xs[ii] = xs[jj];
	mov (%rdi, %rdx, 8), %rax
	mov %rax, (%rdi, %rsi, 8) //take care of that swap

//        xs[jj] = tmp; }}
	mov %r12, (%rdi, %rdx, 8)

swap_done:
	leave
	pop %r12 //pop pop
	ret

//////////////////////////////////////////////////////////////////////////////////////////////////////

//long
//partition(long* xs, long lo, long hi) {
/* Variable Mapping:
- xs in rdi -> %r12
- lo in rsi -> %r13
- hi in rdx -> %r14 then dec to (hi - 1)
- pivot in %r15
- ii takes over %r13 slot
- jj in %rbx
*/
partition:
	push %r12
	push %r13
	push %r14
	push %r15
	push %rbx
	enter $24, $0

//    long pivot = xs[hi - 1];
	mov %rdi, %r12 //xs
	mov %rsi, %r13 //lo
	mov %rdx, %r14 //hi
	dec %r14
	mov (%r12, %r14, 8), %r15 //pivot

//    long ii = lo; lo is no renamed to ii @ %r13

//    long jj = lo;
	mov %r13, %rbx

//    for (; jj < (hi - 1); ++jj) {
partition_loop:
	cmp %r14, %rbx
	jge partition_loop_done

//        if (xs[jj] < pivot) {
	cmp %r15, (%r12, %rbx, 8)
	jge partition_no
	
partition_yes:
//            swap(xs, ii, jj);
	mov %r12, %rdi
	mov %r13, %rsi
	mov %rbx, %rdx
	call swap

//	      ++ii; }}
	inc %r13
	inc %rbx
	jmp partition_loop

partition_no:
	inc %rbx
	jmp partition_loop

partition_loop_done:
//    swap(xs, ii, hi - 1);
	mov %r12, %rdi
	mov %r13, %rsi
	mov %r14, %rdx	
	call swap

	mov %r13, %rax

	leave
	pop %rbx
	pop %r15
	pop %r14
	pop %r13
	pop %r12
	ret

//////////////////////////////////////////////////////////////////////////////////////////////////////

//void
//quicksort(long* xs, long lo, long hi) {
/*Variable Mapping:
- xs in rdi -> r12
- lo in rsi -> r13
- hi in rdx -> r14
- pp in r15
*/
quicksort:
	push %r12
	push %r13
	push %r14
	push %r15
	enter $48, $0

	mov %rdi, %r12
	mov %rsi, %r13
	mov %rdx, %r14

//    if (hi - lo < 1) {
//        return; }
	sub %rsi, %rdx // values still in input slots, result stays at rdx
	mov $1, %rdi
	cmp %rdi, %rdx
	jl quicksort_done 
	
//    long pp = partition(xs, lo, hi);
	mov %r12, %rdi
	mov %r13, %rsi
	mov %r14, %rdx
	call partition
	mov %rax, %r15

//    quicksort(xs, lo, pp);
	mov %r12, %rdi
	mov %r13, %rsi
	mov %r15, %rdx
	call quicksort

//    quicksort(xs, pp + 1, hi); {
	mov %r12, %rdi
	inc %r15
	mov %r15, %rsi
	mov %r14, %rdx
	call quicksort
	

quicksort_done:
	leave
	pop %r15
	pop %r14
	pop %r13
	pop %r12
	ret

//////////////////////////////////////////////////////////////////////////////////////////////////////

//void
//read_int(long* ptr) {
/*Variable Mapping:
- ptr in rdi
*/
read_int:
	enter $16, $0

//    if (scanf("%ld", ptr) != 1) {
	mov %rdi, %rsi // lea before change
	mov $input, %rdi
	mov $0, %al
	call scanf
	cmp $1, %rax 
	je read_int_done

//       puts("bad input");
	mov $bad_input, %rdi
	call puts

//        exit(1); }}
	mov $1,  %rax
	call abort

read_int_done:
	leave
	ret

//////////////////////////////////////////////////////////////////////////////////////////////////////

//int
//main(int _argc, char* _argv[]) {
/* Variable Mapping:
- _argc in rdi
- _argv[] in rsi
- nn in 0(%rsp) -> r12
- xs in r13 
*/
main:
	push %r12
	push %r13
	push %rbx
	enter $24, $0 //allocated 16 for memory

//    long nn;
//    read_int(&nn);
	lea 0(%rsp), %rdi // this takes the memory address and feeds it to rdi for read int
	call read_int
	mov 0(%rsp), %r12

//    long* xs = malloc(nn * sizeof(long));
	mov %r12, %rdi 
	imul $8, %rdi, %rdi
	call malloc
	mov %rax, %r13 //xs is now in r13

//    for (long ii = 0; ii < nn; ++ii) {
	mov $0, %rbx

main_loop1:
	cmp %r12, %rbx
	jge main_loop1_exit

//	  read_int(&(xs[ii]))); }
	lea (%r13, %rbx, 8), %rdi // is this yes?
	call read_int  
	inc %rbx //++ii
	jmp main_loop1

main_loop1_exit:
//    quicksort(xs, 0, nn);
	mov %r13, %rdi
	mov $0, %rsi
	mov 0(%rsp), %rdx
	call quicksort // rdi "changed" in quicksort but should point to the momory in r13. r13 has xs

//    printf("%ld\n", nn);
	mov $good_input, %rdi
	mov 0(%rsp), %rsi
	mov $0, %al
	call printf

//    for (long ii = 0; ii < nn; ++ii) {
	mov $0, %rbx
main_loop2:
	cmp 0(%rsp), %rbx
	jge main_loop2_exit

//        printf("%ld ", xs[ii]);}
	mov $output, %rdi
	mov (%r13, %rbx, 8), %rsi
	mov $0, %al
	call printf
	inc %rbx
	jmp main_loop2
	
main_loop2_exit:
//    printf("\n");
	mov $indent, %rdi
	mov $0, %al
	call printf

//    free(xs);
	mov %r13, %rdi
	call free //frees the memory

//    return 0;}
	mov $0, %rax

	leave
	pop %rbx
	pop %r13
	pop %r12
	ret
