<?php
class SM_Picasso_Model_Observer extends Mage_Core_Model_Abstract
{ 
	public function hookCheckoutCartProductAddAfter($observer) {
			$quoteItem = $observer->getQuoteItem();
			$qty = intval($quoteItem->getQty());
			$price = $this->getEffectPrice($quoteItem);
			$product = $quoteItem->getProduct();
			if($price !== false){
				$product->setData('effect_price',$price);
				//$quoteItem->setCustomPrice($price);
				//$quoteItem->setOriginalCustomPrice($price);	
			}		
		return $this;
    }
    
	public function getInfoBuyRequest($quoteItem){
		$options = $quoteItem->getOptionByCode('info_buyRequest');
		$data = $options->getData('value');
		$data = unserialize($data);
		return $data;
	}
	
	public function getEffectPrice($quoteItem){
		$infoRequest = $this->getInfoBuyRequest($quoteItem);
		if(is_array($infoRequest)){
			if(!empty($infoRequest['effect-selected'])){
				$effect = Mage::getModel('picasso/effect')->load($infoRequest['effect-selected']);
				return $effect->getPrice();
			}
		}
		return false;
	}
}