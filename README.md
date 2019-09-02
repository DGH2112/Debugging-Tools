# Debugging Tools

Author:   David Hoyle

Version:  1.3

Date:     02 Sep 2019

Web Page: http://www.davidghoyle.co.uk/WordPress/?page_id=1777



## Overview

This is a RAD Studio plug-in which adds debugging tools to the IDE (was formally
called Debug with CodeSite).

At the moment there are only 2 tools:
 * Debug with CodeSite - Adds an evaluation breakpoint to the code so you can
                         output debug data to CodeSite without having to alter
                         the code
 * Add Breakpoint      - This adds / opens a breakpoint into the code and
                         displays the full breakpoint editor for changes

## Compilation

This RAD Studio Open Tools API project uses a single DPR/DPROJ file for all
version of RAD Studio from XE2 through to the current 10.3 Tokyo. If you need to
compile the plug-in yourself just option the project in the IDE and compile and
the correct IDE version suffix will be applied to the output DLL.

## Usage

The options are in the main IDEs options page under third parties.

## Current Limitations

It will only save file added to a project - files change that are on a search
path will NOT be saved.

## Binaries

You can download a binary of this project if you don't want to compile it
yourself from the web page above.

