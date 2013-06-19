#!/usr/bin/env perl
use ExtUtils::MakeMaker;
WriteMakefile(
  PREREQ_PM => {
      'Encode' => '2.51',
      'Mojolicious' => '4.16',
      'Data::HanConvert' => "1.2",
      "Convert::Moji" => "0.05"
  }
);
