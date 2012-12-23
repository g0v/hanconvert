#!/usr/bin/env perl
use ExtUtils::MakeMaker;
WriteMakefile(
  PREREQ_PM => {
      'Mojolicious' => '2.98',
      'Data::HanConvert' => "1.1",
      "Convert::Moji" => "0.05"
  }
);
