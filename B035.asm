#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

#CS=0000h#
#IP=0000h#

#DS=0000h#
#ES=0000h#

#SS=0000h#
#SP=FFFEh#

#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#


;assigning address for ports of first 8255
porta1 equ 00h
portb1 equ 02h
portc1 equ 04h
creg1  equ 06h

;assigning address for ports of second 8255
porta2 equ 08h
portb2 equ 0ah
portc2 equ 0ch
creg2  equ 0eh


     
   ; add your code here

         jmp     st1 
         db     5 dup(0)

;IVT entry for NMI H
         
         dw     nmi_isr
         dw     0000
         db     1012 dup(0)
     
		st1:   

		mov ax,0200h
		mov ds,ax
		mov es,ax
		mov ss,ax

		mov sp,0FFFEH
           mov al,81h
		out creg2,al    ;porta2,portb2,portc2upper as output, portc2 lower as input
 
          mov al,00001000b
          out creg2,al
          

   x100:jmp x100
			
	
nmi_isr:		mov ax,996
		mov [0020h],ax  ;li8 wala part multiply by .996
		mov bx,0022h

		mov al,91h 		
		out creg1,al
		


	 
        mov al,00000000b
        out portb1,al
	 

	
		mov al,00001110b  	
		out creg1,al
		nop
		nop
		nop
		mov al,00001011b
		out creg1,al		   
		           
		
		mov al,00001111b  	;DOUBT CLOCK CYCLE-----DOUBT CLOCK CYCLE
		out creg1,al
          
		
		mov al,00001010b
		out creg1,al		
	                 
		mov al,00001110b	
		out creg1,al
                    
           lol: in al,portc2
                and al,00000001b
                jz lol
                mov al,00001011b
                out creg2,al
                
                
         
	
		     
			                
        mov al,91h 		
    	out creg1,al
        
        in al,porta1
    	mov [bx],al   	 
    	
		                 mov al,00001010b
                out creg2,al



        mov al,91h 		
    	out creg1,al

        mov al,00000001b
        out portb1,al
		 		 
    	mov al,00001110b  	;soc 0
		out creg1,al
          
		
		mov al,00001011b
		out creg1,al		; ale 0  
		           
		
		mov al,00001111b  	; soc 1
		out creg1,al
          
		
		mov al,00001010b
		out creg1,al		;0 ale
	                 
		mov al,00001110b	 
		out creg1,al
 

         
	           lol1: in al,portc2
                and al,00000001b
                jz lol1
                mov al,00001011b
                out creg2,al         		                
        mov al,91h 		
        out creg1,al
        
        in al,porta1
    	mov [bx+1],al  
    	       mov al,00001010b
                out creg2,al
		   
	  


        mov al,91h 		
		out creg1,al

        mov al,00000010b
        out portb1,al
		 		 

    	mov al,00001110b  	;soc  0
		out creg1,al
          
		
		mov al,00001011b
		out creg1,al		;ale 1  
		           
		
		mov al,00001111b  	; soc  1
		out creg1,al
          
		
		mov al,00001010b
		out creg1,al		; ale
	                 
		mov al,00001110b	 ;soc  0
		out creg1,al
                   
		          
             
            lol2: in al,portc2
                and al,00000001b
                jz lol2
                mov al,00001011b
                out creg2,al
			                
        mov al,91h 		
	    out creg1,al
        
	    in al,porta1
    	mov [bx+2],al  
    	
		       mov al,00001010b
                out creg2,al

		 

	  
		mov ax,[0020h]	 
		mov ch,0
		mov cl,[bx] 	              
		mul cx 			 

		mov cx,1000
		div cx 			 
		mov [0030h],ax
		mov [0032h],dx   

; other two load cells

		mov ax,[0020h]   
		mov ch,0
		mov cl,[bx+1] 
		mul cx        
		mov cx,1000
		div cx           ;dividing by 1000 to get the weight
		mov [0034h],ax

		mov [0036h],dx   ;moving the result back to memory


		mov ax,[0020h]  
		mov ch,0
		mov cl,[bx+2]   
		mul cx          
		mov cx,1000
		div cx          ;dividing by 1000 to get the weight
	
		mov [0038h],ax
		mov [0040h],dx   

		mov bx,[0030h]
		add bx,[0034h]
		add bx,[0038h]   

	
		mov ax,[0032h]
		add ax,[0036h]
		add ax,[0040h]   

		mov dx,0
		mov cx,1000
		div cx  	    
		add bx,ax 	  						;overall remainder is in dx 
       
		mov [0054h],dx ;moving remainder
		
		mov cl,3
		mov ax,bx
		div cl		   

		mov [0050h],ax 	  
		
		mov cx,1000 
		mov al,ah
		mov ah,0
		mul cx			;multiplying remainder of division of quotient of weight when divided by 3--- with 1000
  
        add ax,[0054h]
      
		mov cx,3    
		mov dx,0
        div cx

       
		mov dx,ax        
		mov cl,[0050h]
		mov ch,0
  
		mov bx,cx		
		        
		cmp bx,0063h 	
		jb calculate
		
		cmp bx,0063h
		ja alarm
		
		cmp dx,0000h
		je calculate
alarm:	mov al,00001001b
		out creg2,al	  ; alarm		
		jmp alarm

calculate:
		mov ax,bx
		mov bh,0ah 		 
		div bh 			 
						 
		mov [0040h],al   
		mov [0042h],ah   

;extracting the digits from decimal 
		mov si,0048h
		mov ax,dx
		mov cx,3
		mov bx,000ah ;moving decimal value 10 into bh
		
x1:		mov dx,0
		div bx
		mov [si],dl
		dec si     
		dec si
		loop x1


;starting the display process
refresh:
		mov al,00001110b    ;port a as output c upper as input portb mode1 port b as input port c lower as output
		out creg2,al
		


;display the first digit
				
		mov al,81h			;bsr pc0 set
		out creg2,al    

		
		mov al,[0040h]  ;moving the first digit to al	
		out porta2,al 	;moving the first digit into the port
            			;A of 8255(2) which is connected to 7447

		
		mov al,00000001b
		out portb2,al		;value is made displayed on first led


        call delay1
        
        mov al,00000000b
		out portb2,al	
;display the second digit
               
              
               
		mov al,[0042h]  ;moving the second digit to al
		out porta2,al 	;moving the second digit into the port
						;A of 8255(2) which is connected to 7447


		mov al,00000010b
		out portb2,al		;value is made displayed on second led
    

     call delay1
        
        
        mov al,00000000b
		out portb2,al	         
;display the first decimal digit
            
               
               
		mov al,[0044h]  ;moving the first decimal digit to al
		out porta2,al	;moving the first decimal into the port
						;A of 8255(2) which is connected to 7447
		
		mov al,00000100b
		out portb2,al		;value is made displayed on third led
		
           call delay1 
       
        mov al,00000000b
		out portb2,al	           
         
           
;display the second decimal digit
     

     
		mov al,[0046h]  ;moving the second decimal digit to al
		out porta2, al 	;moving the first digit into the port

						;A of 8255(2) which is connected to 7447
		mov al,00001000b
		out portb2,al		;value is made displayed on fourth led
	    
             call delay1
        
        mov al,00000000b
		out portb2,al	
	 
;display the third decimal digit
                 
         
		mov al,[0048h]  ;moving the third decimal digit to al
		out porta2, al 	;moving the third digit into the port
						;A of 8255(2) which is connected to 7447

		mov al,00010000b
		out portb2,al		;value is made displayed on fifth led
		
        call delay1
      
         mov al,00000000b
		out portb2,al	
		jmp refresh




delay1    proc   near 
          
          push cx 
          mov cx,1
      ps1: nop 
          loop ps1 
          pop cx 
          ret 
delay1    endp         
iret