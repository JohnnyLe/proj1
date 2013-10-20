;SMARTOSC - TUANNA
;File: unitedcolors1.scm
;Function: smartosc-unitedcolors1
;param

(define (smartosc-unitedcolors1
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
    (gimp-brightness-contrast inLayer 30 20)
    
    (plug-in-randomize-pick RUN-NONINTERACTIVE img inLayer 10 1 11 10)

    (gimp-levels inLayer 0 25 255 1.25 0 255)
  
    (gimp-hue-saturation inLayer 0 0 10 -100)
    
    (define newLayer)
    (gimp-palette-set-background '(255 125 0))
    (set! newLayer (car (gimp-layer-new img width height RGB "New Layer" 100 HARDLIGHT-MODE)))
    (gimp-image-add-layer img newLayer 0)
    (gimp-edit-fill newLayer BG-IMAGE-FILL)
    
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
                    "smartosc-unitedcolors1"                  ;function name
                    _"Unitedcolors Effect 1"                   ;menu label
                    "Unitedcolors Effect 1"                    ;description
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
(script-fu-menu-register "smartosc-unitedcolors1" _"<Image>/SmartOSC")