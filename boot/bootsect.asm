[bits 16]
org 0x7c00


[section .text]
jmp entry
db 0x90
DB "Hier--OS"	; 启动扇区名称（8字节）
DW 512			; 每个扇区（sector）大小（必须512字节）
DB 1			; 簇（cluster）大小（必须为1个扇区）
DW 1			; FAT起始位置（一般为第一个扇区）
DB 2			; FAT个数（必须为2）
DW 224			; 根目录大小（一般为224项）
DW 2880			; 该磁盘大小（必须为2880扇区1440*1024/512）
DB 0xf0			; 磁盘类型（必须为0xf0）
DW 9			; FAT的长度（必??9扇区）
DW 18			; 一个磁道（track）有几个扇区（必须为18）
DW 2			; 磁头数（必??2）
DD 0			; 不使用分区，必须是0
DD 2880			; 重写一次磁盘大小
DB 0,0,0x29		; 意义不明（固定）
DD 0xffffffff	; （可能是）卷标号码
DB "Hier-----OS"; 磁盘的名称（必须为11字，不足填空格）
DB "FAT12   "	; 磁盘格式名称（必须为8字，不足填空格）
times 18 db 0	; 填充18个字节


; 从si中循环读取字符输出到屏幕上
print_:
	mov al,[si]
	add si,1
	cmp al,0
	je ret_
	mov ah,0xe
	int 0x10
	jmp print_
ret_:
	ret

entry:
	; 初始化寄存器
	xor ax,ax
	mov ss,ax
	mov sp,ax
	mov ds,ax
	mov es,ax
	
	; 设置显示方式, 80*20 16色文本
	mov ah,0
	mov al,0x3
	int 0x10
	
	; 打印字符串
	mov si,msg
	call print_
	jmp fin

fin:
	hlt
	jmp fin

msg:
	db "load bootsect success...",13,10,13,10
	db "Hello HierOS!!!",0
	

times 510 - ($-$$) db 0 ; 填充零
dw 0x55aa ; 引导扇区标志