/*++

Copyright (c) 2017 Minoca Corp.

    This file is licensed under the terms of the GNU General Public License
    version 3. Alternative licensing terms are available. Contact
    info@minocacorp.com for details. See the LICENSE file at the root of this
    project for complete licensing information.

Module Name:

    trap.S

Abstract:

    This module implements interrupt and exception trap management, such as
    saving and restoring registers.

Author:

    Evan Green 8-Jun-2017

Environment:

    Kernel

--*/

//
// ------------------------------------------------------------------- Includes
//

#include <minoca/kernel/x64.inc>

//
// ---------------------------------------------------------------- Definitions
//

//
// -------------------------------------------------------------------- Globals
//

//
// ----------------------------------------------------------------------- Code
//

ASSEMBLY_FILE_HEADER

.globl HlVectorStart
.globl HlVectorEnd
.hidden HlVectorStart
.hidden HlVectorEnd

//
// VOID
// ArBreakExceptionHandlerAsm (
//     VOID
//     )
//

/*++

Routine Description:

    This routine is called directly when an debug exception occurs. It sets up
    the parameters and calls a C routine to handle the break. It then restores
    machine state to return from the exception. The arguments to this function
    are pushed by the hardware.

Arguments:

    None. RIP, CS, RFLAGS, RSP, and SS have been pushed onto the stack by the
    processor, and the stack was 16-byte aligned before the pushes.

Return Value:

    None.

--*/

FUNCTION(ArBreakExceptionHandlerAsm)
    pushq   $0                      # Push a dummy error code.
    call    ArGenerateTrapFrame     # Create a local trap frame.
    CFI_TRAP_FRAME_PUSHED           # Set unwind info for the debugger.
    movq    %rsp, %rdi              # 1st parameter is trap frame pointer.
    call    KeDispatchBreakPointTrap  # Call the main exception handler.
    call    ArRestoreTrapFrame      # Restore the trap frame
    CFI_TRAP_FRAME_POPPED           # Let the debugger know.
    iretq                           # Return from the exception.

END_FUNCTION(ArBreakExceptionHandlerAsm)

//
// VOID
// KdNmiHandlerAsm (
//     VOID
//     )
//

/*++

Routine Description:

    This routine is called directly when an NMI occurs.

Arguments:

    None. RIP, CS, RFLAGS, RSP, and SS have been pushed onto the stack by the
    processor, and NMIs run on their own stack.

Return Value:

    None.

--*/

FUNCTION(KdNmiHandlerAsm)
    pushq   $0                      # Push a dummy error code.
    call    ArGenerateTrapFrame     # Create a local trap frame.
    CFI_TRAP_FRAME_PUSHED           # Set unwind info for the debugger.
    movq    %rsp, %rdi              # 1st parameter is trap frame pointer.
    call    KeDispatchNmiTrap       # Call the main exception handler.
    call    ArRestoreTrapFrame      # Restore the trap frame
    CFI_TRAP_FRAME_POPPED           # Let the debugger know.
    iretq                           # Return from the exception.

END_FUNCTION(KdNmiHandlerAsm)

//
// VOID
// ArSingleStepExceptionHandlerAsm (
//     VOID
//     )
//

/*++

Routine Description:

    This routine is called directly when an debug exception occurs. It sets up
    the parameters and calls the executive to dispatch the trap.

Arguments:

    None. RIP, CS, RFLAGS, RSP, and SS have been pushed onto the stack by the
    processor, and the stack was 16-byte aligned before the pushes.

Return Value:

    None.

--*/

FUNCTION(ArSingleStepExceptionHandlerAsm)
    pushq   $0                      # Push a dummy error code.
    call    ArGenerateTrapFrame     # Create a local trap frame.
    CFI_TRAP_FRAME_PUSHED           # Set unwind info for the debugger.
    movq    %rsp, %rdi              # 1st parameter is trap frame pointer.
    call    KeDispatchSingleStepTrap  # Call the main exception handler.
    call    ArRestoreTrapFrame      # Restore the trap frame
    CFI_TRAP_FRAME_POPPED           # Let the debugger know.
    iretq                           # Return from the exception.

END_FUNCTION(ArSingleStepExceptionHandlerAsm)

//
// VOID
// KdDebugServiceHandlerAsm (
//     VOID
//     )
//

/*++

Routine Description:

    This routine is entered via an IDT entry to request debug service. It sets
    up the parameters and calls KdDebugExceptionHandler, and then restores
    machine state to return from the exception. The arguments to this function
    are pushed by the hardware. Upon Entry:

        rdi - Supplies the debug service request.

        rsi - Supplies the parameter to the request.

Arguments:

    None. RIP, CS, RFLAGS, RSP, and SS have been pushed onto the stack by the
    processor, and the stack was 16-byte aligned before the pushes.

Return Value:

    None.

--*/

FUNCTION(KdDebugServiceHandlerAsm)
    pushq   $0                      # Push a dummy error code.
    call    ArGenerateTrapFrame     # Create a local trap frame.
    CFI_TRAP_FRAME_PUSHED           # Set unwind info for the debugger.
    movq    %rsp, %rdi              # 1st parameter is trap frame pointer.
    call    KeDispatchDebugServiceTrap  # Call the main exception handler.
    call    ArRestoreTrapFrame      # Restore the trap frame
    CFI_TRAP_FRAME_POPPED           # Let the debugger know.
    iretq                           # Return from the exception.

END_FUNCTION(KdDebugServiceHandlerAsm)

//
// VOID
// ArDivideByZeroExceptionHandlerAsm (
//     VOID
//     )
//

/*++

Routine Description:

    This routine is called directly when a divide by zero exception occurs.

Arguments:

    None. RIP, CS, RFLAGS, RSP, and SS have been pushed onto the stack by the
    processor, and the stack was 16-byte aligned before the pushes.

Return Value:

    None.

--*/

FUNCTION(ArDivideByZeroExceptionHandlerAsm)
    pushq   $0                      # Push a dummy error code.
    call    ArGenerateTrapFrame     # Create a local trap frame.
    CFI_TRAP_FRAME_PUSHED           # Set unwind info for the debugger.
    movq    %rsp, %rdi              # 1st parameter is trap frame pointer.
    call    KeDispatchDivideByZeroTrap  # Call the main exception handler.
    call    ArRestoreTrapFrame      # Restore the trap frame
    CFI_TRAP_FRAME_POPPED           # Let the debugger know.
    iretq                           # Return from the exception.

END_FUNCTION(ArDivideByZeroExceptionHandlerAsm)

//
// VOID
// ArFpuAccessExceptionHandlerAsm (
//     VOID
//     )
//

/*++

Routine Description:

    This routine is called directly when floating point access occurs and the
    TS bit in CR0 is

Arguments:

    None. RIP, CS, RFLAGS, RSP, and SS have been pushed onto the stack by the
    processor, and the stack was 16-byte aligned before the pushes.

Return Value:

    None.

--*/

FUNCTION(ArFpuAccessExceptionHandlerAsm)
    pushq   $0                      # Push a dummy error code.
    call    ArGenerateTrapFrame     # Create a local trap frame.
    CFI_TRAP_FRAME_PUSHED           # Set unwind info for the debugger.
    movq    %rsp, %rdi              # 1st parameter is trap frame pointer.
    call    KeDispatchFpuAccessTrap # Call the main exception handler.
    call    ArRestoreTrapFrame      # Restore the trap frame
    CFI_TRAP_FRAME_POPPED           # Let the debugger know.
    iretq                           # Return from the exception.

END_FUNCTION(ArFpuAccessExceptionHandlerAsm)

//
// VOID
// ArDoubleFaultHandlerAsm (
//     VOID
//     )
//

/*++

Routine Description:

    This routine is entered via an IDT entry when a double fault exception
    occurs. Double faults are non-recoverable. This machine loops attempting
    to enter the debugger indefinitely.

Arguments:

    None. RIP, CS, RFLAGS, RSP, and SS have been pushed onto the stack by the
    processor, and the double fault handler runs on its own known-good stack.

Return Value:

    None, this routine does not return.

--*/

FUNCTION(ArDoubleFaultHandlerAsm)
    call    ArGenerateTrapFrame     # Create a local trap frame.
    CFI_TRAP_FRAME_PUSHED           # Set unwind info for the debugger.
    movq    %rsp, %rdi              # 1st parameter is trap frame pointer.
    call    ArpHandleDoubleFault    # Call the main exception handler.
    call    ArRestoreTrapFrame      # Restore the trap frame
    CFI_TRAP_FRAME_POPPED           # Let the debugger know.
    iretq                           # Return from the exception.

END_FUNCTION(ArDoubleFaultHandlerAsm)

//
// VOID
// ArProtectionFaultHandlerAsm (
//     VOID
//     )
//

/*++

Routine Description:

    This routine is called directly when a general protection fault occurs.
    It's job is to prepare the trap frame, call the appropriate handler, and
    then restore the trap frame.

Arguments:

    None. RIP, CS, RFLAGS, RSP, and SS have been pushed onto the stack by the
    processor, and the stack was 16-byte aligned before the pushes.

Return Value:

    None.

--*/

FUNCTION(ArProtectionFaultHandlerAsm)
    call    ArGenerateTrapFrame     # Create a local trap frame.
    CFI_TRAP_FRAME_PUSHED           # Set unwind info for the debugger.
    movq    %rsp, %rdi              # 1st parameter is trap frame pointer.
    call    KeDispatchProtectionFault    # Call the main exception handler.
    call    ArRestoreTrapFrame      # Restore the trap frame
    CFI_TRAP_FRAME_POPPED           # Let the debugger know.
    iretq                           # Return from the exception.

END_FUNCTION(ArProtectionFaultHandlerAsm)

//
// VOID
// ArMathFaultHandlerAsm (
//     VOID
//     )
//

/*++

Routine Description:

    This routine is called directly when a x87 FPU fault occurs.

Arguments:

    None. RIP, CS, RFLAGS, RSP, and SS have been pushed onto the stack by the
    processor, and the stack was 16-byte aligned before the pushes.

Return Value:

    None.

--*/

FUNCTION(ArMathFaultHandlerAsm)
    pushq   $0                      # Push a dummy error code.
    call    ArGenerateTrapFrame     # Create a local trap frame.
    CFI_TRAP_FRAME_PUSHED           # Set unwind info for the debugger.
    movq    %rsp, %rdi              # 1st parameter is trap frame pointer.
    call    KeDispatchMathFault     # Call the main exception handler.
    call    ArRestoreTrapFrame      # Restore the trap frame
    CFI_TRAP_FRAME_POPPED           # Let the debugger know.
    iretq                           # Return from the exception.

END_FUNCTION(ArMathFaultHandlerAsm)

//
// INTN
// ArSyscallHandlerAsm (
//     VOID
//     )
//

/*++

Routine Description:

    This routine is executed when user mode invokes the SYSCALL instruction.
    Upon entry, CS, SS, RIP, and RFLAGS are set to predefined values. Execution
    is still running on the user mode stack.

Arguments:

    None.

Return Value:

    STATUS_SUCCESS or positive integer on success.

    Error status code on failure.

--*/

FUNCTION(ArSyscallHandlerAsm)

    //
    // Switch to the kernel GS: base, and get onto the kernel stack (since rsp
    // is still the user mode one) as quickly as possible.
    //

    swapgs                          # Enable access to the PROCESSOR_BLOCK.
    movq    %rsp, %r10              # Save the user stack pointer in a volatile.
    movq    %gs:PROCESSOR_BLOCK_TSS, %rsp   # Get to the TSS from the processor.
    movq    TSS_RSP0(%rsp), %rsp    # Get to the kernel stack.
    sti                             # With a stack, it's safe for interrupts.

    //
    // Save a minimal amount of stuff in the trap frame, and let the debugger
    // know how to unwind from here.
    //

    subq    $(TRAP_FRAME_SIZE + 16), %rsp  # Allocate frame, bool (aligned).
    movq    %rcx, TRAP_RIP+16(%rsp) # Save the user RIP, saved by syscall.
    movq    %r11, TRAP_RFLAGS+16(%rsp) # Save RFLAGS, put there by syscall.
    movq    %r10, TRAP_RSP+16(%rsp) # Save the user RSP.
    movq    %rdi, TRAP_RDI+16(%rsp) # Save first parameter in case of restart.
    movq    %rsi, TRAP_RSI+16(%rsp) # Save second parameter in case of restart.
    CFI_DEF_CFA(%rsp, 16)
    CFI_OFFSET(%rip, TRAP_RIP)
    CFI_OFFSET(%rsp, TRAP_RSP)
    CFI_OFFSET(%rdi, TRAP_RDI)
    CFI_OFFSET(%rsi, TRAP_RSI)

    //
    // Move user DS (rather than user CS) into the trap frame to indicate
    // 1) this is a user mode trap frame and 2) it's incomplete.
    //

    movq    $USER_DS, TRAP_CS+16(%rsp)
    movq    %rsp, %rcx              # Move boolean to 4th parameter.
    leaq    16(%rsp), %rdx          # Move trap frame pointer to 3rd parameter.
    call    KeSystemCallHandler     # Call out to the handler.

    //
    // See if there is a signal pending, as reported by the signal handler
    // function. If there is, then save the full trap frame and attempt to
    // dispatch the signal. Note that the trap frame was allocated on the
    // kernel stack and may be copied out to user mode. Don't leak kernel stack
    // values.
    //

    popq    %rcx                    # Get the signal pending boolean.
    addq    $8, %rsp                # Pop the remaining alignment.
    CFI_ADJUST_CFA_OFFSET(-16)      # Tell the debugger about the pops.
    testl   %ecx, %ecx              # See if zero.
    jz      ArSyscallHandlerRestore # Exit quickly if no signal pending.

    //
    // See if the trap frame is already complete from being upgraded by the
    // system call itself. Avoid the save if so, as that might undo useful
    // work (like restoring pre-signal context).
    //

    cmpl    $USER_DS, TRAP_CS(%rsp) # Compare CS hint against non-full value.
    jne     ArSyscallFullRestore    # Go back and do a full restoration maybe.

    //
    // Perform a full trap frame save.
    //

    movq    $USER64_CS, TRAP_CS(%rsp)   # Indicate trap frame is complete.
    movq    %rax, TRAP_RAX(%rsp)    # Save RAX.
    movl    $USER_DS, %eax          # Get USER_DS in a register.
    movl    %eax, TRAP_SS(%rsp)     # Set SS.
    movl    %eax, TRAP_DS(%rsp)     # Set DS.
    movl    %eax, TRAP_ES(%rsp)     # Set ES.
    movl    %eax, TRAP_FS(%rsp)     # Set FS.
    movl    %eax, TRAP_GS(%rsp)     # Set GS.
    xorl    %eax, %eax              # Get a zero register.
    movq    %rax, TRAP_PADDING(%rsp)# Clear padding.
    movq    $USER64_CS, TRAP_CS(%rsp)   # Save CS, and indicate completeness.
    movq    %rax, TRAP_ERRORCODE(%rsp)  # Clear error code.
    movq    %r15, TRAP_R15(%rsp)    # Save R15.
    movq    %r14, TRAP_R14(%rsp)    # Save R14.
    movq    %r13, TRAP_R13(%rsp)    # Save R13.
    movq    %r12, TRAP_R12(%rsp)    # Save R12.
    movq    %rax, TRAP_R11(%rsp)    # Clear volatile R11.
    movq    %rax, TRAP_R10(%rsp)    # Clear volatile R10.
    movq    %rax, TRAP_RDX(%rsp)    # Clear volatile RDX.
    movq    %rax, TRAP_R9(%rsp)     # Clear volatile R9.
    movq    %rax, TRAP_R8(%rsp)     # Clear volatile R8.
    movq    %rbp, TRAP_RBP(%rsp)    # Save RBP.
    movq    %rax, TRAP_RCX(%rsp)    # Clear RCX.
    movq    %rbx, TRAP_RBX(%rsp)    # Save RBX.
    CFI_TRAP_FRAME_PUSHED           # Inform the unwinder of the full frame.

ArSyscallSignalDispatch:
    movq    %rsp, %rdi              # Set the trap frame as the first parameter.
    call    PsApplyPendingSignalsOrRestart # Dispatch signals or restart.

ArSyscallHandlerRestore:
    cmpl    $USER_DS, TRAP_CS(%rsp) # Compare CS hint against non-full value.
    jne     ArSyscallFullRestore    # Go back and do a full restoration maybe.

    //
    // Restore some portions of the pseudo trap frame. Do not zero RAX as it
    // holds the return value from the system call. Canonicalize the RIP to
    // avoid the infamous AMD sysret bug.
    //

    movq    TRAP_RIP(%rsp), %rcx    # Prepare rip in rcx for sysret.
    movq    $X64_CANONICAL_LOW, %rdx    # Load 64-bit immediate for AND.
    andq    %rdx, %rcx              # Canonicalize rip.
    movq    TRAP_RFLAGS(%rsp), %r11 # Prepare rflags in rcx for sysret.
    xorl    %edx, %edx              # Clear volatile to avoid leaking data.
    xorl    %esi, %esi              # Clear volatile.
    xorl    %r8d, %r8d              # Clear volatile.
    xorl    %r9d, %r9d              # Clear volatile.
    xorl    %r10d, %r10d            # Clear volatile.
    cli                             # Disable interrupts to go off-stack.
    movq    TRAP_RSP(%rsp), %rsp    # Restore user mode stack.
    swapgs                          # Go back to user land.
    sysretq                         # Return to user mode, slickly.

    //
    // The out of line code to do a full trap frame restore.
    //

ArSyscallFullRestore:
    call    ArRestoreTrapFrame      # Restore the full context.
    CFI_TRAP_FRAME_POPPED           # Let the debugger know.
    iretq                           # Jump out the old way.

END_FUNCTION(ArSyscallHandlerAsm)

//
// VOID
// ArpPageFaultHandlerAsm (
//     VOID
//     )
//

/*++

Routine Description:

    This routine is called directly when a page fault occurs.

Arguments:

    None. RIP, CS, RFLAGS, RSP, and SS have been pushed onto the stack by the
    processor, and the stack was 16-byte aligned before the pushes.

Return Value:

    None.

--*/

FUNCTION(ArpPageFaultHandlerAsm)
    call    ArGenerateTrapFrame     # Create a local trap frame.
    CFI_TRAP_FRAME_PUSHED           # Set unwind info for the debugger.
    xorl    %eax, %eax              # Zero a register.
    movq    %cr2, %rdi              # 1st parameter is faulting address.
    movq    %rax, %cr2              # Clear CR2.
    sti                             # Re-enable interrupts.
    movq    %rsp, %rsi              # 2nd parameter is trap frame pointer.
    call    KeDispatchPageFault     # Call the main exception handler.
    call    ArRestoreTrapFrame      # Restore the trap frame
    CFI_TRAP_FRAME_POPPED           # Let the debugger know.
    iretq                           # Return from the exception.

END_FUNCTION(ArpPageFaultHandlerAsm)

//
// VOID
// HlSpuriousInterruptHandlerAsm (
//     VOID
//     )
//

/*++

Routine Description:

    This routine handles spurious interrupts. It does not require an EOI or
    other interrupt acknowledgement.

Arguments:

    None. RIP, CS, RFLAGS, RSP, and SS have been pushed onto the stack by the
    processor, and the stack was 16-byte aligned before the pushes.

Return Value:

    None.

--*/

FUNCTION(HlSpuriousInterruptHandlerAsm)
    pushq   $0                      # Push a dummy error code.
    call    ArGenerateTrapFrame     # Create a local trap frame.
    CFI_TRAP_FRAME_PUSHED           # Set unwind info for the debugger.
    leaq HlSpuriousInterruptCount@GOTPCREL(%rip), %rax
    lock addl   $1, (%rax)          # Count interrupts
    call    ArRestoreTrapFrame      # Restore the trap frame
    CFI_TRAP_FRAME_POPPED           # Let the debugger know.
    iretq                           # Return from the exception.

END_FUNCTION(HlSpuriousInterruptHandlerAsm)

//
// VOID
// ArRestoreTrapFrame (
//     PTRAP_FRAME TrapFrame
//     )
//

/*++

Routine Description:

    This routine restores information contained in a trap frame to the
    processor and prepares the machine for an iretq back to the code that
    generated this trap frame. It's not really a function because it assumes
    a specific stack layout and modifies data that technically belongs to the
    caller. It should only be called immediately before returning from an
    exception or interrupt.

Arguments:

    TrapFrame - Supplies the trap frame to restore, at the top of the stack.

Return Value:

    Upon return, the trap frame will have been popped off the stack, and the
    machine will be in the same state as right after the exception happened.

--*/

FUNCTION(ArRestoreTrapFrame)
    popq    %rax                            # Pop return address.
    movq    %rax, TRAP_ERRORCODE(%rsp)      # Save into convenient return slot.
    movl    TRAP_DS(%rsp), %ecx             # Restore ds.
    movw    %cx, %ds                        #
    movl    TRAP_ES(%rsp), %ecx             # Restore es.
    movw    %cx, %es                        #
    movq    TRAP_RAX(%rsp), %rax            # Restore general registers.
    movq    TRAP_RBX(%rsp), %rbx            #
    movq    TRAP_RCX(%rsp), %rcx            #
    movq    TRAP_RDX(%rsp), %rdx            #
    movq    TRAP_RSI(%rsp), %rsi            #
    movq    TRAP_RDI(%rsp), %rdi            #
    movq    TRAP_RBP(%rsp), %rbp            #
    movq    TRAP_R8(%rsp), %r8              #
    movq    TRAP_R9(%rsp), %r9              #
    movq    TRAP_R10(%rsp), %r10            #
    movq    TRAP_R11(%rsp), %r11            #
    movq    TRAP_R12(%rsp), %r12            #
    movq    TRAP_R13(%rsp), %r13            #
    movq    TRAP_R14(%rsp), %r14            #
    movl    TRAP_CS(%rsp), %r15d            # Get CS.
    cli                                     # Disable interrupts for user GS.
    andl    $SEGMENT_PRIVILEGE_MASK, %r15d  # Get Privilege level.
    jz      RestoreTrapFrameReturn          # Jump over swapgs if kernel mode.
    swapgs                                  # Swap back to user GS segment.

RestoreTrapFrameReturn:
    movq    TRAP_R15(%rsp), %r15            #
    addq    $TRAP_ERRORCODE, %rsp           # Pop off non-hardware portion.
    ret                                     # Pop error code to return.

END_FUNCTION(ArRestoreTrapFrame)

//
// --------------------------------------------------------- Internal Functions
//

//
// This macro stamps out the assembly dispatch code necessary for interrupts
// received at each vector. It will create code for all vectors between
// MinimumVector and MaximumVector.
//

.macro InterruptVector _Vector

    //
    // 0x6A xx is the instruction for push imm8, except the immediate is sign
    // extended. The assembler will use the longer form for numbers >= 0x80
    // since those should not be sign extended. Use the shorter form directly
    // here to save space, and deal with it using a cast in the C code.
    //

    .byte   0x6A
    .byte   (\_Vector)
    jmp     KeInterruptEntry

.endm

.macro InterruptVectors16 _Vector
    InterruptVector (\_Vector)
    InterruptVector (\_Vector + 1)
    InterruptVector (\_Vector + 2)
    InterruptVector (\_Vector + 3)
    InterruptVector (\_Vector + 4)
    InterruptVector (\_Vector + 5)
    InterruptVector (\_Vector + 6)
    InterruptVector (\_Vector + 7)
    InterruptVector (\_Vector + 8)
    InterruptVector (\_Vector + 9)
    InterruptVector (\_Vector + 10)
    InterruptVector (\_Vector + 11)
    InterruptVector (\_Vector + 12)
    InterruptVector (\_Vector + 13)
    InterruptVector (\_Vector + 14)
    InterruptVector (\_Vector + 15)

.endm

//
// Now actually instantiate the macro to create the vector code.
//

HlVectorStart:

InterruptVectors16 0x30
InterruptVectors16 0x40
InterruptVectors16 0x50
InterruptVectors16 0x60
InterruptVectors16 0x70
InterruptVectors16 0x80
InterruptVectors16 0x90
InterruptVectors16 0xA0
InterruptVectors16 0xB0
InterruptVectors16 0xC0
InterruptVectors16 0xD0
InterruptVectors16 0xE0
InterruptVectors16 0xF0

HlVectorEnd:

//
// TRAP_FRAME
// ArGenerateTrapFrame (
//     ULONGLONG ErrorCode,
//     ULONGLONG ReturnRip,
//     ULONGLONG ReturnCs,
//     ULONGLONG ReturnRflags,
//     ULONGLONG ReturnRsp,
//     ULONGLONG ReturnSs
//     )
//

/*++

Routine Description:

    This routine generates a trap frame based on the data pushed onto the
    stack by the processor after an exception. It is not really a function
    in that it assumes a certain stack layout and will modify data that
    belongs to the caller. This function should only be called immediately
    after an interrupt/exception.

Arguments:

    ErrorCode - Supplies the error code that generated the fault, or a dummy
        error code should be pushed if this was not an exception where the
        hardware would push it.

    ReturnRip - Supplies the instruction that generated the exception.

    ReturnCs - Supplies the code selector of the code that generated the
        exception.

    ReturnRflags - Supplies the flags of the code that generated the
        exception.

    ReturnRsp - Supplies the stack pointer of the code that generated the
        exception.

    ReturnSs - Supplies the stack segment of the code that generated the
        exception.

Return Value:

    Upon return, a TRAP_FRAME will be on the top of the stack.

--*/

FUNCTION(ArGenerateTrapFrame)

    //
    // Allocate room on the stack for the trap frame, minus the original
    // return address, minus the fields that have already been pushed by
    // hardware.
    //

    subq    $TRAP_R15, %rsp             # Allocate remaining trap frame space.
    movq    %rax, TRAP_RAX(%rsp)        # Save RAX to free it up.
    movq    TRAP_R15(%rsp), %rax        # Get the return address.
    movq    %rbx, TRAP_RBX(%rsp)        # Save the general registers.
    movq    %rcx, TRAP_RCX(%rsp)        #
    movq    %rdx, TRAP_RDX(%rsp)        #
    movq    %rsi, TRAP_RSI(%rsp)        #
    movq    %rdi, TRAP_RDI(%rsp)        #
    movq    %rbp, TRAP_RBP(%rsp)        #
    movq    %r8, TRAP_R8(%rsp)          #
    movq    %r9, TRAP_R9(%rsp)          #
    movq    %r10, TRAP_R10(%rsp)        #
    movq    %r11, TRAP_R11(%rsp)        #
    movq    %r12, TRAP_R12(%rsp)        #
    movq    %r13, TRAP_R13(%rsp)        #
    movq    %r14, TRAP_R14(%rsp)        #
    movq    %r15, TRAP_R15(%rsp)        #
    movq    %ds, %rcx                   #
    movl    %ecx, TRAP_DS(%rsp)         # Save DS.
    movq    %es, %rcx                   #
    movl    %ecx, TRAP_ES(%rsp)         # Save ES.
    movq    %fs, %rcx                   #
    movl    %ecx, TRAP_FS(%rsp)         # Save FS.
    movq    %gs, %rcx                   #
    movl    %ecx, TRAP_GS(%rsp)         # Save GS.

    //
    // Determine if the exception came from user mode. If so, swap the GS base.
    // to get the processor block back.
    //

    movl    TRAP_CS(%rsp), %ecx         # Get CS.
    andl    $SEGMENT_PRIVILEGE_MASK, %ecx   # Mask off the privilege.
    jz      GenerateTrapFrameReturn     # Return if zero.
    swapgs                              # Swap GS segment if from user mode.

GenerateTrapFrameReturn:
    jmp     *%rax                       # Return

END_FUNCTION(ArGenerateTrapFrame)

//
// Define the common interrupt entry code. At this point the vector number has
// been pushed into the error code slot, but nothing else has been done. Note
// that this code needs to be far enough away from the vectors themselves so
// that none of the jumps in the vectors turn into shorter instructions
// (distance >= 0x100).
//

FUNCTION(KeInterruptEntry)
    call    ArGenerateTrapFrame     # Create a local trap frame.
    CFI_TRAP_FRAME_PUSHED           # Set unwind info for the debugger.
    movq    %rsp, %rdi              # 1st parameter is trap frame pointer.
    call    KeDispatchInterrupt     # Call the main exception handler.
    call    ArRestoreTrapFrame      # Restore the trap frame
    CFI_TRAP_FRAME_POPPED           # Let the debugger know.
    iretq                           # Return from the exception.

END_FUNCTION(KeInterruptEntry)

