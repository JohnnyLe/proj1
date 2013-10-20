<?php

class SM_Picasso_Block_Adminhtml_Effect_Edit_Tabs extends Mage_Adminhtml_Block_Widget_Tabs
{

    public function __construct()
    {
        parent::__construct();
        $this->setId('picasso_effect_tabs');
        $this->setDestElementId('edit_form');
        $this->setTitle(Mage::helper('picasso')->__('Effect Information'));
    }

    protected function _beforeToHtml()
    {
        $this->addTab('general_section', array(
            'label'     => Mage::helper('picasso')->__('Effect Info'),
            'title'     => Mage::helper('picasso')->__('Effect Info'),
            'content'   => $this->getLayout()->createBlock('picasso/adminhtml_effect_edit_tab_main')->toHtml(),
        ));

        return parent::_beforeToHtml();
    }
}