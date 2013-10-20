<?php
class SM_Picasso_Block_Override_Catalog_Product_View_Options_Type_Select
    extends Mage_Catalog_Block_Product_View_Options_Type_Select
{
    /**
     * Return html for control element
     *
     * @return string
     */
    public function getValuesHtml()
    {
        $_option = $this->getOption();
        $_groupId = $_option->getGroup();
        $_group = Mage::getModel('picasso/groupOption')->load($_groupId);
        $optionIsRequire = $_option->getIsRequire()||($_group->getOptionRequire() && in_array($_option->getId(),explode(',',$_group->getOptionIds())) );
        $_option->setIsRequire($optionIsRequire);
        $configValue = $this->getProduct()->getPreconfiguredValues()->getData('options/' . $_option->getId());
        $store = $this->getProduct()->getStore();

        if ($_option->getType() == Mage_Catalog_Model_Product_Option::OPTION_TYPE_DROP_DOWN
            || $_option->getType() == Mage_Catalog_Model_Product_Option::OPTION_TYPE_MULTIPLE) {
            $require = ($_option->getIsRequire()) ? ' required-entry' : '';
            $extraParams = '';
            $select = $this->getLayout()->createBlock('core/html_select')
                ->setData(array(
                    'id' => 'select_'.$_option->getId(),
                    'class' => $require.' product-custom-option'
                ));
            if ($_option->getType() == Mage_Catalog_Model_Product_Option::OPTION_TYPE_DROP_DOWN) {
                $select->setName('options['.$_option->getid().']')
                    ->addOption('', $this->__('-- Please Select --'));
            } else {
                $select->setName('options['.$_option->getid().'][]');
                $select->setClass('multiselect'.$require.' product-custom-option');
            }
            foreach ($_option->getValues() as $_value) {
                $priceStr = $this->_formatPrice(array(
                    'is_percent'    => ($_value->getPriceType() == 'percent'),
                    'pricing_value' => $_value->getPrice(($_value->getPriceType() == 'percent'))
                ), false);
                $select->addOption(
                    $_value->getOptionTypeId(),
                    $_value->getTitle() . ' ' . $priceStr . '',
                    array('price' => $this->helper('core')->currencyByStore($_value->getPrice(true), $store, false),'org_text'=>$this->htmlEscape($_value->getTitle()))
                );
            }
            if ($_option->getType() == Mage_Catalog_Model_Product_Option::OPTION_TYPE_MULTIPLE) {
                $extraParams = ' multiple="multiple"';
            }
            if (!$this->getSkipJsReloadPrice()) {
                $extraParams .= ' onchange="opConfig.reloadPrice(this)"';
            }

            $extraParams .=' option_id="'.$_option->getId().'" group_id="'.$_option->getGroup().'"';

            $select->setExtraParams($extraParams);

            if ($configValue) {
                $select->setValue($configValue);
            }

            return $select->getHtml();
        }

        if ($_option->getType() == Mage_Catalog_Model_Product_Option::OPTION_TYPE_RADIO
            || $_option->getType() == Mage_Catalog_Model_Product_Option::OPTION_TYPE_CHECKBOX
            ) {
            $selectHtml = '<ul id="options-'.$_option->getId().'-list" class="options-list" group_id="'.$_group->getId().'" parent_group_id="'.$_group->getParentId().'">';
            $require = ($_option->getIsRequire() || $_group->getType() == 'radio') ? ' validate-one-required-by-name' : '';
            $arraySign = '';
            $disabled = $_option->getIsDisable() ? 'disabled="disabled"' : '';
            switch ($_option->getType()) {
                case Mage_Catalog_Model_Product_Option::OPTION_TYPE_RADIO:
                    $type = 'radio';
                    $class = 'radio';
                    if (!$_option->getIsRequire()) {
                        /*
                        $selectHtml .= '<li style="display:none"><input '.$disabled.' type="radio" id="options_' . $_option->getId() . '" class="'
                            . $class . ' product-custom-option" name="options[' . $_option->getId() . ']"'
                            . ($this->getSkipJsReloadPrice() ? '' : ' onclick="opConfig.reloadPrice(this)"')
                            . ' value="" checked="checked" option_id="'.$_option->getId().'" group_id="'.$_option->getGroup().'" /><span class="label"><label for="options_'
                            . $_option->getId() . '">' . $this->__('None') . '</label></span></li>';
                        */
                    }
                    break;
                case Mage_Catalog_Model_Product_Option::OPTION_TYPE_CHECKBOX:
                    $type = 'checkbox';
                    $class = 'checkbox';
                    $arraySign = '[]';
                    break;
            }
            $count = 1;
            foreach ($_option->getValues() as $_value) {
                $count++;

                $priceStr = $this->_formatPrice(array(
                    'is_percent'    => ($_value->getPriceType() == 'percent'),
                    'pricing_value' => $_value->getPrice($_value->getPriceType() == 'percent')
                ));

                $htmlValue = $_value->getOptionTypeId();
                if ($arraySign) {
                    $checked = (is_array($configValue) && in_array($htmlValue, $configValue)) ? 'checked' : '';
                } else {
                    $checked = $configValue == $htmlValue ? 'checked' : '';
                }

                if($this->getOptionImage($_value) !== ''){
                	$imgOptionHtml = '<img alt="'.$_value->getTitle().'" rel="#options_' . $_option->getId(). '_' . $count . '" class="custom-paint-option-img" src="'.$this->getOptionImage($_value).'" href="'.$this->getOptionImage($_value).'"/>';
                }
                else{
                	$imgOptionHtml = '<img alt="'.$_value->getTitle().'" rel="#options_' . $_option->getId(). '_' . $count . '" class="custom-paint-option-img" src="'.$this->getSkinUrl('sm/images/option-placeholder.jpg').'" href="'.$this->getSkinUrl('sm/images/option-placeholder.jpg').'"/>';
                }
                $selectHtml .= '<li rel="options_' . $_option->getId(). '_' . $count . '" value="'.$_value->getId().'">'
                	.'<label for="options_' . $_option->getId() . '_' . $count . '">'
                    . $imgOptionHtml
                    . '<span class="label">'
                    . $_value->getTitle() . '<br/>' . $priceStr . '</span></label>'
                    		
                	. '<input org_text="'.$_value->getTitle().'" style="opacity:0;filter:alpha(opacity=0);" '.$disabled.' type="' . $type . '" class="' . $class . ' ' . $require
                    . ' product-custom-option"'
                    . ($this->getSkipJsReloadPrice() ? '' : ' onclick="opConfig.reloadPrice(this)"')
                    . ' name="options[' . $_option->getId() . ']' . $arraySign . '" id="options_' . $_option->getId()
                    . '_' . $count . '" value="' . $htmlValue . '"  ' . $checked . ' price="'
                    . $this->helper('core')->currencyByStore($_value->getPrice(true), $store, false) . '" option_id="'.$_option->getId().'" group_id="'.$_option->getGroup().'" parent_group_id="'.$_group->getParentId().'" />'
                ;
                
                
                if ($_option->getIsRequire()) {
                    $selectHtml .= '<script type="text/javascript">' . '$(\'options_' . $_option->getId() . '_'
                    . $count . '\').advaiceContainer = \'options-' . $_option->getId() . '-container\';'
                    . '$(\'options_' . $_option->getId() . '_' . $count
                    . '\').callbackFunction = \'validateOptionsCallback\';' . '</script>';
                }
                $selectHtml .= '</li>';
            }
            $selectHtml .= '</ul><div style="clear:both"></div>';

            return $selectHtml;
        }
    }

    
    protected function getOptionImage($v){
    	$imgSrc= '';
    	$optValue = $v->getImage();
    	$optValue = json_decode($optValue,true);
    	if(!empty($optValue[0]['url'])){
    		$imgSrc = $optValue[0]['url'];
            $imgSrc = preg_replace('/http:\/\/(.*?)\//', '', $imgSrc);
            $imgSrc = Mage::getBaseUrl().$imgSrc;
    	}
    	return $imgSrc;
    }
    
}
