module framebuffer

import limine

@[_linker_section: '.requests']
@[cinit]
__global (
	volatile framebuffer_req = limine.LimineFramebufferRequest{
		response: unsafe { nil }
	}
)

__global (
	framebuffer_tag = &limine.LimineFramebuffer(unsafe { nil })
)

pub fn initialise() {
	if fb_req.response == unsafe { nil } {
		panic('Framebuffer bootloader response missing')
	}
	framebuffer_tag = unsafe { fb_req.response.framebuffers[0] }
}
