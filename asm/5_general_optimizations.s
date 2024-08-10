	.arch armv8-a+crc
	.file	"5_general_optimizations.c"
	.text
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align	3
.LC1:
	.string	"optimized fp ccm log2(%f) = %f\n"
	.section	.text.startup,"ax",@progbits
	.align	2
	.p2align 4,,15
	.global	main
	.type	main, %function
main:
.LFB11:
	.cfi_startproc
	mov	x2, 163277476724736
	mov	x1, 3689348814741910323
	str	x30, [sp, -16]!
	.cfi_def_cfa_offset 16
	.cfi_offset 30, -16
	movk	x2, 0xbfe7, lsl 48
	movk	x1, 0x3fe3, lsl 48
	adrp	x0, .LC1
	fmov	d1, x2
	add	x0, x0, :lo12:.LC1
	fmov	d0, x1
	bl	printf
	ldr	x30, [sp], 16
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	mov	w0, 0
	ret
	.cfi_endproc
.LFE11:
	.size	main, .-main
	.ident	"GCC: (Debian 12.2.0-14) 12.2.0"
	.section	.note.GNU-stack,"",@progbits
