<?php
class SM_Picasso_Model_Mysql4_Group_Collection extends Mage_Core_Model_Mysql4_Collection_Abstract {
	protected $options = null;
    public function _construct() {
        parent::_construct();
        $this->_init('picasso/group');
    }
    
    public function toOptionArray(){
    	$options = array();
    	if(is_null($this->options)){
	    	foreach($this as $item){
	    		$this->options[] = array(
	    			'label'=> $item->getName(),
	    			'value' => $item->getId()
	    		);
	    	}
    	}
    	//die();
    	return $this->options;
    }
}