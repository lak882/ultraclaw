Class InterClaw.Installer.WebSocketSetup
{

/// Default SSL/TLS configuration name
Parameter TLSCONFIGNAME = "WebSocketTLS";

/// Default certificate file path
Parameter CERTFILE = "/usr/local/InterSystems/IRISHealth/mgr/ssl/vmdev1.crt";

/// Default private key file path
Parameter KEYFILE = "/usr/local/InterSystems/IRISHealth/mgr/ssl/vmdev1.key";

/// Web application path
Parameter WEBAPP = "/api/ws";

/// Target namespace
Parameter NAMESPACE = "CLAUDE";

/// Gateway server profile name
Parameter SERVERNAME = "IRISHEALTH";

/// SuperServer port
Parameter SUPERSERVERPORT = 1972;

/// CSP.ini file path
Parameter INIPATH = "/opt/webgateway/conf/CSP.ini";

/// Run all setup steps in order
ClassMethod SetupAll() As %Status
{
    set sc = $$$OK

    write "=== WebSocket TLS Setup ===",!
    write !,"[1/6] Ensuring TLS configuration...",!
    set sc1 = ..EnsureTLSConfig()
    if $$$ISERR(sc1) { write "  FAILED: ", $system.Status.GetErrorText(sc1),! } else { write "  OK",! }
    set sc = $$$ADDSC(sc, sc1)

    write !,"[2/6] Ensuring web application...",!
    set sc2 = ..EnsureWebApplication()
    if $$$ISERR(sc2) { write "  FAILED: ", $system.Status.GetErrorText(sc2),! } else { write "  OK",! }
    set sc = $$$ADDSC(sc, sc2)

    write !,"[3/6] Ensuring gateway server profile...",!
    set sc3 = ..EnsureGatewayServerProfile()
    if $$$ISERR(sc3) { write "  FAILED: ", $system.Status.GetErrorText(sc3),! } else { write "  OK",! }
    set sc = $$$ADDSC(sc, sc3)

    write !,"[4/6] Ensuring gateway application mapping...",!
    set sc4 = ..EnsureGatewayApplicationMapping()
    if $$$ISERR(sc4) { write "  FAILED: ", $system.Status.GetErrorText(sc4),! } else { write "  OK",! }
    set sc = $$$ADDSC(sc, sc4)

    write !,"[5/6] Reloading gateway...",!
    set sc5 = ..ReloadGateway()
    if $$$ISERR(sc5) { write "  FAILED: ", $system.Status.GetErrorText(sc5),! } else { write "  OK",! }
    set sc = $$$ADDSC(sc, sc5)

    write !,"[6/6] Verifying setup...",!
    do ..VerifySetup()

    write !,"=== Setup Complete ===",!
    if $$$ISERR(sc) {
        write "WARNING: Some steps had errors. Review output above.",!
    } else {
        write "All steps completed successfully.",!
    }

    return sc
}

/// Create or update SSL/TLS configuration for WebSocket connections.
/// Switches to %SYS namespace to access Security.SSLConfigs.
/// Note: The private key file MUST be readable by the IRIS process user.
/// Copy certs to IRISHealth/mgr/ssl/ and chmod 644 the key before running.
ClassMethod EnsureTLSConfig(pCertFile As %String = {..#CERTFILE}, pKeyFile As %String = {..#KEYFILE}) As %Status
{
    new $namespace
    set $namespace = "%SYS"

    set configName = ..#TLSCONFIGNAME

    // Validate files exist before attempting create/modify
    if '##class(%File).Exists(pCertFile) {
        write "  ERROR: Certificate file not found: ", pCertFile,!
        return $$$ERROR($$$GeneralError, "Certificate file not found: " _ pCertFile)
    }
    if '##class(%File).Exists(pKeyFile) {
        write "  ERROR: Private key file not found: ", pKeyFile,!
        return $$$ERROR($$$GeneralError, "Private key file not found: " _ pKeyFile)
    }

    if ##class(Security.SSLConfigs).Exists(configName) {
        write "  TLS config '", configName, "' exists, updating...",!
        set sc = ##class(Security.SSLConfigs).Get(configName, .props)
        if $$$ISERR(sc) return sc

        set props("CertificateFile") = pCertFile
        set props("PrivateKeyFile") = pKeyFile
        set props("Type") = 1
        set props("Enabled") = 1
        set props("VerifyPeer") = 0

        set sc = ##class(Security.SSLConfigs).Modify(configName, .props)
    } else {
        write "  Creating TLS config '", configName, "'...",!
        // Create with no cert/key first (avoids file-open validation errors),
        // then Modify to add them
        set props("Description") = "TLS config for WebSocket connections (wss://)"
        set props("Type") = 1
        set props("Enabled") = 1
        set props("VerifyPeer") = 0

        set sc = ##class(Security.SSLConfigs).Create(configName, .props)
        if $$$ISERR(sc) return sc

        // Now add cert/key via Modify
        set mProps("CertificateFile") = pCertFile
        set mProps("PrivateKeyFile") = pKeyFile
        set sc = ##class(Security.SSLConfigs).Modify(configName, .mProps)
    }

    if $$$ISERR(sc) {
        write "  HINT: Ensure the key file is readable by the IRIS process (chmod 644).",!
    }

    return sc
}

/// Ensure the /api/ws web application exists with correct settings.
/// Switches to %SYS namespace to access Security.Applications.
ClassMethod EnsureWebApplication() As %Status
{
    new $namespace
    set $namespace = "%SYS"

    set appPath = ..#WEBAPP
    set ns = ..#NAMESPACE

    if ##class(Security.Applications).Exists(appPath) {
        write "  Web app '", appPath, "' exists, updating...",!
        set sc = ##class(Security.Applications).Get(appPath, .props)
        if $$$ISERR(sc) return sc

        set props("NameSpace") = ns
        set props("Type") = 2
        set props("CSPZENEnabled") = 1
        set props("AutheEnabled") = 64
        set props("Enabled") = 1
        set props("IsNameSpaceDefault") = 0
        set props("InbndWebServicesEnabled") = 1

        set sc = ##class(Security.Applications).Modify(appPath, .props)
    } else {
        write "  Creating web app '", appPath, "'...",!
        set props("NameSpace") = ns
        set props("Type") = 2
        set props("CSPZENEnabled") = 1
        set props("AutheEnabled") = 64
        set props("Enabled") = 1
        set props("IsNameSpaceDefault") = 0
        set props("InbndWebServicesEnabled") = 1
        set props("Description") = "WebSocket endpoint for InterClaw"

        set sc = ##class(Security.Applications).Create(appPath, .props)
    }

    return sc
}

/// Verify the gateway server access profile exists in CSP.ini
ClassMethod EnsureGatewayServerProfile() As %Status
{
    set serverName = ..#SERVERNAME
    set iniPath = ..#INIPATH

    if '##class(%File).Exists(iniPath) {
        return $$$ERROR($$$GeneralError, "CSP.ini not found at " _ iniPath)
    }

    set cmd = "grep -c '^\[" _ serverName _ "\]' " _ iniPath
    set rc = $zf(-1, cmd)

    if rc = 0 {
        write "  Server profile '", serverName, "' found in CSP.ini.",!
        return $$$OK
    }

    write "  WARNING: Server profile '", serverName, "' not found in CSP.ini.",!
    return $$$ERROR($$$GeneralError, "Server profile '" _ serverName _ "' not found in CSP.ini")
}

/// Check /api/ws application path mapping in gateway config (CSP.ini).
/// CSP.ini is owned by www-data so IRIS cannot modify it directly.
/// This method only verifies; use sudo from shell to modify.
ClassMethod EnsureGatewayApplicationMapping() As %Status
{
    set appPath = ..#WEBAPP
    set iniPath = ..#INIPATH

    if '##class(%File).Exists(iniPath) {
        return $$$ERROR($$$GeneralError, "CSP.ini not found at " _ iniPath)
    }

    set cmd = "grep -c 'APP_PATH:" _ appPath _ "' " _ iniPath
    set rc = $zf(-1, cmd)

    if rc = 0 {
        write "  App path '", appPath, "' already configured in CSP.ini.",!
        return $$$OK
    }

    write "  App path '", appPath, "' NOT found in CSP.ini.",!
    write "  CSP.ini is owned by www-data - update from shell with sudo.",!
    return $$$ERROR($$$GeneralError, "App path '" _ appPath _ "' missing from CSP.ini")
}

/// Reload the gateway configuration
ClassMethod ReloadGateway() As %Status
{
    write "  Requesting gateway reload...",!
    // The most reliable way to reload is Apache restart, which was done externally.
    // Try to hit the gateway management URL to trigger a config re-read.
    try {
        set req = ##class(%Net.HttpRequest).%New()
        set req.Server = "localhost"
        set req.Port = 80
        set req.Timeout = 5
        set sc = req.Get("/csp/bin/Systems/Module.cxw")
        if $$$ISOK(sc) {
            write "  Gateway management page reachable (HTTP ", req.HttpResponse.StatusCode, ").",!
        } else {
            write "  Note: Could not reach gateway management page.",!
        }
    } catch ex {
        write "  Note: Gateway management request error: ", ex.DisplayString(),!
    }

    write "  Note: Run 'sudo systemctl restart apache2' for a full gateway reload.",!
    return $$$OK
}

/// Verify all components are properly configured
ClassMethod VerifySetup() As %Status
{
    set allOk = 1

    write !,"=== Verification Report ===",!

    // 1. Check TLS config (need %SYS)
    write !,"[TLS Config]",!
    new $namespace
    set $namespace = "%SYS"
    if ##class(Security.SSLConfigs).Exists(..#TLSCONFIGNAME) {
        set sc = ##class(Security.SSLConfigs).Get(..#TLSCONFIGNAME, .props)
        if $$$ISOK(sc) {
            write "  Status: EXISTS",!
            set certFile = $get(props("CertificateFile"), "N/A")
            set keyFile = $get(props("PrivateKeyFile"), "N/A")
            write "  Certificate: ", certFile,!
            write "  Private Key: ", keyFile,!
            write "  Cert on disk: ", $select(##class(%File).Exists(certFile):"YES", 1:"NO (WARNING)"),!
            write "  Key on disk: ", $select(##class(%File).Exists(keyFile):"YES", 1:"NO (WARNING)"),!
            if '##class(%File).Exists(certFile) || '##class(%File).Exists(keyFile) {
                set allOk = 0
            }
        }
    } else {
        write "  Status: MISSING",!
        set allOk = 0
    }

    // 2. Check web application (still in %SYS)
    write !,"[Web Application]",!
    if ##class(Security.Applications).Exists(..#WEBAPP) {
        set sc = ##class(Security.Applications).Get(..#WEBAPP, .appProps)
        if $$$ISOK(sc) {
            write "  Status: EXISTS",!
            write "  Namespace: ", $get(appProps("NameSpace"), "N/A"),!
            write "  Enabled: ", $get(appProps("Enabled"), "N/A"),!
            write "  CSPZENEnabled: ", $get(appProps("CSPZENEnabled"), "N/A"),!
            write "  AutheEnabled: ", $get(appProps("AutheEnabled"), "N/A"),!
        }
    } else {
        write "  Status: MISSING",!
        set allOk = 0
    }

    // Switch back for remaining checks
    set $namespace = "CLAUDE"

    // 3. Check CSP.ini
    write !,"[Gateway Config (CSP.ini)]",!
    set iniPath = ..#INIPATH
    if ##class(%File).Exists(iniPath) {
        write "  CSP.ini: EXISTS",!
        set cmd = "grep -c '^\[IRISHEALTH\]' " _ iniPath
        set rc = $zf(-1, cmd)
        write "  Server 'IRISHEALTH': ", $select(rc=0:"CONFIGURED", 1:"MISSING"),!
        if rc '= 0 set allOk = 0
        set cmd2 = "grep -c 'APP_PATH:/api/ws' " _ iniPath
        set rc2 = $zf(-1, cmd2)
        write "  App path '/api/ws': ", $select(rc2=0:"CONFIGURED", 1:"MISSING"),!
        if rc2 '= 0 set allOk = 0
    } else {
        write "  CSP.ini: NOT FOUND",!
        set allOk = 0
    }

    // 4. Check WebSocket classes
    write !,"[WebSocket Classes]",!
    set echoExists = ##class(%Dictionary.ClassDefinition).%ExistsId("InterClaw.WS.EchoTest")
    write "  InterClaw.WS.EchoTest: ", $select(echoExists:"COMPILED", 1:"MISSING"),!
    if 'echoExists set allOk = 0

    set chatExists = ##class(%Dictionary.ClassDefinition).%ExistsId("InterClaw.WS.Chat")
    write "  InterClaw.WS.Chat: ", $select(chatExists:"COMPILED", 1:"MISSING"),!

    // 5. Expected endpoint URLs
    write !,"[Endpoints]",!
    write "  WSS Echo:   wss://vmdev1.iscinternal.com/irishealth/api/ws/InterClaw.WS.EchoTest.cls",!
    write "  WSS Chat:   wss://vmdev1.iscinternal.com/irishealth/api/ws/InterClaw.WS.Chat.cls",!
    write "  HTTPS Test: https://vmdev1.iscinternal.com/irishealth/api/ws/InterClaw.WS.EchoTest.cls",!

    // 6. Summary
    write !,"=== ", $select(allOk:"ALL CHECKS PASSED", 1:"SOME CHECKS FAILED"), " ===",!

    return $select(allOk:$$$OK, 1:$$$ERROR($$$GeneralError, "One or more verification checks failed"))
}

}
