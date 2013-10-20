<?php

class SM_Picasso_Block_Adminhtml_Effect_Edit extends Mage_Adminhtml_Block_Widget_Form_Container
{
    public function __construct()
    {
        parent::__construct();

        $this->_objectId    = 'id';
        $this->_blockGroup  = 'picasso';
        $this->_controller  = 'adminhtml_effect';

        $this->_updateButton('save', 'label', Mage::helper('picasso')->__('Save Effect'));
        $this->_updateButton('delete', 'label', Mage::helper('picasso')->__('Delete Effect'));

        $this->_addButton('saveandcontinue', array(
            'label'     => Mage::helper('adminhtml')->__('Save And Continue Edit'),
            'onclick'   => 'saveAndContinueEdit()',
            'class'     => 'save',
        ), -100);

        $this->_formScripts[] = "
            function saveAndContinueEdit(){
                editForm.submit($('edit_form').action+'back/edit/');
            }
        ";
    }

    public function getHeaderText()
    {
        return Mage::helper('picasso')->__("Edit Effect '%s'", $this->htmlEscape(Mage::registry('effect_data')->getTitle()));
    }
}