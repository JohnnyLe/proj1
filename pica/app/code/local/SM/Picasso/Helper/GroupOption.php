<?php

class SM_Picasso_Helper_GroupOption extends Mage_Core_Helper_Abstract
{

    private $_effectOptions;
	private $outtree = array();

	public function getSelectcat(){
		$this->outtree['value'][] = '0';
		$this->outtree['label'][] = 'Root';
        $this->drawSelect(0);
        
        foreach ($this->outtree['value'] as $k => $v){
        	$out[] = array('value'=>$v, 'label'=>$this->outtree['label'][$k]);
        }
		return $out;
	}

	public function drawSelect($pid=0, $sep=1){
		$spacer = '';
		for ($i = 0; $i <= $sep; $i++){
			$spacer.= '----';
		}
		$items = $this->getChildrens($pid);
		if(count($items) > 0 ){
			foreach ($items as $item){
				$this->outtree['value'][] = $item['id'];
				$this->outtree['label'][] = $spacer . $item['name'];
				$child = $this->getChildrens($item['id']);
				if(!empty($child)){
					$this->drawSelect($item['id'], $sep + 1);
				}
			}
		}
		return;
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
        	->addFieldToFilter('pid', array('in'=>$pid) )
			->setOrder('sort_order', 'asc')
			->load();
		if($collection->count() > 0){
			return true;
		}
		return false;
	}

    public function getEffectOptions(){
        if(is_null($this->_effectOptions)){
            $product = Mage::getModel('catalog/product')->load(167);
            $this->_effectOptions = $product->getOptions();
        }
        return $this->_effectOptions;
    }

    public function getEffectOptionsArray(){
            $result = array();
            $options = $this->getEffectOptions();
            foreach($options as $option){
                $result[] = array(
                    'label' => $option->getTitle(),
                    'value' => $option->getId()
                );
            }
        return $result;
    }
}