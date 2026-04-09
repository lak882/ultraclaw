Class InterClaw.ChangeLog Extends %Persistent [ SqlTableName = ChangeLog ]
{

/// When the change was recorded
Property Timestamp As %TimeStamp [ InitialExpression = {$zdatetime($ztimestamp,3)} ];

/// Fully qualified document name (e.g. MyPkg.DTL.Transform.cls)
Property ClassName As %String(MAXLEN = 500) [ Required ];

/// IRIS namespace where the change occurred
Property Namespace As %String(MAXLEN = 100);

/// Type of change: create, push, delete, revert
Property Action As %String(MAXLEN = 50);

/// Lines added in this change
Property LinesAdded As %Integer [ InitialExpression = 0 ];

/// Lines removed in this change
Property LinesRemoved As %Integer [ InitialExpression = 0 ];

/// True if this was a brand-new document (no previous version on server)
Property IsNew As %Boolean [ InitialExpression = 0 ];

/// Who or what made the change
Property ChangedBy As %String(MAXLEN = 200) [ InitialExpression = "InterClaw" ];

/// One-line human-readable summary
Property Summary As %String(MAXLEN = 1000);

Index TimestampIdx On Timestamp;

Index ClassNameIdx On ClassName;

/// Recent changes for a class, newest first.
Query RecentByClass(className As %String, count As %Integer = 20) As %SQLQuery [ SqlProc ]
{
    SELECT TOP :count ID, Timestamp, ClassName, Action, LinesAdded, LinesRemoved, IsNew, Summary
    FROM InterClaw.ChangeLog
    WHERE ClassName = :className
    ORDER BY Timestamp DESC
}

/// All recent changes across all classes, newest first.
Query RecentAll(count As %Integer = 50) As %SQLQuery [ SqlProc ]
{
    SELECT TOP :count ID, Timestamp, ClassName, Action, LinesAdded, LinesRemoved, IsNew, Summary
    FROM InterClaw.ChangeLog
    ORDER BY Timestamp DESC
}

}
