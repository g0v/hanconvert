#!/usr/bin/env perl
use ExtUtils::MakeMaker;
WriteMakefile(
  PREREQ_PM => {
      'Encode' => '2.51',
      'Mojolicious' => '4.17',
      'Data::HanConvert' => "1.3",
      "Convert::Moji" => "0.07"
  }
);
