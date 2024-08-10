	.arch armv8-a+crc
	.file	"2_unoptimized.c"
	.text
	.align	2
	.p2align 4,,15
	.global	calculate_lut
	.type	calculate_lut, %function
calculate_lut:
.LFB11:
	.cfi_startproc
	stp	x19, x20, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 19, -32
	.cfi_offset 20, -24
	mov	x19, 0
	mov	x20, x0
	str	d8, [sp, 24]
	.cfi_offset 72, -8
	fmov	d8, 1.0e+0
	str	x30, [sp, 16]
	.cfi_offset 30, -16
	.p2align 3,,7
.L2:
	neg	w1, w19
	fmov	d0, 2.0e+0
	scvtf	d1, w1
	bl	pow
	fadd	d0, d0, d8
	bl	log2
	str	d0, [x20, x19, lsl 3]
	add	x19, x19, 1
	cmp	x19, 15
	bne	.L2
	ldr	x30, [sp, 16]
	ldr	d8, [sp, 24]
	ldp	x19, x20, [sp], 32
	.cfi_restore 20
	.cfi_restore 19
	.cfi_restore 30
	.cfi_restore 72
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE11:
	.size	calculate_lut, .-calculate_lut
	.align	2
	.p2align 4,,15
	.global	log2_CCM
	.type	log2_CCM, %function
log2_CCM:
.LFB12:
	.cfi_startproc
	stp	x19, x20, [sp, -192]!
	.cfi_def_cfa_offset 192
	.cfi_offset 19, -192
	.cfi_offset 20, -184
	mov	x19, 1
	add	x20, sp, 64
	stp	d8, d9, [sp, 32]
	.cfi_offset 72, -160
	.cfi_offset 73, -152
	fmov	d8, 1.0e+0
	fmov	d9, d0
	stp	x21, x30, [sp, 16]
	.cfi_offset 21, -176
	.cfi_offset 30, -168
	mov	w21, w19
	str	d10, [sp, 48]
	.cfi_offset 74, -144
	.p2align 3,,7
.L7:
	sub	w0, w21, w19
	fmov	d0, 2.0e+0
	scvtf	d1, w0
	bl	pow
	fadd	d0, d0, d8
	bl	log2
	add	x0, x20, x19, lsl 3
	add	x19, x19, 1
	cmp	x19, 16
	str	d0, [x0, -8]
	bne	.L7
	movi	d10, #0
	fmov	d8, 1.0e+0
	mov	x19, 1
	mov	w21, w19
	.p2align 3,,7
.L10:
	sub	w0, w21, w19
	fmov	d0, 2.0e+0
	scvtf	d1, w0
	bl	pow
	fadd	d1, d0, d8
	add	x0, x20, x19, lsl 3
	ldr	d2, [x0, -8]
	fmul	d1, d1, d9
	fcmpe	d1, d8
	bls	.L11
.L8:
	add	x19, x19, 1
	cmp	x19, 16
	bne	.L10
	ldp	x21, x30, [sp, 16]
	fmov	d0, d10
	ldp	d8, d9, [sp, 32]
	ldr	d10, [sp, 48]
	ldp	x19, x20, [sp], 192
	.cfi_remember_state
	.cfi_restore 20
	.cfi_restore 19
	.cfi_restore 21
	.cfi_restore 30
	.cfi_restore 74
	.cfi_restore 72
	.cfi_restore 73
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L11:
	.cfi_restore_state
	fsub	d10, d10, d2
	fmov	d9, d1
	b	.L8
	.cfi_endproc
.LFE12:
	.size	log2_CCM, .-log2_CCM
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align	3
.LC0:
	.string	"unoptimized ccm log2(%f) = %f\n"
	.section	.text.startup,"ax",@progbits
	.align	2
	.p2align 4,,15
	.global	main
	.type	main, %function
main:
.LFB13:
	.cfi_startproc
	mov	x0, 3689348814741910323
	str	x30, [sp, -16]!
	.cfi_def_cfa_offset 16
	.cfi_offset 30, -16
	movk	x0, 0x3fe3, lsl 48
	str	d8, [sp, 8]
	.cfi_offset 72, -8
	fmov	d8, x0
	fmov	d0, d8
	bl	log2_CCM
	adrp	x0, .LC0
	fmov	d1, d0
	fmov	d0, d8
	add	x0, x0, :lo12:.LC0
	bl	printf
	ldr	d8, [sp, 8]
	mov	w0, 0
	ldr	x30, [sp], 16
	.cfi_restore 30
	.cfi_restore 72
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE13:
	.size	main, .-main
	.ident	"GCC: (Debian 12.2.0-14) 12.2.0"
	.section	.note.GNU-stack,"",@progbits
