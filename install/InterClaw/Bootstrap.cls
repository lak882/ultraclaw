/// InterClaw.Bootstrap — one-liner installer for InterClaw on a fresh IRIS instance.
///
/// Modeled on the IPM one-liner pattern. The token embedded in this class is a
/// read-only, single-repo, fine-grained PAT and is intentionally shareable —
/// treat it like a public "deploy key" for the private mirror.
///
/// One-liner (paste into %SYS terminal, replace the token if rotated):
///   s tk="github_pat_XXXXXX"
///   s r=##class(%Net.HttpRequest).%New(),r.Server="raw.githubusercontent.com",r.SSLConfiguration="ISC.FeatureTracker.SSL.Config" d r.SetHeader("Authorization","Bearer "_tk),r.Get("/lak882/interclaw-mirror/main/install/InterClaw/Bootstrap.cls"),$system.OBJ.LoadStream(r.HttpResponse.Data,"c") d ##class(InterClaw.Bootstrap).Run("INTERCLAW")
///
/// Performs four idempotent steps:
///   1. Create the target namespace (HS.Util.Installer.Foundation if HealthShare,
///      otherwise Config.Databases + Config.Namespaces + %EnsembleMgr.EnableNamespace)
///   2. Install IPM into that namespace via pm.community.intersystems.com
///   3. Download the InterClaw mirror tarball from codeload.github.com with the PAT
///   4. zpm load the extracted tree — IPM's <Invokes> in module.xml then runs
///      InterClaw.Installer.Setup automatically as part of load.
Class InterClaw.Bootstrap Extends %RegisteredObject
{

/// Default fine-grained PAT. Scope: Contents R/O + Metadata R/O on lak882/interclaw-mirror.
/// This is intentionally shareable; rotating it only requires updating this parameter
/// and the one-liner.
Parameter DEFAULTTOKEN = "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";

Parameter DEFAULTREPOOWNER = "lak882";

Parameter DEFAULTREPONAME = "interclaw-mirror";

Parameter DEFAULTREF = "main";

/// Main entry point. Run from %SYS (or any namespace — will switch as needed).
ClassMethod Run(
	pNamespace As %String = "INTERCLAW",
	pToken As %String = "",
	pRepoOwner As %String = {..#DEFAULTREPOOWNER},
	pRepoName As %String = {..#DEFAULTREPONAME},
	pRef As %String = {..#DEFAULTREF}) As %Status
{
	if pToken = "" set pToken = ..#DEFAULTTOKEN

	write !,"================================================================",!
	write "  InterClaw Bootstrap",!
	write "================================================================",!
	write "  Target namespace: ", pNamespace,!
	write "  Repo:             ", pRepoOwner, "/", pRepoName, "@", pRef,!
	write "  IRIS version:     ", $zversion,!
	write "================================================================",!

	if pToken = "" {
		write !,"ERROR: No token available (empty DEFAULTTOKEN parameter and no pToken argument)",!
		return $$$ERROR($$$GeneralError, "GitHub PAT required")
	}

	// Step 1: Create namespace (runs in %SYS)
	write !,"[Step 1/4] Creating namespace ", pNamespace, "...",!
	set sc = ..CreateNamespaceIfMissing(pNamespace)
	if $$$ISERR(sc) {
		write "  [!!] ", $system.Status.GetErrorText(sc),!
		return sc
	}

	// Switch into the target namespace for steps 2–4
	new $namespace
	set $namespace = pNamespace
	write "  [OK] Switched to namespace ", $namespace,!

	// Step 2: Install IPM
	write !,"[Step 2/4] Installing IPM...",!
	set sc = ..InstallIPMIfMissing()
	if $$$ISERR(sc) {
		write "  [!!] ", $system.Status.GetErrorText(sc),!
		return sc
	}

	// Step 3: Download the repo tarball
	write !,"[Step 3/4] Downloading repo tarball...",!
	set repoDir = ""
	set sc = ..DownloadRepo(pRepoOwner, pRepoName, pRef, pToken, .repoDir)
	if $$$ISERR(sc) {
		write "  [!!] ", $system.Status.GetErrorText(sc),!
		return sc
	}
	write "  [OK] Extracted to ", repoDir,!

	// Step 4: zpm load — triggers InterClaw.Installer.Setup via module.xml <Invokes>
	write !,"[Step 4/4] Loading package via IPM...",!
	set sc = ##class(%IPM.Main).Shell("load " _ repoDir _ " -v")
	if $$$ISERR(sc) {
		write "  [!!] zpm load failed: ", $system.Status.GetErrorText(sc),!
		return sc
	}

	write !,"================================================================",!
	write "  InterClaw Bootstrap Complete",!
	write "================================================================",!
	return $$$OK
}

/// Create the namespace if it does not already exist.
/// Runs in %SYS. Idempotent — returns OK if the namespace is already present.
ClassMethod CreateNamespaceIfMissing(pNamespace As %String) As %Status
{
	new $namespace
	set $namespace = "%SYS"

	if ##class(Config.Namespaces).Exists(pNamespace) {
		write "  Namespace already exists: ", pNamespace,!
		return $$$OK
	}

	// Prefer HealthShare foundation if available
	if $$$comClassDefined("HS.Util.Installer.Foundation") {
		write "  Using HS.Util.Installer.Foundation...",!
		return ##class(HS.Util.Installer.Foundation).Install(pNamespace)
	}

	// Vanilla IRIS: database + namespace + enable interop
	write "  Creating database and namespace (vanilla IRIS path)...",!
	set mgrDir = $system.Util.ManagerDirectory()
	set dbDir = mgrDir _ pNamespace
	if '##class(%File).DirectoryExists(dbDir) {
		do ##class(%File).CreateDirectoryChain(dbDir)
	}

	set sc = ##class(SYS.Database).CreateDatabase(dbDir)
	return:$$$ISERR(sc) sc

	set dbProps("Directory") = dbDir
	set sc = ##class(Config.Databases).Create(pNamespace, .dbProps)
	return:$$$ISERR(sc) sc

	set nsProps("Globals") = pNamespace
	set nsProps("Routines") = pNamespace
	set sc = ##class(Config.Namespaces).Create(pNamespace, .nsProps)
	return:$$$ISERR(sc) sc

	set sc = ##class(%EnsembleMgr).EnableNamespace(pNamespace, 1)
	return sc
}

/// Install IPM into the current namespace if %IPM.Main is not already defined.
ClassMethod InstallIPMIfMissing() As %Status
{
	if $$$comClassDefined("%IPM.Main") {
		write "  IPM already installed in ", $namespace,!
		return $$$OK
	}

	write "  Fetching IPM installer from pm.community.intersystems.com...",!
	set r = ##class(%Net.HttpRequest).%New()
	set r.Server = "pm.community.intersystems.com"
	set r.SSLConfiguration = "ISC.FeatureTracker.SSL.Config"
	set sc = r.Get("/packages/zpm/latest/installer")
	return:$$$ISERR(sc) sc
	if r.HttpResponse.StatusCode '= 200 {
		return $$$ERROR($$$GeneralError, "IPM installer HTTP " _ r.HttpResponse.StatusCode)
	}

	write "  Compiling IPM.Installer (this runs the embedded installer as a side effect)...",!
	return $system.OBJ.LoadStream(r.HttpResponse.Data, "c")
}

/// Download the repo tarball from codeload.github.com and extract it into a temp directory.
/// Returns the extracted repo root (the directory containing module.xml) in pExtractedDir.
ClassMethod DownloadRepo(
	pOwner As %String,
	pRepo As %String,
	pRef As %String,
	pToken As %String,
	Output pExtractedDir As %String) As %Status
{
	set pExtractedDir = ""
	set tmpParent = ##class(%File).NormalizeDirectory($$$FileTempDir)
	set tarFile = tmpParent _ "interclaw-repo.tar.gz"
	set extractDir = tmpParent _ "interclaw-extract/"

	// Clean any previous run
	if ##class(%File).Exists(tarFile) do ##class(%File).Delete(tarFile)
	if ##class(%File).DirectoryExists(extractDir) {
		do ##class(%File).RemoveDirectoryTree(extractDir)
	}
	do ##class(%File).CreateDirectoryChain(extractDir)

	write "  GET https://codeload.github.com/", pOwner, "/", pRepo, "/tar.gz/", pRef,!
	set r = ##class(%Net.HttpRequest).%New()
	set r.Server = "codeload.github.com"
	set r.SSLConfiguration = "ISC.FeatureTracker.SSL.Config"
	do r.SetHeader("Authorization", "Bearer " _ pToken)
	do r.SetHeader("User-Agent", "InterClaw-Bootstrap")

	set sc = r.Get("/" _ pOwner _ "/" _ pRepo _ "/tar.gz/" _ pRef)
	return:$$$ISERR(sc) sc
	if r.HttpResponse.StatusCode '= 200 {
		return $$$ERROR($$$GeneralError, "codeload HTTP " _ r.HttpResponse.StatusCode _ " — check token and repo visibility")
	}

	// Save the tarball stream to disk
	set fs = ##class(%Stream.FileBinary).%New()
	set fs.Filename = tarFile
	set sc = fs.CopyFrom(r.HttpResponse.Data)
	return:$$$ISERR(sc) sc
	set sc = fs.%Save()
	return:$$$ISERR(sc) sc

	set tarSize = ##class(%File).GetFileSize(tarFile)
	write "  Extracting tarball (", tarSize, " bytes)...",!

	// Pure-ObjectScript extraction via IPM (installed by step 2).
	// Cross-platform: no dependency on a shell `tar` binary, so this works
	// on Windows/Linux/Docker uniformly.
	if '$$$comClassDefined("%IPM.General.Archive") {
		return $$$ERROR($$$GeneralError, "%IPM.General.Archive not available — IPM install in step 2 may have failed")
	}
	set sc = ##class(%IPM.General.Archive).Extract(tarFile, extractDir)
	return:$$$ISERR(sc) sc

	// codeload tarballs always extract to a single <repo>-<ref>/ directory
	set guess = extractDir _ pRepo _ "-" _ pRef _ "/"
	if ##class(%File).DirectoryExists(guess) {
		set pExtractedDir = guess
		return $$$OK
	}

	// Fallback: find the single subdirectory inside extractDir
	set rs = ##class(%File).FileSetFunc(extractDir)
	while rs.%Next() {
		if rs.%Get("Type") = "D" {
			set name = rs.%Get("Name")
			if $extract(name, *) '= "/" set name = name _ "/"
			set pExtractedDir = name
			return $$$OK
		}
	}

	return $$$ERROR($$$GeneralError, "no subdirectory found inside extracted tarball")
}

}
