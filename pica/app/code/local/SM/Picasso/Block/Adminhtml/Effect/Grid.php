<?php

class SM_Picasso_Block_Adminhtml_Effect_Grid extends Mage_Adminhtml_Block_Widget_Grid {
    public function __construct() {
        parent::__construct();
        $this->setId('effectGrid');
        $this->setDefaultSort('creation_time');
        $this->setDefaultDir('DESC');
        $this->setSaveParametersInSession(true);
    }

    protected function _getStore() {
        $storeId = (int) $this->getRequest()->getParam('store', 0);
        return Mage::app()->getStore($storeId);
    }

    protected function _prepareCollection() {
        $collection = Mage::getModel('picasso/effect')->getCollection();
        $collection->addGroupNameToSelect();
        $this->setCollection($collection);
        return parent::_prepareCollection();
    }

    protected function _prepareColumns() {
        $this->addColumn('effect_id', array(
                'header'    => Mage::helper('picasso')->__('ID'),
                'align'     =>'right',
                'width'     => '50px',
                'index'     => 'id',
        ));
        
		$this->addColumn('image', array(
            'header' => Mage::helper('picasso')->__('Image'),
            'align' => 'center',
            'index' => 'image',
            'renderer' => 'picasso/adminhtml_widget_grid_column_renderer_image',
            'escape' => true,
            'sortable' => false,
            'width' => '150px',
        ));
        $this->addColumn('title', array(
                'header'    => Mage::helper('picasso')->__('Name'),
                'align'     =>'left',
                'index'     => 'name',
        ));
		

		$this->addColumn('Group', array(
				'header'    => Mage::helper('picasso')->__('Group'),
				'align'     =>'left',
				'index'     => 'group_name',
		));


        $this->addColumn('action',
                array(
                'header'    =>  Mage::helper('picasso')->__('Action'),
                'width'     => '100',
                'type'      => 'action',
                'getter'    => 'getId',
                'actions'   => array(
                        array(
                                'caption'   => Mage::helper('picasso')->__('Edit'),
                                'url'       => array('base'=> '*/*/edit'),
                                'field'     => 'id'
                        ),
                        array(
                                'caption'   => Mage::helper('picasso')->__('Delete'),
                                'url'       => array('base'=> '*/*/delete'),
                                'field'     => 'id'
                        )
                ),
                'filter'    => false,
                'sortable'  => false,
                'index'     => 'stores',
                'is_system' => true,
        ));

        return parent::_prepareColumns();
    }

    public function getRowUrl($row) {
        return $this->getUrl('*/*/edit', array('id' => $row->getId()));
    }

}