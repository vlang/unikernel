module term

import klock
import framebuffer
import flanterm as _

__global (
	flanterm_ctx    voidptr
	term_write_lock klock.Lock
)

pub fn initialise() {
	flanterm_ctx = unsafe {
		C.flanterm_fb_init(voidptr(malloc), voidptr(free), framebuffer_tag.address,
			framebuffer_width, framebuffer_height, framebuffer_tag.pitch, framebuffer_tag.red_mask_size,
			framebuffer_tag.red_mask_shift, framebuffer_tag.green_mask_size, framebuffer_tag.green_mask_shift,
			framebuffer_tag.blue_mask_size, framebuffer_tag.blue_mask_shift, nil, nil,
			nil, nil, nil, nil, nil, nil, 0, 0, 1, 0, 0, 0)
	}
}

pub fn write(s voidptr, len u64) {
	term_write_lock.acquire()
	C.flanterm_write(flanterm_ctx, s, len)
	term_write_lock.release()
}
