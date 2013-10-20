<?php
$installer = $this;

$installer->startSetup();

$installer->run("
	CREATE TABLE IF NOT EXISTS {$this->getTable('picasso/group_option')} (
	  `id` int(11) NOT NULL AUTO_INCREMENT,
	  `parent_id` int(11) NOT NULL DEFAULT '0',
	  `name` varchar(255) NOT NULL,
	  `description` text NULL,
	  `sort_order` int(11) DEFAULT '0',
	  `show_title` tinyint(1) NOT NULL DEFAULT '1',
	  `show_option_title` tinyint(1) NOT NULL DEFAULT '1',
	  PRIMARY KEY (`id`)
	) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;
");

$installer->endSetup();