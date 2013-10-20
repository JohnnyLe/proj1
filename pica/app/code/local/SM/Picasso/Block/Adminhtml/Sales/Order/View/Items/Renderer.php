<?php
class SM_Picasso_Block_Adminhtml_Sales_Order_View_Items_Renderer extends Mage_Adminhtml_Block_Sales_Order_View_Items_Renderer_Default
{
    public function getImageUrl($item = null)
    {
        $result = false;

        if ($options = $this->getItem()->getProductOptions()) {
            if (isset($options['info_buyRequest']['file-image-selected'])) {
                $result = $options['info_buyRequest']['file-image-selected'];
            }
        }
        return $result;
    }
}
