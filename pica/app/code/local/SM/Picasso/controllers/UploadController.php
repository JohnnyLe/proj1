<?php
//set_time_limit(300);
class SM_Picasso_UploadController extends Mage_Core_Controller_Front_Action
{
	const DS = "/";
	public function indexAction(){
		$sessionId = Mage::helper('picasso')->getSessionId();
		// list of valid extensions, ex. array("jpeg", "xml", "bmp")
		$allowedExtensions = Mage::helper('picasso')->getFileImageExtensionAllow();//array("jpeg", "png", "bmp","gif","jpg");
		// max file size in bytes
		$sizeLimit = Mage::helper('picasso')->getImageFileSizeAllow();
		
		$uploader = new qqFileUploader($allowedExtensions, $sizeLimit);
		$uploadDir = Mage::getBaseDir('base').DS.'media'.DS.'picasso'.DS.'uploads'.DS.$sessionId.DS;
		$result = $uploader->handleUpload($uploadDir);

		if(!empty($result['imagePath'])){
			$imagePath = $result['imagePath'];
			//$basePath - origin file location
			$imageObj = new Varien_Image($imagePath);
			$imageObj->constrainOnly(TRUE);
			$imageObj->keepAspectRatio(FALSE);
			$imageObj->keepFrame(FALSE);
			//$width, $height - sizes you need (Note: when keepAspectRatio(TRUE), height would be ignored)
			$imageObj->resize(100, 80);
			$imageResizePath = dirname($imagePath).self::DS.'thumb_'.basename($imagePath);
			$imageObj->save($imageResizePath);
			
			$result['imageThumbPath'] = $imageResizePath;
			
			$result['images'] = $this->getEffectThumbImagePath($result['imageThumbPath']);
		}
		echo htmlspecialchars(json_encode($result), ENT_NOQUOTES);
	}
	
        
        
        public function upload_urlAction(){
		$sessionId = Mage::helper('picasso')->getSessionId();
		// list of valid extensions, ex. array("jpeg", "xml", "bmp")
		$allowedExtensions = Mage::helper('picasso')->getFileImageExtensionAllow();//array("jpeg", "png", "bmp","gif","jpg");
		// max file size in bytes
		$sizeLimit = Mage::helper('picasso')->getImageFileSizeAllow();
		
		$uploader = new qqFileUploader($allowedExtensions, $sizeLimit);
		$uploadDir = Mage::getBaseDir('base').DS.'media'.DS.'picasso'.DS.'uploads'.DS.$sessionId.DS;
		
                $urlImage=$_GET['url'];
                
                $result = $uploader->handleUploadFromURL($uploadDir,$urlImage);

		if(!empty($result['imagePath'])){
			$imagePath = $result['imagePath'];
			//$basePath - origin file location
			$imageObj = new Varien_Image($imagePath);
			$imageObj->constrainOnly(TRUE);
			$imageObj->keepAspectRatio(FALSE);
			$imageObj->keepFrame(FALSE);
			//$width, $height - sizes you need (Note: when keepAspectRatio(TRUE), height would be ignored)
			$imageObj->resize(100, 80);
			$imageResizePath = dirname($imagePath).self::DS.'thumb_'.basename($imagePath);
			$imageObj->save($imageResizePath);
			
			$result['imageThumbPath'] = $imageResizePath;
			
			$result['images'] = $this->getEffectThumbImagePath($result['imageThumbPath']);
		}
		echo htmlspecialchars(json_encode($result), ENT_NOQUOTES);
	}
        
        
	public function processMainImageAction(){
		$imagePath = $this->getRequest()->getPost('image_path');
		$effectId = $this->getRequest()->getPost('effect_id');
		$crop = $this->getRequest()->getPost('crop');
		$brightnessContrast = $this->getRequest()->getPost('brightness_contrast');
		$ip_addr = "127.0.0.1";
		$ip_port = "10008";
		$MAGIC = 'G'; // inferred GIMP Net-FU Protocol Header
		if(file_exists($imagePath)){
			$sessionId = Mage::helper('picasso')->getSessionId();
			$rootDir = MAGENTO_ROOT.self::DS;
			$rootDir = str_replace("\\",'/',$rootDir);
			$imageDir = $rootDir.'media'.self::DS.'picasso'.self::DS.'uploads'.self::DS.$sessionId;
			$imageDir = str_replace("\\",'/',$imageDir);
			$fileinput = $imagePath;
			$script = '';
			
			$effect = Mage::getModel('picasso/effect')->load($effectId);
			$params = array();
			$params[] = '';
			if(empty($crop)){
				$imageSize = getimagesize($imagePath);
				$params[] = $imageSize[0].' '. $imageSize[1]. ' 0 0';
				
			}
			else{
                $crop['w'] = floatval($crop['w']);
                $crop['h'] = floatval($crop['h']);
                $crop['x'] = floatval($crop['x']);
                $crop['y'] = floatval($crop['y']);
                if($crop['w'] == 0 && $crop['h'] == 0 && $crop['x'] == 0 && $crop['y'] == 0){
                    $imageSize = getimagesize($imagePath);
                    $params[] = $imageSize[0].' '. $imageSize[1]. ' 0 0';
                }
                else{
                    $params[] = $crop['w'].' ' . $crop['h']. ' ' . $crop['x'] .' '. $crop['y'] ;
                }

			}
			
			if(empty($brightnessContrast)){
				$params[] = '0 0';
			}
			else{
				$params[] = $brightnessContrast['brightness'] . ' ' . $brightnessContrast['contrast'];
			}
			
			$params = implode(' ', $params);
			//$params = ' 100 80 0 0 0 0';
			//die($params);
			
			$pathExplode = explode(self::DS,$fileinput);
			$outputImage = end($pathExplode);
			$fileoutput = $imageDir.self::DS.$effect['code'].self::DS.$outputImage;
			//if(!file_exists($fileoutput)){
				unset($pathExplode[count($pathExplode)-1]);
				$effectDir = implode(self::DS,$pathExplode).self::DS.$effect['code'];
				if(!is_dir($effectDir)){
					mkdir($effectDir);
				}
				$runScript = str_replace(array('{{fileinput}}','{{fileoutput}}','{{params}}','(gimp-quit 0)'),array($fileinput,$fileoutput,$params,''), $effect['script_fu']);
				$script .= $runScript;
					
					
				$cmdLine = str_replace("\\", "",$script);
				$cmdLength = strlen($cmdLine);
				//die($cmdLine);
				$old_err = error_reporting(E_ERROR | E_PARSE);
				$fp = fsockopen($ip_addr, $ip_port, $errno, $errstr, 30);
				if (!$fp) {
					$target = "HTTP/1.0 503 Service Unavailable";
				} else {
					$temp = sprintf("G%c%c%s",$cmdLength >> 8,$cmdLength & 0xff,$cmdLine);
					fwrite($fp,$temp);
					$c = fgetc($fp);
					if( $c == $MAGIC )
					{
						$response = fread($fp,2);
						// 3 characters discarded for unknown reasons
						// I don't actually have any documentation for the Net-FU protocol
						// so it's monkey see, monkey do
						$response_len = ord(fread($fp,1)); // length of the file name
						$response = fread($fp, $response_len);
						if( preg_match( "/^ERROR: ([^:]*)/", $response, $matches ) ) {
							$img_url = "\"" . $matches[1] . " - " . $matches[2] . "\"";
						}
						else {
							//$img_url = "http://" . $_SERVER['SERVER_NAME'] . "/net-fu/tmp/" ;
							//$img_url .= basename($response);
						}
					}
					else // error from gimp
					{
						$target = "HTTP/1.0 500 Internal Server Error";
					}
				
				}
				
				fclose($fp);
					
				
			//}
			$imageOutput = str_replace($rootDir, Mage::getBaseUrl(), $fileoutput);
			$result = array('src'=>$imageOutput.'?r='.time(),'path' => $fileoutput);
			$this->getResponse()->setBody(Mage::helper('core')->jsonEncode($result));
			//Mage::log("result= ".$result."\n------------------\n cmd=".$cmd."\n-------------------------------------",null,'picasso.log');
		}
	}
	
	public function processThumbImageAction(){
		$result = $this->getRequest()->getPost();
		// to pass data through iframe you will need to encode all html tags
		if(!empty($result['imageThumbPath'])){
			$result['images'] = $this->convertThumbImage($result['imageThumbPath']);
		}
		$this->getResponse()->setBody(Mage::helper('core')->jsonEncode($result));
	}
	
	public function getEffectThumbImagePath($imagePath){
		if(file_exists($imagePath)){
			$sessionId = Mage::helper('picasso')->getSessionId();
			$rootDir = MAGENTO_ROOT.self::DS;
			$rootDir = str_replace("\\",'/',$rootDir);
			$imageDir = $rootDir.'media'.self::DS.'picasso'.self::DS.'uploads'.self::DS.$sessionId;
			$imageDir = str_replace("\\",'/',$imageDir);
			$effects = $effects = Mage::getResourceModel('picasso/effect_collection')
			->addGroupNameToSelect()
			->addActiveToFilter()
			->toArrayEffect();
			$fileinput = $imagePath;
			$imageConverts = array();
			$listEffect = array();
			foreach ($effects as $effect){
				$pathExplode = explode(self::DS,$fileinput);
				$outputImage = end($pathExplode);
				$fileoutput = $imageDir.self::DS.$effect['code'].self::DS.$outputImage;
				unset($pathExplode[count($pathExplode)-1]);
				$effectDir = implode(self::DS,$pathExplode).self::DS.$effect['code'];
				if(!is_dir($effectDir)){
					mkdir($effectDir);
				}
				$imageOutput = str_replace($rootDir, Mage::getBaseUrl(), $fileoutput);
				$listEffect[] = array(
						'effect' => $effect['id'],
						'image_output' => $imageOutput
				);
			}
			return $listEffect;
		}
		else{
			return array();
		}
	}

	public function downloadAction(){
		$imagePath = $this->getRequest()->getParam('path');
		$fileName = end(explode('/', $imagePath));
		$fh = fopen($imagePath, 'r');
		$theData = fread($fh, filesize($imagePath));
		fclose($fh);
		$this->_prepareDownloadResponse($fileName, $theData);
	}
	
	public function convertThumbImage($imagePath){
		$ip_addr = "127.0.0.1";
		$ip_port = "10008";
		$MAGIC = 'G'; // inferred GIMP Net-FU Protocol Header
		if(file_exists($imagePath)){
			$sessionId = Mage::helper('picasso')->getSessionId();
			$rootDir = MAGENTO_ROOT.self::DS;
			$rootDir = str_replace("\\",'/',$rootDir);
			$imageDir = $rootDir.'media'.self::DS.'picasso'.self::DS.'uploads'.self::DS.$sessionId;
			$imageDir = str_replace("\\",'/',$imageDir);
			$effects = $effects = Mage::getResourceModel('picasso/effect_collection')
							->addGroupNameToSelect()
							->addActiveToFilter()
							->toArrayEffect();
			$fileinput = $imagePath;
			$imageConverts = array();
			$listEffect = array(); 
			$script = '';
			$params = ' 100 80 0 0 0 0';
			foreach ($effects as $effect){
					$pathExplode = explode(self::DS,$fileinput);
					$outputImage = end($pathExplode);
					$fileoutput = $imageDir.self::DS.$effect['code'].self::DS.$outputImage;
					unset($pathExplode[count($pathExplode)-1]);
					$effectDir = implode(self::DS,$pathExplode).self::DS.$effect['code'];
					if(!is_dir($effectDir)){
						mkdir($effectDir);
					}
					
					$runScript = str_replace(array('{{fileinput}}','{{fileoutput}}','{{params}}','(gimp-quit 0)'),array($fileinput,$fileoutput,$params,''), $effect['script_fu']);
					
					//$runScript = str_replace(array('{{fileinput}}','{{fileoutput}}','(gimp-quit 0)'),array($fileinput,$fileoutput,''), $effect['script_fu']);
					$script .= $runScript;
					$imageOutput = str_replace($rootDir, Mage::getBaseUrl(), $fileoutput);
					$listEffect[] = array(
								   		'effect' => $effect['id'],
										'image_output' => $imageOutput
	                               );
			}
			/*	
			$gimpPath = Mage::helper('picasso')->getGimpPath();
			$cmd = $gimpPath.' -i -b "'.$script.'" -b "(gimp-quit 0)"';
			$return ='' ;
			$result = shell_exec($cmd);
			*/
			$cmdLine = str_replace("\\", "",$script);
			$cmdLength = strlen($cmdLine);
			$old_err = error_reporting(E_ERROR | E_PARSE);
			$fp = fsockopen($ip_addr, $ip_port, $errno, $errstr, 30);
			if (!$fp) {
				$target = "HTTP/1.0 503 Service Unavailable";
			} else {
				$temp = sprintf("G%c%c%s",$cmdLength >> 8,$cmdLength & 0xff,$cmdLine);
				fwrite($fp,$temp);
				$c = fgetc($fp);
				if( $c == $MAGIC )
				{
					$response = fread($fp,2);
					// 3 characters discarded for unknown reasons
					// I don't actually have any documentation for the Net-FU protocol
					// so it's monkey see, monkey do
					$response_len = ord(fread($fp,1)); // length of the file name
					$response = fread($fp, $response_len);
					if( preg_match( "/^ERROR: ([^:]*)/", $response, $matches ) ) {
						$img_url = "\"" . $matches[1] . " - " . $matches[2] . "\"";
					}
					else {
						$img_url = "http://" . $_SERVER['SERVER_NAME'] . "/net-fu/tmp/" ;
						$img_url .= basename($response);
					}
				}
				else // error from gimp
				{
					$target = "HTTP/1.0 500 Internal Server Error";
				}
				fclose($fp);
			}
			
			Mage::log("result= ".$result."\n------------------\n cmd=".$cmdLine."\n-------------------------------------",null,'picasso.log');
			return $listEffect;
		}
		else{
			return array();
		}
	}
}


/**
 * Handle file uploads via XMLHttpRequest
 */
class qqUploadedFileXhr {
	
    /**
     * Save the file to the specified path
     * @return boolean TRUE on success
     */
    function save($path) {    
        $input = fopen("php://input", "r");
        $temp = tmpfile();
        $realSize = stream_copy_to_stream($input, $temp);
        fclose($input);
        
        if ($realSize != $this->getSize()){            
            return false;
        }
        
        $target = fopen($path, "w");        
        fseek($temp, 0, SEEK_SET);
        stream_copy_to_stream($temp, $target);
        fclose($target);
        
        return true;
    }
    function getName() {
        return $_GET['qqfile'];
    }
    function getSize() {
        if (isset($_SERVER["CONTENT_LENGTH"])){
            return (int)$_SERVER["CONTENT_LENGTH"];            
        } else {
            throw new Exception('Getting content length is not supported.');
        }      
    }   
}

/**
 * Handle file uploads via regular form post (uses the $_FILES array)
 */
class qqUploadedFileForm {  
    /**
     * Save the file to the specified path
     * @return boolean TRUE on success
     */
    function save($path) {
        if(!move_uploaded_file($_FILES['qqfile']['tmp_name'], $path)){
            return false;
        }
        return true;
    }
    function getName() {
        return $_FILES['qqfile']['name'];
    }
    function getSize() {
        return $_FILES['qqfile']['size'];
    }
} 


class qqUploadedFileURL {  
    /**
     * Save the file to the specified path
     * @return boolean TRUE on success
     */
    function save($path) {
        return true;
    }
    function getName() {
        return null;
    }
    function getSize() {
        return null;
    }
}

class qqFileUploader {
    private $allowedExtensions = array();
    private $sizeLimit = 10485760;
    private $file;
	const DS ="/";
    function __construct(array $allowedExtensions = array(), $sizeLimit = 10485760){        
        $allowedExtensions = array_map("strtolower", $allowedExtensions);
            
        $this->allowedExtensions = $allowedExtensions;        
        $this->sizeLimit = $sizeLimit;
        
        //$this->checkServerSettings();       

        if (isset($_GET['qqfile'])) {
            $this->file = new qqUploadedFileXhr();
        } elseif (isset($_FILES['qqfile'])) {
            $this->file = new qqUploadedFileForm();
        } 
        elseif(isset($_GET['url'])) {
            $this->file = new qqUploadedFileURL();
        }
        else {
            $this->file = false; 
        }
    }
    
    private function checkServerSettings(){        
        $postSize = $this->toBytes(ini_get('post_max_size'));
        $uploadSize = $this->toBytes(ini_get('upload_max_filesize'));        
        
        if ($postSize < $this->sizeLimit || $uploadSize < $this->sizeLimit){
            $size = max(1, $this->sizeLimit / 1024 / 1024) . 'M';             
            die("{'error':'increase post_max_size and upload_max_filesize to $size'}");    
        }        
    }
    
    private function toBytes($str){
        $val = trim($str);
        $last = strtolower($str[strlen($str)-1]);
        switch($last) {
            case 'g': $val *= 1024;
            case 'm': $val *= 1024;
            case 'k': $val *= 1024;        
        }
        return $val;
    }
    
    /**
     * Returns array('success'=>true) or array('error'=>'error message')
     */
    function handleUpload($uploadDirectory, $replaceOldFile = FALSE){
    	
    	if(!is_dir($uploadDirectory)){
			mkdir($uploadDirectory);
		}
        if (!is_writable($uploadDirectory)){
            return array('error' => "Server error. Upload directory isn't writable.");
        }
        
        if (!$this->file){
            return array('error' => 'No files were uploaded.');
        }
        
        $size = $this->file->getSize();
        
        if ($size == 0) {
            return array('error' => 'File is empty');
        }
        
        if ($size > $this->sizeLimit) {
            return array('error' => 'File is too large');
        }
        
        $pathinfo = pathinfo($this->file->getName());
        $filename = $pathinfo['filename'];
        //$filename = md5(uniqid());
        $ext = $pathinfo['extension'];

        if($this->allowedExtensions && !in_array(strtolower($ext), $this->allowedExtensions)){
            $these = implode(', ', $this->allowedExtensions);
            return array('error' => 'File has an invalid extension, it should be one of '. $these . '.');
        }
        
        if(!$replaceOldFile){
            /// don't overwrite previous files that were uploaded
            while (file_exists($uploadDirectory . $filename . '.' . $ext)) {
                $filename .= rand(10, 99);
            }
        }
        
        if ($this->file->save($uploadDirectory . $filename . '.' . $ext)){
        	$sessionId = Mage::helper('picasso')->getSessionId();
			$imageUrl = Mage::getBaseUrl(Mage_Core_Model_Store::URL_TYPE_MEDIA).'picasso/uploads/'.$sessionId.'/'.$filename.'.' . $ext;
			$uploadDir = MAGENTO_ROOT.self::DS.'media'.self::DS.'picasso'.self::DS.'uploads'.self::DS.$sessionId.self::DS;
            $uploadDir = str_replace("\\", self::DS, $uploadDir);
			$imagePath = $uploadDir.$filename . '.' . $ext;
			return array('success'=>true,'imageUrl'=>$imageUrl,'imagePath' => $imagePath,'fileName'=>$filename . '.' . $ext,'uploadDir'=>$uploadDir);
        } else {
            return array('error'=> 'Could not save uploaded file.' .
                'The upload was cancelled, or server error encountered');
        }
        
    } 
    
    
    //Johnny add upload file from URL
     function handleUploadFromURL($uploadDirectory,$url){
    	
    	if(!is_dir($uploadDirectory)){
			mkdir($uploadDirectory);
		}
        if (!is_writable($uploadDirectory)){
            return array('error' => "Server error. Upload directory isn't writable.");
        } 
        
        // Get file from URL
        $filename = basename($url);
        $ext = end(explode(".",strtolower($filename)));
        
        if($this->allowedExtensions && !in_array(strtolower($ext), $this->allowedExtensions)){
            $these = implode(', ', $this->allowedExtensions);
            return array('error' => 'File has an invalid extension, it should be one of '. $these . '.');
        }
        
        $uploaded = file_put_contents($uploadDirectory . $filename . '.' . $ext,file_get_contents($url));
        
        if ($uploaded>0){
        	$sessionId = Mage::helper('picasso')->getSessionId();
			$imageUrl = Mage::getBaseUrl(Mage_Core_Model_Store::URL_TYPE_MEDIA).'picasso/uploads/'.$sessionId.'/'.$filename.'.' . $ext;
			$uploadDir = MAGENTO_ROOT.self::DS.'media'.self::DS.'picasso'.self::DS.'uploads'.self::DS.$sessionId.self::DS;
            $uploadDir = str_replace("\\", self::DS, $uploadDir);
			$imagePath = $uploadDir.$filename . '.' . $ext;
			return array('success'=>true,'imageUrl'=>$imageUrl,'imagePath' => $imagePath,'fileName'=>$filename . '.' . $ext,'uploadDir'=>$uploadDir);
        } else {
            return array('error'=> 'Could not save uploaded file.' .
                'The upload was cancelled, or server error encountered');
        }
        
    }
    
    
}