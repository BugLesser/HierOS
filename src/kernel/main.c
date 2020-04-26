typedef unsigned short uint16_t;
typedef unsigned char uint8_t;

// make a char and color
#define make_cc(c, color) ((unsigned short)((color << 8) | c));

uint16_t* video_memory = (uint16_t*)0xb8000;


// 80列*25行
static uint8_t cursor_x = 0;
static uint8_t cursor_y = 0;

void outb(uint16_t port, uint8_t value)
{
    asm volatile ("outb %1, %0" : : "dN" (port), "a" (value));
}

void move_cursor()
{
    // 屏幕是 80 字节宽
    uint16_t cursorLocation = cursor_y * 80 + cursor_x;
    // 在这里用到的两个内部寄存器的编号为14与15，分别表示光标位置
    // 的高8位与低8位。
    outb(0x3D4, 14);                    // 告诉 VGA 我们要设置光标的高字节
    outb(0x3D5, cursorLocation >> 8);   // 发送高 8 位
    outb(0x3D4, 15);                    // 告诉 VGA 我们要设置光标的低字节
    outb(0x3D5, cursorLocation);        // 发送低 8 位
}

void clear_console() {
	int i = 0;
	while(i < 80 * 25) {
		video_memory[i++] = make_cc(' ', 0xf);
	}
	cursor_x = 0;
	cursor_y = 0;
	move_cursor();
}

void putchar(char c) {
	if(cursor_x > 25) {
		cursor_x = 0;
		cursor_y++;
	}
	video_memory[cursor_y * 80 + cursor_x++] = make_cc(c, 0xf);
	move_cursor();
}

void print_str(const char* str) {
	while(*str) {
		putchar(*str++);
	}
}



// kernel entry
void kernel_entry()
{
	clear_console();
	print_str("I AM DECAT !!!");
	
	while (1)
	{
		asm("hlt");
	}
}