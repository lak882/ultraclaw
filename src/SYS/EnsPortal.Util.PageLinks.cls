/* Copyright (c) 2026 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Include %syInterop

/// This class is for internal use
Class EnsPortal.Util.PageLinks [ Abstract, Hidden, System = 4 ]
{

Property ruleEditorBaseURL As %String [ InitialExpression = {..GetRuleEditorURL(1)}, Internal ];

Property interopBaseURL As %String [ InitialExpression = {..GetInteropURL(1)}, Internal ];

Property dtlEditorBaseURL As %String [ InitialExpression = {..GetDTLEditorURL(1)}, Internal ];

Property bplEditorBaseURL As %String [ InitialExpression = {..GetBPLEditorURL(1)}, Internal ];

Property messageViewerBaseURL As %String [ InitialExpression = {..GetMessageViewerURL(1)}, Internal ];

/// Always use non-Zen Rule Editor since it has been the default for years
ClassMethod GetRuleEditorURL(pIncludeNamespace As %Boolean = 0, pForceNew As %Boolean = 1) As %String [ CodeMode = expression, Internal, ZenMethod ]
{
..GetURL(pIncludeNamespace, pForceNew, "EnsPortal.RuleConfig.zen", $$$InteropWebAppRoot_"rule-editor/index.html")
}

ClassMethod GetInteropURL(pIncludeNamespace As %Boolean = 0, pForceNew As %Boolean = 0) As %String [ CodeMode = expression, Internal, ZenMethod ]
{
..GetURL(pIncludeNamespace, pForceNew, "EnsPortal.ProductionConfig.zen", $$$InteropWebAppRoot_"interop-editor/index.html")
}

ClassMethod GetDTLEditorURL(pIncludeNamespace As %Boolean = 0, pForceNew As %Boolean = 0) As %String [ CodeMode = expression, Internal, ZenMethod ]
{
..GetURL(pIncludeNamespace, pForceNew, "EnsPortal.DTLEditor.zen", $$$InteropWebAppRoot_"dtl-editor/index.html")
}

ClassMethod GetBPLEditorURL(pIncludeNamespace As %Boolean = 0, pForceNew As %Boolean = 0) As %String [ CodeMode = expression, Internal, ZenMethod ]
{
..GetURL(pIncludeNamespace, pForceNew, "EnsPortal.BPLEditor.zen", $$$InteropWebAppRoot_"bpl-editor/index.html")
}

ClassMethod GetMessageViewerURL(pIncludeNamespace As %Boolean = 0, pForceNew As %Boolean = 0) As %String [ CodeMode = expression, Internal, ZenMethod ]
{
..GetURL(pIncludeNamespace, pForceNew, "EnsPortal.MessageViewer.zen", $$$InteropWebAppRoot_"message-viewer/index.html")
}

ClassMethod GetURL(pIncludeNamespace As %Boolean = 0, pForceNew As %Boolean = 0, pZenURL As %String, pNonZenURL As %String) As %String [ CodeMode = expression, Internal, Private ]
{
$SELECT(pForceNew||(''$GET(^%SYS("Interop","DefaultNewUI"))):pNonZenURL,1:pZenURL) _ $SELECT(pIncludeNamespace:"?$NAMESPACE="_$ZCONVERT($NAMESPACE,"O","URL"),1:"")
}

}
