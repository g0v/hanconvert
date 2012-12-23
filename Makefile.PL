#!/usr/bin/env perl
use ExtUtils::MakeMaker;
WriteMakefile(
  PREREQ_PM => {
      'Mojolicious' => '3.69',
      'Data::HanConvert' => "1.12",
      "Convert::Moji" => "0.05"
  }
);
