<?php
class SM_Picasso_Helper_Data extends Mage_Core_Helper_Abstract
{
	protected static $egridImgDir = null;
	protected static $egridImgURL = null;
	protected static $egridImgThumb = null;
	protected static $egridImgThumbWidth = null;
	protected $_allowedExtensions = Array();

	public function __construct()
	{
		self::$egridImgDir = Mage::getBaseDir('media') . DS;
		self::$egridImgURL = Mage::getBaseUrl('media');
		self::$egridImgThumb = "thumb/";
		self::$egridImgThumbWidth = 100;
	}


	public function updateDirSepereator($path){
		return str_replace('\\', DS, $path);
	}

	public function getImageUrl($image_file) {
		$url = false;
		if (file_exists(self::$egridImgDir . self::$egridImgThumb . $this->updateDirSepereator($image_file)))
			$url = self::$egridImgURL . self::$egridImgThumb . $image_file;
		else
			$url = self::$egridImgURL . $image_file;
		return $url;
	}

	public function getFileExists($image_file) {
		$file_exists = false;
		$file_exists = file_exists(self::$egridImgDir . $this->updateDirSepereator($image_file));
		return $file_exists;
	}

	public function getImageThumbSize($image_file) {
		$img_file = $this->updateDirSepereator(self::$egridImgDir . $image_file);
		if ($image_file == '' || !file_exists($img_file))
			return false;
		list($width, $height, $type, $attr) = getimagesize($img_file);
		$a_height = (int) ((self::$egridImgThumbWidth / $width) * $height);
		return Array('width' => self::$egridImgThumbWidth, 'height' => $a_height);
	}
	
 	public function getSessionId(){
    	return Mage::getSingleton('core/session', array('name'=>'frontend'))->getEncryptedSessionId();
    }
    
    public function getGimpPath(){
    	return Mage::getStoreConfig('picasso/general/gimp_path');
    }
    
    public function getImageFileSizeAllow(){
    	$fileSize = Mage::getStoreConfig('picasso/general/image_file_size_allow');
    	$fileSize = floatval($fileSize) * 1024 * 1024;
    	return $fileSize;
    }
    
    public function getFileImageExtensionAllow(){
    	$allowExt = Mage::getStoreConfig('picasso/general/file_extension_allow');
    	return explode(',', $allowExt);
    }
    
    public function getDefaultEffect(){
    	$defaultEffect = Mage::getStoreConfig('picasso/general/default_effect');
    	return $defaultEffect;
    }
}
