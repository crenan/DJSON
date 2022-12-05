# DJSON

DJSON is a JSON implementation for Delphi 7 and Lazarus (FPC).

The objects are memory-managed and auto-constructed in a fluent coding style.

To use in your project just compile the corresponding version.

## Using with Delphi 7
- Open the package DJsonD7.dpk and compile.
- The .dcu and .bpl files will be in `.\lib\D7\` path.

## Using with Lazarus
- Open the package DJsonFPC.lpk and compile.
- The .o and .ppu files will be in `.\lib\FPC\<target-cpu>-<target-os>\` path.

## Unit tests
There are projects for unit testing the library for both Delphi 7 (using DUnit) and Lazarus (using FPUnit).
To execute the tests you need first compile the library, then the test projects.

## Examples

The starting point for creating JSON objects is through `JSONBuilder`, like:
```pascal
JString := JSONBuilder.BuildString('JSON Test'); // "JSON Test"
JNumber := JSONBuiler.BuildNumber(666); // 666
JBoolean := JSONBuilder.BuildBoolean(true); // true
JNull := JSONBuilder.BuildNull; // null
JArray := JSONBuilder.BuildArray
  .Add('String test')
  .Add(100)
  .Add(false)
  .Build;
// ["String test", 100, false]
JObject := JSONBuilder.BuildObject
  .Add('Library Name', 'DJSON')
  .Add('Version', 1000)
  .Add('Suport FPC', true)
  .Add('Suport D7', true)
  .Build;
// {"Library Name":"DJSON","Version":1000,"Suport FPC":true,"Suport D7": true}
```

You can check which type the object is using the `.ValueType` property. The valid values are:
```pascal
(jsObject, jsArray, jsString, jsNumber, jsBoolean, jsNull)
```

And you can mix calls to JSONBuilder to build complex JSON objects like:
```pascal
JCplxObject := JSONBuilder.BuildObject
  .Add('Library', 'DJSON')
  .Add('Version', JSONBuilder.BuildArray
    .Add(1)
    .Add(0)
    .Add(0)
    .Add(0)
    .Build)
  .Build;
// {"Library":"DJSON", "Version":[1,0,0,0]}
```

You can use the `TJSONReader` class to parse strings into JSON objects, like:
```pascal
JObject := TJSONReader.Read('{"Library":"DJSON", "Version":[1,0,0,0]}'); // parse a string directly
JObject := TJSONReader.ReadFromStream(aStream); // Read JSON from a stream
JObject := TJSONReader.ReadFromFile(aFile); // Read JSON from a file
```

You can write a JSON using the `TJSONWriter` class, like:
```pascal
TJSONWriter.WriteToStream(aJSON, aStream);
TJSONWriter.WriteToFile(aJSON, aFile);
```

To transform a JSON object to string, simple call the `ToString()` method, like:
```pascal
MyJSONText := aJSON.ToString;
```

The simple JSON values (string, number, boolean and null) are accessed using the `.Value` property, like:
```pascal
JNumber := JSONBuilder.BuildNumber(666);
MyNumber := JNumber.Value; // MyNumber = 666
```

The JSON array values are accessed using the default property `Element[]`, like:
```pascal
JArray := JSONBuilder.BuildArray
  .Add('String test')
  .Add(100)
  .Add(false)
  .Build;
// JArray[0].Value = 'String test'
// JArray.Element[1].Value = 100
// JArray[2].Value = false
```

The JSON object values are accessed using the default property `Member[]`, like:
```pascal
JObject := JSONBuilder.BuildObject
  .Add('Library Name', 'DJSON')
  .Add('Version', 1000)
  .Add('Suport FPC', true)
  .Add('Suport D7', true)
  .Build;
// JObject['Library Name'].Value = 'DJSON'
// JObject['Version'].Value = 1000
```

You can access a specific member by its index in a JSON object using the `MemberAt[]` property, like:
```pascal
JObject := JSONBuilder.BuildObject
  .Add('Library Name', 'DJSON')
  .Add('Version', 1000)
  .Add('Suport FPC', true)
  .Add('Suport D7', false)
  .Build;
// JObject.MemberAt[2].Value = true
// JObject.MemberAt[3].Value = false
```

You can also access the member name or value by its index using `NameAt[]` and `ValueAt[]`, respectively, like:
```pascal
JObject := JSONBuilder.BuildObject
  .Add('Library Name', 'DJSON')
  .Add('Version', 1000)
  .Add('Suport FPC', true)
  .Add('Suport D7', false)
  .Build;
// JObject.NameAt[2] = 'Suport FPC'
// JObject.ValueAt[2] = true
```

Both `IJSONArray` and `IJSONObject` have the `.Count` property which returns the total elements inside the object.

For complex JSON objects, you can access a nested complex element using `.AsArray` or `.AsObject` properties, like:
```pascal
JObject := TJSONReader.Read('{"Library":"DJSON", "Version":[1,0,0,0]}');
// JObject['Version'].AsArray[0].Value = 1
// JObject['Version'].AsArray[1].Value = 0
...
```

If you like you can use a [validation tool](https://jsononline.net/json-validator) to check if the values are considered a valid JSON.

Take a look at the unit test [DJsonTests.pas](tests/DJsonTests.pas) file to see more examples.
