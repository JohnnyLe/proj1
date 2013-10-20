<?php
class SM_Picasso_Model_Mysql4_GroupOption_Collection extends Mage_Core_Model_Mysql4_Collection_Abstract {
	protected $options = null;
    public function _construct() {
        parent::_construct();
        $this->_init('picasso/groupOption');
    }
    
    public function toOptionArray(){
    	$options = array();
    	if(is_null($this->options)){
    		$this->options[] = array(
    				'label'=> 'Root',
    				'value' => 0
    		);
	    	foreach($this as $item){
	    		$this->options[] = array(
	    			'label'=> $item->getName(),
	    			'value' => $item->getId()
	    		);
	    	}
    	}
    	return $this->options;
    }
}