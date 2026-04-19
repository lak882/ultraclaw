# IPM module.xml Reference

Reference for building InterSystems Package Manager (IPM) packages. Based on source code analysis of IPM 0.10.x.

- [Official IPM Documentation](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=AIPM)
- [IPM GitHub Repository](https://github.com/intersystems/ipm)
- Deep dive: `research/2026-04-09_0353_ipm-deep-dive-runtime-behavior.md`
- Schema reference: `research/2026-04-08_2400_ipm-module-xml-comprehensive-reference.md`

---

## module.xml Envelope

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
  <Document name="my-package.ZPM">
    <Module>
      <!-- all content here -->
    </Module>
  </Document>
</Export>
```

The `name` attribute in `<Document>` must end in `.ZPM`.

---

## Top-Level Elements

| Element | Required | Description |
|---------|----------|-------------|
| `<Name>` | Yes | Package identifier (lowercase internally) |
| `<Version>` | Yes | Semantic version: `1.0.0`, `1.0.0-beta.1`, `1.0.0+build` |
| `<ExternalName>` | No | Public-facing name (if different from internal Name) |
| `<Description>` | No | Human-readable description |
| `<Keywords>` | No | Space-separated keywords |
| `<Author>` | No | Contains `<Person>`, `<Organization>`, `<CopyrightDate>`, `<License>`, `<Notes>` |
| `<Packaging>` | No | `"module"` (default), `"studio-project"` |
| `<SourcesRoot>` | No | Relative path prefix for source files (e.g., `"src"`) |
| `<LifecycleClass>` | No | Explicit lifecycle class override |
| `<GlobalScope>` | No | If `1`, resources mapped globally |
| `<Deployed>` | No | If `1`, module ships source-stripped |
| `<InstallerClass>` | No | Custom installer class |
| `<UpdatePackage>` | No | Package containing versioned update steps |
| `<AfterInstallMessage>` | No | Message shown after successful install |
| `<SystemRequirements>` | No | Version/feature gates (see below) |

---

## Automatic File/Directory Detection (No XML Needed)

IPM automatically detects and handles these — no `<Resource>` declaration required:

| Convention | What IPM does | Phase |
|------------|---------------|-------|
| `requirements.txt` at module root | Runs `pip install -r requirements.txt` | Reload |
| `preload/` directory at module root | Imports all code before Reload (good for Installer classes) | Initialize |
| `readme.md`, `changelog.md`, `license`, `license.md`, `license.txt` | Auto-bundled into `.tgz` archive | Package |
| `.modules/` directory | Creates temp local repo for offline dependency resolution | Load |
| `wheels/` directory | Default location for `<PythonWheel>` files | Initialize |

### Directory Conventions for Source Files

Under `<SourcesRoot>`:

| Extension | Default Directory | Filename Transform |
|-----------|-------------------|-------------------|
| `.CLS`, `.DTL`, `.BPL` | `cls/` | `Package.Class.cls` → `cls/Package/Class.cls` |
| `.INC` | `inc/` | `MyInclude.inc` → `inc/MyInclude.inc` |
| `.MAC` | `rtn/` | `MyRoutine.rtn` → `rtn/MyRoutine.rtn` |
| `.GBL` | `gbl/` | Global export XML |
| `.LUT`, `.HL7`, `.X12`, `.ESD` | `i14y/` (fallback: `misc/`) | Interoperability artifacts |
| `.LOC` | `localize/` | Localization XML |
| `.DFI` | (root) | DeepSee items (`-` as separator) |

The `%` prefix in class names is translated to `_` in filenames.

---

## Resources

```xml
<Resource Name="MyApp.PKG" />                          <!-- class package -->
<Resource Name="MyClass.CLS" />                        <!-- single class -->
<Resource Name="MyInclude.INC" />                      <!-- include file -->
<Resource Name="MyRoutine.MAC" />                      <!-- routine -->
<Resource Name="MyGlobal.GBL" />                       <!-- global -->
<Resource Name="MyLookup.LUT" />                       <!-- lookup table -->
<Resource Name="MySchema.HL7" />                       <!-- HL7 schema -->
<Resource Name="MySchema.X12" />                       <!-- X12 schema -->
<Resource Name="MyDeepSee.DFI" />                      <!-- DeepSee item -->
<Resource Name="MyMessages.LOC" />                     <!-- localized messages -->
```

### Resource Attributes

| Attribute | Default | Description |
|-----------|---------|-------------|
| `Name` | **required** | Resource name with extension suffix |
| `ProcessorClass` | auto | Explicit processor override |
| `Deploy` | `0` | Strip source during MakeDeployed phase |
| `Scope` | `""` | `"test"` or `"verify"` — only load during that phase |
| `Preload` | `0` | Load before main Reload phase |
| `Generated` | `0` | Mark as generated (not exported during Package) |
| `Directory` | auto | Override default source directory |

### Resource Sub-Attributes

```xml
<Resource Name="MyClass.CLS">
  <Attribute Name="CompileAfter">OtherClass.CLS</Attribute>
  <Attribute Name="Flags">ck</Attribute>
</Resource>
```

| Attribute Name | Description |
|----------------|-------------|
| `CompileAfter` | Comma-separated list of resources to compile before this one |
| `Flags` | Compile flags (default `"ck"`) |
| `Format` | `"UDL"` or `"XML"` |
| `Directory` | Source directory override |
| `Overlay` | For Package processor: preserve existing files |
| `Preserve` | For Global processor: don't delete on clean |

---

## Web Applications (`<WebApplication>`)

**Preferred** — replaces deprecated `<CSPApplication>`. Accepts ANY property from `Security.Applications`.

### REST API

```xml
<WebApplication
  Name="/api/myapp"
  NameSpace="{$namespace}"
  DispatchClass="MyApp.REST.Dispatch"
  AutheEnabled="#{$$$AutheCache + $$$AutheUnauthenticated}"
  MatchRoles=":${globalsDbRole}:%All"
  CookiePath="/api/myapp/"
  UseCookies="2"
/>
```

### Static File Serving (Angular, React, HTML)

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

### CORS and JWT (IRIS 2024+)

```xml
<WebApplication
  Name="/api/myapp"
  CorsAllowlist="https://example.com,https://other.com"
  CorsCredentialsAllowed="1"
  CorsHeadersList="Access-Control-Allow-Origin,Content-Type"
  JWTAuthEnabled="1"
  JWTAccessTokenTimeout="60"
  JWTRefreshTokenTimeout="900"
/>
```

### Common WebApplication Attributes

| Attribute | Description |
|-----------|-------------|
| `Name` | Web app path (e.g., `/api/myapp`). **Required.** |
| `NameSpace` | Target namespace. Supports `{$namespace}`. |
| `DispatchClass` | REST dispatch class |
| `AutheEnabled` | Auth flags. Supports `#{}` macro expressions |
| `MatchRoles` | Role matching. Supports `${globalsDbRole}` |
| `ServeFiles` | `0`, `1`, or `2` |
| `Path` | Physical file path for CSP/static files |
| `Recurse` | Include subdirectories |
| `Enabled` | Enable/disable the app |
| `CookiePath` | Cookie path |
| `UseCookies` | Cookie usage mode |
| `CorsAllowlist` | CORS allowed origins |
| `JWTAuthEnabled` | Enable JWT auth |

Any valid `Security.Applications` property works as an attribute.

---

## File Copy (`<FileCopy>`)

Copies files or directories to a target location during the Activate phase.

```xml
<FileCopy Name="config/defaults.json" Target="${mgrDir}myapp/config.json" />
<FileCopy Name="static/" InstallDirectory="${cspDir}myapp/static/" Overlay="true" />
<FileCopy Name="scripts/" Target="{$root}scripts/" />
```

| Attribute | Aliases | Default | Description |
|-----------|---------|---------|-------------|
| `Name` | `SourceDirectory` | **required** | Source file/directory relative to module root |
| `InstallDirectory` | `Target`, `Dest` | `""` | Destination path. Supports expressions |
| `Overlay` | | `0` | Preserve existing files (only copy new/updated) |
| `CSPApplication` | | `""` | CSP app to map the directory into |
| `Defer` | | `0` | Defer copy to end of Activate phase |

Supports `Scope="test"` or `Scope="verify"` for phase-scoped copies.

---

## Python Wheels (`<PythonWheel>`)

Installs Python wheel packages during the Initialize phase.

```xml
<PythonWheel Name="requests-2.32.4-py3-none-any.whl" ExtraPipFlags="--no-deps" />
<PythonWheel Name="mylib-1.0.0-py3-none-any.whl" Directory="python_wheels" />
```

| Attribute | Default | Description |
|-----------|---------|-------------|
| `Name` | **required** | Wheel filename |
| `Directory` | `"wheels"` | Directory containing .whl files |
| `ExtraPipFlags` | `""` | Extra pip flags (e.g., `"--no-deps"`) |

For online installs, prefer `requirements.txt` at the module root (auto-detected, no XML needed).

---

## CPF Merge (`<CPF>`)

Merges IRIS Configuration Parameter File settings via `iris merge`.

```xml
<CPF Name="memory-settings" />
<CPF Name="config" Directory="cpf" Phase="Compile" When="After" />
<CPF Name="custom" CustomPhase="MyPhase" />
```

| Attribute | Default | Description |
|-----------|---------|-------------|
| `Name` | **required** | CPF filename (without extension) |
| `Directory` | `"cpf"` | Directory containing CPF files |
| `Phase` | `"Initialize"` | Lifecycle phase |
| `When` | `"Before"` | `"Before"` or `"After"` the phase |
| `CustomPhase` | `""` | Run only during this custom phase |

CPF file content supports system expressions (`{$namespace}`, `${mgrDir}`) and `$$$macro` evaluation.

---

## Unit Tests (`<UnitTest>`)

```xml
<UnitTest Name="/tests/unit/" Package="Test.MyApp" Phase="test" />
<UnitTest Name="/tests/integration/" Package="Verify.MyApp" Phase="verify" />
<UnitTest Name="/tests/" Class="Test.Specific" Phase="test" />
```

| Attribute | Default | Description |
|-----------|---------|-------------|
| `Name` | **required** | Directory containing test classes |
| `Package` | `""` | Test package (mutually exclusive with Class) |
| `Class` | `""` | Specific test class |
| `Phase` | `"test"` | `"test"`, `"verify"`, or `"test,verify"` |
| `ManagerClass` | `"%IPM.Test.Manager"` | Custom test manager |

- **test** phase runs in the current namespace
- **verify** phase creates a **separate clean namespace**, installs the module fresh, runs tests, then tears down

CLI filtering:
```
zpm "mymodule test -suite Test.SubPkg -case Test.Case -method TestMethod"
zpm "mymodule test -junit-export /tmp/results.xml"
```

---

## Dependencies

```xml
<Dependencies>
  <ModuleReference>
    <Name>other-package</Name>
    <Version>>=1.0.0</Version>
  </ModuleReference>
  <ModuleReference Scope="test">
    <Name>test-helper</Name>
    <Version>2.0.0</Version>
  </ModuleReference>
</Dependencies>
```

Version expressions: `1.0.0` (exact), `>=1.0.0` (minimum), `>=1.0.0 <2.0.0` (range).

Scoped dependencies (`Scope="test"` or `"verify"`) are only installed during that phase.

---

## Mappings

```xml
<Mappings>
  <Mapping Name="MyApp.Shared.PKG" Source="USER" />
  <Mapping Name="MyGlobal.GBL" Source="{$root}DATA" />
</Mappings>
```

Mapping types by suffix: `.PKG` (package), `.MAC` (routine), `.GBL` (global).

Both wrapped (`<Mappings><Mapping.../></Mappings>`) and unwrapped (`<Mapping .../>`) syntax work.

---

## Invoke Hooks

Run ObjectScript methods at specific lifecycle phases.

```xml
<!-- Default: Phase="Configure", When="After" -->
<Invoke Class="MyApp.Installer" Method="Setup" />

<!-- Explicit phase and timing -->
<Invoke Class="MyApp.Installer" Method="PreCheck" Phase="Reload" When="Before" />

<!-- With arguments (support expressions) -->
<Invoke Class="MyApp.Installer" Method="Configure">
  <Arg>{$namespace}</Arg>
  <Arg>${mgrDir}</Arg>
  <Arg>literal</Arg>
</Invoke>

<!-- Custom phase (only runs when explicitly triggered) -->
<Invoke Class="MyApp.Setup" Method="Reset" CustomPhase="ResetData" When="After" />
```

| Attribute | Default | Description |
|-----------|---------|-------------|
| `Class` | **required** | ObjectScript class |
| `Method` | **required** | Method name |
| `Phase` | `"Configure"` | Standard lifecycle phase |
| `When` | `"After"` | `"Before"` or `"After"` the phase |
| `CustomPhase` | `""` | Custom phase name (not part of normal install) |
| `CheckStatus` | auto | `1`=always check, `0`=never, omit=auto-detect from return type |

Both wrapped (`<Invokes><Invoke.../></Invokes>`) and unwrapped (`<Invoke .../>`) syntax work.

---

## Defaults

Four sub-element types under `<Defaults>`:

### Custom Variables

```xml
<Default Name="AppRoot" Value="/opt/myapp" />
```
Referenced as `{AppRoot}` in expressions. Can be overridden at install time: `zpm "install pkg -AppRoot /custom/path"`.

### Lifecycle Parameters

```xml
<Parameter Name="Verbose">1</Parameter>
<Parameter Name="NoTransaction">1</Parameter>
<Parameter Name="NoLock">1</Parameter>
<Parameter Name="NoJournal">1</Parameter>
```

Lifecycle-scoped: `<Parameter Name="X" LifecycleClass="%IPM.Lifecycle.Module">val</Parameter>`

### Namespace Config

```xml
<NamespaceConfig EnableEnsemble="1" EnableHealthShare="0" />
```

### Processor Defaults (with conditions)

```xml
<ProcessorDefault Class="%IPM.ResourceProcessor.Default.Package">
  <Attribute Name="Format">UDL</Attribute>
  <Condition Attribute="Name" Operator="contains" Value=".Test." />
</ProcessorDefault>
```

Condition operators: `eq`, `neq`, `gt`, `lt`, `gte`, `lte`, `contains`.

---

## System Requirements

```xml
<SystemRequirements
  Version=">=2024.1"
  Interoperability="enabled"
  Health="true"
  IPMVersion=">=0.9.0"
  PythonVersion=">=3.9"
/>
```

| Attribute | Description |
|-----------|-------------|
| `Version` | IRIS version (semantic version expression) |
| `Interoperability` | `"enabled"` or `"disabled"` |
| `Health` | `true` requires IRIS for Health. `false` disallows it |
| `IPMVersion` | Minimum IPM version |
| `PythonVersion` | Minimum Python version |

`Health="true"` implicitly requires `Interoperability="enabled"`.

---

## Expression System

### Module Expressions (`{...}`)

| Expression | Value |
|------------|-------|
| `{$root}` | Module root directory |
| `{$namespace}` | Current namespace |
| `{$ipmDir}` | IPM cache directory |
| `{name}` | Module name |
| `{version}` | Module version |
| `{CustomName}` | Custom `<Default>` value |

### System Expressions (`${...}`)

| Expression | Value |
|------------|-------|
| `${namespace}` / `${ns}` | Current namespace |
| `${namespaceLower}` | Namespace lowercase |
| `${mgrDir}` | IRIS manager directory |
| `${cspDir}` | CSP root directory |
| `${installDir}` | IRIS install directory |
| `${dataDir}` | IRIS data directory |
| `${binDir}` | Binary directory |
| `${libDir}` | Library directory |
| `${webroot}` | URL with host:port |
| `${globalsDbRole}` | Globals database role (replaces deprecated `${dbrole}`) |
| `${namespaceRoutineDB}` | Routines database name |
| `${namespaceGlobalsDB}` | Globals database name |

### ObjectScript/Macro Evaluation

| Pattern | Description |
|---------|-------------|
| `#{expression}` | Evaluated as ObjectScript at runtime |
| `$$$macroName` | Macro evaluation (inside `#{}`) |

Example: `AutheEnabled="#{$$$AutheCache + $$$AutheUnauthenticated}"`

---

## Lifecycle Phases

| Phase | Description |
|-------|-------------|
| Clean | Remove all installed resources and mappings |
| Initialize | PythonWheel install, preload/ import, CPF merge |
| Reload | Load sources, install requirements.txt, map packages/globals |
| Validate | Validate resources and dependencies |
| Compile | Multi-pass compilation with CompileAfter ordering |
| Activate | FileCopy, WebApplication creation, Studio project |
| Configure | Post-install hooks (default Invoke phase) |
| Test | Run unit tests (Scope="test") |
| Package | Export to .tgz archive (includes static files) |
| Verify | Create clean namespace, install, run verify tests, tear down |
| Publish | Package + publish to registry |
| MakeDeployed | Strip source from deployed resources |
| ExportData | Export global data |
| Unconfigure | Reverse configuration (before Clean) |
| ApplyUpdateSteps | Run versioned migration scripts |

### Phase Chains

| Requested | Executed |
|-----------|----------|
| `reload` | Initialize → Reload |
| `compile` | Initialize → Reload → Validate → Compile |
| `activate` | Initialize → Reload → Validate → Compile → Activate |
| `test` | Initialize → Reload → Validate → Compile → Activate → Test |
| `package` | Initialize → Reload → Validate → Compile → Activate → MakeDeployed → Package |
| `verify` | Initialize → Reload → Validate → Compile → Activate → MakeDeployed → Test → Verify |
| `publish` | Full chain through Publish |

---

## CLI Commands Quick Reference

| Command | Description |
|---------|-------------|
| `zpm "load /path"` | Load from local directory (dev mode by default) |
| `zpm "install name"` | Install from registry |
| `zpm "install name -dev"` | Install in developer mode |
| `zpm "install name -env /path/config.json"` | Install with environment config |
| `zpm "install name -create-lockfile"` | Generate module-lock.json |
| `zpm "install name -lockfile /path/lock.json"` | Install from lock file |
| `zpm "update name"` | Update (runs UpdateSteps) |
| `zpm "uninstall name"` | Uninstall |
| `zpm "name test"` | Run test phase |
| `zpm "name test -case Test.Cls -method TestX"` | Run specific test |
| `zpm "name verify"` | Run verify phase (isolated namespace) |
| `zpm "name publish"` | Publish to registry |
| `zpm "name customphase"` | Run custom phase |
| `zpm "list-installed"` | List installed modules |
| `zpm "orphans"` | List unowned resources |
| `zpm "search keyword"` | Search registries |
| `zpm "namespace *"` | List namespaces with modules |
| `zpm "module-version name -bump-minor"` | Bump version |
| `zpm "history"` | Show install history |
| `zpm "generate"` | Interactive module.xml generator |

### Key Modifiers

| Modifier | Description |
|----------|-------------|
| `-dev` / `-d` | Developer mode |
| `-verbose` / `-v` | Verbose output |
| `-force` | Skip downgrade checks, bypass UpdatePackage |
| `-only` | Run phase for this module only (skip deps) |
| `-bypass-py-deps` | Skip Python requirements install |
| `-extra-pip-flags` | Additional pip flags |
| `-export-python-deps` | Include wheels in package |
| `-export-deps` | Include module dependencies in package |
| `-map` | Map to all namespaces |
| `-globally` | Apply across all namespaces |
| `-purge` | Remove all associated data |

---

## Environment Config Files

```
zpm "install mymodule -env /path/to/config.json"
```

```json
{
  "mymodule": {
    "DatabasePath": "${MY_DB_DIR}/data",
    "ApiKey": "${API_KEY}",
    "Debug": "true"
  }
}
```

`${VARNAME}` resolves to OS environment variables. Values are accessible via:
```objectscript
set config = ##class(%IPM.General.EnvironmentConfig).%Get()
set value = config.GetArg("mymodule", "DatabasePath")
```

---

## Lock Files

```
zpm "install mymodule -create-lockfile"
```

Generates `module-lock.json` with pinned versions and repositories for all dependencies. Install from lock file:

```
zpm "install mymodule -lockfile /path/to/module-lock.json"
```

---

## Offline Dependencies (`.modules/`)

Bundle dependency modules in a `.modules/` subdirectory:

```
mymodule/
  module.xml
  .modules/
    dep-a/
      module.xml
      src/...
    dep-b/
      module.xml
      src/...
```

IPM creates a temporary local repository from `.modules/` — no network access needed.

---

## Update Steps Framework

For versioned migration scripts during upgrades:

```xml
<UpdatePackage>MyApp.UpdateSteps</UpdatePackage>
```

Each update step class has methods that run at specific version transitions. IPM tracks which steps have been executed. On `update`, IPM runs unexecuted steps in order.

**Important**: When `UpdatePackage` is set, you **must** use `zpm "update"` (not `install` or `load`) to upgrade.

---

## Complete Example

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Export generator="IRIS" version="26">
<Document name="my-app.ZPM">
  <Module>
    <Name>my-app</Name>
    <Version>2.0.0</Version>
    <ExternalName>My Application</ExternalName>
    <Description>Full-featured interoperability app with frontend</Description>
    <Keywords>interoperability hl7</Keywords>
    <Author>
      <Person>Developer</Person>
      <Organization>My Org</Organization>
      <CopyrightDate>2026</CopyrightDate>
      <License>MIT</License>
    </Author>
    <Packaging>module</Packaging>
    <SourcesRoot>src</SourcesRoot>

    <!-- ObjectScript classes -->
    <Resource Name="MyApp.PKG" />
    <Resource Name="MyApp.Installer.CLS" Preload="true" />
    <Resource Name="MyApp.Test.PKG" Scope="test" />

    <!-- Interoperability artifacts -->
    <Resource Name="MyApp.FacilityLookup.LUT" />
    <Resource Name="MyApp.CustomSchema.HL7" />

    <!-- Globals (preserved on uninstall) -->
    <Resource Name="MyApp.Config.GBL">
      <Attribute Name="Preserve">1</Attribute>
    </Resource>

    <!-- REST API web app -->
    <WebApplication
      Name="/api/myapp"
      NameSpace="{$namespace}"
      DispatchClass="MyApp.REST.Dispatch"
      AutheEnabled="#{$$$AutheCache + $$$AutheUnauthenticated}"
      MatchRoles=":${globalsDbRole}:%All"
    />

    <!-- Static frontend web app -->
    <WebApplication
      Name="/myapp"
      NameSpace="{$namespace}"
      ServeFiles="1"
      Recurse="1"
      Path="${cspDir}myapp/"
      AutheEnabled="#{$$$AutheUnauthenticated}"
      MatchRoles=":%All"
    />

    <!-- File copies -->
    <FileCopy Name="config/defaults.json" Target="${mgrDir}myapp/config.json" />
    <FileCopy Name="static/" Target="${cspDir}myapp/static/" Overlay="true" />

    <!-- Unit tests -->
    <UnitTest Name="/tests/unit/" Package="Test.MyApp" Phase="test" />
    <UnitTest Name="/tests/integration/" Package="Verify.MyApp" Phase="verify" />

    <!-- Dependencies -->
    <Dependencies>
      <ModuleReference>
        <Name>core-library</Name>
        <Version>>=1.0.0</Version>
      </ModuleReference>
      <ModuleReference Scope="test">
        <Name>test-utilities</Name>
        <Version>2.0.0</Version>
      </ModuleReference>
    </Dependencies>

    <!-- Post-install hooks -->
    <Invoke Class="MyApp.Installer" Method="Setup" Phase="Configure" When="After" />
    <Invoke Class="MyApp.Installer" Method="PreCheck" Phase="Reload" When="Before">
      <Arg>{$namespace}</Arg>
    </Invoke>

    <!-- Custom phase (triggered manually: zpm "my-app ResetData") -->
    <Invoke Class="MyApp.Installer" Method="ClearAll" CustomPhase="ResetData" />

    <!-- Defaults -->
    <Defaults>
      <Default Name="AppRoot" Value="/opt/myapp" />
      <Parameter Name="Verbose">1</Parameter>
      <NamespaceConfig EnableEnsemble="1" />
    </Defaults>

    <!-- System requirements -->
    <SystemRequirements Version=">=2024.1" Interoperability="enabled" PythonVersion=">=3.9" />

    <AfterInstallMessage>Installed! Visit /myapp to get started.</AfterInstallMessage>
  </Module>
</Document></Export>
```

Note: `requirements.txt` at the module root is auto-detected — no XML needed for Python deps.
