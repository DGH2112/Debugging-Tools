(**

  This method contains simple types to be used throughout the application.

  @Author  David Hoyle
  @Version 1.3
  @Date    11 Aug 2019

**)
Unit DebuggingTools.Types;

Interface

Type
  (** An enumerate to describe the boolean options for the plug-in. **)
  TDDTCheck = (
    DDTcCodeSiteLogging,  // Check that CodeSiteLogging is in the DPR/DPK unit list.
    DDTcDebuggingDCUs,    // Check that the project has Debugging DCUs checked
    DDTcLibraryPath,      // Check that CodeSite path is in the library
    DDTcLogResult,        // Log the Result of the CodeSite breakpoint to the event log
    DDTcBreak,            // Break at the CodeSite breakpoint
    DDTcEditBreakpoint    // Edit the breakpoint after its added
  );
  (** A set of the above enumerates to describe the options for the plug-in. **)
  TDDTChecks = Set Of TDDTCheck;

Implementation

End.
