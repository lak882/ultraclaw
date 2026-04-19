# Custom Utility Functions Reference

Custom utility functions extend the built-in DTL/rule function set with organization-specific logic.

## How It Works

A class that extends `Ens.Rule.FunctionSet` automatically registers all its ClassMethods as utility functions available in DTL expressions, routing rule conditions, and BPL code. No explicit registration needed — IRIS discovers them at compile time.

## Pattern

```objectscript
Class MyApp.UtilityFunctions.MyHelpers Extends Ens.Rule.FunctionSet
{

ClassMethod EmbedPDF(pdfFilePath As %String) As %String
{
    Set pdfFile = ##class(%Stream.FileBinary).%New()
    Do pdfFile.LinkToFile(pdfFilePath)
    Set pdfRawContents = ##class(%Stream.GlobalCharacter).%New()
    Do ##class(HS.Util.StreamUtils).Base64Encode(pdfFile, pdfRawContents)
    Return pdfRawContents
}

ClassMethod PadLeft(value As %String, length As %Integer, padChar As %String = "0") As %String
{
    Return $Justify(value, length, , padChar)
}

}
```

## Rules

1. Class **MUST** extend `Ens.Rule.FunctionSet`
2. Functions **MUST** be `ClassMethod` (not instance methods)
3. Parameters and return types must be simple (`%String`, `%Integer`, `%Boolean`) — no object references
4. Method name becomes the function name in DTL/rule expressions
5. Multiple functions can live in one class, or use multiple FunctionSet classes

## Using in DTL

```xml
<!-- Call custom function with .. prefix -->
<assign value='..EmbedPDF(source.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:5})' 
        property='target.{PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX:5}' action='set'/>
```

## Using in Routing Rules

```xml
<when condition="..MyCustomCheck(HL7.{MSH:SendingApplication.NamespaceID})=&quot;true&quot;">
  <send transform="..." target="..."/>
</when>
```

## When to Create Custom Utility Functions

Create a custom `Ens.Rule.FunctionSet` class whenever the POC requires logic that **cannot be expressed with built-in DTL utility functions** (e.g., `..ReplaceStr`, `..Lookup`, `..Pad`). Common examples:

- **Embedding a PDF as Base64** — reading a file from disk, encoding it, and returning the string. The built-in functions can't do file I/O.
- **Custom string formatting** — complex transformations beyond what `..ReplaceStr`, `..Piece`, `..Pad` can handle.
- **External lookups** — calling an API, reading from a database, etc.

**Never use ObjectScript `<code>` blocks in DTL** for logic that should be a reusable function. Instead, create a FunctionSet class, push and compile it, then call `..FunctionName()` in the DTL.

### Package convention
```
<Pkg>.UtilityFunctions.<Name>    — e.g., StClair.POC.UtilityFunctions.EmbedPDF
```

The class is pushed and compiled like any other .cls file. Once compiled, the functions are immediately available in DTL expressions throughout the namespace.

## After Compiling

Functions appear in the Management Portal DTL editor's function picker under "Custom Functions."
