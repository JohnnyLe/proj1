<?php

class SM_Picasso_Block_Override_Catalog_Product_View_Options extends Mage_Catalog_Block_Product_View_Options
{
	
	protected $_groupOptions = null;
	protected $_groupSelected = null;
	public function getGroupOption(){

		if(is_null($this->_groupOptions)){
			$options = $this->getOptions();
			$this->_groupOptions = array();
			foreach($options as $option){
				$groupName = $option->getData('group');
				if(!is_array($this->_groupOptions[$groupName])){
					$this->_groupOptions[$groupName] = array();
				}
				
				$this->_groupOptions[$groupName][$option->getId()] = $option;
			}
		}
		return $this->_groupOptions;
	}
	
	public function getGroupOptions(){
		if(is_null($this->_groupOptions)){
			$root = array('id'=>0);
			$this->drawSelect($root);
		}
		$this->_groupOptions = $root;
		return $this->_groupOptions;
	}
	
	public function drawGroupOption($parentItem=array(), $level=0)
    {
        $groupsSelected = $this->getGroupOptionSelected();
        $html = '';
        $pid = empty($parentItem['id'])? 0:$parentItem['id'];
        $items = $this->getChildrens($pid);
		$i = 0;
		$totreg = count($items);
        foreach ($items as $k => $item){
            $step = intval($item['sort_order']);
            $groupShow = '';
            if($pid == 0){
                $groupShow = 'style="display:none"';

                if($step == 0){
                    $groupShow = '';
                }
            }

            $html.= '<li '.$groupShow.' id="group_option_container_'.$item['id'].'">';

	        $html.= '<div class="ui-widget-content">';

            switch($parentItem['type']){
                case 'radio':
                    $checked = false;
                    if(in_array($item['id'],$groupsSelected)){
                        $checked = false; // hieptq qickfix
                    }
                    break;
                case 'checkbox':

                default :
                    $checked = true;
            }


	        if(!empty($item['show_title'])){
                $description = $item['description'];
                $classHoverTip = '';
                if(!empty($description)){
                    $classHoverTip = 'group-option-tooltip';
                }

                switch($parentItem['type']){
                    case 'radio':
                        $strChecked =  $checked ? 'checked="checked"':'';
                        $html.= '<h3 class="ui-widget-header '.$classHoverTip.'" description="'.$description.'"><input id="group_option_'.$item['parent_id'].'_'.$item['id'].'" name="group_option['.$item['parent_id'].']" style="padding-right:10px" type="radio" parent_group_id="'.$item['parent_id'].'" group_id="'.$item['id'].'" onclick="groupOptionRadioChange(this)" value="'.$item['id'].'" '. $strChecked .'/><label for="group_option_'.$item['parent_id'].'_'.$item['id'].'">'.$this->htmlEscape($item['name']).'</label></h3>'."\n";
                        break;
                    case 'checkbox':

                    default :

                        $html.= '<h3 class="ui-widget-header '.$classHoverTip.'" description="'.$description.'">'.$this->htmlEscape($item['name']).'</h3>'."\n";
                }

	        }
            if($pid == 0){
                $availableStep = $item['available_step'];
	            $html.= '<div class="group-step" id="group-step-'.$step.'" step="'.$step.'" available_step="'.$availableStep.'">';
            }

	        if ($level > 0) {
	        	$html.= '<ul></ul>'."\n";
	        }
	        $hasChildrens = $this->hasChildrens($item['id']);
	        if ($hasChildrens) {
	            $htmlChildren = '';
                $htmlChildren.= $this->drawGroupOption($item, $level+1);
	            if (!empty($htmlChildren)) {
	                $html.= '<ul class="sub-group-option sub-parent-group-option-'.$item['parent_id'].'" id="sub-group-option-'.$item['id'].'">'."\n"
	                        .$htmlChildren
	                        .'</ul>';
	            }
	        }
	        
	        $htmlChildren = '';
	        $options = $this->getOptionsByGroup($item['id']);
	        if(count($options) > 0){
	        	
	        	$disableOptionTitle = empty($item['show_option_title']) ? 'hidden-title':'';
	        	
	        	$htmlChildren.='<div class="group-option '.$disableOptionTitle.'">';
	        	foreach($options as $_option){
                    $isDisable = !$checked;
                    $_option->setIsDisable($isDisable);

                    // hieptq hardcode fix enable input with group 1
                    if($pid == 2){
                        $_option->setIsDisable(false);
                    }
                    $htmlChildren.= '<div id="group-option-subcontainer'.$_option->getId().'">';
	        		$htmlChildren.= $this->getOptionHtml($_option);
	        		$htmlChildren.='<div class="custom-option-description">'.str_replace("\n", "<br/>",$_option->getDefaultDescription()).'</div>';
                                
                              // johnny add custmom image                
	        	    $htmlChildren.= '</div>';
                }
	        	$htmlChildren.='</div>';

	        }
            $strDisplay =  $checked ? '':'display:block';
	        if (!empty($htmlChildren)) {

                $html.= '<ul style="'. $strDisplay .'" class="sub-group-option sub-parent-group-option-'.$item['parent_id'].'" id="sub-group-option-'.$item['id'].'">'."\n"
	        			.$htmlChildren
                        .'<div style="margin-top:20px;margin-left:20px;'. $strDisplay.'">'.$item['description'].'</div>'
	        			.'</ul>';

	        }


            if($pid == 0){
                $html.='</div>';
            }

            $html.='</div>';

	        $html.= '</li>'."\n";
	        $i++;
        }
        return $html;
    }
	
	public function getChildrens($pid=0){
		$out = array();
		$collection = Mage::getModel('picasso/groupOption')->getCollection()
		->addFieldToFilter('parent_id', array('in'=>$pid) )
		->setOrder('sort_order', 'asc');
		foreach ($collection as $item){
			$out[] = $item->getData();
		}
		return $out;
	}
	
	public function hasChildrens($pid=0){
		$collection = Mage::getModel('picasso/groupOption')->getCollection()
		->addFieldToFilter('parent_id', array('in'=>$pid) )
		->setOrder('sort_order', 'asc')
		->load();
		if($collection->count() > 0){
			return true;
		}
		return false;
	}
	
	
	public function getOptionsByGroup($groupId){
		$groupId = intval($groupId);
		$options = array();
		foreach($this->getOptions() as $option){
			
			$group = intval($option->getData('group'));
			//echo $groupId.'===='.$group."\n";
			if($group == $groupId){
				$options[] =  $option;
			}
		}
		return $options;
	}

    protected function getGroupOptionSelected(){
        if(is_null($this->_groupSelected)){
            $this->_groupSelected = $this->getDefaultGroupOptionSelect();
            $product = $this->getProduct();
            $data = $product->getPreconfiguredValues();
            if(!empty($data['group_option'])){
                $this->_groupSelected = $data['group_option'];
            }
        }

        return $this->_groupSelected;
    }

    protected function getDefaultGroupOptionSelect(){
        $result = array();
        $collection = Mage::getModel('picasso/groupOption')->getCollection()
            ->addFieldToFilter('type', array('in'=>array('radio')));
        foreach ($collection as $item){
            $collection2 = Mage::getModel('picasso/groupOption')->getCollection()
                ->addFieldToFilter('parent_id', $item->getId());
            foreach($collection2 as $item2){
                $result[] = $item2->getId();
                break;
            }
        }
        return $result;
    }

    public function getDefaultMainGroupSelect(){
        $result = '';
        $collection = Mage::getModel('picasso/groupOption')->getCollection()
            ->addFieldToFilter('price_type', 'main_price' );
        foreach ($collection as $item){
            $result = $item->getId();
            break;
        }
        return $result;
    }

    protected function getGroupOptionsConfig(){
        $result = array();
        $collection = Mage::getResourceModel('picasso/groupOption_collection');
        $optionConfig = array();
        foreach($collection as $group){
            $optionConfig[$group->getId()] = $group->getPriceConfigFormated();
            $data = $group->getData();
            unset($data['price_config']);
            $groupConfig[$group->getId()] = $data;
        }

        $result = array(
            'optionConfig' => $optionConfig,
            'groupConfig'  => $groupConfig
        );

        return $result;
    }

    protected function getGroupOptionsJsonConfig(){
        $config = $this->getGroupOptionsConfig();
        return json_encode($config);
    }

    public function removeOptionRenderer($type)
    {
        unset($this->_optionRenders[$type]);
        return $this;
    }

    public function getOptionSelected()
    {
        $cart = Mage::getSingleton('checkout/cart');
        $id = $this->getRequest()->getParam('id');
        $quoteItem = $cart->getQuote()->getItemById($id);
        if(!$quoteItem){
            return '{}';
        }
        $buyRequest = $quoteItem->getBuyRequest();
        $optionElementSelected = $buyRequest->getData('option_selected');
        return $optionElementSelected;
    }

    public function getOptionSelectedOrder()
    {
        $cart = Mage::getSingleton('checkout/cart');
        $id = $this->getRequest()->getParam('id');
        $quoteItem = $cart->getQuote()->getItemById($id);
        if(!$quoteItem){
            return '[]';
        }
        $buyRequest = $quoteItem->getBuyRequest();
        $optionElementSelected = $buyRequest->getData('option_selected_order');
        return $optionElementSelected;
    }

    /**
     * Get json representation of
     *
     * @return string
     */
    public function getCustomOptionsDependJsonConfig()
    {
        $config = array();

        foreach ($this->getOptions() as $option) {
            /* @var $option Mage_Catalog_Model_Product_Option */
            if($option->getCustomOptionDepend()){
                $dependIds= explode(',',$option->getCustomOptionDepend());
                $dependList = array();
                $collection = Mage::getResourceModel('catalog/product_option_collection')->addFieldToFilter('option_id',array('in'=>$dependIds));
                foreach($collection as $opt){
                    $dependList[$opt->getId()] = $opt->getData();
                }
                $config[$option->getId()] = array(
                                                'type' => $option->getType(),
                                                'depends' => $dependList
                                            );
            }
        }

        return Mage::helper('core')->jsonEncode($config);
    }
}
