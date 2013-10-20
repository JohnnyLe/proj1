<?php

class SM_Picasso_Block_Adminhtml_Group_Edit_Tab_Main
    extends Mage_Adminhtml_Block_Widget_Form
    implements Mage_Adminhtml_Block_Widget_Tab_Interface
{
    protected function _prepareForm()
    {
        /* @var $model Mage_Cms_Model_Group */
        $model = Mage::registry('group_data');



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


		$fieldset->addField('sort_order', 'text', array(
            'name'      => 'sort_order',
            'label'     => Mage::helper('picasso')->__('Sort Order'),
            'title'     => Mage::helper('picasso')->__('Sort Order'),
            'required'  => false
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
