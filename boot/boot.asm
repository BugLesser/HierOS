;这三个双字为GRUB加载器识别MagicNumber 以及配置信息（可以不用理解）
dd 0x1badb002  
dd 0x3   	
dd -(0x1badb002+0x3)      

[BITS 32]   ;由于GRUB在加载内核前进入保护模式，所以要32位编译   
section .text
[GLOBAL boot_start]
[EXTERN kernel_entry]

gdt:
	; gdt[0] 啥也不是
	dd 0x00000000,0x00000000
	
	; gdt[1] 可执行的代码段
	dd 0x0000ffff,0x00cf9a00
	
	; gdt[2] 可读写的数据段
	dd 0x0000ffff,0x00cf9200
   ;以下是定义gdt的指针，前2字节是gdt界限，后4字节是gdt起始地址

gdt_ptr:
	dw 8 * 3 - 1
	dd gdt

;boot开始！
boot_start:
    cli                        ;关闭外中断        
    ;-----------------   准备进入保护模式   -------------------
;1 打开A20
;2 加载gdt
;3 将cr0的pe位置1
   ;-----------------  打开A20  ----------------
    in al,0x92
    or al,0000_0010B
    out 0x92,al
   ;-----------------  加载GDT  ----------------
    lgdt [gdt_ptr]
   ;-----------------  cr0第0位置1  ----------------
    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax
    jmp dword 0x8:far_jmp_target      ; 刷新流水线，避免分支预测的影响,这种cpu优化策略，最怕jmp跳转，

;初始化段寄存器以及栈结构
far_jmp_target:
    mov ax,0x10 ; 数据段
	mov	ds,ax
	mov	ss,ax
	mov	fs,ax
	mov	es,ax
	mov gs,ax
    mov esp, stack_top_end
    mov ebp, 0           
;进入内核主函数    
    call kernel_entry                    
    jmp dword $ ; 防止意外退出内核


section .bss ; 未初始化的数据段从这里开始
stack_top:
	resb 0x512
stack_top_end equ $-1