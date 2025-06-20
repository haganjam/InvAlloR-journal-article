
# InvAlloR-journal-article

Repository to produce the analysis and manuscript for a paper (currently in review) based on the R-package: [InvAlloR](https://haganjam.github.io/InvAlloR/).

To reproduce the analyses and manuscript files, download this repository to your computer. This can be done in two ways:

1. with git

in the Terminal:

cd path/to/local/folder

(on your computer - the folder were you want the repository to live) command on Windows might differ. Then, run the following command in the Terminal:

git clone https://github.com/haganjam/InvAlloR-journal-article.git

This should download the repository to the chosen folder.

2. without git

If you don't have git installed, you can download the repository as zip file and save it locally.

--> Clone or download (green button top right) --> Download Zip

then save and extract the zip where you want the directory to be saved on your computer. To run the code correctly, it is important to create a R-Project. In R-Studio go to File > New Project... > Existing Directory > Choose the extracted directory.

## code

To generate the relevant figures and tables, run the scripts (`01 to 04`) sequentially. This will send the relevant figures and tables to the folder: `manuscript/figures-tables/`.

## manuscript

Once the code has been run and all relevant figures and tables have been created, you can render the following *Quarto* files to produce the manuscript, supplement and title page:

+ `manuscript.qmd`
+ `supplement.qmd`
+ `title-page.qmd`

## renv

This project uses the renv R-package for package management. The .lock file contains all relevant information on the packages and the versions of those packages that were used in this project. To reproduce this analysis, users should install the renv R package:

install.packages("renv")
Then run the following code in the console:

renv::restore()
This will create a local copy of all relevant package versions that were used to perform these analyses.
