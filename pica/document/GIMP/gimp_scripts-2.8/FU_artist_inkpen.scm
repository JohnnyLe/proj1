; FU_artist_inkpen.scm
; version 2.7 [gimphelp.org]
; last modified/tested by Paul Sherman
; 05/05/2012 on GIMP-2.8
;
; ------------------------------------------------------------------
; Original information ---------------------------------------------
;
; Inkpen script  for GIMP 2.2
; Copyright (C) 2007 Eddy Verlinden <eddy_verlinden@hotmail.com>
; 
; --------------------------------------------------------------------
; End original information ------------------------------------------
;--------------------------------------------------------------------

(define (FU-inkpen
			img
			drawable
			color
			lightness
			length
			outlines?
      grid?
	)

  (gimp-image-undo-group-start img)

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

 
    (gimp-drawable-fill layer-tempb WHITE-IMAGE-FILL)
    (gimp-image-insert-layer img layer-tempb 0 -1)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-tempb 0)))
    (gimp-hue-saturation layer-tempb 0 0 lightness 0)
    (gimp-threshold layer-tempb 125 255)

    (gimp-drawable-fill layer-tempa WHITE-IMAGE-FILL)
    (gimp-image-insert-layer img layer-tempa 0 -1)
    (plug-in-randomize-hurl 1 img layer-tempa 25 1 1 10)
    (plug-in-mblur 1 img layer-tempa 0 length 135 1 0)
    (gimp-threshold layer-tempa 215 230)

    (gimp-drawable-fill layer-tempd WHITE-IMAGE-FILL)
    (gimp-image-insert-layer img layer-tempd 0 -1)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-tempd 0)))
    (gimp-hue-saturation layer-tempd 0 0 lightness 0)
    (gimp-threshold layer-tempd 75 255)

    (gimp-drawable-fill layer-tempc WHITE-IMAGE-FILL)
    (gimp-image-insert-layer img layer-tempc 0 -1)
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
    (gimp-image-insert-layer img layer-tempe 0 -1)
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
    (gimp-image-insert-layer img layer-tempf 0 -1)
    (gimp-layer-set-mode layer-tempf 4)
    (gimp-image-merge-down img layer-tempf 0)
    (set! layer-tempa (car (gimp-image-get-active-layer img)))

 ;------------------------------------------------
    (if (eqv? grid? TRUE)
        (begin
    (gimp-drawable-fill layer-tempg WHITE-IMAGE-FILL)
    (gimp-image-insert-layer img layer-tempg 0 -1)
    (gimp-image-lower-item img layer-tempg)
    (plug-in-grid 1 img layer-tempg 1 16 8 gridcolor 64 1 16 8 gridcolor 64 0 2 6 gridcolor 128)
    (plug-in-gauss 1 img layer-tempg 0.5 0.5 0)

    (gimp-layer-set-mode layer-tempa 9)
    (gimp-image-merge-down img layer-tempa 0)
    (set! layer-tempa (car (gimp-image-get-active-layer img)))
	))
;------------------------------------------------

    (gimp-image-select-item img CHANNEL-OP-REPLACE old-selection)
    (gimp-selection-invert img)
    (if (eqv? (car (gimp-selection-is-empty img)) FALSE) ; both Empty and All are denied
        (begin
        (gimp-edit-clear layer-tempa)
        ))

    (gimp-item-set-name layer-tempa "Inkpen")
    (gimp-image-select-item img CHANNEL-OP-REPLACE old-selection)
    (gimp-image-remove-channel img old-selection)


    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register "FU-inkpen"
	"<Image>/Script-Fu/Artist/Inkpen"
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

