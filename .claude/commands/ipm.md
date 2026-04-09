Build or update an IPM (InterSystems Package Manager) package — generate module.xml, installer classes, and deployment configuration.

Usage: /ipm <action> [arguments]

Actions:
- **(default) description** — Generate or update an IPM package from a natural language description
- **init** — Initialize a new module.xml for the current project
- **add-class** — Add a class package or single class resource
- **add-webapp** — Add a web application (REST API, static frontend, or CORS/JWT)
- **add-filecopy** — Add a file/directory copy to an install target
- **add-lookup** — Add a lookup table resource
- **add-schema** — Add an HL7, X12, or ESD schema resource
- **add-global** — Add a global resource
- **add-test** — Add a unit test declaration
- **add-dependency** — Add a dependency on another IPM package
- **add-invoke** — Add a lifecycle hook (method call at a specific phase)
- **add-cpf** — Add a CPF merge configuration
- **add-defaults** — Add a default variable, parameter, or processor default
- **add-requirements** — Set up Python dependency installation
- **validate** — Check the module.xml for common issues
- **show** — Display the current module.xml

Examples:
- /ipm init my-package
- /ipm add-class MyApp.PKG
- /ipm add-webapp /api/myapp --rest MyApp.REST.Dispatch
- /ipm add-webapp /myapp --static --path "${cspDir}myapp/"
- /ipm add-webapp /api/myapp --cors "https://example.com" --jwt
- /ipm add-filecopy config/ --target "${mgrDir}myapp/config/" --overlay
- /ipm add-lookup MyApp.FacilityLookup
- /ipm add-schema MyApp.CustomSchema.HL7
- /ipm add-test /tests/unit/ --package Test.MyApp --phase test
- /ipm add-dependency core-library >=1.0.0
- /ipm add-invoke MyApp.Installer Setup --phase Configure --when After
- /ipm add-invoke MyApp.Setup Reset --custom-phase ResetData
- /ipm add-requirements
- /ipm validate
- /ipm show
- /ipm Package this project with the frontend and all interop classes

---

## Reference

Read FIRST before any action:
- `.claude/skills/interclaw/references/infra/IPM/module-xml-reference.md` — element/attribute reference
- `research/2026-04-09_0353_ipm-deep-dive-runtime-behavior.md` — runtime behavior, hidden features
- `research/2026-04-08_2400_ipm-module-xml-comprehensive-reference.md` — schema-level detail

Also check the existing `module.xml` in the project root.

---

## Parsing

Parse "$ARGUMENTS". Extract:
- If the first word matches an action name → treat as that action with remaining args
- Otherwise → treat the entire string as a natural language description

Determine the active server and namespace from conversation context (for validation).

---

## Action: init

Create a new `module.xml` in the project root.

Ask for or infer:
- Package name (kebab-case, e.g., `interop-agent-orchestrator`)
- Version (default `0.1.0`)
- Description
- Author

Generate the skeleton:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Export generator="IRIS" version="26">
  <Document name="<package-name>.ZPM">
    <Module>
      <Name><package-name></Name>
      <Version><version></Version>
      <Description><description></Description>
      <Keywords><keywords></Keywords>
      <Author>
        <Person><name></Person>
        <Organization><org></Organization>
        <CopyrightDate><year></CopyrightDate>
      </Author>
      <Packaging>module</Packaging>
      <SourcesRoot>src</SourcesRoot>

      <!-- Resources added with /ipm add-class, add-webapp, etc. -->

      <SystemRequirements Version=">=2024.1" />

      <AfterInstallMessage>Installed! Run /connect to get started.</AfterInstallMessage>
    </Module>
  </Document>
</Export>
```

Also remind the user about auto-detected files that need no XML:
- `requirements.txt` at module root → Python deps auto-installed
- `preload/` directory → code auto-imported before Reload
- `readme.md`, `changelog.md`, `license` → auto-bundled in package

Write to `module.xml` in the project root.

---

## Action: add-class

Add a `<Resource>` for a class package or single class.

Arguments: package/class name (e.g., `MyApp.PKG`, `MyApp`, `MyApp.Installer.CLS`)

1. Read `module.xml`
2. Normalize name: add `.PKG` suffix if no extension (for packages) or `.CLS` for single classes
3. Verify source directory/file exists under `<SourcesRoot>/`
4. Add `<Resource Name="MyApp.PKG" />` (or `.CLS`) inside `<Module>`
5. Optional flags:
   - `--deploy` → add `Deploy="true"` (strip source)
   - `--preload` → add `Preload="true"` (load before Reload)
   - `--scope test|verify` → add `Scope="test"` or `Scope="verify"`
   - `--compile-after X.CLS` → add `<Attribute Name="CompileAfter">X.CLS</Attribute>`

---

## Action: add-webapp

Add a `<WebApplication>` element. Replaces the deprecated `<CSPApplication>`.

Arguments:
- URL path (e.g., `/api/myapp`, `/myapp`)
- `--rest <dispatch-class>` — REST API with dispatch class
- `--static` — static file serving
- `--path <dir>` — physical file path (for static serving)
- `--cors <origins>` — comma-separated CORS allowlist
- `--jwt` — enable JWT authentication
- `--namespace <ns>` — target namespace (default: `{$namespace}`)
- `--roles <pattern>` — MatchRoles (default: `":${globalsDbRole}:%All"`)
- `--auth <expression>` — AutheEnabled expression

### REST API pattern:
```xml
<WebApplication
  Name="/api/myapp"
  NameSpace="{$namespace}"
  DispatchClass="MyApp.REST.Dispatch"
  AutheEnabled="#{$$$AutheCache + $$$AutheUnauthenticated}"
  MatchRoles=":${globalsDbRole}:%All"
/>
```

### Static files pattern:
```xml
<WebApplication
  Name="/myapp"
  NameSpace="{$namespace}"
  ServeFiles="1"
  Recurse="1"
  Path="${cspDir}myapp/"
  AutheEnabled="#{$$$AutheUnauthenticated}"
  MatchRoles=":%All"
/>
```

### CORS/JWT pattern:
```xml
<WebApplication
  Name="/api/myapp"
  NameSpace="{$namespace}"
  DispatchClass="MyApp.REST.Dispatch"
  CorsAllowlist="https://example.com"
  CorsCredentialsAllowed="1"
  JWTAuthEnabled="1"
  JWTAccessTokenTimeout="60"
  AutheEnabled="#{$$$AutheCache + $$$AutheUnauthenticated}"
  MatchRoles=":${globalsDbRole}:%All"
/>
```

**Important**: Use `<WebApplication>`, NOT `<CSPApplication>` (deprecated).

---

## Action: add-filecopy

Add a `<FileCopy>` element for deploying files/directories to the target system.

Arguments:
- Source path (relative to module root)
- `--target <path>` — destination (supports expressions like `${mgrDir}`, `${cspDir}`, `{$root}`)
- `--overlay` — preserve existing files at destination
- `--scope test|verify` — phase-scoped copy
- `--defer` — defer to end of Activate phase

```xml
<FileCopy Name="config/" Target="${mgrDir}myapp/config/" Overlay="true" />
```

---

## Action: add-lookup

Add a lookup table resource.

Arguments: lookup table name (e.g., `MyApp.FacilityLookup`)

1. Read `module.xml`
2. Add `<Resource Name="<name>.LUT" />`
3. Remind the user that interop resources default to `i14y/` directory (or `misc/` fallback)

---

## Action: add-schema

Add an HL7, X12, or ESD schema resource.

Arguments: schema name and type
- `--hl7` — HL7 schema (`.HL7` extension)
- `--x12` — X12 schema (`.X12` extension)
- `--esd` — ESD schema (`.ESD` extension)

```xml
<Resource Name="MyApp.CustomSchema.HL7" />
```

Default source directory: `i14y/` (or `misc/`).

---

## Action: add-global

Add a global resource.

Arguments: global name
- `--preserve` — don't delete on uninstall

```xml
<Resource Name="MyApp.Config.GBL">
  <Attribute Name="Preserve">1</Attribute>
</Resource>
```

---

## Action: add-test

Add a `<UnitTest>` declaration.

Arguments:
- Test directory path (relative to module root)
- `--package <pkg>` — test package name (mutually exclusive with --class)
- `--class <cls>` — specific test class (mutually exclusive with --package)
- `--phase test|verify|test,verify` — when to run (default: `test`)

```xml
<UnitTest Name="/tests/unit/" Package="Test.MyApp" Phase="test" />
```

Remind: `test` runs in current namespace, `verify` creates an isolated namespace.

---

## Action: add-dependency

Add a module dependency.

Arguments: package name and version expression
- `--scope test|verify` — scoped dependency (only installed during that phase)

```xml
<Dependencies>
  <ModuleReference>
    <Name>other-package</Name>
    <Version>>=1.0.0</Version>
  </ModuleReference>
</Dependencies>
```

Version expressions: `1.0.0` (exact), `>=1.0.0` (minimum), `>=1.0.0 <2.0.0` (range).

If `<Dependencies>` section already exists, add inside it. If not, create it.

---

## Action: add-invoke

Add an `<Invoke>` lifecycle hook.

Arguments: class name and method name
- `--phase <phase>` — lifecycle phase (default: `Configure`)
- `--when Before|After` — timing (default: `After`)
- `--custom-phase <name>` — register as a custom phase (only runs on explicit trigger)
- `--args <arg1> <arg2>...` — positional arguments (support expressions)

```xml
<!-- Standard post-install hook -->
<Invoke Class="MyApp.Installer" Method="Setup" Phase="Configure" When="After" />

<!-- Custom phase (triggered via: zpm "my-app ResetData") -->
<Invoke Class="MyApp.Setup" Method="ClearAll" CustomPhase="ResetData" />

<!-- With arguments -->
<Invoke Class="MyApp.Installer" Method="Init" Phase="Compile" When="After">
  <Arg>{$namespace}</Arg>
  <Arg>${mgrDir}</Arg>
</Invoke>
```

---

## Action: add-cpf

Add a `<CPF>` merge element for IRIS configuration.

Arguments: CPF filename
- `--dir <directory>` — source directory (default: `cpf`)
- `--phase <phase>` — lifecycle phase (default: `Initialize`)
- `--when Before|After` — timing (default: `Before`)
- `--custom-phase <name>` — run only during a custom phase

```xml
<CPF Name="memory-settings" Directory="cpf" Phase="Initialize" When="Before" />
```

Remind: CPF file content supports `{$namespace}`, `${mgrDir}`, and `$$$macro` expressions.

---

## Action: add-defaults

Add a `<Defaults>` entry.

Sub-actions:
- `--var <name> <value>` — custom variable (`<Default Name="X" Value="Y" />`)
- `--param <name> <value>` — lifecycle parameter (`<Parameter Name="X">Y</Parameter>`)
- `--namespace-config` — namespace settings (`<NamespaceConfig EnableEnsemble="1" />`)
- `--processor-default <class>` — processor attribute defaults with conditions

```xml
<Defaults>
  <Default Name="AppRoot" Value="/opt/myapp" />
  <Parameter Name="Verbose">1</Parameter>
  <NamespaceConfig EnableEnsemble="1" />
  <ProcessorDefault Class="%IPM.ResourceProcessor.Default.Package">
    <Attribute Name="Format">UDL</Attribute>
  </ProcessorDefault>
</Defaults>
```

If `<Defaults>` section already exists, add inside it. If not, create it.

---

## Action: add-requirements

Set up Python dependency installation.

Two approaches:
1. **Auto-detected** (recommended for online installs): Place `requirements.txt` at the module root. IPM runs `pip install -r requirements.txt` automatically during Reload. **No XML needed.**
2. **Bundled wheels** (for offline/air-gapped): Download `.whl` files to `wheels/` and declare each:
   ```xml
   <PythonWheel Name="requests-2.32.4-py3-none-any.whl" ExtraPipFlags="--no-deps" />
   ```

Steps:
1. If `requirements.txt` exists at module root → tell user it's already auto-detected, no action needed
2. If `requirements.txt` exists elsewhere → suggest moving it to the module root
3. If user wants offline support → help create `<PythonWheel>` entries:
   ```bash
   pip download <package> -d wheels/ --only-binary=:all: --python-version 3 --platform any
   ```
4. Optionally add `<SystemRequirements PythonVersion=">=3.9" />` if not already present

---

## Action: validate

Check the module.xml for common issues:

1. Read `module.xml`
2. Check:
   - All `<Resource Name="*.PKG"/>` have corresponding directories under `<SourcesRoot>/`
   - All `<Resource Name="*.CLS"/>` have corresponding `.cls` files
   - `<WebApplication>` names start with `/`
   - `<WebApplication DispatchClass>` references exist in declared packages
   - No deprecated `<CSPApplication>` elements (suggest `<WebApplication>` migration)
   - No deprecated `<Invokes>` wrapper (unwrapped `<Invoke>` is preferred)
   - Version format is valid semver
   - No duplicate resources or web applications
   - `<SystemRequirements>` is present
   - `<Invoke>` class references exist in declared packages
   - `requirements.txt` at module root (if present, note it's auto-detected)
   - `preload/` directory (if present, note it's auto-imported)
   - `<FileCopy>` targets use expressions (`${mgrDir}` etc.), not hardcoded paths
3. Report issues or confirm valid

---

## Action: show

Display the current module.xml contents.

Read and display the module.xml file from the project root.

---

## Natural Language Description

When arguments are a description, analyze what the user wants and combine multiple actions:

1. Read the reference: `.claude/skills/interclaw/references/infra/IPM/module-xml-reference.md`
2. Read existing `module.xml` if present
3. Plan the changes needed
4. Execute the relevant actions (init, add-class, add-webapp, etc.)
5. Show the final module.xml

---

## After Any Action

1. Show the updated module.xml
2. List follow-up steps needed (e.g., "export lookup tables to i14y/", "create requirements.txt", "create preload/ directory")
3. Remind about auto-detected conventions when relevant:
   - `requirements.txt` at root → Python deps auto-installed
   - `preload/` directory → code auto-imported
   - `readme.md`, `changelog.md`, `license` → auto-bundled
   - `.modules/` → offline dependency bundling
4. If an installer class was generated or modified, offer to push it with `/push`
