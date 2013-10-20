<?php
$installer = $this;

$installer->startSetup();

$installer->run("
    ALTER TABLE  {$this->getTable('picasso/group_option')} ADD  `option_require` tinyint(1) NOT NULL DEFAULT '0';
");

$installer->endSetup();