# Understanding the Heap or Dynamic Memory Allocator and Deallocator
- I used the Odin programming language here as it is my preferred choice, but this concept also applies to low-level languages without a borrow checker or garbage collection like C, C++ and Zig.

- This repo includes three functions: 
1. The first function implements a temporary allocator for a dynamic array and frees that memory at the end of the function's scope.

2. The second function provides an advanced implementation of memory management that uses a default allocator, a temporary allocator, and a tracking allocator, which checks for memory leaks and prevents double frees.

3. The third function is a variant of the second function, but it intentionally includes a memory leak and double frees, causing the program to crash.

### Run the program using:
-           odin run .

