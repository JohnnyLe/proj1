;SMARTOSC - TUANNA
;File: gouache.scm
;Function: smartosc-gouache
;param

(define (smartosc-gouache
            ;img inLayer;input/output
            imgURL inLayerURL ;url to file input/output
            effectSize flattenImage)
    (let* 
        (
            ;start proccessing img from input url - comment 2 rows below if using img inLayer variables
            (img (car (gimp-file-load RUN-NONINTERACTIVE imgURL imgURL))) ;load img from imgURL
            (inLayer (car (gimp-image-get-active-layer img)))
            ;end processing img from input url
            
           
        )
        
    (define theNewlayer) 
    (define origlayer)
    (define nlayer)
    (gimp-image-undo-group-start img)
    
    ;beginning Step by step
    
    ;step 1: set water color with effectSize = 3
    (set! theNewlayer (car (gimp-layer-copy inLayer 1)))
    (set! origlayer (car (gimp-layer-copy inLayer 1)))
	
    (plug-in-gauss-iir2 1 img inLayer effectSize effectSize)
    (gimp-image-insert-layer img theNewlayer 0 -1)
    (plug-in-laplace 1 img theNewlayer)
    (gimp-layer-set-mode theNewlayer SUBTRACT-MODE)
    (gimp-image-merge-down img theNewlayer EXPAND-AS-NECESSARY)
	
    (if (= flattenImage FALSE)
	(begin
	    (set! nlayer (car (gimp-image-get-active-layer img)))
	    (gimp-image-insert-layer img origlayer 0 -1)
	    (gimp-image-lower-item-to-bottom img origlayer)
	    (gimp-image-set-active-layer img nlayer)
	    (gimp-item-set-name nlayer "Watercolor Layer")
        )
    )
    
    ;step 2: Select current layer: Colors / Hue-Saturation...
    ;Overlap: 0 / Hue: 5 / Lightness: 0 / Saturation: 50
    (define theActiveLayer)
    (set! theActiveLayer (car (gimp-image-get-active-layer img)))
    (gimp-hue-saturation theActiveLayer 0 5 0 50) 
    
    ;step 3: Colors / Curves... Channel: Value / X = 145, Y = 170
    (define (spline)
        (let*
            ((a (make-vector 6 'byte)))
	    (set-pt a 0 0 0)
	    (set-pt a 1 145 170)
	    (set-pt a 2 255 255)
	a)
    )
    (define (set-pt a index x y)
		(prog1
		(aset a (* index 2) x)
		(aset a (+ (* index 2) 1) y)))
    (gimp-curves-spline theActiveLayer 0 6 (spline))
    
    ;step 4: Colors / Levels...Channel: Value / Input Levels: 100 - 1.50 - 180
    (gimp-levels theActiveLayer 0 100 180 1.5 0 255)
    
    ;step 5: Colors / Brightness-Contrast...Brightness: 80 / Contrast: 0
    (gimp-brightness-contrast theActiveLayer 80 0)
    
    ;step 6: Colors / Levels...Channel: Value / Input Levels: 60 - 1.40 - 230
    (gimp-levels theActiveLayer 0 60 230 1.4 0 255)
    
    ;end step by step
    
    ;save file to inLayerURL - comment if using img inLayer variables
    (gimp-file-save RUN-NONINTERACTIVE img theActiveLayer inLayerURL inLayerURL)
    
    ;clean-up
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
  )
)

;register the function with GIMP
(script-fu-register
                    "smartosc-gouache"                  ;function name
                    _"Gouache Effect"                   ;menu label
                    "Gouache Effect"                    ;description
                    "Nguyen Anh Tuan"                   ;author
                    "tuanna <tuanna@smartosc.com>"      ;copyright
                    "18/06/2012"                        ;date created
                    "*"                                 ;image type that the script works on
                    SF-IMAGE        "Input image"                   0
                    SF-DRAWABLE     "Input drawable"                0
                    ;SF-STRING      "Input image"                   "" ;url input
                    ;SF-STRING      "Output image"                  "" ;url output
                    SF-ADJUSTMENT   "Effect Size (pixels)"	    '(3 0 32 1 10 0 0)
                    SF-TOGGLE       "Flatten Image when complete"   TRUE
)
;register
(script-fu-menu-register "smartosc-gouache" _"<Image>/SmartOSC")