;SMARTOSC - TUANNA
;File: charcoal.scm
;Function: smartosc-charcoal
;param

(define (smartosc-charcoal
            ;img inLayer;input/output
            imgURL inLayerURL ;url to file input/output
            photocopyMaskRadius photocopySharpness photocopyPercentBlack photocopyPercentWhite)
    (let* 
    (
        ;start proccessing img from input url - comment 2 rows below if using img inLayer variables
        (img (car (gimp-file-load RUN-NONINTERACTIVE imgURL imgURL))) ;load img from imgURL
        (inLayer (car (gimp-image-get-active-layer img)))
        ;end processing img from input url
        
        (width (car (gimp-drawable-width inLayer)))
        (x_off (min (trunc (/ width 2)) 200))
        (height (car (gimp-drawable-height inLayer)))
        (y_off (min (trunc (/ height 2)) 200))
        (layers 0)
        (layercount 0)
        (counter 0)
        (buffname "tilablebuf")
        ;important variables
        (tileImage 0)
        (tileLayer 0)
        (tileLayer2 0)
    )
    
    (gimp-image-undo-group-start img)
    (set! tileImage (car (gimp-image-duplicate img)))
    (gimp-image-undo-disable tileImage)
    (set! tileLayer (car (gimp-image-get-active-layer tileImage)))
    (set! layers (cadr (gimp-image-get-layers tileImage)))
    (set! layercount (car (gimp-image-get-layers tileImage)))
    
    ;get rid of all other layers
    (while (< counter layercount)
      (if (<> (vector-ref layers counter) tileLayer)
        (gimp-image-remove-layer tileImage (vector-ref layers counter))
      )
      (set! counter (+ 1 counter))
    )
    
    ;offfset before tiling
    (gimp-drawable-offset tileLayer TRUE OFFSET-BACKGROUND x_off y_off)
    
    ;tile enlarges the image
    (plug-in-tile RUN-NONINTERACTIVE tileImage tileLayer (+ width x_off x_off) (+ height y_off y_off) FALSE)
    
    ;beginning Step by step
    
    ;step 1: call plug-in-photocopy function (Filters / Artistic / Photocopy...)
    (plug-in-photocopy RUN-NONINTERACTIVE tileImage tileLayer photocopyMaskRadius photocopySharpness photocopyPercentBlack photocopyPercentWhite)
    ;step 2: set normal mode.
    (gimp-layer-set-mode tileLayer NORMAL-MODE)
    ;step 3: new layer with color: #000000, opacity 10, Grain merge mode
    (gimp-palette-set-foreground '(255 255 255))
    (gimp-palette-set-background '(255 255 255))
    (set! tileLayer2 (car (gimp-layer-new tileImage width height RGB "New Layer" 10 GRAIN-MERGE-MODE)))
    (gimp-image-add-layer tileImage tileLayer2 0)
    (gimp-edit-fill tileLayer2 BG-IMAGE-FILL)
    
    ;end step by step
    
    ;select the center area
    (gimp-rect-select tileImage x_off y_off width height CHANNEL-OP-REPLACE FALSE 0)
    (set! buffname (car (gimp-edit-named-copy tileLayer buffname)))
    (gimp-floating-sel-anchor (car (gimp-edit-named-paste inLayer buffname FALSE)))
    
    ;save file to inLayerURL - comment if using img inLayer variables
    (gimp-file-save RUN-NONINTERACTIVE tileImage inLayer inLayerURL inLayerURL)
    
    ;clean-up
    (gimp-image-delete tileImage)
    (gimp-image-undo-group-end img)
    (gimp-drawable-update inLayer 0 0 width height)
    (gimp-displays-flush)
  )
)

;register the function with GIMP
(script-fu-register
                    "smartosc-charcoal"                 ;function name
                    _"Charcoal Effect"                  ;menu label
                    "Adding an Antique Photo Border"    ;description
                    "Nguyen Anh Tuan"                   ;author
                    "tuanna <tuanna@smartosc.com>"      ;copyright
                    "18/06/2012"                        ;date created
                    "*"                                 ;image type that the script works on
                    SF-IMAGE       "Input image"          0
                    SF-DRAWABLE    "Input drawable"       0
                    ;SF-STRING       "Input image"          "" ;url input
                    ;SF-STRING       "Output image"       "" ;url output
                    SF-ADJUSTMENT _"Photocopy Mask Radius"      '(12 3 50 0.01 1 2 1)  ;'(value lower upper step_inc page_inc digits type)
                    SF-ADJUSTMENT _"Photocopy Sharpness"        '(1 0 1 0.001 0.01 3 1)
                    SF-ADJUSTMENT _"Photocopy Percent Black"    '(0.2 0 1 0.001 0.01 3 1)
                    SF-ADJUSTMENT _"Photocopy Percent White"    '(0.5 0 1 0.001 0.01 3 1)
)
;register
(script-fu-menu-register "smartosc-charcoal" _"<Image>/SmartOSC")