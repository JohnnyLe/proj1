<?php

class SM_Picasso_Model_Catalog_Product_Price extends Mage_Catalog_Model_Product_Type_Price
{
	public function getFinalPrice($qty = null, $product)
	{
		if (is_null($qty) && !is_null($product->getCalculatedFinalPrice())) {
			return $product->getCalculatedFinalPrice();
		}

        $finalPrice = $this->getBasePrice($product, $qty);
        $product->setFinalPrice($finalPrice);
        Mage::dispatchEvent('catalog_product_get_final_price', array('product' => $product, 'qty' => $qty));
        if($finalPrice = $this->getPriceFinal($product)){

        }
        else{

            $finalPrice = $product->getData('final_price');
            $finalPrice = $this->_applyOptionsPrice($product, $qty, $finalPrice);
            $finalPrice += floatval($this->getEffectPrice($product));
            //echo '$finalPrice='.$product->getData('effect_price');
            $finalPrice = max(0, $finalPrice);
        }

		$product->setFinalPrice($finalPrice);
	
		return $finalPrice;
	}
	
	public function getEffectPrice($product, $qty = null)
	{
		$price = 0.0;
		if ($product->hasCustomOptions()) {
			$customOption = $product->getCustomOption('info_buyRequest');
			if ($customOption) {
				$infoRequest = $product->getCustomOption('info_buyRequest')->getData('value');
				$infoRequest = unserialize($infoRequest);
				if(is_array($infoRequest)){
					if(!empty($infoRequest['effect-selected'])){
						$effect = Mage::getModel('picasso/effect')->load($infoRequest['effect-selected']);
						$price =  $effect->getPrice();
					}
				}
			}
		}
		return $price;
	}

    public function getPriceFinal($product){
        $price = 0.0;
        if ($product->hasCustomOptions()) {
            $customOption = $product->getCustomOption('info_buyRequest');
            if ($customOption) {
                $infoRequest = $product->getCustomOption('info_buyRequest')->getData('value');
                $infoRequest = unserialize($infoRequest);
                if(is_array($infoRequest)){
                    if(!empty($infoRequest['final_price'])){
                        $price = floatval($infoRequest['final_price']);
                    }
                }
            }
        }
        return $price;
    }
}