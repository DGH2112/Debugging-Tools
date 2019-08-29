(**

  This method contains simple types to be used throughout the application.

  @Author  David Hoyle
  @Version 1.3
  @Date    29 Aug 2019

  @license
  
    DGH Debugging Tools is a RAD Studio plug-in to provide additional functionality
    in the RAD Studio IDE when debugging.
    
    Copyright (C) 2019  David Hoyle (https://github.com/DGH2112/Debugging-Tools/)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License

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
