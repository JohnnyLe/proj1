<?php

class SM_Picasso_Block_Adminhtml_Effect_Edit_Tab_Main
    extends Mage_Adminhtml_Block_Widget_Form
    implements Mage_Adminhtml_Block_Widget_Tab_Interface
{
    protected function _prepareForm()
    {
        /* @var $model Mage_Cms_Model_Effect */
        $model = Mage::registry('effect_data');



        $form = new Varien_Data_Form();

        $form->setHtmlIdPrefix('effect_');

        $fieldset = $form->addFieldset('base_fieldset', array('legend'=>Mage::helper('picasso')->__('Effect Information')));

        if ($model->getId()) {
            $fieldset->addField('id', 'hidden', array(
                'name' => 'id',
            ));
        }

        $fieldset->addField('name', 'text', array(
            'name'      => 'name',
            'label'     => Mage::helper('picasso')->__('Name'),
            'title'     => Mage::helper('picasso')->__('Name'),
            'required'  => true
        ));
        
        $fieldset->addField('price', 'text', array(
            'name'      => 'price',
            'label'     => Mage::helper('picasso')->__('Price'),
            'title'     => Mage::helper('picasso')->__('Price'),
            'required'  => true
        ));

        $fieldset->addField('code', 'text', array(
            'name'      => 'code',
            'label'     => Mage::helper('picasso')->__('Code'),
            'title'     => Mage::helper('picasso')->__('Code'),
            'required'  => true
        ));
		
        
        
        $fieldset->addField('script_fu', 'textarea', array(
            'name'      => 'script_fu',
            'label'     => Mage::helper('picasso')->__('Script'),
            'title'     => Mage::helper('picasso')->__('Script'),
            'required'  => true
        ));
        
        $groups = Mage::getModel('picasso/group')->getCollection();
        $fieldset->addField('group', 'select', array(
            'name'      => 'group',
            'label'     => Mage::helper('picasso')->__('Group'),
            'title'     => Mage::helper('picasso')->__('Group'),
            'required'  => true,
        	'values' => $groups->toOptionArray()
        ));
        
		$bigImage = '';
		if($model->getImage() !=''){
		
			$bigImage = '<img style="width:100px" src="'.Mage::getBaseUrl(Mage_Core_Model_Store::URL_TYPE_MEDIA).$model->getImage().'"/>';
		}
		
		$fieldset->addField('image', 'image', array(
			'label' => Mage::helper('picasso')->__('Image'),
			'name' => 'image',
			'after_element_html' => $bigImage
		));

        $fieldset->addField('default_brightness', 'text', array(
            'name'      => 'default_brightness',
            'label'     => Mage::helper('picasso')->__('Default Brightness'),
            'title'     => Mage::helper('picasso')->__('Default Brightness'),
            'required'  => true
        ));

        $fieldset->addField('default_contrast', 'text', array(
            'name'      => 'default_contrast',
            'label'     => Mage::helper('picasso')->__('Default Contrast'),
            'title'     => Mage::helper('picasso')->__('Default Contrast'),
            'required'  => true
        ));
		
		
		$fieldset->addField('sort_order', 'text', array(
            'name'      => 'sort_order',
            'label'     => Mage::helper('picasso')->__('Sort Order'),
            'title'     => Mage::helper('picasso')->__('Sort Order'),
            'required'  => false
        ));

        $fieldset->addField('active', 'select', array(
            'name'      => 'active',
            'label'     => Mage::helper('picasso')->__('Enable'),
            'title'     => Mage::helper('picasso')->__('Enable'),
            'required'  => true,
        	'values' => array(
        		array(
        			'label' => Mage::helper('picasso')->__('Yes'),
        			'value' => 1
        		),
        		array(
        			'label' => Mage::helper('picasso')->__('No'),
        			'value' => 0
        		)
        	)
        ));
        
        $form->setValues($model->getData());
        $this->setForm($form);

        return parent::_prepareForm();
    }

    /**
     * Prepare label for tab
     *
     * @return string
     */
    public function getTabLabel()
    {
        return Mage::helper('picasso')->__('Effect Information');
    }

    /**
     * Prepare title for tab
     *
     * @return string
     */
    public function getTabTitle()
    {
        return Mage::helper('picasso')->__('Effect Information');
    }

    /**
     * Returns status flag about this tab can be shown or not
     *
     * @return true
     */
    public function canShowTab()
    {
        return true;
    }

    /**
     * Returns status flag about this tab hidden or not
     *
     * @return true
     */
    public function isHidden()
    {
        return false;
    }
}
