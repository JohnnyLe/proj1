<?php

class SM_Picasso_Model_Catalog_Product_Type extends Mage_Catalog_Model_Product_Type_Abstract
{
	const TYPE_CP_PRODUCT = 'picasso';
    public function processBuyRequest($product, $buyRequest)
    {
        return array('group_option'=>$buyRequest->getData('group_option'));
    }
}