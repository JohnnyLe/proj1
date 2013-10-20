;SMARTOSC - TUANNA
;File: unitedcolors3.scm
;Function: smartosc-unitedcolors3
;param

(define (smartosc-unitedcolors3
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
    (gimp-levels inLayer 0 90 190 0.9 0 255)
    (gimp-desaturate inLayer)
    (plug-in-colortoalpha RUN-NONINTERACTIVE img inLayer '(255 255 255))
    (gimp-invert inLayer)
    (define newLayer)
    (gimp-palette-set-background '(147 26 17))
    (set! newLayer (car (gimp-layer-new img width height RGB "New Layer" 100 NORMAL-MODE)))
    (gimp-image-add-layer img newLayer 1)
    (gimp-edit-fill newLayer BG-IMAGE-FILL)
    (plug-in-colorify RUN-NONINTERACTIVE img inLayer '(198 248 127))
        
    ;save file to inLayerURL - comment if using img inLayer variables
    (define result-layer)
    (set! result-layer (car (gimp-image-merge-visible-layers img EXPAND-AS-NECESSARY)))
    (gimp-file-save RUN-NONINTERACTIVE img result-layer inLayerURL inLayerURL)
    
    ;clean-up
    (gimp-image-undo-group-end img)
    (gimp-image-delete img) ;uncomment if you save the output to file
    (gimp-displays-flush)
  )
)

;register the function with GIMP
(script-fu-register
                    "smartosc-unitedcolors3"                  ;function name
                    _"United Colors Effect 3"                   ;menu label
                    "United Colors Effect 3"                    ;description
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
(script-fu-menu-register "smartosc-unitedcolors3" _"<Image>/SmartOSC")