;SMARTOSC - TUANNA
;File: oilpainting2.scm
;Function: smartosc-oilpainting2
;param

(define (smartosc-oilpainting2
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
    (gimp-hue-saturation inLayer 0 0 0 30)
    (plug-in-oilify RUN-NONINTERACTIVE img inLayer 5 1)
    
    (gimp-brightness-contrast inLayer 35 90)
    
    (define newLayer)
    (gimp-palette-set-background '(255 0 0))
    (set! newLayer (car (gimp-layer-new img width height RGB "New Layer" 100 DODGE-MODE)))
    (gimp-image-add-layer img newLayer 0)
    (gimp-edit-fill newLayer BG-IMAGE-FILL)
    
    (define newLayer2)
    (set! newLayer2 ( car (gimp-layer-copy inLayer TRUE)))
    (gimp-image-add-layer img newLayer2 0)
    (gimp-layer-set-mode newLayer2 VALUE-MODE)
    (gimp-layer-set-opacity newLayer2 35)
    
    (plug-in-gauss-rle2 1 img inLayer 2 2)
    
    
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
                    "smartosc-oilpainting2"                  ;function name
                    _"Oil Painting Effect 2"                   ;menu label
                    "Oil Painting Effect 2"                    ;description
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
(script-fu-menu-register "smartosc-oilpainting2" _"<Image>/SmartOSC")