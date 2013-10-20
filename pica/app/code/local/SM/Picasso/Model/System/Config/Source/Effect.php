<?php
class SM_Picasso_Model_System_Config_Source_Effect
{
	protected $_options;

    public function toOptionArray()
    {
        if (!$this->_options) {
            $this->_options = Mage::getResourceModel('picasso/effect_collection')->toOptionIdArray();
        }
        return $this->_options;
    }
}