;SMARTOSC - TUANNA
;File: oldphoto19.scm
;Function: smartosc-oldphoto19
;param

(define (smartosc-oldphoto19
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
   
    (gimp-levels inLayer 0 65 215 2.5 0 255)
    
    (gimp-brightness-contrast inLayer 30 10)
   
    (define tileLayer2)
    (gimp-palette-set-foreground '(150 137 86))
    (gimp-palette-set-background '(150 137 86))
    (set! tileLayer2 (car (gimp-layer-new img width height RGB "New Layer" 25 BURN-MODE)))
    (gimp-image-add-layer img tileLayer2 0)
    (gimp-edit-fill tileLayer2 BG-IMAGE-FILL)
    
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
                    "smartosc-oldphoto19"                  ;function name
                    _"Old Photo Effect 19"                   ;menu label
                    "Old Photo Effect 19"                    ;description
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
(script-fu-menu-register "smartosc-oldphoto19" _"<Image>/SmartOSC")