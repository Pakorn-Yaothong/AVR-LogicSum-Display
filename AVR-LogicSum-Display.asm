.include "m328pdef.inc"   ; ไฟล์ header สำหรับ ATmega328P
.device ATMEGA328P       ; กำหนดอุปกรณ์เป็น ATmega328P

.def TMP1 = R16         ; รีจิสเตอร์ชั่วคราว 1
.def TMP2 = R17         ; รีจิสเตอร์ชั่วคราว 2
.def LSEG_0 = R18        ; เก็บค่าที่จะแสดงผลบน 7-segment หลักหน่วย
.def LSEG_1 = R19        ; เก็บค่าที่จะแสดงผลบน 7-segment หลักสิบ
.def INPUT_COUNT = R20  ; เก็บค่าจำนวนอินพุตที่ On อยู่
.def TOTALHIGH_COUNT = R21 ; เก็บค่าจำนวนวงจรที่ On อยู่ เพิ่มขึ้นทีละ 1
.def VAR_I = R22        ; ตัวแปรนับค่าจาก Dip Switch
.def ZERO = R23         ; ค่า 0 ที่ใช้ในการคำนวณ
.def TOTAL = R24        ; ผลรวมของการนับทั้งหมด
.def STATE = R25        ; สถานะของ Interrupt

.cseg                   ; กำหนดเซกเมนต์ของโค้ด
.org 0x0000             ; กำหนดจุดเริ่มต้นของโปรแกรม
rjmp start              ; ข้ามไปที่ label 'start'

.org 0x0002             ; เวกเตอร์ของ Interrupt
rjmp triggered          ; ไปที่ฟังก์ชัน Interrupt

start:
    ldi TMP1, 0x00      ; โหลดค่า 0x00 ไปยัง TMP1
    out DDRC, TMP1      ; กำหนด PORTC เป็นอินพุตทั้งหมด
    ldi TMP1, 0b01111011 ; ตั้งค่าให้ขา PORTD เป็นเอาต์พุต ยกเว้น PORTD2
    out DDRD, TMP1      ; บันทึกค่าลง PORTD
	ldi TMP1, 0b00110000 ; ***
	out DDRB, TMP1      ; ***
    clr ZERO            ; กำหนดค่า ZERO เป็น 0

    ldi TMP1, 0x01      ; โหลดค่า 0x01 ไปยัง TMP1
    out EIMSK, TMP1     ; เปิดใช้งาน Interrupt INT0
    sei                 ; เปืดใช้งาน Interrupt 

MAIN:
    rcall HIGH_NUMBER   ; อ่านค่าจาก Dip Switch 
    ldi STATE, 0x00     ; Clear สถานะ Interrupt

MPLY_LOOP:
    cpi TOTAL, 100      ; ตรวจสอบว่า TOTAL มากกว่าหรือเท่ากับ 100 หรือไม่
    brge CLEAR_TOTAL    ; ถ้าใช่ ให้ไปที่ฟังก์ชัน CLEAR_TOTAL
    rcall OUTPUT_SEP    ; แสดงผลค่าที่ได้
    cpi STATE, 0x01     ; ตรวจสอบว่า Interrupt ถูกเรียกใช้หรือไม่
    breq MAIN           ; ถ้าใช่ กลับไปที่ MAIN
    add TOTAL, TOTALHIGH_COUNT ; เพิ่มค่าจำนวนวงจรที่เปิดอยู่เข้าไปใน TOTAL
    rjmp MPLY_LOOP      ; วนลูปต่อไป

CLEAR_TOTAL:
    ldi TOTAL, 0        ; รีเซ็ตค่า TOTAL เป็น 0
    rjmp MPLY_LOOP      ; กลับไปที่ลูปหลัก

triggered:              ; เมื่อ Dip Switch เปลี่ยนค่า ให้ตั้งค่า STATE เป็น 0x01
    ldi STATE, 0x01     ; กำหนดสถานะของ Interrupt
    reti                ; กลับจากการใช้ Subroutine Interrupt

DELAY10MS:
    push R16            ; บันทึกค่า R16 ลงใน Stack
    push R17            ; บันทึกค่า R17 ลงใน Stack
    ldi R16, 0x00       ; ตั้งค่า R16 เป็น 0
LOOP2:
    inc R16             ; เพิ่มค่า R16 ทีละ 1
    ldi R17, 0x00       ; ตั้งค่า R17 เป็น 0 
LOOP1:
    inc R17             ; เพิ่มค่า R17 ทีละ 1
    cpi R17, 249        ; ตรวจสอบว่า R17 เท่ากับ 249 หรือไม่
    brlo LOOP1          ; ถ้าไม่ ให้วนลูปต่อไป
    nop                 ; คำสั่งหน่วงเวลา
    cpi R16, 160        ; ตรวจสอบว่า R16 เท่ากับ 160 หรือไม่
    brlo LOOP2          ; ถ้าไม่ ให้วนลูปต่อไป
    pop R17             ; ดึงค่า R17 กลับจาก Stack
    pop R16             ; ดึงค่า R16 กลับจาก Stack
    ret                 ; ออกจากฟังก์ชันหน่วงเวลา

DELAY_50MS:
    ldi R16, 50         ; ตั้งค่าจำนวนรอบสำหรับหน่วงเวลา 50ms

delay_loop_50:
    rcall DELAY10MS     ; เรียกใช้ฟังก์ชันหน่วงเวลา 10ms
    dec R16             ; ลดค่า R16 ลง 1
    brne delay_loop_50  ; ถ้ายังไม่ถึง 50ms ให้วนลูปต่อ
    ret                 ; ออกจากฟังก์ชันหน่วงเวลา

HIGH_NUMBER:					 ; นับสวิตช์ที่ On
    in INPUT_COUNT, PINC		 ; อ่านค่าจาก PORTC
    andi INPUT_COUNT, 0b00111111 ; จำกัดค่าที่อ่านได้ให้อยู่ในช่วง 0-5 ของ PORTC
    ldi VAR_I, 0x00				 ; กำหนดค่าเริ่มต้นให้ VAR_I มีค่าเป็น 0
    ldi TOTALHIGH_COUNT, 0x00		 ; กำหนดค่าเริ่มต้นให้ TOTALHIGH_COUNT มีค่าเป็น 0 
FOR:
    cpi VAR_I, 8				 ; ตรวจสอบว่า VAR_I ถึง 8 หรือไม่
    brlo F_LOOP					 ; ถ้า No ให้ทำต่อไป
    rjmp ENDLOOP				 ; ถ้า Yes ให้จบลูป
F_LOOP:
    rol INPUT_COUNT				 ; หมุนบิตของ INPUT_COUNT
    adc TOTALHIGH_COUNT, ZERO		 ; เพิ่มค่า TOTALHIGH_COUNT ตามค่าที่อ่านได้
    inc VAR_I					 ; เพิ่มค่า VAR_I
    rjmp FOR					 ; กลับไปที่ลูป
ENDLOOP:
    ret							 ; ออกจากฟังก์ชัน

OUTPUT_SEP:
    mov LSEG_0, TOTAL		 ; คัดลอกค่า TOTAL ไปที่ LSEG_0
    ldi LSEG_1, 0			 ; ตั้งค่า LSEG_1 เป็นศูนย์
OUTPUT_SEP_LOOP:
    cpi LSEG_0, 10			 ; ตรวจสอบว่า LSEG_0 มากกว่าหรือเท่ากับ 10 หรือไม่
    brlo OUTPUT_SEP_PRINT    ; ถ้าน้อยกว่า ให้ไปแสดงผล
    subi LSEG_0, 10			 ; ลบค่า 10 ออกจาก LSEG_0
    inc LSEG_1				 ; เพิ่มค่า LSEG_1
    rjmp OUTPUT_SEP_LOOP	 ; กลับไปที่ลูป
OUTPUT_SEP_PRINT:
    mov TMP2, LSEG_1			 ; คัดลอกค่า LSEG_1 ไปที่ TMP2
    lsl TMP2
    lsl TMP2
    lsl TMP2				 ; เลื่อนบิตซ้าย 3 ครั้ง
    //ori TMP2, 0b00000010	 ; เพิ่มบิต 2
    out PORTD, TMP2			 ; ส่งค่าไปที่ PORTD
	ldi TMP2, 0b00100000     ; ***
	out PORTB, TMP2          ; ***
    rcall DELAY_100MS		 ; หน่วงเวลา

    mov TMP2, LSEG_0			 ; คัดลอกค่า LSEG_0 ไปที่ TMP2
    lsl TMP2				 ; เลื่อนบิตไปท้ายซ้าย 1 ตําแหน่ง
    lsl TMP2				 ; เลื่อนบิตไปท้ายซ้าย 1 ตําแหน่ง
    lsl TMP2				 ; เลื่อนบิตไปท้ายซ้าย 1 ตําแหน่ง (รวมแล้วเลื่อนไป 3 ตําแหน่ง)
    //ori TMP2, 0b00000001	 ; เพิ่มบิต 1
    out PORTD, TMP2			 ; ส่งค่าไปที่ PORTD0
	ldi TMP2, 0b00010000     ; ***
	out PORTB, TMP2          ; ***
    rcall DELAY_50MS		 ; หน่วงเวลา 50ms

    ret						 ; ออกจากการใช้ Subroutine 