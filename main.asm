.MODEL SMALL
.STACK 100H
.DATA

gametitle db "<** Guess the Number Game **>$"
playmsg db "Play the game? (Y/N): $"
startmsg db "Guess a number between 1 and 100 <H=Hint> (Q=Quit): $"
highmsg db "------>>> Too High...[Try a smaller number]$"
lowmsg db "------>>> Too Low...[Try a larger number]$"
evenstr db "------>>> The number is Even$"
oddstr db "------>>> The number is Odd$"
div5msg db "------>>> The number is divisible by 5$"
notdiv5msg db "----->>> The number is not divisible by 5$"
div3msg db "------>>> The number is divisible by 3$"
notdiv3msg db "----->>> The number is not divisible by 3$"
div7msg db "------>>> The number is divisible by 7$"
notdiv7msg db "----->>> The number is not divisible by 7$"
hintoverstr db "--->> All the hints are over!$"
hintstr db "---->> Use the hint wisely <<----$"
badinmsg db "Entry must be number from 1-100 (Q=Quit)$"
rightguess db "--->> Congratulation!! You guessed it right! <<---$" 

maxlen db 4
strlen db 0
inbuf db 5 dup('$')
randnum db 0
usernum db 0
placevals db 1,10,100
quitflag db 0
hintctr db 0

.CODE
    MAIN PROC
    MOV AX,@DATA
    MOV DS,AX 

    ;code here  
    mov ah, 9
    mov dx, offset gametitle
    int 21h

    mov dl,0dh
    mov ah,2
    int 21h
    mov dl,0ah 
    int 21h

    
    mainloop:
    mov ax,0
    mov bx,0
    mov cx,0
    mov dx,0
    mov hintctr,al
    
    mov dl,0dh
    mov ah,2
    int 21h
    mov dl,0ah 
    int 21h
        
    mov ah, 9
    mov dx, offset playmsg
    int 21h
    mov ah, 1
    int 21h
    cmp al, 'y'
    je cont1
    cmp al, 'Y'
    je cont1
    jmp terminate
      
    cont1:
    call getrand
      
    cont2:
    call getguess 
    call process
    jc cont2  
    cmp quitflag, 1  
    je terminate
    
       
    call chkguess
    jc cont2      
    jmp mainloop
    
    
    terminate:
    mov ax, 4C00h            
    int 21h
  
    MAIN ENDP  
    
;-------------------------------------------------------------

  getrand proc
    mov ah, 2Ch     ;get system time from BIOS
    int 21h
    
    mov ax, 0           
    add al, ch      ;add hour
    add al, cl      ;add minute
    add al, dh      ;add second to it
    add al, dl      ;add hundredths of second
                    
    mov cx, 100    
    div cl        
                   ;remainder is 0 to 99
    inc ah         ; 1 to 100
                   
    mov randnum, ah
  ret            
getrand endp

;-------------------------------------------------------------

getguess proc
    
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  
  mov ah, 9
  mov dx, offset startmsg
  int 21h

  mov ah, 0Ah
  mov dx, offset maxlen
  int 21h

  ret
getguess endp

;-------------------------------------------------------------

process proc
  mov ax, 0         
  mov usernum, al   
  mov si,0          
  mov cx,0            
  mov cl, strlen    
  mov bx, offset strlen     
  mov di, offset placevals 

pro1:
  mov dx,0          
  mov si, cx        ;strlen into SI
  mov dl, [bx + si] ;place ASCII digit into DL
  cmp dl, 30h      ;not number/latter 
  jb pro2           
  cmp dl, 39h      ;letter
  ja pro3           

pro4:
  sub dl,30h       
  mov al,[di]      ;get place value into AL
  mul dl            ; dl x al result in AX
  add usernum, al   
  inc di            
  loop pro1        
  mov al, usernum   
  cmp al, 100       
  ja pro2           
  clc               
  jmp proexit       ;and exit the proc

pro2:
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h  
  
  mov ah, 9
  mov dx, offset badinmsg
  int 21h
  stc 
  
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
               
  jmp proexit
  
pro3:
  cmp dl, 'q'      
  je pro5
  cmp dl, 'Q'     
  je pro5
  cmp dl, 'h'
  je hint
  cmp dl, 'H'
  je hint
  jmp pro2         

pro5:
  clc
  inc quitflag      
  jmp proexit
  
hint:
  mov ch,dl
  inc hintctr
  cmp hintctr,1
  je hint1
  cmp hintctr,2
  je hint2
  cmp hintctr,3
  je hint3
  cmp hintctr,4
  je hint4
  cmp hintctr,5
  jge hintover
;****************************  
hint1:
  mov al,randnum
  test al,1
  jz evenmsg
  jmp oddmsg
  
evenmsg:

  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  
  mov ah, 9         
  mov dx, offset evenstr
  int 21h

  
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  
  jmp proexit
  
oddmsg:

  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  
  mov ah, 9        
  mov dx, offset oddstr
  int 21h

  
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  
  jmp proexit

;****************************
 
hint2:
  mov al,randnum
  mov ah,0
  mov cl,5
  div cl
  
  cmp ah,0
  jz divby5
  jmp notdivby5
  
divby5:
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  
  mov ah, 9         
  mov dx, offset div5msg
  int 21h

  
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  
  jmp proexit
  
notdivby5:
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  
  mov ah, 9        
  mov dx, offset notdiv5msg
  int 21h

  
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  jmp proexit

;****************************

hint3:
  mov al,randnum
  mov ah,0
  mov cl,3
  div cl
  
  cmp ah,0
  jz divby3
  jmp notdivby3
  
divby3:
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  
  mov ah, 9         
  mov dx, offset div3msg
  int 21h

  
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  
  jmp proexit
  
notdivby3:
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  
  mov ah, 9        
  mov dx, offset notdiv3msg
  int 21h

  
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  jmp proexit
  
;****************************

hint4:
  mov al,randnum
  mov ah,0
  mov cl,7
  div cl
  
  cmp ah,0
  jz divby7
  jmp notdivby7
  
divby7:
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  
  mov ah, 9         
  mov dx, offset div7msg
  int 21h

  
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  
  jmp proexit
  
notdivby7:
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  
  mov ah, 9        
  mov dx, offset notdiv7msg
  int 21h

  
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  jmp proexit

;****************************

hintover: 
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  
  mov ah, 9         
  mov dx, offset hintoverstr
  int 21h

  
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  
  jmp proexit  

proexit:
  ret

process endp

;-------------------------------------------------------------

chkguess proc
  cmp ch,'h'
  je hintmsg
  cmp ch,'H'
  je hintmsg 
  
  
  mov al, randnum  
  cmp usernum, al 
  jl toolow         
  jg toohigh 
  
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  
  mov ah, 9
  mov dx, offset rightguess
  int 21h
  clc
  
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h  
  
  jmp chkgexit


toolow:

  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  
  mov ah, 9
  mov dx, offset lowmsg
  int 21h
  stc           
  
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h 
  
  jmp chkgexit


toohigh:

  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  
  mov ah, 9        
  mov dx, offset highmsg
  int 21h
  stc           
  
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h
  jmp chkgexit

hintmsg:
  mov ah, 9         
  mov dx, offset hintstr
  int 21h
  stc             
  
  mov dl,0dh
  mov ah,2
  int 21h
  mov dl,0ah 
  int 21h

                   
chkgexit:
  ret

    chkguess ENDP
END MAIN
