<?php 
class SM_Picasso_Block_ImageEditor extends Mage_Catalog_Block_Product_View
{

    private $_quoteItem;

	public function getGroupsEffect(){
		$effects = Mage::getResourceModel('picasso/effect_collection')
					->addGroupNameToSelect()
					->addActiveToFilter()
					->toArrayEffect();
		$groups = array();
		foreach($effects as $effect){
			if(empty($groups[$effect['group']]) && !is_array($groups[$effect['group']])){
				$groups[$effect['group']] = array(
											'name' => $effect['group_name'],
											'effects' => array()
										  );
			}
			$groups[$effect['group']]['effects'][] = $effect;
		}
		return $groups;
	}
	
	
	public function getDefaultConfig(){
        $effects = Mage::getResourceModel('picasso/effect_collection')->toArrayEffect2();
		$config = array(
					'siteUrl' => $this->getUrl(),
					'imageSizeAllow' => Mage::helper('picasso')->getImageFileSizeAllow(),
					'imageExtAllow' => Mage::helper('picasso')->getFileImageExtensionAllow(),
					'defaultEffect' => Mage::helper('picasso')->getDefaultEffect(),
                    'effects' => $effects
				);
		return Mage::helper('core')->jsonEncode($config);
	}
	
	public function getEditJsonConfig(){
		$quoteItem = $this->getCurrentQuoteItem();
		if(empty($quoteItem)){
			return false;
		}
		$result = array();
		$buyRequest = $quoteItem->getBuyRequest();
		$result['orgImagePath'] = $buyRequest->getData('org-image-path');
		$result['effectSelected'] = $buyRequest->getData('effect-selected');
		$result['fileImageSelected'] = $buyRequest->getData('file-image-selected');
        $result['filePathImageSelected'] = $buyRequest->getData('file-path-image-selected');

		$result['imageEffects'] = $buyRequest->getData('image-effects');
        $result['uploadList'] = json_decode($buyRequest->getData('upload_list'));
		$result['allowExt'] = Mage::helper('picasso')->getFileImageExtensionAllow();
		$result['imageFileSize'] = Mage::helper('picasso')->getImageFileSizeAllow();
		
		$brightness = $buyRequest->getData('brightness');
		$contrast = $buyRequest->getData('contrast');
		
		$brightness = empty($brightness) ? 0 : $brightness;
		$contrast = empty($contrast) ? 0 : $contrast;
		
		$result['brightnessContrast'] = array('brightness'=>$brightness,'contrast'=>$contrast);
		$result['orgImageSrc'] = $buyRequest->getData('org_image_src');
		$result['cropSelect'] = explode(',', $buyRequest->getData('crop_select'));
		return Mage::helper('core')->jsonEncode($result);
	}

    public function getBuyRequest($key){
        $quoteItem = $this->getCurrentQuoteItem();
        if($quoteItem){
            $buyRequest = $quoteItem->getBuyRequest();
            return $buyRequest->getData($key);
        }
        return '';
    }

    protected function getCurrentQuoteItem()
    {
        if(is_null($this->_quoteItem))
        {
            $cart = Mage::getSingleton('checkout/cart');
            $id = $this->getRequest()->getParam('id');
            $this->_quoteItem = $cart->getQuote()->getItemById($id);
        }
        return $this->_quoteItem;
    }
} 