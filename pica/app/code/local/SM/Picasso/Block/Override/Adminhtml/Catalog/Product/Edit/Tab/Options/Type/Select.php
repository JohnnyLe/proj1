<?php

class SM_Picasso_Block_Override_Adminhtml_Catalog_Product_Edit_Tab_Options_Type_Select extends
    Mage_Adminhtml_Block_Catalog_Product_Edit_Tab_Options_Type_Select
{
    /**
     * Class constructor
     */
    public function __construct()
    {
        parent::__construct();
        $this->setTemplate('sm/picasso/catalog/product/edit/options/type/select.phtml');
        $this->setCanEditPrice(true);
        $this->setCanReadPrice(true);
    }

    protected function _prepareLayout()
    {
        $this->setChild('add_select_row_button',
            $this->getLayout()->createBlock('adminhtml/widget_button')
                ->setData(array(
                    'label' => Mage::helper('catalog')->__('Add New Row'),
                    'class' => 'add add-select-row',
                    'id'    => 'add_select_row_button_{{option_id}}'
                ))
        );

        $this->setChild('delete_select_row_button',
            $this->getLayout()->createBlock('adminhtml/widget_button')
                ->setData(array(
                    'label' => Mage::helper('catalog')->__('Delete Row'),
                    'class' => 'delete delete-select-row icon-btn',
                    'id'    => 'delete_select_row_button'
                ))
        );

        return parent::_prepareLayout();
    }

    public function getAddButtonHtml()
    {
        return $this->getChildHtml('add_select_row_button');
    }

    public function getDeleteButtonHtml()
    {
        return $this->getChildHtml('delete_select_row_button');
    }

    public function getPriceTypeSelectHtml()
    {
        $this->getChild('option_price_type')
            ->setData('id', 'product_option_{{id}}_select_{{select_id}}_price_type')
            ->setName('product[options][{{id}}][values][{{select_id}}][price_type]');

        return parent::getPriceTypeSelectHtml();
    }
    
    public function getUploaderJsonConfig(){
    	$formKey = Mage::getSingleton('core/session')->getFormKey();
    	$config = array(
    		'url' => $this->getUrl('adminhtml/catalog_product_gallery/upload'),
    		'params' => array('form_key'=> $formKey),
    		'file_field' => 'image',
    		'filters'	=> array(
    						'images' => array(
    								 	'label' => 'Images (.gif, .jpg, .png)',
    								    'files' => array("*.gif","*.jpg","*.jpeg","*.png")
    								 )	
    					),
    		'replace_browse_with_remove'=>true,
    		'width'=>'32',
    		"hide_upload_button"=>true
    	);
    	
    	return json_encode($config);
    }
    
    public function getOptionImages(){
    	$images = array();
    	$product = Mage::registry('product');
    	if($product){
    		if($product->getOptions()){
    			foreach ($product->getOptions() as $o) {
			        $optionType = $o->getType();    
			        if (in_array($optionType,array('drop_down','radio','checkbox','multiple'))) {
			        	$images[$o->getOptionId()] = array();
			            $values = $o->getValues();
			            foreach ($values as $k => $v) {
			                $optValue = $v->getImage();
			                $optValue = json_decode($optValue,true); 
			                if(!empty($optValue[0]['url'])){
			                	$images[$o->getOptionId()][$v->getOptionTypeId()]= array(array('url'=>$optValue[0]['url']));
			                }
			            	
			            }
			        }
	
			    }
    		}
    	}
    	return json_encode($images);
    }
}
