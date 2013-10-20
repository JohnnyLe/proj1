<?php

class SM_Picasso_Block_Adminhtml_GroupOption_Edit_Tab_Price_Element_Price
    extends Varien_Data_Form_Element_Abstract
{
	public function __construct($attributes = array())
    {
        parent::__construct($attributes);
        
    }
    
    public function getRenderer(){
    	$this->_renderer = new SM_Picasso_Block_Adminhtml_GroupOption_Edit_Tab_Price_Element_PriceRender();
    	return $this->_renderer;
    }
    
	public function getElementHtml()
    {
    	$html = $this->getRenderer()->render($this);
        return $html;
    }
}
?>