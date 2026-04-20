/// InterClaw.Bootstrap — one-shot bootstrapper for fresh IRIS instances.
///
/// Flow: ensure the target HealthShare namespace exists, download the
/// `lak882/interclaw-mirror` repo tarball from GitHub with a PAT, extract
/// it to a temp directory, and `zpm "load"` that directory so IPM fires the
/// post-install `InterClaw.Installer.Setup` hook.
///
/// Paste into an IRIS terminal on a bare instance:
///   set r=##class(%Net.HttpRequest).%New(),r.Server="raw.githubusercontent.com",r.SSLConfiguration="ISC.FeatureTracker.SSL.Config"
///   set t="github_pat_..."
///   do r.SetHeader("Authorization","Bearer "_t),r.Get("/lak882/interclaw-mirror/main/install/InterClaw/Bootstrap.cls"),$SYSTEM.OBJ.LoadStream(r.HttpResponse.Data,"ck")
///   do ##class(InterClaw.Bootstrap).Run("INTERCLAW",t)
Class InterClaw.Bootstrap Extends %RegisteredObject
{

Parameter REPOOWNER = "lak882";

Parameter REPONAME = "interclaw-mirror";

Parameter DEFAULTREF = "main";

/// Entry point. Creates the namespace if missing, downloads the repo
/// tarball, extracts it, and loads it via IPM. Safe to re-run to upgrade.
ClassMethod Run(namespace As %String = "INTERCLAW", token As %String = "", ref As %String = "") As %Status
{
    if ref = "" set ref = ..#DEFAULTREF
    if token = "" {
        write !,"ERROR: GitHub PAT required. Pass as the second argument.",!
        return $$$ERROR($$$GeneralError, "Missing GitHub token")
    }

    write !,"================================================================",!
    write "  InterClaw Bootstrap",!
    write "================================================================",!
    write "  Namespace: ", namespace,!
    write "  Repo:      ", ..#REPOOWNER, "/", ..#REPONAME, "@", ref,!
    write "================================================================",!,!

    // 1. Ensure the namespace exists (HealthShare Foundation layout).
    set sc = ..EnsureNamespace(namespace)
    if $$$ISERR(sc) return sc

    // 2. Fetch + extract the repo tarball to a temp directory.
    set extractRoot = ..FetchRepo(token, ref)
    if extractRoot = "" return $$$ERROR($$$GeneralError, "Tarball fetch/extract failed")
    write "  Extracted to: ", extractRoot,!,!

    // 3. zpm load the extracted tree in the target namespace.
    set sc = ..LoadPackage(namespace, extractRoot)
    if $$$ISERR(sc) return sc

    write !,"================================================================",!
    write "  Bootstrap complete.",!
    write "================================================================",!
    return $$$OK
}

/// Create the namespace via HS.Util.Installer.Foundation when missing.
/// Skip when it already exists so upgrades don't wipe data.
ClassMethod EnsureNamespace(namespace As %String) As %Status
{
    if ##class(%SYS.Namespace).Exists(namespace) {
        write "[1/3] Namespace ", namespace, " already exists — skipping create.",!
        return $$$OK
    }
    write "[1/3] Creating HealthShare Foundation namespace ", namespace, "...",!
    new $namespace
    set $namespace = "HSLIB"
    set sc = ##class(HS.Util.Installer.Foundation).Install(namespace)
    if $$$ISERR(sc) {
        write "  ERROR: Foundation install failed: ", $system.Status.GetErrorText(sc),!
    }
    return sc
}

/// Download the repo tarball from the GitHub API and extract to a temp
/// directory. Returns the absolute path of the extracted repo root, or ""
/// on failure (error message is printed).
ClassMethod FetchRepo(token As %String, ref As %String) As %String [ Language = python ]
{
    import urllib.request, tempfile, os, tarfile

    owner = "lak882"
    repo = "interclaw-mirror"
    url = f"https://api.github.com/repos/{owner}/{repo}/tarball/{str(ref)}"
    print(f"[2/3] Downloading {owner}/{repo}@{ref} from GitHub...")
    try:
        req = urllib.request.Request(url, headers={
            "Authorization": f"Bearer {str(token)}",
            "Accept": "application/vnd.github+json",
            "User-Agent": "interclaw-bootstrap",
        })
        with urllib.request.urlopen(req, timeout=180) as r:
            data = r.read()
    except Exception as e:
        detail = ""
        try:
            detail = e.read().decode("utf-8")[:300]
        except Exception:
            pass
        print(f"  ERROR: tarball fetch failed: {type(e).__name__}: {e} {detail}")
        return ""
    print(f"  Downloaded {len(data)} bytes.")

    stage = tempfile.mkdtemp(prefix="interclaw-bootstrap-")
    tar_path = os.path.join(stage, "repo.tar.gz")
    with open(tar_path, "wb") as f:
        f.write(data)
    try:
        with tarfile.open(tar_path, "r:gz") as tf:
            tf.extractall(stage)
    except Exception as e:
        print(f"  ERROR: tarball extract failed: {type(e).__name__}: {e}")
        return ""

    # GitHub tarballs put everything under a single `<owner>-<repo>-<sha>/`
    entries = [e for e in os.listdir(stage) if e != "repo.tar.gz"]
    if len(entries) != 1:
        print(f"  ERROR: unexpected tarball layout: {entries}")
        return ""
    return os.path.join(stage, entries[0])
}

/// Run `zpm "load <dir>"` in the target namespace so IPM's post-install
/// hooks fire. Falls back to a direct Installer.Setup call if IPM is
/// unavailable on this instance.
ClassMethod LoadPackage(namespace As %String, dir As %String) As %Status
{
    write "[3/3] Loading package from ", dir, " into ", namespace, "...",!
    new $namespace
    set $namespace = namespace

    set loaded = 0
    // Modern IPM entry point.
    if ##class(%Dictionary.CompiledClass).%ExistsId("%ZPM.PackageManager") {
        try {
            do ##class(%ZPM.PackageManager).Shell("load " _ dir _ " -verbose")
            set loaded = 1
        } catch ex {
            write "  %ZPM.PackageManager.Shell failed: ", ex.DisplayString(),!
        }
    }
    // Legacy IPM entry point (older IRIS).
    if 'loaded, ##class(%Dictionary.CompiledClass).%ExistsId("%IPM.Main") {
        try {
            do ##class(%IPM.Main).Shell("load " _ dir _ " -verbose")
            set loaded = 1
        } catch ex {
            write "  %IPM.Main.Shell failed: ", ex.DisplayString(),!
        }
    }
    // No IPM — fall back to plain OBJ.LoadDir + direct Installer.Setup.
    if 'loaded {
        write "  IPM not available on this instance — falling back to OBJ.LoadDir.",!
        set sc = $system.OBJ.LoadDir(dir _ "/install", "ck", , 1)
        if $$$ISERR(sc) return sc
        if ##class(%Dictionary.CompiledClass).%ExistsId("InterClaw.Installer") {
            set sc = ##class(InterClaw.Installer).Setup()
            if $$$ISERR(sc) return sc
        }
    }
    return $$$OK
}

}
