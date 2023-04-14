# RCrystal-Regex
A regex-parser

## Examples
```
  re = MRegex.new("a|b")
  puts re.match("aa") // false
  puts re.match("ab") // false
  puts re.match("a") // true
  puts re.match("b") // true
```