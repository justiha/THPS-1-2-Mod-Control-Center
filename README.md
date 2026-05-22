THPS 1+2 Mod Control Center v1.3
The Story Behind the Tool When I first tried creating custom texture and picture replacers for Tony Hawk's Pro Skater 1+2, the game wouldn't recognize my raw files. I knew I needed to pack them into a .pak file, but every YouTube tutorial I found went way too fast or showing tools that were already configured without ever explaining how to actually write or import the setup scripts.
Admittedly, I teamed up with Gemini to help me program or code exactly what I needed from scratch. The result is a clean, interactive command-line toolkit that completely automates the pipeline, and I love how it turned out.

Key Features
Dynamic Three-Way Path Configuration: When launched for the first time, an initialization wizard configures your workspace, your Unreal Engine 4.24 path, and your actual game folder. It fully supports both manual CMD paste mode and native Windows PowerShell popup dialog boxes.
Smart Input Sanitization & Auto-Correction: The tool automatically strips out accidental quotation marks or extra spaces from your paths. If you paste an Unreal Engine directory path and forget to include UnrealPak.exe
at the end, the tool automatically detects it and appends it for you.
Automatic Asset Scan & Sync (Step-by-Step Packing): Instantly scans your staging workspace's \Base
folder for modified assets (.uasset, .ubulk,.uexp), builds a localized system manifest (pack.txt), and compresses them into a custom-named .pak archive using standard Unreal compression.
One-Click Auto-Deploy Pipeline: As soon as your custom .pak file finishes compiling, the script can automatically copy the fresh mod directly over to your live game folder for instant testing.
Flexible Setup Bypassing: Don't want the tool interacting with your live game directory? Simply type skip
or no during setup to completely disable game folder tracking and hide deployment prompts.
Staging vs. Game Archive Inspection (Advanced Menu Selection): Features an advanced sub-menu that lets you scan for .pak files in either your workspace or your live game directory. You can select an archive by number to print its entire internal file hierarchy structure straight to the screen.
Interactive Menu Interface: Displays your current active working directory, selected Unreal Engine version, and live game installation path at the top of the terminal screen in real-time.
One-Click Clean & Uninstall Routines: Includes a maintenance feature to instantly wipe temporary build manifests (pack.txt) and a self-destruct mechanism to completely wipe cached configuration data if you need a fresh reset.
