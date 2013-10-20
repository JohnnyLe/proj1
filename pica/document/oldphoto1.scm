;SMARTOSC - TUANNA
;File: oldphoto1.scm
;Function: smartosc-oldphoto1
;param

(define (smartosc-oldphoto1
            ;img inLayer;input/output
            imgURL inLayerURL ;url to file input/output
        )
    (let* 
        (
            ;start proccessing img from input url - comment 2 rows below if using img inLayer variables
            (img (car (gimp-file-load RUN-NONINTERACTIVE imgURL imgURL))) ;load img from imgURL
            (inLayer (car (gimp-image-get-active-layer img)))
            ;end processing img from input url
            (width (car (gimp-drawable-width inLayer)))
            (height (car (gimp-drawable-height inLayer)))
        )
        
    (gimp-image-undo-group-start img)
    
    ;beginning Step by step
    
    ;step 1: Open image and select layer 1: Filters / Decor / Old Photo...
    ;Defocus: check / Border size: 0 / Sepia: uncheck / Mottle: check / Work on copy: uncheck.
    (define theActiveLayer)
    (set! theActiveLayer (car (gimp-image-get-active-layer img)))
    (script-fu-old-photo img theActiveLayer TRUE 0 FALSE TRUE FALSE)
    (set! theActiveLayer (car (gimp-image-flatten img)))
    
    ;step 2: Create a New layer >>> layer 2: fill: #dbb77f. Raise on top. Layer mode: Multiply / Opacity: 100
    (define tileLayer2)
    (gimp-palette-set-foreground '(219 183 127))
    (gimp-palette-set-background '(219 183 127))
    (set! tileLayer2 (car (gimp-layer-new img width height RGB "New Layer" 100 MULTIPLY-MODE)))
    (gimp-image-add-layer img tileLayer2 0)
    (gimp-edit-fill tileLayer2 BG-IMAGE-FILL)
    
    ;step 3: Select layer 1: Colors / Desaturate... / Lightness
    (gimp-desaturate theActiveLayer)
    
    ;step 4: Colors / Levels...Channel: Value / Input Levels: 50 - 1.35 - 255
    (gimp-levels theActiveLayer 0 50 255 1.35 0 255)
    
    ;end step by step
    
    ;save file to inLayerURL - comment if using img inLayer variables
    (define result-layer)
    (set! result-layer (car (gimp-image-merge-visible-layers img EXPAND-AS-NECESSARY)))
    (gimp-file-save RUN-NONINTERACTIVE img result-layer inLayerURL inLayerURL)
    
    ;clean-up
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
  )
)

;register the function with GIMP
(script-fu-register
                    "smartosc-oldphoto1"                  ;function name
                    _"Old Photo Effect 1"                   ;menu label
                    "Old Photo Effect 1"                    ;description
                    "Nguyen Anh Tuan"                   ;author
                    "tuanna <tuanna@smartosc.com>"      ;copyright
                    "18/06/2012"                        ;date created
                    "*"                                 ;image type that the script works on
                    ;SF-IMAGE        "Input image"                   0
                    ;SF-DRAWABLE     "Input drawable"                0
                    SF-STRING      "Input image"                   "" ;url input
                    SF-STRING      "Output image"                  "" ;url output
)
;register
(script-fu-menu-register "smartosc-oldphoto1" _"<Image>/SmartOSC")