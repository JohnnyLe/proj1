<?php
class SM_Picasso_ImageController extends Mage_Core_Controller_Front_Action
{
	const DS = "/";
	public function indexAction(){
		$this->convertImage();
	}
	
	public function convertAction(){
		$imagePath = $this->getRequest()->getPost('image');
		$effectsPost = $this->getRequest()->getPost('effects');
		$sessionId = Mage::helper('picasso')->getSessionId();
		$rootDir = MAGENTO_ROOT.self::DS;
		$imageDir = $rootDir.'media'.self::DS.'picasso'.self::DS.'uploads'.self::DS.$sessionId;
		$imageDir = str_replace("\\",'/',$imageDir);
		$effects = $effects = Mage::getResourceModel('picasso/effect_collection')
						->addGroupNameToSelect()
						->toArrayEffect();
		$fileinput = $imagePath;
		$imageConverts = array();
		$listEffect = array(); 
		$script = '';
		foreach ($effects as $effect){
			if(in_array($effect['code'], $effectsPost)){
				$pathExplode = explode(self::DS,$fileinput);
				$outputImage = end($pathExplode);
				$fileoutput = $imageDir.self::DS.$effect['code'].self::DS.$outputImage;
				unset($pathExplode[count($pathExplode)-1]);
				$effectDir = implode(self::DS,$pathExplode).self::DS.$effect['code'];
				if(!is_dir($effectDir)){
					mkdir($effectDir);
				}
				
				$runScript = str_replace(array('{{fileinput}}','{{fileoutput}}','(gimp-quit 0)'),array($fileinput,$fileoutput,''), $effect['script_fu']);
				$script .= $runScript;
				$imageOutput = 
				$listEffect[] = array(
							   		'effect' => $effect['id'],
									'image_output' => $runScript
                               );
			}
		}
		$script .= '(gimp-quit 0)';
		$cmd = '"C:/Program Files/GIMP 2/bin/gimp-2.8.exe" -i -b "'.$script.'"';
		$return ='' ;
		$result = exec($cmd,$output,$return);
		foreach(){
			
		}
	}
	
	function convertImage(){
		$sessionId = Mage::helper('picasso')->getSessionId();
		$image = $_GET['img'];
		$effect = $_GET['effect'];
		$imageDir = MAGENTO_ROOT.self::DS.'media'.self::DS.'picasso'.self::DS.'uploads'.self::DS.$sessionId;
		$imageDir = str_replace("\\",'/',$imageDir);
		$effects = $effects = Mage::getResourceModel('picasso/effect_collection')
					->addGroupNameToSelect()
					->toArrayEffect();
		
		$effectSelected = $effects[$effect];
		
		$fileinput = $image;
		$pathExplode = explode(self::DS,$fileinput);
		$outputImage = end($pathExplode);
		$fileoutput = $imageDir.self::DS.$effect.self::DS.$outputImage;
		unset($pathExplode[count($pathExplode)-1]);
		$effectDir = implode(self::DS,$pathExplode).self::DS.$effect;
		//die($fileoutput);
		if (file_exists($fileoutput))
		{
			
			
			$size = getimagesize($fileoutput);

			$fp = fopen($fileoutput, 'rb');

			if ($size and $fp)
			{
				// Optional never cache
			//  header('Cache-Control: no-cache, no-store, max-age=0, must-revalidate');
			//  header('Expires: Mon, 26 Jul 1997 05:00:00 GMT'); // Date in the past
			//  header('Pragma: no-cache');

				// Optional cache if not changed
			//  header('Last-Modified: '.gmdate('D, d M Y H:i:s', filemtime($file)).' GMT');

				// Optional send not modified
			//  if (isset($_SERVER['HTTP_IF_MODIFIED_SINCE']) and 
			//      filemtime($file) == strtotime($_SERVER['HTTP_IF_MODIFIED_SINCE']))
			//  {
			//      header('HTTP/1.1 304 Not Modified');
			//  }

				header('Content-Type: '.$size['mime']);
				header('Content-Length: '.filesize($fileoutput));

				fpassthru($fp);

				exit;
			}
		}
		else{
			
			if(!is_dir($effectDir)){
				mkdir($effectDir);
			}
			//$script = $effectSelected['effect_function'].str_replace(array('{{fileinput}}','{{fileoutput}}'),array($fileinput,$fileoutput), $effectSelected['run_script']);
			$script = str_replace(array('{{fileinput}}','{{fileoutput}}'),array($fileinput,$fileoutput), $effectSelected['script_fu']);
			//die($script);
			
			$cmd = '"C:/Program Files/GIMP 2/bin/gimp-2.8.exe" -i -b "'.$script.'"';
			//die($cmd);
			$return ='' ;
			$result = exec($cmd,$output,$return);
			if (file_exists($fileoutput))
			{
				
				
				$size = getimagesize($fileoutput);

				$fp = fopen($fileoutput, 'rb');

				if ($size and $fp)
				{
					// Optional never cache
				//  header('Cache-Control: no-cache, no-store, max-age=0, must-revalidate');
				//  header('Expires: Mon, 26 Jul 1997 05:00:00 GMT'); // Date in the past
				//  header('Pragma: no-cache');

					// Optional cache if not changed
				//  header('Last-Modified: '.gmdate('D, d M Y H:i:s', filemtime($file)).' GMT');

					// Optional send not modified
				//  if (isset($_SERVER['HTTP_IF_MODIFIED_SINCE']) and 
				//      filemtime($file) == strtotime($_SERVER['HTTP_IF_MODIFIED_SINCE']))
				//  {
				//      header('HTTP/1.1 304 Not Modified');
				//  }

					header('Content-Type: '.$size['mime']);
					header('Content-Length: '.filesize($fileoutput));

					fpassthru($fp);

					exit;
				}
			}
		}
		
	}
}