	.text

	/*
         * save the old thread's registers,
         * restore the new thread's registers.
         */
    .text
    .globl thread_switch
thread_switch:

    pushal

    movl current_thread, %eax
    movl %esp, (%eax)

    movl next_thread, %eax
    movl (%eax), %esp
    # esp = t1.주소

    movl %eax, current_thread

    // 레지스터 복구
    popal

    movl $0, next_thread
    
    ret   # 스택 상의 리턴 주소(=스레드 진입 지점)로 점프