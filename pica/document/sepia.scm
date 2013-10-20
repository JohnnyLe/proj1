;SMARTOSC - TUANNA
;File: sepia.scm
;Function: smartosc-sepia
;param

(define (smartosc-sepia
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
    (plug-in-sel-gauss RUN-NONINTERACTIVE img inLayer 1 50)
    
    (gimp-layer-set-mode inLayer NORMAL-MODE)
 
    (define newLayer)
    (set! newLayer ( car (gimp-layer-copy inLayer 1)))
    (gimp-image-add-layer img newLayer 0)
    (gimp-hue-saturation newLayer 0 0 0 -100) 
    
    (gimp-layer-set-mode newLayer NORMAL-MODE)
    (gimp-layer-set-opacity newLayer 20)
    (define newLayer3)
    (gimp-palette-set-background '(114 90 56))
    (set! newLayer3 (car (gimp-layer-new img width height RGB "New Layer 3" 100 COLOR-MODE)))
    (gimp-image-add-layer img newLayer3 0)
    (gimp-edit-fill newLayer3 BG-IMAGE-FILL)
    
    
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
                    "smartosc-sepia"                  ;function name
                    _"Sepia Effect"                   ;menu label
                    "Sepia Effect"                    ;description
                    "Nguyen Anh Tuan"                   ;author
                    "tuanna <tuanna@smartosc.com>"      ;copyright
                    "20/06/2012"                        ;date created
                    "*"                                 ;image type that the script works on
                    ;SF-IMAGE        "Input image"                   0
                    ;SF-DRAWABLE     "Input drawable"                0
                    SF-STRING      "Input image"                   "" ;url input
                    SF-STRING      "Output image"                  "" ;url output
)
;register
(script-fu-menu-register "smartosc-sepia" _"<Image>/SmartOSC")