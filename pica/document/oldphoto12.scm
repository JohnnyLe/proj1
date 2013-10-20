;SMARTOSC - TUANNA
;File: oldphoto12.scm
;Function: smartosc-oldphoto12
;param

(define (smartosc-oldphoto12
            ;img inLayer;input/output
            imgURL inLayerURL ;url to file input/output
            maskImgURL ;url to old_paper.jpg file
        )
    (let* 
        (
            ;start proccessing img from input url - comment 2 rows below if using img inLayer variables
            (img (car (gimp-file-load RUN-NONINTERACTIVE imgURL imgURL))) ;load img from imgURL
            (inLayer (car (gimp-image-get-active-layer img)))
            ;end processing img from input url
            (width (car (gimp-drawable-width inLayer)))
            (height (car (gimp-drawable-height inLayer)))
            (maskImg (car (gimp-file-load RUN-NONINTERACTIVE maskImgURL maskImgURL))) ;load mask image
        )
        
    (gimp-image-undo-group-start img)
    (gimp-desaturate inLayer)
    (gimp-brightness-contrast inLayer 15 45)
    (gimp-levels inLayer 0 55 255 1.0 0 255)
    (define bg-layer)
    (gimp-image-scale maskImg width height)
    (gimp-selection-all maskImg)
    (set! bg-layer (aref (cadr (gimp-image-get-layers maskImg)) 0))
    (gimp-edit-copy bg-layer)
    (gimp-selection-none maskImg)
    (define newLayer)
    (define float)
    (set! newLayer (car (gimp-layer-new img width height RGB "New Mask Layer" 100 MULTIPLY-MODE)))
    (gimp-image-add-layer img newLayer 0)
    (gimp-edit-clear newLayer)
    (set! float (car (gimp-edit-paste newLayer 0)))
    (gimp-floating-sel-anchor float)
    (gimp-layer-set-mode newLayer MULTIPLY-MODE)
    (define newLayer3)
    (set! newLayer3 (car (gimp-layer-copy newLayer 1)))
    (gimp-image-add-layer img newLayer3 0)
    (gimp-layer-set-mode newLayer3 MULTIPLY-MODE)
    (gimp-layer-set-opacity newLayer3 30)
    
    ;save file to inLayerURL - comment if using img inLayer variables
    (define result-layer)
    (set! result-layer (car (gimp-image-merge-visible-layers img EXPAND-AS-NECESSARY)))
    (gimp-file-save RUN-NONINTERACTIVE img result-layer inLayerURL inLayerURL)
    
    ;clean-up
    (gimp-image-delete maskImg)
    (gimp-image-undo-group-end img)
    (gimp-image-delete img)
    (gimp-displays-flush)
  )
)

;register the function with GIMP
(script-fu-register
                    "smartosc-oldphoto12"                  ;function name
                    _"Old Photo Effect 12"                   ;menu label
                    "Old Photo Effect 12"                    ;description
                    "Nguyen Anh Tuan"                   ;author
                    "tuanna <tuanna@smartosc.com>"      ;copyright
                    "20/06/2012"                        ;date created
                    "*"                                 ;image type that the script works on
                    ;SF-IMAGE        "Input image"                   0
                    ;SF-DRAWABLE     "Input drawable"                0
                    SF-STRING      "Input image"                   "" ;url input
                    SF-STRING      "Output image"                  "" ;url output
                    SF-STRING      "Mask image"                     "" ;mask image url
)
;register
(script-fu-menu-register "smartosc-oldphoto12" _"<Image>/SmartOSC")