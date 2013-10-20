<?php

class SM_Picasso_Adminhtml_EffectController extends Mage_Adminhtml_Controller_Action {
    protected function _initAction() {
        $this->loadLayout()
                ->_setActiveMenu('picasso');

        return $this;
    }

    public function indexAction() {
        $this->_title($this->__('Effect Manager'));
        $this->_initAction();
        $this->_addContent($this->getLayout()->createBlock('picasso/adminhtml_effect'));
        $this->renderLayout();
    }

    public function newAction() {
        $this->_forward('edit');
    }

    public function editAction() {
        $effectId     = $this->getRequest()->getParam('id');
        $_model  = Mage::getModel('picasso/effect')->load($effectId);
            $this->_title($_model->getId() ? $_model->getName() : $this->__('New Effect'));

            Mage::register('effect_data', $_model);
            Mage::register('current_effect', $_model);

            $this->_initAction();
            $this->_addBreadcrumb(Mage::helper('adminhtml')->__('Effect Manager'), Mage::helper('adminhtml')->__('Effect Manager'), $this->getUrl('*/*/'));
            $this->_addBreadcrumb(Mage::helper('adminhtml')->__('Edit Effect'), Mage::helper('adminhtml')->__('Edit Effect'));

            $this->getLayout()->getBlock('head')->setCanLoadExtJs(true);
			if (Mage::getSingleton('cms/wysiwyg_config')->isEnabled()) {
				$this->getLayout()->getBlock('head')->setCanLoadTinyMce(true);
			}
            $this->_addContent($this->getLayout()->createBlock('picasso/adminhtml_effect_edit'))
                    ->_addLeft($this->getLayout()->createBlock('picasso/adminhtml_effect_edit_tabs'));

            $this->renderLayout();
      
    }

    public function saveAction() {
	
        if ($data = $this->getRequest()->getPost()) {
            $_model = Mage::getModel('picasso/effect');
            if(isset($data['position'])){
            	$data['position'] = implode(',', $data['position']);
            }
            if($this->getRequest()->getParam('id')){
            
            	$_model->setData($data)
                    ->setId($this->getRequest()->getParam('id'));
            }
            else{
            	$_model->setData($data);
            }
            
	        $imagedata = array();
	     
	        if (!empty($_FILES['image']['name'])) {
	            try {
	                $ext = substr($_FILES['image']['name'], strrpos($_FILES['image']['name'], '.') + 1);
	                $fname = 'File-' . time() . '.' . $ext;
	                $uploader = new Varien_File_Uploader('image');
	                $uploader->setAllowedExtensions(array('jpg', 'jpeg', 'gif', 'png')); // or pdf or anything
	
	                $uploader->setAllowRenameFiles(true);
	                $uploader->setFilesDispersion(false);
	
	                $path = Mage::getBaseDir('media').DS.'picasso'.DS.'effects';
	
	                $uploader->save($path, $fname);
	
	                $imagedata['image'] = 'picasso/effects/'.$fname;
					$_model->setData('image',$imagedata['image']);
	            } catch (Exception $e) {
	               Mage::logException($e);
	            }
	        }
		
			if (empty($imagedata['image'])) {
				$effectLogo = $this->getRequest()->getPost('image');
	            if (isset($effectLogo['delete']) && $effectLogo['delete'] == 1) {
					if ($effectLogo['value'] != '') {
						$_helper = Mage::helper('picasso');
						$file = Mage::getBaseDir('media').DS.$_helper->updateDirSepereator($effectLogo['value']);
						try {
							$io = new Varien_Io_File();
							$result = $io->rmdir($file, true);
						} catch (Exception $e) {
						    Mage::logException($e);
						}
					}
					$imagedata['image']='';
					$_model->setData('image',$imagedata['image']);
				}
				else{
					$_model->setData('image',$effectLogo['value']);
				}
				
			}
            
            try {
                $_model->save();
                Mage::getSingleton('adminhtml/session')->addSuccess(Mage::helper('picasso')->__('Effect was successfully saved'));
                Mage::getSingleton('adminhtml/session')->setFormData(false);

                if ($this->getRequest()->getParam('back')) {
                    $this->_redirect('*/*/edit', array('id' => $_model->getId()));
                    return;
                }
                $this->_redirect('*/*/');
                return;
            } catch (Exception $e) {
                Mage::getSingleton('adminhtml/session')->addError($e->getMessage());
                Mage::getSingleton('adminhtml/session')->setFormData($data);
                $this->_redirect('*/*/edit', array('id' => $this->getRequest()->getParam('id')));
                return;
            }
        }
        Mage::getSingleton('adminhtml/session')->addError(Mage::helper('picasso')->__('Unable to find effect to save'));
        $this->_redirect('*/*/');
    }

    public function deleteAction() {
        if( $this->getRequest()->getParam('id') > 0 ) {
            try {
                $model = Mage::getModel('picasso/effect');

                $model->setId($this->getRequest()->getParam('id'))
                        ->delete();

                Mage::getSingleton('adminhtml/session')->addSuccess(Mage::helper('adminhtml')->__('Effect was successfully deleted'));
                $this->_redirect('*/*/');
            } catch (Exception $e) {
                Mage::getSingleton('adminhtml/session')->addError($e->getMessage());
                $this->_redirect('*/*/edit', array('id' => $this->getRequest()->getParam('id')));
            }
        }
        $this->_redirect('*/*/');
    }

    public function massDeleteAction() {
        $IDList = $this->getRequest()->getParam('effect');
        if(!is_array($IDList)) {
            Mage::getSingleton('adminhtml/session')->addError(Mage::helper('adminhtml')->__('Please select effect(s)'));
        } else {
            try {
                foreach ($IDList as $itemId) {
                    $_model = Mage::getModel('picasso/effect')
                            ->setIsMassDelete(true)->load($itemId);
                    $_model->delete();
                }
                Mage::getSingleton('adminhtml/session')->addSuccess(
                        Mage::helper('adminhtml')->__(
                        'Total of %d record(s) were successfully deleted', count($IDList)
                        )
                );
            } catch (Exception $e) {
                Mage::getSingleton('adminhtml/session')->addError($e->getMessage());
            }
        }
        $this->_redirect('*/*/index');
    }

    public function massStatusAction() {
        $IDList = $this->getRequest()->getParam('effect');
        if(!is_array($IDList)) {
            Mage::getSingleton('adminhtml/session')->addError($this->__('Please select effect(s)'));
        } else {
            try {
                foreach ($IDList as $itemId) {
                    $_model = Mage::getSingleton('picasso/effect')
                            ->setIsMassStatus(true)
                            ->load($itemId)
                            ->setIsActive($this->getRequest()->getParam('status'))
                            ->save();
                }
                $this->_getSession()->addSuccess(
                        $this->__('Total of %d record(s) were successfully updated', count($IDList))
                );
            } catch (Exception $e) {
                $this->_getSession()->addError($e->getMessage());
            }
        }
        $this->_redirect('*/*/index');
    }

    public function imageAction() {
        $result = array();
        try {
            $uploader = new SM_Picasso_Media_Uploader('image');
            $uploader->setAllowedExtensions(array('jpg','jpeg','gif','png'));
            $uploader->setAllowRenameFiles(true);
            $uploader->setFilesDispersion(true);
            $result = $uploader->save(
                    Mage::getSingleton('picasso/config')->getBaseMediaPath()
            );

            $result['url'] = Mage::getSingleton('picasso/config')->getMediaUrl($result['file']);
            $result['cookie'] = array(
                    'name'     => session_name(),
                    'value'    => $this->_getSession()->getSessionId(),
                    'lifetime' => $this->_getSession()->getCookieLifetime(),
                    'path'     => $this->_getSession()->getCookiePath(),
                    'domain'   => $this->_getSession()->getCookieDomain()
            );
        } catch (Exception $e) {
            $result = array('error'=>$e->getMessage(), 'errorcode'=>$e->getCode());
        }

        $this->getResponse()->setBody(Zend_Json::encode($result));
    }

    public function categoriesJsonAction()
    {
        $effectId     = $this->getRequest()->getParam('id');
        $_model  = Mage::getModel('picasso/effect')->load($effectId);
        Mage::register('effect_data', $_model);
        Mage::register('current_effect', $_model);

        $this->getResponse()->setBody(
            $this->getLayout()->createBlock('picasso/adminhtml_effect_edit_tab_category')
                ->getCategoryChildrenJson($this->getRequest()->getParam('category'))
        );
    }

    /**
     * Add an extra title to the end or one from the end, or remove all
     *
     * Usage examples:
     * $this->_title('foo')->_title('bar');
     * => bar / foo / <default title>
     *
     * $this->_title()->_title('foo')->_title('bar');
     * => bar / foo
     *
     * $this->_title('foo')->_title(false)->_title('bar');
     * bar / <default title>
     *
     * @see self::_renderTitles()
     * @param string|false|-1|null $text
     * @return Mage_Core_Controller_Varien_Action
     */
    protected function _title($text = null, $resetIfExists = true)
    {
        if (is_string($text)) {
            $this->_titles[] = $text;
        } elseif (-1 === $text) {
            if (empty($this->_titles)) {
                $this->_removeDefaultTitle = true;
            } else {
                array_pop($this->_titles);
            }
        } elseif (empty($this->_titles) || $resetIfExists) {
            if (false === $text) {
                $this->_removeDefaultTitle = false;
                $this->_titles = array();
            } elseif (null === $text) {
                $this->_removeDefaultTitle = true;
                $this->_titles = array();
            }
        }
        return $this;
    }
}