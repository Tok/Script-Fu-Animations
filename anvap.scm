;;;;;;;;;;;;;
;;  AnVap  ;;
;;;;;;;;;;;;;
;;
(define anvap-frame-count 20)
(define (script-fu-anvap image)
	(define type-purple 1) ;1=black
	(define type-green 0)  ;0=smeared
	(define amplitude-purple 61)
	(define amplitude-green 100) ;<= 100.0
	(define wave-lengtg-purple 30.0) ;0.1 <= wavelength <= 50.0
	(define wave-lengtg-green 50.0)  ;0.1 <= wavelength <= 50.0
	(let* (
			(newImage (car (gimp-image-duplicate image)))
			(layers (gimp-image-get-layers newImage))
			(blackLayer (aref (cadr layers) 0))
			(purpleLayer (aref (cadr layers) 1))
			(greenLayer (aref (cadr layers) 2))
			(emptyLayer (car (gimp-layer-copy blackLayer TRUE)))
		)
		(anvap-add-empty-layer newImage emptyLayer)
		(gimp-display-new newImage)
		(gimp-image-undo-disable newImage)
		(let loop ((i 0)) (if (< i anvap-frame-count) (begin
			(let* (
					(newLayerName (string-append (string-append "layer" (number->string i)) " (replace)"))
					(newLayer (car (gimp-layer-copy emptyLayer TRUE)))
					(newBlackLayer (car (gimp-layer-copy blackLayer TRUE)))
					(newPurpleLayer (car (gimp-layer-copy purpleLayer TRUE)))
					(newGreenLayer (car (gimp-layer-copy greenLayer TRUE)))
				)
				(gimp-image-insert-layer newImage newLayer 0 0)
				(gimp-item-set-name newLayer newLayerName)

				;;; green
				(gimp-image-insert-layer newImage newGreenLayer 0 0)
				(gimp-item-transform-shear newGreenLayer ORIENTATION-VERTICAL (anvap-calc-shear-green i))
				(anvap-wave newImage newGreenLayer i amplitude-green wave-lengtg-green type-green)
				(gimp-item-transform-scale newGreenLayer 0.0 0.0 1600.0 600.0)
				(gimp-image-merge-down newImage newGreenLayer CLIP-TO-IMAGE)

				;;; purple
				(gimp-image-insert-layer newImage newPurpleLayer 0 0)
				(gimp-item-transform-shear newPurpleLayer ORIENTATION-VERTICAL (anvap-calc-shear-purple i))
				(anvap-wave newImage newPurpleLayer i amplitude-purple wave-lengtg-purple type-purple)
				(gimp-item-transform-scale newPurpleLayer (- 0.0 400.0) 0.0 2400.0 600.0)
				(gimp-image-merge-down newImage newPurpleLayer CLIP-TO-IMAGE)

				;;; black
				(gimp-image-insert-layer newImage newBlackLayer 0 0)
				(car (gimp-layer-copy newBlackLayer TRUE))
				(gimp-image-merge-down newImage newBlackLayer CLIP-TO-IMAGE)
			)
			(gimp-displays-flush)
			(loop (+ i 1))
		)))
		(gimp-image-remove-layer newImage blackLayer)
		(gimp-image-remove-layer newImage purpleLayer)
		(gimp-image-remove-layer newImage greenLayer)
		(gimp-image-remove-layer newImage emptyLayer)
		(plug-in-animationplay RUN-INTERACTIVE newImage -1)
	)
)
(define (anvap-add-empty-layer image layer)
 	(gimp-image-insert-layer image layer 0 -1)
	(gimp-edit-clear layer)
	(gimp-item-set-name layer "empty")
)
(define (anvap-calc-shear-purple i) (- (random 600) 300))
(define (anvap-calc-shear-green i) (- (random 600) 300))
(define anvap-phase-start 360.00)
(define anvap-phase-end (- 0 360.0))
(define anvap-phase-range (- anvap-phase-end anvap-phase-start))
(define anvap-phase-step (/ anvap-phase-range anvap-frame-count))
(define (anvap-clip-phase phase) (min (max (modulo (floor phase) 360) (- 0 360)) 360))
(define (anvap-wave image layer i amplitude waveLength waveType)
	(plug-in-waves RUN-NONINTERACTIVE image layer
		amplitude 
		(anvap-clip-phase (+ anvap-phase-start (* i anvap-phase-step)))
		waveLength waveType FALSE ;reflection (not implemented)
	)
)
(script-fu-register
    "script-fu-anvap" "AnVap"
	"Animates an image of the AnVap flag with 3 layers."
	"@zirteq" "(A)" "October 2017"
	"RGB*, GRAY*" SF-IMAGE "Image" 0
)
(script-fu-menu-register "script-fu-anvap" "<Image>")
