;;;;;;;;;;;;;
;;  AnVap  ;;
;;;;;;;;;;;;;
;;
(define ANVAP_FRAME_COUNT 15)
(define ANVAP_FC_HALF (/ ANVAP_FRAME_COUNT 2))
(define ANVAP_FC_THIRD (/ ANVAP_FRAME_COUNT 3))
(define ANVAP_FC_TWO_THIRDS (* ANVAP_FC_THIRD 2))
(define WAVE_TYPE_PURPLE 1) ;1=black
(define WAVE_TYPE_GREEN 0) ;0=smeared
(define AMPLITUDE_PURPLE 61)
(define AMPLITUDE_GREEN 100) ;<= 100.0
(define WAVE_LENGTH_PURPLE 30.0) ;0.1 <= wavelength <= 50.0
(define WAVE_LENGTH_GREEN 50.0) ;0.1 <= wavelength <= 50.0
(define ANVAP_PHASE_START 360.00)
(define ANVAP_PHASE_END (- 0 360.0))
(define ANVAP_PHASE_RANGE (- ANVAP_PHASE_END ANVAP_PHASE_START))
(define ANVAP_PHASE_STEP (/ ANVAP_PHASE_RANGE ANVAP_FRAME_COUNT))
;;
(define (script-fu-anvap image)
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
		(let loop ((i 0)) (if (< i ANVAP_FRAME_COUNT) (begin
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
				(anvap-wave newImage newGreenLayer i AMPLITUDE_GREEN WAVE_LENGTH_GREEN WAVE_TYPE_GREEN)
				;;TODO stretch layer
				(gimp-image-merge-down newImage newGreenLayer CLIP-TO-IMAGE)

				;;; purple
				(gimp-image-insert-layer newImage newPurpleLayer 0 0)
				(gimp-item-transform-shear newPurpleLayer ORIENTATION-VERTICAL (anvap-calc-shear-purple i))
				(anvap-wave newImage newPurpleLayer i AMPLITUDE_PURPLE WAVE_LENGTH_PURPLE WAVE_TYPE_PURPLE)
				;;TODO stretch layer
				(gimp-image-merge-down newImage newPurpleLayer CLIP-TO-IMAGE)

				;;; black
				(gimp-image-insert-layer newImage newBlackLayer 0 0)
				(car (gimp-layer-copy newBlackLayer TRUE))
				(gimp-image-merge-down newImage newBlackLayer CLIP-TO-IMAGE)
			)
			;(gimp-displays-flush)
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
(define (anvap-calc-shear-purple i)
	(- (random 600) 300)
	;(if (< i ANVAP_FC_HALF)
	;   (- (modulo (floor (* i (/ 1200 ANVAP_FRAME_COUNT))) 600) 300)
	;   (- (modulo (floor (* i (/ (- 0 1200) ANVAP_FRAME_COUNT))) 600) 300)
	;)
)
(define (anvap-calc-shear-green i)
	(- (random 600) 300)
	;(- (* i (/ 600 ANVAP_FRAME_COUNT)) 300)
)
(define (anvap-clip-phase phase) (min (max (modulo (floor phase) 360) (- 0 360)) 360))
(define (anvap-wave image layer i amplitude waveLength waveType)
	(plug-in-waves RUN-NONINTERACTIVE image layer
		amplitude 
		(anvap-clip-phase (+ ANVAP_PHASE_START (* i ANVAP_PHASE_STEP)))
		waveLength waveType FALSE ;reflection (not implemented)
	)
)
(script-fu-register
    "script-fu-anvap"
    "AnVap"
	"Animates an image of the AnVap flag with 3 layers."
	"@zirteq"
	"(A)"
	"October 2017"
	"RGB*, GRAY*"
	SF-IMAGE "Image" 0
)
(script-fu-menu-register "script-fu-anvap" "<Image>")
