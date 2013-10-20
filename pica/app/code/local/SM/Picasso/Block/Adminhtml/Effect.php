<?php
class SM_Picasso_Block_Adminhtml_Effect extends Mage_Adminhtml_Block_Widget_Grid_Container {
    public function __construct() {
        $this->_controller = 'adminhtml_effect';
        $this->_blockGroup = 'picasso';
        $this->_headerText = Mage::helper('picasso')->__('Effect Manager');
        parent::__construct();

        //$this->setTemplate('my_picasso/effect.phtml');
    }

    protected function _prepareLayout() {
        $this->setChild('add_new_button',
                $this->getLayout()->createBlock('adminhtml/widget_button')
                ->setData(array(
                'label'     => Mage::helper('picasso')->__('Add New Effect'),
                'onclick'   => "setLocation('".$this->getUrl('*/*/add')."')",
                'class'   => 'add'
                ))
        );
        $this->setChild('grid', $this->getLayout()->createBlock('picasso/adminhtml_effect_grid', 'effect.grid'));
        return parent::_prepareLayout();
    }

    public function getAddNewButtonHtml() {
        return $this->getChildHtml('add_new_button');
    }

    public function getGridHtml() {
        return $this->getChildHtml('grid');
    }
}