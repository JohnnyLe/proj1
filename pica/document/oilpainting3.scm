;SMARTOSC - TUANNA
;File: oilpainting3.scm
;Function: smartosc-oilpainting3
;param

(define (smartosc-oilpainting3
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
    
    (plug-in-lic RUN-NONINTERACTIVE img inLayer)    
    
    (plug-in-apply-canvas RUN-NONINTERACTIVE img inLayer 0 2)
    
    (gimp-hue-saturation inLayer 0 0 -5 -10)
    
    
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
                    "smartosc-oilpainting3"                  ;function name
                    _"Oil Painting Effect 3"                   ;menu label
                    "Oil Painting Effect 3"                    ;description
                    "Nguyen Anh Tuan"                   ;author
                    "tuanna <tuanna@smartosc.com>"      ;copyright
                    "21/06/2012"                        ;date created
                    "*"                                 ;image type that the script works on
                    ;SF-IMAGE        "Input image"                   0
                    ;SF-DRAWABLE     "Input drawable"                0
                    SF-STRING      "Input image"                   "" ;url input
                    SF-STRING      "Output image"                  "" ;url output
)
;register
(script-fu-menu-register "smartosc-oilpainting3" _"<Image>/SmartOSC")