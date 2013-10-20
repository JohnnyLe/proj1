<?php

class SM_Picasso_Block_Adminhtml_Group_Edit extends Mage_Adminhtml_Block_Widget_Form_Container
{
    public function __construct()
    {
        parent::__construct();

        $this->_objectId    = 'id';
        $this->_blockGroup  = 'picasso';
        $this->_controller  = 'adminhtml_group';

        $this->_updateButton('save', 'label', Mage::helper('picasso')->__('Save Group'));
        $this->_updateButton('delete', 'label', Mage::helper('picasso')->__('Delete Group'));

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
        return Mage::helper('picasso')->__("Edit Group '%s'", $this->htmlEscape(Mage::registry('group_data')->getTitle()));
    }
}