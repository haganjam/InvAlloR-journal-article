
# load relevant libraries
library(tibble)
library(knitr)

# Create the table
table_1 <- tribble(
  ~Group1, ~Group2, ~Life_stage, ~Body_size, ~Order, ~Example_taxon,
  "Insecta", "Hemimetabolous", "nymph, adult", "BL", "Ephemeroptera", "Coloburiscus humeralis",
  "", "", "", "", "Plecoptera", "Zelandobius",
  "", "", "", "", "Megaloptera", "Archichauliodes diversus",
  "", "", "", "", "Trichoptera", "Olinga feredayi",
  "", "", "", "", "Odonata", "Erythrodiplax justiniana",
  "", "", "", "", "Hemiptera", "Notonecta",
  "", "Holometabolous", "larva, pupa, adult", "BL", "Diptera", "Austrosimulium",
  "", "", "", "", "Lepidoptera", "Pyralidae",
  "", "", "", "", "Coleoptera", "Tropisternus",
  "Crustacea", "Copepoda", "nauplius, copepodite, adult", "BL", "Calanoida", "Argyrodiaptomus azevedoi",
  "", "", "", "", "Cyclopoida", "Thermocyclops decipiens",
  "", "", "", "", "Harpacticoida", NA,
  "", "Malacostraca", "adult", "BL", "Amphipoda", "Hyalella azteca",
  "", "", "", "", "Isopoda", "Asellidae",
  "", "", "", "", "Decapoda", "Aegla neuquensis",
  "", "Branchiopoda", "adult", "BL", "Diplostraca", "Daphnia gessneri",
  "", "", "", "", "Anostraca", NA,
  "", "", "", "", "Notostraca", "Triops cancriformis",
  "", "", "", "", "Clam shrimps", NA,
  "", "Ostracoda", "adult", "BL", "", NA,
  "Arachnida", "", "adult", "BL", "", NA,
  "Rotifera", "", "adult", "BL", "", "Asplanchna",
  "Tardigrada", "", "adult", "BL", "", NA,
  "Collembola", "", "adult", "BL", "", "Hypogastrura manubrialis",
  "Nematoda", "", "none", "BL", "", NA,
  "Platyhelminthes", "Turbellaria", "none", "BL", "", "Girardia",
  "Annelida", "Oligochaeta", "none", "BL", "", "Limnodrilus",
  "", "Hirudinea", "none", "BL", "", NA,
  "Mollusca", "Gastropoda", "none", "SH", "", "Tarebia granifera",
  "", "Bivalvia", "none", "SW", "", "Ptychobranchus fasciolaris"
)

# print with kable
table_1 <- kable(table_1)

# save as a .rds file
saveRDS(table_1,
        file = "manuscript/figures-tables/table-1.rds")



