; The GIMP -- an image manipulation program
; Copyright (C) 1995 Spencer Kimball and Peter Mattis
; 
;--------------------------------------------------------------------------------------
; Photo effects bundle 1
; Made by Iccii for GIMP version 1
;
; Bundled and adapted for GIMP version 2.x by Eddy Verlinden 
; Most changes are documented
; 
;
; Find the Original scripts at http://wingimp.hp.infoseek.co.jp/files/script/script.html
; Copyright (C) 2001-2002 Iccii <iccii@hotmail.com>
;---------------------------------------------------------------------------------------
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.  
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;

;***************************************************************************
; 
; Chrome image script  for GIMP 1.2
; Copyright (C) 2001-2002 Iccii <iccii@hotmail.com>
; 
; --------------------------------------------------------------------
; version 0.1  by Iccii 2001/07/22
;     - Initial relase
; version 0.1a by Iccii 2001/07/23
;     - Fixed some bugs in curve caluclation
; version 0.1a by Iccii 2001/10/08
;     - Added Color option (which enable only RGB image type)
; version 0.1b 2002/02/25 Iccii <iccii@hotmail.com>
;     - Added Contrast option
;
; --------------------------------------------------------------------
; 

(define (script-fu-chrome-image-G2
			img		
			drawable	
			color		
			contrast
			deform
			random
			emboss?
	)

  (let* (
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
	 (old-fg (car (gimp-palette-get-foreground)))
	 (image-type (if (eqv? (car (gimp-drawable-is-gray drawable)) TRUE)
                         GRAYA-IMAGE
                         RGBA-IMAGE))
	 (layer-color (car (gimp-layer-new img width height image-type
	                                   "Color Layer" 100 OVERLAY-MODE)))
	 (point-num (+ 2 (* random 2)))
	 (step (/ 255 (+ (* random 2) 1)))
	 (control_pts (cons-array (* point-num 2) 'byte))
         (count 0)
        )

    (gimp-undo-push-group-start img)
    (if (eqv? (car (gimp-drawable-is-gray drawable)) FALSE)
        (gimp-desaturate drawable))
    (plug-in-gauss-iir2 1 img drawable deform deform)
    (if (eqv? emboss? TRUE)
        (plug-in-emboss 1 img drawable 30 45.0 20 1))

	;; カーブツールの処理部分
    (while (< count random)
      (aset control_pts (+ (* count 4) 2) (* step (+ (* count 2) 1)))
      (aset control_pts (+ (* count 4) 3) (+ 128 contrast))
      (aset control_pts (+ (* count 4) 4) (* step (+ (* count 2) 2)))
      (aset control_pts (+ (* count 4) 5) (- 128 contrast))
      (set! count (+ count 1)))
    (aset control_pts 0 0)
    (aset control_pts 1 0)
    (aset control_pts (- (* point-num 2) 2) 255)
    (aset control_pts (- (* point-num 2) 1) 255)
    (gimp-curves-spline drawable VALUE-LUT (* point-num 2) control_pts)

	;; 画像タイプが RGBA の時だけ色付けする
    (if (eqv? image-type RGBA-IMAGE)
        (begin
          (gimp-palette-set-foreground color)
          (gimp-image-add-layer img layer-color -1)
          (gimp-edit-fill layer-color FG-IMAGE-FILL)
        )
     )

	;; 後処理
    (gimp-palette-set-foreground old-fg)
    (gimp-undo-push-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script-fu-chrome-image-G2"
  _"<Image>/Filters/Decor/Photo Effects/Style/Chrome Image..."
  "Create chrome image.  Usefull when you want to create metallic surfaces"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "2002, Feb"
  "RGB* GRAY*"
  SF-IMAGE      "Image"		0
  SF-DRAWABLE   "Drawable"	0
  SF-COLOR      "Color"         '(255 127 0)
  SF-ADJUSTMENT "Contrast"      '(96 0 127 1 1 0 0)
  SF-ADJUSTMENT "Deformation"   '(10 1 50 1 10 0 0)
  SF-ADJUSTMENT "Ramdomeness"   '(4 1 7 1 10 0 1)
  SF-TOGGLE     "Enable Emboss" TRUE
)

;*************************************************************************************** 
; Cross light script  for GIMP 2
; based on Cross light script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; --------------------------------------------------------------------
; version 0.1  by Iccii 2001/07/22
;     - Initial relase
; version 0.2  by Iccii 2001/08/09
;     - Add the Start Angle and the Number of Lighting options
; version 0.2a adapted for GIMP2  by EV
; --------------------------------------------------------------------
; 

(define (script-fu-cross-light
			img
			drawable
			length
			angle	
			number
			threshold
	)
  (let* (
	 (modulo fmod)			;; in R4RS way
	 (count 1)
	 (tmp-layer (car (gimp-layer-copy drawable TRUE)))
	 (target-layer (car (gimp-layer-copy drawable TRUE)))
	 (layer-mask (car (gimp-layer-create-mask target-layer WHITE-MASK)))
	 (marged-layer (car (gimp-layer-copy drawable TRUE)))
   (currentselection (car(gimp-selection-save img)))
        )

    (gimp-undo-push-group-start img)

;    (set! currentselection (car(gimp-selection-save img)))
    (gimp-selection-none img)

; these tree line were moved up by EV
    (gimp-image-add-layer img target-layer -1)
    (gimp-image-add-layer-mask img target-layer layer-mask)
    (gimp-image-add-layer img tmp-layer -1)

    (gimp-desaturate tmp-layer)
    (gimp-threshold tmp-layer threshold 255)
   (gimp-edit-copy tmp-layer)

    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-mask 0)))
    (gimp-image-remove-layer-mask img target-layer APPLY)

    (gimp-drawable-fill tmp-layer TRANS-IMAGE-FILL)

    (gimp-image-set-active-layer img target-layer)
    (while (<= count number)
      (let* (
             (layer-copy (car (gimp-layer-copy target-layer TRUE)))
             (degree (modulo (+ (* count (/ 360 number)) angle) 360))
            )
        (gimp-image-add-layer img layer-copy -1)  
        (if (= count 1) (gimp-image-raise-layer img layer-copy)) 
        (plug-in-mblur 1 img layer-copy 0 length degree 0 0); two argyuments added for GIMP2  by EV       

        (set! marged-layer (car (gimp-image-merge-down img layer-copy 0 )))
        (gimp-drawable-set-name marged-layer "cross-light") ; this line was added by EV
        (set! count (+ count 1))
      ) ; end of let*
    ) ; end of while

    (gimp-image-remove-layer img target-layer)

    (gimp-layer-set-opacity marged-layer 80)
    (gimp-layer-set-mode marged-layer SCREEN-MODE)

    (gimp-selection-load currentselection) ; these five lines are new in version 0.6a
    (if (equal? (car (gimp-selection-is-empty img)) FALSE) 
        (begin
        (gimp-selection-invert img)
        (if (equal? (car (gimp-selection-is-empty img)) FALSE) (gimp-edit-fill marged-layer 3))
        (gimp-selection-invert img)
        ))
    (gimp-image-remove-channel img currentselection)

    (gimp-undo-push-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script-fu-cross-light"
  _"<Image>/Filters/Decor/Photo Effects/Style/Cross Light..."
  "Cross light effect"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "2001, Aug"
  "RGB*"
  SF-IMAGE      "Image"			0
  SF-DRAWABLE   "Drawable"		0
  SF-ADJUSTMENT _"Light Length"		'(40 1 255 1 10 0 0)
  SF-ADJUSTMENT _"Start Angle"		'(30 0 360 1 10 0 0)
  SF-ADJUSTMENT "Number of Lights"	'(4 1 16 1 2 0 1)
  SF-ADJUSTMENT _"Threshold (Bigger 1<-->255 Smaller)"  '(223 1 255 1 10 0 0)
)


;*************************************************************************************** 
; Note paper image script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; --------------------------------------------------------------------
; version 0.1  by Iccii 2001/07/22
;     - Initial relase
; version 0.1a by Iccii 2001/07/26
;     - Add Background color selector
; version 0.1b by Iccii 2001/09/25
;     - Add Cloud option in Background Texture
; version 0.2  by Iccii 2001/10/01 <iccii@hotmail.com>
;     - Changed menu path because this script attempts to PS's filter
;     - Added some code (if selection exists...)
; version 0.2a by Iccii 2001/10/02 <iccii@hotmail.com>
;     - Fixed bug in keeping transparent area
; version 0.2b by Iccii 2001/10/02 <iccii@hotmail.com>
;     - Fixed bug (get error when drawable doesn't have alpha channel)
;
; --------------------------------------------------------------------


	;; ノート用紙スクリプト
(define (script-fu-note-paper-G2
			img		;; 対象画像
			drawable	;; 対象ドロアブル (レイヤー)
			threshold1	;; 閾値1
			threshold2	;; 閾値2
			base-color	;; 着色する色
			bg-color	;; 背景の色
			bg-type		;; 背景のテクスチャの種類
	)

  (gimp-undo-push-group-start img)

  (let* (
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
	 (old-fg (car (gimp-palette-get-foreground)))
	 (old-selection (car (gimp-selection-save img)))
	 (layer-copy1 (car (gimp-layer-copy drawable TRUE)))
	 (layer-copy2 (car (gimp-layer-copy drawable TRUE)))
	 (layer-color1 (car (gimp-layer-new img width height RGBA-IMAGE "Color Upper" 100 MULTIPLY-MODE)))
	 (color-mask1 (car (gimp-layer-create-mask layer-color1 WHITE-MASK)))
	 (layer-color2 (car (gimp-layer-new img width height RGBA-IMAGE "Color Under" 100 MULTIPLY-MODE)))
	 (color-mask2 (car (gimp-layer-create-mask layer-color2 WHITE-MASK)))
	 (final-layer (car (gimp-layer-copy drawable TRUE)))
         (tmp 0)
	 (invert? FALSE)
        ) ; end variable definition

	;; 本処理
    (gimp-selection-none img)
    (gimp-image-add-layer img layer-copy1 -1)
    (gimp-image-add-layer img layer-copy2 -1)
    (gimp-desaturate layer-copy2)
    (gimp-desaturate layer-copy1)
    (cond
      ((eqv? bg-type 0)
         (gimp-edit-fill layer-copy1 WHITE-IMAGE-FILL)
         (gimp-brightness-contrast layer-copy1 0 63))
      ((eqv? bg-type 1)
         (gimp-edit-fill layer-copy1 WHITE-IMAGE-FILL)
         (plug-in-noisify 1 img layer-copy1 FALSE 1.0 1.0 1.0 0)
         (gimp-brightness-contrast layer-copy1 0 63))
      ((eqv? bg-type 2)
         (plug-in-solid-noise 1 img layer-copy1 FALSE FALSE (rand 65535) 15 16 16)
         (plug-in-edge 1 img layer-copy1 4 1 4)  ; ev: needed too add the type (new plug-in)
         (gimp-brightness-contrast layer-copy1 0 -63))
      ((eqv? bg-type 3)
         (plug-in-plasma 1 img layer-copy1 (rand 65535) 4.0)
         (gimp-desaturate layer-copy1)
         (plug-in-gauss-iir2 1 img layer-copy1 1 1)
         (gimp-brightness-contrast layer-copy1 0 63))	) ; end of cond
    (if (> threshold1 threshold2)
        (begin				;; always (threshold1 < threshold2)
          (set! tmp threshold2)
          (set! threshold2 threshold1)
          (set! threshold1 tmp)
          (set! invert? TRUE))
        (set! invert? FALSE))
    (if (= threshold1 threshold2)
        (gimp-message "Execution error:\n Threshold1 equals to threshold2!")
        (gimp-threshold layer-copy2 threshold1 threshold2))
    (gimp-edit-copy layer-copy2)
    (plug-in-bump-map 1 img layer-copy1 layer-copy1 135 35 3 0 0 0 0 TRUE FALSE LINEAR)
    (plug-in-bump-map 1 img layer-copy1 layer-copy2 135 35 3 0 0 0 0 FALSE invert? LINEAR)
    (gimp-brightness-contrast layer-copy2 127 0)

	;; 着色処理
    (gimp-image-add-layer img layer-color1 -1)
    (gimp-image-add-layer-mask img layer-color1 color-mask1)
    (gimp-palette-set-foreground base-color)
    (gimp-drawable-fill layer-color1 FG-IMAGE-FILL)
    (gimp-floating-sel-anchor (car (gimp-edit-paste color-mask1 0)))
    (gimp-image-add-layer img layer-color2 -1)
    (gimp-image-add-layer-mask img layer-color2 color-mask2)
    (gimp-palette-set-foreground bg-color)
    (gimp-drawable-fill layer-color2 FG-IMAGE-FILL)
    (gimp-floating-sel-anchor (car (gimp-edit-paste color-mask2 0)))
    (gimp-invert color-mask2)

	;; レイヤー後始末
    (gimp-layer-set-mode layer-copy2 SCREEN-MODE)
    (gimp-layer-set-opacity layer-copy2 75)
    (gimp-image-merge-down img layer-copy2 EXPAND-AS-NECESSARY)
    (gimp-image-merge-down img layer-color1 EXPAND-AS-NECESSARY)
    (set! final-layer (car (gimp-image-merge-down img layer-color2 EXPAND-AS-NECESSARY)))
    (plug-in-bump-map 1 img final-layer final-layer 135 45 3 0 0 0 0 TRUE FALSE LINEAR) ; added ev
    (if (eqv? (car (gimp-drawable-has-alpha drawable)) TRUE)
        (gimp-selection-layer-alpha drawable))
    (if (eqv? (car (gimp-selection-is-empty img)) FALSE)
        (begin
          (gimp-selection-invert img)
          (gimp-edit-clear final-layer)))
    (gimp-selection-load old-selection)
    (gimp-edit-copy final-layer)
    (gimp-image-remove-layer img final-layer)
    (gimp-floating-sel-anchor (car (gimp-edit-paste drawable 0)))
    (gimp-selection-load old-selection)
    (gimp-image-remove-channel img old-selection)


	;; 後処理
    (gimp-palette-set-foreground old-fg)
    (gimp-undo-push-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script-fu-note-paper-G2"
  _"<Image>/Filters/Decor/Photo Effects/Artist/Note Paper..."
  "Creates note paper, which simulates Photoshop's Textureizer filter"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "2001, Oct"
  "RGB*"
  SF-IMAGE      "Image"	           0
  SF-DRAWABLE   "Drawable"         0
  SF-ADJUSTMENT "Threshold (Bigger 1<-->255 Smaller)" '(127 0 255 1 10 0 0)
  SF-ADJUSTMENT "Threshold (Bigger 1<-->255 Smaller)" '(255 0 255 1 10 0 0)
  SF-COLOR      "Base Color"       '(255 255 255)
  SF-COLOR      "Background Color" '(223 223 223)
  SF-OPTION     "Background Texture" '("Plane" "Sand" "Paper" "Cloud")
)

;*************************************************************************************** 
; Pastel image script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; This script is based on pastel-windows100.scm
; 
; --------------------------------------------------------------------
; version 0.1  by Iccii 2001/10/19 <iccii@hotmail.com>
;     - Initial relase
;
; --------------------------------------------------------------------
;     Reference Book
; Windows100% Magazine October, 2001
;   Tamagorou's Photograph touching up class No.29
;     theme 1 -- Create the Pastel image
; --------------------------------------------------------------------
; 

(define (script-fu-pastel-image-G2
			img		
			drawable	
                        Dbord           
			detail		
			length		
			amount		
			angle		
			canvas?		
	)

  (gimp-undo-push-group-start img)

  (let* (
	 (Dbordx  (cond ((= Dbord 0) 4) ((= Dbord 1) 0) ((= Dbord 2) 1) ((= Dbord 3) 2) ((= Dbord 4) 3) ((= Dbord 5) 5)  ))
	 (old-selection (car (gimp-selection-save img)))
	 (layer-copy0 (car (gimp-layer-copy drawable TRUE)))
	 (dummy (if (< 0 (car (gimp-layer-mask layer-copy0)))
                  (gimp-image-remove-layer-mask img layer-copy0 DISCARD)))
	 (layer-copy1 (car (gimp-layer-copy layer-copy0 TRUE)))
	 (length (if (= length 1) 0 length))
	 (layer-copy2 (car (gimp-layer-copy layer-copy0 TRUE)))
	 (marged-layer (car (gimp-layer-copy drawable TRUE)))
	 (final-layer  (car (gimp-layer-copy drawable TRUE)))
	)

    (gimp-image-add-layer img layer-copy0 -1)
    (gimp-image-add-layer img layer-copy2 -1)
    (gimp-image-add-layer img layer-copy1 -1)

    (plug-in-mblur TRUE img layer-copy0 0 length angle TRUE TRUE);
    (plug-in-mblur TRUE img layer-copy0 0 length (+ angle 180) TRUE TRUE)


    (plug-in-gauss-iir TRUE img layer-copy1 (- 16 detail) TRUE TRUE)
    (plug-in-edge TRUE img layer-copy1 6.0 0 Dbord)  
    (gimp-layer-set-mode layer-copy1 DIVIDE-MODE)
    (set! marged-layer (car (gimp-image-merge-down img layer-copy1 EXPAND-AS-NECESSARY)))
    (gimp-layer-set-mode marged-layer VALUE-MODE)

    (if (equal? canvas? TRUE)
        (plug-in-apply-canvas TRUE img marged-layer 0 5))
    (plug-in-unsharp-mask TRUE img layer-copy0 (+ 1 (/ length 5)) amount 0)
    (set! final-layer (car (gimp-image-merge-down img marged-layer EXPAND-AS-NECESSARY)))

    (gimp-selection-load old-selection)
    (gimp-edit-copy final-layer)
;    (gimp-image-remove-layer img final-layer)                     ;let's keep the original layer
;    (gimp-floating-sel-anchor (car (gimp-edit-paste drawable 0)))  

    (gimp-selection-load old-selection)
    (gimp-image-remove-channel img old-selection)

    (gimp-undo-push-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script-fu-pastel-image-G2"
  _"<Image>/Filters/Decor/Photo Effects/Artist/Pastel..."
  "Create the Pastel image"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "2001, Oct"
  "RGB*"
  SF-IMAGE      "Image"	         0
  SF-DRAWABLE   "Drawable"       0
  SF-OPTION     "Edge detection" '("Differential" "Sobel" "Prewitt" "Gradient" "Roberts" "Laplace")
  SF-ADJUSTMENT "Detail Level"   '(12.0 0 15.0 0.1 0.5 1 1)
  SF-ADJUSTMENT "Scketch Length" '(10 0 32 1 1 0 1)
  SF-ADJUSTMENT "Scketch Amount" '(5.0 0 5.0 0.1 0.5 1 1)
  SF-ADJUSTMENT "Angle"          '(45 0 180 1 15 0 0)
  SF-TOGGLE     "Add a canvas texture" FALSE
 )

;*************************************************************************************** 
; The GIMP -- an image manipulation program
; Copyright (C) 1995 Spencer Kimball and Peter Mattis
; 
; Patchwork effect script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; --------------------------------------------------------------------
; version 0.1  by Iccii 2001/07/12
;     - Initial relase
; version 0.2  by Iccii 2001/07/14
;     - Change to better algorithm
; version 0.3  by Iccii 2001/07/16
;     - Add the round option to create round tile
; version 0.4  by Iccii 2001/07/19
;     - Add Tile Type options to select tile type
; version 0.5  by Iccii 2001/10/01 <iccii@hotmail.com>
;     - Changed menu path because this script attempts to PS's filter
;     - Added Angle option
; version 0.5a by Iccii 2001/10/02 <iccii@hotmail.com>
;     - Fixed bug in keeping transparent area
; version 0.5b by Iccii 2001/10/02 <iccii@hotmail.com>
;     - Fixed bug (get error when drawable doesn't have alpha channel)
;
; --------------------------------------------------------------------
; 
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.  
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;

	;; パッチワークスクリプト
(define (script-fu-patchwork-G2
			img		;; 対象画像
			drawable	;; 対象レイヤー
			type		;; タイルの種類
			size		;; タイルの大きさ
			depth		;; タイルの深度
			angle		;; バンプマップの角度
			level		;; タイルのばらつき度
	)

  (gimp-undo-push-group-start img)

  (let* (
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
	 (old-fg (car (gimp-palette-get-foreground)))
	 (old-selection (car (gimp-selection-save img)))
	 (tmp-layer1 (car (gimp-layer-copy drawable TRUE)))
	 (tmp-layer2 (car (gimp-layer-copy drawable TRUE)))
 	 (final-layer (car (gimp-layer-copy drawable TRUE)))
	 (depth-color (list depth depth depth))
	 (radius (- (/ size 2) 1))
	 (blur   (cond ((= type 0) 1) ((= type 1) 0) ((= type 2) 0) ((= type 3) 0)))
	 (hwidth (cond ((= type 0) 1) ((= type 1) 0) ((= type 2) 2) ((= type 3) 1)))
	 (vwidth (cond ((= type 0) 1) ((= type 1) 2) ((= type 2) 0) ((= type 3) 1)))
	) ; end variable definition

	;; 一時的なレイヤー追加
; *** The next 2 lines were moved here by EV
   (gimp-image-add-layer img tmp-layer1 -1)
   (gimp-image-add-layer img tmp-layer2 -1)
   (gimp-desaturate tmp-layer2)
    (if (eqv? (car (gimp-selection-is-empty img)) FALSE)
        (begin
          (gimp-selection-invert img)
          (gimp-edit-clear tmp-layer2)
          (gimp-selection-invert img)))
; *** The next 2 lines were moved upwards
;    (gimp-image-add-layer img tmp-layer1 -1)
;    (gimp-image-add-layer img tmp-layer2 -1)

	;; 一時的なレイヤーへ順番にフィルタ処理を行う
    (plug-in-noisify 1 img tmp-layer2 FALSE 1.0 1.0 1.0 0)
    (plug-in-pixelize 1 img tmp-layer1 size)
    (plug-in-pixelize 1 img tmp-layer2 size)
    (gimp-levels tmp-layer2 VALUE-LUT (+ 32 (* level 2)) (- 223 (* level 2)) 1.0 0 255)
    (plug-in-grid 1 img tmp-layer2 hwidth size 0 depth-color 255
	                           vwidth size 0 depth-color 255
                                   0      0    0 '(0 0 0)    255)
	;; 丸めるオプションを有効にした場合
    (if (= type 3)
        (let* ((selection-channel (car (gimp-selection-save img))))
          (gimp-palette-set-foreground depth-color)
          (gimp-by-color-select tmp-layer2 depth-color 0 REPLACE FALSE 0 0 FALSE)
          (gimp-selection-grow img radius)
          (gimp-selection-shrink img radius)
          (gimp-edit-fill tmp-layer2 FG-IMAGE-FILL)
          (gimp-selection-load selection-channel)
          (gimp-image-remove-channel img selection-channel)
          (gimp-image-set-active-layer img tmp-layer2)	;; why do I need this line?
          (gimp-palette-set-foreground old-fg)))
    (plug-in-gauss-iir2 1 img tmp-layer2 (+ blur hwidth) (+ blur vwidth))
    (plug-in-bump-map 1 img tmp-layer2 tmp-layer2 angle
                      30 (+ 4 level) 0 0 0 0 TRUE FALSE LINEAR)

	;; 一時的なレイヤーの調整、結合
    (gimp-layer-set-mode tmp-layer2 OVERLAY-MODE)
    (gimp-layer-set-opacity tmp-layer2 (+ level 84))
    (set! final-layer (car (gimp-image-merge-down img tmp-layer2 EXPAND-AS-NECESSARY)))
    (if (eqv? (car (gimp-drawable-has-alpha drawable)) TRUE)
        (gimp-selection-layer-alpha drawable))
    (if (eqv? (car (gimp-selection-is-empty img)) FALSE)
        (begin
          (gimp-selection-invert img)
          (gimp-edit-clear final-layer)))
    (gimp-selection-load old-selection)
    (gimp-edit-copy final-layer)
    (gimp-image-remove-layer img final-layer)
    (gimp-floating-sel-anchor (car (gimp-edit-paste drawable 0)))
    (gimp-selection-load old-selection)
    (gimp-image-remove-channel img old-selection)

	;; 後処理
    (gimp-palette-set-foreground old-fg)
    (gimp-undo-push-group-end img)
    (gimp-displays-flush)
  ) ; end of let*
) ; end of define

(script-fu-register
  "script-fu-patchwork-G2"
  _"<Image>/Filters/Decor/Photo Effects/Texture/Patchwork..."
  "Creates patchwork image, which simulates Photoshop's Patchwork filter"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "2001, Oct"
  "RGB*"
  SF-IMAGE       "Image"	0
  SF-DRAWABLE    "Drawable"	0
  SF-OPTION      "Tile Type"    '("Normal" "Horizontal" "Vertical" "Round")
  SF-ADJUSTMENT  _"Block Size"	'(10 2 127 1 10 0 1)
  SF-ADJUSTMENT  _"Depth"	'(127 0 255 1 10 0 1)
  SF-ADJUSTMENT  _"Angle"	'(135 0 360 1 10 0 0)
  SF-ADJUSTMENT  _"Level"	'(8 0 16 1 2 0 0)
)

;*************************************************************************************** 
; Stained glass script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; You'll find that this script isn't "real" staind glass effect
; Plese tell me how to create if you know more realistic effect
; This script is only applying the mosac plugin ;-(
; --> Eddy Verlinden : tile spacing bigger and light-direction set to 270 + added copy-layer3 in screenmode
; --------------------------------------------------------------------
; version 0.1  by Iccii 2001/07/21
;     - Initial relase
; this version 9 april 2006
; --------------------------------------------------------------------



	;; ステンドグラス風スクリプト
(define (script-fu-stained-glass-G2
			img		;; 対象画像
			drawable	;; 対象ドロアブル (レイヤー)
			tile-size	;; 一つ一つの大きさ
	)
  (gimp-undo-push-group-start img)
; one variable added in the next line; and some other parameters are changed
; (plug-in-mosaic 1 img drawable tile-size 0 1.0 0.65 90.0 0.25 TRUE TRUE 1 0 0)
  (plug-in-mosaic 1 img drawable tile-size 0 2.5 0.65 0 270.0 0.25 TRUE TRUE 1 0 0)
  (let* (
	 (copy-layer1 (car (gimp-layer-copy drawable 1)))
	 (copy-layer2 (car (gimp-layer-copy drawable 1)))
	 (copy-layer3 (car (gimp-layer-copy drawable 1)))
        )

    (gimp-image-add-layer img copy-layer1 -1)
    (gimp-image-add-layer img copy-layer2 -1)
    (gimp-layer-set-mode copy-layer1 OVERLAY-MODE)
    (gimp-layer-set-mode copy-layer2 OVERLAY-MODE)
    (gimp-layer-set-opacity copy-layer1 100)
    (gimp-layer-set-opacity copy-layer2 100)
    (gimp-image-merge-down img
      (car (gimp-image-merge-down img copy-layer2 EXPAND-AS-NECESSARY))
                               EXPAND-AS-NECESSARY)
 ; )

    (gimp-image-add-layer img copy-layer3 -1)
    (gimp-layer-set-mode copy-layer3 SCREEN-MODE)
    (gimp-layer-set-opacity copy-layer3 100)
    (gimp-image-merge-down img copy-layer3 EXPAND-AS-NECESSARY)
     )



	;; 後処理
  (gimp-undo-push-group-end img)
  (gimp-displays-flush)
)

(script-fu-register
  "script-fu-stained-glass-G2"
  _"<Image>/Filters/Decor/Photo Effects/Texture/Stained Glass..."
  "Create stained glass image"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "2001, Jul"
  "RGB*"
  SF-IMAGE      "Image"		0
  SF-DRAWABLE   "Drawable"	0
  SF-ADJUSTMENT "Cell Size (pixels)"   '(18 5 100 1 10 0 1)
)

;*************************************************************************************** 
; Texturizer script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; I would appreciate any comments/suggestions that you have about this
; script. I need new texture, how to create it.
; 
; --------------------------------------------------------------------
; version 0.1  by Iccii 2001/09/26 <iccii@hotmail.com>
;     - Initial relase
;     - There are three texture type -- Sand, Paper, Cloud
; version 0.2  by Iccii 2001/09/27 <iccii@hotmail.com>
;     - Create the texture image as new window image instead of
;       creating layer in base image
;     - Added Depth option
; version 0.2a by Iccii 2001/09/30 <iccii@hotmail.com>
;     - Added Pattern option in texture type
; version 0.3  by Iccii 2001/10/01 <iccii@hotmail.com>
;     - Changed menu path because this script attempts to PS's filter
;     - Added Angle option
;
; --------------------------------------------------------------------
; 


	;; テクスチャスクリプト
(define (script-fu-texturizer-G2
			img		;; 対象画像
			drawable	;; 対象ドロアブル (レイヤー)
			pattern		;; パターン
			bg-type		;; 背景のテクスチャの種類
			angle		;; バンプの角度
			elevation	;; 彫りの深さ
			direction	;; テクスチャ伸張の方向
			invert?		;; 凹凸を反転させるかどうか
			show?		;; テクスチャ画像を表示するかどうか
	)
  (let* (
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
	 (old-fg (car (gimp-palette-get-foreground)))
	 (old-pattern (car (gimp-patterns-get-pattern)))
	 (tmp-image (car (gimp-image-new width height GRAY)))
	 (tmp-layer (car (gimp-layer-new tmp-image width height
                                         2 "Texture" 100 0)))  ; was 'GRAY-Image "Texture" 100 NORMAL'
        ) ; end variable definition

	;; 本処理
    (gimp-undo-push-group-start img)
    (gimp-image-undo-disable tmp-image)
   ; (if (eqv? (car (gimp-drawable-is-layer-mask drawable)) TRUE)
   ;     (set! layer (car (gimp-image-get-active-layer img drawable))))
    (gimp-drawable-fill tmp-layer WHITE-IMAGE-FILL)
    (gimp-image-add-layer tmp-image tmp-layer 0)

    (cond
      ((eqv? bg-type 0)
         (gimp-patterns-set-pattern pattern)
         (gimp-bucket-fill tmp-layer PATTERN-BUCKET-FILL NORMAL-MODE 100 0 FALSE 0 0))
      ((eqv? bg-type 1)
         (plug-in-noisify 1 img tmp-layer FALSE 1.0 1.0 1.0 0)
         (gimp-brightness-contrast tmp-layer 0 63))
      ((eqv? bg-type 2)
         (plug-in-solid-noise 1 img tmp-layer FALSE FALSE (rand 65535) 15 16 16)
; last parameter added by EV (for GIMP 2)
         (plug-in-edge 1 img tmp-layer 4 1 5)
         (gimp-brightness-contrast tmp-layer 0 -63))
      ((eqv? bg-type 3)
         (plug-in-plasma 1 img tmp-layer (rand 65535) 4.0)
         (plug-in-gauss-iir2 1 img tmp-layer 1 1)
         (gimp-brightness-contrast tmp-layer 0 63))
      ) ; end of cond
    (plug-in-bump-map 1 img drawable tmp-layer angle (+ 35 elevation)
                      1 0 0 0 0 TRUE invert? LINEAR)



	;; 後処理
   ; (cond
	;; If Drawable is Layer
   ;   ((eqv? (car (gimp-drawable-is-layer drawable)) TRUE)
   ;     (gimp-image-set-active-layer img drawable))
	;; If Drawable is Layer mask
   ;   ((eqv? (car (gimp-drawable-is-layer-mask drawable)) TRUE)
   ;     (gimp-image-set-active-layer img layer))
	;; If Drawable is Channel
   ;   ((eqv? (car (gimp-drawable-is-channel drawable)) TRUE)
   ;     (gimp-image-set-active-channel img drawable))
   ; ) ; end of cond

    (gimp-palette-set-foreground old-fg)
    (gimp-patterns-set-pattern old-pattern)
    (gimp-image-clean-all tmp-image)
    (gimp-image-undo-enable tmp-image)
    (if (eqv? show? TRUE)
        (gimp-display-new tmp-image)
        (gimp-image-delete tmp-image))
    (gimp-undo-push-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script-fu-texturizer-G2"
  _"<Image>/Filters/Decor/Photo Effects/Texture/Texturizer..."
  "Creates textured canvas image, which simulates Photoshop's Texturizer filter"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "2001, Oct"
  "RGB* GRAY*"
  SF-IMAGE      "Image"	           0
  SF-DRAWABLE   "Drawable"         0
  SF-PATTERN    "Use Pattern"      "Pine?"
  SF-OPTION     "Texture Type"     '("Pattern" "Sand" "Paper" "Cloud")
  SF-ADJUSTMENT "Angle"            '(135 0 360 1 10 0 0)
  SF-ADJUSTMENT "Depth"            '(0 -5 5 1 1 0 1)
  SF-OPTION     "Stretch Direction" '("None" "Horizontal" "Vertical")
  SF-TOGGLE     "Invert"           FALSE
  SF-TOGGLE     "Show Texture"     FALSE
)


;*************************************************************************************** 
; Water paint effect script  for GIMP 1.2
;   <Image>/Filters/Alchemy/Water Paint Effect...
;
; --------------------------------------------------------------------
;   - Changelog -
; version 0.1  2001/04/15 iccii <iccii@hotmail.com>
;     - Initial relased
; version 0.1a 2001/07/20 iccii <iccii@hotmail.com>
;     - more simple
;
; --------------------------------------------------------------------
; 

(define (script-fu-water-paint-effect-G2
			inImage
			inDrawable
			inEffect
	)

	(gimp-undo-push-group-start inImage)
(let* (
        (currentselection (car(gimp-selection-save inImage))) 
        (theNewlayer (car (gimp-layer-copy inDrawable TRUE)))
      )
;        (gimp-selection-none inImage)
;	(set! tmp-layer (car (gimp-layer-copy inDrawable TRUE)))
;	(gimp-image-add-layer inImage tmp-layer -1)
        

	(plug-in-gauss-iir2 1 inImage inDrawable inEffect inEffect)
	(set! theNewlayer (car (gimp-layer-copy inDrawable 1)))
	(gimp-image-add-layer inImage theNewlayer -1)
	(plug-in-unsharp-mask 1 inImage theNewlayer 5.0 10.0 0)
	(plug-in-laplace 1 inImage theNewlayer)
	(gimp-layer-set-mode theNewlayer SUBTRACT-MODE)


    (gimp-selection-load currentselection)
    (if (equal? (car (gimp-selection-is-empty inImage)) FALSE) 
        (begin
        (gimp-selection-invert inImage)
        (if (equal? (car (gimp-selection-is-empty inImage)) FALSE) (gimp-edit-fill theNewlayer 3))
        (gimp-selection-invert inImage)
        ))
    (gimp-image-remove-channel inImage currentselection)

	(gimp-image-merge-down inImage theNewlayer EXPAND-AS-NECESSARY)



	(gimp-undo-push-group-end inImage)
	(gimp-displays-flush)
  )
)

(script-fu-register
	"script-fu-water-paint-effect-G2"
	_"<Image>/Filters/Decor/Photo Effects/Artist/Water Paint Effect..."
	"draw with water paint effect"
	"Iccii <iccii@hotmail.com>"
	"Iccii"
	"Jul, 2001"
	"RGB*, GRAY*"
	SF-IMAGE	"Image"		0
	SF-DRAWABLE	"Drawable"	0
	SF-ADJUSTMENT	"Effect Size (pixels)"	'(5 0 32 1 10 0 0)
)


;*************************************************************************************** 
; Wrap paint effect Script  for GIMP 1.2
;   <Image>/Filters/Alchemy/Wrap Effect...
; 
; --------------------------------------------------------------------
;   - Changelog -
; version 0.1  by Iccii 2001/04/15 <iccii@hotmail.com>
;     - Initial relase
; version 0.2  by Iccii 2001/10/01 <iccii@hotmail.com>
;     - Changed menu path because this script attempts to PS's filter
;     - Added some code (if selection exists...)
;
; --------------------------------------------------------------------
; 
;
(define (script-fu-wrap-effect-G2
                		inImage
				inDrawable
				inRadius
				inGamma1
				inGamma2
				inSmooth
	)

	(gimp-undo-push-group-start inImage)

  (let* (
	(theOld-bg (car (gimp-palette-get-background)))
	(theNewlayer (car (gimp-layer-copy inDrawable 1)))
	(theOldselection (car (gimp-selection-save inImage)))
	(theLayermask (car (gimp-layer-create-mask theNewlayer BLACK-MASK)))
	)

	(gimp-layer-set-name theNewlayer "Wrap effect")
	(gimp-layer-set-mode theNewlayer NORMAL-MODE)
	(gimp-image-add-layer inImage theNewlayer -1)

	(gimp-desaturate theNewlayer)
	(plug-in-gauss-iir2 1 inImage theNewlayer inRadius inRadius)
	(plug-in-edge 1 inImage theNewlayer 6.0 0 4)
	(gimp-invert theNewlayer)


	(if (eqv? inSmooth TRUE)
	    (plug-in-gauss-iir2 0 inImage theNewlayer 5 5))
	(gimp-edit-copy theNewlayer)

	(if (< 0 (car (gimp-layer-mask theNewlayer)))
	    (gimp-image-remove-layer-mask inImage theNewlayer APPLY))
;	(set! theLayermask (car (gimp-layer-create-mask theNewlayer BLACK-MASK)))
	(gimp-image-add-layer-mask inImage theNewlayer theLayermask)
	(gimp-floating-sel-anchor (car (gimp-edit-paste theLayermask 0)))

	(gimp-levels theNewlayer 0 0 255 (/ inGamma1 10) 0 255)
	(gimp-levels theNewlayer 0 0 255 (/ inGamma1 10) 0 255)
	(gimp-levels theLayermask 0 0 255 (/ inGamma2 10) 0 255)
	(gimp-levels theLayermask 0 0 255 (/ inGamma2 10) 0 255)

	(gimp-image-remove-layer-mask inImage theNewlayer APPLY)
	(gimp-selection-load theOldselection)
	(gimp-edit-copy theNewlayer)
	(gimp-image-remove-layer inImage theNewlayer)
	(gimp-floating-sel-anchor (car (gimp-edit-paste inDrawable 0)))
	(gimp-selection-load theOldselection)
	(gimp-image-remove-channel inImage theOldselection)

	(gimp-palette-set-background theOld-bg)
	;(gimp-image-set-active-layer inImage inDrawable)
	(gimp-undo-push-group-end inImage)
	(gimp-displays-flush)
   )
)

(script-fu-register
	"script-fu-wrap-effect-G2"
	_"<Image>/Filters/Decor/Photo Effects/Artist/Wrap Effect..."
	"Draws with wrap effect, which simulates Photoshop's Wrap filter"
	"Iccii <iccii@hotmail.com>"
	"Iccii"
	"Oct, 2001"
	"RGB*"
	SF-IMAGE	"Image"			0
	SF-DRAWABLE	"Drawable"		0
	SF-ADJUSTMENT	"Randomness"		'(10 0 32 1 10 0 0)
	SF-ADJUSTMENT	"Highlight Balance"	'(3.0 1.0 10 0.5 0.1 1 0)
	SF-ADJUSTMENT	"Edge Amount"		'(3.0 1.0 10 0.5 0.1 1 0)
	SF-TOGGLE	"Smooth"		FALSE
)




;*************************************************************************************** 
; Stamp image script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; --------------------------------------------------------------------
; version 0.1  by Iccii 2001/10/01 <iccii@hotmail.com>
;     - Initial relase
; version 0.1a by Iccii 2001/10/02 <iccii@hotmail.com>
;     - Added Balance option
;     - Fixed bug in keeping transparent area
; version 0.1b by Iccii 2001/10/02 <iccii@hotmail.com>
;     - Fixed bug (get error when drawable doesn't have alpha channel)
;
; --------------------------------------------------------------------
; 



	;; スタンプスクリプト
(define (script-fu-stamp-image-G2
			img		;; 対象画像
			drawable	;; 対象ドロアブル (レイヤー)
			threshold1	;; 閾値1
			threshold2	;; 閾値2
			base-color	;; 着色する色
			bg-color	;; 背景の色
			balance		;; 白黒量のバランス
			smooth		;; ぼかしの量
	)

  (gimp-undo-push-group-start img)

  (let* (
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
	 (old-fg (car (gimp-palette-get-foreground)))
	 (old-selection (car (gimp-selection-save img)))
	 (layer-color1 (car (gimp-layer-new img width height RGBA-IMAGE "Color1" 100 NORMAL-MODE)))
	 (layer-color2 (car (gimp-layer-new img width height RGBA-IMAGE "Color2" 100 NORMAL-MODE)))
	 (color-mask2 (car (gimp-layer-create-mask layer-color2 BLACK-MASK)))
	 (channel (car (gimp-channel-new img width height "Color" 50 '(255 0 0))))
	 (tmp 0)
	 (final-layer (car (gimp-layer-new img width height RGBA-IMAGE "Color1" 100 NORMAL-MODE)))
        ) ; end variable definition

	;; 本処理
; These lines were movede up by EV
    (gimp-image-add-layer img layer-color1 -1)
    (gimp-image-add-layer img layer-color2 -1)
    (gimp-image-add-layer-mask img layer-color2 color-mask2)
    (gimp-image-add-channel img channel 0)

    (gimp-selection-none img)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste channel 0)))
    (if (> threshold1 threshold2)
        (begin				;; always (threshold1 < threshold2)
          (set! tmp threshold2)
          (set! threshold2 threshold1)
          (set! threshold1 tmp)))
    (if (= threshold1 threshold2)
        (gimp-message "Execution error:\n Threshold1 equals to threshold2!")
        (gimp-threshold channel threshold1 threshold2))
    (gimp-edit-copy channel)

	;; 着色処理
; these 3 lines were moved up by EV
;    (gimp-image-add-layer img layer-color1 -1)
;    (gimp-image-add-layer img layer-color2 -1)
;    (gimp-image-add-layer-mask img layer-color2 color-mask2)
    (gimp-palette-set-foreground bg-color)
    (gimp-drawable-fill layer-color1 FG-IMAGE-FILL)
    (gimp-palette-set-foreground base-color)
    (gimp-drawable-fill layer-color2 FG-IMAGE-FILL)

    (gimp-selection-load channel)
    (if (> balance 0)
      (gimp-selection-grow img balance)
      (begin
        (gimp-selection-invert img)
        (gimp-selection-grow img (abs balance))
        (gimp-selection-invert img)))
    (gimp-selection-feather img smooth)
    (gimp-selection-sharpen img)
    (gimp-edit-fill color-mask2 WHITE-IMAGE-FILL)
    (gimp-selection-none img)

	;; レイヤー結合
    (set! final-layer (car (gimp-image-merge-down img layer-color2 EXPAND-AS-NECESSARY)))
    (if (eqv? (car (gimp-drawable-has-alpha drawable)) TRUE)
        (gimp-selection-layer-alpha drawable))
    (if (eqv? (car (gimp-selection-is-empty img)) FALSE)
        (begin
          (gimp-selection-invert img)
          (gimp-edit-clear final-layer)))
    (gimp-selection-load old-selection)
    (gimp-edit-copy final-layer)
    (gimp-image-remove-layer img final-layer)
    (gimp-floating-sel-anchor (car (gimp-edit-paste drawable 0)))
    (gimp-selection-load old-selection)
    (gimp-image-remove-channel img old-selection)
; Next line added by EV to remove the red color.
    (gimp-drawable-set-visible channel 0)

	;; 後処理
    (gimp-palette-set-foreground old-fg)
    (gimp-undo-push-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script-fu-stamp-image-G2"
  _"<Image>/Filters/Decor/Photo Effects/Artist/Stamp..."
  "Creates photocopy image, which simulates Photoshop's Stamp filter"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "2001, Oct"
  "RGB*"
  SF-IMAGE      "Image"	           0
  SF-DRAWABLE   "Drawable"         0
  SF-ADJUSTMENT "Threshold (Bigger 1<-->255 Smaller)" '(127 0 255 1 10 0 0)
  SF-ADJUSTMENT "Threshold (Bigger 1<-->255 Smaller)" '(255 0 255 1 10 0 0)
  SF-COLOR      "Base Color"       '(255 255 255)
  SF-COLOR      "Background Color" '(  0   0   0)
  SF-ADJUSTMENT "Balance"          '(0 -100 100 1 10 0 1)
  SF-ADJUSTMENT "Smooth"           '(5 1 100 1 10 0 1)
)


;*************************************************************************************** 
; Tile Pattern shades script (easy version)  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; --------------------------------------------------------------------
; version 0.1  by Iccii 2001/12/21
;     - Initial relase
; version 0.1a by Iccii 2001/12/31
;     - Added Lighting degree option
;
; --------------------------------------------------------------------
; 

	;; Brick wall script

(define (script-fu-brick-wall-G2
			img		;; Target Image
			drawable	;; Target Drawable (Layer)
			size		;; Brick wall block size
			direction	;; Horizontal or Vectrical
			styleB		;; Brick wall style
			degree		;; Lighting angle in degree
	)
    (gimp-undo-push-group-start img)

  (define (list-ref l n) (nth n l))

  (define (draw-block-line layer)
    (let* ((w-size (* 2 size))
           (strokes (cons-array 4 'double))
           (old-brush (car (gimp-brushes-get-brush))))
      (gimp-drawable-fill layer WHITE-IMAGE-FILL)
      (gimp-brushes-set-brush "Circle (01)")
      (gimp-palette-set-foreground '(127 127 127))
      (aset strokes 0 0)
      (aset strokes 1 (/ size 2))
      (aset strokes 2 w-size)
      (aset strokes 3 (/ size 2))
      (gimp-paintbrush layer 0 4 strokes 0 0)
      (aset strokes 0 0)
      (aset strokes 1 (+ (/ size 2) size))
      (aset strokes 2 w-size)
      (aset strokes 3 (+ (/ size 2) size))
      (gimp-paintbrush layer 0 4 strokes 0 0)
      (aset strokes 0 (/ size 2))
      (aset strokes 1 (/ size 2))
      (aset strokes 2 (/ size 2))
      (aset strokes 3 (+ (/ size 2) size))
      (gimp-paintbrush layer 0 4 strokes 0 0)
      (aset strokes 0 (+ (/ size 2) size))
      (aset strokes 1 0)
      (aset strokes 2 (+ (/ size 2) size))
      (aset strokes 3 (/ size 2))
      (gimp-paintbrush layer 0 4 strokes 0 0)
      (aset strokes 0 (+ (/ size 2) size))
      (aset strokes 1 (+ (/ size 2) size))
      (aset strokes 2 (+ (/ size 2) size))
      (aset strokes 3 w-size)
      (gimp-paintbrush layer 0 4 strokes 0 0)
      (gimp-channel-ops-offset layer TRUE 0 (- (/ size 2)) (- (/ size 2)))
      (gimp-brushes-set-brush old-brush)))

  (let* (
	 (old-fg (car (gimp-palette-get-foreground)))
         (bounds (cdr (gimp-selection-bounds img)))
	 (style  (cond ((= styleB 0) 2) ((= styleB 1) 0) ((= styleB 2) 1)   ))
         (x1 (car  bounds))
         (y1 (cadr bounds))
         (x2 (car  (cddr bounds)))
         (y2 (cadr (cddr bounds)))
         (org-width (- x2 x1))
         (org-height (- y2 y1))
         (tmp-img (car (gimp-image-new org-width org-height RGB)))
         (tmp-layer1 (car (gimp-layer-new tmp-img org-width org-height
                                          1 "Dummy1" 100 0)))
         (tmp-layer2 (car (gimp-layer-new tmp-img org-width org-height
                                          1 "Dummy2" 100 0)))
         (tmp-mask2 (car (gimp-layer-create-mask tmp-layer2 BLACK-MASK)))
         (old-selection (if (equal? (car (gimp-selection-is-empty img)) TRUE)
                            0
                            (car (gimp-selection-save img))))
         (w-size (* size 2))
    	; (float (car (gimp-edit-paste drawable FALSE))) 
      	 (float (car (gimp-layer-copy drawable TRUE)))
      	 (final-layer (car (gimp-layer-copy drawable TRUE)))
        )

;    (gimp-undo-push-group-start img)

	;; Initialize
    (gimp-drawable-fill tmp-layer1 TRANS-IMAGE-FILL)
    (gimp-drawable-fill tmp-layer2 TRANS-IMAGE-FILL)
    (gimp-image-add-layer tmp-img tmp-layer1 -1)
    (gimp-image-add-layer tmp-img tmp-layer2 -1)
    (gimp-image-add-layer-mask tmp-img tmp-layer2 tmp-mask2)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste tmp-layer1 FALSE)))
    (gimp-floating-sel-anchor (car (gimp-edit-paste tmp-layer2 FALSE)))

    (let* ((end (cond ((= direction 0) org-height)
                      ((= direction 1) org-width)))
           (pos 0))
      (while (< pos end)
        (let* ((x-start (if (= direction 0) 0 pos))
               (y-start (if (= direction 1) 0 pos))
               (x-end (if (= direction 0) org-width size))
               (y-end (if (= direction 1) org-height size)))
          (gimp-rect-select tmp-img x-start y-start x-end y-end REPLACE FALSE 0)
          (if (equal? (car (gimp-selection-is-empty img)) TRUE)
              (gimp-edit-fill tmp-mask2 WHITE-IMAGE-FILL))
          (set! pos (+ pos w-size)))))
    (gimp-selection-none tmp-img)

    (gimp-layer-resize tmp-layer1 (+ org-width size) (+ org-height size) size size)
    (gimp-rect-select tmp-img 0 0 1 org-height REPLACE FALSE 0)
    (gimp-edit-copy tmp-layer1)
    (set! float (car (gimp-selection-float tmp-layer1 (- size) 0)))
    (gimp-floating-sel-to-layer float)
    (gimp-layer-scale float (* size 2) org-height TRUE)
    (gimp-rect-select tmp-img 0 0 org-width 1 REPLACE FALSE 0)
    (gimp-edit-copy tmp-layer1)
    (set! float (car (gimp-selection-float tmp-layer1 0 (- size))))
    (gimp-floating-sel-to-layer float)
    (gimp-layer-scale float org-width (* size 2) TRUE)
    (gimp-image-raise-layer-to-top tmp-img tmp-layer2)
    (set! tmp-layer1 (car (gimp-image-merge-down tmp-img 
                       (car (gimp-image-merge-down tmp-img float EXPAND-AS-NECESSARY))
                     CLIP-TO-BOTTOM-LAYER)))
 
   (plug-in-pixelize 1 tmp-img tmp-layer1 w-size)
    (plug-in-pixelize 1 tmp-img tmp-layer2 w-size)

    (set! final-layer (car (gimp-image-merge-visible-layers tmp-img CLIP-TO-IMAGE)))

    (cond ((= style 1)
            (plug-in-bump-map 1 tmp-img final-layer final-layer degree 35.0 5 0 0 0 0 TRUE FALSE 0))
          ((= style 2)
            (let* ((style-layer (car (gimp-layer-new tmp-img w-size w-size 1
                                                     "Style Layer" 100 0))))
; next line added by EV
              (gimp-image-add-layer tmp-img style-layer -1)
              (draw-block-line style-layer)
              (if (= direction 1)
                  (plug-in-rotate 1 tmp-img style-layer 3 FALSE))
              (plug-in-tile 1 tmp-img style-layer org-width org-height FALSE)
; heigth of the bumpmap changed from 3 into 8 and angle from 45 to 30 by EV
              (plug-in-bump-map 1 tmp-img final-layer style-layer degree 30.0 8 0 0 0 0 TRUE FALSE 0)))
    ) ; end of cond

    (if (equal? old-selection TRUE)
        (gimp-selection-load old-selection))
    (gimp-edit-copy final-layer)
    (gimp-floating-sel-anchor (car (gimp-edit-paste drawable TRUE)))
    (if (equal? old-selection TRUE)
        (begin
          (gimp-selection-load old-selection)
          (gimp-image-remove-channel img old-selection)))
    (gimp-palette-set-foreground old-fg)
    (gimp-undo-push-group-end img)
    (gimp-displays-flush)

  ) ; end of let*
)

(script-fu-register
  "script-fu-brick-wall-G2"
  _"<Image>/Filters/Decor/Photo Effects/Texture/Brick Wall..."
  "Effects like a brick wall"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "2001, Nov"
  "RGB* GRAY*"
  SF-IMAGE      "Image"              0
  SF-DRAWABLE   "Drawable"           0
  SF-ADJUSTMENT "Size"               '(10 1 100 1 10 0 1)
  SF-OPTION     "Direction"          '("Horizontal" "Vertical")
  SF-OPTION     "Brick Style"        '("Brick" "Flat" "Embedded")
  SF-ADJUSTMENT "Lighting (degrees)" '(135 0 360 1 10 0 0)
)

;*************************************************************************************** 
; High pass image script  for GIMP 1.2
; Copyright (C) 2002 Iccii <iccii@hotmail.com>
; 
; --------------------------------------------------------------------
; version 0.1  by Iccii 2002/04/24 <iccii@hotmail.com>
;     - Initial relase
;
; --------------------------------------------------------------------
; 


(define (script-fu-highpass-image-G2
			img		;; 対象画像
			drawable	;; 対象ドロアブル (レイヤー)
			radius		;; 半径
	)

  (gimp-undo-push-group-start img)

  (let* (
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
	 (old-selection (car (gimp-selection-save img)))
	 (image-type (if (eqv? (car (gimp-drawable-is-gray drawable)) TRUE)
                         GRAYA-IMAGE
                         RGBA-IMAGE))
   (layer-color (car (gimp-layer-new img width height image-type "Color Invert"  50 NORMAL-MODE)))

   (currentselection (car(gimp-selection-save img)))
   (selection-flag TRUE)
        ) ; end variable definition

    (set! currentselection (car(gimp-selection-save img))) 
    (gimp-selection-none img)

    (if (eqv? (car (gimp-selection-is-empty img)) TRUE)
        (begin
          (gimp-drawable-fill old-selection WHITE-IMAGE-FILL)
          (set! selection-flag TRUE)))
    (gimp-selection-none img)
    (gimp-drawable-fill layer-color TRANS-IMAGE-FILL)
    (gimp-image-add-layer img layer-color -1)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-color 0)))
    (gimp-invert layer-color)
    (plug-in-gauss-iir 1 img layer-color radius TRUE TRUE)

    (gimp-selection-load currentselection) ; these five lines are new in version 0.6a
    (if (equal? (car (gimp-selection-is-empty img)) FALSE) 
        (begin
        (gimp-selection-invert img)
        (if (equal? (car (gimp-selection-is-empty img)) FALSE) (gimp-edit-fill layer-color 3))
        (gimp-selection-invert img)
        ))
    (gimp-image-remove-channel img currentselection)
    (gimp-image-remove-channel img old-selection)
    (gimp-image-merge-down img layer-color 0)


    (gimp-undo-push-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script-fu-highpass-image-G2"
  _"<Image>/Filters/Decor/Photo Effects/The Others/High Pass..."
  "Creates high pass image, which simulates Photoshop's High pass filter.  It is used as an aid for sharpening pictures"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "2002, Apr"
  "RGB* GRAY*"
  SF-IMAGE      "Image"	            0
  SF-DRAWABLE   "Drawable"          0
  SF-ADJUSTMENT "Radius"            '(5 1 128 1 10 0 0)
)

;*************************************************************************************** 
; Soft focus script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; --------------------------------------------------------------------
; version 0.1  by Iccii 2001/07/22
;     - Initial relase
;
; --------------------------------------------------------------------
; 


	;; ソフトフォーカススクリプト
(define (script-fu-soft-focus-G2
			img		;; 対象画像
			drawable	;; 対象ドロアブル
			blur		;; ぼかしレベル
	)
  (let* (
	;; 対象レイヤーをコピーする
	 (layer-copy (car (gimp-layer-copy drawable TRUE)))
	;; コピーしたレイヤーへのレイヤーマスクを作る
	 (layer-mask (car (gimp-layer-create-mask layer-copy WHITE-MASK)))
        )

	;; アンドｩグループ開始
    (gimp-undo-push-group-start img)
	;; レイヤーを画像に追加
    (gimp-image-add-layer img layer-copy -1)
	;; レイヤーマスクを画像 (コピーしたレイヤー) に追加
    (gimp-image-add-layer-mask img layer-copy layer-mask)
	;; レイヤーのイメージをコピーして保管しておく
    (gimp-edit-copy layer-copy)
	;; それをレイヤーマスクにペーストする
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-mask 0)))
	;; レイヤーマスクをレイヤーに適用する
    (gimp-image-remove-layer-mask img layer-copy APPLY)
	;; コピーしたレイヤーにガウシアンぼかしをかける
    (plug-in-gauss-iir2 1 img layer-copy blur blur)
	;; コピーしたレイヤーの不透明度を変更する
    (gimp-layer-set-opacity layer-copy 80)
	;; コピーしたレイヤーのモードをスクリーンに変更する
    (gimp-layer-set-mode layer-copy SCREEN-MODE)

	;; 後処理
    (gimp-undo-push-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script-fu-soft-focus-G2"
  _"<Image>/Filters/Decor/Photo Effects/Style/Soft Focus..."
  "Soft focus effect"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "2001, Jul"
  "RGB* GRAYA"
  SF-IMAGE      "Image"		0
  SF-DRAWABLE   "Drawable"	0
  SF-ADJUSTMENT _"Blur Amount"  '(10 1 100 1 10 0 0)
)

;*************************************************************************************** 
; Solarization script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; --------------------------------------------------------------------
; version 0.1  by Iccii 2001/12/08
;     - Initial relase
; version 0.1a by Iccii 2001/12/09
;     - Added Threshold adjuster
;
; --------------------------------------------------------------------
; 



	;; Solarization Effect

(define (script-fu-solarization-G2
			img
			drawable
			threshold
			target-channel
			invert?
			value-change?
	)

  (define (apply-solarization channel)
    (let* ((point-num 256)
           (control_pts (cons-array point-num 'byte))
           (start-value (if (< threshold 128) (- 255 (* threshold 2)) 0))
           (end-value   (if (< threshold 128) 0 (* (- threshold 128) 2)))
           (grad (if (< threshold 128)
                     (/ (- 127 start-value) 127)
                     (/ (- end-value 127)   127)))
           (count 0))
      (while (< count point-num)
        (let* ((value1 (if (< threshold 128)
                           (if (< count 128)
                               (+ start-value (* grad count))
                               (- 255 count))
                           (if (< count 128)
                               count
                               (+ 127 (* grad (- count 128))))))
               (value2 (if (equal? value-change? TRUE) (+ value1 127) value1))
               (value  (if (equal? invert? TRUE) (- 255 value2) value2)))
          (aset control_pts count value)
          (set! count (+ count 1))))
      (gimp-curves-explicit drawable channel point-num control_pts)))


  (let* (
         (image-type (car (gimp-image-base-type img)))
         (has-alpha? (car (gimp-drawable-has-alpha drawable)))
        ) ; end variable definition

    (gimp-undo-push-group-start img)

    (if (or (= target-channel 0) (equal? image-type GRAY))
        (apply-solarization VALUE-LUT)
        (cond ((= target-channel 1)
                (apply-solarization RED-LUT))
              ((= target-channel 2)
                (apply-solarization GREEN-LUT))
              ((= target-channel 3)
                (apply-solarization BLUE-LUT))
              ((= target-channel 4)
                (if (equal? has-alpha? TRUE)
                    (apply-solarization ALPHA-LUT)
                    (gimp-message "Drawable doesn't have an alpha channel! Abort."))) ))

    (gimp-undo-push-group-end img)
    (gimp-displays-flush)
))

(script-fu-register
  "script-fu-solarization-G2"
  _"<Image>/Filters/Decor/Photo Effects/Style/Solarization..."
  "Apply solarization effect, which simulates Photoshop's Solarization filter"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "2001, Dec"
  "RGB* GRAY*"
  SF-IMAGE      _"Image"          0
  SF-DRAWABLE   _"Drawable"       0
  SF-ADJUSTMENT _"Threshold"      '(127 0 255 1 1 0 0)
  SF-OPTION     _"Target Channel" '("RGB (Value)" "Red" "Green" "Blue" "Alpha")
  SF-TOGGLE     _"Invert"         FALSE
  SF-TOGGLE     _"Value Change"   FALSE
)

;*************************************************************************************** 
; Scroll script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; --------------------------------------------------------------------
; version 0.1  by Iccii 2001/12/08
;     - Initial relase
;
; --------------------------------------------------------------------
; 
	;; Scroll

(define (script-fu-scroll-G2
			img
			drawable
			width
			height
			wrap-type
	)


  (let* (
	 (old-fg (car (gimp-palette-get-foreground)))
         (drawable-width (car (gimp-drawable-width drawable)))
         (drawable-height (car (gimp-drawable-height drawable)))
         (offset-x (min drawable-width width))		; <- needs abs
         (offset-y (min drawable-height  height))	; <- needs abs
        ) ; end variable definition

    (gimp-undo-push-group-start img)

    (cond ((= wrap-type 0)
             (gimp-drawable-offset drawable FALSE OFFSET-BACKGROUND offset-x offset-y))
          ((= wrap-type 1)
             (gimp-drawable-offset drawable FALSE OFFSET-TRANSPARENT offset-x offset-y))
          ((= wrap-type 2)
             (gimp-drawable-offset drawable TRUE OFFSET-TRANSPARENT offset-x offset-y))
          ((= wrap-type 3)
             (gimp-drawable-offset drawable FALSE OFFSET-TRANSPARENT offset-x offset-y)
             (gimp-rect-select img (if (> 0 offset-x) 0 offset-x)
                                   (if (> 0 offset-y) (+ drawable-height offset-y -1) offset-y)
                                   (- drawable-width (abs offset-x)) 1 REPLACE FALSE 0)
;             (set! float (car (gimp-selection-float drawable
;                                                    0 (if (> 0 offset-y) 0 (- offset-y)))))
      (let* (
            ( float (car (gimp-selection-float drawable
                                                0 (if (> 0 offset-y) 0 (- offset-y)))))
            ) ; end float definition                                    
             (gimp-floating-sel-to-layer float)

	;; gimp-layer-scale の最後を TRUE にするとレイヤーが正しく表示されるのに
	;; FALSE にするとレイヤーが遥か彼方に移動してしまうのはなぜ？
	;; しかも offset を負の数にした時だけ発生する
             (gimp-layer-scale float (- drawable-width (abs offset-x)) (+ (abs offset-y) 1) FALSE)

             (set! drawable (car (gimp-image-merge-down img float EXPAND-AS-NECESSARY)))
             (gimp-rect-select img (if (> 0 offset-x) (+ drawable-width offset-x -1) offset-x)
                                   (if (> 0 offset-y) 0 offset-y)
                                   1 (- drawable-height (abs offset-y)) REPLACE FALSE 0)
             (set! float (car (gimp-selection-float drawable
                                                    (if (> 0 offset-x) 0 (- offset-x)) 0)))
             (gimp-floating-sel-to-layer float)
             (gimp-layer-scale float (+ (abs offset-x) 1) (- drawable-height (abs offset-y)) FALSE)
             (set! drawable (car (gimp-image-merge-down img float EXPAND-AS-NECESSARY)))
             (gimp-rect-select img (if (> 0 offset-x) (+ drawable-width offset-x) 0)
                                   (if (> 0 offset-y) (+ drawable-height offset-y) 0)
                                   (abs offset-x) (abs offset-y) REPLACE FALSE 0)
             (gimp-color-picker img drawable
                                (if (> 0 offset-x) (+ drawable-width offset-x) offset-x)
                                (if (> 0 offset-y) (+ drawable-height offset-y) offset-y)
                                FALSE FALSE 1)  
             (gimp-edit-fill drawable FG-IMAGE-FILL)
             (gimp-selection-none img))
      ) ; end of let float       
    ) ; end of cond

    (gimp-palette-set-foreground old-fg)
    (gimp-undo-push-group-end img)
    (gimp-displays-flush)
))

(script-fu-register
  "script-fu-scroll-G2"
  _"<Image>/Filters/Decor/Photo Effects/The Others/Scroll..."
  "Apply scroll, which simulates Photoshop's Photocopy filter"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "2001, Dec"
  "RGB* GRAY*"
  SF-IMAGE      _"Image"       0
  SF-DRAWABLE   _"Drawable"    0
  SF-ADJUSTMENT	_"Offset X"    '(10 -1000 1000 1 1 0 1)
  SF-ADJUSTMENT	_"Offset Y"    '(10 -1000 1000 1 1 0 1)
  SF-OPTION     _"Wrap Method" '("BG Color" "Transparent"
                                 "Wrap Around" "Repeat Edge Pixels")
)

;*************************************************************************************** 
; Funky color script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; --------------------------------------------------------------------
; version 0.1  by Iccii 2001/12/03
;     - Initial relase
; version 0.1a by Iccii 2001/12/08
;     - Now only affects to selection area
;
; --------------------------------------------------------------------
; 

(define (apply-easy-glowing-effect
			img
			img-layer
			blur)

  (let* (
         (img-width (car (gimp-drawable-width img-layer)))
         (img-height (car (gimp-drawable-height img-layer)))
         (layer (car (gimp-layer-new img img-width img-height RGBA-IMAGE
                                           "Base Layer" 100 NORMAL-MODE)))
    	 (layer-copy (car (gimp-layer-copy layer TRUE)))
        )

    (gimp-image-resize img img-width img-height 0 0)
    (if (equal? (car (gimp-drawable-has-alpha img-layer)) FALSE)
        (gimp-layer-add-alpha img-layer))
    (gimp-image-add-layer img layer -1)
    (gimp-image-lower-layer img layer)
    (gimp-drawable-fill layer WHITE-IMAGE-FILL)
    (set! layer (car (gimp-image-merge-down img img-layer EXPAND-AS-NECESSARY)))
    (set! layer-copy (car (gimp-layer-copy layer TRUE)))
    (gimp-image-add-layer img layer-copy -1)
    (gimp-layer-set-mode layer-copy OVERLAY-MODE)
    (plug-in-gauss-iir2 1 img layer blur blur)
    (plug-in-gauss-iir2 1 img layer-copy (+ (/ blur 2) 1) (+ (/ blur 2) 1))
    (let* ((point-num 3)
           (control_pts (cons-array (* point-num 2) 'byte)))
       (aset control_pts 0 0)
       (aset control_pts 1 0)
       (aset control_pts 2 127)
       (aset control_pts 3 255)
       (aset control_pts 4 255)
       (aset control_pts 5 0)
       (gimp-curves-spline layer VALUE-LUT (* point-num 2) control_pts)
       (gimp-curves-spline layer-copy VALUE-LUT (* point-num 2) control_pts))
    (plug-in-gauss-iir2 1 img layer (+ (* blur 2) 1) (+ (* blur 2) 1))
    (let* ((point-num 4)
           (control_pts (cons-array (* point-num 2) 'byte)))
       (aset control_pts 0 0)
       (aset control_pts 1 0)
       (aset control_pts 2 63)
       (aset control_pts 3 255)
       (aset control_pts 4 191)
       (aset control_pts 5 0)
       (aset control_pts 6 255)
       (aset control_pts 7 255)
       (gimp-curves-spline layer VALUE-LUT (* point-num 2) control_pts)
       (gimp-curves-spline layer-copy VALUE-LUT (* point-num 2) control_pts))

    (list layer layer-copy)	; Return
  ) ; end of let*
) ; end of define



(define (script-fu-funky-color-alpha
			img
			layer
			blur
	)

  (gimp-undo-push-group-start img)
  (let* (
	 (old-fg (car (gimp-palette-get-foreground)))
	 (old-bg (car (gimp-palette-get-background)))
         (old-layer-name (car (gimp-layer-get-name layer)))
         (layer-list (apply-easy-glowing-effect img layer blur))
	) ; end variable definition

    (gimp-layer-set-name (car layer-list) old-layer-name)
    (gimp-layer-set-name (cadr layer-list) "Change layer mode")
    (if (equal? (car (gimp-selection-is-empty img)) FALSE)
        (begin
          (gimp-selection-invert img)
          (gimp-edit-clear (cadr layer-list))
          (gimp-selection-invert img)))
    (gimp-palette-set-foreground old-fg)
    (gimp-palette-set-background old-bg)
    (gimp-undo-push-group-end img)
    (gimp-displays-flush)))

(script-fu-register
  "script-fu-funky-color-alpha"
  _"<Image>/Filters/Decor/Photo Effects/Style/Funky Color..."
  "Create funky color logo image"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "2001, Dec"
  "RGB*"
  SF-IMAGE     "Image"		0
  SF-DRAWABLE  "Drawable"	0
  SF-ADJUSTMENT _"Blur Amount"	'(10 1 100 1 1 0 1)
)



;***************************************************************************************
; Cutout image script for GIMP 2.2
; Copyright (C) 2007 Eddy Verlinden <eddy_verlinden@hotmail.com>
;
; --------------------------------------------------------------------
; Fidelity added by Rob Antonishen


(define (script-fu-cutout-G2
img
drawable
colors
smoothness
fidelity
)

(gimp-undo-push-group-start img)

(let* (
(width (car (gimp-drawable-width drawable)))
(height (car (gimp-drawable-height drawable)))
(old-selection (car (gimp-selection-save img)))
(image-type (car (gimp-image-base-type img)))
(blur (/ (* width smoothness 0.001 ) fidelity))
(count 0)
(layer-lock (car (gimp-layer-get-lock-alpha drawable)))
(layer-type (car (gimp-drawable-type drawable)))
(layer-temp1 (car (gimp-layer-new img width height layer-type "temp1" 100 NORMAL-MODE)))
(img2 (car (gimp-image-new width height image-type)))
(layer-temp2 (car (gimp-layer-new img2 width height layer-type "temp2" 100 NORMAL-MODE)))
)

(if (eqv? (car (gimp-selection-is-empty img)) TRUE)
(gimp-drawable-fill old-selection WHITE-IMAGE-FILL)) ; so Empty and All are the same.
(gimp-selection-none img)
(gimp-drawable-fill layer-temp1 TRANS-IMAGE-FILL)
(gimp-image-add-layer img layer-temp1 -1)
(gimp-edit-copy drawable)
(gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp1 0)))


(gimp-layer-set-lock-alpha layer-temp1 TRUE)
(while (< count fidelity)
(plug-in-gauss 1 img layer-temp1 blur blur 0)
(set! count (+ count 1))
)
(gimp-layer-set-lock-alpha layer-temp1 layer-lock)

(gimp-edit-copy layer-temp1)

(gimp-image-add-layer img2 layer-temp2 -1)
(gimp-drawable-fill layer-temp2 TRANS-IMAGE-FILL)
(gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp2 0)))
(gimp-image-convert-indexed img2 0 0 colors 0 0 "0")
(gimp-edit-copy layer-temp2)
(gimp-image-delete img2)

(gimp-layer-add-alpha layer-temp1)
(gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp1 0)))

(gimp-selection-load old-selection)
(gimp-selection-invert img)
(if (eqv? (car (gimp-selection-is-empty img)) FALSE) ; both Empty and All are denied
(begin
(gimp-edit-clear layer-temp1)
))

(gimp-layer-set-name layer-temp1 "Cutout")
(gimp-selection-load old-selection)
(gimp-image-remove-channel img old-selection)


(gimp-undo-push-group-end img)
(gimp-displays-flush)
)
)

(script-fu-register
"script-fu-cutout-G2"
"<Image>/Filters/Decor/Photo Effects/Artist/Cutout..."
"Creates a drawing effect"
"Eddy Verlinden <eddy_verlinden@hotmail.com>"
"Eddy Verlinden"
"2007, juli"
"RGB* GRAY*"
SF-IMAGE "Image" 0
SF-DRAWABLE "Drawable" 0
SF-ADJUSTMENT "Colors" '(10 4 32 1 10 0 0)
SF-ADJUSTMENT "Smoothness" '(8 1 20 1 1 0 0)
SF-ADJUSTMENT "Fidelity" '(5 1 20 1 1 0 0)
)


;*************************************************************************************** 
; Color pencil image script  for GIMP 2.2
; Copyright (C) 2007 Eddy Verlinden <eddy_verlinden@hotmail.com>
; 
; --------------------------------------------------------------------


(define (script-fu-coloredpencil-G2
			img
			drawable
	)

  (gimp-undo-push-group-start img)

  (let* (
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
	 (old-selection (car (gimp-selection-save img)))
	 (image-type (car (gimp-image-base-type img)))
	 (layer-type (car (gimp-drawable-type drawable)))
	 (layer-temp1 (car (gimp-layer-new img width height layer-type "temp1"  100 NORMAL-MODE)))
        ) 

    (if (eqv? (car (gimp-selection-is-empty img)) TRUE)
        (gimp-drawable-fill old-selection WHITE-IMAGE-FILL)) ; so Empty and All are the same.
    (gimp-selection-none img)
    (gimp-drawable-fill layer-temp1 TRANS-IMAGE-FILL)
    (gimp-image-add-layer img layer-temp1 -1)
    (gimp-layer-add-alpha layer-temp1)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp1 0)))

    (plug-in-gimpressionist 1 img layer-temp1 "ev_coloredpencil.txt")
    (gimp-hue-saturation layer-temp1 0 0 0 60) 

    (gimp-selection-load old-selection)
    (gimp-selection-invert img)
    (if (eqv? (car (gimp-selection-is-empty img)) FALSE) ; both Empty and All are denied
        (begin
        (gimp-edit-clear layer-temp1)
        ))

    (gimp-layer-set-name layer-temp1 "Col Pencil")
    (gimp-selection-load old-selection)
    (gimp-image-remove-channel img old-selection)


    (gimp-undo-push-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script-fu-coloredpencil-G2"
  _"<Image>/Filters/Decor/Photo Effects/Artist/Color Pencil..."
  "Creates a drawing effect like made with colored pencils"
  "Eddy Verlinden <eddy_verlinden@hotmail.com>"
  "Eddy Verlinden"
  "2007, juli"
  "RGB* GRAY*"
  SF-IMAGE      "Image"	            0
  SF-DRAWABLE   "Drawable"          0
)

;*************************************************************************************** 
; Palette Knife image script  for GIMP 2.2
; Copyright (C) 2007 Eddy Verlinden <eddy_verlinden@hotmail.com>
; 
; --------------------------------------------------------------------


(define (script-fu-paletteknife-G2
			img
			drawable
	)

  (gimp-undo-push-group-start img)

  (let* (
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
	 (old-selection (car (gimp-selection-save img)))
	 (image-type (car (gimp-image-base-type img)))
	 (layer-type (car (gimp-drawable-type drawable)))
	 (layer-temp1 (car (gimp-layer-new img width height layer-type "temp1"  100 NORMAL-MODE)))
        ) 

    (if (eqv? (car (gimp-selection-is-empty img)) TRUE)
        (gimp-drawable-fill old-selection WHITE-IMAGE-FILL)) ; so Empty and All are the same.
    (gimp-selection-none img)
    (gimp-drawable-fill layer-temp1 TRANS-IMAGE-FILL)
    (gimp-image-add-layer img layer-temp1 -1)
    (gimp-layer-add-alpha layer-temp1)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp1 0)))

    (plug-in-gimpressionist 1 img layer-temp1 "ev_paletknife2.txt")
    (gimp-levels layer-temp1 0 0 255 0.5 0 255) 

    (gimp-selection-load old-selection)
    (gimp-selection-invert img)
    (if (eqv? (car (gimp-selection-is-empty img)) FALSE) ; both Empty and All are denied
        (begin
        (gimp-edit-clear layer-temp1)
        ))

    (gimp-layer-set-name layer-temp1 "Palette knife")
    (gimp-selection-load old-selection)
    (gimp-image-remove-channel img old-selection)


    (gimp-undo-push-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script-fu-paletteknife-G2"
  _"<Image>/Filters/Decor/Photo Effects/Artist/Palette Knife..."
  "Creates a drawing effect like made with a palette knife, based on the Gimpressionist."
  "Eddy Verlinden <eddy_verlinden@hotmail.com>"
  "Eddy Verlinden"
  "2007, juli"
  "RGB* GRAY*"
  SF-IMAGE      "Image"	            0
  SF-DRAWABLE   "Drawable"          0
)

;*************************************************************************************** 
; Angled Strokes image script  for GIMP 2.2
; Copyright (C) 2007 Eddy Verlinden <eddy_verlinden@hotmail.com>
; 
; --------------------------------------------------------------------


(define (script-fu-angledstrokes-G2
			img
			drawable
	)

  (gimp-undo-push-group-start img)

  (let* (
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
	 (old-selection (car (gimp-selection-save img)))
	 (image-type (car (gimp-image-base-type img)))
	 (layer-type (car (gimp-drawable-type drawable)))
	 (layer-temp1 (car (gimp-layer-new img width height layer-type "temp1"  100 NORMAL-MODE)))
        ) 

    (if (eqv? (car (gimp-selection-is-empty img)) TRUE)
        (gimp-drawable-fill old-selection WHITE-IMAGE-FILL)) ; so Empty and All are the same.
    (gimp-selection-none img)
    (gimp-drawable-fill layer-temp1 TRANS-IMAGE-FILL)
    (gimp-image-add-layer img layer-temp1 -1)
    (gimp-layer-add-alpha layer-temp1)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp1 0)))

    (plug-in-gimpressionist 1 img layer-temp1 "ev_angledstrokes.txt")
    (plug-in-unsharp-mask 1 img layer-temp1 5.0 1.0 0) 

    (gimp-selection-load old-selection)
    (gimp-selection-invert img)
    (if (eqv? (car (gimp-selection-is-empty img)) FALSE) ; both Empty and All are denied
        (begin
        (gimp-edit-clear layer-temp1)
        ))

    (gimp-layer-set-name layer-temp1 "Angled strokes")
    (gimp-selection-load old-selection)
    (gimp-image-remove-channel img old-selection)


    (gimp-undo-push-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script-fu-angledstrokes-G2"
  _"<Image>/Filters/Decor/Photo Effects/Brush/Angled strokes..."
  "Creates a drawing effect, based on the Gimpressionist."
  "Eddy Verlinden <eddy_verlinden@hotmail.com>"
  "Eddy Verlinden"
  "2007, juli"
  "RGB* GRAY*"
  SF-IMAGE      "Image"	            0
  SF-DRAWABLE   "Drawable"          0
)

;*************************************************************************************** 
; Crosshatch image script  for GIMP 2.2
; Copyright (C) 2007 Eddy Verlinden <eddy_verlinden@hotmail.com>
; 
; --------------------------------------------------------------------


(define (script-fu-crosshatch-G2
			img
			drawable
	)

  (gimp-undo-push-group-start img)

  (let* (
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
	 (old-selection (car (gimp-selection-save img)))
	 (image-type (car (gimp-image-base-type img)))
	 (layer-type (car (gimp-drawable-type drawable)))
	 (layer-temp1 (car (gimp-layer-new img width height layer-type "temp1"  100 NORMAL-MODE)))
        ) 

    (if (eqv? (car (gimp-selection-is-empty img)) TRUE)
        (gimp-drawable-fill old-selection WHITE-IMAGE-FILL)) ; so Empty and All are the same.
    (gimp-selection-none img)
    (gimp-drawable-fill layer-temp1 TRANS-IMAGE-FILL)
    (gimp-image-add-layer img layer-temp1 -1)
    (gimp-layer-add-alpha layer-temp1)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp1 0)))

    (plug-in-gimpressionist 1 img layer-temp1 "ev_crosshatched.txt")

    (gimp-selection-load old-selection)
    (gimp-selection-invert img)
    (if (eqv? (car (gimp-selection-is-empty img)) FALSE) ; both Empty and All are denied
        (begin
        (gimp-edit-clear layer-temp1)
        ))

    (gimp-layer-set-name layer-temp1 "Crosshatch")
    (gimp-selection-load old-selection)
    (gimp-image-remove-channel img old-selection)


    (gimp-undo-push-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script-fu-crosshatch-G2"
  _"<Image>/Filters/Decor/Photo Effects/Brush/Crosshatched..."
  "Creates a crosshatched blur effect, based on the Gimpressionist."
  "Eddy Verlinden <eddy_verlinden@hotmail.com>"
  "Eddy Verlinden"
  "2007, juli"
  "RGB* GRAY*"
  SF-IMAGE      "Image"	            0
  SF-DRAWABLE   "Drawable"          0
)

;*************************************************************************************** 
; Drawing script  for GIMP 2.2
; Copyright (C) 2007 Eddy Verlinden <eddy_verlinden@hotmail.com>
; 
; --------------------------------------------------------------------


(define (script-fu-drawing-G2
			img
			drawable
			thickness
	)

  (gimp-undo-push-group-start img)

  (let* (
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
	 (old-selection (car (gimp-selection-save img)))
         (thf (* height  0.005 thickness ))
	 (image-type (car (gimp-image-base-type img)))
	 (layer-type (car (gimp-drawable-type drawable)))
	 (layer-temp1 (car (gimp-layer-new img width height layer-type "temp1"  100 NORMAL-MODE)))
	 (layer-temp2 (car (gimp-layer-new img width height layer-type "temp2"  100 NORMAL-MODE)))
        ) 

    (if (eqv? (car (gimp-selection-is-empty img)) TRUE)
        (gimp-drawable-fill old-selection WHITE-IMAGE-FILL)) ; so Empty and All are the same.
    (gimp-selection-none img)
    (gimp-image-add-layer img layer-temp1 -1)
    (gimp-image-add-layer img layer-temp2 -1)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp1 0)))

    (if (eqv? (car (gimp-drawable-is-gray drawable)) FALSE)      
        (gimp-desaturate layer-temp1))
    (gimp-edit-copy layer-temp1)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp2 0)))
    (gimp-invert layer-temp2)
    (plug-in-gauss 1 img layer-temp2 thf thf 0)
    (gimp-layer-set-mode layer-temp2 16)
    (gimp-image-merge-down img layer-temp2 0)
    (set! layer-temp1 (car (gimp-image-get-active-layer img)))
    (gimp-levels layer-temp1 0 215 235 1.0 0 255) 

    (gimp-selection-load old-selection)
    (gimp-selection-invert img)
    (if (eqv? (car (gimp-selection-is-empty img)) FALSE) ; both Empty and All are denied
        (begin
        (gimp-edit-clear layer-temp1)
        ))

    (gimp-layer-set-name layer-temp1 "Drawing")
    (gimp-selection-load old-selection)
    (gimp-image-remove-channel img old-selection)


    (gimp-undo-push-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script-fu-drawing-G2"
  _"<Image>/Filters/Decor/Photo Effects/Artist/Drawing..."
  "Creates a drawing."
  "Eddy Verlinden <eddy_verlinden@hotmail.com>"
  "Eddy Verlinden"
  "2007, juli"
  "RGB* GRAY*"
  SF-IMAGE      "Image"	            0
  SF-DRAWABLE   "Drawable"          0
  SF-ADJUSTMENT "thickness"        '(2 1 5 1 1 0 0)
)

;*************************************************************************************** 
; Cartoon script  for GIMP 2.2
; Copyright (C) 2007 Eddy Verlinden <eddy_verlinden@hotmail.com>
; 
; --------------------------------------------------------------------


(define (script-fu-cartoon-G2
			img
			drawable
	)

  (gimp-undo-push-group-start img)

  (let* (
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
	 (old-selection (car (gimp-selection-save img)))
	 (image-type (car (gimp-image-base-type img)))
	 (layer-type (car (gimp-drawable-type drawable)))
	 (layer-temp1 (car (gimp-layer-new img width height layer-type "temp1"  100 NORMAL-MODE)))
	 (layer-temp2 (car (gimp-layer-new img width height layer-type "temp2"  100 NORMAL-MODE)))
        ) 

    (if (eqv? (car (gimp-selection-is-empty img)) TRUE)
        (gimp-drawable-fill old-selection WHITE-IMAGE-FILL)) ; so Empty and All are the same.
    (gimp-selection-none img)
    (gimp-image-add-layer img layer-temp1 -1)
    (gimp-image-add-layer img layer-temp2 -1)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp1 0)))
    (gimp-edit-copy layer-temp1)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp2 0)))

    (plug-in-photocopy 1 img layer-temp2 8.0 1.0 0.0 0.8)
    (gimp-levels layer-temp2 0 215 235 1.0 0 255) 
    (gimp-layer-set-mode layer-temp2 3)
    (gimp-levels layer-temp1 0 25 225 2.25 0 255) 
    (gimp-image-merge-down img layer-temp2 0)
    (set! layer-temp1 (car (gimp-image-get-active-layer img)))

    (gimp-selection-load old-selection)
    (gimp-selection-invert img)
    (if (eqv? (car (gimp-selection-is-empty img)) FALSE) ; both Empty and All are denied
        (begin
        (gimp-edit-clear layer-temp1)
        ))

    (gimp-layer-set-name layer-temp1 "Cartoon")
    (gimp-selection-load old-selection)
    (gimp-image-remove-channel img old-selection)


    (gimp-undo-push-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script-fu-cartoon-G2"
  _"<Image>/Filters/Decor/Photo Effects/Artist/Cartoon..."
  "Creates a light cartoon."
  "Eddy Verlinden <eddy_verlinden@hotmail.com>"
  "Eddy Verlinden"
  "2007, juli"
  "RGB* GRAY*"
  SF-IMAGE      "Image"	            0
  SF-DRAWABLE   "Drawable"          0
)

;*************************************************************************************** 
; Cartoon-2 script  for GIMP 2.2
; Copyright (C) 2007 Eddy Verlinden <eddy_verlinden@hotmail.com>
; 
; --------------------------------------------------------------------


(define (script-fu-cartoon2-G2
			img
			drawable
			colors
			smoothness
	)

  (gimp-undo-push-group-start img)

  (let* (
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
	 (old-selection (car (gimp-selection-save img)))
	 (image-type (car (gimp-image-base-type img)))
         (blur (* width  smoothness 0.002 ))
	 (layer-type (car (gimp-drawable-type drawable)))
	 (layer-temp1 (car (gimp-layer-new img width height layer-type "temp1"  100 NORMAL-MODE)))
 	 (layer-temp3 (car (gimp-layer-new img width height layer-type "temp3"  100 NORMAL-MODE)))
	 (layer-temp4 (car (gimp-layer-new img width height layer-type "temp4"  100 NORMAL-MODE)))
    	 (img2 (car (gimp-image-new width height image-type)))
	 (layer-temp2 (car (gimp-layer-new img2 width height layer-type "temp2"  100 NORMAL-MODE)))
       ) 

    (if (eqv? (car (gimp-selection-is-empty img)) TRUE)
        (gimp-drawable-fill old-selection WHITE-IMAGE-FILL)) ; so Empty and All are the same.
    (gimp-selection-none img)
    (gimp-drawable-fill layer-temp1 TRANS-IMAGE-FILL)
    (gimp-image-add-layer img layer-temp1 -1)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp1 0)))

    (plug-in-gauss 1 img layer-temp1 blur blur 0)
    (gimp-edit-copy layer-temp1)


    (gimp-image-add-layer img2 layer-temp2 -1)
    (gimp-drawable-fill layer-temp2 TRANS-IMAGE-FILL)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp2 0)))
    (gimp-image-convert-indexed img2 0 0 colors 0 0 "0")
    (gimp-edit-copy layer-temp2)
    (gimp-image-delete img2)


    (gimp-layer-add-alpha layer-temp1)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp1 0)))
;------------------------------------------------
    (gimp-image-add-layer img layer-temp3 -1)
    (gimp-image-add-layer img layer-temp4 -1)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp3 0)))

    (gimp-desaturate layer-temp3)
    (gimp-edit-copy layer-temp3)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp4 0)))
    (gimp-invert layer-temp4)
    (plug-in-gauss 1 img layer-temp4 4 4 0)
    (gimp-layer-set-mode layer-temp4 16)
    (gimp-image-merge-down img layer-temp4 0)
    (set! layer-temp3 (car (gimp-image-get-active-layer img)))
    (gimp-levels layer-temp3 0 215 235 1.0 0 255) 
    (gimp-layer-set-mode layer-temp3 3)    
;------------------------------------------------
    (gimp-image-merge-down img layer-temp3 0)
    (set! layer-temp1 (car (gimp-image-get-active-layer img)))


    (gimp-selection-load old-selection)
    (gimp-selection-invert img)
    (if (eqv? (car (gimp-selection-is-empty img)) FALSE) ; both Empty and All are denied
        (begin
        (gimp-edit-clear layer-temp1)
        ))

    (gimp-layer-set-name layer-temp1 "Toon")
    (gimp-selection-load old-selection)
    (gimp-image-remove-channel img old-selection)


    (gimp-undo-push-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script-fu-cartoon2-G2"
  _"<Image>/Filters/Decor/Photo Effects/Artist/Cartoon2..."
  "Creates a drawing effect"
  "Eddy Verlinden <eddy_verlinden@hotmail.com>"
  "Eddy Verlinden"
  "2007, juli"
  "RGB* GRAY*"
  SF-IMAGE      "Image"	            0
  SF-DRAWABLE   "Drawable"          0
  SF-ADJUSTMENT "Colors"            '(8 4 32 1 10 0 0)
  SF-ADJUSTMENT "Smoothness"        '(8 1 20 1 1 0 0)
)




;*************************************************************************************** 
; Inkpen script  for GIMP 2.2
; Copyright (C) 2007 Eddy Verlinden <eddy_verlinden@hotmail.com>
; 
; --------------------------------------------------------------------


(define (script-fu-inkpen-G2
			img
			drawable
			color
			lightness
			length
			outlines?
      grid?
	)

  (gimp-undo-push-group-start img)

  (let* (
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
	 (old-selection (car (gimp-selection-save img)))
	 (image-type (car (gimp-image-base-type img)))
         (blur (* height  0.01 ))
         (gridcolor '(128 128 255))
	 (layer-type (car (gimp-drawable-type drawable)))
	 (layer-tempa (car (gimp-layer-new img width height layer-type "tempa"  100 NORMAL-MODE)))
	 (layer-tempb (car (gimp-layer-new img width height layer-type "tempb"  100 NORMAL-MODE)))
 	 (layer-tempc (car (gimp-layer-new img width height layer-type "tempc"  100 NORMAL-MODE)))
	 (layer-tempd (car (gimp-layer-new img width height layer-type "tempd"  100 NORMAL-MODE)))
 	 (layer-tempe (car (gimp-layer-new img width height layer-type "tempe"  100 NORMAL-MODE)))
 	 (layer-tempf (car (gimp-layer-new img width height layer-type "tempf"  100 NORMAL-MODE)))
 	 (layer-tempg (car (gimp-layer-new img width height layer-type "tempg"  100 NORMAL-MODE)))
       ) 

    (if (eqv? (car (gimp-selection-is-empty img)) TRUE)
        (gimp-drawable-fill old-selection WHITE-IMAGE-FILL)) ; so Empty and All are the same.
    (gimp-selection-none img)

;------------------------------------------------

 
    (gimp-drawable-fill layer-tempb WHITE-IMAGE-FILL)
    (gimp-image-add-layer img layer-tempb -1)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-tempb 0)))
    (gimp-hue-saturation layer-tempb 0 0 lightness 0)
    (gimp-threshold layer-tempb 125 255)

    (gimp-drawable-fill layer-tempa WHITE-IMAGE-FILL)
    (gimp-image-add-layer img layer-tempa -1)
    (plug-in-randomize-hurl 1 img layer-tempa 25 1 1 10)
    (plug-in-mblur 1 img layer-tempa 0 length 135 1 0)
    (gimp-threshold layer-tempa 215 230)

    (gimp-drawable-fill layer-tempd WHITE-IMAGE-FILL)
    (gimp-image-add-layer img layer-tempd -1)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-tempd 0)))
    (gimp-hue-saturation layer-tempd 0 0 lightness 0)
    (gimp-threshold layer-tempd 75 255)

    (gimp-drawable-fill layer-tempc WHITE-IMAGE-FILL)
    (gimp-image-add-layer img layer-tempc -1)
    (plug-in-randomize-hurl 1 img layer-tempc 25 1 1 10)
    (plug-in-mblur 1 img layer-tempc 0 length 45 0 0)
    (gimp-threshold layer-tempc 215 230)

    (gimp-layer-set-mode layer-tempa 10)
    (gimp-layer-set-mode layer-tempc 10)

    (gimp-image-merge-down img layer-tempc 0)
    (set! layer-tempc (car (gimp-image-get-active-layer img)))
    (gimp-layer-set-mode layer-tempc 3)

    (gimp-image-merge-down img layer-tempa 0)
    (set! layer-tempa (car (gimp-image-get-active-layer img)))
    (gimp-layer-set-mode layer-tempa 0)


    (gimp-image-merge-down img layer-tempc 0)
    (set! layer-tempa (car (gimp-image-get-active-layer img)))
    (gimp-layer-set-mode layer-tempa 0)
;------------------------------------------------
    (if (eqv? outlines? TRUE)
        (begin
    (gimp-image-add-layer img layer-tempe -1)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-tempe 0)))
    (plug-in-photocopy 1 img layer-tempe 5.0 1.0 0.0 0.8)
    (gimp-levels layer-tempe 0 215 235 1.0 0 255) 
    (gimp-layer-set-mode layer-tempe 3)
    (gimp-image-merge-down img layer-tempe 0)
    (set! layer-tempa (car (gimp-image-get-active-layer img)))
      ))
;------------------------------------------------
    (gimp-context-set-foreground color)
    (gimp-drawable-fill layer-tempf 0)
    (gimp-image-add-layer img layer-tempf -1)
    (gimp-layer-set-mode layer-tempf 4)
    (gimp-image-merge-down img layer-tempf 0)
    (set! layer-tempa (car (gimp-image-get-active-layer img)))

 ;------------------------------------------------
    (if (eqv? grid? TRUE)
        (begin
    (gimp-drawable-fill layer-tempg WHITE-IMAGE-FILL)
    (gimp-image-add-layer img layer-tempg -1)
    (gimp-image-lower-layer img layer-tempg)
    (plug-in-grid 1 img layer-tempg 1 16 8 gridcolor 64 1 16 8 gridcolor 64 0 2 6 gridcolor 128)
    (plug-in-gauss 1 img layer-tempg 0.5 0.5 0)

    (gimp-layer-set-mode layer-tempa 9)
    (gimp-image-merge-down img layer-tempa 0)
    (set! layer-tempa (car (gimp-image-get-active-layer img)))
	))
;------------------------------------------------

    (gimp-selection-load old-selection)
    (gimp-selection-invert img)
    (if (eqv? (car (gimp-selection-is-empty img)) FALSE) ; both Empty and All are denied
        (begin
        (gimp-edit-clear layer-tempa)
        ))

    (gimp-layer-set-name layer-tempa "Inkpen")
    (gimp-selection-load old-selection)
    (gimp-image-remove-channel img old-selection)


    (gimp-undo-push-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script-fu-inkpen-G2"
  _"<Image>/Filters/Decor/Photo Effects/Artist/Inkpen..."
  "Creates a inkpen drawing effect"
  "Eddy Verlinden <eddy_verlinden@hotmail.com>"
  "Eddy Verlinden"
  "2007, juli"
  "RGB* GRAY*"
  SF-IMAGE      "Image"	            0
  SF-DRAWABLE   "Drawable"          0
  SF-COLOR      "Ink Color"       '(0 0 0)
  SF-ADJUSTMENT "Lightness"       '(0 -100 100 1 10 0 0)
  SF-ADJUSTMENT "Stroke length"   '(30 10 50 1 10 0 0)
  SF-TOGGLE     "Outlines"  TRUE
  SF-TOGGLE     "Blue grid" TRUE
)


;*************************************************************************************** 
; Conte image script  for GIMP 2.2
; Copyright (C) 2007 Eddy Verlinden <eddy_verlinden@hotmail.com>
; 
; --------------------------------------------------------------------


(define (script-fu-conte-G2
			img
			drawable
			brightness
			contrast
			wild?
			canvas?
	)

  (gimp-undo-push-group-start img)

  (let* (
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
	 (old-selection (car (gimp-selection-save img)))
	 (image-type (car (gimp-image-base-type img)))
	 (layer-type (car (gimp-drawable-type drawable)))
	 (layer-tempa (car (gimp-layer-new img width height layer-type "tempa"  100 NORMAL-MODE)))
	 (layer-tempb (car (gimp-layer-new img width height layer-type "tempb"  100 NORMAL-MODE)))
	 (layer-tempc (car (gimp-layer-new img width height layer-type "tempc"  100 NORMAL-MODE)))
	 (layer-tempd (car (gimp-layer-new img width height layer-type "tempd"  100 NORMAL-MODE)))
	 (layer-tempe (car (gimp-layer-new img width height layer-type "tempe"  100 NORMAL-MODE)))
	 (img2 (car (gimp-image-new width height image-type)))
	 (layer-temp2 (car (gimp-layer-new img2 width height layer-type "temp2" 100 NORMAL-MODE)))
        ) 

    (if (eqv? (car (gimp-selection-is-empty img)) TRUE)
        (gimp-drawable-fill old-selection WHITE-IMAGE-FILL)) ; so Empty and All are the same.
    (gimp-selection-none img)
;-------------------------------------------------------
    (if (eqv? (car (gimp-palettes-get-list "conte_ev8")) 0)
    (begin
    (gimp-palette-new "conte_ev8")
    (gimp-palette-add-entry "conte_ev8" "1" '(117 96 91))
    (gimp-palette-add-entry "conte_ev8" "2" '(139 91 87))
    (gimp-palette-add-entry "conte_ev8" "3" '(164 91 85))
    (gimp-palette-add-entry "conte_ev8" "4" '(185 103 89))
    (gimp-palette-add-entry "conte_ev8" "5" '(240 238 239))
    (gimp-palette-add-entry "conte_ev8" "6" '(205 212 220))
    (gimp-palette-add-entry "conte_ev8" "7" '(90 93 100))
    (gimp-palette-add-entry "conte_ev8" "8" '(51 51 51))
    ))
    (if (> (car (gimp-palettes-get-list "conte_ev8 ")) 0)
        (gimp-message "There is/are palette(s) 'conte_ev8 *'. The best is to delete all palettes 'conte_ev8' (in the dialog 'palettes'). A new original will be created the next time this script is activated"))
    (if (> (car (gimp-palettes-get-list "conte_ev8#")) 0)
        (gimp-message "There is/are palette(s) 'conte_ev8#'. The best is to delete all palettes 'conte_ev8' (in the dialog 'palettes'). A new original will be created the next time this script is activated"))
;-------------------------------------------------------
    (gimp-drawable-fill layer-tempa TRANS-IMAGE-FILL)
    (gimp-image-add-layer img layer-tempa -1)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-tempa 0)))
    (gimp-drawable-fill layer-tempb TRANS-IMAGE-FILL)
    (gimp-image-add-layer img layer-tempb -1)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-tempb 0)))

    (plug-in-neon 1 img layer-tempa 5.0 0)
    (gimp-invert layer-tempa)
    (gimp-desaturate layer-tempa)

    (gimp-brightness-contrast layer-tempb (* brightness 1.25) (* contrast 1.25))
    (plug-in-gauss 1 img layer-tempb 2.0 2.0 0)
    (gimp-image-add-layer img layer-tempc -1)
    (gimp-edit-copy layer-tempb)

    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-tempc 0)))
    (plug-in-gimpressionist 1 img layer-tempc "ev_strokes45r.txt")
    (plug-in-dog 1 img layer-tempc 7.0 2.0 TRUE TRUE)
    (gimp-threshold layer-tempc 250 255)

    (gimp-layer-set-mode layer-tempc 3)
    (gimp-layer-set-mode layer-tempb 3)
    (gimp-image-merge-down img layer-tempc 0)
    (set! layer-tempb (car (gimp-image-get-active-layer img)))
    (gimp-image-merge-down img layer-tempb 0)
    (set! layer-tempa (car (gimp-image-get-active-layer img)))
    (gimp-edit-copy layer-tempa)

;    (set! img2 (car (gimp-image-new width height image-type)))
;    (set! layer-temp2 (car (gimp-layer-new img2 width height layer-type "temp2"  100 NORMAL-MODE)))
    (gimp-image-add-layer img2 layer-temp2 -1)
    (gimp-drawable-fill layer-temp2 TRANS-IMAGE-FILL)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp2 0)))
    (gimp-image-convert-indexed img2 0 4 0 0 0 "conte_ev8")
    (gimp-edit-copy layer-temp2)
    (gimp-image-delete img2)

    (gimp-layer-add-alpha layer-tempa)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-tempa 0)))
    (gimp-image-add-layer img layer-tempd -1)
    (gimp-edit-copy layer-tempa)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-tempd 0)))
    (if (eqv? wild? TRUE)
        (begin
    (plug-in-gimpressionist 1 img layer-tempd "graphite2.txt")
      ))
    (gimp-layer-set-mode layer-tempd 19)
    (gimp-image-merge-down img layer-tempd 0)
    (set! layer-tempa (car (gimp-image-get-active-layer img)))

    (if (eqv? canvas? TRUE)
        (begin
    (gimp-image-add-layer img layer-tempe -1)
    (gimp-context-set-foreground '(234 220 190))
    (gimp-drawable-fill layer-tempe 0)
    (plug-in-apply-canvas 1 img layer-tempe 1 1)
    (gimp-layer-set-mode layer-tempa 9)
    (gimp-image-lower-layer img layer-tempe)
    (gimp-image-merge-down img layer-tempa 0)
    (set! layer-tempa (car (gimp-image-get-active-layer img)))
       ))

;-------------------------------------------------------
    (gimp-selection-load old-selection)
    (gimp-selection-invert img)
    (if (eqv? (car (gimp-selection-is-empty img)) FALSE) ; both Empty and All are denied
        (begin
        (gimp-edit-clear layer-tempa)
        ))

    (gimp-layer-set-name layer-tempa "Conte")
    (gimp-selection-load old-selection)
    (gimp-image-remove-channel img old-selection)


    (gimp-undo-push-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "script-fu-conte-G2"
  _"<Image>/Filters/Decor/Photo Effects/Artist/Conte..."
  "Creates an image that looks like a conte sketch."
  "Eddy Verlinden <eddy_verlinden@hotmail.com>"
  "Eddy Verlinden"
  "2007, juli"
  "RGB* GRAY*"
  SF-IMAGE      "Image"	            0
  SF-DRAWABLE   "Drawable"          0
  SF-ADJUSTMENT "Brightness"        '(50 -100 100 1 10 0 0)
  SF-ADJUSTMENT "Contrast"          '(80 -100 100 1 10 0 0)
  SF-TOGGLE     "Wild" TRUE
  SF-TOGGLE     "Canvas" TRUE
)


;*************************************************************************************** 
;*************************************************************************************** 
;*************************************************************************************** 
;*************************************************************************************** 
;*************************************************************************************** 
