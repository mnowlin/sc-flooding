dir.create("data")
dir.create("fig-output")
dir.create("scripts")
dir.create("manuscript")
dir.create("references")
dir.create("presentation")

## set-up manuscript folder 
project_folder <- "/Users/nowlinmc/Dropbox/01-PROJECTS/Research In Progress/sc-flooding/manuscript"

file.copy("/Users/nowlinmc/Dropbox/Projects/Manuscript-files/template.qmd",
          to=project_folder, copy.mode = TRUE)

file.rename("/Users/nowlinmc/Dropbox/01-PROJECTS/Research In Progress/sc-flooding/manuscript/template.qmd", 
            "/Users/nowlinmc/Dropbox/01-PROJECTS/Research In Progress/sc-flooding/manuscript/sc-flooding.qmd")

## find and replace insert with project name
