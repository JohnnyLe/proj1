<?php
class SM_Picasso_Model_Mysql4_Effect_Collection extends Mage_Core_Model_Mysql4_Collection_Abstract  
{
	protected $_effects = null;
    public function _construct() {
        parent::_construct();
        $this->_init('picasso/effect');
         
    }
   
    public function addGroupNameToSelect(){
    	$this->getSelect()
    			->join( array('ge'=>$this->getTable('picasso/group')), 'main_table.group = ge.id', array('group_name'=>'ge.name'));
    	return $this;
    }
    
    public function addActiveToFilter(){
    	$this->getSelect()->where('active = ?',1);
    	return $this;
    }
	
	public function toArrayEffect(){
		if(is_null($this->_effects)){
			$this->_effects = array();
			foreach ($this as $item){
				$this->_effects[$item->getCode()] = $item->getData();
			}
		}
		return $this->_effects;
	}

    public function toArrayEffect2(){
        if(is_null($this->_effects)){
            $this->_effects = array();
            foreach ($this as $item){
                $this->_effects[$item->getId()] = $item->getData();
            }
        }
        return $this->_effects;
    }
	
	public function toOptionIdArray(){
		$result = array();
		foreach($this as $item){
			$result[] = array(
						'value' => $item->getId(),
						'label'	=> $item->getName()
					);
		}
		return $result;
	}
}