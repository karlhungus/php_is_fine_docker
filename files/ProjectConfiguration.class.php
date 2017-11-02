<?php

//require_once __DIR__.'/../lib/vendor/autoload.php';
require_once '/home/sfproject/lib/vendor/autoload.php';

class ProjectConfiguration extends sfProjectConfiguration
{
  public function setup()
  {
      $this->enablePlugins('sfDoctrinePlugin');
  }
}
