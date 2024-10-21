package dynamic_memory

import "core:fmt"
import "core:mem"
import "core:math/rand"
import "core:c/libc"
import "core:log"


using_temp_allocator :: proc() -> int {
    numbers := make([dynamic]int, context.temp_allocator)

    for i in 0..<100 {
        append(&numbers, i)
    }

    rand.shuffle(numbers[:])
    fmt.println(numbers)
    
    defer {
        free_all(context.temp_allocator)  
        fmt.println("Trying to access deleted memory:", numbers[0]) // Expect undefined behavior here      
    }

    return numbers[0]
}

advanced_memory_management :: proc() -> int {
    default_allocator := context.allocator 
    tracking_allocator: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_allocator, default_allocator)
    context.allocator = mem.tracking_allocator(&tracking_allocator) 

    reset_tracking_allocator :: proc(a: ^mem.Tracking_Allocator) -> bool {
        err := false

        for _, value in a.allocation_map {
            fmt.printf("%v: Leaked %v bytes\n", value.location, value.size)
            err = true
        }

        mem.tracking_allocator_clear(a)
        return err
    }


    // Defers the destruction of the memory allocators until the function scope ends
    defer {
        free_all(context.temp_allocator)
        mem.tracking_allocator_destroy(&tracking_allocator)
    }
 
    numbers := make([dynamic]int, default_allocator)

    for i in 0..<100 {
        append(&numbers, i)
    }
    fmt.println(numbers)

    rand.shuffle(numbers[:])
    n := numbers[0]
    fmt.println(n)

    if len(tracking_allocator.bad_free_array) > 0 {
        for b in tracking_allocator.bad_free_array {
            log.errorf("Bad free at: %v", b.location)
        }

        libc.getchar()
        panic("Bad free detected")
    }  

    some_int := new(int, context.temp_allocator) 

    // Checks for memory leaks
    if reset_tracking_allocator(&tracking_allocator) {
		libc.getchar()
	}
    
    any_int := new(int, context.temp_allocator)

    return n
}


leaked_memory_example :: proc() -> int {
    default_allocator := context.allocator
    tracking_allocator: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_allocator, default_allocator)
    context.allocator = mem.tracking_allocator(&tracking_allocator) 

    reset_tracking_allocator :: proc(a: ^mem.Tracking_Allocator) -> bool {
        err := false

        for _, value in a.allocation_map {
            fmt.printf("%v: Leaked %v bytes\n", value.location, value.size)
            err = true
        }

        mem.tracking_allocator_clear(a)
        return err
    }

    // Defers the destruction of tracking_allocator until the function scope ends
    defer mem.tracking_allocator_destroy(&tracking_allocator) 

    // not allocating any memory here also causes a memory leak 
    // because we cannot destroy even after the function scope 
    some_int := new(int)

    // using context.allocator here instead of default_allocator 
    // as well as not clearing(deallocating) allocated memory also causes a memory leak
    numbers := make([dynamic]int, context.allocator)

    for i in 0..<100 {
        append(&numbers, i)
    }
    fmt.println(numbers)

    rand.shuffle(numbers[:])
    n := numbers[0]
    fmt.println(n)

    reset_tracking_allocator(&tracking_allocator)

    free_all(context.temp_allocator) 

    // Second destruction of tracking_allocator in the function scope. 
    // This is a bad free also known as a double free
    mem.tracking_allocator_destroy(&tracking_allocator)

    return n
}

manual_memory :: proc() {
    using_temp_allocator() 
    advanced_memory_management()
    leaked_memory_example()
}
