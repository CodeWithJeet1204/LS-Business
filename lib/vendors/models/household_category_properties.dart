import 'package:flutter/services.dart';

final Map<String, List<List<dynamic>>> businessCategoryProperties = {
  // Name, Hint Text, No of Answers, DropDown Items, TextInputType, Max Lines, Mandatory Info
  'Storage & Organisation': [
    [
      'Width',
      'in centimeters',
      1,
      [''],
      TextInputType.text,
      1,
      true,
    ],
    [
      'Height',
      'in centimeters',
      1,
      [''],
      TextInputType.text,
      1,
      true,
    ],
    [
      'Material',
      'eg. Plastic',
      1,
      [''],
      TextInputType.text,
      1,
      true,
    ],
    [
      'Colors',
      'eg. Blue, Green',
      3,
      [''],
      TextInputType.text,
      true,
    ],
    [
      '',
      'eg. Blue, Green',
      3,
      [''],
      TextInputType.text,
      true,
    ],
    [
      '',
      'eg. Blue, Green',
      3,
      [''],
      TextInputType.text,
      true,
    ],
  ],
};
