<?php
class SM_Picasso_Model_Mysql4_GroupOption extends Mage_Core_Model_Mysql4_Abstract
{
	public function _construct() {
        $this->_init('picasso/group_option','id');
    }
}