;;;;;;;;;;;;;
;;  G T W  ;;
;;;;;;;;;;;;;
;;
(define FRAME_COUNT 45)
(define FC_HALF (/ FRAME_COUNT 2))
(define FC_THIRD (/ FRAME_COUNT 3))
(define FC_QUARTER (/ FRAME_COUNT 4))
(define FC_TWO_THIRDS (* FC_THIRD 2))
(define FC_THREE_QUARTERS (* FC_QUARTER 3))
;;
(define STAR_START_FRAME 0)
(define STAR_STOP_FRAME FC_HALF)
(define STAR_FRAME_COUNT (- STAR_STOP_FRAME STAR_START_FRAME))
(define STAR_ROTATION_START_DEG 90.00)
(define STAR_ROTATION_END_DEG 0.00)
(define STAR_ROTATION_RANGE_DEG (- STAR_ROTATION_START_DEG STAR_ROTATION_END_DEG))
(define STAR_ROTATION_STEP_DEG (/ STAR_ROTATION_RANGE_DEG STAR_FRAME_COUNT))
;;
(define LOGO_ZOOM_START_FRAME FC_THIRD)
(define LOGO_ZOOM_STOP_FRAME FC_TWO_THIRDS)
(define LOGO_ZOOM_FRAME_COUNT (- LOGO_ZOOM_STOP_FRAME LOGO_ZOOM_START_FRAME))
(define LOGO_ZOOM_X 0.50)
(define LOGO_ZOOM_Y 0.50)
(define LOGO_ZOOM_START_Z 2.00)
(define LOGO_ZOOM_END_Z 0.00)
(define LOGO_ZOOM_RANGE (- LOGO_ZOOM_END_Z LOGO_ZOOM_START_Z))
(define LOGO_ZOOM_STEP (/ LOGO_ZOOM_RANGE LOGO_ZOOM_FRAME_COUNT))
;;
(define TEXT_ZOOM_START_FRAME FC_HALF)
(define TEXT_ZOOM_STOP_FRAME FC_THREE_QUARTERS)
(define TEXT_ZOOM_FRAME_COUNT (- TEXT_ZOOM_STOP_FRAME TEXT_ZOOM_START_FRAME))
(define TEXT_ZOOM_X 0.50)
(define TEXT_ZOOM_Y 0.50)
(define TEXT_ZOOM_START_Z 2.00)
(define TEXT_ZOOM_END_Z 0.00)
(define TEXT_ZOOM_RANGE (- TEXT_ZOOM_END_Z TEXT_ZOOM_START_Z))
(define TEXT_ZOOM_STEP (/ TEXT_ZOOM_RANGE TEXT_ZOOM_FRAME_COUNT))
;;
(define WAVE_START_FRAME LOGO_ZOOM_START_FRAME)
(define WAVE_STOP_FRAME FC_THREE_QUARTERS)
(define WAVE_FRAME_COUNT (- WAVE_STOP_FRAME WAVE_START_FRAME))
(define WAVE_AMPLITUDE_START 10.00)
(define WAVE_AMPLITUDE_END 0.00)
(define WAVE_AMP_RANGE (- WAVE_AMPLITUDE_END WAVE_AMPLITUDE_START))
(define WAVE_AMP_STEP (/ WAVE_AMP_RANGE WAVE_FRAME_COUNT))
(define WAVE_PHASE_START 360.00)
(define WAVE_PHASE_END (- 0.0 360.00))
(define WAVE_PHASE_RANGE (- WAVE_PHASE_END WAVE_PHASE_START))
(define WAVE_PHASE_STEP (/ WAVE_PHASE_RANGE WAVE_FRAME_COUNT))
(define WAVE_LENGTH 10.0) ;0.1 <= wavelength <= 50.0
(define WAVE_TYPE 0) ;0=smeared 1=black
;;
(define OBJECT_TYPE 0) ;plane
(define ROT_X 0.00)(define ROT_Y 0.00)(define ROT_Z 0.00)
(define POS_X 0.50)(define POS_Y 0.50)(define POS_Z 0.00)
(define VIEWPOINT_X 0.50)(define VIEWPOINT_Y 0.50)(define VIEWPOINT_Z 2.00)
; light
(define LIGHT_TYPE 0)
(define LIGHT_COLOR '(255 255 255))
(define LIGHT_POS_X 0.41)(define LIGHT_POS_Y 0.65)(define LIGHT_POS_Z 2.00)
(define LIGHT_DIRECTION_X 0.5)(define LIGHT_DIRECTION_Y 0.2)(define LIGHT_DIRECTION_Z 0.00)
(define AMBIENT 0.30)
(define DIFFUSE_INTENSITY 1.0)
(define DIFFUSE_REFLECTIVITY 0.50)
(define SPECULAR_REFLECTIVITY 0.50)
(define HIGHLIGHT 27.0) ;exp
; settings
(define IS_ANTIALIASING TRUE)
(define IS_TILE_SOURCE_IMAGE FALSE)
(define IS_CREATE_NEW_IMAGE FALSE)
(define IS_TRANSPARENT_BACKGROUND TRUE)
;;
(define (script-fu-gtw image)
	(let* (
			(newImage (car (gimp-image-duplicate image)))
			(layers (gimp-image-get-layers newImage))
			(starLayer (aref (cadr layers) 2))
			(logoLayer (aref (cadr layers) 1))
			(textLayer (aref (cadr layers) 0))
			(emptyLayer (car (gimp-layer-copy starLayer TRUE)))
		)
		(gtw-add-empty-layer newImage emptyLayer)
		(gimp-display-new newImage)
		(gimp-image-undo-disable newImage)		
		(let loop ((i 0)) (if (< i FRAME_COUNT) (begin
			(let* (
					(newLayer (car (gimp-layer-copy emptyLayer TRUE)))
					(newStarLayer (car (gimp-layer-copy starLayer TRUE)))
					(newLogoLayer (car (gimp-layer-copy logoLayer TRUE)))
					(newTextLayer (car (gimp-layer-copy textLayer TRUE)))
					(newLayerName 
						(if (< i (- FRAME_COUNT 1))
							(string-append (string-append "layer" (number->string i)) " (replace)")
							"last (replace)(2000ms)"
						)
					)
					(eyeZpos (gtw-calc-eye-z-pos i))
					(textZpos (gtw-calc-text-z-pos i))
					(lightZpos (gtw-calc-light-z-pos i))
					(lightZdir (gtw-calc-light-z-direction i))
				)
				(gimp-image-insert-layer newImage newLayer 0 0)
				(gimp-item-set-name newLayer newLayerName)

				;;; star
				(gtw-rotate-star newImage newStarLayer i lightZpos lightZdir)

				;;; enl logo
				(gimp-image-insert-layer newImage newLogoLayer 0 0)
				(if (< i WAVE_STOP_FRAME)
					(gtw-wave newImage newLogoLayer i)
				)
				(gtw-zoom-logo newImage newLogoLayer i lightZpos lightZdir eyeZpos)
				(gimp-image-merge-down newImage newLogoLayer CLIP-TO-IMAGE)

				;;; gtw text
				(gtw-zoom-text newImage newTextLayer i lightZpos lightZdir textZpos)
			)
			(gimp-displays-flush)
			(loop (+ i 1))
		)))
		(gimp-image-remove-layer newImage starLayer)
		(gimp-image-remove-layer newImage logoLayer)
		(gimp-image-remove-layer newImage textLayer)
		(gimp-image-remove-layer newImage emptyLayer)
		(plug-in-animationplay RUN-INTERACTIVE newImage -1)
	)
)
(define (gtw-add-empty-layer image layer)
 	(gimp-image-insert-layer image layer 0 -1)
	(gimp-edit-clear layer)
	(gimp-item-set-name layer "empty")
)
(define (gtw-calc-light-z-pos frameNumber)
	2.00
)
(define (gtw-calc-light-z-direction frameNumber)
	0.00
)
(define gtw-calc-eye-x-pos 0.41)
(define gtw-calc-eye-y-pos 0.65)
(define (gtw-calc-eye-z-pos frameNumber)
	(if (< frameNumber LOGO_ZOOM_START_FRAME) LOGO_ZOOM_START_Z
		(if (>= frameNumber LOGO_ZOOM_STOP_FRAME) LOGO_ZOOM_END_Z
			(+ LOGO_ZOOM_START_Z (* (- frameNumber LOGO_ZOOM_START_FRAME) LOGO_ZOOM_STEP))
		)
	)
)
(define (gtw-calc-text-z-pos frameNumber)
	(if (< frameNumber TEXT_ZOOM_START_FRAME) TEXT_ZOOM_START_Z
		(if (>= frameNumber TEXT_ZOOM_STOP_FRAME) TEXT_ZOOM_END_Z
			(+ TEXT_ZOOM_START_Z (* (- frameNumber TEXT_ZOOM_START_FRAME) TEXT_ZOOM_STEP))
		)
	)
)
(define (gtw-zoom-text image layer frameNumber lightZpos lightZdir textZpos)
	(gimp-image-insert-layer image layer 0 0)
	(plug-in-map-object RUN-NONINTERACTIVE image layer 
		OBJECT_TYPE VIEWPOINT_X VIEWPOINT_Y VIEWPOINT_Z
		TEXT_ZOOM_X TEXT_ZOOM_Y textZpos
		0.5 0.0 0.0 0.5 1.0 0.0 ;object axis unused
		ROT_X ROT_Y ROT_Z
		LIGHT_TYPE LIGHT_COLOR LIGHT_POS_X LIGHT_POS_Y lightZpos
		LIGHT_DIRECTION_X LIGHT_DIRECTION_Y lightZdir
		AMBIENT DIFFUSE_INTENSITY DIFFUSE_REFLECTIVITY SPECULAR_REFLECTIVITY HIGHLIGHT
		IS_ANTIALIASING IS_TILE_SOURCE_IMAGE IS_CREATE_NEW_IMAGE IS_TRANSPARENT_BACKGROUND
		0.00 -1 -1 -1 0.0 -1 -1 -1 -1 -1 -1 -1 -1 ;unused for plane
	)
	(gimp-image-merge-down image layer CLIP-TO-IMAGE)
)
(define (gtw-zoom-logo image layer frameNumber lightZpos lightZdir eyeZpos)
	(plug-in-map-object RUN-NONINTERACTIVE image layer
		OBJECT_TYPE VIEWPOINT_X VIEWPOINT_Y VIEWPOINT_Z
		LOGO_ZOOM_X LOGO_ZOOM_Y eyeZpos
		0.5 0.0 0.0 0.5 1.0 0.0 ;object axis unused
		ROT_X ROT_Y ROT_Z
		LIGHT_TYPE LIGHT_COLOR LIGHT_POS_X LIGHT_POS_Y lightZpos
		LIGHT_DIRECTION_X LIGHT_DIRECTION_Y lightZdir
		AMBIENT DIFFUSE_INTENSITY DIFFUSE_REFLECTIVITY SPECULAR_REFLECTIVITY HIGHLIGHT
		IS_ANTIALIASING IS_TILE_SOURCE_IMAGE IS_CREATE_NEW_IMAGE IS_TRANSPARENT_BACKGROUND
		0.00 -1 -1 -1 0.0 -1 -1 -1 -1 -1 -1 -1 -1 ;unused for plane
	)
)
(define (gtw-wave image layer frameNumber)
	(let* (
			(i (- frameNumber WAVE_START_FRAME))
			(amplitude 
				(if (< frameNumber WAVE_START_FRAME) WAVE_AMPLITUDE_START
					(if (>= frameNumber WAVE_STOP_FRAME) WAVE_AMPLITUDE_END
						(+ WAVE_AMPLITUDE_START (* i WAVE_AMP_STEP))
					)
				)
			)
			(phase
				(if (< frameNumber WAVE_START_FRAME) WAVE_PHASE_START
					(if (>= frameNumber WAVE_STOP_FRAME) WAVE_PHASE_END
						(+ WAVE_PHASE_START (* i WAVE_PHASE_STEP))
					)
				)
			)
		)
		(plug-in-waves RUN-NONINTERACTIVE image layer
			amplitude phase WAVE_LENGTH WAVE_TYPE
			FALSE ;reflection (not implemented)
		)
	)
)
(define (gtw-rotate-star image layer frameNumber lightZpos lightZdir)
	(gimp-image-insert-layer image layer 0 0)
	(let* (
			(i (- frameNumber STAR_START_FRAME))
			(yRotation 
				(if (< frameNumber STAR_START_FRAME) STAR_ROTATION_START_DEG
					(if (>= frameNumber STAR_STOP_FRAME) STAR_ROTATION_END_DEG
						(+ STAR_ROTATION_START_DEG (* i STAR_ROTATION_STEP_DEG))
					)
				)
			)
		)
		(plug-in-map-object RUN-NONINTERACTIVE image layer 
			OBJECT_TYPE VIEWPOINT_X VIEWPOINT_Y VIEWPOINT_Z
			POS_X POS_Y POS_Z
			0 0 0 0 0 0 ;object axis unused
			ROT_X yRotation ROT_Z
			LIGHT_TYPE LIGHT_COLOR LIGHT_POS_X LIGHT_POS_Y lightZpos
			LIGHT_DIRECTION_X LIGHT_DIRECTION_Y lightZdir
			AMBIENT DIFFUSE_INTENSITY DIFFUSE_REFLECTIVITY SPECULAR_REFLECTIVITY HIGHLIGHT
			IS_ANTIALIASING IS_TILE_SOURCE_IMAGE IS_CREATE_NEW_IMAGE IS_TRANSPARENT_BACKGROUND
			0.00 -1 -1 -1 0.0 -1 -1 -1 -1 -1 -1 -1 -1 ;unused for plane
		)
	)
	(gimp-image-merge-down image layer CLIP-TO-IMAGE)
)
(script-fu-register
    "script-fu-gtw"     ;func name
    "GTW"               ;menu label
	"Animates an image of the GTW logo with 3 layers."
	"@zirteq"           ;auth
	"EFES"              ;copywat
	"October 2017"
	"RGB*, GRAY*"
	SF-IMAGE "Image" 0
)
(script-fu-menu-register "script-fu-gtw" "<Image>")
