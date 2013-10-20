<?php

class SM_Picasso_Block_Checkout_Cart_Item_Renderer extends Mage_Checkout_Block_Cart_Item_Renderer
{
	public function getEffectImage(){
		$infoRequest = $this->getInfoBuyRequest();
		if(is_array($infoRequest)){
			if(!empty($infoRequest['file-image-selected'])){
				return $infoRequest['file-image-selected'];
			}
		}
		return false;
	}
	
	public function getInfoBuyRequest(){
		$item = $this->getItem();
		$options = $item->getOptionByCode('info_buyRequest');
		$data = $options->getData('value');
		$data = unserialize($data);
		return $data;
	}
}
