bits 32
; Author: Plaskon Pavol, xplask00 AT stud.fit.vutbr.cz
; Course: Advanced assembly languages
; Date:   18. 12. 2015   
;********************************************************************
; Included files
%include 'opengl.inc'
%include 'win32.inc'
%include 'general.inc'
;********************************************************************
;kernel32.dll functions
win32fn GetModuleHandle, kernel32.dll, GetModuleHandleA
win32fn GetCommandLine, kernel32.dll, GetCommandLineA
win32fn ExitProcess, kernel32.dll
win32fn GetTickCount, kernel32.dll
win32fn QueryPerformanceCounter, kernel32.dll
win32fn QueryPerformanceFrequency, kernel32.dll
win32fn Sleep, kernel32.dll
;********************************************************************
; user32.dll functions 
win32fn ShowWindow, user32.dll
win32fn UpdateWindow, user32.dll
win32fn TranslateMessage, user32.dll
win32fn RegisterClassEx, user32.dll, RegisterClassExA
win32fn LoadIcon, user32.dll, LoadIconA
win32fn LoadCursor, user32.dll, LoadCursorA
win32fn CreateWindowEx, user32.dll, CreateWindowExA
win32fn GetMessage, user32.dll, GetMessageA
win32fn PeekMessage, user32.dll, PeekMessageA
win32fn DispatchMessage, user32.dll, DispatchMessageA
win32fn PostQuitMessage, user32.dll
win32fn MessageBox, user32.dll, MessageBoxA
win32fn DefWindowProc, user32.dll, DefWindowProcA
win32fn ReleaseDC, user32.dll 
win32fn GetDC, user32.dll
win32fn GetCursorPos, user32.dll
win32fn SendMessage, user32.dll, SendMessageA
win32fn SendInput, user32.dll
win32fn ShowCursor, user32.dll
win32fn GetWindowRect, user32.dll
win32fn SetCursorPos, user32.dll
win32fn GetFocus, user32.dll
;********************************************************************
; gdi32.dll functions
win32fn SwapBuffers, gdi32.dll
win32fn ChoosePixelFormat, gdi32.dll
win32fn SetPixelFormat, gdi32.dll
win32fn GetStockObject, gdi32.dll
win32fn TextOut, gdi32.dll, TextOutA
win32fn SetBkColor, gdi32.dll
win32fn	SetTextColor, gdi32.dll
;********************************************************************
; glu32.dll functions 
win32fn gluPerspective, glu32.dll
win32fn gluOrtho2D, glu32.dll
;********************************************************************
; Data segment
[section .data class=DATA use32 align=16]

string szWndClassName, "Our window class"
string szWndCaption, "ASMoid"

auxEDX		dd	0
auxECX		dd	0

hInstance		dd	0		; instance handle
hWnd			dd	0		; window handle 
dwWndWidth		dd	480		; window width
dwWndHeight		dd	640		; window height
hDC				dd	0		; device context handle
hRC				dd	0		; resource context handle

g_pause			dd 	1		;pause
g_score			dd 	0		;score counter
g_lives			dd	3		;lives count

lives_pos:					;lives "points" position
		dd __float32__(10.0)
		dd __float32__(32.0)
		dd __float32__(54.0)
		dd __float32__(76.0)
		
mxcsr			dd 0		;mxcsr register for div rounding

null 	dd 	__float32__(0.0)	;null for comparison

; float width height
Width			dd __float32__(480.0)
Height			dd __float32__(640.0)

; ball coordinates
ball_x 			dd __float32__(250.0)
ball_y			dd __float32__(50.0)

step_x			dd __float32__(5.0)
step_y			dd __float32__(5.0)
ball_dx			dd __float32__(0.0)
ball_dy			dd __float32__(5.0)

ball_size		dd __float32__(20.0)

;bonus ball - add score / live
bonus_ball		dd 1
bonus_ball_x	dd __float32__(240.0)
bonus_ball_y	dd __float32__(670.0)
bonus_ball_step	dd __float32__(3.0)
bonus_ball_ypos	dd __float32__(670.0)

speed 		dd  8000		;ball speed
d_speed 	dd 	400			;increase of speed
min_speed 	dd	4500

; ball 'catcher' coordinates
catch_x1 		dd __float32__(200.0)		
catch_x2		dd __float32__(300.0)
catch_xm		dd __float32__(250.0)
catch_y1  		dd __float32__(21.0)
catch_y2		dd __float32__(38.0)
catch_length  	dd __float32__(100.0)
catch_step		dd __float32__(0.0625)
catch_step_max	dd __float32__(2.0)

catcher_ball		dd 1
catcher_ball_x		dd __float32__(240.0)
catcher_ball_y		dd __float32__(670.0)
catcher_ball_step	dd __float32__(3.0)
catcher_ball_ypos	dd __float32__(670.0)
catcher_enlarge		dd 0
catcher_dx			dd __float32__(50.0)
catcher_enl_length	dd __float32__(200.0)
catcher_def_length 	dd __float32__(100.0)

catch_parts 	dd __float32__(3.0)
tollerance		dd __float32__(8.0)

;32 blocks on top
blocks	 		dd 0xffffffff 

;blocks coords
y_coords1:
		dd __float32__(598.0)
		dd __float32__(619.0)
		dd __float32__(640.0)
		
y_coords2:
		dd __float32__(580.0)
		dd __float32__(600.0)
		dd __float32__(620.0)

;timing structure
STRUC LARGE_INT
	.lowpart RESD 1
		alignb 8
	.highpart RESD 1
		alignb 8
ENDSTRUC

qpc_count:
	istruc LARGE_INT
		.lowpart 	dd 0
		.highpart 	dd 0	
	iend

qpc_freq:
	istruc LARGE_INT
		.lowpart 	dd 0
		.highpart 	dd 0	
	iend

micro_secs_prev 	dq __float64__(0.0)
qpc_to_micro 		dq __float64__(0.0)
sec_to_micro		dq __float64__(1000000.0)
time_diff			dd 0

;mouse
Mouse:
	istruc POINT
		at POINT.x,	 dd 0
		at POINT.y,	 dd 0
	iend

;window coords
wnd_coords:
	istruc RECT
		at RECT.left,	 dd 0
		at RECT.top,	 dd 0
		at RECT.right,	 dd 0
		at RECT.bottom,	 dd 0
	iend

;text positions

text_pos_x		dd 0
text_pos_y		dd 0
game_over 		db "Game Over! Press Space for new game", 0
start_text		db "Press Space to play/pause", 0
start_text2 	db "Press Esc to Exit game", 0
start_text3 	db "Use mouse to move left/right", 0
msg_paused 		db "Press Space to play",0
msg_score		db "Score:    ",0

string noCpuid, "CPUID instruction was NOT detected!", 0
string noMMX,"MMX support was NOT detected!",0
string noSSE,"SSE support was NOT detected!",0x0A,0x0D
string noSSE2,"SSE2 support was NOT detected!",0x0A,0x0D
string noQPC,"QuerryPerformanceFrequency failed!",0x0A,0x0D

Message:		resb MSG_size
;**************************************************************************
WndClass:
	istruc WNDCLASSEX
	    at WNDCLASSEX.cbSize,          dd  WNDCLASSEX_size
	    at WNDCLASSEX.style,           dd  CS_VREDRAW + CS_HREDRAW + CS_OWNDC
	    at WNDCLASSEX.lpfnWndProc,     dd  WndProc
	    at WNDCLASSEX.cbClsExtra,      dd  0
	    at WNDCLASSEX.cbWndExtra,      dd  0
	    at WNDCLASSEX.hInstance,       dd  NULL
	    at WNDCLASSEX.hIcon,           dd  NULL
	    at WNDCLASSEX.hCursor,         dd  NULL
	    at WNDCLASSEX.hbrBackground,   dd  NULL
	    at WNDCLASSEX.lpszMenuName,    dd  NULL
	    at WNDCLASSEX.lpszClassName,   dd  szWndClassName
	    at WNDCLASSEX.hIconSm,         dd  NULL
	iend

PixelFormatDescriptor:
	istruc PIXELFORMATDESCRIPTOR
		at PIXELFORMATDESCRIPTOR.nSize,				dw	PIXELFORMATDESCRIPTOR_size
		at PIXELFORMATDESCRIPTOR.nVersion,			dw	1
		at PIXELFORMATDESCRIPTOR.dwFlags,			dd	PFD_DOUBLEBUFFER + PFD_DRAW_TO_WINDOW + PFD_SUPPORT_OPENGL
		at PIXELFORMATDESCRIPTOR.iPixelType,		db	PFD_TYPE_RGBA
		at PIXELFORMATDESCRIPTOR.cColorBits,		db	24 
  		at PIXELFORMATDESCRIPTOR.cRedBits,			db	0 
  		at PIXELFORMATDESCRIPTOR.cRedShift,			db	0 
  		at PIXELFORMATDESCRIPTOR.cGreenBits,		db	0 
  		at PIXELFORMATDESCRIPTOR.cGreenShift,		db	0 
  		at PIXELFORMATDESCRIPTOR.cBlueBits,			db	0 
  		at PIXELFORMATDESCRIPTOR.cBlueShift,		db	0 
  		at PIXELFORMATDESCRIPTOR.cAlphaBits,		db	0 
  		at PIXELFORMATDESCRIPTOR.cAlphaShift,		db	0 
  		at PIXELFORMATDESCRIPTOR.cAccumBits,		db	0 
  		at PIXELFORMATDESCRIPTOR.cAccumRedBits,		db	0 
  		at PIXELFORMATDESCRIPTOR.cAccumGreenBits,	db	0 
  		at PIXELFORMATDESCRIPTOR.cAccumBlueBits,	db	0 
  		at PIXELFORMATDESCRIPTOR.cAccumAlphaBits,	db	0 
  		at PIXELFORMATDESCRIPTOR.cDepthBits,		db	32 
  		at PIXELFORMATDESCRIPTOR.cStencilBits,		db	0 
  		at PIXELFORMATDESCRIPTOR.cAuxBuffers,		db	0 
  		at PIXELFORMATDESCRIPTOR.iLayerType,		db	PFD_MAIN_PLANE 
  		at PIXELFORMATDESCRIPTOR.bReserved,			db	0 
  		at PIXELFORMATDESCRIPTOR.dwLayerMask,		dd	0 
  		at PIXELFORMATDESCRIPTOR.dwVisibleMask,		dd	0
  		at PIXELFORMATDESCRIPTOR.dwDamageMask,		dd	0
	iend
;********************************************************************
[section .code use32 class=CODE]

 ..start:
  	invoke GetModuleHandle,NULL				
  	mov [hInstance],eax        					; save handle to hInstance
  	mov [WndClass + WNDCLASSEX.hInstance],eax	; save handle to window struct
  		                       					
	invoke RegisterClassEx,WndClass		
  	test eax,eax                    			; if eax == 0 some error occurs
  	jz near .Finish                 						
 	
	invoke CreateWindowEx,\
 		0,\
       	szWndClassName,szWndCaption,\
 		WS_CAPTION + WS_VISIBLE + WS_SYSMENU + WS_SIZEBOX + WS_MAXIMIZEBOX + WS_MINIMIZEBOX + WS_OVERLAPPED,\
 		CW_USEDEFAULT, CW_USEDEFAULT, [dwWndWidth], [dwWndHeight],\
 		NULL, NULL, [hInstance], NULL
	test eax,eax								; check errors
	jz near .Finish								

   	mov [hWnd],eax								; save handle
	  
	mov edx, [dwWndWidth]
	shr edx, 1
	sub edx, 70
	mov [text_pos_x], edx
	mov ebx, [dwWndHeight]
	shr ebx, 1
	mov [text_pos_y], ebx 
	 
	invoke ShowWindow,eax,SW_SHOWDEFAULT		; show window
	invoke UpdateWindow,[hWnd]					

	call checkInstructions						; check SSE, MMX support

	invoke QueryPerformanceCounter, qpc_count	;get QPC value
	invoke QueryPerformanceFrequency, qpc_freq	;get QPC frequency 
	test eax, eax
	jnz near .qpc_ok							;check qpc freq error
	invoke TextOut, [hDC], [text_pos_x], [text_pos_y], noQPC, lenof.noQPC
	jmp .Finish
	
.qpc_ok:
		
	fld qword [sec_to_micro]	;set quocient to convert tics to microsecs
	fild qword [qpc_freq]
	fdivp
	fst qword [qpc_to_micro]
	fmul qword [qpc_count]
	fstp qword [micro_secs_prev]
	
	stmxcsr [mxcsr]  		; for SSE conversion instructions
	mov ecx, 13				; set division rounding to lower number!
	mov eax, 1
	shl eax, cl
	or [mxcsr], eax
	ldmxcsr [mxcsr]
	
	invoke SetBkColor, [hDC], 0x00000000		;for TextOut
	invoke SetTextColor, [hDC], 0x00ffffff
	
	invoke TextOut, [hDC], [text_pos_x], [text_pos_y], msg_paused, 19
	
	mov dword [g_pause], 0						;pause game at the beggining
	
;********************************************************************
.GameLoop:

	invoke PeekMessage,Message,NULL,0,0,PM_REMOVE 	; check for message
	test eax,eax								; if no msg, jump to NoMessage
	jz near .NoMessage							
	
	cmp dword [Message + MSG.message],WM_QUIT	; check if msg is quit
	jz near .Finish								
 			   									
	invoke TranslateMessage,Message				; translate virtual keys
	invoke DispatchMessage,Message 				; call service function

.NoMessage:
	xor eax, eax
	cmp eax, [g_pause]	;if paused, do nothing
	jz .GameLoop
	
	invoke QueryPerformanceCounter, qpc_count ;get qpc
	test eax, eax
	jnz .ok
	invoke PostQuitMessage,0
.ok:
	fild qword [qpc_count]
	fmul qword [qpc_to_micro]		;convert to microseconds
	fst st1
	fld qword  [micro_secs_prev]
	fsubp							;compare with previous
	fistp dword [time_diff]
	mov eax, [time_diff]
	cmp eax, [speed]				;if got here faster than speed, do not change ball coords
	jc .to_rend
	fstp qword [micro_secs_prev]
	invoke GetFocus
	cmp eax, [hWnd]
	jz near .have_focus
	xor eax, eax
	mov [g_pause], eax
	invoke ShowCursor, 1			;show cursor while game paused
	invoke TextOut, [hDC], [text_pos_x], [text_pos_y], msg_paused, 19
	jmp .GameLoop
.have_focus	
	call moveBall					;change ball coords
	call bonusBallMove				;change bonus ball coords
	call catcherBallMove
	call resizeCatcher
	jmp .rend

.to_rend:
	fstp dword [time_diff]			;just clear FPU stack
			
.rend:
	invoke GetCursorPos, Mouse		;get mouse coords and window coords to compute mouse position in wnd
	invoke GetWindowRect, [hWnd], wnd_coords
	call mouseMove
    call Render		  							; render window
    jmp .GameLoop 								; loop
;********************************************************************

.Finish:
	invoke ExitProcess,[Message + MSG.wParam]	; app end

;********************************************************************
function WndProc,hWnd,wMsg,wParam,lParam							
;********************************************************************
begin
	mov eax,dword [wMsg]	; save wMsg to eax - used often
	               
	cmp eax,WM_DESTROY		
	je near .Destroy
	cmp eax,WM_CLOSE		
	je near .Destroy		
	cmp eax,WM_PAINT		
	je near .Paint
	cmp eax,WM_CHAR			; char from keyboard
	je near .Char
	cmp eax,WM_CREATE		; window created
	je near .Create
	cmp eax,WM_SIZE			; window size has changed
	je near .Resize

;if we do not want this msg, we call default window proc function

	invoke DefWindowProc,[hWnd],[wMsg],[wParam],[lParam]
	return eax

.Close:
.Destroy:							
	invoke wglMakeCurrent,NULL,NULL	
	invoke wglDeleteContext,[hRC]	
	invoke ReleaseDC,[hWnd],[hDC]	
	invoke PostQuitMessage,0		

.Finish:
	return 0						
	
.Create:
	invoke GetDC,[hWnd]		   		; get window device context
	mov [hDC],eax					; save to hDC
	invoke ChoosePixelFormat,eax,PixelFormatDescriptor		; set format of pixels
	invoke SetPixelFormat,[hDC],eax,PixelFormatDescriptor	
	invoke wglCreateContext,[hDC]	; create OpenGL context
	mov [hRC],eax					; save it to resource context handler
	invoke wglMakeCurrent,[hDC],eax	; activate OpenGL context
	call InitGL						; call our funciton to init OpenGL
	jmp .Finish					

.Paint:
	call Render						; call our Render function
	jmp .Finish						;

.Char:	
	cmp dword [wParam], VK_ESCAPE	;esc == app end
	jz near .Close					
	cmp dword [wParam], VK_SPACE	;space == pause
	jnz near .Finish
	xor eax, eax
	cmp eax, [g_pause]
	jz near .pause_end
	mov dword [g_pause], 0
	invoke ShowCursor, 1			;show cursor while game paused
	invoke TextOut, [hDC], [text_pos_x], [text_pos_y], msg_paused, 19
	jmp .Finish
.pause_end:
	mov dword [g_pause], 1			;unpause game = hide cursor
	invoke ShowCursor, 0 
	jmp .Finish	

.Resize:
	mov eax,[lParam]				; lParam new width and height
	shr eax,16					
	mov [dwWndHeight],eax			; save new Height
	push eax						; push to stack for next call of glViewport
	mov eax,[lParam]				
	and eax,0x0000FFFF				; mask lower 16 bytes 	
	mov [dwWndWidth],eax			; we got window width
	push eax						; save and push to stack
	call InitGL						; call Init GL due to size change
	invoke glViewport, 0, 0			; call just with 2 params (next 2 are already on stack)
	call Render
	mov dword [g_pause], 1
	call Render
	mov dword [g_pause], 0			;pause game after resize
	mov edx, [dwWndWidth]	
	shr edx, 1
	sub edx, 70
	mov [text_pos_x], edx		;set new text positions
	mov ebx, [dwWndHeight]
	shr ebx, 1
	mov [text_pos_y], ebx
	invoke TextOut, [hDC], edx, ebx, msg_paused, 19	
	jmp .Finish						

end ;WndProc
;********************************************************************

_f64_10: dq __float64__(10.0)
_f64_1:  dq __float64__(1.0)
_f64_90:  dq __float64__(90.0)
;********************************************************************
function InitGL														
;********************************************************************
begin
  
	invoke glEnable, GL_DEPTH_TEST		; allow depth tests
	invoke glEnable, GL_POINT_SMOOTH	; for circle point
	invoke glEnable, GL_BLEND
	invoke glMatrixMode,GL_PROJECTION	; set projection matrix
	invoke glLoadIdentity				; load identity

	sub esp,8                 ; save (double)10.0 = 2x32 bits
	mov eax,[_f64_10]					
	mov [esp],eax
	mov eax,[_f64_10 + 4]
	mov [esp + 4],eax
	
	sub esp,8                 ; save (double)1.0 = 2x32 bits				
    movq xmm0,[_f64_1]
    movq [esp],xmm0
	
    sub esp,8                			; save (double)width/height = 2x32 bits
 	fild dword [dwWndWidth]				; st0 = width
	fidiv dword [dwWndHeight]			; st0 = width/height
	fstp qword [esp]					; save st0 to esp						
										; call gluPerspective
										; fovy = (double)90.0
   sub esp,8             			    ; save (double)90.0 = 2x32 bits
   fld qword [_f64_90]
   fstp qword [esp]

	invoke gluPerspective

	return
end ; InitGL
;********************************************************************

%define f(x) __float32__(x)
;********************************************************************
function Render														
;********************************************************************
begin	  
	; do not render while paused
	xor eax, eax
	cmp eax, [g_pause]
	jnz .not_paused
	return

.not_paused:
    invoke glMatrixMode, GL_MODELVIEW
	invoke glPointSize, [ball_size]
	
	invoke glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
	
	invoke glClearColor, f(0.0), f(0.0), f(0.0), f(0.0)
    invoke glClear, GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
	
	call OrthoStart	
	invoke glLoadIdentity
	invoke glTranslatef, f(-240.0), f(-320.0), f(0.0)

	invoke glBegin, GL_POINTS
	
	;bonus ball
	invoke glColor3f, f(1.0), f(0.6), f(0.0)
	invoke glVertex2f, [bonus_ball_x], [bonus_ball_y]
	
	;catcher_ball
	invoke glColor3f, f(0.0), f(1.0), f(0.0)
	invoke glVertex2f, [catcher_ball_x], [catcher_ball_y]
	
	;lives
	invoke glColor3f, f(1.0), f(0.0), f(0.0)
	mov edi, [g_lives]
	test edi, edi
	jz near .no_chance
	mov edx, 0
	
.rend_lives:
	mov ebx, [lives_pos + edx]
	invoke glVertex2f, ebx, f(10.0)
	add edx, 4
	sub edi, 1
	test edi, edi
	jnz near .rend_lives

.no_chance:	

	;ball
	invoke glColor3f, f(0.0), f(0.0), f(1.0)
	invoke glVertex2f, [ball_x], [ball_y]
	
    invoke glEnd
	
	invoke glBegin, GL_QUADS
	
	; ball 'catcher' 
	invoke glColor3f, f(1.0), f(0.0), f(0.0)
	invoke glVertex2f, [catch_x1], [catch_y1]
	invoke glVertex2f, [catch_x2], [catch_y1]
	invoke glColor3f, f(0.2), f(0.2), f(1.0)
	invoke glVertex2f, [catch_x2], [catch_y2]
	invoke glVertex2f, [catch_x1], [catch_y2]	

	; blocks on top	
	mov edx, [blocks]
	mov edi, f(579.0)
	mov ebx, f(560.0)
	mov esi, 0
	
.blocks_loop:
	test edx, 1
	jz near .second
	invoke glVertex2f, f(0.0), ebx
	invoke glVertex2f, f(59.0), ebx
	invoke glVertex2f, f(59.0), edi
	invoke glVertex2f, f(0.0), edi
.second:
	test edx, 2
	jz near .third
	invoke glVertex2f, f(60.0), ebx
	invoke glVertex2f, f(119.0), ebx
	invoke glVertex2f, f(119.0), edi
	invoke glVertex2f, f(60.0), edi	
.third:
	test edx, 4
	jz near .fourth
	invoke glVertex2f, f(120.0), ebx
	invoke glVertex2f, f(179.0), ebx
	invoke glVertex2f, f(179.0), edi
	invoke glVertex2f, f(120.0), edi
.fourth:
	test edx, 8
	jz near .fifth
	invoke glVertex2f, f(180.0), ebx
	invoke glVertex2f, f(239.0), ebx
	invoke glVertex2f, f(239.0), edi
	invoke glVertex2f, f(180.0), edi
.fifth:
	test edx, 16
	jz near .sixth
	invoke glVertex2f, f(240.0), ebx
	invoke glVertex2f, f(299.0), ebx
	invoke glVertex2f, f(299.0), edi
	invoke glVertex2f, f(240.0), edi
.sixth:
	test edx, 32
	jz near .seventh
	invoke glVertex2f, f(300.0), ebx
	invoke glVertex2f, f(359.0), ebx
	invoke glVertex2f, f(359.0), edi
	invoke glVertex2f, f(300.0), edi
.seventh:
	test edx, 64
	jz near .eighth
	invoke glVertex2f, f(360.0), ebx
	invoke glVertex2f, f(419.0), ebx
	invoke glVertex2f, f(419.0), edi
	invoke glVertex2f, f(360.0), edi
.eighth:
	test edx, 128
	jz near .last
	invoke glVertex2f, f(420.0), ebx
	invoke glVertex2f, f(480.0), ebx
	invoke glVertex2f, f(480.0), edi
	invoke glVertex2f, f(420.0), edi
.last:
	
	shr edx, 8
	test edx, edx
	jz near .blocks_end

	mov edi, [y_coords1 + esi]
	mov ebx, [y_coords2 + esi]
	add esi, 4
	jmp near .blocks_loop
	
.blocks_end:

	invoke glEnd
	
	call OrthoEnd
	
    invoke SwapBuffers, [hDC]
	
    return
end ; Render


txt_w: dq __float64__(240.0)
txt_h:  dq __float64__(320.0)
;********************************************************************
;* 						ortoghonal start							*
;********************************************************************
function OrthoStart													
begin
	invoke glMatrixMode, GL_PROJECTION
	invoke glPushMatrix
	invoke glLoadIdentity
	sub esp, 8                  
    fld qword [txt_h]
    fstp qword [esp]
	sub esp, 8   
	fldz
	fsub qword [txt_h]
	fstp qword [esp]
	sub esp, 8                  
    fld qword [txt_w]
    fstp qword [esp]
	sub esp, 8   
	fldz
	fsub qword [txt_w]
	fstp qword [esp]
	invoke gluOrtho2D
	invoke glMatrixMode, GL_MODELVIEW
	
	return
end ; OrthoStart

;********************************************************************
;* 						ortoghonal end								*
;********************************************************************
function OrthoEnd
begin
	invoke glMatrixMode, GL_PROJECTION
	invoke glPopMatrix
	invoke glMatrixMode, GL_MODELVIEW

	return
end	; OrthoEnd


diff:	dd	__float32__(80.0)
;********************************************************************
;* 						Mouse move									*
;********************************************************************
function mouseMove
begin
	cvtsi2ss xmm0, [Mouse]
	cvtsi2ss xmm1, [wnd_coords]
	subss xmm0, xmm1			;get mouse position in window
	
	movss xmm3, [Width]
	cvtsi2ss xmm4, [dwWndWidth]
	divss xmm3,xmm4				;map coordinates to window coordinates
	mulss xmm0, xmm3
	
	movss xmm1, [catch_xm]	;position of catcher	
	subss xmm0, xmm1		;dx
	
	comiss xmm1, [null]		;check if not behind left border
	jnc .test_rigth_border
	comiss xmm0, [null]
	jc .out_of_wnd	
	jmp .change_coords
	
.test_rigth_border:			;test if not behind right border
	comiss xmm1, [Width]
	jc .change_coords
	comiss xmm0, [null]
	jnc .out_of_wnd
	
.change_coords:				; mouse is inside window = change catcher coords
	movss xmm2, [catch_x1]
	addss xmm1, xmm0
	movss [catch_xm], xmm1
	addss xmm2, xmm0
	movss [catch_x1], xmm2
	movss xmm3, [catch_x2]
	addss xmm3, xmm0
	movss [catch_x2], xmm3

.out_of_wnd:	
	return
end	;mouseMove

up_max: 	dd __float32__(630.0)
down_min:	dd __float32__(50.0)
left_border: 	dd __float32__(10.0)
right_border:	dd __float32__(469.0)
;********************************************************************
;* 			Change ball coordinates									*
;********************************************************************
function moveBall
begin
	;y axis
	movss xmm2, [ball_x]
	movss xmm0, [ball_y]	
	comiss xmm0, [up_max]		;check up border
	jnc near .up_down_border		
	comiss xmm0, [down_min]		;check down border
	jnc near .check_x
	call testCatcher		
	test eax, eax
	jnz near .up_down_border	;reached up/down border, change y coords
	return
	
.up_down_border:
	pxor xmm1, xmm1
	subss xmm1, [ball_dy]		;set opposite dy
	movss [ball_dy], xmm1
	jmp near .change_values

.check_x:
	comiss xmm2, [right_border]	;check left/right border
	jnc near .left_right_border
	comiss xmm2, [left_border]
	jnc near .change_values
.left_right_border:
	pxor xmm1, xmm1
	subss  xmm1, [ball_dx]		;change dx to opposite
	movss [ball_dx], xmm1

.change_values:				;change ball coordes
	addss xmm0, [ball_dy]
	movss [ball_y], xmm0
	addss xmm2, [ball_dx]
	movss [ball_x], xmm2
	
	call testHit			;check if ball hit the block
	return
end

y1: 	dd __float32__(550.0)
y2:		dd __float32__(570.0)
y3:		dd __float32__(590.0)
y4:		dd __float32__(610.0)
block_size  dd __float32__(60.0)
;********************************************************************
;* 					Test if ball hit the block						*
;********************************************************************
function testHit
begin

	mov ebx, [blocks]
	test ebx, 0xff 			;if lower line is empty, shift all rows down
	jnz .not_empty			;upper row is full
	shr ebx, 8
	or ebx, 0xff000000
	mov [blocks], ebx
	movss xmm7, [speed]		;new row = higher speed of ball
	subss xmm7, [d_speed]
	comiss xmm7, [min_speed]
	jc near .not_empty
	movss [speed], xmm7
	
.not_empty:

	movss xmm0, [ball_y]
	
	comiss xmm0, [y1] 		;0-7  == first row (down)
	jnz near .not1
	movss xmm1, [ball_x]
	divss xmm1, [block_size]
	cvtss2si ecx, xmm1 		;which bit must be set to zero
	mov eax, 1
	shl eax, cl
	test eax, ebx
	jz .nothit				;block at that position is already destroyed
	not eax
	and ebx, eax
	mov [blocks], ebx
	pxor xmm7, xmm7						;hit -> ball goes down
	subss xmm7, [step_y]
	movss [ball_dy], xmm7
	mov eax, [g_score]		;increase score
	add eax, 1
	mov [g_score], eax
	call bonusBall
	call catcherBall
	return
	
.not1:
	comiss xmm0, [y2]
	jnz near .not2
	movss xmm1, [ball_x]	;8-15 == second row
	divss xmm1, [block_size]
	cvtss2si ecx, xmm1 		;which bit must be set to zero (0-7)
	add ecx, 8				;moved to second byte (8-15)
	mov eax, 1
	shl eax, cl
	test eax, ebx
	jz .nothit				;already destroyed block
	not eax
	and ebx, eax
	mov [blocks], ebx
	pxor xmm7, xmm7						;hit -> ball goes down
	subss xmm7, [step_y]
	movss [ball_dy], xmm7
	mov eax, [g_score]
	add eax, 1
	mov [g_score], eax
	call bonusBall
	call catcherBall
	return
	
.not2:
	comiss xmm0, [y3]
	jnz near .not3
	movss xmm1, [ball_x]	;16-23 == third row
	divss xmm1, [block_size]
	cvtss2si ecx, xmm1  	;which bit must be set to zero
	add ecx, 16				;moved to third byte (16-23)
	mov eax, 1
	shl eax, cl
	test eax, ebx
	jz .nothit				;already destroyed block
	not eax
	and ebx, eax
	mov [blocks], ebx
	pxor xmm7, xmm7						;hit -> ball goes down
	subss xmm7, [step_y]
	movss [ball_dy], xmm7
	mov eax, [g_score]
	add eax, 1
	mov [g_score], eax
	call bonusBall
	call catcherBall
	return
	
.not3:
	comiss xmm0, [y4]
	jnz near .nothit
	movss xmm1, [ball_x]	;highest row, highest byte
	divss xmm1, [block_size]
	cvtss2si ecx, xmm1 		;which bit must be set to zero
	add ecx, 24				;move to the fourth byte
	mov eax, 1
	shl eax, cl
	test eax, ebx
	jz .nothit				;already destroyed block
	not eax
	and ebx, eax
	mov [blocks], ebx
	pxor xmm7, xmm7						;hit -> ball goes down
	subss xmm7, [step_y]
	movss [ball_dy], xmm7
	mov eax, [g_score]
	add eax, 1
	mov [g_score], eax
	call bonusBall
	call catcherBall
	
.nothit:
	return
end


;********************************************************************
;* 			Test how ball hit the catcher, if ever, else fail		*
;********************************************************************
function testCatcher
begin
	pxor xmm3, xmm3
	movss xmm4, [ball_dx]
	
	movss xmm7, [ball_x]	;check fail - out of catcher
	movss xmm6, xmm7
	subss xmm7, [tollerance] ;some small tollerance of catching 
	movss xmm5, xmm7
	comiss xmm7, [catch_x2]
	jnc near .fail
	addss xmm6, [tollerance]
	comiss xmm6, [catch_x1]
	jc near .fail	
	
	movss xmm7, xmm5
	movss xmm5, [catch_x1]
	movss xmm6, [catch_length]
	divss xmm6, [catch_parts]   ;xmm6 = length of one part - left, middle, right
	addss xmm5, xmm6			
	comiss xmm7, xmm5			;check if catch ball by left part
	jnc .test_middle
	comiss xmm4, xmm3 			;for negative dx no change, else -step
	jc near .ok_ret
	subss xmm4, [step_x]
	movss [ball_dx], xmm4
	jmp near .ok_ret
	
.test_middle:
	addss xmm5, xmm6			
	comiss xmm7, xmm5			;check if catch ball by middle part
	jnc near .catch_right 		;no change for ball_dx	
	jmp near .ok_ret
.catch_right:
	comiss xmm4, [step_x] 		;for positive dx(=step) nothing, else +step
	jz near .ok_ret
	addss xmm4, [step_x]
	movss [ball_dx], xmm4
	
.ok_ret:
	return 1
	
.fail:
	;return 1	;just for testing
	
	mov eax, [catch_y2]
	mov dword [ball_y], eax		;add one step to ball, for better visibility of fail
	movss xmm0, [ball_x]
	addss xmm0, [ball_dx]
	movss [ball_x], xmm0

	;convert score int -> string
	mov esi, 9		
	mov cl, 10
	mov eax, [g_score]
	
.int_str:
	div cl
	add ah, 48				;48 = ascii zero
	mov [msg_score + esi], ah
	mov ah, 0
	sub esi, 1
	test ax, ax
	jnz .int_str
	
	mov eax, [g_lives]		;check if game over, or lost life
	sub eax, 1
	mov [g_lives], eax
	
	call Render
	invoke Sleep, 500 		;render failed position of ball, then render new reseted window
	call Reset
	call Render
	
	mov eax, [g_lives]
	test eax, eax
	jz near .no_chance		;if have som lives left, just pause game
	invoke TextOut, [hDC], [text_pos_x], [text_pos_y], msg_paused, 19
	mov eax, [dwWndWidth]
	shr eax, 1
	add eax, [wnd_coords]
	mov ebx, [dwWndHeight]
	shr ebx, 1
	add ebx, [wnd_coords + 4]
	invoke SetCursorPos, eax, ebx	;move cursor to middle of window for next game
	mov dword [g_pause], 0
	invoke ShowCursor, 1
	return 0


.no_chance:				;no lives left
	mov edx, [dwWndWidth]
	shr edx, 1
	sub edx, 40
	mov ebx, [dwWndHeight]	;print out score
	shr ebx, 1
	invoke TextOut, [hDC], edx, ebx, msg_score, 10

	mov edx, [dwWndWidth]
	shr edx, 1
	sub edx, 120
	add ebx, 20
	invoke TextOut, [hDC], edx, ebx, game_over, 35
	
	;additional reset  - in case of game over, different reset variables for game over and lost one life
	mov dword [g_pause], 0
	invoke ShowCursor, 1
	
	mov dword [msg_score + 6], 0
	;32 blocks on top
	mov dword [blocks], 0xffffffff
	mov dword [g_score], 0
	mov dword [g_lives], 3
	
	mov dword [speed], 8000
	
	;move to the center of window
	mov eax, [dwWndWidth]
	shr eax, 1
	add eax, [wnd_coords]
	mov ebx, [dwWndHeight]
	shr ebx, 1
	add ebx, [wnd_coords + 4]
	invoke SetCursorPos, eax, ebx
	
	return 0
end ; testCatcher

;********************************************************************
;* 			 		Reset all coordinates							*
;********************************************************************
function Reset
begin
	;ball
	mov dword [ball_x], __float32__(250.0)
	mov dword [ball_y], __float32__(50.0)
	
	;bonus_ball
	mov dword [bonus_ball], 1
	mov dword [bonus_ball_y], __float32__(670.0)

	mov dword [catcher_ball], 1
	mov dword [catcher_ball_y], __float32__(670.0)
	mov dword [catcher_enlarge], 0

	mov dword [step_x], __float32__(5.0)
	mov dword [step_y], __float32__(5.0)
	mov dword [ball_dx], __float32__(0.0)
	mov dword [ball_dy],__float32__(5.0)

	mov dword [ball_size], __float32__(20.0)

	; ball 'catcher' coordinates
	mov dword [catch_x1], __float32__(200.0)		
	mov dword [catch_x2], __float32__(300.0)
 	mov dword [catch_xm], __float32__(250.0)
	mov dword [catch_y1], __float32__(21.0)
 	mov dword [catch_y2], __float32__(39.0)
 	mov dword [catch_length], __float32__(100.0)
	mov dword [catch_step], __float32__(0.0625)
	mov dword [catch_step_max], __float32__(2.0) 

	;y_coords1
	mov dword [y_coords1], __float32__(598.0)
	mov dword [y_coords1 + 4], __float32__(619.0)
	mov dword [y_coords1 + 8], __float32__(640.0)
		
	;y_coords2
	mov dword [y_coords2], __float32__(580.0)
	mov dword [y_coords2 + 4], __float32__(600.0)
	mov dword [y_coords2 + 8], __float32__(620.0)

	;micro_secs:
	mov dword [qpc_count], 0
	mov dword [qpc_count + 4], 0

	mov dword [micro_secs_prev], 0
	
	return
end ; Reset

;********************************************************************
;* 					Randomly creates bonus ball						*
;********************************************************************
function bonusBall
begin
	mov eax, [bonus_ball]	
	test eax, eax			;check if is active - if yes, move it
	jnz near .new_ball
	call bonusBallMove
	return 

.new_ball:
	mov eax, [qpc_count]	;for random function
	and eax, 31				;chance 1/16 to bonus ball				
	sub eax, 12				;random num 
	jnz near .no_bonus
	
	xor eax, eax			;activate bonus ball - set coords of main ball
	mov [bonus_ball], eax
	movss xmm0, [ball_x]
	movss [bonus_ball_x], xmm0
	movss xmm1, [ball_y]
	movss [bonus_ball_y], xmm1
	
.no_bonus:
	return
end ; bonusBall

;********************************************************************
;* 					Move bonus ball if is active					*
;********************************************************************
function bonusBallMove
begin
	mov eax, [bonus_ball]	
	test eax, eax			;check if is active
	jz near .move_ball
	return

.move_ball:
	movss xmm0, [bonus_ball_y]		;check for down border, if is there, check for catcher 
	comiss xmm0, [down_min]
	jc near .test_catcher	
	subss xmm0, [bonus_ball_step]	;else goes down
	movss [bonus_ball_y], xmm0
	return
	
.test_catcher:
	movss xmm0, [bonus_ball_x]		
	movss xmm1, [catch_x1]
	subss xmm1, [tollerance]
	comiss xmm0, xmm1
	jc near .no_bonus
	movss xmm1, [catch_x2]
	addss xmm1, [tollerance]		
	comiss xmm1, xmm0
	jc near .no_bonus	
	mov eax, 1				;if bonus ball is catched
	mov [bonus_ball], eax 
	mov eax, [g_lives]		;got bonus 
	cmp eax, 3
	jz near .add_score		;if not full life, add one
	add eax, 1
	mov [g_lives], eax
	jmp .no_bonus
	
.add_score:
	mov eax, [g_score]		;if life is full, add 3 points to score
	add eax, 3
	mov [g_score], eax
		
.no_bonus:
	movss xmm0, [bonus_ball_ypos]	;no at down border yet, move down
	movss [bonus_ball_y], xmm0
	mov eax, 1
	mov [bonus_ball], eax
	return
end ; bonusBallMove

;********************************************************************
;* 					Randomly creates catcher_ball					*
;********************************************************************
function catcherBall
begin
	mov eax, [catcher_ball]	
	test eax, eax			;check if is active - if yes, move it
	jnz near .new_ball
	call catcherBallMove
	return 

.new_ball:
	mov eax, [catcher_enlarge]
	test eax, eax
	jnz .no_bonus
	
	mov eax, [qpc_count]	;for random function
	and eax, 7				;chance 1/8 to bonus ball				
	sub eax, 5 				;random num 
	jnz near .no_bonus
	
	xor eax, eax			;activate catcher ball - set coords of main ball
	mov [catcher_ball], eax
	movss xmm0, [ball_x]
	movss [catcher_ball_x], xmm0
	movss xmm1, [ball_y]
	movss [catcher_ball_y], xmm1
	
.no_bonus:
	return
end ; catcherBall

;********************************************************************
;* 					Move catcher ball if is active					*
;********************************************************************
function catcherBallMove
begin
	mov eax, [catcher_ball]	
	test eax, eax			;check if is active
	jz near .move_ball
	return

.move_ball:
	movss xmm0, [catcher_ball_y]		;check for down border, if is there, check for catcher 
	comiss xmm0, [down_min]
	jc near .test_catcher	
	subss xmm0, [catcher_ball_step]	;else goes down
	movss [catcher_ball_y], xmm0
	return
	
.test_catcher:
	movss xmm0, [catcher_ball_x]		
	movss xmm1, [catch_x1]
	subss xmm1, [tollerance]
	comiss xmm0, xmm1
	jc near .no_bonus
	movss xmm1, [catch_x2]		
	addss xmm1, [tollerance]
	comiss xmm1, xmm0
	jc near .no_bonus	
	mov eax, 1				;if bonus ball is catched
	mov [catcher_ball], eax
	mov eax, 690
	mov [catcher_enlarge], eax
	movss xmm0, [catch_x1]
	subss xmm0, [catcher_dx]
	movss [catch_x1], xmm0
	
	movss xmm1, [catch_x2]
	addss xmm1, [catcher_dx]
	movss [catch_x2], xmm1
	
	movss xmm2, [catcher_enl_length]
	movss [catch_length], xmm2
		
.no_bonus:
	movss xmm0, [catcher_ball_ypos]	;no at down border yet, move down
	movss [catcher_ball_y], xmm0
	mov eax, 1
	mov [catcher_ball], eax
	return
end ; catcherBallMove

;********************************************************************
;* 					Change size of catcher							*
;********************************************************************
function resizeCatcher
begin
	mov eax, [catcher_enlarge]
	test eax, eax
	jz near .no_change
	
	sub eax, 1
	mov [catcher_enlarge], eax
	test eax, eax
	jnz .no_change
	
	movss xmm0, [catch_x1]
	addss xmm0, [catcher_dx]
	movss [catch_x1], xmm0
	
	movss xmm1, [catch_x2]
	subss xmm1, [catcher_dx]
	movss [catch_x2], xmm1
	
	movss xmm0, [catcher_def_length]
	movss [catch_length], xmm0	
	
.no_change:
	return
	
end ;resizeCatcher

;********************************************************************
;* 			Check if mmx, sse, sse2 instructions are supported		*
;********************************************************************
function checkInstructions
begin
	;test cpuid
	pushfd
	pop eax
	mov ebx,eax
	xor eax,0x00200000
	push eax 
	popfd
	pushfd
	pop eax 
	cmp eax,ebx 
	jz near .L_NoCPUID
	
	mov eax,1
	cpuid

	;test mmx
	test edx,0x00800000
	jz near .L_MMXNotFound
	
	mov [auxEDX],edx
	mov [auxECX],ecx

	;test SSE
	test dword [auxEDX],0x02000000
	jnz .L_SSE

	invoke TextOut, [hDC], [text_pos_x], [text_pos_y], noSSE, lenof.noSSE
	jmp .L_Finish
	
.L_SSE:
	;test SSE2
	test dword [auxEDX],0x04000000
	jnz .L_SSE2

	invoke TextOut, [hDC], [text_pos_x], [text_pos_y], noSSE2, lenof.noSSE2
	jmp .L_Finish

.L_SSE2:
	return
	
.L_MMXNotFound:
	invoke TextOut, [hDC], [text_pos_x], [text_pos_y], noMMX, lenof.noMMX
	jmp .L_Finish
	
.L_NoCPUID:
	invoke TextOut, [hDC], [text_pos_x], [text_pos_y], noCpuid, lenof.noCpuid
	
.L_Finish:
	invoke Sleep, 1000
	invoke ExitProcess
end