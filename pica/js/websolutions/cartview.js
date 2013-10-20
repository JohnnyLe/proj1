/**
 * Magento
 *
 * NOTICE OF LICENSE
 *
 * This source file is subject to the Academic Free License (AFL 3.0)
 * that is bundled with this package in the file LICENSE_AFL.txt.
 * It is also available through the world-wide-web at this URL:
 * http://opensource.org/licenses/afl-3.0.php
 * If you did not receive a copy of the license and are unable to
 * obtain it through the world-wide-web, please send an email
 * to license@magentocommerce.com so we can send you a copy immediately.
 *
 * DISCLAIMER
 *
 * Do not edit or add to this file if you wish to upgrade Magento to newer
 * versions in the future. If you wish to customize Magento for your
 * needs please refer to http://www.magentocommerce.com for more information.
 *
 * @category    Websolutions
 * @package     Websolutions_Cartview
 * @copyright   Copyright (c) 2011 Christian Ducrot (http://www.ducrot.de)
 * @license     http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
 */

/**
 * Trigger hover events for cartview
 */
document.observe('dom:loaded', function() {
    if($('cartview')){
        $('cartview').observe('mouseover', function(e) {
            $('cartview-panel').show();
        });
        $('cartview').observe('mouseout', function(e) {
            $('cartview-panel').hide();
        });
    }

});