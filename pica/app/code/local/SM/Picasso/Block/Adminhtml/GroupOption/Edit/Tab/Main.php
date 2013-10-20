<?php

class SM_Picasso_Block_Adminhtml_GroupOption_Edit_Tab_Main
    extends Mage_Adminhtml_Block_Widget_Form
    implements Mage_Adminhtml_Block_Widget_Tab_Interface
{
    protected function _prepareForm()
    {
        /* @var $model Mage_Cms_Model_Group */
        $model = Mage::registry('group_option_data');



        $form = new Varien_Data_Form();

        $form->setHtmlIdPrefix('group_');

        $fieldset = $form->addFieldset('base_fieldset', array('legend'=>Mage::helper('picasso')->__('Group Information')));

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
        


        $fieldset->addField('type', 'select', array(
            'name'      => 'type',
            'label'     => Mage::helper('picasso')->__('Type'),
            'title'     => Mage::helper('picasso')->__('Type'),
            'required'  => true,
            'values' => array(
                array(
                    'label' => Mage::helper('picasso')->__('Checkbox'),
                    'value' => 'checkbox'
                ),
                array(
                    'label' => Mage::helper('picasso')->__('Radio'),
                    'value' => 'radio'
                )
            )
        ));

        $fieldset->addField('show_title', 'select', array(
        		'name'      => 'show_title',
        		'label'     => Mage::helper('picasso')->__('Show Title'),
        		'title'     => Mage::helper('picasso')->__('Show Title'),
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
        
        $fieldset->addField('show_option_title', 'select', array(
        		'name'      => 'show_option_title',
        		'label'     => Mage::helper('picasso')->__('Show Option Title'),
        		'title'     => Mage::helper('picasso')->__('Show Option Title'),
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

        $fieldset->addField('option_require', 'select', array(
            'name'      => 'option_require',
            'label'     => Mage::helper('picasso')->__('Option Require'),
            'title'     => Mage::helper('picasso')->__('Option Require'),
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

        try{
        	$config = Mage::getSingleton('cms/wysiwyg_config')->getConfig(
        			array(
        					'add_widgets' => false,
        					'add_variables' => false,
        			)
        	);
        }
        catch (Exception $ex){
        	$config = null;
        }
        
        $fieldset->addField('description', 'editor', array(
        		'name'      => 'description',
        		'label'     => Mage::helper('picasso')->__('Description'),
        		'title'     => Mage::helper('picasso')->__('Description'),
        		'style'     => 'width:700px; height:100px;',
        		'config'    => $config
        ));


		$fieldset->addField('sort_order', 'text', array(
            'name'      => 'sort_order',
            'label'     => Mage::helper('picasso')->__('Sort Order'),
            'title'     => Mage::helper('picasso')->__('Sort Order'),
            'required'  => false
        ));

        $fieldset->addField('available_step', 'text', array(
            'name'      => 'available_step',
            'label'     => Mage::helper('picasso')->__('Available Step'),
            'title'     => Mage::helper('picasso')->__('Available Step')
        ));

        $form->setValues($model->getData());


        $fieldset->addField('Parent', 'select', array(
            'name'      => 'parent_id',
            'label'     => Mage::helper('picasso')->__('Parent'),
            'title'     => Mage::helper('picasso')->__('Parent'),
            'value'     => $model->getParentId(),
            'values'	=> Mage::helper('picasso/groupOption')->getSelectcat(),
            'required'  => true
        ));

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
        return Mage::helper('picasso')->__('Group Information');
    }

    /**
     * Prepare title for tab
     *
     * @return string
     */
    public function getTabTitle()
    {
        return Mage::helper('picasso')->__('Group Information');
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
