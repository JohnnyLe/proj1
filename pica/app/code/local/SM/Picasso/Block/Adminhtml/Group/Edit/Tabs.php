<?php

class SM_Picasso_Block_Adminhtml_Group_Edit_Tabs extends Mage_Adminhtml_Block_Widget_Tabs
{

    public function __construct()
    {
        parent::__construct();
        $this->setId('picasso_group_tabs');
        $this->setDestElementId('edit_form');
        $this->setTitle(Mage::helper('picasso')->__('Group Information'));
    }

    protected function _beforeToHtml()
    {
        $this->addTab('general_section', array(
            'label'     => Mage::helper('picasso')->__('Group Info'),
            'title'     => Mage::helper('picasso')->__('Group Info'),
            'content'   => $this->getLayout()->createBlock('picasso/adminhtml_group_edit_tab_main')->toHtml(),
        ));

        return parent::_beforeToHtml();
    }
}