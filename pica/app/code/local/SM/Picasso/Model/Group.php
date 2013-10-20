<?php
class SM_Picasso_Model_Group extends Mage_Core_Model_Abstract
{
	public function _construct() {
        parent::_construct();
        $this->_init('picasso/group');
    }
}