;SMARTOSC - TUANNA
;File: oldphoto13.scm
;Function: smartosc-oldphoto13
;param

(define (smartosc-oldphoto13
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
    
    (script-fu-old-photo img inLayer TRUE 2 FALSE FALSE FALSE)
    (set! inLayer (car (gimp-image-flatten img)))
    
    (gimp-desaturate inLayer)
    
    (gimp-levels inLayer 0 80 200 0.9 0 255)
    (define (spline)
        (let*
            ((a (make-vector 6 'byte)))
	    (set-pt a 0 0 0)
	    (set-pt a 1 60 120)
	    (set-pt a 2 255 255)
	a)
    )
    (define (set-pt a index x y)
		(prog1
		(aset a (* index 2) x)
		(aset a (+ (* index 2) 1) y)))
    (gimp-curves-spline inLayer 0 6 (spline))
    
    (plug-in-gauss-rle2 1 img inLayer 3 3)
    
    (define tileLayer2)
    (gimp-palette-set-foreground '(114 90 56))
    (gimp-palette-set-background '(114 90 56))
    (set! tileLayer2 (car (gimp-layer-new img width height RGB "New Layer" 100 COLOR-MODE)))
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
                    "smartosc-oldphoto13"                  ;function name
                    _"Old Photo Effect 13"                   ;menu label
                    "Old Photo Effect 13"                    ;description
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
(script-fu-menu-register "smartosc-oldphoto13" _"<Image>/SmartOSC")