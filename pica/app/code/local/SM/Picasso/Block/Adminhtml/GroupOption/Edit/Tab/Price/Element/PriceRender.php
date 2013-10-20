<?php

class SM_Picasso_Block_Adminhtml_GroupOption_Edit_Tab_Price_Element_PriceRender
    extends Mage_Adminhtml_Block_System_Config_Form_Field_Array_Abstract
{
	
	protected $magentoAttributes;
 
    public function __construct()
    {

        $options = $this->getOptions();

        foreach($options as $option){
            $this->addColumn('option'.$option['id'], array(
                'label' => Mage::helper('adminhtml')->__($option['label']),
                'size'  => '150px',
                'style'	=> 'select',
                'values' => $option['values']
            ));
        }


        
         $this->addColumn('price', array(
            'label' => Mage::helper('adminhtml')->__('Price'),
            'size'  => '150px',
        	'style'	=> 'text'
        ));
        
        
        $this->_addAfter = false;
        $this->_addButtonLabel = Mage::helper('adminhtml')->__('Add Rate');
 
        parent::__construct();
        $this->setTemplate('sm/picasso/groupoption/edit/element/render/prices.phtml');
    }
 
    protected function _renderCellTemplate($columnName)
    {
        if (empty($this->_columns[$columnName])) {
            throw new Exception('Wrong column name specified.');
        }
        $column     = $this->_columns[$columnName];
        $inputName  = $this->getElement()->getName() . '[#{_id}][' . $columnName . ']';
        $idName = '#{_id}'.'_'.$columnName;

        $type = $this->_columns[$columnName]['style'];
        $rendered = '';
        if($type == 'text'){
        	$rendered = '<input style="width:'.$this->_columns[$columnName]['size'].'" type="text" name="'.$inputName.'" id="'.$idName.'" value="" />';
        }
        elseif($type == 'select'){
            $rendered = '<select style="width:'.$this->_columns[$columnName]['size'].'" name="'.$inputName.'" id="'.$idName.'" >';
            $values = $this->_columns[$columnName]['values'];
            foreach($values as $value){
                $rendered .= '<option value="'.$value['id'].'">'.$value['label'].'</option>';
            }
            $rendered .='</select>';
        }
        return $rendered;
    }
    
	public function render(Varien_Data_Form_Element_Abstract $element)
    {
        $html = $this->_getElementHtml($element);
        return $html;
    }

    public function getCurrentGroupOption(){
        $groupOption = Mage::registry('group_option_data');
        return $groupOption;
    }

    public function getOptions(){
        $optionIds = $this->getCurrentGroupOption()->getOptionIds();
        $optionIds = explode(',',$optionIds);
        $result = array();
        if(!empty($optionIds)){
            //$options = Mage::getResourceModel('catalog/product_option_collection')->addFieldToFilter('option_id',array('in'=> $optionIds));

            $options = Mage::helper('picasso/groupOption')->getEffectOptions();

            foreach($options as $option){
                if(in_array($option->getId(),$optionIds)){
                    $opt = array(
                        'id'    => $option->getId(),
                        'label'  => $option->getTitle(),
                        'values' => array()
                    );

                    foreach($option->getValues() as $value){
                        $opt['values'][] = array(
                            'id' => $value->getId(),
                            'label' => $value->getTitle()
                        );
                    }

                    $result[] = $opt;
                }
            }

        }

        return $result;
    }

    public function addColumn($name, $params)
    {
        $this->_columns[$name] = array(
            'label'     => empty($params['label']) ? 'Column' : $params['label'],
            'size'      => empty($params['size'])  ? false    : $params['size'],
            'style'     => empty($params['style'])  ? null    : $params['style'],
            'class'     => empty($params['class'])  ? null    : $params['class'],
            'values'    => empty($params['values'])  ? null    : $params['values'],
            'renderer'  => false,
        );
        if ((!empty($params['renderer'])) && ($params['renderer'] instanceof Mage_Core_Block_Abstract)) {
            $this->_columns[$name]['renderer'] = $params['renderer'];
        }
    }
}
?>