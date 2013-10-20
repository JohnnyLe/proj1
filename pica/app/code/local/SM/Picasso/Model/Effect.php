<?php
class SM_Picasso_Model_Effect extends Mage_Core_Model_Abstract
{
	public function _construct() {
        parent::_construct();
        $this->_init('picasso/effect');
    }
    /*
	public function getEffects(){
		$effects = array(
			'old_photo' => array(
				'group' => 'Group 1',
				'code'  => 'old_photo',
				'name'  => 'Old Photo',
				'effect_function' => '(define (simple-unsharp-mask filename output mask-radius pct-black)(let* ((image (car (gimp-file-load RUN-NONINTERACTIVE filename filename)))(drawable (car (gimp-image-get-active-layer image))))(script-fu-old-photo image drawable TRUE 20 TRUE TRUE FALSE)(set! drawable (car (gimp-image-flatten image)))(gimp-file-save RUN-NONINTERACTIVE image drawable output output)(gimp-image-delete image)))',
				'run_script' => '(simple-unsharp-mask \"{{fileinput}}\" \"{{fileoutput}}\" 11 11)(gimp-quit 0)'
			),
			'photocopy' => array(
				'group' => 'Group 2',
				'code'  => 'photocopy',
				'name'  => 'Photo Copy',
				'effect_function' => '(define (simple-unsharp-mask filename output mask-radius pct-black)(let* ((image (car (gimp-file-load RUN-NONINTERACTIVE filename filename)))(drawable (car (gimp-image-get-active-layer image))))(plug-in-photocopy RUN-NONINTERACTIVE image drawable 7.5 0.8 0.2 0.3)(set! drawable (car (gimp-image-flatten image)))(gimp-file-save RUN-NONINTERACTIVE image drawable output output)(gimp-image-delete image)))',
				'run_script' => '(simple-unsharp-mask \"{{fileinput}}\" \"{{fileoutput}}\" 11 11)(gimp-quit 0)'
			),
			'cartoon' => array(
				'group' => 'Group 2',
				'code'  => 'cartoon',
				'name'  => 'Cartoon',
				'effect_function' => '(define (simple-unsharp-mask filename output mask-radius pct-black)(let* ((image (car (gimp-file-load RUN-NONINTERACTIVE filename filename)))(drawable (car (gimp-image-get-active-layer image))))(plug-in-cartoon RUN-NONINTERACTIVE image drawable mask-radius pct-black)(set! drawable (car (gimp-image-flatten image)))(gimp-file-save RUN-NONINTERACTIVE image drawable output output)(gimp-image-delete image)))',
				'run_script' => '(simple-unsharp-mask \"{{fileinput}}\" \"{{fileoutput}}\" 11 11)(gimp-quit 0)'
			),
		);
	}
	*/
}