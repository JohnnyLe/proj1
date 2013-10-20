<?php
class SM_Picasso_Model_GroupOption extends Mage_Core_Model_Abstract
{
    protected $_priceConfig;
	public function _construct() {
        parent::_construct();
        $this->_init('picasso/groupOption');
    }

    public function getPriceConfig(){
        if(is_null($this->_priceConfig)){
            $priceConfig = $this->getData('price_config');
            if(!empty($priceConfig)){
                $priceConfig = unserialize($priceConfig);
                $priceConfig = array_filter($priceConfig);
                $this->_priceConfig = $priceConfig;
            }
        }
        return $this->_priceConfig;
    }

    public function getPriceConfigFormated(){
        $result = array();
        if($this->getPriceConfig()){
            $priceConfig = $this->getPriceConfig();
            foreach($priceConfig as $rate){
                $result[] = $rate;
            }
        }
        return $result;
    }
}