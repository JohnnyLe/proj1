<?php
class SM_Picasso_Model_Override_Catalog_Product_Option extends Mage_Catalog_Model_Product_Option
{
    protected $_optionGroup;
    protected function _construct()
    {
        $this->_init('picasso/catalog_product_option');
    }
    
    /**
     * Get Product Option Collection
     *
     * @param  Mage_Catalog_Model_Product $product
     * @return Aijko_CustomOptionDescription_Model_Resource_Eav_Mysql4_Product_Option_Collection
     */
    public function getProductOptionCollection(Mage_Catalog_Model_Product $product)
    {
        $collection = $this->getCollection()
            ->addFieldToFilter('product_id', $product->getId())
            ->addTitleToResult($product->getStoreId())
            ->addPriceToResult($product->getStoreId())
            ->addDescriptionToResult($product->getStoreId())
            ->setOrder('sort_order', 'asc')
            ->setOrder('title', 'asc')
            ->addValuesToResult($product->getStoreId());
        
        return $collection;
    }

    public function getOptionGroup()
    {
        if($group = $this->getGroup()){
            if(is_null($this->_optionGroup)){
                $this->_optionGroup = Mage::getModel('picasso/groupOption')->load($group);
            }
        }
        return $this->_optionGroup;
    }
    /*
    public function getCustomOptionDepend()
    {
        if($customOptionDepend = $this->getData('custom_option_depend')){
            if(is_string($customOptionDepend)){
                return explode(',',$customOptionDepend);
            }
        }
        return $customOptionDepend;
    }
    */
}