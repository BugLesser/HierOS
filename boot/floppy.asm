incbin "bootsect.bin"

times 80 * 18 * 2 * 512 - ($-$$) db 0 ; 填充软盘剩余空间
