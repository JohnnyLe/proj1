;SMARTOSC - TUANNA
;File: oldphoto5.scm
;Function: smartosc-oldphoto5
;param

(define (smartosc-oldphoto5
	    ;img inLayer
            imgURL inLayerURL ;url to file input/output
        )
    (let* 
        (
            ;start proccessing img from input url - comment 2 rows below if using img inLayer variables
            (img (car (gimp-file-load RUN-NONINTERACTIVE imgURL imgURL))) ;load img from imgURL
            (inLayer (car (gimp-image-get-active-layer img)))
        )
        
    (gimp-image-undo-group-start img)
    (plug-in-photocopy RUN-NONINTERACTIVE img inLayer 40 1 0.5 0.3)
    (plug-in-gauss-rle2 1 img inLayer 5 5)
    (gimp-levels inLayer 0 75 255 0.5 0 255)
    (gimp-file-save RUN-NONINTERACTIVE img inLayer inLayerURL inLayerURL)
    
    ;clean-up
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
  )
)

;register the function with GIMP
(script-fu-register
                    "smartosc-oldphoto5"                  ;function name
                    _"Old Photo Effect 5"                   ;menu label
                    "Old Photo Effect 5"                    ;description
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
(script-fu-menu-register "smartosc-oldphoto5" _"<Image>/SmartOSC")