module main

import limine
import pmm

// Only support Limine base revision 2 and up.
@[_linker_section: '.requests']
@[cinit]
__global (
	volatile limine_base_revision = limine.LimineBaseRevision{
		revision: 2
	}
)

// Stub V main() (we need to call the pmm_init() before initialising the
// runtime, which wouldn't be possible if using normal main()).
pub fn main() {
	kmain()
}

fn C._vinit(argc int, argv voidptr)

pub fn kmain() {
	// Ensure the Limine base revision is supported.
	if limine_base_revision.revision != 0 {
		for {}
	}

	for {}

	// Initialize the memory allocator.
	pmm.initialise()

	// Call Vinit to initialise the V runtime.
	C._vinit(0, 0)

	print('hello world')

    for {}
}
