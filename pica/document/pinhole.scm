;SMARTOSC - TUANNA
;File: pinhole.scm
;Function: smartosc-pinhole
;param

(define (smartosc-pinhole
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
    (gimp-desaturate inLayer)
    (gimp-levels inLayer 0 95 175 2.6 0 255)
    (FU-cross-light img inLayer 40 40 2 255)
    (plug-in-mblur RUN-NONINTERACTIVE img inLayer 0 3 40 0 0)
    (gimp-levels inLayer 0 50 215 0.8 0 255)
    (define layer3)
    (set! layer3 (car (gimp-layer-new img width height 1 "Layer 3" 100 NORMAL-MODE)))
    (gimp-image-add-layer img layer3 0)
    (gimp-selection-all img)
    (gimp-round-rect-select img 10 10 (- width 20) (- height 20) 50 50 CHANNEL-OP-REPLACE TRUE FALSE 0 0)
    (gimp-selection-invert img)
    (gimp-selection-feather img 50)
    (gimp-palette-set-background '(0 0 0))
    (gimp-edit-fill layer3 BG-IMAGE-FILL)
    (gimp-selection-none img)
    (gimp-layer-set-opacity layer3 90)
       
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
                    "smartosc-pinhole"                  ;function name
                    _"Pinhole Effect"                   ;menu label
                    "Pinhole Effect"                    ;description
                    "Nguyen Anh Tuan"                   ;author
                    "tuanna <tuanna@smartosc.com>"      ;copyright
                    "21-22/06/2012"                        ;date created
                    "*"                                 ;image type that the script works on
                    ;SF-IMAGE        "Input image"                   0
                    ;SF-DRAWABLE     "Input drawable"                0
                    SF-STRING      "Input image"                   "" ;url input
                    SF-STRING      "Output image"                  "" ;url output
)
;register
(script-fu-menu-register "smartosc-pinhole" _"<Image>/SmartOSC")