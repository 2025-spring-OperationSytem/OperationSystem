	.text

	/*
         * save the old thread's registers,
         * restore the new thread's registers.
         */
    .text
    .globl thread_switch
thread_switch:
    // 레지스터 저장
    pushal

    // eax에 current_thread 저장
    // esp에 바로 못넘김
    movl current_thread, %eax
    // current_thread = esp
    // esp에는 전에 저장해놨던 thread의 주소가 있음
    movl %esp, (%eax)

    // 다음 실행할 쓰레드 저장 eax에 담아서 esp에 저장
    movl next_thread, %eax
    movl (%eax), %esp

    // current_thread = next_thread
    movl %eax, current_thread

    // 레지스터 복구
    popal

    // next_thread = 0
    movl $0, next_thread
    
    // 다시 원래 실행하던 곳으로 점프
    // esp에 next_thread주소를 넣고 current_thread와 next_thread를 바꿔놓았기 때문에
    // contextSwitching이 된 상태로 돌아간다.
    ret   
